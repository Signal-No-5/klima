# Getting started

Prerequisites depend on which surface you touch. Commands below match the package scripts / configs in-tree.

## Choose a surface

| Surface | Package manager / tool | Quickstart |
|---------|------------------------|------------|
| API + pipeline | `uv` (see `backend/pyproject.toml`) | [Backend](/guide/backend) |
| LGU dashboard stub | `pnpm` (`frontend/package.json` → `packageManager: pnpm@9.15.0`) | [Frontend](/guide/frontend) |
| Citizen app | Flutter (`mobile/pubspec.yaml`, SDK `^3.5.0`) | [Mobile](/guide/mobile) |
| ETL pointer / bronze run | `uv` from `backend/` | [Data / ETL](/guide/data) |
| This docs site | `pnpm` (`docs/package.json`) | [Docs](/guide/docs) |

## Fastest path: API for mobile

```bash
cd backend
uv sync
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then open interactive docs at `http://localhost:8000/docs` (FastAPI Swagger UI) or raw OpenAPI at `http://localhost:8000/openapi.json`.

Mobile default base URL (Android emulator): `http://10.0.2.2:8000`  
Override at build time: `flutter run --dart-define=API_BASE_URL=...`

## Layout

New to the repo? Read [Monorepo layout](/layout) next.
