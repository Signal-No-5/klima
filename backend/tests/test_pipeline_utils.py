"""Unit tests for pipeline helpers that must stay pure and offline-safe."""

from datetime import datetime, timedelta, timezone

from pipeline.utils.grammar import s
from pipeline.utils.timestamp import LOCAL, hours_ago, right_now


def test_plural_suffix():
    assert s(0) == "s"
    assert s(1) == ""
    assert s(2) == "s"


def test_right_now_is_iso_ph_time():
    stamp = right_now()
    parsed = datetime.fromisoformat(stamp)
    assert parsed.tzinfo is not None
    # Philippine Time is UTC+8
    assert parsed.utcoffset() == timedelta(hours=8)
    assert LOCAL == timezone(timedelta(hours=8))


def test_hours_ago_is_before_now():
    now = datetime.fromisoformat(right_now())
    earlier = datetime.fromisoformat(hours_ago(3))
    delta = now - earlier
    assert timedelta(hours=2, minutes=50) < delta < timedelta(hours=3, minutes=10)
