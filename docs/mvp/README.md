# MVP Plan: Flat Klima + working surfaces

> **Date:** 2026-07-25  
> **Repo:** [Signal-No-5/klima](https://github.com/Signal-No-5/klima)  
> **Local:** `/home/kaoru/work/signal/klima`  
> **Status:** Plan to build (MVP)  
> **Epic:** [#2 MVP: Flat monorepo + working backend/frontend/docs/data + central schema](https://github.com/Signal-No-5/klima/issues/2)  
> **Layout reference:** [liitkud/complyaigent](https://github.com/liitkud/complyaigent) (`backend/`, `frontend/`, `docs/`)

## Problem
Monorepo is nested under `web/{api,dashboard,docs}` instead of a flat surface. `data/` is a pointer stub; dashboard/docs are scaffolds; schemas live only inside the API.

## Target layout
```text
klima/
├── mobile/
├── backend/     # was web/api
├── frontend/    # was web/dashboard
├── docs/        # was web/docs (+ this mvp/handoffs)
├── data/        # canonical ETL + DuckDB
└── schema/      # central contracts
```

## Definition of Done
- [ ] Flat layout (no `web/` nesting)
- [ ] Backend boots; health + mobile contract endpoints work
- [ ] Frontend talks to live backend
- [ ] Docs site builds with getting-started + API overview
- [ ] Data owns ETL; bronze ingest runnable
- [ ] `schema/` is SoT for hazard/report/safezone/community
- [ ] README + STATUS match reality
- [ ] Handoffs exist for every workstream issue

## Workstreams → issues

| # | Workstream | Issue | Pri |
|---|------------|-------|-----|
| W1 | Flatten monorepo | [#3](https://github.com/Signal-No-5/klima/issues/3) | P0 |
| W2 | Central schema | [#4](https://github.com/Signal-No-5/klima/issues/4) | P0 |
| W3 | Backend working | [#5](https://github.com/Signal-No-5/klima/issues/5) | P0 |
| W4 | Frontend live | [#6](https://github.com/Signal-No-5/klima/issues/6) | P0 |
| W5 | Docs site | [#7](https://github.com/Signal-No-5/klima/issues/7) | P1 |
| W6 | Data owns ETL | [#8](https://github.com/Signal-No-5/klima/issues/8) | P0 |
| W7 | Centralize deployments | [#9](https://github.com/Signal-No-5/klima/issues/9) | P1 |

**Suggested order:** W1 → W2 → W3∥W6 → W4 → W5 (schema before backend; data can parallel backend after flatten).

## Non-goals
Auth0/Keycloak multi-tenant RBAC; full silver/gold orchestration; channel bots; production offline sync.

## Handoffs
See [../handoffs/](../handoffs/).
