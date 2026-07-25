"""Central Klima MVP contracts — single source of truth for API shapes."""

from __future__ import annotations

from klima_schema.models import (
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

__version__ = "0.1.0"
