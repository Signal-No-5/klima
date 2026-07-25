# Klima — status matrix

Honest inventory of what exists in this monorepo versus what was promised in hackathon decks / READMEs.

| Area | Present | Stub / scaffold | Promised (not built) |
|------|---------|-----------------|----------------------|
| **Mobile (Flutter)** | Hazard feed, report/help/safe flows, map, go-bag, community UI, offline mocks | Firebase / push polish, production assets | Full offline sync, production auth |
| **API (`backend/`)** | Root health routes, Prometheus metrics, audit middleware, mobile contract endpoints, DuckDB bronze read from `data/warehouse/` | Messenger / Telegram / Viber channel endpoints | Full auth (Keycloak/Auth0), multi-tenant LGU RBAC |
| **ETL (`data/`)** | Installable `klima-data` package; `pipeline/` bronze PAGASA asset; CLI `python -m pipeline` / `klima-etl`; DuckDB under `data/warehouse/`; offline fixture mode | Silver/gold transforms; orchestration | Full medallion orchestration, schedules |
| **`docs/`** | VitePress scaffold + MVP handoffs | Content beyond getting-started | Full operator + API docs site |
| **`frontend/`** | Minimal Next.js stub page | No real LGU workflows | Live risk map, report triage, occupancy |
| **`schema/`** | — | Planned (#4) | Shared contracts across backend/mobile/frontend |
| **Community / risk / safe zones** | Fixture-backed API responses matching mobile models | Persistence beyond in-memory reports | Verified geospatial risk model, live safe-zone CMS |

## Legend

- **Present** — usable code or data in-tree for local/hackathon demos.
- **Stub / scaffold** — intentional placeholder so the monorepo layout is honest.
- **Promised** — mentioned historically; do not assume it works.
