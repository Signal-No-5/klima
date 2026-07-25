# Data / ETL

`data/` is a **pointer package**, not a second pipeline.

From `data/pyproject.toml`:

- `name = "klima-data"`
- `dependencies = []`
- Description: scaffold only — ETL lives in `../backend/pipeline`

## Where ETL actually runs

All bronze (and related DuckDB) wiring lives in:

```text
backend/pipeline/
```

Run the only registered bronze asset from the API package:

```bash
cd backend
uv run python scripts/run_pipeline.py pagasa_warnings
```

List known assets:

```bash
cd backend
uv run python scripts/run_pipeline.py --list
```

Today that list is just `pagasa_warnings`.

## DuckDB files

When the pipeline has been run, DuckDB files used by the API are under:

```text
backend/data/bronze.duckdb
backend/data/silver.duckdb
backend/data/gold.duckdb
```

Silver/gold **orchestration and schedules** are not a finished product surface; do not assume a full medallion job graph.

## Why `data/` exists

Historical layout kept a top-level `data/` name. Duplicating the pipeline here would drift. Issue [#8](https://github.com/Signal-No-5/klima/issues/8) tracks moving ETL ownership into a real `data/` product boundary.

## Related

- [Backend quickstart](/guide/backend)
- [Monorepo layout](/layout)
