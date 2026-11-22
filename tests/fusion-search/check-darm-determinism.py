#!/usr/bin/env python3
"""Replay the same HLLD R2B candidate in independent processes."""

import json
from pathlib import Path
import subprocess
import sys
import tempfile


search, worker = (Path(arg).resolve() for arg in sys.argv[1:])
fixture = Path(__file__).with_name("darm-hlld-r2b-parent.ll").resolve()

with tempfile.TemporaryDirectory() as directory:
    reference = None
    for index in range(5):
        run = Path(directory) / str(index)
        run.mkdir()
        subprocess.run([
            search, "--ir", fixture,
            "--function", "_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii",
            "--split", "B9", "--left", "B22", "--right", "B12",
            "--anchor-wave-shape", "128,1,1", "--tti-worker", worker,
            "--debug-dir", "structural", "--out", "fused.ll",
        ], cwd=run, check=True, stdout=subprocess.DEVNULL)
        trial = run / "structural/trial-0"
        receipt = json.loads((trial / "trial.json").read_text())
        assert receipt["valid"] and receipt["merge_path"] == "darm-R2B"
        assert receipt["replication_required"]
        assert receipt["score_result"] is not None
        snapshot = tuple((trial / name).read_bytes()
                         for name in ("after-raw.ll", "after.ll"))
        current = (snapshot, receipt["score_result"])
        if reference is None:
            reference = current
        assert current == reference, f"HLLD R2B changed on replay {index + 1}"

print("PASS HLLD R2B deterministic raw IR, cleaned IR and score")
