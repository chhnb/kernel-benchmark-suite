#!/usr/bin/env python3
"""Verify and price every hand-written micro scheme with the LLVM evaluator."""
import argparse
import json
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("evaluator", type=Path)
args = parser.parse_args()
micro = root / "tests/dataflow-b2b/micro"
costs = root / "docs/dataflow-b2b/COST_TABLE.json"
count = 0
for expectation in sorted(micro.glob("*/expect.json")):
    schemes = json.loads(expectation.read_text())["schemes"]
    files = {ir.stem: ir for ir in (expectation.parent / "schemes").glob("*.ll")}
    if files.keys() != schemes.keys():
        raise ValueError(f"{expectation.parent}: scheme names do not match")
    for name, scheme in schemes.items():
        options = ["--original"] if name == "original" else []
        report = subprocess.check_output([args.evaluator, files[name], costs, *options])
        actual = json.loads(report)["T"]
        if actual != scheme["T"]:
            raise ValueError(f"{expectation.parent.name}/{name}: {actual} != {scheme['T']}")
        count += 1
        print(f"{expectation.parent.name}/{name}: {actual}")
print(f"{count} schemes verified and priced")
