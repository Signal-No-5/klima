# Issue #4 handoff — central schema

## Intent

Create one strict, exportable source of truth for the backend/mobile MVP wire
contracts. This ticket does not implement endpoints; issue #5 consumes it.

## Changes

- `schema/klima_schema/models.py` owns all Pydantic contract definitions.
- `backend/app/schemas/klima.py` is a re-export façade, not a second model copy.
- `schema/klima_schema/export.py` generates committed JSON Schema documents.
- `docs/backend/schema-parity.md` records Flutter field parity.
- Backend uv resolves `klima-schema` through an editable local path.
- Backend CI runs on `schema/**` changes, lints the package, and fails when the
  committed exports drift from the models. Export output is byte-stable.

## Contract decisions

- JSON is snake_case and coordinates are flat for Flutter compatibility.
- Unknown fields are rejected to surface drift.
- Latitude/longitude and risk scores are range-validated.
- Report type/status and risk level are string enums.
- Hazard `type`/`severity` remain strings because official PAGASA products are
  open-ended; the API mapping in #5 normalizes current values.

## Verify

```bash
cd backend
uv sync --extra test
uv run python -m klima_schema.export --out ../schema/exported
uv run ruff check --no-fix app tests ../schema/klima_schema
uv run python -m pytest -q
```

## Stack order

Branch: `feat/4-central-schema` (T3) → `integ/backend-mvp` (T2).

PR this branch first. Issue #5 is stacked on this commit and should be
integrated second.
