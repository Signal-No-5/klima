# Klima — status matrix

Honest inventory of what exists in this monorepo versus what was promised in hackathon decks / READMEs.

| Area | Present | Stub / scaffold | Promised (not built) |
|------|---------|-----------------|----------------------|
| **Mobile (Flutter)** | Hazard feed, report/help/safe flows, map, go-bag, community UI, offline mocks | Firebase / push polish, production assets | Full offline sync, production auth |
| **API (`backend/`)** | Boots with `uv`; `/health` + `/metrics`; audit middleware; schema-backed mobile contract endpoints (hazard/reports/risk/safezones/community); DuckDB bronze read from `data/warehouse/` with fixture fallback; contract tests green (#5) | Messenger / Telegram / Viber channel endpoints | Full auth (Keycloak/Auth0), multi-tenant LGU RBAC, persistent report store |
| **ETL (`data/`)** | Installable `klima-data` package; `pipeline/` bronze PAGASA asset; CLI `python -m pipeline` / `klima-etl`; DuckDB under `data/warehouse/`; offline fixture mode (#8) | Silver/gold transforms; orchestration | Full medallion orchestration, schedules |
| **`docs/`** | VitePress MVP site (layout, quickstarts, API overview from real routes, schema honesty) + MVP handoffs (in-repo, excluded from site build) | Operator runbooks, embedded OpenAPI UI, deployment guides | Full LGU/operator docs portal |
| **`frontend/`** | MVP LGU dashboard: hazards, reports, risk, safe zones via live API (`NEXT_PUBLIC_KLIMA_API_URL`); explicit empty/error states | Map UI, triage actions, auth | Full risk map CMS, report workflow, occupancy ops |
| **`schema/`** | Pydantic MVP entities + JSON Schema export; backend re-exports | Flutter still parallel Dart models (parity doc); frontend hand-mirrors TS from export | Generated Dart/TS clients from schema |
| **Community / risk / safe zones** | Fixture-backed API responses matching mobile models (schema-validated) | Persistence beyond in-memory reports | Verified geospatial risk model, live safe-zone CMS |

## Legend

- **Present** — usable code or data in-tree for local/hackathon demos.
- **Stub / scaffold** — intentional placeholder so the monorepo layout is honest.
- **Promised** — mentioned historically; do not assume it works.
