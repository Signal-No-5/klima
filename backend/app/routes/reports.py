"""Citizen report submission and listing."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Query, status
from klima_schema import ReportCreate, ReportOut

from app.core.config import db_manager
from app.services import reports as report_service

router = APIRouter(prefix="/reports", tags=["reports"])


@router.post("", response_model=ReportOut, status_code=status.HTTP_201_CREATED)
async def submit_report(payload: ReportCreate) -> ReportOut:
    """Persist a citizen report; the server mints an id when mobile omits one."""
    async with db_manager.get_db() as sessions:
        return report_service.create(sessions, payload)


@router.get("", response_model=list[ReportOut])
async def list_reports(
    type: Annotated[str | None, Query(description="hazard, help, or safe")] = None,
    barangay: Annotated[str | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=500)] = 100,
) -> list[ReportOut]:
    async with db_manager.get_db() as sessions:
        session = next(iter(sessions.values()))
        return report_service.listing(
            session, report_type=type, barangay=barangay, limit=limit
        )
