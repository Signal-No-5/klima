# Klima — agent instructions

Read this before changing anything in this repository.

## What this repo is

Flat monorepo assembled from five `Signal-No-5` source repositories:

| Path | Source | Status |
|------|--------|--------|
| `backend/` | `klima-api` | Real FastAPI + DuckDB pipeline |
| `mobile/` | `klima-mobile` | Real Flutter citizen app |
| `frontend/` | `klima-lgu-dashboard` | Sparse (`.gitignore` + `LICENSE` only) |
| `data/` | `klima-data` | Sparse until ETL ownership moves here |
| `docs/` | `klima-docs` | Sparse + agent notes (`CI.md`, `SOURCE_HISTORY.md`) |
| `schema/` | — | `klima-schema`: the only place wire models are defined |

Provenance and history: [`docs/SOURCE_HISTORY.md`](./docs/SOURCE_HISTORY.md).

## Hard guardrails

1. **Do not invent scaffolds** over sparse `frontend/`, `data/`, or `docs/`. If the source repo only has license files, leave it that way until real work lands from that component's owners.
2. **Do not rewrite git history** of imported packages for convenience. History was deliberately preserved under prefixes.
3. **ETL ownership today:** bronze pipeline lives in `backend/pipeline/`. Moving it to `data/` is a deliberate migration, not a silent copy.
4. **One implementation:** never duplicate the pipeline into `data/` while it still lives in `backend/`.
5. **Secrets:** never commit `.env`, tokens, or dashboard env values into `vercel.json` / workflow files.
6. **Containers:** prefer **Podman** over Docker Desktop when documenting or scripting local runs.
7. **JS package manager:** **pnpm** only (never npm/npx as the project default).
8. **Python tooling:** **uv** for backend/data packages.
9. **Wire models live in `schema/` only.** Never define a request/response model
   inside `backend/`; import from `klima_schema`. See the `klima-contracts` skill.
10. **Say which data is real.** Hazards are live PAGASA; safe zones, community
    posts, and barangay baselines are seed JSON. Never present seed data as live.

## Branching

Three tiers, named by prefix. Agents never open or merge a PR against `main`.

| Tier | Prefix | Who |
| --- | --- | --- |
| T1 | `main` | maintainers only |
| T2 | `integ/*` | integration branch per scope; maintainers promote to T1 |
| T3 | `feat/*`, `fix/*`, `chore/*` | one working branch per ticket; PRs target T2 |

The current backend pass uses `integ/backend-mvp`. Full contract:
[`docs/handoff/backend.md`](./docs/handoff/backend.md).

## How to work

1. Read `README.md` and this file.
2. Load relevant project skills under `.cursor/skills/` (mirrored in `.agents/skills/`).
3. Prefer path-filtered CI: changing `backend/**` must keep Backend green; same for `mobile/**`, etc.
4. Red → green: add or extend a failing test first, then implement.
5. Keep comments sparse and high-level; preserve existing docstrings.

## Checks (local)

```bash
# Layout
python3 -m pytest -q tests/test_monorepo_layout.py

# Backend (+ central schema)
cd backend && uv sync --extra test
uv run ruff check --no-fix app tests ../schema/klima_schema
uv run python -m pytest -q
uv run python -m uvicorn app.main:app --reload   # not `uv run uvicorn`

# Mobile
cd mobile && flutter pub get && flutter analyze && flutter test
```

Whole workflows can be run locally with `act` over the Podman socket:

```bash
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
act pull_request -W .github/workflows/ci-backend.yml
```

## Skills index

| Skill | Use when |
|-------|----------|
| `klima-provenance` | Touching layout, imports, sparse packages, history |
| `klima-code-review` | Reviewing a PR/diff |
| `klima-simplification` | Cutting bloat / YAGNI |
| `klima-spec` | Drift vs README / STATUS / contracts |
| `klima-planning` | Architecture / milestone plans |
| `klima-mobile` | Flutter work in `mobile/` |
| `klima-backend` | FastAPI work in `backend/` — endpoints, services, warehouse reads |
| `klima-contracts` | Any field that crosses the wire; `schema/` changes |
| `klima-improvement` | Fix loops; write `.agents/LEARNINGS.md` |

## Out of scope for agents by default

- Re-opening the closed synthetic MVP PR stack
- Generating a fake LGU dashboard or VitePress site to “look complete”
- Claiming Supabase / auth / channel bots work when they do not
