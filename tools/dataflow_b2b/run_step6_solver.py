#!/usr/bin/env python3
"""Rerun the Step 5/5b oracle comparisons before retrying timed-out regions."""

import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import gzip
import json
from pathlib import Path
import sys

from check_step5_small import CORPUS, COSTS, RESULTS, TARGETS, normalize_target, read_solution
from run_step2 import invoke
from run_step3 import direct_pair
from run_step5b import save


def hint(source, folder, kind):
    if kind == "b2b-triangle":
        return None
    pair = direct_pair(source)
    if not pair:
        return None
    debug = folder / "anchor"
    args = [flag for key, value in zip(("--split", "--left", "--right"), pair)
            for flag in (key, value)]
    trial = debug / "trial-0/trial.json"
    if not trial.is_file():
        invoke(["build/llvm24-tti/fusion-search-llvm24", "--ir", source,
                "--function", "region", *args, "--out", folder / "anchor.ll",
                "--debug-dir", debug, "--ir-snapshots", "compact",
                "--b2b-strategy", "anchor", "--tti-worker", "tools/run-llvm24-tti"],
               timeout=90)
    if trial.is_file():
        plan = json.loads(trial.read_text()).get("anchor", {}).get("dataflow_hint")
        if plan and plan.get("pairs"):
            result = folder / "hint.json"
            save(result, plan)
            return result
    return None


def run(item, args, inventory):
    previous, tier, mode = item
    uid = previous["id"]
    row = inventory[uid]
    folder = args.output / tier / mode / uid
    folder.mkdir(parents=True, exist_ok=True)
    report = folder / "result.json"
    if report.is_file():
        return json.loads(report.read_text())
    source = CORPUS / row["ir"]
    if source.suffix == ".gz":
        dest = folder / "input.ll"
        dest.write_bytes(gzip.decompress(source.read_bytes()))
        source = dest
    if tier == "small" and mode == "real" and (target := TARGETS.get(uid[:12])):
        source = normalize_target(source, folder / "target.ll", target)
    anchor = hint(source, folder, row["kind"])
    options = ["--anchor-hint", anchor] if anchor else []
    result = read_solution([sys.executable, "tools/dataflow_b2b/ilp_solver", source, COSTS,
                            folder / "ilp", "--cost", mode, "--condition-source",
                            row["condition_source"], "--reference", args.reference,
                            "--interpreter", args.interpreter, "--seconds", str(args.seconds),
                            *options], args.seconds + 10)
    old = previous["ilp"]
    same = None
    if tier in ("small", "proved"):
        comparison = (
            result.get("min_D", {}).get("T"),
            result.get("strategy", {}).get("T"),
        )
        expected = old["min_D"]["T"], old["strategy"]["T"]
        same = comparison == expected and all(
            result.get(k, {}).get("optimal") for k in ("min_D", "strategy"))
    record = {"id": uid, "tier": tier, "mode": mode, "kind": row["kind"],
              "condition_source": row["condition_source"], "same": same,
              "previous": {k: old.get(k) for k in ("status", "min_D", "strategy")}, "ilp": result}
    save(report, record)
    return record


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--reference", type=Path, default=Path("build/llvm24-tti/reference_solver"))
    parser.add_argument("--interpreter", type=Path, default=Path("build/llvm24-tti/interpret_region"))
    parser.add_argument("--jobs", type=int, default=80)
    parser.add_argument("--seconds", type=float, default=600)
    parser.add_argument("--phase", choices=("regression", "retry", "all"), default="all")
    args = parser.parse_args()
    inventory = {r["id"]: r for r in json.loads((CORPUS / "inventory-b2b.json").read_text())["regions"]}
    with gzip.open(RESULTS / "step5-small.json.gz") as archive:
        small = [(r, "small", r["mode"]) for r in json.load(archive) if r["status"] == "agree"]
    medium = {"proved": [], "retry": []}
    with gzip.open(RESULTS / "step5b-medium.json.gz") as archive:
        for row in json.load(archive):
            if row["status"] in ("optimal", "timeout"):
                tier = "proved" if row["status"] == "optimal" else "retry"
                medium[tier].append((row, tier, "real"))

    def campaign(tasks, label):
        tasks.sort(key=lambda task: -(inventory[task[0]["id"]]["left_ops"] +
                                      inventory[task[0]["id"]]["right_ops"]))
        with ThreadPoolExecutor(args.jobs) as pool:
            records = list(pool.map(lambda item: run(item, args, inventory), tasks))
        save(args.output / f"{label}.json", records)
        print(label, Counter((r["tier"], r["mode"], r["ilp"]["status"], r["same"])
                             for r in records), flush=True)
        return records

    if args.phase in ("regression", "all"):
        regression = campaign(small + medium["proved"], "regression")
        if any(not r["same"] for r in regression):
            return 1
    if args.phase in ("retry", "all"):
        campaign(medium["retry"], "retry")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
