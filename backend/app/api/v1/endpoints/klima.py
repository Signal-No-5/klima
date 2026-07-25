"""Mobile-facing Klima routes (paths match Flutter AppConstants / ApiService)."""

from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Query, status

from app.schemas.klima import (
    CommunityPostOut,
    HazardOut,
    ReportCreate,
    ReportOut,
    RiskOut,
    SafeZoneOut,
)
from app.services import klima as klima_service

router = APIRouter(tags=["klima"])


@router.get("/hazard/latest", response_model=list[HazardOut])
def get_latest_hazards(
    type: Optional[str] = Query(None, description="Hazard type filter"),
    barangay: Optional[str] = Query(None),
    municipality: Optional[str] = Query(None),
) -> list[HazardOut]:
    return klima_service.list_hazards(
        hazard_type=type,
        barangay=barangay,
        municipality=municipality,
    )


@router.get("/reports", response_model=list[ReportOut])
def get_reports(
    type: Optional[str] = Query(None),
    barangay: Optional[str] = Query(None),
) -> list[ReportOut]:
    return klima_service.list_reports(report_type=type, barangay=barangay)


@router.post(
    "/reports",
    response_model=ReportOut,
    status_code=status.HTTP_201_CREATED,
)
def post_report(body: ReportCreate) -> ReportOut:
    return klima_service.create_report(body)


@router.get("/risk/{barangay_id}", response_model=RiskOut)
def get_risk(barangay_id: str) -> RiskOut:
    return klima_service.get_risk(barangay_id)


@router.get("/safezones", response_model=list[SafeZoneOut])
def get_safe_zones(
    barangay: Optional[str] = Query(None),
    municipality: Optional[str] = Query(None),
) -> list[SafeZoneOut]:
    return klima_service.list_safe_zones(
        barangay=barangay,
        municipality=municipality,
    )


@router.get("/community/posts", response_model=list[CommunityPostOut])
def get_community_posts(
    barangay: Optional[str] = Query(None),
) -> list[CommunityPostOut]:
    return klima_service.list_community_posts(barangay=barangay)
