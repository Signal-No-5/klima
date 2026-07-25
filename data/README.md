# `data/` — Klima ETL package

Canonical home for the PAGASA bronze pipeline and DuckDB warehouse (**issue #8**).

## Install

```bash
cd data
uv sync
```

## Run bronze ingest

Documented entrypoint (prefer the venv interpreter if `uv run` misbehaves):

```bash
# Offline / fixture mode (no live PAGASA access) — verified for MVP
.venv/bin/python -m pipeline pagasa_warnings --offline

# Or via console script after sync:
.venv/bin/klima-etl pagasa_warnings --offline

# Live PAGASA (needs network); on failure, clear error unless:
.venv/bin/python -m pipeline pagasa_warnings --offline-fallback
```

DuckDB outputs:

```text
data/warehouse/bronze.duckdb
data/warehouse/silver.duckdb
data/warehouse/gold.duckdb
```

Inspect bronze rows:

```bash
.venv/bin/python -c "
import duckdb
from pipeline.config import db
con = duckdb.connect(str(db.BRONZE), read_only=True)
print(con.execute('SHOW TABLES').fetchall())
print(con.execute('SELECT COUNT(*) FROM pagasa_warnings').fetchone())
"
```

## Layout

```text
data/
├── pipeline/           # installable Python package (one implementation)
│   ├── asset.py
│   ├── cli.py          # klima-etl / python -m pipeline
│   ├── config/
│   ├── refinery/bronze/pagasa_warnings.py
│   └── utils/
├── fixtures/           # offline PAGASA ActiveWarning JSON
├── warehouse/          # DuckDB bronze/silver/gold files
└── pyproject.toml      # klima-data (uv)
```

## Backend relationship

`backend/` path-depends on this package (`klima-data` editable). There is **no** second copy of the pipeline under `backend/pipeline/`. The API reads bronze from `data/warehouse/bronze.duckdb`. Compatibility CLI: `backend/scripts/run_pipeline.py` → `pipeline.cli`.

## Still stubbed

- Silver/gold transforms (empty refinery stages)
- Orchestration / scheduling (`pipeline/orchestration/`)
- Additional bronze sources beyond PAGASA warnings
