# Data / ETL

`data/` is the **canonical ETL package** (`klima-data`) and owns the DuckDB warehouse. There is exactly one implementation of the pipeline — the backend reads the warehouse, it does not define it.

## Install

```bash
cd data
uv sync
```

## Run the bronze ingest

Prefer the venv interpreter if `uv run` misbehaves on your machine:

```bash
# Offline / fixture mode (no live PAGASA access) — the MVP-verified path
.venv/bin/python -m pipeline pagasa_warnings --offline

# Console script, after sync
.venv/bin/klima-etl pagasa_warnings --offline

# Live PAGASA needs network; fall back to fixtures on failure
.venv/bin/python -m pipeline pagasa_warnings --offline-fallback
```

Today the only registered asset is `pagasa_warnings`.

## DuckDB files

```text
data/warehouse/bronze.duckdb
data/warehouse/silver.duckdb
data/warehouse/gold.duckdb
```

`backend/` reads `data/warehouse/bronze.duckdb` and falls back to fixtures when it is missing, empty, or unreadable.

Silver/gold transforms are empty stages, and there is no scheduler — do not assume a full medallion job graph.

## Layout

```text
data/
├── pipeline/           # installable package (asset, CLI, refinery, config)
├── fixtures/           # offline PAGASA ActiveWarning JSON
├── warehouse/          # DuckDB bronze/silver/gold
└── pyproject.toml      # klima-data (uv)
```

## Related

- [Backend quickstart](/guide/backend)
- [Monorepo layout](/layout)
