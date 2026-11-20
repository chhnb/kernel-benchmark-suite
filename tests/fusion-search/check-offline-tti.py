#!/usr/bin/env python3
"""Check recorded scores, strict replay, and the configurable offline fallback."""
import csv
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
fixture = Path(__file__).with_name("domain-vllm-quant8.ll").resolve()
driver = Path("build/decision-fuse/decision-greedy")
engine = Path("build/llvm24-tti/fusion-search-llvm24")
layout = Path("build/llvm24-tti/offline-tti-layout")
launcher = Path("tools/run-llvm24-tti")


def run(command, env, *, check=True):
    return subprocess.run(command, env=env, check=check, text=True, capture_output=True)


def search_state(path):
    summary = json.loads((path / "summary.json").read_text())
    trial_fields = ("candidate", "stage", "eligible", "cost", "gain", "reason")
    rounds = [
        (r["decision"], Path(r["selected"]).name if r["selected"] else "",
         [tuple(t.get(k) for k in trial_fields) for t in r["attempts"]])
        for r in summary["rounds"]
    ]
    final = (path / "final.ll").read_bytes().split(b"\n", 1)[1]
    return summary["tti_cost_kind"], summary["initial_cost"], summary["final_cost"], rounds, final


with tempfile.TemporaryDirectory() as tmp:
    temp = Path(tmp)
    environment = os.environ | {"FUSION_TTI_DB": str(temp / "quotes.sqlite"),
                                "FUSION_TTI_WARNINGS": str(temp / "warnings.log")}
    environment.pop("FUSION_TTI_OVERRIDES", None)
    environment["FUSION_TTI_COST_KIND"] = "throughput"

    # Exercise the normal driver root discovery with no LLVM24 executable.
    isolated = temp / "offline"
    for relative in (driver, engine, layout, launcher, Path("tools/offline_tti.py")):
        target = isolated / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / relative, target)
    offline_env = environment | {"FUSION_TTI_MODE": "strict"}
    offline_env.pop("LLVM24_LIBDIR", None)
    cost_rows = []
    probe = root / "regression/tti-gfx906/memory-probe.ll"
    for kind, label in (("throughput", "TCK_RecipThroughput"), ("latency", "TCK_Latency")):
        live = environment | {"FUSION_TTI_COST_KIND": kind}
        offline = offline_env | {"FUSION_TTI_COST_KIND": kind}
        if kind == "latency":
            missing = run([isolated / launcher, fixture, "quant8"], offline, check=False)
            assert missing.returncode != 0 and "missing recorded request" in missing.stderr
            (temp / "warnings.log").unlink()
        recorded, replayed = (temp / f"{kind}-{mode}" for mode in ("recorded", "replayed"))
        run([root / driver, fixture, "quant8", recorded], live | {"FUSION_TTI_MODE": "record"})
        run([isolated / driver, fixture, "quant8", replayed], offline)
        assert search_state(recorded) == search_state(replayed)
        assert search_state(replayed)[0] == label
        assert not (temp / "warnings.log").exists()
        report = json.loads(run([root / launcher, probe, "probe"],
                                live | {"FUSION_TTI_MODE": "llvm24"}).stdout)
        assert report["cost_kind"] == label
        cost_rows.append([(row["ir"].strip(), str(row["tti_cost"])) for row in report["instruction_costs"]])

    reference = root / "regression/tti-gfx906/memory-costs.csv"
    with reference.open() as f:
        expected = list(csv.reader(f))[1:]
    assert len(cost_rows[0]) == len(cost_rows[1])
    assert [ir for ir, cost in cost_rows[0]] == [ir for ir, cost in cost_rows[1]]
    assert [[a[0], a[1], b[1]] for a, b in zip(*cost_rows)] == expected

    unseen = temp / "unseen.ll"
    unseen.write_text('''target triple = "amdgcn-amd-amdhsa"
define double @quant8(double %x, double %y) #0 {
entry:
  %v = fdiv double %x, %y
  ret double %v
}
attributes #0 = { "target-cpu"="gfx906" }
''')
    miss = temp / "missing"
    failed = run([isolated / driver, unseen, "quant8", miss], offline_env, check=False)
    assert failed.returncode != 0 and (miss / "offline-tti-errors.log").is_file()
    assert not (miss / "final.ll").exists()
    offline_env["FUSION_TTI_MODE"] = "offline"

    def division_cost(result):
        rows = json.loads(result.stdout)["instruction_costs"]
        return next(row["accepted_cost"] for row in rows if row["key"] == "fdiv:double")

    assert division_cost(run([isolated / launcher, unseen, "quant8"], offline_env)) == 1
    assert "fdiv:double" in (temp / "warnings.log").read_text()
    overrides = temp / "overrides.json"
    overrides.write_text(json.dumps([{"key": "fdiv:double", "cost": 24}]))
    adjusted = run([isolated / launcher, unseen, "quant8"],
                   offline_env | {"FUSION_TTI_OVERRIDES": str(overrides)})
    assert division_cost(adjusted) == 24

print("offline TTI recording, strict replay, and fallback passed")
