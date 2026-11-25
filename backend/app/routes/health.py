"""Readiness detail for the data sources the API serves from.

``/health`` stays a flat liveness check for orchestrators. This endpoint answers
the question that actually causes empty feeds in practice: has the pipeline been
run, and are the seed files present?
"""

from __future__ import annotations

from fastapi import APIRouter

from app.services import hazards, seed, warehouse

router = APIRouter(prefix="/health", tags=["main"])


@router.get("/ready")
def readiness() -> dict:
    silver = warehouse.silver_path()
    hazard_table = warehouse.table_exists("hazard_warnings")
    active = len(hazards.latest(limit=500)) if hazard_table else 0

    checks = {
        "silver_warehouse": {
            "path": str(silver),
            "present": silver.exists(),
            "hazard_table": hazard_table,
            "active_advisories": active,
        },
        "seed": {
            "safe_zones": len(seed.safe_zones()),
            "community_posts": len(seed.community_posts()),
            "barangay_baselines": len(seed.barangays()),
        },
    }
    degraded = not hazard_table or active == 0
    return {"status": "degraded" if degraded else "ok", "checks": checks}
