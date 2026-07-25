# Monorepo layout

After flattening (#3), Klima is a **single flat monorepo**. There is no `web/` nesting.

```text
klima/
├── mobile/      # Flutter citizen/responder app
├── backend/     # FastAPI API + DuckDB pipeline (canonical ETL today)
├── frontend/    # Next.js LGU dashboard stub
├── docs/        # VitePress site + mvp/ + handoffs/
├── data/        # Pointer / packaging scaffold (ETL still in backend/pipeline)
└── schema/      # Planned central contracts (#4) — not present on feat/mvp-flatten
```

## What each path owns

| Path | Owns | Does not own |
|------|------|----------------|
| `mobile/` | Flutter UI, Dart models, local mocks | Backend persistence |
| `backend/` | FastAPI routes, Pydantic response models, DuckDB bronze ingest | LGU dashboard UI |
| `backend/pipeline/` | PAGASA bronze asset + DuckDB wiring | Standalone published datasets |
| `frontend/` | Minimal Next.js stub page | Live risk map / triage (not built) |
| `docs/` | VitePress guide + MVP handoffs | Operator runbooks beyond MVP |
| `data/` | README pointing at `backend/pipeline` | A second copy of the pipeline |
| `schema/` | (planned) shared `klima_schema` package | — until #4 lands |

## Historical note

Older layouts nested API/dashboard/docs under `web/`. That nesting is gone. Treat this repo as the source of truth; historical split repos under `Signal-No-5/*` are reference only.

## Related

- [Getting started](/getting-started)
- [Data / ETL](/guide/data)
- [Schema / contracts](/schema)
- Epic [#2](https://github.com/Signal-No-5/klima/issues/2)
