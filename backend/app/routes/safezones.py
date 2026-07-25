"""Safe zone / evacuation centre directory."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Query
from klima_schema import SafeZoneOut

from app.services import seed

router = APIRouter(prefix="/safezones", tags=["safezones"])


def _matches(value: str, needle: str | None) -> bool:
    if not needle:
        return True
    return needle.strip().lower() in value.lower()


@router.get("", response_model=list[SafeZoneOut])
def list_safe_zones(
    barangay: Annotated[str | None, Query()] = None,
    municipality: Annotated[str | None, Query()] = None,
    operational_only: Annotated[bool, Query()] = False,
) -> list[SafeZoneOut]:
    """Directory of evacuation centres and other safe facilities.

    Sourced from ``backend/data/seed/safe_zones.json`` until an LGU facility
    feed exists.
    """
    zones = [
        zone
        for zone in seed.safe_zones()
        if _matches(zone.barangay, barangay)
        and _matches(zone.municipality, municipality)
    ]
    if operational_only:
        zones = [zone for zone in zones if zone.is_operational]
    return zones
