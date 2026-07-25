"""Shared medallion pipeline runner used by the CLI and helper scripts.

Keeps one implementation of stage ordering, reset, and summaries so the
container entrypoint and the ``scripts/run_*.py`` wrappers never drift.
"""

from __future__ import annotations

from pathlib import Path

import duckdb

from pipeline.config import db
from pipeline.refinery.bronze.pagasa_warnings import pagasa_warnings
from pipeline.refinery.silver.hazard_warnings import hazard_warnings

# Stage name -> ordered asset callables. Ingest order matters (silver reads
# bronze), so ``all`` runs these top-to-bottom.
STAGES: dict[str, list] = {
    "bronze": [pagasa_warnings],
    "silver": [hazard_warnings],
}

# Stage name -> attribute on pipeline.config.db holding its warehouse path.
_STAGE_DB = {
    "bronze": "BRONZE",
    "silver": "SILVER",
    "gold": "GOLD",
}


def stage_db_path(stage: str) -> Path:
    attr = _STAGE_DB.get(stage)
    if attr is None:
        raise ValueError(f"Unknown stage {stage!r}")
    return Path(getattr(db, attr))


def ensure_data_dir() -> None:
    db.DATA_DIR.mkdir(parents=True, exist_ok=True)


def reset_stage(stage: str) -> None:
    """Drop and recreate an empty warehouse file for ``stage``."""
    ensure_data_dir()
    path = stage_db_path(stage)
    if path.exists():
        path.unlink()
    duckdb.connect(str(path)).close()
    print(f"Reset {path}")


def run_stage(stage: str) -> None:
    if stage not in STAGES:
        raise ValueError(f"Unknown stage {stage!r}; choose from {list(STAGES)}")
    ensure_data_dir()
    for asset in STAGES[stage]:
        print(f"Running {stage} asset: {asset.__name__}")
        asset()


def run_all() -> None:
    for stage in STAGES:
        run_stage(stage)


def summarize(stage: str, limit: int = 20) -> None:
    path = stage_db_path(stage)
    if not path.exists():
        print(f"{stage}: no warehouse at {path}")
        return
    with duckdb.connect(str(path), read_only=True) as con:
        tables = [row[0] for row in con.execute("SHOW TABLES").fetchall()]
        print(f"\n{stage} warehouse: {path.resolve()}")
        print(f"Tables: {tables or '(none)'}")
        for table in tables:
            rows = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            print(f"\n{table}: {rows} row(s)")
            if rows:
                print(
                    con.execute(f"SELECT * FROM {table} LIMIT {limit}")
                    .fetchdf()
                    .to_string(index=False)
                )
