# Klima

Hackathon weather resilience platform: real-time alerts, community reporting, LGU dashboards, and data pipelines.

This repository is a **single monorepo**. Packages live in-tree (not git submodules).

## Layout

| Path | Role |
|------|------|
| `mobile/` | Flutter citizen/responder app (from `klima-mobile`) |
| `web/api/` | Backend API + pipeline (from `klima-api`) |
| `web/dashboard/` | LGU web dashboard (from `klima-lgu-dashboard`) |
| `web/docs/` | VitePress docs site (from `klima-docs`) |
| `data/` | ETL / data pipelines (from `klima-data`) |

## Notes

- Historical split repos under `Signal-No-5/*` remain for reference; **this repo is the source of truth**.
- `mobile` previously pointed at a missing `klima-frontend` submodule; content is taken from `klima-mobile`.
