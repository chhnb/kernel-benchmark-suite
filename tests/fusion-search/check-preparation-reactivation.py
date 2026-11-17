#!/usr/bin/env python3
"""Check the prepared-arm lifecycle in a completed tree schedule."""
import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("run", type=Path)
parser.add_argument("--shared-coordinates", action="store_true",
                    help="require both independently prepared Map-Airy candidates to be scored")
args = parser.parse_args()
summary = json.loads((args.run / "summary.json").read_text())
assert summary["status"] == "completed"
assert summary["domain_schedule"] == "trees"
seen = set()
current_parent = None
sweep_requests = 0
shared_coordinates = False
for row in summary["rounds"]:
    if row["parent"] != current_parent:
        seen.clear()
        current_parent = row["parent"]
    for decision in row["prepared_decisions"]:
        assert decision not in seen, (row["parent"], decision)
        seen.add(decision)
    prepared = {}
    for attempt in row["attempts"]:
        request = json.loads((Path(attempt["directory"]) / "request.json").read_text())
        argv = request["argv"]
        trial_input = Path(argv[argv.index("--ir") + 1])
        if trial_input.name.startswith("prepared-"):
            assert row["prepared_decisions"] and row["active_domain"]
            sweep_requests += int(not row["decision"])
            if args.shared_coordinates:
                key = (attempt["candidate"], attempt["left"], attempt["right"])
                origin = (attempt["prepared_decision"], attempt["prepared_ordinal"])
                group = prepared.setdefault(key, {})
                assert origin not in group, (key, origin)
                group[origin] = attempt["stage"]
    shared_coordinates |= any(list(group.values()).count("scored") >= 2
                              for group in prepared.values())
assert sweep_requests > 0, "Structural sweep failed to trial reactivated prepared arms"
if args.shared_coordinates:
    assert shared_coordinates, "Missing independently scored prepared candidates"
print(f"Passed: {sweep_requests} prepared-arm trials in the structural sweep")
