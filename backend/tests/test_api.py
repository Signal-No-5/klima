"""HTTP smoke + contract tests for the Klima FastAPI surface."""


def test_root_reports_running(client):
    response = client.get("/")
    assert response.status_code == 200
    body = response.json()
    assert "message" in body
    assert "Klima API" in body["message"]


def test_health_ok(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_metrics_exposed(client):
    response = client.get("/metrics")
    assert response.status_code == 200
    content_type = response.headers.get("content-type", "")
    assert "text/plain" in content_type
    assert "http_requests" in response.text or "python_info" in response.text


def test_openapi_available(client):
    response = client.get("/openapi.json")
    assert response.status_code == 200
    body = response.json()
    assert body["info"]["title"] == "Klima API"
    paths = body["paths"]
    assert "/" in paths
    assert "/health" in paths
    assert "/status" in paths


def test_status_returns_audit_buckets(client):
    # Generate at least one audited request first.
    assert client.get("/health").status_code == 200

    response = client.get("/status")
    assert response.status_code == 200
    stats = response.json()["stats"]
    assert set(stats) == {"2xx", "4xx", "5xx"}
    assert isinstance(stats["2xx"], int)
    assert stats["2xx"] >= 1
    assert stats["4xx"] >= 0
    assert stats["5xx"] >= 0


def test_unknown_route_is_404(client):
    response = client.get("/definitely-not-a-route")
    assert response.status_code == 404
