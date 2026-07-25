"""Export canonical Klima contracts as JSON Schema."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from klima_schema.models import (
    CommunityPostOut,
    HazardOut,
    ReportCreate,
    ReportOut,
    RiskOut,
    SafeZoneOut,
)

EXPORT_MODELS: dict[str, type] = {
    "HazardOut": HazardOut,
    "ReportCreate": ReportCreate,
    "ReportOut": ReportOut,
    "RiskOut": RiskOut,
    "SafeZoneOut": SafeZoneOut,
    "CommunityPostOut": CommunityPostOut,
}


def model_json_schemas() -> dict[str, Any]:
    """Return the serialization schema for every public wire contract."""
    return {
        name: model.model_json_schema(mode="serialization")
        for name, model in EXPORT_MODELS.items()
    }


def write_json_schemas(out_dir: Path) -> list[Path]:
    """Write a bundle plus one schema document per public model."""
    out_dir.mkdir(parents=True, exist_ok=True)
    schemas = model_json_schemas()
    written: list[Path] = []

    bundle = out_dir / "klima-mvp.schema.json"
    bundle.write_text(
        json.dumps(
            {
                "$schema": "https://json-schema.org/draft/2020-12/schema",
                "title": "Klima MVP contracts",
                "description": "Generated from schema/klima_schema.",
                "$defs": schemas,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )
    written.append(bundle)

    for name, schema in schemas.items():
        path = out_dir / f"{name}.schema.json"
        path.write_text(
            json.dumps(schema, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        written.append(path)

    return written


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--out",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "exported",
    )
    args = parser.parse_args(argv)
    for path in write_json_schemas(args.out):
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
