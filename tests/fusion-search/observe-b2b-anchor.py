#!/usr/bin/env python3
"""Record planner outcomes for nontrivial anchor ordering and reuse."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


parser = argparse.ArgumentParser(description=__doc__)
for name in ("search", "worker", "opt"):
    parser.add_argument(name, type=Path)
parser.add_argument("--ir", type=Path, help="trace the DP on a specific module and block triple")
parser.add_argument("--function")
parser.add_argument("--anchor-gap", choices=("fork", "linear", "both", "auto"), default="fork")
parser.add_argument("--anchor-select-dedup", choices=("0", "1"), default="0")
parser.add_argument("--anchor-cutoff", choices=("static",), default="static")
parser.add_argument("--anchor-gap-rank", choices=("lazy",), default="lazy")
parser.add_argument("--anchor-guarded-gap", choices=("0", "1"), default="0")
parser.add_argument("--split")
parser.add_argument("--left")
parser.add_argument("--right")
parser.add_argument("--output", type=Path, help="write the specified pair's JSON observation here")
args = parser.parse_args()
specific = (args.ir, args.function, args.split, args.left, args.right, args.output)
if any(item is not None for item in specific) and any(item is None for item in specific):
    parser.error("specifying a pair requires --ir, --function, --split, --left, --right and --output")

search, worker, opt = args.search, args.worker, args.opt
fixtures = Path(__file__).parent / "b2b-anchor"
cases = ("shared-producer", "crossed-chains", "lis-drops-parent")

with tempfile.TemporaryDirectory() as directory:
    if args.ir is not None:
        root = Path(directory)
        debug, trace, output = root / "debug", root / "planner.jsonl", root / "candidate.ll"
        result = subprocess.run(
            [search, "--ir", args.ir, "--function", args.function,
             "--split", args.split, "--left", args.left, "--right", args.right,
             "--b2b-strategy", "anchor", "--anchor-gap", args.anchor_gap,
             "--anchor-select-dedup", args.anchor_select_dedup,
             "--anchor-cutoff", args.anchor_cutoff, "--anchor-gap-rank", args.anchor_gap_rank,
             "--anchor-guarded-gap", args.anchor_guarded_gap,
             "--structural", "1", "--tti-worker", worker,
             "--out", output, "--debug-dir", debug],
            env=os.environ | {"FUSION_OBSERVE_B2B_DP": str(trace)}, check=False,
        )
        if result.returncode not in (0, 4) or not trace.is_file():
            raise subprocess.CalledProcessError(result.returncode or 1, result.args)
        if result.returncode == 0:
            subprocess.run([opt, "-verify", "-disable-output", output], check=True)
        trial = json.loads((debug / "trial-0/trial.json").read_text())
        plans = [json.loads(line) for line in trace.read_text().splitlines()]
        args.output.write_text(json.dumps({
            "function": args.function,
            "input": str(args.ir),
            "trial": trial,
            "planner": plans,
        }, indent=2) + "\n")
        sys.exit(0)

    for case in cases:
        root = Path(directory) / case
        output = root.with_suffix(".ll")
        result = subprocess.run(
            [search, "--ir", fixtures / f"{case}.ll", "--function", "diamond",
             "--split", "B0", "--left", "B1", "--right", "B2",
             "--b2b-strategy", "anchor", "--tti-worker", worker,
             "--out", output, "--debug-dir", root],
            check=False,
        )
        if result.returncode not in (0, 4):
            raise subprocess.CalledProcessError(result.returncode, result.args)
        if output.exists():
            subprocess.run([opt, "-verify", "-disable-output", output], check=True)
        trial = json.loads((root / "trial-0/trial.json").read_text())
        layouts = []
        for row in trial["layout_profitability"]:
            metrics = row.get("score_result", {}).get("metrics", {})
            layouts.append({
                "layout": row["layout"],
                "tti": metrics.get("work_after"),
                "anchor": row.get("anchor"),
            })
        metrics = trial["score_result"]["metrics"]
        print(json.dumps({"case": case, "layout": trial["merge_path"],
                          "before": metrics.get("work_before"), "after": metrics.get("work_after"),
                          "layouts": layouts}, sort_keys=True))
