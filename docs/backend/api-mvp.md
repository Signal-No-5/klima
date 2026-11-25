# Klima MVP API

Every response model comes from the central `klima-schema` package, so payloads
match the Flutter client field for field. Paths and query parameter names mirror
`mobile/lib/services/api_service.dart`; `backend/tests/test_klima_endpoints.py`
fails if either side renames one.

Base URL in development: `http://localhost:8000`.

## Data sources at a glance

| Endpoint | Backed by | Real data today |
| --- | --- | --- |
| `GET /hazard/latest` | silver `hazard_warnings` | Yes — live PAGASA |
| `POST /reports`, `GET /reports` | SQL `citizenreport` table | Yes — user submissions |
| `GET /risk/{barangay_id}` | live hazards + seed baselines | Partly |
| `GET /safezones` | `backend/data/seed/safe_zones.json` | No — seed |
| `GET /community/posts` | `backend/data/seed/community_posts.json` | No — seed |

Seed-backed endpoints are honest placeholders: Klima has no LGU facility or
authoring integration yet. They are JSON files rather than Python literals so an
LGU can replace the file without a code change, and they are validated against
the contract on load.

## `GET /hazard/latest`

Active advisories, newest first.

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| `type` | string | – | Normalized hazard type (`flood`, `typhoon`, `storm`, …) |
| `barangay` | string | – | Match against advisory coverage |
| `municipality` | string | – | Match against advisory coverage |
| `limit` | 1–500 | 100 | Maximum items |
| `include_expired` | bool | `false` | Include advisories past their expiry |

Returns `[]` — not an error — when the warehouse has not been built. Check
`/health/ready` to tell "no hazards" apart from "no data".

Place filters match an advisory's *coverage*, not the hazard's own address
fields, because PAGASA publishes at region and province granularity. See
[hazard-mapping.md](./hazard-mapping.md).

```bash
curl -s "localhost:8000/hazard/latest?type=flood&municipality=Bulacan"
```

## `POST /reports`

Accepts the `ReportCreate` contract and returns `ReportOut` with `201`.

- Mobile queues reports offline and submits with `id: ""`; the server mints a
  UUID rather than rejecting the payload.
- Unknown fields, out-of-range coordinates, and unknown `type`/`status` values
  are rejected with `422`. That is deliberate: silent coercion is how client and
  server contracts drift apart.

## `GET /reports`

| Parameter | Type | Default |
| --- | --- | --- |
| `type` | `hazard`, `help`, `safe` | – |
| `barangay` | string (exact) | – |
| `limit` | 1–500 | 100 |

Newest first.

## `GET /risk/{barangay_id}`

Returns `RiskOut` for a barangay, or `404` when no baseline exists. Accepts
either the baseline id (`calumpit-iba-este`) or the barangay name (`Iba Este`).

`GET /risk` lists the available baseline ids so clients can avoid guessing.

Scoring is documented in [risk-model.md](./risk-model.md).

## `GET /safezones`

| Parameter | Type |
| --- | --- |
| `barangay` | substring match |
| `municipality` | substring match |
| `operational_only` | bool |

## `GET /community/posts`

| Parameter | Type | Notes |
| --- | --- | --- |
| `barangay` | string | Matches post **tags**, which is how seed posts record audience |
| `limit` | 1–200 | Default 50 |

Pinned posts first, then newest.

## Health and metrics

- `GET /health` — flat liveness check, `{"status": "ok"}`. Safe for orchestrators.
- `GET /health/ready` — reports the silver warehouse path, whether the hazard
  table exists, how many advisories are active, and how many seed records
  loaded. Returns `status: degraded` when there is no hazard data to serve.
- `GET /metrics` — Prometheus format.
- `GET /status` — audit-log response-code buckets.

## Known gaps

- Official advisories are regional, so `barangay`, `municipality`, and
  `province` on `HazardOut` are empty for PAGASA items; coverage lives in
  `metadata.region` and `metadata.areas`.
- `RiskOut.safe_residents` is always `0`; nothing records safe check-ins yet.
- Reports are not authenticated. Anyone who can reach the API can post one.
