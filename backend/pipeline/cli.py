"""Klima data pipeline CLI.

Examples:
    python -m pipeline run --stage all --reset
    python -m pipeline run --stage bronze
    python -m pipeline summary --stage silver
    python -m pipeline loop --stage all --interval 900
"""

from __future__ import annotations

import argparse
import sys
import time

from pipeline import runner

_STAGE_CHOICES = [*runner.STAGES.keys(), "all"]


def _dispatch_run(stage: str, reset: bool) -> None:
    stages = list(runner.STAGES) if stage == "all" else [stage]
    if reset:
        for s in stages:
            runner.reset_stage(s)
    if stage == "all":
        runner.run_all()
    else:
        runner.run_stage(stage)
    for s in stages:
        runner.summarize(s)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="pipeline", description="Klima medallion data pipeline"
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_run = sub.add_parser("run", help="Materialize one stage or all stages")
    p_run.add_argument("--stage", choices=_STAGE_CHOICES, default="all")
    p_run.add_argument("--reset", action="store_true", help="Drop target(s) first")

    p_sum = sub.add_parser("summary", help="Print current warehouse contents")
    p_sum.add_argument("--stage", choices=_STAGE_CHOICES, default="all")

    p_loop = sub.add_parser("loop", help="Run repeatedly on an interval")
    p_loop.add_argument("--stage", choices=_STAGE_CHOICES, default="all")
    p_loop.add_argument("--interval", type=int, default=900, help="Seconds")
    p_loop.add_argument("--reset-first", action="store_true")

    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    if args.command == "run":
        _dispatch_run(args.stage, args.reset)
        return 0

    if args.command == "summary":
        stages = list(runner.STAGES) if args.stage == "all" else [args.stage]
        for s in stages:
            runner.summarize(s)
        return 0

    if args.command == "loop":
        first = True
        while True:
            reset = args.reset_first and first
            try:
                _dispatch_run(args.stage, reset)
            except Exception as exc:  # keep the scheduler alive across failures
                print(f"pipeline run failed: {exc}", file=sys.stderr)
            first = False
            print(f"Sleeping {args.interval}s until next run…", flush=True)
            time.sleep(args.interval)

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
