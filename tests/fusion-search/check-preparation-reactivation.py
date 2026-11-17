#!/usr/bin/env python3
"""Check the prepared-arm lifecycle in a completed PCM32 tree schedule."""
import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("run", type=Path)
args = parser.parse_args()
summary = json.loads((args.run / "summary.json").read_text())
assert summary["status"] == "completed"
assert summary["domain_schedule"] == "trees"
seen = set()
current_parent = None
sweep_requests = 0
for row in summary["rounds"]:
    if row["parent"] != current_parent:
        seen.clear()
        current_parent = row["parent"]
    for decision in row["prepared_decisions"]:
        assert decision not in seen, (row["parent"], decision)
        seen.add(decision)
    if row["decision"]:
        continue
    for attempt in row["attempts"]:
        request = json.loads((Path(attempt["directory"]) / "request.json").read_text())
        argv = request["argv"]
        trial_input = Path(argv[argv.index("--ir") + 1])
        if trial_input.name.startswith("prepared-"):
            assert row["prepared_decisions"] and row["active_domain"]
            sweep_requests += 1
assert sweep_requests > 0, "Structural sweep failed to trial reactivated prepared arms"
print(f"PCM32 passed: {sweep_requests} prepared-arm trials in the structural sweep")
