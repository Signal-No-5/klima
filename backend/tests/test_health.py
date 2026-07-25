"""API smoke tests for the imported klima-api backend."""

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root_reports_running():
    response = client.get("/")
    assert response.status_code == 200
    body = response.json()
    assert "message" in body
    assert "Klima API" in body["message"]


def test_health_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_metrics_exposed():
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "text/plain" in response.headers.get("content-type", "")
