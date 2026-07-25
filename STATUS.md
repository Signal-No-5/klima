# Klima — status matrix

Honest inventory of what exists in this monorepo versus what was promised in hackathon decks / READMEs.

| Area | Present | Stub / scaffold | Promised (not built) |
|------|---------|-----------------|----------------------|
| **Mobile (Flutter)** | Hazard feed, report/help/safe flows, map, go-bag, community UI, offline mocks | Firebase / push polish, production assets | Full offline sync, production auth |
| **API (`backend/`)** | Boots with `uv`; `/health` + `/metrics`; schema-backed mobile contract endpoints (hazard/reports/risk/safezones/community); DuckDB bronze read with fixture fallback; contract tests green (#5) | Messenger / Telegram / Viber channel endpoints | Full auth (Keycloak/Auth0), multi-tenant LGU RBAC, persistent report store |
| **ETL** | `backend/pipeline/refinery/bronze/pagasa_warnings.py` + DuckDB bronze/silver/gold files | Silver/gold transforms | Full medallion orchestration, schedules; move home to `data/` (#8) |
| **`data/`** | README + `pyproject.toml` pointing at `backend/pipeline` | Empty product surface | Standalone ETL package / published datasets |
| **`docs/`** | VitePress scaffold + MVP handoffs | Content beyond getting-started | Full operator + API docs site |
| **`frontend/`** | Minimal Next.js stub page | No real LGU workflows | Live risk map, report triage, occupancy |
| **`schema/`** | Pydantic MVP entities + JSON Schema export; backend re-exports | Flutter still parallel Dart models (parity doc) | Generated Dart/TS clients from schema |
| **Community / risk / safe zones** | Fixture-backed API responses matching mobile models (schema-validated) | Persistence beyond in-memory reports | Verified geospatial risk model, live safe-zone CMS |

## Legend

- **Present** — usable code or data in-tree for local/hackathon demos.
- **Stub / scaffold** — intentional placeholder so the monorepo layout is honest.
- **Promised** — mentioned historically; do not assume it works.
