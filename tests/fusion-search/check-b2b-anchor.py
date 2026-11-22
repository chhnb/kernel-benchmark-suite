#!/usr/bin/env python3
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


search, worker, opt = map(Path, sys.argv[1:])
fixtures = Path(__file__).parent / "b2b-anchor"
cases = (
    ("vllm-7", "quant", "B2", "B1", 25),
    ("HLLD", "HLLD", "B1", "B2", 146),
    ("MapAiry", "MapAiry", "B1", "B2", 347),
    ("Tigre4", "Tigre4", "B1", "B2", 91),
    ("no-phi", "diamond", "B1", "B2", 10),
)

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    for name, fn, left, right, historical_tti in cases:
        debug = root / name
        result = debug.with_suffix(".ll")
        subprocess.run(
            [search, "--ir", fixtures / f"{name}.ll", "--function", fn,
             "--split", "B0", "--left", left, "--right", right,
             "--b2b-strategy", "anchor", "--tti-worker", worker,
             "--out", result, "--debug-dir", debug],
            env=os.environ | {"FUSION_OBSERVE_B2B_DP": str(root / f"{name}-planner.jsonl")},
            check=True,
        )
        subprocess.run([opt, "-verify", "-disable-output", result], check=True)
        trial = debug / "trial-0"
        report = json.loads((trial / "trial.json").read_text())
        assert report["valid"] and report["score_result"]["status"] == "scored"
        score = report["score_result"]["metrics"]["work_after"]
        stats = report["anchor"]
        assert 1 <= stats["unique_normalized"] <= stats["generated"]
        assert len(report["layout_profitability"]) == stats["generated"]
        fork_layouts = [row for row in report["layout_profitability"]
                        if row["anchor"]["emission"] not in ("linear", "guarded-linear")]
        assert 1 <= len(fork_layouts) <= 9
        assert stats["conflicts"] == 0
        if name == "no-phi":
            assert stats["anchors"] == 0 and stats["segments"] == 1
        if name == "HLLD":
            emissions = [row["anchor"]["emission"] for row in report["layout_profitability"]]
            assert stats["emission"] == "before-split"
            assert emissions.index("before-split") < emissions.index("merged-exit")
        if name == "vllm-7":
            assert stats["mode"] == "relaxed"
            assert any(
                {cutoff["left"], cutoff["right"]} == {"%s108", "%s112"}
                for row in report["layout_profitability"]
                if row["anchor"]["mode"] == "strict"
                for cutoff in row["anchor"]["cutoffs"]
            )
        if name == "Tigre4":
            assert any(
                {cutoff["left"], cutoff["right"]} == {"%add494", "%add508"}
                for row in report["layout_profitability"]
                if row["anchor"]["mode"] == "strict"
                for cutoff in row["anchor"]["forward_cutoffs"]
            )
        assert score <= historical_tti, (name, score)
        if name == "vllm-7":
            assert score == historical_tti
            text = result.read_text()
            local = text.split("%upper = fcmp", 1)[1]
            assert len(re.findall(r" = select ", local)) == 9
            assert len(re.findall(r" = fcmp ", local)) == 4
            assert len(re.findall(r"call float @llvm\.copysign", local)) == 1
            assert not re.search(r"select i1 [^\n,]+, i1 ", local)
            assert "float 3.500000e+00, float 1.750000e+00" in local
            assert "float 5.000000e+00, float 1.250000e+00" in local
        print(name, historical_tti, "->", score)


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    fixture = (fixtures / "MapAiry.ll").read_text()
    split = "br i1 %cond, label %left, label %right"
    thread_fixture = fixture.replace(
        split,
        "%tid = call i32 @llvm.amdgcn.workitem.id.x()\n"
        "  %lane.test = icmp ult i32 %tid, 8\n"
        "  br i1 %lane.test, label %left, label %right",
        1,
    ) + "\ndeclare i32 @llvm.amdgcn.workitem.id.x()\n"

    def gate_trial(label, ir):
        parent, output, debug = root / f"{label}.ll", root / f"{label}.out.ll", root / label
        parent.write_text(ir)
        subprocess.run(
            [search, "--ir", parent, "--function", "MapAiry", "--split", "B0",
             "--left", "B1", "--right", "B2",
             "--tti-worker", worker, "--out", output, "--debug-dir", debug],
            check=True,
        )
        subprocess.run([opt, "-verify", "-disable-output", output], check=True)
        return json.loads((debug / "trial-0/trial.json").read_text())

    def linear_layouts(report):
        rows = [row for row in report["layout_profitability"]
                if row["anchor"]["emission"] in ("linear", "guarded-linear")]
        assert rows
        return rows

    optimistic = gate_trial("thread-pattern", thread_fixture)
    assert optimistic["anchor"]["condition_source"] == "thread-pattern"
    assert optimistic["anchor"]["emission"] == "linear" and optimistic["eligible"]
    assert optimistic["score_result"]["metrics"]["work_after"] == 303
    for row in linear_layouts(optimistic):
        assert row["eligible"] and row["score_result"]["metrics"]["uniform_gain_false"] < 0

    constant_fixture = fixture.replace(split, "br i1 true, label %left, label %right", 1)
    rejected = gate_trial("constant-condition", constant_fixture)
    for row in linear_layouts(rejected):
        assert "uniform_gain_false" not in row["score_result"]["metrics"]
        assert row["uniform_gate_rejection"] == "workgroup_uniform"

    uniform_fixture = thread_fixture.replace("workitem.id.x", "workgroup.id.x")
    uniform = gate_trial("workgroup-uniform", uniform_fixture)
    assert uniform["anchor"]["condition_source"] == "workgroup-uniform"
    assert uniform["anchor"]["emission"] == "segmented" and uniform["eligible"]
    for row in linear_layouts(uniform):
        assert row["tti_eligible"] and row["uniform_gate_rejection"] == "workgroup_uniform"

    debug = root / "nqu64"
    subprocess.run([
        search, "--ir", fixtures / "nqu64-guard-parent.ll",
        "--function", "_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i",
        "--split", "B2", "--left", "B19", "--right", "B21",
        "--tti-worker", worker, "--debug-dir", debug,
        "--out", debug.with_suffix(".ll"),
    ], check=True)
    trial = json.loads((debug / "trial-0/trial.json").read_text())
    assert trial["anchor"]["condition_source"] == "data"
    guarded = [row for row in linear_layouts(trial)
               if row["anchor"]["emission"] == "guarded-linear"]
    assert guarded and all(row["tti_eligible"] and
                           row["uniform_gate_rejection"] == "negative_uniform_gain"
                           for row in guarded)
