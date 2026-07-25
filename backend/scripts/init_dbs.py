#!/usr/bin/env python3
"""Initialize DuckDB warehouse files under the data package (not backend/data)."""

from __future__ import annotations

import duckdb

from pipeline.config import db

DBS = {
    "bronze": db.BRONZE,
    "silver": db.SILVER,
    "gold": db.GOLD,
}


def init_databases() -> None:
    """Create the 3-tier DuckDB databases if they don't exist."""
    db.WAREHOUSE_DIR.mkdir(parents=True, exist_ok=True)

    for name, db_path in DBS.items():
        if not db_path.exists():
            print(f"Creating {name} database at {db_path}")
            duckdb.connect(str(db_path)).close()
        else:
            print(f"The {name} database already exists at {db_path}")


if __name__ == "__main__":
    init_databases()
    print("All DuckDB databases have been initialized")
