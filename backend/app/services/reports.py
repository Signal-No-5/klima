"""Store and read citizen reports.

Mobile submits with an empty ``id`` when offline-first queueing has not assigned
one, so the server mints a UUID rather than rejecting the payload.
"""

from __future__ import annotations

import json
from datetime import UTC, datetime
from uuid import uuid4

from klima_schema import ReportCreate, ReportOut
from sqlalchemy.orm import Session
from sqlmodel import select

from app.models.reports import CitizenReport


def to_row(payload: ReportCreate) -> CitizenReport:
    image_urls = payload.image_urls
    return CitizenReport(
        id=payload.id or str(uuid4()),
        user_id=payload.user_id,
        user_name=payload.user_name,
        type=str(payload.type),
        hazard_type=payload.hazard_type,
        title=payload.title,
        description=payload.description,
        latitude=payload.latitude,
        longitude=payload.longitude,
        barangay=payload.barangay,
        municipality=payload.municipality,
        timestamp=payload.timestamp or datetime.now(UTC),
        image_url=str(payload.image_url) if payload.image_url else None,
        image_urls_json=(
            json.dumps([str(url) for url in image_urls]) if image_urls else None
        ),
        status=str(payload.status),
        responder_notes=payload.responder_notes,
        responded_at=payload.responded_at,
    )


def to_contract(row: CitizenReport) -> ReportOut:
    return ReportOut(
        id=row.id,
        user_id=row.user_id,
        user_name=row.user_name,
        type=row.type,
        hazard_type=row.hazard_type,
        title=row.title,
        description=row.description,
        latitude=row.latitude,
        longitude=row.longitude,
        barangay=row.barangay,
        municipality=row.municipality,
        timestamp=row.timestamp,
        image_url=row.image_url,
        image_urls=json.loads(row.image_urls_json) if row.image_urls_json else None,
        status=row.status,
        responder_notes=row.responder_notes,
        responded_at=row.responded_at,
    )


def create(sessions: dict[str, Session], payload: ReportCreate) -> ReportOut:
    """Write one report to every configured database and return the contract."""
    row = to_row(payload)
    for session in sessions.values():
        session.add(CitizenReport(**row.model_dump()))
        session.commit()
    return to_contract(row)


def listing(
    session: Session,
    *,
    report_type: str | None = None,
    barangay: str | None = None,
    limit: int = 100,
) -> list[ReportOut]:
    statement = select(CitizenReport)
    if report_type:
        statement = statement.where(CitizenReport.type == report_type.strip().lower())
    if barangay:
        statement = statement.where(CitizenReport.barangay == barangay.strip())
    statement = statement.order_by(CitizenReport.timestamp.desc()).limit(limit)
    return [to_contract(row) for row in session.execute(statement).scalars()]
