# Barangay risk model

`GET /risk/{barangay_id}` composes one number from three components. The weights
and thresholds live in `backend/app/services/risk.py` so the mobile app and the
LGU dashboard cannot disagree about what "high risk" means.

**This is a screening heuristic, not a hazard assessment.** Only the hazard
component is measured; the other two are placeholder baselines. Do not present
its output as an official DRRM figure.

## Formula

```
risk_score = 0.5 × hazard_score
           + 0.3 × exposure_score
           + 0.2 × vulnerability_score
```

All components and the result are in `[0, 1]`, and the result is clamped and
rounded to four decimals.

| `risk_score` | `risk_level` |
| --- | --- |
| ≥ 0.75 | `critical` |
| ≥ 0.50 | `high` |
| ≥ 0.25 | `moderate` |
| otherwise | `low` |

## `hazard_score` — measured

Derived from live silver PAGASA advisories that cover the barangay. Each active
advisory contributes by mapped severity:

| Severity | Weight |
| --- | --- |
| `critical` | 1.00 |
| `high` | 0.75 |
| `moderate` | 0.50 |
| `low` | 0.25 |

`hazard_breakdown` keeps the worst active weight **per hazard type**, and
`hazard_score` is the maximum across types. Maximum rather than sum: two
simultaneous floods are not twice as dangerous as one, and a sum would saturate
at 1.0 and stop discriminating.

### Scope widening

PAGASA publishes at region, province, and nationwide scope, so advisories are
collected for the barangay name, its municipality, **and** its province, then
deduplicated by id.

All scopes are queried and unioned rather than stopping at the first that matches.
An earlier version stopped early, and a nationwide `Tropical Cyclone Alert`
(which matches everything) masked a province-level extreme flood advisory,
reporting `hazard_score` 0.5 where it should have been 1.0.

## `exposure_score` and `vulnerability_score` — placeholders

Read from `backend/data/seed/barangays.json`. Klima has no census, elevation, or
DRRM integration yet, so these are tiered by hand from local knowledge of
Calumpit, Bulacan — a floodplain municipality at the Angat/Pampanga river
confluence:

| Tier | `exposure_score` | Applied to |
| --- | --- | --- |
| Riverside / low-lying | 0.80 | Barangays along the river system |
| Interior | 0.55 | Mixed elevation |
| Elevated / built-up | 0.30 | Poblacion-adjacent |

`vulnerability_score` follows the same tiers, nudged by population density.
`total_population` figures are approximate.

Replacing these values with real data is a data change, not a code change: edit
the JSON. The file is validated against `BarangayBaseline` on load, so a
malformed edit fails tests rather than a request.

## What is missing

- `safe_residents` is always `0`; there is no safe check-in feed yet.
- Citizen reports do not feed `hazard_score`. Only official advisories count, so a
  barangay reporting knee-deep water while PAGASA is silent still scores 0 on the
  hazard component.
- No flood-depth or elevation model. Exposure is a hand-assigned tier.
- Coverage is limited to the 24 Calumpit barangays in the seed file; anything else
  returns `404`.
