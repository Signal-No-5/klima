"""Pydantic schemas matching Klima mobile JSON models."""

from __future__ import annotations

from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, ConfigDict, Field


class HazardOut(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: str
    type: str
    title: str
    description: str
    latitude: float
    longitude: float
    barangay: str = ""
    municipality: str = ""
    province: str = ""
    severity: str = "moderate"
    timestamp: datetime
    image_url: Optional[str] = None
    source: str = "citizen"
    is_verified: bool = False
    upvotes: int = 0
    reports: int = 1
    metadata: Optional[dict[str, Any]] = None


class ReportCreate(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: Optional[str] = None
    user_id: str = ""
    user_name: str = "Anonymous"
    type: str = "hazard"
    hazard_type: Optional[str] = None
    title: str = ""
    description: str = ""
    latitude: float = 0.0
    longitude: float = 0.0
    barangay: str = ""
    municipality: str = ""
    timestamp: Optional[datetime] = None
    image_url: Optional[str] = None
    image_urls: Optional[list[str]] = None
    status: str = "pending"
    responder_notes: Optional[str] = None
    responded_at: Optional[datetime] = None


class ReportOut(ReportCreate):
    id: str
    timestamp: datetime


class RiskOut(BaseModel):
    model_config = ConfigDict(extra="ignore")

    barangay_id: str
    barangay_name: str
    municipality: str
    hazard_score: float
    exposure_score: float
    vulnerability_score: float
    risk_score: float
    risk_level: str
    hazard_breakdown: dict[str, float] = Field(default_factory=dict)
    last_updated: datetime
    active_warnings: list[str] = Field(default_factory=list)
    safe_residents: int = 0
    total_population: int = 0


class SafeZoneOut(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: str
    name: str
    type: str = "evacuation_center"
    latitude: float
    longitude: float
    address: str = ""
    barangay: str = ""
    municipality: str = ""
    capacity: int = 0
    current_occupancy: int = 0
    amenities: list[str] = Field(default_factory=list)
    contact_number: Optional[str] = None
    is_operational: bool = True
    elevation: Optional[float] = None
    image_url: Optional[str] = None
    metadata: Optional[dict[str, Any]] = None


class CommunityPostOut(BaseModel):
    model_config = ConfigDict(extra="ignore")

    id: str
    title: str
    content: str
    author_name: str
    author_type: str = "citizen"
    timestamp: datetime
    image_url: Optional[str] = None
    tags: Optional[list[str]] = None
    is_pinned: bool = False
    views: int = 0
    contact_info: Optional[str] = None
