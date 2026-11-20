#!/usr/bin/env python3
"""Check metadata on the instruction emitted by the Anchor B2B planner."""
from pathlib import Path
import json
import re
import subprocess
import sys
import tempfile

search, worker, opt = map(Path, sys.argv[1:])
fixture = Path(__file__).with_name("memory-metadata.ll")
with tempfile.TemporaryDirectory() as path:
    for name, opcode in [("store_mismatch", "store"), ("load_range", "load"),
                         ("tbaa_same", "store"), ("tbaa_generic", "store")]:
        debug = Path(path) / name
        result = debug.with_suffix(".ll")
        subprocess.run([search, "--ir", fixture, "--function", name, "--out", result,
                        "--debug-dir", debug, "--merge-metadata", "intersect",
                        "--tti-worker", worker, "--split", "B0", "--left", "B1", "--right", "B2"],
                       capture_output=True, check=True)
        subprocess.run([opt, "-verify", "-disable-output", result], check=True)
        raw = (debug / "trial-0/after-raw.ll").read_text()
        function = re.search(rf"(?ms)^define [^\n]*@{name}\([^\n]+\n(.*?)^}}", raw)[1]
        # Match opcodes rather than names or temporary value numbers.
        instructions = re.findall(rf"(?m)^  (?:%[\w.]+ = )?{opcode} .*$", function)
        assert len(instructions) == 1, (name, instructions)
        line = instructions[0]
        if name in ("store_mismatch", "load_range"):
            assert "!tbaa" not in line and "!range" not in line, (name, line)
            continue
        tag_id = re.search(r"!tbaa !(\d+)", line)[1]
        node_id = re.search(rf"(?m)^!{tag_id} = !{{!(\d+),", raw)[1]
        node = re.search(rf"(?m)^!{node_id} = !{{!(?:\"([^\"]+)\")", raw)[1]
        assert node == ("int" if name == "tbaa_same" else "common"), (name, node)
    out = Path(path)
    command = [search, "--ir", fixture, "--function", "region_load_range", "--tti-worker", worker,
               "--merge-metadata", "intersect", "--region-align", "anchor"]
    subprocess.run([*command, "--catalog-only", "1", "--debug-dir", out / "catalog",
                    "--out", out / "catalog.ll"], capture_output=True, check=True)
    catalog = json.loads((out / "catalog/catalog.json").read_text())
    pair, = (p for p in catalog["candidates"]
             if p["left"].startswith("R") and p["right"].startswith("R"))
    debug = out / "region"
    result = out / "region.ll"
    subprocess.run([*command, "--split", pair["split"], "--left", pair["left"], "--right", pair["right"],
                    "--debug-dir", debug, "--out", result], capture_output=True, check=True)
    subprocess.run([opt, "-verify", "-disable-output", result], check=True)
    trial = json.loads((debug / "trial-0/trial.json").read_text())
    assert trial["fusion_plan"]["kind"] == "R2R" and trial["region_alignment"]["blocks"]
    raw = (debug / "trial-0/after-raw.ll").read_text()
    function = re.search(r"(?ms)^define [^\n]*@region_load_range\([^\n]+\n(.*?)^}", raw)[1]
    loads = re.findall(r"(?m)^  %[^ ]+ = load .*$", function)
    assert len(loads) == 1 and "!range" not in loads[0], loads
print("PASS Anchor B2B and R2R memory metadata intersection and LLVM verifier")
