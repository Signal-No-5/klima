"""Contract tests for the mobile-facing Klima endpoints.

Paths and query parameters mirror ``mobile/lib/services/api_service.dart``; a
rename there without a change here should fail these tests.
"""

from __future__ import annotations

from datetime import UTC, datetime

import pytest
from klima_schema import CommunityPostOut, HazardOut, ReportOut, RiskOut, SafeZoneOut


def _validate_all(model, payload):
    return [model.model_validate(item) for item in payload]


class TestHazardLatest:
    def test_returns_active_advisories_newest_first(self, client):
        response = client.get("/hazard/latest")
        assert response.status_code == 200
        hazards = _validate_all(HazardOut, response.json())

        ids = [hazard.id for hazard in hazards]
        assert "fixture-1" in ids
        assert "fixture-expired" not in ids, "expired advisories must be filtered"
        assert "fixture-no-centroid" not in ids, "unmappable rows must be dropped"
        timestamps = [hazard.timestamp for hazard in hazards]
        assert timestamps == sorted(timestamps, reverse=True)

    def test_severity_and_type_are_normalized(self, client):
        hazards = _validate_all(HazardOut, client.get("/hazard/latest").json())
        by_id = {hazard.id: hazard for hazard in hazards}

        assert by_id["fixture-1"].severity == "critical"
        assert by_id["fixture-1"].type == "flood"
        assert by_id["fixture-2"].severity == "high"
        # No severity bucket published; must not be invented as low or critical.
        assert by_id["fixture-cyclone"].severity == "moderate"
        assert by_id["fixture-cyclone"].type == "typhoon"

    def test_region_coverage_is_preserved_in_metadata(self, client):
        hazards = _validate_all(HazardOut, client.get("/hazard/latest").json())
        hazard = next(item for item in hazards if item.id == "fixture-1")

        assert hazard.metadata is not None
        assert hazard.metadata["region"] == "Region 3 (Central Luzon)"
        assert hazard.metadata["areas"] == ["Bulacan", "Pampanga"]
        assert hazard.source == "pagasa"
        assert hazard.is_verified is True

    def test_type_filter(self, client):
        response = client.get("/hazard/latest", params={"type": "typhoon"})
        hazards = _validate_all(HazardOut, response.json())
        assert {hazard.id for hazard in hazards} == {
            "fixture-cyclone",
            "fixture-nationwide",
        }

    def test_place_filter_matches_covered_areas(self, client):
        response = client.get("/hazard/latest", params={"municipality": "Bulacan"})
        ids = {item["id"] for item in response.json()}
        assert "fixture-1" in ids, "Bulacan is a listed area of fixture-1"
        assert "fixture-2" not in ids, "Metro Manila advisory must not leak"

    def test_nationwide_advisory_reaches_every_place(self, client):
        """A cyclone alert scoped to the whole PAR covers any queried place."""
        response = client.get("/hazard/latest", params={"barangay": "Nowhere At All"})
        ids = {item["id"] for item in response.json()}
        assert ids == {"fixture-nationwide"}

    def test_include_expired_opt_in(self, client):
        response = client.get("/hazard/latest", params={"include_expired": True})
        ids = {item["id"] for item in response.json()}
        assert "fixture-expired" in ids

    def test_limit_is_bounded(self, client):
        assert client.get("/hazard/latest", params={"limit": 1}).json().__len__() == 1
        assert client.get("/hazard/latest", params={"limit": 0}).status_code == 422


class TestReports:
    payload = {
        "id": "",
        "user_id": "u-1",
        "user_name": "Juana",
        "type": "hazard",
        "hazard_type": "flood",
        "title": "Baha sa Iba Este",
        "description": "Tuhod na ang tubig.",
        "latitude": 14.9167,
        "longitude": 120.7667,
        "barangay": "Iba Este",
        "municipality": "Calumpit",
        "timestamp": "2026-07-25T18:00:00+08:00",
        "image_url": None,
        "image_urls": None,
        "status": "pending",
        "responder_notes": None,
        "responded_at": None,
    }

    def test_submit_assigns_id_when_mobile_sends_blank(self, client):
        response = client.post("/reports", json=self.payload)
        assert response.status_code == 201
        report = ReportOut.model_validate(response.json())
        assert report.id, "server must mint an id for offline-queued reports"
        assert report.barangay == "Iba Este"

    def test_submitted_report_is_listed_and_filterable(self, client):
        created = ReportOut.model_validate(
            client.post("/reports", json={**self.payload, "id": "report-listed"}).json()
        )

        listed = _validate_all(ReportOut, client.get("/reports").json())
        assert created.id in {report.id for report in listed}

        filtered = client.get("/reports", params={"barangay": "Iba Este"}).json()
        assert "report-listed" in {item["id"] for item in filtered}

        empty = client.get("/reports", params={"barangay": "Elsewhere"}).json()
        assert empty == []

    def test_unknown_field_is_rejected(self, client):
        response = client.post("/reports", json={**self.payload, "rogue": "field"})
        assert response.status_code == 422

    def test_out_of_range_coordinates_are_rejected(self, client):
        response = client.post("/reports", json={**self.payload, "latitude": 120.0})
        assert response.status_code == 422

    def test_unknown_status_is_rejected(self, client):
        response = client.post("/reports", json={**self.payload, "status": "made-up"})
        assert response.status_code == 422


class TestRisk:
    def test_known_barangay_composes_risk_from_live_hazards(self, client):
        response = client.get("/risk/calumpit-iba-este")
        assert response.status_code == 200
        risk = RiskOut.model_validate(response.json())

        assert risk.barangay_name == "Iba Este"
        assert risk.municipality == "Calumpit"
        # The Bulacan-wide extreme advisory must reach the barangay, and the
        # nationwide cyclone alert contributes its own hazard type.
        assert risk.hazard_score == 1.0
        assert risk.hazard_breakdown == {"flood": 1.0, "typhoon": 0.5}
        assert risk.risk_level == "critical"
        assert risk.active_warnings

    def test_score_matches_documented_weights(self, client):
        risk = RiskOut.model_validate(client.get("/risk/calumpit-iba-este").json())
        expected = (
            0.5 * risk.hazard_score
            + 0.3 * risk.exposure_score
            + 0.2 * risk.vulnerability_score
        )
        assert risk.risk_score == pytest.approx(expected, abs=1e-4)

    def test_lookup_by_name_is_accepted(self, client):
        by_id = client.get("/risk/calumpit-iba-este").json()
        by_name = client.get("/risk/Iba Este").json()
        assert by_name["barangay_id"] == by_id["barangay_id"]

    def test_unknown_barangay_is_404(self, client):
        assert client.get("/risk/not-a-barangay").status_code == 404

    def test_index_lists_baselines(self, client):
        ids = client.get("/risk").json()
        assert "calumpit-iba-este" in ids
        assert len(ids) == 24


class TestSafeZones:
    def test_seed_zones_satisfy_the_contract(self, client):
        response = client.get("/safezones")
        assert response.status_code == 200
        zones = _validate_all(SafeZoneOut, response.json())
        assert zones
        assert all(-90 <= zone.latitude <= 90 for zone in zones)

    def test_filters(self, client):
        by_barangay = client.get("/safezones", params={"barangay": "Iba Este"}).json()
        assert {zone["id"] for zone in by_barangay} == {"calumpit-nhs"}

        by_municipality = client.get(
            "/safezones", params={"municipality": "Calumpit"}
        ).json()
        assert len(by_municipality) == len(client.get("/safezones").json())

        assert client.get("/safezones", params={"barangay": "Nowhere"}).json() == []


class TestCommunity:
    def test_pinned_posts_come_first(self, client):
        response = client.get("/community/posts")
        assert response.status_code == 200
        posts = _validate_all(CommunityPostOut, response.json())
        assert posts

        pinned = [index for index, post in enumerate(posts) if post.is_pinned]
        unpinned = [index for index, post in enumerate(posts) if not post.is_pinned]
        assert not unpinned or max(pinned) < min(unpinned)

    def test_barangay_filter_uses_tags(self, client):
        posts = client.get("/community/posts", params={"barangay": "Iba Este"}).json()
        assert {post["id"] for post in posts} == {
            "calumpit-evacuation-reminder-iba-este"
        }


class TestReadiness:
    def test_reports_warehouse_and_seed_state(self, client):
        response = client.get("/health/ready")
        assert response.status_code == 200
        body = response.json()

        assert body["status"] == "ok"
        silver = body["checks"]["silver_warehouse"]
        assert silver["present"] is True
        assert silver["hazard_table"] is True
        assert silver["active_advisories"] >= 1
        assert body["checks"]["seed"]["barangay_baselines"] == 24


class TestOpenAPI:
    def test_every_mobile_path_is_published(self, client):
        paths = client.get("/openapi.json").json()["paths"]
        for path in (
            "/hazard/latest",
            "/reports",
            "/risk/{barangay_id}",
            "/safezones",
            "/community/posts",
            "/health",
            "/health/ready",
        ):
            assert path in paths, f"{path} missing from the published API"


def test_seed_timestamps_are_timezone_aware():
    """Naive seed timestamps would sort inconsistently against live data."""
    from app.services import seed

    for post in seed.community_posts():
        assert post.timestamp.tzinfo is not None
        assert post.timestamp <= datetime.now(UTC)
