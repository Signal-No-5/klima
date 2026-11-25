"""Compose barangay risk from live hazard data and static baselines.

Hazard exposure is the only component Klima can currently measure: it comes from
the silver PAGASA advisories covering the barangay. Exposure and vulnerability
are static baselines from ``backend/data/seed/barangays.json`` until census and
DRRM sources are wired in. Weights and thresholds live here so the mobile and
dashboard surfaces cannot disagree about what "high risk" means.
"""

from __future__ import annotations

from datetime import UTC, datetime

from klima_schema import HazardOut, RiskLevel, RiskOut

from app.services import hazards as hazard_service
from app.services import seed

HAZARD_WEIGHT = 0.5
EXPOSURE_WEIGHT = 0.3
VULNERABILITY_WEIGHT = 0.2

# Contribution of a single advisory by mapped severity.
_SEVERITY_WEIGHT = {
    "low": 0.25,
    "moderate": 0.5,
    "high": 0.75,
    "critical": 1.0,
}

_LEVEL_THRESHOLDS = (
    (0.75, RiskLevel.CRITICAL),
    (0.5, RiskLevel.HIGH),
    (0.25, RiskLevel.MODERATE),
)


def severity_weight(severity: str) -> float:
    return _SEVERITY_WEIGHT.get(severity.strip().lower(), 0.5)


def level_for(score: float) -> RiskLevel:
    for threshold, level in _LEVEL_THRESHOLDS:
        if score >= threshold:
            return level
    return RiskLevel.LOW


def hazard_breakdown(active: list[HazardOut]) -> dict[str, float]:
    """Worst active severity weight per hazard type."""
    breakdown: dict[str, float] = {}
    for hazard in active:
        weight = severity_weight(hazard.severity)
        breakdown[hazard.type] = max(breakdown.get(hazard.type, 0.0), weight)
    return breakdown


def active_for(baseline: seed.BarangayBaseline) -> list[HazardOut]:
    """Every active advisory covering a barangay at any granularity.

    PAGASA publishes at region, province, and nationwide scope, so all three are
    queried and unioned. Stopping at the first scope that matched would let a
    broad nationwide alert hide a severe province-level one.
    """
    scopes = [baseline.name, baseline.municipality, baseline.province]
    found: dict[str, HazardOut] = {}
    for scope in scopes:
        if not scope:
            continue
        for hazard in hazard_service.latest(barangay=scope, limit=200):
            found[hazard.id] = hazard
    return list(found.values())


def for_barangay(identifier: str) -> RiskOut | None:
    """Risk for one barangay, or ``None`` when the barangay is unknown."""
    baseline = seed.barangay(identifier)
    if baseline is None:
        return None

    active = active_for(baseline)

    breakdown = hazard_breakdown(active)
    hazard_score = max(breakdown.values(), default=0.0)
    risk_score = (
        HAZARD_WEIGHT * hazard_score
        + EXPOSURE_WEIGHT * baseline.exposure_score
        + VULNERABILITY_WEIGHT * baseline.vulnerability_score
    )
    risk_score = round(min(max(risk_score, 0.0), 1.0), 4)

    return RiskOut(
        barangay_id=baseline.id,
        barangay_name=baseline.name,
        municipality=baseline.municipality,
        hazard_score=round(hazard_score, 4),
        exposure_score=baseline.exposure_score,
        vulnerability_score=baseline.vulnerability_score,
        risk_score=risk_score,
        risk_level=level_for(risk_score),
        hazard_breakdown={key: round(value, 4) for key, value in breakdown.items()},
        last_updated=datetime.now(UTC),
        active_warnings=sorted({hazard.title for hazard in active}),
        safe_residents=0,
        total_population=baseline.total_population,
    )
