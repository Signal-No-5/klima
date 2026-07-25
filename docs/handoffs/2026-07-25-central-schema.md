# HANDOFF — Central schema (#4)

**Status:** Done (MVP)  
**Branch:** `feat/mvp-schema` (based on `feat/mvp-flatten`)  
**Issue(s):** #4  
**Last updated:** 2026-07-25

## Bottom line
`schema/` is the single source of truth for Hazard, Report, SafeZone, Community, Risk contracts. Backend re-exports from `klima_schema`; JSON Schema export + mobile/frontend parity docs are in-tree.

## Current state
- Canonical Pydantic models: `schema/klima_schema/models.py`
- Backend façade: `backend/app/schemas/klima.py` (re-export only)
- Export: `python -m klima_schema.export` → `schema/exported/`
- Parity checklist: `docs/mvp/schema-parity.md`
- Editable dep: `backend/pyproject.toml` → `klima-schema` path `../schema`

## Hook points
- Extend entities in `klima_schema.models`, never duplicate under `backend/app/schemas/`
- Flutter still owns Dart models; keep checklist updated when fields change
- Frontend should consume OpenAPI / JSON Schema when LGU UI is built (#6)

## Open follow-ups
- [ ] Generate Dart / TypeScript clients from JSON Schema (optional codegen)
- [ ] Move GoBag / UserLocation into schema if they become API contracts
- [ ] CI step: export schemas + fail on drift vs committed `schema/exported/`

## How to verify
```bash
cd backend
.venv/bin/pip install -e ../schema   # if not already synced
.venv/bin/python -m pytest tests/test_klima_endpoints.py tests/test_schema_source.py -q
cd ../schema && ../backend/.venv/bin/python -m klima_schema.export --out exported
# API OpenAPI components include HazardOut, ReportOut, …
```

## Done means
- [x] No divergent duplicate Pydantic defs for MVP entities
- [x] Parity checklist committed
- [x] OpenAPI / JSON Schema export documented
