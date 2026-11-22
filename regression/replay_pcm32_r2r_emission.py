#!/usr/bin/env python3
"""Rebuild one revision's pair search and quote two fixed raw PCM32 R2Rs."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess

ROOT = Path(__file__).resolve().parents[1]
FUNCTION = "_Z3pcmPi"
TRIALS = (
    (139, 137, ("B5", "H6_8", "H7_8"), "7e7d08a9d8067ea9d99d48492f573a5663796662a81fffeb449301e02ee94b41"),
    (138, 136, ("B7", "H8_10", "H9_10"), "49ecad01ebc225ea7fe90ff0af667e48c5cc8407415bfae3e1da14fb972f31ee"),
)


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_logged(command, log_path, env):
    with log_path.open("w") as log:
        print(shlex.join(map(str, command)), file=log, flush=True)
        subprocess.run(command, env=env, stdout=log, stderr=log, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("commit")
    parser.add_argument("--repo", type=Path, default=ROOT)
    parser.add_argument("--historical-run", type=Path, required=True,
                        help="Step 7 historical-run directory containing trial-136 and trial-137")
    parser.add_argument("--tti-worker", type=Path, required=True, help="Fixed LLVM24 TTI worker command")
    parser.add_argument("--out", type=Path, required=True, help="New replay directory")
    args = parser.parse_args()
    worker = args.tti_worker.resolve(strict=True)
    parent_paths = {}
    for number, parent_trial, _, expected_sha in TRIALS:
        parent = (args.historical_run / f"trial-{parent_trial}/fused.ll").resolve(strict=True)
        if sha256(parent) != expected_sha:
            parser.error(f"trial-{number} parent differs from the fixed Step 7 IR")
        parent_paths[number] = parent

    repo = ["git", "-C", args.repo]
    rev = subprocess.check_output([*repo, "rev-parse", "--verify", f"{args.commit}^{{commit}}"], text=True).strip()
    out = args.out.resolve()
    source = out / "source"
    out.mkdir(parents=True, exist_ok=False)
    source.mkdir()
    archive = subprocess.check_output([*repo, "archive", rev, "tools"])
    subprocess.run(["tar", "-xf", "-", "-C", source], input=archive, check=True)

    env = os.environ.copy()
    env["FUSION_TTI_COST_KIND"] = "throughput"
    run_logged(["bash", source / "tools/build-llvm24-tti", "--search-only"], out / "build.log", env)
    search = source / "build/llvm24-tti/fusion-search-llvm24"
    cli = (source / "tools/fusion_search_llvm24_main.cpp").read_text()
    driver = (source / "tools/decision_greedy_main.cpp").read_text()
    # These two R2Rs use the actual driver's policy at each revision. The pair
    # CLI retained experimental options after the driver moved to guarded fusion.
    historical = "--gap-trials" in driver
    options = ["--speculation", "cost", "--gap-trials", "4"] if historical else []
    for flag, value in (("--cross-level-b2r", "0"), ("--b2r-strategy", "darm"),
                        ("--ir-snapshots", "full")):
        if flag in cli:
            options.extend((flag, value))
    cleanup = "darm-cfg-dce" if historical else "darm-cfg-dce-instcombine"

    def quote(ir):
        result = json.loads(subprocess.check_output([worker, ir, FUNCTION, "--summary-only"], env=env))
        if (result["cost_kind"] != "TCK_RecipThroughput" or result["unknown"]
                or not result["verifier_passed"]):
            raise RuntimeError(f"missing verified throughput quote: {ir}")
        return result["cost"]

    rows = []
    for number, _, (split, left, right), parent_sha in TRIALS:
        folder = out / f"trial-{number}"
        folder.mkdir()
        parent = parent_paths[number]
        debug = folder / "structural"
        product = folder / "fused.ll"
        command = [search, "--ir", parent, "--function", FUNCTION, "--structural", "1",
                   "--tti-worker", worker, "--cleanup", cleanup, "--split", split, "--left", left,
                   "--right", right, "--debug-dir", debug, "--out", product, *options]
        run_logged(command, folder / "run.log", env)
        trial = debug / "trial-0"
        report = json.loads((trial / "trial.json").read_text())
        if (not report["valid"] or report["candidate"] != ":".join((FUNCTION, split, left, right))
                or report["fusion_plan"]["kind"] != "R2R"):
            raise RuntimeError(f"did not emit the fixed R2R: {folder}")
        raw = trial / "after-raw.ll"
        rows.append({"trial": number, "parent_sha256": parent_sha, "raw_ir": str(raw),
                     "raw_sha256": sha256(raw), "raw_tti": quote(raw), "cleaned_tti": quote(product)})
    receipt = json.dumps({"revision": rev, "search_sha256": sha256(search), "rows": rows}, indent=2)
    (out / "result.json").write_text(receipt + "\n")
    print(receipt)


if __name__ == "__main__":
    main()
