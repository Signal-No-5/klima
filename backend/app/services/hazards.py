"""Map silver PAGASA advisories onto the ``HazardOut`` contract.

Silver rows are regional: PAGASA publishes per-region advisories with a
comma-separated list of covered provinces, while the mobile contract is
barangay-scoped. Region and covered areas are therefore carried in ``metadata``
rather than guessed into ``province``, and place filters match against coverage.
See ``docs/backend/hazard-mapping.md``.
"""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any

from klima_schema import HazardOut

from app.services import warehouse

_TABLE = "hazard_warnings"

# PAGASA product families -> mobile hazard type vocabulary.
_TYPE_BY_CLASS = {
    "flood-warning": "flood",
    "flood-advisory": "flood",
    "rainfall-warning": "flood",
    "thunderstorm-warning": "storm",
    "tropical-cyclone": "typhoon",
}
_TYPE_KEYWORDS = (
    ("flood", "flood"),
    ("cyclone", "typhoon"),
    ("typhoon", "typhoon"),
    ("rain", "flood"),
    ("thunderstorm", "storm"),
    ("wind", "storm"),
    ("landslide", "landslide"),
    ("heat", "heatwave"),
)

# PAGASA severity buckets are ranked 1..4; mobile expects named severities.
_SEVERITY_BY_RANK = {1: "low", 2: "moderate", 3: "high", 4: "critical"}


def classify_type(hazard: str | None, hazard_class: str | None) -> str:
    """Normalize a PAGASA product name into the mobile hazard vocabulary."""
    if hazard_class:
        mapped = _TYPE_BY_CLASS.get(hazard_class.strip().lower())
        if mapped:
            return mapped
    haystack = f"{hazard or ''} {hazard_class or ''}".lower()
    for keyword, hazard_type in _TYPE_KEYWORDS:
        if keyword in haystack:
            return hazard_type
    return "advisory"


def classify_severity(rank: int | None, label: str | None) -> str:
    if rank in _SEVERITY_BY_RANK:
        return _SEVERITY_BY_RANK[rank]
    if label:
        lowered = label.strip().lower()
        if lowered in set(_SEVERITY_BY_RANK.values()):
            return lowered
    return "moderate"


def _areas(value: str | None) -> list[str]:
    if not value:
        return []
    return [part.strip() for part in value.split(",") if part.strip()]


def to_hazard(row: dict[str, Any]) -> HazardOut | None:
    """Convert one silver row to ``HazardOut``, or ``None`` if unusable.

    Rows without a centroid cannot be placed on the map, and rows without an
    issue time cannot be ordered in the feed; both are dropped rather than
    filled with sentinel coordinates.
    """
    latitude = row.get("centroid_lat")
    longitude = row.get("centroid_lon")
    issued_at = row.get("issued_at")
    if latitude is None or longitude is None or issued_at is None:
        return None

    hazard = row.get("hazard") or "Advisory"
    region = row.get("region") or ""
    areas = _areas(row.get("areas"))

    metadata: dict[str, Any] = {
        "region": region,
        "areas": areas,
        "pagasa_product": hazard,
        "hazard_class": row.get("hazard_class"),
        "severity_code": row.get("severity_code"),
        "severity_rank": row.get("severity_rank"),
    }
    if row.get("alert_url"):
        metadata["alert_url"] = row["alert_url"]
    if row.get("expired_at"):
        metadata["expires_at"] = _isoformat(row["expired_at"])

    return HazardOut(
        id=str(row["source_id"]),
        type=classify_type(hazard, row.get("hazard_class")),
        title=f"{hazard} — {region}" if region else hazard,
        description=row.get("description") or "",
        latitude=float(latitude),
        longitude=float(longitude),
        severity=classify_severity(row.get("severity_rank"), row.get("severity_label")),
        timestamp=issued_at,
        source="pagasa",
        is_verified=True,
        upvotes=0,
        reports=1,
        metadata=metadata,
    )


def _isoformat(value: Any) -> str:
    if isinstance(value, datetime):
        return value.isoformat()
    return str(value)


# Nationwide products (e.g. Tropical Cyclone Alert) are scoped to this pseudo
# region rather than an area list, so a province-name match would miss them.
NATIONWIDE_SCOPES = {"philippine area of responsibility"}


def covers(hazard: HazardOut, place: str) -> bool:
    """Whether a place name falls inside this advisory's stated coverage."""
    needle = place.strip().lower()
    if not needle:
        return True
    metadata = hazard.metadata or {}
    region = str(metadata.get("region", ""))
    areas = [str(area) for area in metadata.get("areas", [])]

    if region.strip().lower() in NATIONWIDE_SCOPES:
        return True

    haystack = [hazard.barangay, hazard.municipality, hazard.province, region, *areas]
    return any(needle in value.lower() for value in haystack if value)


def latest(
    *,
    hazard_type: str | None = None,
    barangay: str | None = None,
    municipality: str | None = None,
    limit: int = 100,
    include_expired: bool = False,
) -> list[HazardOut]:
    """Active advisories, newest first."""
    if not warehouse.table_exists(_TABLE):
        return []

    rows = warehouse.query(
        f"SELECT * FROM {_TABLE} ORDER BY issued_at DESC"  # noqa: S608 - fixed name
    )

    now = datetime.now(UTC)
    hazards: list[HazardOut] = []
    for row in rows:
        if not include_expired and _is_expired(row.get("expired_at"), now):
            continue
        hazard = to_hazard(row)
        if hazard is None:
            continue
        if hazard_type and hazard.type != hazard_type.strip().lower():
            continue
        if barangay and not covers(hazard, barangay):
            continue
        if municipality and not covers(hazard, municipality):
            continue
        hazards.append(hazard)
        if len(hazards) >= limit:
            break
    return hazards


def _is_expired(expired_at: Any, now: datetime) -> bool:
    if not isinstance(expired_at, datetime):
        return False
    # DuckDB TIMESTAMP columns are naive; PAGASA publishes Philippine time
    # already normalized to UTC upstream in bronze.
    reference = expired_at if expired_at.tzinfo else expired_at.replace(tzinfo=UTC)
    return reference < now
