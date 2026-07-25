import hashlib
import json
import os

from pipeline.asset import asset
from pipeline.config import db
from pipeline.config.api import pagasa
from pipeline.utils.extract_http import extract_http
from pipeline.utils.grammar import s

FIXTURE_NAME = "pagasa_active_warning.json"


def _load_fixture() -> dict:
    path = db.FIXTURES_DIR / FIXTURE_NAME
    if not path.is_file():
        raise FileNotFoundError(
            f"Offline fixture missing: {path}. "
            "Expected data/fixtures/pagasa_active_warning.json"
        )
    with path.open(encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Fixture {path} must be a JSON object (hazard → payload)")
    return data


def _fetch_pagasa() -> dict:
    return extract_http(
        "POST",
        pagasa.ACTIVE_WARNING_ENDPOINT,
        headers=pagasa.ACTIVE_WARNING_HEADERS,
    )


def _load_active_warnings(ctx) -> dict:
    mode = os.environ.get("KLIMA_ETL_MODE", "live").lower()
    if mode == "offline":
        ctx.log(f"Offline mode: loading fixture {FIXTURE_NAME}")
        return _load_fixture()

    try:
        return _fetch_pagasa()
    except Exception as exc:
        if mode == "offline_fallback":
            ctx.warn(f"Live PAGASA fetch failed ({exc}); falling back to fixture")
            return _load_fixture()
        raise RuntimeError(
            "PAGASA ActiveWarning fetch failed. "
            "Re-run with --offline (fixture) or --offline-fallback. "
            f"Original error: {exc}"
        ) from exc


@asset(
    name="pagasa_warnings",
    stage="bronze",
    schema="""
        source_id VARCHAR PRIMARY KEY,
        hazard VARCHAR,
        payload JSON,
        inserted_at TIMESTAMP
    """,
    # Note: The @asset decorator automatically sets `inserted_at`
    dedupe_key="source_id",
    retry=1,
)
def pagasa_warnings(ctx):
    """
    Extracts and loads the latest active hazard warnings from PAGASA's API
    and stores each top-level hazard type as a separate record in the
    ``pagasa_warnings`` bronze table.

    Modes (via ``KLIMA_ETL_MODE`` / ``klima-etl --offline``):
      - live (default): POST PAGASA ActiveWarning
      - offline: load ``fixtures/pagasa_active_warning.json``
      - offline_fallback: live first, fixture on network/API failure
    """

    data = _load_active_warnings(ctx)

    records = []
    for hazard, payload in data.items():
        payload_json = json.dumps(payload, sort_keys=True)
        records.append(
            {
                "source_id": hashlib.sha256(
                    f"{hazard}{payload_json}".encode()
                ).hexdigest(),
                "hazard": hazard,
                "payload": payload_json,
            }
        )

    rows = len(records)
    ctx.log(f"✅ Parsed {rows} hazard payload{s(rows)}:\n")
    for h in records:
        print(f"🔹 {h['hazard']}")
        print(f"   → Hash: {h['source_id'][:8]}...")
        print(f"   → Size: {len(h['payload'])} bytes\n")

    return records
