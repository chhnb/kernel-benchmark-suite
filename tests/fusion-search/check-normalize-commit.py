#!/usr/bin/env python3
"""Verify NQU64 can commit the profitable no-meld control when enabled."""
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile

root = Path(__file__).resolve().parents[2]
driver, opt = map(Path, sys.argv[1:])
release = root / "regression/golden/20261120-anchor-release"
manifest = json.loads((release / "manifest.json").read_text())
case = next(row for row in manifest["cases"] if row["case"] == "NQU64")

with tempfile.TemporaryDirectory(prefix="normalize-commit-") as temporary:
    work = Path(temporary)
    source = work / "input.ll"
    with tarfile.open(release / manifest["archive"]["file"]) as archive:
        source.write_bytes(archive.extractfile(case["input"]["archive_entry"]).read())

    def run(name, *options):
        out = work / name
        subprocess.run([driver, source, case["function"], root, out, *options], check=True)
        subprocess.run([opt, "-verify", "-disable-output", out / "final.ll"], check=True)
        return json.loads((out / "summary.json").read_text())

    default = run("default")
    assert default["commits"] == 1
    assert not any(r.get("selected_kind") == "normalize-only" for r in default["rounds"])

    enabled = run("enabled", "--commit-normalize-only")
    selections = [r for r in enabled["rounds"] if r.get("selected_kind") == "normalize-only"]
    assert len(selections) == 1, selections
    selected, = selections
    assert selected["parent_cost"] == 282 and selected["selected_cost"] == 274
    assert enabled["commits"] == 2 and enabled["final_cost"] == 274
    winner = next(a for a in selected["attempts"] if a["directory"] == selected["selected"])
    assert winner["kind"] == "normalize-only" and winner["gain"] == 8
    assert any(a.get("control_cost") == a.get("cost") == 274
               and a.get("reason") == "nonpositive_gain"
               for a in selected["attempts"])
    assert b"!decision.ordered_trial_boundary" not in (work / "enabled/final.ll").read_bytes()

print("PASS NQU64 accepts only the opt-in normalize-only winner")
