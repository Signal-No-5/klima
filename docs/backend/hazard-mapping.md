# Mapping PAGASA advisories to `HazardOut`

`GET /hazard/latest` serves rows from the silver `hazard_warnings` table. The two
models do not line up cleanly, so this records every decision the mapping makes.
The code is `backend/app/services/hazards.py`.

## The granularity mismatch

PAGASA publishes **per-region** advisories with a comma-separated list of covered
provinces. `HazardOut` was designed around the mobile app, which is
**barangay-scoped**.

Rather than guess a barangay or write a province list into `province`, the mapping
leaves the address fields empty for official items and carries coverage in
`metadata`:

```json
{
  "barangay": "",
  "municipality": "",
  "province": "",
  "metadata": {
    "region": "Region 3 (Central Luzon)",
    "areas": ["Bataan", "Zambales"],
    "pagasa_product": "General Flood Advisory",
    "hazard_class": "flood-warning",
    "severity_code": "3Severe",
    "severity_rank": 3,
    "alert_url": "https://www.panahon.gov.ph/public-alerts/…",
    "expires_at": "2026-07-26T05:35:42"
  }
}
```

Consequence for clients: do not read `province` to label an official advisory,
read `metadata.region`. Citizen reports promoted into the hazard feed later can
populate the address fields properly.

## Place filtering

Because the address fields are empty, filtering on them would return nothing
useful. `barangay` and `municipality` instead ask "does this advisory cover the
named place?", matching against `barangay`, `municipality`, `province`,
`metadata.region`, and each entry of `metadata.areas`.

Advisories scoped to `Philippine Area of Responsibility` (how PAGASA publishes
`Tropical Cyclone Alert`) are treated as nationwide and match every place. Before
this rule, a live cyclone alert was invisible to every place query.

## Type normalization

Mobile uses a fixed vocabulary (`flood`, `typhoon`, `storm`, `landslide`,
`heatwave`). PAGASA product names are open-ended, so `hazard_class` is mapped
first, then keywords in the product name, then a literal `advisory` fallback.

| PAGASA `hazard_class` | `type` |
| --- | --- |
| `flood-warning`, `flood-advisory`, `rainfall-warning` | `flood` |
| `thunderstorm-warning` | `storm` |
| `tropical-cyclone` | `typhoon` |

`HazardOut.type` and `severity` are deliberately plain strings, not enums: a new
PAGASA product should degrade to `advisory`, not 500 the feed.

## Severity

Silver parses bucket keys like `4Extreme` into a rank and label. Ranks map
directly:

| Rank | `severity` |
| --- | --- |
| 4 | `critical` |
| 3 | `high` |
| 2 | `moderate` |
| 1 | `low` |

Products with no severity bucket (again, `Tropical Cyclone Alert`) fall back to
`moderate`. Neither `low` nor `critical` is defensible for an unranked alert —
one hides a real threat, the other cries wolf.

## Rows that are dropped

- **No centroid** — cannot be placed on the map. Filling in a sentinel coordinate
  would put the hazard in the Gulf of Guinea.
- **No `issued_at`** — cannot be ordered in a "latest first" feed.

## Expiry

Advisories past `expired_at` are excluded by default. `include_expired=true`
returns them for history views and debugging. DuckDB timestamps are naive and
already normalized to UTC upstream in bronze, so they are read as UTC.

This means the feed legitimately empties out when no advisory is active. Use
`/health/ready` to distinguish that from a warehouse that was never built.
