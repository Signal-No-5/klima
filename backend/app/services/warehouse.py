"""Read-only access to the DuckDB medallion warehouse.

The API never writes to the warehouse; the pipeline in ``backend/pipeline`` owns
that. Reads are opened read-only and per-request so a concurrent pipeline run
cannot be blocked by a long-lived API connection.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

import duckdb

from pipeline.config import db


def silver_path() -> Path:
    """Resolved silver warehouse path, honouring ``KLIMA_DATA_DIR``."""
    return db.SILVER


def is_available(path: Path | None = None) -> bool:
    target = path or silver_path()
    return target.exists()


def query(sql: str, path: Path | None = None) -> list[dict[str, Any]]:
    """Run ``sql`` against the silver warehouse, returning dict rows.

    Yields an empty list when the warehouse file has not been built yet so the
    API degrades to "no data" instead of a 500.
    """
    target = path or silver_path()
    if not target.exists():
        return []

    with duckdb.connect(str(target), read_only=True) as con:
        cursor = con.execute(sql)
        columns = [column[0] for column in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


def table_exists(name: str, path: Path | None = None) -> bool:
    target = path or silver_path()
    if not target.exists():
        return False
    with duckdb.connect(str(target), read_only=True) as con:
        tables = {row[0] for row in con.execute("SHOW TABLES").fetchall()}
    return name in tables
