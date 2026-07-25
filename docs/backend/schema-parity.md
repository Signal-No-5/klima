# Backend/mobile contract parity

**Canonical source:** `schema/klima_schema/models.py`  
**Wire format:** snake_case JSON; ISO-8601 datetimes; flat coordinates.

| Contract | Mobile model | Parity notes |
|----------|--------------|--------------|
| `HazardOut` | `mobile/lib/models/hazard.dart` | All fields align; mobile maps `latitude`/`longitude` to `LatLng`. |
| `ReportCreate`, `ReportOut` | `mobile/lib/models/report.dart` | All fields and report status values align. Server assigns `id`/`timestamp` when omitted on create. |
| `RiskOut` | `mobile/lib/models/risk.dart` | Score fields are constrained to `0..1`; names align. |
| `SafeZoneOut` | `mobile/lib/models/safe_zone.dart` | All fields align; coordinates remain flat on wire. |
| `CommunityPostOut` | `mobile/lib/models/community_post.dart` | All fields align. |

## Canonical field sets

- **Hazard:** `id`, `type`, `title`, `description`, `latitude`, `longitude`,
  `barangay`, `municipality`, `province`, `severity`, `timestamp`, `image_url`,
  `source`, `is_verified`, `upvotes`, `reports`, `metadata`.
- **Report:** `id`, `user_id`, `user_name`, `type`, `hazard_type`, `title`,
  `description`, `latitude`, `longitude`, `barangay`, `municipality`,
  `timestamp`, `image_url`, `image_urls`, `status`, `responder_notes`,
  `responded_at`.
- **Risk:** `barangay_id`, `barangay_name`, `municipality`, the four score
  fields, `risk_level`, `hazard_breakdown`, `last_updated`, `active_warnings`,
  `safe_residents`, `total_population`.
- **Safe zone:** identity/location, capacity/occupancy, amenities/contact,
  operational status, elevation/image/metadata.
- **Community:** identity/content/author, timestamp/image/tags, pin/views,
  contact information.

## Change checklist

1. Edit only `schema/klima_schema/models.py`.
2. Run `uv run python -m klima_schema.export --out ../schema/exported` from
   `backend/`.
3. Update mobile serializers if a wire field changes.
4. Update this document.
5. Run backend tests and inspect `/openapi.json`.

Mobile-only `GoBagItem` and `UserLocation` are outside the MVP API contract.
