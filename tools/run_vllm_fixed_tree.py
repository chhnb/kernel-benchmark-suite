#!/usr/bin/env python3
"""Build a fixed vLLM fusion tree using a rolling IR checkpoint."""
import argparse
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SCHEDULES = {"recursive": [0] * 7, "balanced": [0, 1, 2, 3, 0, 1, 0]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shape", choices=SCHEDULES)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--tool-root", type=Path, default=ROOT)
    args = parser.parse_args()
    source = ROOT / "cases/vllm-quant/start.ll"
    tools = args.tool_root.resolve() / "build"
    out = args.out.resolve()
    out.mkdir(parents=True)
    catalog = json.loads(subprocess.check_output([
        tools / "decision-model/decision-model", source, "cache_eval"
    ]))
    trees = [row for row in catalog if len(row["arms"]) == 8
             and all(arm["kind"] == "Linear" for arm in row["arms"])]
    if len(trees) != 32:
        raise RuntimeError(f"expected 32 eight-leaf trees, found {len(trees)}")
    order = out / "leaf-order.json"
    order.write_text(json.dumps([
        {"entry": arm["entry"], "family": tree["id"], "index": index}
        for tree in trees for index, arm in enumerate(tree["arms"])
    ], indent=2))
    roots = [row["root"] for row in catalog]
    current = source
    keep = os.environ.get("DECISION_GAP_KEEP_CATALOG") == "1"
    env = dict(os.environ, DECISION_GAP_SEARCH="1", DECISION_GAP_ROOTS_STDOUT="1")
    remaining = 256
    for n, tree in enumerate(trees):
        for step, left in enumerate(SCHEDULES[args.shape]):
            trial = out / f"{n:02d}-{step}"
            with (out / f"{n:02d}-{step}.log").open("w") as log:
                result = subprocess.run([
                    tools / "decision-fuse/decision-fuse", current, "cache_eval",
                    str(roots.index(tree["root"])), str(left), trial, order
                ], env=env, stdout=subprocess.PIPE, stderr=log, check=True)
            next_roots = json.loads(result.stdout)
            report = json.loads((trial / "trial.json").read_text())
            next_ir = trial / "fused.ll"
            remaining -= 1
            if report["status"] != "verified" or next_ir.read_text().count(
                "call float @llvm.copysign.f32"
            ) != remaining:
                raise RuntimeError(f"unexpected fusion result in {trial}")
            if not keep:
                if current != source:
                    current.unlink()
                (trial / "meld-raw.ll").unlink()
            current, roots = next_ir, next_roots
        if not report.get("completed_decision"):
            raise RuntimeError(f"decision not complete in {trial}")
        print(args.shape, f"{n + 1}/32", "copysign calls:", remaining, flush=True)
    final = out / "final.ll"
    if keep:
        final.write_bytes(current.read_bytes())
    else:
        current.rename(final)


if __name__ == "__main__":
    main()
