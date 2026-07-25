# Klima docs

Hackathon weather-resilience platform: citizen reporting (Flutter), FastAPI backend + bronze pipeline, LGU dashboard stub, and this VitePress site.

This docs site covers **local development**, the **flat monorepo layout**, and the **API surface that actually exists** in `backend/`. It does not invent product features.

## Start here

| Page | What you get |
|------|----------------|
| [Getting started](/getting-started) | Quick path per package |
| [Monorepo layout](/layout) | What lives where after flattening |
| [API overview](/api/overview) | Routes from `backend/` + OpenAPI |
| [Schema / contracts](/schema) | Where Pydantic models live today |

## Package map (honest)

| Path | Role | Docs status |
|------|------|-------------|
| `mobile/` | Flutter citizen/responder app | [Quickstart](/guide/mobile) |
| `backend/` | FastAPI + DuckDB pipeline | [Quickstart](/guide/backend) |
| `frontend/` | Next.js LGU dashboard | [Stub only](/guide/frontend) |
| `data/` | Pointer package (ETL not here yet) | [Data / ETL](/guide/data) |
| `docs/` | This VitePress site | [Docs quickstart](/guide/docs) |
| `schema/` | Central contracts | **Not on this branch** — see [Schema](/schema) and issue [#4](https://github.com/Signal-No-5/klima/issues/4) |

For present vs stub vs promised, see the repo root [`STATUS.md`](https://github.com/Signal-No-5/klima/blob/feat/mvp-flatten/STATUS.md).

## Internal planning notes

MVP plan and workstream handoffs live in-repo under `docs/mvp/` and `docs/handoffs/` (excluded from this site build; open them on GitHub or in the checkout):

- [docs/mvp/README.md](https://github.com/Signal-No-5/klima/blob/feat/mvp-docs-7/docs/mvp/README.md)
- [docs/handoffs/](https://github.com/Signal-No-5/klima/tree/feat/mvp-docs-7/docs/handoffs)
