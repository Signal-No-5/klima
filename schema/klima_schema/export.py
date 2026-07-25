"""Export central Klima contracts as JSON Schema documents.

Usage (from repo root or schema/):

    python -m klima_schema.export
    # or after install:
    klima-schema-export
    klima-schema-export --out schema/exported

Also available at runtime via FastAPI OpenAPI once the backend re-exports
these models: GET /openapi.json (component schemas HazardOut, ReportOut, …).
"""

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

# Models that define the wire contract (create + response variants where needed).
EXPORT_MODELS: dict[str, type] = {
    "HazardOut": HazardOut,
    "ReportCreate": ReportCreate,
    "ReportOut": ReportOut,
    "RiskOut": RiskOut,
    "SafeZoneOut": SafeZoneOut,
    "CommunityPostOut": CommunityPostOut,
}


def model_json_schemas() -> dict[str, Any]:
    """Return a name → JSON Schema map for all MVP entities."""
    return {
        name: model.model_json_schema(mode="serialization")
        for name, model in EXPORT_MODELS.items()
    }


def write_json_schemas(out_dir: Path) -> list[Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    bundle = model_json_schemas()
    bundle_path = out_dir / "klima-mvp.schema.json"
    bundle_path.write_text(
        json.dumps(
            {
                "$schema": "https://json-schema.org/draft/2020-12/schema",
                "title": "Klima MVP contracts",
                "description": (
                    "Generated from schema/klima_schema — single source of truth."
                ),
                "$defs": bundle,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )
    written.append(bundle_path)

    for name, schema in bundle.items():
        path = out_dir / f"{name}.schema.json"
        path.write_text(
            json.dumps(schema, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        written.append(path)
    return written


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Export Klima JSON Schemas")
    default_out = Path(__file__).resolve().parents[1] / "exported"
    parser.add_argument(
        "--out",
        type=Path,
        default=default_out,
        help=f"Output directory (default: {default_out})",
    )
    args = parser.parse_args(argv)
    paths = write_json_schemas(args.out)
    for path in paths:
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
