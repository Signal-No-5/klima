# HANDOFF — Flatten monorepo (#3)

**Status:** In progress  
**Branch:** `feat/mvp-flatten`  
**Issue(s):** #3  
**Last updated:** 2026-07-25

## Bottom line
Restructure Klima to match complYaigent-style flat roots: `mobile/`, `backend/`, `frontend/`, `docs/`, `data/` (+ later `schema/`). Kill `web/` nesting.

## Current state
- `web/api`, `web/dashboard`, `web/docs` nest all non-mobile surfaces
- `data/` is pointer-only stub to `web/api/pipeline`
- README/STATUS describe nested layout

## Hook points
- `web/api/**` → `backend/**`
- `web/dashboard/**` → `frontend/**`
- `web/docs/**` → merge into root `docs/` (keep mvp/handoffs)
- Root `README.md`, `STATUS.md`, CI under `mobile/.github` if any path refs
- Mobile dart-define / docs that say `web/api`

## Open follow-ups
- [ ] `git mv` preserving history
- [ ] Update all scripts (`uvicorn`, `pnpm`, pytest paths)
- [ ] Smoke: backend boots; frontend installs; docs build

## How to verify
```bash
test -d backend && test -d frontend && test -d docs && test ! -d web
cd backend && uv sync && uv run uvicorn app.main:app --host 127.0.0.1 --port 8000 &
curl -sf http://127.0.0.1:8000/health
```

## Done means
- [ ] Flat tree; no `web/`
- [ ] Documented commands work
- [ ] STATUS/README updated
