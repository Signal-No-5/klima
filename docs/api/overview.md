# API overview

Source of truth for routes: `backend/app/main.py`, `backend/app/routes/root.py`, and `backend/app/api/v1/endpoints/klima.py`.

Do **not** treat older `backend/README.md` sketches (Messenger, Telegram, Viber, dashboard modules) as live endpoints — those files are not mounted today. Only `klima` is included from `app.api.v1.endpoints`.

## Interactive docs

With the API running:

| URL | Content |
|-----|---------|
| `http://localhost:8000/docs` | Swagger UI |
| `http://localhost:8000/redoc` | ReDoc |
| `http://localhost:8000/openapi.json` | OpenAPI 3 document |

FastAPI generates these from the same Pydantic models used by the handlers.

## Mounting

From `app.main`:

- Root router (`app.routes.root`) — health-style routes
- `api_router` mounted at **`/`** and again at **`/api/v1`** so mobile can call unversioned paths while a versioned mirror exists
- Prometheus instrumentator exposes **`/metrics`**

## Root routes

| Method | Path | Response (shape) |
|--------|------|------------------|
| `GET` | `/` | `{"message": "… Klima API is running"}` |
| `GET` | `/health` | `{"status": "ok"}` |
| `GET` | `/status` | Audit-log aggregate counts (`2xx` / `4xx` / `5xx`) via SQLModel session |
| `GET` | `/metrics` | Prometheus metrics |

## Mobile contract routes

Defined in `backend/app/api/v1/endpoints/klima.py`. Available at both root and `/api/v1` prefixes (example: `/hazard/latest` and `/api/v1/hazard/latest`).

| Method | Path | Response model | Notes |
|--------|------|----------------|-------|
| `GET` | `/hazard/latest` | `list[HazardOut]` | Query: `type`, `barangay`, `municipality` |
| `GET` | `/reports` | `list[ReportOut]` | Query: `type`, `barangay` |
| `POST` | `/reports` | `ReportOut` (`201`) | Body: `ReportCreate` |
| `GET` | `/risk/{barangay_id}` | `RiskOut` | Path param `barangay_id` |
| `GET` | `/safezones` | `list[SafeZoneOut]` | Query: `barangay`, `municipality` |
| `GET` | `/community/posts` | `list[CommunityPostOut]` | Query: `barangay` |

Models are defined in `backend/app/schemas/klima.py` on this branch (see [Schema](/schema)).

## Contract tests

```bash
cd backend
uv run pytest tests/test_klima_endpoints.py -q
```

These tests assert the mobile-facing paths and payload keys above.

## Not present

No Messenger, Telegram, Viber, or dedicated LGU dashboard routers are registered in `app.api.v1.api`. Auth beyond what middleware/config scaffolding implies is **not** documented as a working product feature.
