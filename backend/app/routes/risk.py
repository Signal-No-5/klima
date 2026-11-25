"""Barangay risk endpoints."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, status
from klima_schema import RiskOut

from app.services import risk as risk_service
from app.services import seed

router = APIRouter(prefix="/risk", tags=["risk"])


@router.get("", response_model=list[str])
def known_barangays() -> list[str]:
    """Barangay ids that have a risk baseline, so clients can avoid 404s."""
    return [entry.id for entry in seed.barangays()]


@router.get("/{barangay_id}", response_model=RiskOut)
def barangay_risk(barangay_id: str) -> RiskOut:
    result = risk_service.for_barangay(barangay_id)
    if result is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No risk baseline for barangay {barangay_id!r}",
        )
    return result
