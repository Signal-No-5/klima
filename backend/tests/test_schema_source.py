"""Ensure Klima MVP models come from the central schema package."""

from __future__ import annotations

import app.schemas.klima as klima_schemas
import klima_schema
from klima_schema.models import HazardOut as CanonicalHazardOut


def test_backend_reexports_central_schema_models():
    assert klima_schemas.HazardOut is CanonicalHazardOut
    assert klima_schemas.HazardOut is klima_schema.HazardOut
    for name in (
        "HazardOut",
        "ReportCreate",
        "ReportOut",
        "RiskOut",
        "SafeZoneOut",
        "CommunityPostOut",
    ):
        assert getattr(klima_schemas, name) is getattr(klima_schema, name)


def test_json_schema_export_includes_mvp_entities():
    from klima_schema.export import model_json_schemas

    schemas = model_json_schemas()
    assert set(schemas) >= {
        "HazardOut",
        "ReportCreate",
        "ReportOut",
        "RiskOut",
        "SafeZoneOut",
        "CommunityPostOut",
    }
    assert "properties" in schemas["HazardOut"]
    assert "latitude" in schemas["HazardOut"]["properties"]
