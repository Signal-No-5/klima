"""DuckDB warehouse paths for the Klima medallion pipeline.

Canonical outputs live under ``data/warehouse/`` (package root), not under
``backend/data/``.
"""

from __future__ import annotations

import os
from pathlib import Path

# data/ (package root): pipeline/config/db.py → parents[2]
PACKAGE_ROOT = Path(__file__).resolve().parents[2]

# Allow override for tests / alternate checkouts
WAREHOUSE_DIR = Path(
    os.environ.get("KLIMA_WAREHOUSE_DIR", str(PACKAGE_ROOT / "warehouse"))
).resolve()

BRONZE = WAREHOUSE_DIR / "bronze.duckdb"
SILVER = WAREHOUSE_DIR / "silver.duckdb"
GOLD = WAREHOUSE_DIR / "gold.duckdb"

FIXTURES_DIR = Path(
    os.environ.get("KLIMA_FIXTURES_DIR", str(PACKAGE_ROOT / "fixtures"))
).resolve()
