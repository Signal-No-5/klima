# HANDOFF — Centralize deployments (#9)

**Status:** Planned  
**Branch:** `feat/mvp-deploy` (after flatten #3)  
**Issue(s):** #9  
**Last updated:** 2026-07-25

## Bottom line
One deploy SoT for backend + frontend + docs (compose and/or platform + root CI path filters), replacing scattered `vercel.json` / undocumented hosts.

## Current state
- `web/api/vercel.json` (→ `backend/` after #3)
- Mobile workflows isolated under `mobile/.github`
- No root compose / unified env matrix for web surfaces

## Hook points
- Root `docker-compose.yml` or `deploy/`
- Root `.github/workflows/*` with path filters
- `docs/` deploy page + README
- Per-app vercel.json: demote or delete

## How to verify
```bash
# after implementation — example
docker compose config
# or documented platform deploy dry-run
```

## Done means
- [ ] Single documented primary deploy path
- [ ] CI builds the right package on path change
- [ ] Env/secrets matrix at root
