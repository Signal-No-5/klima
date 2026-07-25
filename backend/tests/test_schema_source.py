"""Central contract source, validation, and export tests."""

from __future__ import annotations

import json
from datetime import UTC, datetime

import klima_schema
import pytest
from klima_schema.export import model_json_schemas, write_json_schemas
from klima_schema.models import HazardOut
from pydantic import ValidationError

import app.schemas.klima as backend_schema

PUBLIC_MODELS = {
    "HazardOut",
    "ReportCreate",
    "ReportOut",
    "RiskOut",
    "SafeZoneOut",
    "CommunityPostOut",
}


def test_backend_reexports_canonical_models():
    for name in PUBLIC_MODELS:
        assert getattr(backend_schema, name) is getattr(klima_schema, name)


def test_export_contains_all_public_models(tmp_path):
    schemas = model_json_schemas()
    assert PUBLIC_MODELS <= schemas.keys()
    assert {"latitude", "longitude"} <= schemas["HazardOut"]["properties"].keys()

    paths = write_json_schemas(tmp_path)
    assert len(paths) == len(PUBLIC_MODELS) + 1
    bundle = json.loads((tmp_path / "klima-mvp.schema.json").read_text())
    assert PUBLIC_MODELS <= bundle["$defs"].keys()


def test_contract_rejects_unknown_fields():
    with pytest.raises(ValidationError, match="extra_forbidden"):
        HazardOut(
            id="h1",
            type="flood",
            title="Flood warning",
            description="",
            latitude=14.6,
            longitude=121.0,
            timestamp=datetime.now(UTC),
            surprise="contract drift",
        )


@pytest.mark.parametrize(
    ("latitude", "longitude"),
    [(91, 121), (-91, 121), (14, 181), (14, -181)],
)
def test_hazard_rejects_invalid_coordinates(latitude, longitude):
    with pytest.raises(ValidationError):
        HazardOut(
            id="h1",
            type="flood",
            title="Flood warning",
            description="",
            latitude=latitude,
            longitude=longitude,
            timestamp=datetime.now(UTC),
        )
