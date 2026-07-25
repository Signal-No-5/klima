"""Silver: normalize bronze ``pagasa_warnings`` into per-region hazard rows.

Bronze stores one row per top-level PAGASA hazard, with the raw payload kept
as JSON. That payload is polymorphic (see ``docs/pagasa/``):

* flood-style products are objects keyed by severity (``4Extreme`` …)
* ``Tropical Cyclone Alert`` is an array of alert buckets

This asset flattens both shapes into one tidy table: one row per
(hazard, severity bucket, region), with severity rank/label parsed and the
advisory ``description`` stripped of HTML.
"""

from __future__ import annotations

import hashlib
import json
import re
from typing import Iterable

import duckdb

from pipeline.asset import asset
from pipeline.config import db

_SEVERITY_RE = re.compile(r"^\s*(\d+)\s*(.*)$")
_TAG_RE = re.compile(r"<[^>]+>")
_WS_RE = re.compile(r"\s+")


def _parse_severity(code: str | None) -> tuple[int | None, str | None]:
    """Split a bucket key like ``"4Extreme"`` into ``(4, "Extreme")``."""
    if not code:
        return None, None
    match = _SEVERITY_RE.match(code)
    if not match:
        return None, code or None
    rank = int(match.group(1))
    label = (match.group(2) or "").strip() or None
    return rank, label


def _clean_text(value: str | None) -> str | None:
    """Strip HTML tags / breaks and collapse whitespace."""
    if not value:
        return None
    text = value.replace("<br />", " ").replace("<br/>", " ").replace("<br>", " ")
    text = _TAG_RE.sub(" ", text)
    text = text.replace("\r", " ").replace("\n", " ").replace("**", "")
    text = _WS_RE.sub(" ", text).strip()
    return text or None


def _to_float(value) -> float | None:
    if value is None:
        return None
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _iter_buckets(value) -> Iterable[tuple[str | None, dict]]:
    """Yield ``(severity_code, bucket)`` for either payload shape."""
    if isinstance(value, dict):
        for code, bucket in value.items():
            if isinstance(bucket, dict):
                yield code, bucket
    elif isinstance(value, list):
        for bucket in value:
            if isinstance(bucket, dict):
                yield None, bucket


def _read_bronze() -> list[dict]:
    with duckdb.connect(str(db.BRONZE), read_only=True) as con:
        tables = {row[0] for row in con.execute("SHOW TABLES").fetchall()}
        if "pagasa_warnings" not in tables:
            return []
        rows = con.execute(
            "SELECT source_id, hazard, payload::VARCHAR FROM pagasa_warnings"
        ).fetchall()
    return [
        {"source_id": r[0], "hazard": r[1], "payload": r[2]} for r in rows
    ]


@asset(
    name="hazard_warnings",
    stage="silver",
    schema="""
        source_id VARCHAR PRIMARY KEY,
        bronze_source_id VARCHAR,
        hazard VARCHAR,
        hazard_class VARCHAR,
        severity_code VARCHAR,
        severity_rank INTEGER,
        severity_label VARCHAR,
        region VARCHAR,
        areas VARCHAR,
        issued_at TIMESTAMP,
        expired_at TIMESTAMP,
        centroid_lat DOUBLE,
        centroid_lon DOUBLE,
        alert_url VARCHAR,
        description VARCHAR,
        inserted_at TIMESTAMP
    """,
    dedupe_key="source_id",
    parents=["pagasa_warnings"],
    retry=1,
)
def hazard_warnings(ctx):
    """Flatten bronze PAGASA warnings into per-region silver rows."""
    bronze_rows = _read_bronze()
    ctx.log(f"Read {len(bronze_rows)} bronze hazard record(s)")

    records: list[dict] = []
    for row in bronze_rows:
        hazard = row["hazard"]
        try:
            payload = json.loads(row["payload"]) if row["payload"] else {}
        except (TypeError, ValueError):
            ctx.warn(f"Skipping unparseable payload for hazard {hazard!r}")
            continue

        for severity_code, bucket in _iter_buckets(payload):
            rank, label = _parse_severity(severity_code)
            hazard_class = bucket.get("class")
            regions = bucket.get("regions") or {}
            for region_name, region in regions.items():
                if not isinstance(region, dict):
                    continue
                centroid = region.get("centroid") or {}
                issued_at = region.get("issued_at")
                fingerprint = "|".join(
                    str(x)
                    for x in (hazard, severity_code, region_name, issued_at)
                )
                records.append(
                    {
                        "source_id": hashlib.sha256(
                            fingerprint.encode()
                        ).hexdigest(),
                        "bronze_source_id": row["source_id"],
                        "hazard": hazard,
                        "hazard_class": hazard_class,
                        "severity_code": severity_code,
                        "severity_rank": rank,
                        "severity_label": label,
                        "region": region_name,
                        "areas": region.get("areas") or region.get("area"),
                        "issued_at": issued_at,
                        "expired_at": region.get("expired_at"),
                        "centroid_lat": _to_float(centroid.get("latitude")),
                        "centroid_lon": _to_float(centroid.get("longitude")),
                        "alert_url": region.get("url"),
                        "description": _clean_text(region.get("description")),
                    }
                )

    ctx.log(f"Flattened into {len(records)} region-level row(s)")
    return records
