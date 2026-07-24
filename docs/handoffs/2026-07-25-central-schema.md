# HANDOFF — Central schema (#4)

**Status:** Planned  
**Branch:** `feat/mvp-schema` (after or with flatten)  
**Issue(s):** #4  
**Last updated:** 2026-07-25

## Bottom line
Introduce `schema/` as the single source of truth for Hazard, Report, SafeZone, Community, Risk contracts used by backend (and documented for mobile/frontend).

## Current state
- Pydantic models in `web/api/app/schemas/klima.py` (will be `backend/app/schemas/…`)
- Flutter models under `mobile/lib/models/` — parallel definitions
- No shared export / OpenAPI publish step

## Hook points
- New `schema/` package (Python preferred to match FastAPI; optional JSON Schema export)
- `backend/app/schemas/` should re-export or thin-wrap schema package
- `docs/` schema parity checklist vs `mobile/lib/models`

## Open follow-ups
- [ ] Move/port klima.py entities into schema
- [ ] Backend imports from schema
- [ ] Document export (`/openapi.json` or `schema/export`)

## How to verify
```bash
cd backend && uv run pytest tests/test_klima_endpoints.py -q
# openapi shows schema-backed models
```

## Done means
- [ ] No divergent duplicate Pydantic defs for MVP entities
- [ ] Parity checklist committed
