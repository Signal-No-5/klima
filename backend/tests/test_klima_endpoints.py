"""Tests for mobile-facing Klima endpoints (schema-backed responses)."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient
from klima_schema import (
    CommunityPostOut,
    HazardOut,
    ReportOut,
    RiskOut,
    SafeZoneOut,
)

from app.main import app
from app.services import klima as klima_service


@pytest.fixture
def client():
    klima_service.clear_reports_for_tests()
    with TestClient(app) as c:
        yield c
    klima_service.clear_reports_for_tests()


def test_hazard_latest_returns_schema_valid_array(client: TestClient):
    res = client.get("/hazard/latest")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    parsed = [HazardOut.model_validate(item) for item in data]
    assert parsed[0].id
    assert parsed[0].type
    assert parsed[0].title


def test_hazard_latest_also_under_api_v1(client: TestClient):
    res = client.get("/api/v1/hazard/latest")
    assert res.status_code == 200
    assert isinstance(res.json(), list)
    HazardOut.model_validate(res.json()[0])


def test_reports_post_and_get(client: TestClient):
    payload = {
        "user_id": "u1",
        "user_name": "Tester",
        "type": "hazard",
        "hazard_type": "flood",
        "title": "Test flood",
        "description": "Knee-deep water",
        "latitude": 14.9167,
        "longitude": 120.7667,
        "barangay": "Iba Este",
        "municipality": "Calumpit",
    }
    created = client.post("/reports", json=payload)
    assert created.status_code == 201
    body = ReportOut.model_validate(created.json())
    assert body.title == "Test flood"
    assert body.id

    listed = client.get("/reports", params={"barangay": "Iba Este"})
    assert listed.status_code == 200
    reports = [ReportOut.model_validate(r) for r in listed.json()]
    assert any(r.id == body.id for r in reports)


def test_risk_by_barangay(client: TestClient):
    res = client.get("/risk/iba-este")
    assert res.status_code == 200
    data = RiskOut.model_validate(res.json())
    assert data.barangay_id == "iba-este"
    assert data.risk_score >= 0
    assert data.risk_level


def test_safezones(client: TestClient):
    res = client.get("/safezones", params={"municipality": "Calumpit"})
    assert res.status_code == 200
    data = [SafeZoneOut.model_validate(z) for z in res.json()]
    assert len(data) >= 1
    assert data[0].latitude
    assert data[0].current_occupancy >= 0


def test_community_posts(client: TestClient):
    res = client.get("/community/posts")
    assert res.status_code == 200
    data = [CommunityPostOut.model_validate(p) for p in res.json()]
    assert len(data) >= 1
    assert data[0].author_name
    assert isinstance(data[0].is_pinned, bool)


def test_root_health_still_works(client: TestClient):
    root = client.get("/")
    assert root.status_code == 200
    health = client.get("/health")
    assert health.status_code == 200
    body = health.json()
    assert body["status"] == "ok"
    assert body["service"] == "klima-api"
    assert "bronze_db" in body
