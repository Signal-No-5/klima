"""Hazard feed endpoints backed by the silver PAGASA warehouse."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Query
from klima_schema import HazardOut

from app.services import hazards

router = APIRouter(prefix="/hazard", tags=["hazard"])


@router.get("/latest", response_model=list[HazardOut])
def latest_hazards(
    type: Annotated[str | None, Query(description="Normalized hazard type")] = None,
    barangay: Annotated[str | None, Query()] = None,
    municipality: Annotated[str | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=500)] = 100,
    include_expired: Annotated[
        bool, Query(description="Include advisories past their expiry")
    ] = False,
) -> list[HazardOut]:
    """Active advisories, newest first.

    Returns an empty list when the silver warehouse has not been built yet;
    ``/health/ready`` reports whether that is the case.
    """
    return hazards.latest(
        hazard_type=type,
        barangay=barangay,
        municipality=municipality,
        limit=limit,
        include_expired=include_expired,
    )
