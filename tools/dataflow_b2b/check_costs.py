#!/usr/bin/env python3
"""Verify and price every hand-written micro scheme with the LLVM evaluator."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("evaluator", type=Path)
args = parser.parse_args()
micro = root / "tests/dataflow-b2b/micro"
costs = root / "docs/dataflow-b2b/COST_TABLE.json"
count = 0
failures = 0
for expectation in sorted(micro.glob("*/expect.json")):
    schemes = json.loads(expectation.read_text())["schemes"]
    files = {ir.stem: ir for ir in (expectation.parent / "schemes").glob("*.ll")}
    for name in sorted(files.keys() ^ schemes.keys()):
        print(f"FAIL {expectation.parent.name}/{name}: IR or expectation missing", file=sys.stderr)
        failures += 1
    for name, scheme in schemes.items():
        if name not in files:
            continue
        options = ["--original"] if name == "original" else []
        try:
            report = subprocess.run([args.evaluator, files[name], costs, *options],
                                    capture_output=True, text=True)
            if report.returncode:
                raise ValueError(report.stdout.strip() or report.stderr.strip() or
                                 f"exit {report.returncode}")
            actual = json.loads(report.stdout)["T"]
            if actual != scheme["T"]:
                raise ValueError(f"{actual} != {scheme['T']}")
        except (KeyError, OSError, ValueError) as error:
            print(f"FAIL {expectation.parent.name}/{name}: {error}", file=sys.stderr)
            failures += 1
            continue
        count += 1
        print(f"{expectation.parent.name}/{name}: {actual}")
print(f"{count} schemes verified and priced")
sys.exit(int(bool(failures)))
