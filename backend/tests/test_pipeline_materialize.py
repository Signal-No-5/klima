"""Offline bronze materialization tests against a temp DuckDB warehouse."""

from __future__ import annotations

from pathlib import Path

import duckdb
import pytest

from pipeline import asset as asset_mod


@pytest.fixture()
def bronze_db(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    path = tmp_path / "bronze.duckdb"
    monkeypatch.setattr(asset_mod.db, "BRONZE", path)
    monkeypatch.setattr(asset_mod.db, "SILVER", tmp_path / "silver.duckdb")
    monkeypatch.setattr(asset_mod.db, "GOLD", tmp_path / "gold.duckdb")
    return path


# Column order must match DataFrame order after _materialize appends inserted_at.
BRONZE_SCHEMA = """
    source_id VARCHAR PRIMARY KEY,
    hazard VARCHAR,
    payload JSON,
    inserted_at TIMESTAMP
"""


def test_materialize_creates_table_and_inserts(bronze_db: Path):
    records = [
        {
            "source_id": "warn-1",
            "hazard": "flood",
            "payload": '{"level": 1}',
        }
    ]
    count = asset_mod._materialize(
        records,
        name="pagasa_warnings",
        stage="bronze",
        schema=BRONZE_SCHEMA,
        dedupe_key="source_id",
        parents=None,
    )
    assert count == 1
    assert bronze_db.exists()

    with duckdb.connect(str(bronze_db), read_only=True) as con:
        rows = con.execute(
            "SELECT source_id, hazard FROM pagasa_warnings"
        ).fetchall()
    assert rows == [("warn-1", "flood")]


def test_materialize_dedupes_on_key(bronze_db: Path):
    first = [
        {"source_id": "warn-1", "hazard": "flood", "payload": "{}"},
        {"source_id": "warn-2", "hazard": "typhoon", "payload": "{}"},
    ]
    second = [
        {"source_id": "warn-1", "hazard": "flood", "payload": "{}"},
        {"source_id": "warn-3", "hazard": "heat", "payload": "{}"},
    ]
    asset_mod._materialize(
        first, "pagasa_warnings", "bronze", BRONZE_SCHEMA, "source_id", None
    )
    asset_mod._materialize(
        second, "pagasa_warnings", "bronze", BRONZE_SCHEMA, "source_id", None
    )

    with duckdb.connect(str(bronze_db), read_only=True) as con:
        ids = {
            row[0]
            for row in con.execute("SELECT source_id FROM pagasa_warnings").fetchall()
        }
    assert ids == {"warn-1", "warn-2", "warn-3"}


def test_materialize_rejects_bad_return_type(bronze_db: Path):
    with pytest.raises(TypeError):
        asset_mod._materialize(
            "not-a-frame",
            name="bad",
            stage="bronze",
            schema="id VARCHAR",
            dedupe_key=None,
            parents=None,
        )
