"""Shared fixtures for backend API tests."""

from __future__ import annotations

import os
from datetime import datetime, timedelta
from pathlib import Path

import pytest

# Fixture advisories are anchored to run time so expiry filtering is testable
# without freezing the clock.
NOW = datetime.now()

SILVER_COLUMNS = (
    "source_id VARCHAR",
    "bronze_source_id VARCHAR",
    "hazard VARCHAR",
    "hazard_class VARCHAR",
    "severity_code VARCHAR",
    "severity_rank INTEGER",
    "severity_label VARCHAR",
    "region VARCHAR",
    "areas VARCHAR",
    "issued_at TIMESTAMP",
    "expired_at TIMESTAMP",
    "centroid_lat DOUBLE",
    "centroid_lon DOUBLE",
    "alert_url VARCHAR",
    "description VARCHAR",
    "inserted_at TIMESTAMP",
)


def _row(**overrides):
    row = {
        "source_id": "fixture-1",
        "bronze_source_id": "bronze-1",
        "hazard": "General Flood Advisory",
        "hazard_class": "flood-warning",
        "severity_code": "4Extreme",
        "severity_rank": 4,
        "severity_label": "Extreme",
        "region": "Region 3 (Central Luzon)",
        "areas": "Bulacan, Pampanga",
        "issued_at": NOW - timedelta(hours=1),
        "expired_at": NOW + timedelta(hours=11),
        "centroid_lat": 14.9167,
        "centroid_lon": 120.7667,
        "alert_url": "https://www.panahon.gov.ph/public-alerts/fixture-1",
        "description": "Flooding is expected in low-lying areas.",
        "inserted_at": NOW,
    }
    row.update(overrides)
    return row


SILVER_ROWS = [
    _row(),
    _row(
        source_id="fixture-2",
        severity_code="3Severe",
        severity_rank=3,
        severity_label="Severe",
        region="NCR (National Capital Region)",
        areas="Metro Manila",
        centroid_lat=14.5987,
        centroid_lon=121.033,
        issued_at=NOW - timedelta(hours=2),
    ),
    _row(
        source_id="fixture-expired",
        region="Region 1 (Ilocos Region)",
        areas="Pangasinan",
        issued_at=NOW - timedelta(days=2),
        expired_at=NOW - timedelta(days=1),
    ),
    _row(
        source_id="fixture-cyclone",
        hazard="Tropical Cyclone Alert",
        hazard_class=None,
        severity_code=None,
        severity_rank=None,
        severity_label=None,
        region="Region 2 (Cagayan Valley)",
        areas="Isabela, Cagayan",
        centroid_lat=17.5,
        centroid_lon=121.6,
    ),
    # Unmappable: no centroid to place on the map.
    _row(source_id="fixture-no-centroid", centroid_lat=None, centroid_lon=None),
    _row(
        source_id="fixture-nationwide",
        hazard="Tropical Cyclone Alert",
        hazard_class=None,
        severity_code=None,
        severity_rank=None,
        severity_label=None,
        region="Philippine Area of Responsibility",
        areas="Philippine Area of Responsibility",
        centroid_lat=13.0,
        centroid_lon=122.0,
        issued_at=NOW - timedelta(hours=3),
    ),
]


@pytest.fixture(scope="session")
def sqlite_file(tmp_path_factory: pytest.TempPathFactory) -> Path:
    path = tmp_path_factory.mktemp("db") / "test-klima.db"
    os.environ["SQLITE_FILE"] = str(path)
    os.environ["LOG_LEVEL"] = "ERROR"
    os.environ["DB_ACTIVE"] = "sqlite"
    return path


@pytest.fixture(scope="session")
def silver_fixture(tmp_path_factory: pytest.TempPathFactory):
    """Build a throwaway silver warehouse and point the API at it.

    Patching ``pipeline.config.db.SILVER`` rather than ``KLIMA_DATA_DIR`` keeps
    the fixture independent of module import order.
    """
    import duckdb

    from pipeline.config import db

    path = tmp_path_factory.mktemp("silver") / "silver.duckdb"
    with duckdb.connect(str(path)) as con:
        con.execute(f"CREATE TABLE hazard_warnings ({', '.join(SILVER_COLUMNS)})")
        columns = list(SILVER_ROWS[0])
        placeholders = ", ".join("?" for _ in columns)
        con.executemany(
            f"INSERT INTO hazard_warnings ({', '.join(columns)}) "
            f"VALUES ({placeholders})",
            [[row[column] for column in columns] for row in SILVER_ROWS],
        )

    with pytest.MonkeyPatch.context() as patch:
        patch.setattr(db, "SILVER", path)
        yield path


@pytest.fixture(scope="session")
def app(sqlite_file: Path, silver_fixture: Path):
    # Import only after SQLITE_FILE is set so Database binds to the temp file.
    from app.main import app as fastapi_app

    return fastapi_app


@pytest.fixture()
def client(app):
    from fastapi.testclient import TestClient

    with TestClient(app) as test_client:
        yield test_client
