"""FastAPI-facing re-exports from the canonical ``schema/`` package.

Keep endpoint imports stable here; model definitions belong in
``klima_schema.models``.
"""

from klima_schema import (
    CommunityPostOut,
    HazardOut,
    ReportCreate,
    ReportOut,
    ReportStatus,
    ReportType,
    RiskLevel,
    RiskOut,
    SafeZoneOut,
)

__all__ = [
    "CommunityPostOut",
    "HazardOut",
    "ReportCreate",
    "ReportOut",
    "ReportStatus",
    "ReportType",
    "RiskLevel",
    "RiskOut",
    "SafeZoneOut",
]
