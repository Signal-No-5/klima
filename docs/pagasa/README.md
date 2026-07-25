# PAGASA website API (unofficial)

> **Status:** reverse-engineered from `https://www.pagasa.dost.gov.ph` on **2026-07-25**.  
> **Not** an official PAGASA / DOST publication. Endpoints, shapes, and auth can change without notice.  
> Use for Klima ingest research only; do not present this as an official contract.

Machine-readable OpenAPI: [`openapi.yaml`](./openapi.yaml)  
Trimmed response fixtures: [`examples/`](./examples/)

## How this was derived

1. Klima already calls `POST /api/ActiveWarning` (`backend/pipeline/config/api/pagasa.py`).
2. The public site’s JS bundles (`themes/hiraia/...`, combined app JS) reference additional `/api/*` routes via `$.post(...)`.
3. Those paths were exercised with `POST` (and `GET` for contrast). **Only `POST` returns JSON** for the Laravel-style routes below; `GET` typically returns the site’s HTML “Page not found” shell with HTTP 200.

## Base URLs

| Host | Role |
|------|------|
| `https://www.pagasa.dost.gov.ph` | Primary JSON API (documented here) |
| `https://pagasa.dost.gov.ph` | Same app / static theme assets |
| `https://pubfiles.pagasa.dost.gov.ph` | Icons, PDFs, track images |
| `https://www.panahon.gov.ph` / `https://v2-cloud.meteopilipinas.gov.ph` | Human-readable alert pages linked from payloads |
| `http://api.meteopilipinas.gov.ph` / `http://src.meteopilipinas.gov.ph` | Contour / satellite imagery URLs embedded in JSON |

## Request conventions

Most JSON routes share this pattern:

```http
POST /api/{Resource} HTTP/1.1
Host: www.pagasa.dost.gov.ph
User-Agent: Mozilla/5.0 …
X-Requested-With: XMLHttpRequest
Origin: https://www.pagasa.dost.gov.ph
Referer: https://www.pagasa.dost.gov.ph/
Accept: */*
```

Observed behavior:

- **Method:** `POST` required for JSON. Empty body is fine; `{}` also works.
- **Auth:** none observed (public website backend).
- **CORS:** `Access-Control-Allow-Origin` echoes the PAGASA origin (browser cross-origin calls from other sites are blocked; server-side ingest is fine).
- **Server:** Apache + **PHP/7.4.33** (`X-Powered-By`), `Cache-Control: no-cache, private`.
- **Bare POST** with only `User-Agent` (no browser-like headers) can return an **empty** body — send the headers above.

Path parameters (e.g. `/api/track_points/{id}`, `/api/meteogram/{synop}`) are used by the map UI.

## Endpoint catalog (verified JSON)

| Method | Path | Klima relevance | Response shape (summary) |
|--------|------|-----------------|---------------------------|
| `POST` | `/api/ActiveWarning` | **Bronze today** | Map of hazard name → severity map **or** list (see below) |
| `POST` | `/api/TropicalCycloneWarning` | High (structured TC) | Array of bulletin objects (signals, PDF, track image) |
| `POST` | `/api/TropicalCycloneBulletin` | High | `{ active, "0": {…bulletin…} }` |
| `POST` | `/api/CycloneTrack` | High | Array of `{ cyclone_name, info: { timestamp → point } }` |
| `POST` | `/api/track_points/{typhoon_id}` | Medium | Array of lat/lon track points |
| `POST` | `/api/Lightning` | Medium | Array of flash points |
| `POST` | `/api/Radar` | Medium | `{ HybridTimeline: { rainfall_estimate, reflectivity } }` |
| `POST` | `/api/HybridTimeline` | Medium | Same timeline frames without wrapper |
| `POST` | `/api/SatelliteImages` | Low | Himawari / COMS image URLs + bounds |
| `POST` | `/api/ContourMaps` | Low | temperature / humidity / rain image overlays |
| `POST` | `/api/CurrentWeather` | Medium | Map **PSGC/geocode →** observation |
| `POST` | `/api/NearestAWS` | Medium | Map geocode → **array** of AWS readings |
| `POST` | `/api/ExtendedWeatherOutlook` | Medium | Map geocode → `{ outlook: [5-day…] }` |
| `POST` | `/api/SearchList` | Low (lookup) | Key cities / stations for home search |
| `POST` | `/api/Municipalities` | Low (lookup) | ~1633 municipalities by PSGC-like id |
| `POST` | `/api/BackgroundImages` | Low | Geocode → background image URL |

Referenced in JS but not fully documented here (path-param / auth unclear):  
`/api/meteogram/{synop}`, `/api/wind-profile-images/{name}`, `/api/climate/rro/`, `/api/ws/`.

## `POST /api/ActiveWarning` (Klima bronze)

This is what `pipeline/refinery/bronze/pagasa_warnings.py` stores as one row per **top-level hazard key**.

### Top-level object

Keys are **human hazard titles**, not stable enums. Observed examples:

- `General Flood Advisory`
- `Tropical Cyclone Alert`
- Historically also named storms (`Tropical Depression Salome`, etc.) when those products are active

### Value polymorphism (important)

| Hazard style | Value type | Inner structure |
|--------------|------------|-----------------|
| Flood (and similar) | **object** | Keys like `4Extreme`, `3Severe`, `2Moderate`, `1Final` → severity bucket |
| `Tropical Cyclone Alert` | **array** | List of alert objects (often length 1) |

Each severity bucket / alert object typically has:

```json
{
  "class": "flood-warning | severe-flood-warning | tropical-cyclone-alert | …",
  "iconUrl": "https://pubfiles.pagasa.dost.gov.ph/…",
  "regions": {
    "<Region label>": {
      "areas": "Province A, Province B",
      "issued_at": "YYYY-MM-DD HH:MM:SS",
      "expired_at": "YYYY-MM-DD HH:MM:SS",
      "url": "https://www.panahon.gov.ph/public-alerts/…",
      "description": "HTML / plain advisory text",
      "centroid": { "latitude": 14.59, "longitude": 121.03 },
      "tooltip": "HTML tooltip"
    }
  }
}
```

Notes for schema design:

- Centroid lat/lon may be **number or string**.
- TC alert regions sometimes use `area` (singular) instead of `areas`.
- Severity key prefixes (`4Extreme`, `3Severe`, …) encode rank + label; treat as opaque strings first, normalize in silver.
- Klima bronze correctly keeps the raw payload as JSON and only lifts `hazard` + hash(`hazard||payload`).

### Quick curl

```bash
curl -sS -X POST 'https://www.pagasa.dost.gov.ph/api/ActiveWarning' \
  -H 'User-Agent: Mozilla/5.0' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'Origin: https://www.pagasa.dost.gov.ph' \
  -H 'Referer: https://www.pagasa.dost.gov.ph/'
```

## Related tropical-cyclone endpoints

Prefer these when you need **structured** TC fields instead of scraping HTML inside `ActiveWarning`:

- **`TropicalCycloneWarning`** — `tc_name`, `bulletin_number`, `issued_at`, `pdf_link`, `image_url`, regional signal blocks, `signals`, etc.
- **`TropicalCycloneBulletin`** — presentation-oriented bulletin (`headline`, `intName` e.g. `NOUL`, indexed `bullets` object).
- **`CycloneTrack`** — time-keyed track points with `cyclone_type` (`TD`/`TS`/…).
- **`track_points/{id}`** — DB-ish rows (`unix`, `latitude`, `longitude`, `vs`, …) for a typhoon id used by the impact UI.

## Weather / station endpoints

Keys under `CurrentWeather`, `NearestAWS`, `ExtendedWeatherOutlook`, `SearchList`, and `BackgroundImages` are **stringified place ids** (appear to be PSA/PSGC-style or internal geocodes, e.g. `133900000` Metro Manila, `41031000` Batangas area).

`Municipalities` uses longer ids (`140101000` …) with `{ region, province, municipality, latitude, longitude }`.

## Imagery endpoints

`Radar` / `HybridTimeline` return arrays of `{ time, url }` frames.  
`SatelliteImages` and `ContourMaps` return named layers with `latest`/`animated`/`url` plus geographic `bounds`.

## Klima mapping

| Stage | Use |
|-------|-----|
| Bronze | `ActiveWarning` as today (+ optionally mirror TC/Lightning/AWS raw) |
| Silver | Explode flood severities × regions; normalize TC from `TropicalCycloneWarning` |
| Gold / API | Hazard feed for mobile (`source=pagasa`) |

Do **not** invent a parallel pipeline under root `data/` until ownership deliberately moves there.

## Changelog

| Date | Note |
|------|------|
| 2026-07-25 | Initial reverse-engineering; ActiveWarning live products: General Flood Advisory + Tropical Cyclone Alert (KIYAPO/NOUL). |
