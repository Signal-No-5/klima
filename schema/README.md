# `schema/` — Klima central contracts

Single source of truth for MVP wire contracts: **Hazard**, **Report**, **SafeZone**, **Community**, **Risk**.

Backend Pydantic models are defined here and **re-exported** from `backend/app/schemas/klima.py` so FastAPI endpoints keep working without duplicate definitions.

## Package layout

```text
schema/
├── klima_schema/
│   ├── models.py      # Pydantic MVP entities
│   └── export.py      # JSON Schema exporter
├── exported/          # Generated JSON Schema (commit after export)
├── pyproject.toml
└── README.md
```

## Install for backend / local tools

From `backend/` (editable path dependency is declared in `backend/pyproject.toml`):

```bash
cd backend
uv sync
# or, with the repo venv:
.venv/bin/pip install -e ../schema
```

## Export JSON Schema

```bash
cd schema
# with repo backend venv (has pydantic):
../backend/.venv/bin/python -m klima_schema.export --out exported
# or after editable install:
klima-schema-export --out exported
```

Outputs:

- `exported/klima-mvp.schema.json` — bundle with `$defs`
- `exported/<ModelName>.schema.json` — per-entity schemas

## OpenAPI (runtime)

With the API running, FastAPI exposes the same models under:

```text
GET http://localhost:8000/openapi.json
```

Look for component schemas: `HazardOut`, `ReportCreate`, `ReportOut`, `RiskOut`, `SafeZoneOut`, `CommunityPostOut`.

## Consumers

| Surface | How it uses contracts |
|---------|------------------------|
| `backend/` | Imports via `app.schemas.klima` → `klima_schema` |
| `mobile/` | Parallel Dart models; see [parity checklist](../docs/mvp/schema-parity.md) |
| `frontend/` | Stub today; consume OpenAPI / JSON Schema when building LGU UI |

Do **not** add a second Pydantic copy under `backend/app/schemas/` — edit `klima_schema.models` instead.
