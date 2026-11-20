#!/usr/bin/env python3
"""Record planner outcomes for nontrivial anchor ordering and reuse."""

import json
from pathlib import Path
import subprocess
import sys
import tempfile


search, worker, opt = map(Path, sys.argv[1:])
fixtures = Path(__file__).parent / "b2b-anchor"
cases = ("shared-producer", "crossed-chains", "lis-drops-parent")

with tempfile.TemporaryDirectory() as directory:
    for case in cases:
        root = Path(directory) / case
        output = root.with_suffix(".ll")
        result = subprocess.run(
            [search, "--ir", fixtures / f"{case}.ll", "--function", "diamond",
             "--split", "B0", "--left", "B1", "--right", "B2",
             "--b2b-strategy", "anchor", "--tti-worker", worker,
             "--out", output, "--debug-dir", root],
            check=False,
        )
        if result.returncode not in (0, 4):
            raise subprocess.CalledProcessError(result.returncode, result.args)
        if output.exists():
            subprocess.run([opt, "-verify", "-disable-output", output], check=True)
        trial = json.loads((root / "trial-0/trial.json").read_text())
        layouts = []
        for row in trial["layout_profitability"]:
            metrics = row.get("score_result", {}).get("metrics", {})
            layouts.append({
                "layout": row["layout"],
                "tti": metrics.get("work_after"),
                "anchor": row.get("anchor"),
            })
        metrics = trial["score_result"]["metrics"]
        print(json.dumps({"case": case, "layout": trial["merge_path"],
                          "before": metrics.get("work_before"), "after": metrics.get("work_after"),
                          "layouts": layouts}, sort_keys=True))
