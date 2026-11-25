# Klima central contracts

`schema/` is the single source of truth for backend wire models:

- `HazardOut`
- `ReportCreate` / `ReportOut`
- `RiskOut`
- `SafeZoneOut`
- `CommunityPostOut`

The backend imports these Pydantic models through
`backend/app/schemas/klima.py`. JSON uses snake_case and flat
`latitude`/`longitude` fields to match existing Flutter serializers.

## Install and test

The backend declares this package as an editable uv path dependency:

```bash
cd backend
uv sync --extra test
uv run pytest -q
```

## Export JSON Schema

```bash
cd backend
uv run python -m klima_schema.export --out ../schema/exported
```

This writes a bundled `klima-mvp.schema.json` and one document per model.
Generated files are committed so non-Python consumers can use the contracts
without running Python.

FastAPI also exposes models used by endpoints in `GET /openapi.json`.

## Change policy

1. Edit `schema/klima_schema/models.py`, never duplicate a Pydantic model under
   `backend/app/`.
2. Re-export `schema/exported/`.
3. Update `docs/backend/schema-parity.md`.
4. Run backend tests and inspect OpenAPI changes.

The contracts intentionally reject unknown fields (`extra="forbid"`) so drift
fails early instead of being silently discarded.
