"""Pipeline CLI / runner tests (offline)."""

from __future__ import annotations

from pathlib import Path

import duckdb
import pytest

from pipeline import cli, runner


def test_parser_defaults_to_all():
    args = cli.build_parser().parse_args(["run"])
    assert args.command == "run"
    assert args.stage == "all"
    assert args.reset is False


def test_parser_rejects_unknown_stage():
    with pytest.raises(SystemExit):
        cli.build_parser().parse_args(["run", "--stage", "platinum"])


def test_stage_registry_orders_bronze_before_silver():
    stages = list(runner.STAGES)
    assert stages.index("bronze") < stages.index("silver")


def test_reset_and_summary_on_temp(tmp_path: Path, monkeypatch, capsys):
    silver_db = tmp_path / "silver.duckdb"
    monkeypatch.setattr(runner.db, "DATA_DIR", tmp_path)
    monkeypatch.setattr(runner.db, "SILVER", silver_db)

    runner.reset_stage("silver")
    assert silver_db.exists()

    with duckdb.connect(str(silver_db)) as con:
        con.execute("CREATE TABLE t (a INTEGER)")
        con.execute("INSERT INTO t VALUES (1), (2)")

    runner.summarize("silver")
    out = capsys.readouterr().out
    assert "silver warehouse" in out
    assert "t: 2 row(s)" in out


def test_run_dispatch_uses_registry(tmp_path: Path, monkeypatch):
    calls: list[str] = []
    monkeypatch.setattr(runner.db, "DATA_DIR", tmp_path)
    monkeypatch.setattr(runner.db, "SILVER", tmp_path / "silver.duckdb")
    monkeypatch.setattr(
        runner,
        "STAGES",
        {"silver": [lambda: calls.append("ran")]},
    )
    monkeypatch.setattr(cli, "runner", runner)

    cli.main(["run", "--stage", "silver"])
    assert calls == ["ran"]
