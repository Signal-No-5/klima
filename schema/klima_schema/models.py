"""Canonical Pydantic wire contracts for Klima.

JSON uses snake_case to match the existing Flutter serializers. Coordinates
remain flat on the wire because mobile converts them to/from ``LatLng``.
"""

from __future__ import annotations

from datetime import datetime
from enum import StrEnum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, HttpUrl


class ContractModel(BaseModel):
    """Strict base model: unexpected wire fields indicate contract drift."""

    model_config = ConfigDict(extra="forbid", use_enum_values=True)


class ReportType(StrEnum):
    HAZARD = "hazard"
    HELP = "help"
    SAFE = "safe"


class ReportStatus(StrEnum):
    PENDING = "pending"
    VERIFIED = "verified"
    RESPONDING = "responding"
    RESOLVED = "resolved"
    DISMISSED = "dismissed"


class RiskLevel(StrEnum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"
    CRITICAL = "critical"


class HazardOut(ContractModel):
    """Active official or citizen-reported hazard feed item."""

    id: str = Field(min_length=1)
    type: str = Field(min_length=1)
    title: str = Field(min_length=1)
    description: str
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    barangay: str = ""
    municipality: str = ""
    province: str = ""
    severity: str = "moderate"
    timestamp: datetime
    image_url: HttpUrl | None = None
    source: str = "citizen"
    is_verified: bool = False
    upvotes: int = Field(default=0, ge=0)
    reports: int = Field(default=1, ge=0)
    metadata: dict[str, Any] | None = None


class ReportCreate(ContractModel):
    """Citizen report/help/safe-status submission."""

    id: str | None = None
    user_id: str = ""
    user_name: str = "Anonymous"
    type: ReportType = ReportType.HAZARD
    hazard_type: str | None = None
    title: str = ""
    description: str = ""
    latitude: float = Field(default=0.0, ge=-90, le=90)
    longitude: float = Field(default=0.0, ge=-180, le=180)
    barangay: str = ""
    municipality: str = ""
    timestamp: datetime | None = None
    image_url: HttpUrl | None = None
    image_urls: list[HttpUrl] | None = None
    status: ReportStatus = ReportStatus.PENDING
    responder_notes: str | None = None
    responded_at: datetime | None = None


class ReportOut(ReportCreate):
    """Persisted report returned by the API."""

    id: str
    timestamp: datetime


class RiskOut(ContractModel):
    """Barangay-level risk components and composite score."""

    barangay_id: str
    barangay_name: str
    municipality: str
    hazard_score: float = Field(ge=0, le=1)
    exposure_score: float = Field(ge=0, le=1)
    vulnerability_score: float = Field(ge=0, le=1)
    risk_score: float = Field(ge=0, le=1)
    risk_level: RiskLevel
    hazard_breakdown: dict[str, float] = Field(default_factory=dict)
    last_updated: datetime
    active_warnings: list[str] = Field(default_factory=list)
    safe_residents: int = Field(default=0, ge=0)
    total_population: int = Field(default=0, ge=0)


class SafeZoneOut(ContractModel):
    """Evacuation center or other safe facility."""

    id: str
    name: str
    type: str = "evacuation_center"
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    address: str = ""
    barangay: str = ""
    municipality: str = ""
    capacity: int = Field(default=0, ge=0)
    current_occupancy: int = Field(default=0, ge=0)
    amenities: list[str] = Field(default_factory=list)
    contact_number: str | None = None
    is_operational: bool = True
    elevation: float | None = None
    image_url: HttpUrl | None = None
    metadata: dict[str, Any] | None = None


class CommunityPostOut(ContractModel):
    """LGU, barangay, NGO, or citizen community announcement."""

    id: str
    title: str
    content: str
    author_name: str
    author_type: str = "citizen"
    timestamp: datetime
    image_url: HttpUrl | None = None
    tags: list[str] | None = None
    is_pinned: bool = False
    views: int = Field(default=0, ge=0)
    contact_info: str | None = None
