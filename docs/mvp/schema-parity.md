# Schema field parity — mobile & frontend

**Source of truth:** [`schema/klima_schema/models.py`](../../schema/klima_schema/models.py)  
**Issue:** [#4](https://github.com/Signal-No-5/klima/issues/4)  
**Export:** see [`schema/README.md`](../../schema/README.md)

Wire JSON uses **snake_case**. Flutter models keep camelCase Dart fields but serialize with the same snake_case keys. Frontend (when built) should type against OpenAPI or the exported JSON Schema — do not invent parallel TypeScript shapes without updating the checklist.

## Hazard

| JSON field | `HazardOut` | Flutter `Hazard` | Notes |
|------------|-------------|------------------|-------|
| `id` | ✅ | ✅ | |
| `type` | ✅ | ✅ | flood, earthquake, landslide, typhoon, heatwave, … |
| `title` | ✅ | ✅ | |
| `description` | ✅ | ✅ | |
| `latitude` / `longitude` | ✅ | via `LatLng location` | Flat on wire |
| `barangay` | ✅ | ✅ | |
| `municipality` | ✅ | ✅ | |
| `province` | ✅ | ✅ | |
| `severity` | ✅ | ✅ | low / moderate / high / critical |
| `timestamp` | ✅ ISO datetime | ✅ `DateTime` | |
| `image_url` | ✅ optional | ✅ `imageUrl` | |
| `source` | ✅ | ✅ | citizen, pagasa, ndrrmc, lgu |
| `is_verified` | ✅ | ✅ `isVerified` | |
| `upvotes` | ✅ | ✅ | |
| `reports` | ✅ | ✅ | count of related reports |
| `metadata` | ✅ optional | ✅ | |

**Flutter file:** `mobile/lib/models/hazard.dart`  
**Frontend:** consume `HazardOut` from OpenAPI when implementing feed/map widgets.

## Report

| JSON field | `ReportCreate` / `ReportOut` | Flutter `Report` | Notes |
|------------|------------------------------|------------------|-------|
| `id` | optional on create; required on out | ✅ | server may assign |
| `user_id` | ✅ | ✅ `userId` | |
| `user_name` | ✅ | ✅ `userName` | |
| `type` | ✅ | ✅ | hazard, help, safe |
| `hazard_type` | ✅ optional | ✅ `hazardType` | |
| `title` | ✅ | ✅ | |
| `description` | ✅ | ✅ | |
| `latitude` / `longitude` | ✅ | via `LatLng` | |
| `barangay` | ✅ | ✅ | |
| `municipality` | ✅ | ✅ | |
| `timestamp` | optional create; required out | ✅ | |
| `image_url` | ✅ optional | ✅ | |
| `image_urls` | ✅ optional | ✅ `imageUrls` | |
| `status` | ✅ string | ✅ `ReportStatus` enum `.name` | pending, verified, responding, resolved, dismissed |
| `responder_notes` | ✅ optional | ✅ | |
| `responded_at` | ✅ optional | ✅ | |

**Flutter file:** `mobile/lib/models/report.dart`

## Risk

| JSON field | `RiskOut` | Flutter `Risk` | Notes |
|------------|-----------|----------------|-------|
| `barangay_id` | ✅ | ✅ `barangayId` | |
| `barangay_name` | ✅ | ✅ | |
| `municipality` | ✅ | ✅ | |
| `hazard_score` | ✅ | ✅ | 0–1 |
| `exposure_score` | ✅ | ✅ | |
| `vulnerability_score` | ✅ | ✅ | |
| `risk_score` | ✅ | ✅ | composite |
| `risk_level` | ✅ | ✅ | low / moderate / high / critical |
| `hazard_breakdown` | ✅ `dict[str,float]` | ✅ `Map<String,double>` | |
| `last_updated` | ✅ | ✅ | |
| `active_warnings` | ✅ | ✅ | |
| `safe_residents` | ✅ | ✅ | |
| `total_population` | ✅ | ✅ | |

**Flutter file:** `mobile/lib/models/risk.dart`  
**Frontend:** primary LGU surface for barangay risk panels.

## SafeZone

| JSON field | `SafeZoneOut` | Flutter `SafeZone` | Notes |
|------------|---------------|--------------------|-------|
| `id` | ✅ | ✅ | |
| `name` | ✅ | ✅ | |
| `type` | ✅ | ✅ | evacuation_center, hospital, … |
| `latitude` / `longitude` | ✅ | via `LatLng` | |
| `address` | ✅ | ✅ | |
| `barangay` | ✅ | ✅ | |
| `municipality` | ✅ | ✅ | |
| `capacity` | ✅ | ✅ | |
| `current_occupancy` | ✅ | ✅ `currentOccupancy` | |
| `amenities` | ✅ | ✅ | |
| `contact_number` | ✅ optional | ✅ | |
| `is_operational` | ✅ | ✅ | |
| `elevation` | ✅ optional | ✅ | meters |
| `image_url` | ✅ optional | ✅ | |
| `metadata` | ✅ optional | ✅ | |

**Flutter file:** `mobile/lib/models/safe_zone.dart`  
**Frontend:** occupancy / capacity widgets for LGU ops.

## Community

| JSON field | `CommunityPostOut` | Flutter `CommunityPost` | Notes |
|------------|--------------------|-------------------------|-------|
| `id` | ✅ | ✅ | |
| `title` | ✅ | ✅ | |
| `content` | ✅ | ✅ | |
| `author_name` | ✅ | ✅ | |
| `author_type` | ✅ | ✅ | lgu, ngp, barangay, citizen |
| `timestamp` | ✅ | ✅ | |
| `image_url` | ✅ optional | ✅ | |
| `tags` | ✅ optional | ✅ | |
| `is_pinned` | ✅ | ✅ | |
| `views` | ✅ | ✅ | |
| `contact_info` | ✅ optional | ✅ | |

**Flutter file:** `mobile/lib/models/community_post.dart`

## Out of schema scope (MVP)

These exist on mobile only and are **not** part of the central `#4` contracts yet:

- `GoBagItem` — `mobile/lib/models/gobag_item.dart`
- `UserLocation` — `mobile/lib/models/user_location.dart`

## How to verify parity after a contract change

1. Edit `schema/klima_schema/models.py`.
2. Re-export JSON Schema: `../backend/.venv/bin/python -m klima_schema.export` (from `schema/`).
3. Update Flutter `fromJson` / `toJson` if fields changed.
4. Tick / update rows in this checklist.
5. Run backend tests: `backend/.venv/bin/python -m pytest tests/test_klima_endpoints.py -q`.
6. Confirm OpenAPI components still list the six models.
