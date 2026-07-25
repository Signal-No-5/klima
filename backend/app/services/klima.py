"""Klima mobile-facing data access: DuckDB bronze when available, else fixtures."""

from __future__ import annotations

import json
import re
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

from app.schemas.klima import (
    CommunityPostOut,
    HazardOut,
    ReportCreate,
    ReportOut,
    RiskOut,
    SafeZoneOut,
)

# backend/data/bronze.duckdb (fixtures used when missing / empty / unreadable)
_API_ROOT = Path(__file__).resolve().parents[2]
BRONZE_DB = _API_ROOT / "data" / "bronze.duckdb"

# In-memory report store for hackathon demos
_REPORTS: list[ReportOut] = []


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _fixture_hazards() -> list[HazardOut]:
    now = _utcnow()
    return [
        HazardOut(
            id="1",
            type="flood",
            title="Mataas na baha sa Iba Este",
            description=(
                "Umabot na sa tuhod ang tubig sa Sitio San Roque. Mahirap makalabas."
            ),
            latitude=14.9167,
            longitude=120.7667,
            barangay="Iba Este",
            municipality="Calumpit",
            province="Bulacan",
            severity="high",
            timestamp=now,
            source="citizen",
            is_verified=True,
            upvotes=12,
            reports=5,
        ),
        HazardOut(
            id="2",
            type="flood",
            title="Blocked Road - Caniogan",
            description="Hindi madaanan ang kalsada dahil sa baha at debris.",
            latitude=14.9200,
            longitude=120.7600,
            barangay="Caniogan",
            municipality="Calumpit",
            province="Bulacan",
            severity="moderate",
            timestamp=now,
            source="citizen",
            is_verified=False,
            upvotes=8,
            reports=3,
        ),
        HazardOut(
            id="3",
            type="typhoon",
            title='Typhoon Signal #3 - Bulacan',
            description=(
                'PAGASA: Typhoon "Egay" is expected to make landfall in Central Luzon.'
            ),
            latitude=14.9167,
            longitude=120.7667,
            barangay="",
            municipality="Calumpit",
            province="Bulacan",
            severity="critical",
            timestamp=now,
            source="pagasa",
            is_verified=True,
            upvotes=45,
            reports=1,
        ),
    ]


def _fixture_safe_zones() -> list[SafeZoneOut]:
    return [
        SafeZoneOut(
            id="1",
            name="Calumpit National High School",
            type="evacuation_center",
            latitude=14.9180,
            longitude=120.7650,
            address="Iba Este, Calumpit, Bulacan",
            barangay="Iba Este",
            municipality="Calumpit",
            capacity=500,
            current_occupancy=120,
            amenities=["Water", "Food", "Medical", "Toilets"],
            contact_number="(044) 913-1234",
            is_operational=True,
            elevation=12.5,
        ),
        SafeZoneOut(
            id="2",
            name="Barangay Hall - Santo Niño",
            type="evacuation_center",
            latitude=14.9100,
            longitude=120.7700,
            address="Santo Niño, Calumpit, Bulacan",
            barangay="Santo Niño",
            municipality="Calumpit",
            capacity=200,
            current_occupancy=45,
            amenities=["Water", "Toilets"],
            contact_number="(044) 913-5678",
            is_operational=True,
            elevation=10.0,
        ),
        SafeZoneOut(
            id="3",
            name="Calumpit District Hospital",
            type="hospital",
            latitude=14.9150,
            longitude=120.7680,
            address="Poblacion, Calumpit, Bulacan",
            barangay="Poblacion",
            municipality="Calumpit",
            capacity=100,
            current_occupancy=30,
            amenities=["Medical", "Emergency Room", "Ambulance"],
            contact_number="(044) 913-9999",
            is_operational=True,
            elevation=15.0,
        ),
    ]


def _fixture_community_posts() -> list[CommunityPostOut]:
    now = _utcnow()
    return [
        CommunityPostOut(
            id="1",
            title="Relief Operations Schedule",
            content=(
                "Magkakaroon ng relief distribution bukas, 8:00 AM sa Barangay Hall. "
                "Magdala ng valid ID."
            ),
            author_name="Calumpit LGU",
            author_type="lgu",
            timestamp=now,
            tags=["relief", "schedule"],
            is_pinned=True,
        ),
        CommunityPostOut(
            id="2",
            title="Road Clearing Update",
            content=(
                "Tapos na ang clearing operations sa C. Mercado Street. "
                "Pwede na dumaan ang mga sasakyan."
            ),
            author_name="MDRRMO Calumpit",
            author_type="lgu",
            timestamp=now,
            tags=["update", "road"],
        ),
    ]


def _map_hazard_type(label: str) -> str:
    lower = label.lower()
    if "flood" in lower:
        return "flood"
    if any(k in lower for k in ("typhoon", "tropical", "cyclone", "depression", "storm")):
        return "typhoon"
    if "earthquake" in lower or "quake" in lower:
        return "earthquake"
    if "landslide" in lower:
        return "landslide"
    if "heat" in lower:
        return "heatwave"
    if "fire" in lower:
        return "fire"
    return "unknown"


def _map_severity(level_key: str) -> str:
    key = level_key.lower()
    if "severe" in key or "critical" in key or key.startswith("4") or key.startswith("5"):
        return "critical"
    if "moderate" in key or key.startswith("2") or key.startswith("3"):
        return "high" if "3" in key or "severe" in key else "moderate"
    if "final" in key or key.startswith("1"):
        return "moderate"
    return "moderate"


def _clean_text(text: str) -> str:
    no_tags = re.sub(r"<[^>]+>", " ", text)
    return re.sub(r"\s+", " ", no_tags).strip()


def _parse_payload(payload: Any) -> dict[str, Any]:
    if isinstance(payload, dict):
        return payload
    if isinstance(payload, str):
        return json.loads(payload)
    return json.loads(str(payload))


def _hazards_from_bronze() -> list[HazardOut]:
    import duckdb

    hazards: list[HazardOut] = []
    with duckdb.connect(str(BRONZE_DB), read_only=True) as con:
        rows = con.execute(
            "SELECT source_id, hazard, payload, inserted_at FROM pagasa_warnings"
        ).fetchall()

    for source_id, hazard_label, payload_raw, inserted_at in rows:
        payload = _parse_payload(payload_raw)
        hazard_type = _map_hazard_type(str(hazard_label))
        ts = inserted_at if isinstance(inserted_at, datetime) else _utcnow()
        if ts.tzinfo is None:
            ts = ts.replace(tzinfo=timezone.utc)

        # Expand region centroids into hazard points when present
        expanded = False
        for level_key, level_body in payload.items():
            if not isinstance(level_body, dict):
                continue
            regions = level_body.get("regions") or {}
            icon = level_body.get("iconUrl")
            severity = _map_severity(str(level_key))
            for region_name, region in regions.items():
                if not isinstance(region, dict):
                    continue
                centroid = region.get("centroid") or {}
                lat = float(centroid.get("latitude") or 0.0)
                lon = float(centroid.get("longitude") or 0.0)
                areas = region.get("areas") or ""
                description = _clean_text(str(region.get("description") or areas))
                hazards.append(
                    HazardOut(
                        id=f"{source_id[:12]}-{level_key}-{region_name}"[:64],
                        type=hazard_type,
                        title=f"{hazard_label} — {region_name}",
                        description=description[:500] or str(areas),
                        latitude=lat,
                        longitude=lon,
                        barangay="",
                        municipality="",
                        province=str(region_name),
                        severity=severity,
                        timestamp=ts,
                        image_url=icon,
                        source="pagasa",
                        is_verified=True,
                        upvotes=0,
                        reports=1,
                        metadata={
                            "source_id": source_id,
                            "level": level_key,
                            "areas": areas,
                            "class": level_body.get("class"),
                        },
                    )
                )
                expanded = True

        if not expanded:
            hazards.append(
                HazardOut(
                    id=str(source_id)[:64],
                    type=hazard_type,
                    title=str(hazard_label),
                    description=f"PAGASA active warning: {hazard_label}",
                    latitude=14.9167,
                    longitude=120.7667,
                    barangay="",
                    municipality="Calumpit",
                    province="Bulacan",
                    severity="moderate",
                    timestamp=ts,
                    source="pagasa",
                    is_verified=True,
                    metadata={"source_id": source_id, "raw_keys": list(payload.keys())},
                )
            )

    return hazards


def list_hazards(
    *,
    hazard_type: Optional[str] = None,
    barangay: Optional[str] = None,
    municipality: Optional[str] = None,
) -> list[HazardOut]:
    try:
        if BRONZE_DB.exists():
            items = _hazards_from_bronze()
            if not items:
                items = _fixture_hazards()
        else:
            items = _fixture_hazards()
    except Exception:
        items = _fixture_hazards()

    if hazard_type:
        items = [h for h in items if h.type.lower() == hazard_type.lower()]
    if barangay:
        items = [h for h in items if barangay.lower() in (h.barangay or "").lower()]
    if municipality:
        items = [
            h
            for h in items
            if municipality.lower() in (h.municipality or "").lower()
            or municipality.lower() in (h.province or "").lower()
        ]
    return items


def list_reports(
    *,
    report_type: Optional[str] = None,
    barangay: Optional[str] = None,
) -> list[ReportOut]:
    items = list(_REPORTS)
    if report_type:
        items = [r for r in items if r.type.lower() == report_type.lower()]
    if barangay:
        items = [r for r in items if barangay.lower() in (r.barangay or "").lower()]
    return items


def create_report(body: ReportCreate) -> ReportOut:
    report = ReportOut(
        id=body.id or str(uuid.uuid4()),
        user_id=body.user_id,
        user_name=body.user_name,
        type=body.type,
        hazard_type=body.hazard_type,
        title=body.title,
        description=body.description,
        latitude=body.latitude,
        longitude=body.longitude,
        barangay=body.barangay,
        municipality=body.municipality,
        timestamp=body.timestamp or _utcnow(),
        image_url=body.image_url,
        image_urls=body.image_urls,
        status=body.status or "pending",
        responder_notes=body.responder_notes,
        responded_at=body.responded_at,
    )
    _REPORTS.insert(0, report)
    return report


def get_risk(barangay_id: str) -> RiskOut:
    name = barangay_id.replace("-", " ").replace("_", " ").title() or "Unknown"
    return RiskOut(
        barangay_id=barangay_id,
        barangay_name=name,
        municipality="Calumpit",
        hazard_score=0.62,
        exposure_score=0.55,
        vulnerability_score=0.48,
        risk_score=0.58,
        risk_level="moderate",
        hazard_breakdown={"flood": 0.7, "typhoon": 0.4, "landslide": 0.1},
        last_updated=_utcnow(),
        active_warnings=["General Flood Advisory"],
        safe_residents=1200,
        total_population=4500,
    )


def list_safe_zones(
    *,
    barangay: Optional[str] = None,
    municipality: Optional[str] = None,
) -> list[SafeZoneOut]:
    items = _fixture_safe_zones()
    if barangay:
        items = [z for z in items if barangay.lower() in z.barangay.lower()]
    if municipality:
        items = [z for z in items if municipality.lower() in z.municipality.lower()]
    return items


def list_community_posts(*, barangay: Optional[str] = None) -> list[CommunityPostOut]:
    # Fixtures are Calumpit-wide; barangay filter is a no-op hook for later CMS.
    _ = barangay
    return _fixture_community_posts()


def clear_reports_for_tests() -> None:
    _REPORTS.clear()
