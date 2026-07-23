"""Tests for mobile-facing Klima endpoints."""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services import klima as klima_service


@pytest.fixture
def client():
    klima_service.clear_reports_for_tests()
    with TestClient(app) as c:
        yield c
    klima_service.clear_reports_for_tests()


def test_hazard_latest_returns_array(client: TestClient):
    res = client.get("/hazard/latest")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    item = data[0]
    for key in (
        "id",
        "type",
        "title",
        "description",
        "latitude",
        "longitude",
        "barangay",
        "municipality",
        "province",
        "severity",
        "timestamp",
        "source",
        "is_verified",
        "upvotes",
        "reports",
    ):
        assert key in item


def test_hazard_latest_also_under_api_v1(client: TestClient):
    res = client.get("/api/v1/hazard/latest")
    assert res.status_code == 200
    assert isinstance(res.json(), list)


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
    body = created.json()
    assert body["title"] == "Test flood"
    assert body["id"]

    listed = client.get("/reports", params={"barangay": "Iba Este"})
    assert listed.status_code == 200
    assert any(r["id"] == body["id"] for r in listed.json())


def test_risk_by_barangay(client: TestClient):
    res = client.get("/risk/iba-este")
    assert res.status_code == 200
    data = res.json()
    assert data["barangay_id"] == "iba-este"
    assert "risk_score" in data
    assert "risk_level" in data


def test_safezones(client: TestClient):
    res = client.get("/safezones", params={"municipality": "Calumpit"})
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert "latitude" in data[0]
    assert "current_occupancy" in data[0]


def test_community_posts(client: TestClient):
    res = client.get("/community/posts")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert "author_name" in data[0]
    assert "is_pinned" in data[0]


def test_root_health_still_works(client: TestClient):
    assert client.get("/").status_code == 200
    assert client.get("/health").status_code == 200
