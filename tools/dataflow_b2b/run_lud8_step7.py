#!/usr/bin/env python3
"""Measure and solve LUD8 winners using DARM's actual mapped alignments."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

from measure_step7 import invoke, read, write
from check_step5_small import COSTS, read_solution


def entry_window(path, symbol):
    value = json.loads(subprocess.check_output(["tools/run-llvm24-tti", path, symbol], text=True))
    entry = [k for k in value["instruction_costs"] if k["block_index"] == 0]
    assert [e["key"].split(":")[0] for e in entry[:2]] == [
        "call", "icmp"], entry[:2]
    assert "workitem.id.x" in entry[0]["key"] and ", 8" in entry[1]["ir"]
    end = next(i for i, x in enumerate(entry) if x["key"].startswith("fence:"))
    assert entry[end - 1]["key"].startswith("store:") and "barrier" in entry[end + 1]["key"]
    assert all(not x["key"].startswith("br.") for x in entry[2:end])
    components, counts = Counter(), Counter()
    for item in entry[2:end]:
        op = item["key"].split(":")[0]
        key = "select" if op == "select" else "escape" if op == "phi" else "instruction"
        components[key] += item["accepted_cost"]
        counts[op] += 1
    return {"T": [sum(components.values())] * 3, "D_components": components, "count": counts,
            "entry_start": 2, "entry_end_exclusive": end}


def measure(row, work, seconds):
    key = hashlib.sha256((row["parent_sha256"] + row["candidate"]).encode()).hexdigest()[:12]
    stage = work / "lud8-ilp" / key
    stage.mkdir(parents=True, exist_ok=True)
    block = row["candidate"].rsplit(":", 3)[1:]
    flags = [arg for key, value in zip(("--split", "--left", "--right"), block)
             for arg in (key, value)]
    output = stage / "darm.ll"
    alignment = stage / "alignment.json"
    baseline = row["replays"]["darm"]["kernel"]["work_after"]
    if not alignment.exists():
        process = subprocess.run([str(work / "darm-probe"), "--ir", row["parent"], "--function",
                                  row["symbol"], *flags, "--out", str(output), "--b2b-strategy", "darm",
                                  "--tti-worker", "tools/run-llvm24-tti", "--debug-dir", str(stage / "trial"),
                                  "--ir-snapshots", "compact"], env=os.environ | {"STEP7_DARM_PAIRS": "1"},
                                 capture_output=True, text=True, check=True, timeout=120)
        (stage / "probe.log").write_text(process.stderr + process.stdout)
        report = read(stage / "trial/trial-0/trial.json")
        assert report["score_result"]["metrics"]["work_after"] == baseline
        marker = "STEP7_DARM_ALIGNMENT "
        mapped = [json.loads(line.removeprefix(marker)) for line in process.stderr.splitlines()
                  if line.startswith(marker)]
        assert len(mapped) == 1 and mapped[0]["pairs"], process.stderr
        write(alignment, mapped[0])
    mapped = read(alignment)
    hint = stage / "hint.json"
    write(hint, {"pairs": mapped["pairs"],
                 "protected": [position[:2] for position in mapped["protected"]]})
    chosen = row["region"]["occurrence"]
    source = work / "regions" / row["region"]["ir"]
    polished = {}
    for role in ("anchor", "darm"):
        polished[role] = entry_window(row["replays"][role]["context"]["ir"], row["symbol"])
    assert polished["anchor"]["T"][0] > polished["darm"]["T"][0]
    anchor = row["replays"]["anchor"]["context"]["record"]["anchor"]
    result = {"case": row["case"], "id": row["region"]["id"], "stage": str(stage),
              "cleaned_region": polished, "anchor_hint": anchor["dataflow_hint"],
              "darm_alignment": mapped, "parent": row["parent"], "candidate": row["candidate"]}
    write(stage / "measurement.json", result)

    # Same solver with an experiment-only 1800-second CLI ceiling.
    actual = Path("tools/dataflow_b2b/ilp_solver").read_text()
    script = stage / "ilp_solver_30min.py"
    before = "if not 0 < args.seconds <= 600:"
    assert actual.count(before) == 1
    script.write_text(actual.replace(before, "if not 0 < args.seconds <= 1800:").replace(
        "--seconds must be in (0,600]", "--seconds must be in (0,1800]"))
    solved = read_solution([sys.executable, script, source, COSTS, stage / "ilp",
                            "--cost=real", "--seconds", str(seconds), "--condition-source",
                            chosen["condition_source"], "--anchor-hint", hint], seconds + 20)
    result["ilp"] = solved
    write(stage / "result.json", result)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("work", type=Path)
    p.add_argument("--seconds", type=int, default=120)
    args = p.parse_args()
    if not 0 < args.seconds <= 1800:
        p.error("--seconds must be in (0, 1800]")
    root = args.work.resolve()
    rows = read(root / "context.json")
    winners = {}
    for row in rows:
        if not row["case"].startswith("LUD8") or row["round"] != 0:
            continue
        winners.setdefault((row["parent_sha256"], row["candidate"]), row)
    with ThreadPoolExecutor(2) as pool:
        values = list(pool.map(lambda row: measure(row, root, args.seconds), winners.values()))
    write(root / "lud8-solutions.json", values)


if __name__ == "__main__":
    main()
