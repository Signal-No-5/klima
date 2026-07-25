"""Re-export Klima MVP contracts from the central `schema/` package.

Canonical definitions live in `klima_schema.models`. Keep this module as a
thin FastAPI-facing façade so existing `from app.schemas.klima import …`
imports continue to work.
"""

from __future__ import annotations

from klima_schema import (
    CommunityPostOut,
    HazardOut,
    ReportCreate,
    ReportOut,
    RiskOut,
    SafeZoneOut,
)

__all__ = [
    "CommunityPostOut",
    "HazardOut",
    "ReportCreate",
    "ReportOut",
    "RiskOut",
    "SafeZoneOut",
]
