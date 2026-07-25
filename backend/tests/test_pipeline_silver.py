"""Silver hazard_warnings flattening tests (offline, temp DuckDB)."""

from __future__ import annotations

import json
from pathlib import Path

import duckdb
import pytest

from pipeline.refinery.silver import hazard_warnings as silver


def _seed_bronze(path: Path) -> None:
    payload_flood = {
        "4Extreme": {
            "class": "severe-flood-warning",
            "iconUrl": "https://example/icon.png",
            "regions": {
                "Region 4-B (MIMAROPA)": {
                    "areas": "Palawan, Romblon",
                    "issued_at": "2026-07-25 17:33:50",
                    "expired_at": "2026-07-26 05:33:50",
                    "url": "https://panahon.example/a",
                    "description": "Heavy rain <br />\r\n**Palawan** rivers.",
                    "centroid": {"latitude": 12.35, "longitude": 121.01},
                    "tooltip": "x",
                }
            },
        },
        "3Severe": {
            "class": "flood-warning",
            "regions": {
                "NCR (National Capital Region)": {
                    "areas": "Metro Manila",
                    "issued_at": "2026-07-25 17:35:42",
                    "expired_at": "2026-07-26 05:35:42",
                    "url": "https://panahon.example/b",
                    "description": "Flooding likely.",
                    # centroid values as strings, like the live API
                    "centroid": {"latitude": "14.5987", "longitude": "121.033"},
                }
            },
        },
    }
    payload_tc = [
        {
            "class": "tropical-cyclone-alert",
            "iconUrl": "https://example/tc.png",
            "regions": {
                "Philippine Area of Responsibility": {
                    "area": "Philippine Area of Responsibility",
                    "issued_at": "2026-07-25 10:48:59",
                    "expired_at": "2026-07-25 23:48:26",
                    "url": "https://meteo.example/c",
                    "description": "KIYAPO maintains strength.",
                    "centroid": {"latitude": "12.25", "longitude": "122.05"},
                }
            },
        }
    ]

    with duckdb.connect(str(path)) as con:
        con.execute(
            """
            CREATE TABLE pagasa_warnings (
                source_id VARCHAR PRIMARY KEY,
                hazard VARCHAR,
                payload JSON,
                inserted_at TIMESTAMP
            )
            """
        )
        con.execute(
            "INSERT INTO pagasa_warnings VALUES (?, ?, ?, now())",
            ["b1", "General Flood Advisory", json.dumps(payload_flood)],
        )
        con.execute(
            "INSERT INTO pagasa_warnings VALUES (?, ?, ?, now())",
            ["b2", "Tropical Cyclone Alert", json.dumps(payload_tc)],
        )


@pytest.fixture()
def warehouse(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    bronze = tmp_path / "bronze.duckdb"
    silver_db = tmp_path / "silver.duckdb"
    _seed_bronze(bronze)
    monkeypatch.setattr(silver.db, "BRONZE", bronze)
    monkeypatch.setattr(silver.db, "SILVER", silver_db)
    return silver_db


def _rows(silver_db: Path):
    with duckdb.connect(str(silver_db), read_only=True) as con:
        return con.execute(
            """
            SELECT hazard, severity_code, severity_rank, severity_label,
                   region, areas, centroid_lat, centroid_lon, description
            FROM hazard_warnings
            ORDER BY severity_rank DESC NULLS LAST, region
            """
        ).fetchdf()


def test_flattens_flood_and_tc(warehouse: Path):
    silver.hazard_warnings()
    df = _rows(warehouse)
    assert len(df) == 3

    extreme = df[df["severity_code"] == "4Extreme"].iloc[0]
    assert extreme["severity_rank"] == 4
    assert extreme["severity_label"] == "Extreme"
    assert extreme["hazard"] == "General Flood Advisory"
    assert abs(extreme["centroid_lat"] - 12.35) < 1e-6

    tc = df[df["hazard"] == "Tropical Cyclone Alert"].iloc[0]
    assert tc["severity_code"] is None
    assert tc["region"] == "Philippine Area of Responsibility"
    # falls back to singular "area"
    assert tc["areas"] == "Philippine Area of Responsibility"


def test_string_centroids_cast_to_float(warehouse: Path):
    silver.hazard_warnings()
    df = _rows(warehouse)
    ncr = df[df["region"] == "NCR (National Capital Region)"].iloc[0]
    assert abs(ncr["centroid_lat"] - 14.5987) < 1e-4
    assert abs(ncr["centroid_lon"] - 121.033) < 1e-4


def test_description_html_stripped(warehouse: Path):
    silver.hazard_warnings()
    df = _rows(warehouse)
    extreme = df[df["severity_code"] == "4Extreme"].iloc[0]
    desc = extreme["description"]
    assert "<br" not in desc
    assert "**" not in desc
    assert "Palawan rivers." in desc


def test_rerun_is_idempotent(warehouse: Path):
    silver.hazard_warnings()
    silver.hazard_warnings()
    df = _rows(warehouse)
    assert len(df) == 3
