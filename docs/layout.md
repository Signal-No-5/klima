# Monorepo layout

After flattening (#3), Klima is a **single flat monorepo**. There is no `web/` nesting.

```text
klima/
├── mobile/      # Flutter citizen/responder app
├── backend/     # FastAPI API (reads the DuckDB warehouse)
├── frontend/    # Next.js LGU dashboard (live against the API)
├── docs/        # VitePress site + mvp/ + handoffs/
├── data/        # Canonical ETL package (klima-data) + DuckDB warehouse
└── schema/      # Central contracts (klima_schema)
```

## What each path owns

| Path | Owns | Does not own |
|------|------|----------------|
| `mobile/` | Flutter UI, Dart models, local mocks | Backend persistence |
| `backend/` | FastAPI routes, schema-backed responses, reads bronze | LGU dashboard UI, ETL definition |
| `frontend/` | LGU dashboard views against the live API | Map UI / triage actions (not built) |
| `docs/` | VitePress guide + MVP handoffs | Operator runbooks beyond MVP |
| `data/` | PAGASA bronze asset, CLI, DuckDB warehouse | Silver/gold transforms, scheduling |
| `schema/` | Shared `klima_schema` Pydantic contracts + JSON Schema export | Generated Dart/TS clients |

## Historical note

Older layouts nested API/dashboard/docs under `web/`. That nesting is gone. Treat this repo as the source of truth; historical split repos under `Signal-No-5/*` are reference only.

## Related

- [Getting started](/getting-started)
- [Data / ETL](/guide/data)
- [Schema / contracts](/schema)
- Epic [#2](https://github.com/Signal-No-5/klima/issues/2)
