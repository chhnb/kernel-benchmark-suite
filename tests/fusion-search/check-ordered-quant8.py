#!/usr/bin/env python3
"""Check the ordered schedule on the eight-leaf domain-vllm-quant8.ll fixture."""
import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("output", type=Path, help="ordered driver run directory")
args = parser.parse_args()
summary = json.loads((args.output / "summary.json").read_text())
assert summary["status"] == "completed" and summary["domain_schedule"] == "ordered"
rows = [row for row in summary["rounds"] if row["selected"]]
assert len(rows) == 7 and summary["final_cost"] == 25
expected = [(i, i) for i in range(8)]
for i, row in enumerate(rows):
    ranges = [(a["first"], a["last"]) for a in row["ordered_arms"]]
    assert ranges == expected, (i, ranges, expected)
    assert all(a["shape"] in ("B", "R") for a in row["ordered_arms"])
    if len(ranges) > 2:
        assert row["ordered_update"] == "rebound"
        left = row["ordered_left"]
        assert ranges[left][1] + 1 == ranges[left + 1][0]
        expected[left:left + 2] = [(ranges[left][0], ranges[left + 1][1])]
    product = Path(row["selected"]) / "fused.ll"
    assert "!decision.ordered_trial_boundary" not in product.read_text()
print("PASS ordered intervals and clean products across seven commits")
