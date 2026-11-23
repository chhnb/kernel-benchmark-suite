#!/usr/bin/env python3
"""Run the medium-tier solver, bounded reference search and direct comparators."""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import gzip
import json
from pathlib import Path
import subprocess
import sys
import time

from check_step5_small import CORPUS, COSTS, read_solution, select
from run_step2 import error, invoke, read_report
from run_step3 import direct_pair


def save(path, report):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(report, indent=2) + "\n")
    temporary.replace(path)


def inputs(args):
    rows = json.loads((CORPUS / "inventory-b2b.json").read_text())["regions"]
    for row in rows:
        if row["size_bucket"] != "medium":
            continue
        folder = args.work / row["id"]
        folder.mkdir(parents=True, exist_ok=True)
        original = CORPUS / row["ir"]
        if original.suffix == ".gz":
            dest = folder / "input.ll"
            dest.write_bytes(gzip.decompress(original.read_bytes()))
            original = dest
        yield row, folder, original


def solve(row, folder, source, args):
    if (folder / "ilp.json").exists():
        return
    stamp = time.monotonic()
    command = [sys.executable, "tools/dataflow_b2b/ilp_solver", source, COSTS,
               folder / "ilp", "--cost=real", "--condition-source", row["condition_source"],
               "--reference", args.tools / "reference_solver", "--interpreter",
               args.tools / "interpret_region", "--seconds", str(args.seconds)]
    try:
        process = subprocess.run(command, capture_output=True, text=True, timeout=args.seconds + 10)
        result = read_report(process)
        if process.stderr:
            (folder / "ilp.stderr").write_text(process.stderr)
    except subprocess.TimeoutExpired:
        result = {"status": "timeout", "reason": "external process deadline"}
    result["driver_seconds"] = time.monotonic() - stamp
    save(folder / "ilp.json", result)


def reference(row, folder, source, args):
    if (folder / "reference.json").exists():
        return
    result = read_solution([args.tools / "reference_solver", source, COSTS, folder / "reference",
                            "--cost=real"], 620)
    if result.get("complete"):
        baseline = result["original_T"]
        front = result["pareto_front"]
        best = min([baseline, *(f["T"] for f in front)])
        policy = select(front, baseline, row["condition_source"])
        result["expected"] = {"min_D": best, "strategy": policy}
    save(folder / "reference.json", result)


def assess(evaluator, source, *flags):
    result = read_report(invoke([evaluator, source, COSTS, "--cost=real", *flags], timeout=90))
    result.pop("operations", None)
    return result


def baselines(row, folder, source, args):
    if (folder / "baselines.json").exists():
        return
    evaluator = args.tools / "evaluate_cost"
    original = assess(evaluator, source, "--original")
    if row["kind"] == "b2b-triangle":
        output = {name: original | {"status": "unchanged" if original.get("T") else "unpriced"}
                  for name in ("anchor", "darm")}
    else:
        pair = direct_pair(source)
        flags = [flag for key, block in zip(("--split", "--left", "--right"), pair or ())
                 for flag in (key, block)]
        output = {}
        for name in ("anchor", "darm"):
            if not pair:
                output[name] = {"status": "no_pair", "reason": "could not resolve branch successors"}
                continue
            dest = folder / f"{name}.ll"
            debug = folder / name
            run = invoke([args.tools / "fusion-search-llvm24", "--ir", source,
                          "--function", "region", *flags, "--out", dest,
                          "--debug-dir", debug, "--ir-snapshots", "compact",
                          "--b2b-strategy", name, "--tti-worker",
                          Path("tools/run-llvm24-tti").resolve()], timeout=120)
            if not run.returncode and dest.is_file():
                abi = ["--output-buffer"] if row["num_outputs"] > 1 else []
                result = assess(evaluator, dest, *abi)
            else:
                result = {"status": "unavailable", "reason": error(run)}
            trial_file = debug / "trial-0" / "trial.json"
            if trial_file.is_file():
                trial = json.loads(trial_file.read_text())
                result["trial"] = {key: trial[key] for key in ("eligible", "reason", "merge_path",
                                                               "fusion_plan") if key in trial}
            result["pair"] = pair
            output[name] = result
    save(folder / "baselines.json", {"original": original, **output})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("work", type=Path)
    parser.add_argument("--tools", type=Path, default=Path("build/llvm24-tti"))
    parser.add_argument("--jobs", type=int, default=88)
    parser.add_argument("--seconds", type=float, default=600)
    args = parser.parse_args()
    rows = sorted(inputs(args), key=lambda item: -(item[0]["left_ops"] + item[0]["right_ops"]))
    with ThreadPoolExecutor(args.jobs) as long, ThreadPoolExecutor(20) as short:
        futures = {}
        for row, folder, source in rows:
            futures[long.submit(solve, row, folder, source, args)] = ("ilp", row["id"])
            futures[short.submit(baselines, row, folder, source, args)] = ("baselines", row["id"])
            if row["left_ops"] + row["right_ops"] <= 14:
                futures[short.submit(reference, row, folder, source, args)] = ("reference", row["id"])
        totals = dict.fromkeys(("ilp", "baselines", "reference"), 0)
        for future in as_completed(futures):
            kind, uid = futures[future]
            try:
                future.result()
            except Exception as exc:
                save(args.work / uid / f"{kind}.json", {"status": "error", "reason": str(exc)})
            totals[kind] += 1
            if totals[kind] % 10 == 0:
                print(totals, flush=True)
        print(totals, flush=True)


if __name__ == "__main__":
    main()
