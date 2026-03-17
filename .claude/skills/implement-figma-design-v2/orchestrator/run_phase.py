#!/usr/bin/env python3
"""
Phase runner for implement-figma-design skill.

Prepares prompt templates for subagent dispatch by:
1. Building placeholder bindings from CLI args
2. Rendering the prompt template via the prompt builder
3. Writing the rendered prompt to an artifacts directory
4. Returning JSON with paths for the orchestrator to use

Adapted from trycycle's run_phase.py, simplified for Figma design workflows
(no git worktrees, no transcript handling, no subagent runner dispatch).

Usage:
    python3 run_phase.py prepare \\
        --phase planning-initial \\
        --template <skill-dir>/subagents/prompt-planning-initial.md \\
        --set USER_FLOW_DESCRIPTION="Build a dashboard" \\
        --set-file DESIGN_ANALYSIS=/tmp/analysis.md \\
        --set-file FIGMA_DESIGN_CONTEXT=/tmp/figma-context.json \\
        --output-dir /tmp/figma-impl-artifacts
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path
from typing import Any


SCRIPT_DIR = Path(__file__).resolve().parent
PROMPT_BUILDER = SCRIPT_DIR / "prompt_builder" / "build.py"


class PhaseError(RuntimeError):
    pass


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _emit_json(payload: dict[str, Any]) -> None:
    json.dump(payload, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")


def prepare_phase(args: argparse.Namespace) -> None:
    """Prepare a phase by rendering the prompt template."""
    import subprocess

    # Create artifacts directory
    artifacts_dir = Path(args.output_dir) / args.phase
    artifacts_dir.mkdir(parents=True, exist_ok=True)

    # Build prompt builder command
    cmd = [
        sys.executable,
        str(PROMPT_BUILDER),
        "--template", str(args.template),
    ]

    for binding in args.set:
        cmd.extend(["--set", binding])

    for binding in args.set_file:
        cmd.extend(["--set-file", binding])

    for tag in args.require_nonempty_tag:
        cmd.extend(["--require-nonempty-tag", tag])

    for tag in args.ignore_tag_for_placeholders:
        cmd.extend(["--ignore-tag-for-placeholders", tag])

    prompt_path = artifacts_dir / "rendered-prompt.md"
    cmd.extend(["--output", str(prompt_path)])

    # Run prompt builder
    result = subprocess.run(cmd, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise PhaseError(f"Prompt builder failed: {result.stderr.strip()}")

    # Write result metadata
    result_payload = {
        "phase": args.phase,
        "prompt_path": str(prompt_path),
        "template_path": str(args.template),
        "artifacts_dir": str(artifacts_dir),
    }

    result_path = artifacts_dir / "result.json"
    _write_json(result_path, result_payload)

    # Emit to stdout for orchestrator
    _emit_json(result_payload)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Phase runner for implement-figma-design skill."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # prepare subcommand
    prepare = subparsers.add_parser("prepare", help="Prepare a phase prompt")
    prepare.add_argument("--phase", required=True, help="Phase name")
    prepare.add_argument("--template", required=True, type=Path, help="Prompt template path")
    prepare.add_argument("--set", action="append", default=[], metavar="NAME=VALUE")
    prepare.add_argument("--set-file", action="append", default=[], metavar="NAME=PATH")
    prepare.add_argument("--require-nonempty-tag", action="append", default=[], metavar="TAG")
    prepare.add_argument("--ignore-tag-for-placeholders", action="append", default=[], metavar="TAG")
    prepare.add_argument(
        "--output-dir",
        default=os.path.join(tempfile.gettempdir(), "figma-impl-artifacts"),
        help="Directory for phase artifacts"
    )

    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if args.command == "prepare":
        prepare_phase(args)
    else:
        raise PhaseError(f"Unknown command: {args.command}")


if __name__ == "__main__":
    try:
        main()
    except PhaseError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
