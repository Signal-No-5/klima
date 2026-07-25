# `data/` — scaffold

This package is a **pointer**, not a second pipeline.

## Where ETL actually lives

All bronze/silver/gold assets and DuckDB wiring live in:

```text
../backend/pipeline/
```

Run the PAGASA bronze asset from the API package:

```bash
cd ../backend
uv run python scripts/run_pipeline.py pagasa_warnings
```

DuckDB files used by the API:

```text
../backend/data/bronze.duckdb
../backend/data/silver.duckdb
../backend/data/gold.duckdb
```

## Why this directory exists

Historical monorepo layout kept a top-level `data/` package name. Duplicating the pipeline here would drift. Keep ETL in `backend/pipeline` and treat this folder as packaging/docs only until a real data-product boundary is needed.
