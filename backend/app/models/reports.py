"""Persistence model for citizen reports.

The wire contract lives in ``klima_schema``; this table is the storage shape.
They are deliberately separate: the table carries server-owned columns
(``created_at``) and stores list fields as JSON text, which the contract should
not expose.
"""

from datetime import datetime
from typing import Optional

from sqlmodel import Field, SQLModel


class CitizenReport(SQLModel, table=True):
    id: str = Field(primary_key=True)
    user_id: str = Field(default="")
    user_name: str = Field(default="Anonymous")
    type: str = Field(default="hazard", index=True)
    hazard_type: Optional[str] = Field(default=None)
    title: str = Field(default="")
    description: str = Field(default="")
    latitude: float = Field(default=0.0)
    longitude: float = Field(default=0.0)
    barangay: str = Field(default="", index=True)
    municipality: str = Field(default="")
    timestamp: datetime = Field(default_factory=datetime.now, index=True)
    image_url: Optional[str] = Field(default=None)
    image_urls_json: Optional[str] = Field(default=None)
    status: str = Field(default="pending", index=True)
    responder_notes: Optional[str] = Field(default=None)
    responded_at: Optional[datetime] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.now)
