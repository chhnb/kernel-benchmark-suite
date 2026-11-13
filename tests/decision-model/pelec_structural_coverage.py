"""Replay PeleC coverage and a volatile-write negative case with decision-greedy."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("tool_root", type=Path)
parser.add_argument("fixture", type=Path, help="Directory containing common.ll, darm-once.ll, darm-step2.ll and kernel.txt")
parser.add_argument("output", type=Path)
args = parser.parse_args()
root, fixture, out = (p.resolve() for p in (args.tool_root, args.fixture, args.output))
out.mkdir()
kernel = (fixture / "kernel.txt").read_text().strip()

def replay(source, label, pressure_growth=0):
    directory = out / label
    env = dict(os.environ, DECISION_MAX_PRESSURE_GROWTH=str(pressure_growth),
               DECISION_MAX_UNIFORM_LOSS="1000000")
    subprocess.run([root / "build/decision-fuse/decision-greedy", source, kernel, root, directory], check=True, env=env)
    report = json.loads((directory / "summary.json").read_text())
    assert report["status"] == "completed" and report["structural_candidates_enabled"]
    return report, {":".join(a["candidate"].rsplit(":", 3)[-3:]): a
            for row in report["rounds"] for a in row["attempts"] if a.get("kind") == "structural"}

def scored(trial, boundaries):
    assert trial["stage"] == "scored"
    details = json.loads((Path(trial["directory"]) / "structural/trial-0/trial.json").read_text())
    assert details["valid"] and not details["replication_required"]
    actual = tuple(details[side][key] for side in ("left", "right") for key in ("entry", "exit"))
    assert actual == boundaries, actual

_, common = replay(fixture / "common.ll", "common")
scored(common["B5:B6:B20"], ("%106", "%1005", "%996", "%1005"))
scored(common["B8:R11:R13"], ("%335", "%337", "%753", "%755"))
_, once = replay(fixture / "darm-once.ll", "darm-once")
scored(once["B7:R11:R13"], ("%329", "%331", "%747", "%749"))
# DARM selects both region pairs before rewriting the first. The second
# pair's labels in the melding log refer to the intermediate CFG.
scored(once["B7:R12:R14"], ("%331", "%551", "%749", "%848"))
_, twice = replay(fixture / "darm-step2.ll", "darm-step2")
scored(twice["B42:B43:B44"], ("%merged.branch.split157", "%merged.bb",
                            "%merged.branch.split158", "%merged.bb"))


source = (fixture / "common.ll").read_text()
head, target = source.split("@" + kernel + "(", 1)
target, tail = target.split("\n}", 1)
target, count = re.subn(r"(  store )(double [^\n]*addrspace\(5\)\*)", r"\1volatile \2", target, count=1)
assert count == 1
negative = out / "volatile.ll"
negative.write_text(head + "@" + kernel + "(" + target + "\n}" + tail)
_, volatile = replay(negative, "volatile")
trial = volatile["B5:B6:B20"]
assert trial["stage"] == "legality_rejected", trial
assert trial["reason"] == "side_effect_in_trial_scope_not_supported", trial
print("PeleC anchored and independent-exit candidates scored, volatile-write candidate rejected")

for input_name, selected_pair in (("common", "B8:R11:R13"), ("darm-once", "B7:R11:R13")):
    label = input_name + "-relaxed"
    report, _ = replay(fixture / (input_name + ".ll"), label, pressure_growth=20)
    first, following = report["rounds"][:2]
    selected = next(a for a in first["attempts"] if a["directory"] == first["selected"])
    assert selected["candidate"].endswith(":" + selected_pair)
    assert following["parent"] == str(Path(first["selected"]) / "fused.ll")
    assert following["parent_cost"] == selected["cost"]
    catalog = json.loads((out / label / "structural-1/catalog.json").read_text())
    assert catalog["source_ir"] == following["parent"]
    assert following["attempts"], following
    assert {a["candidate"] for a in following["attempts"]} == {
        a["candidate"] for a in catalog["candidates"]
    }
print("Both structural commits triggered a fresh catalog and trials on the committed IR")
