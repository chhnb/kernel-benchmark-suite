#!/usr/bin/env python3
"""Check the DP2 profitability guard in completed NQU Auto Greedy runs."""
import json
from pathlib import Path
import sys

for run_path in sys.argv[1:]:
    run = Path(run_path)
    summary = json.loads((run / "summary.json").read_text())
    assert summary["status"] == "completed"
    assert summary["b2b_strategy"] == "dp2"
    assert summary["commits"] == 2

    attempts = [attempt for row in summary["rounds"] for attempt in row["attempts"]]
    rejected = [attempt for attempt in attempts
                if attempt.get("reason") == "loop-speculation-with-only-cfg-phi-gain"
                and attempt["control_cost"] == summary["final_cost"]]
    assert rejected, run
    for attempt in rejected:
        assert not attempt["eligible"]
        report = Path(attempt["directory"]) / "structural/trial-0/trial.json"
        layouts = json.loads(report.read_text())["layout_profitability"]
        assert any(row["inside_loop"] and row["speculated_single_side_ops"] > 0
                   and row["work_gain"] == 0 and row["cfg_phi_gain"] == row["total_gain"] == 5
                   and not row["eligible"] and row["reason"] == attempt["reason"]
                   for row in layouts), report
    print(run.name, "rejected the CFG/PHI-only speculation plan")
