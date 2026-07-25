"""Load reference data that has no upstream feed yet.

Safe zones, community posts, and barangay baselines are not published by PAGASA
and Klima has no LGU integration yet, so they live as JSON under
``backend/data/seed/``. Keeping them as data (validated against the central
schema on load) rather than Python literals means an LGU can replace a file
without a code change, and a malformed file fails tests instead of a request.
"""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Any

from klima_schema import CommunityPostOut, SafeZoneOut
from pydantic import BaseModel

SEED_DIR = Path(__file__).resolve().parents[2] / "data" / "seed"


class BarangayBaseline(BaseModel):
    """Static exposure/vulnerability inputs for a barangay.

    Placeholder figures pending real census and DRRM data; see
    ``docs/backend/risk-model.md``.
    """

    id: str
    name: str
    municipality: str
    province: str = ""
    exposure_score: float
    vulnerability_score: float
    total_population: int = 0


def _load(filename: str) -> list[dict[str, Any]]:
    path = SEED_DIR / filename
    if not path.exists():
        return []
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, list):
        raise ValueError(f"{path} must contain a JSON array")
    return payload


def _parse[T: BaseModel](filename: str, model: type[T]) -> list[T]:
    return [model.model_validate(item) for item in _load(filename)]


@lru_cache(maxsize=1)
def safe_zones() -> tuple[SafeZoneOut, ...]:
    return tuple(_parse("safe_zones.json", SafeZoneOut))


@lru_cache(maxsize=1)
def community_posts() -> tuple[CommunityPostOut, ...]:
    return tuple(_parse("community_posts.json", CommunityPostOut))


@lru_cache(maxsize=1)
def barangays() -> tuple[BarangayBaseline, ...]:
    return tuple(_parse("barangays.json", BarangayBaseline))


def barangay(identifier: str) -> BarangayBaseline | None:
    """Look up a baseline by id or by case-insensitive name."""
    needle = identifier.strip().lower()
    for entry in barangays():
        if entry.id.lower() == needle or entry.name.lower() == needle:
            return entry
    return None


def reset_cache() -> None:
    """Drop cached seed data; used by tests that point ``SEED_DIR`` elsewhere."""
    safe_zones.cache_clear()
    community_posts.cache_clear()
    barangays.cache_clear()
