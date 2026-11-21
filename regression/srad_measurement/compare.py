from collections import defaultdict
from pathlib import Path
from statistics import median
import csv
import fcntl
import json
import math
import os
import subprocess

root = Path.cwd()
scratch = Path(__file__).resolve().parent
old = root / "build/b2b-layouts"
archive = old / "anchor-default/verified"
cases = {
    "SRAD16": ("replay", root / "build/dp1-removal/srad1/16/input.txt",
               archive / "SRAD16/A.hsaco", False),
    "SRAD1024": ("replay", old / "anchor-ablation/heldout/SRAD-stage2/anchor-holdout-synthetic-v1/1024/input.txt",
                 archive / "SRAD-stage2/A.hsaco", True),
    "TIGRE": ("tigre", old / "archive-recovery.KkNzUN/verified-by-hash/20261109-gfx906-v1/tigre/inputs",
              archive / "tigre/A.hsaco", False),
}

def run(name, method, count, windows, label):
    exe, input_path, binary, mutable = cases[name]
    env = os.environ | {"HIP_VISIBLE_DEVICES": "0", "ROCR_VISIBLE_DEVICES": "0",
                        "SRAD_MEASURE": method, "SRAD_LAUNCHES": str(count)}
    if mutable:
        env["SRAD_RESTORE_BETWEEN"] = "1"
    out = scratch / "comparison" / name / label
    out.parent.mkdir(parents=True, exist_ok=True)
    cmd = [scratch / exe, "--kernel", binary, "--reference", binary, "--candidate", binary,
           "--input", input_path, "--output", out, "--mode", "benchmark",
           "--windows", str(windows), "--repeat", "15"]
    with out.with_suffix(".log").open("w") as log:
        print(json.dumps(list(map(str, cmd))), file=log, flush=True)
        subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    with (out / "windows.csv").open() as stream:
        rows = list(csv.DictReader(stream))
    expected = 6 if name == "TIGRE" else 1
    assert len(rows) == 3 * windows * expected
    grouped = defaultdict(dict)
    for row in rows:
        grouped[int(row["window"]), row["role"]][int(row["angle"])] = float(row["microseconds"])
    assert all(len(v) == expected for v in grouped.values())
    ratios = [sum(grouped[i, "N"].values()) / sum(grouped[i, "A"].values()) for i in range(windows)]
    med, span = median(ratios), max(ratios) / min(ratios) - 1
    result = dict(case=name, method=method, count=count, windows=windows,
                  median=med, spread=span, ratio=ratios,
                  min_event_ms=min(float(row["total_ms"]) for row in rows),
                  qualified=(abs(med - 1) <= .01 and span <= .03), samples=rows)
    (out / "summary.json").write_text(json.dumps(result, indent=2) + "\n")
    print(name, method, label, count, f"median {med:.6f} span {span:.4%} min {result['min_event_ms']:.4f} ms", flush=True)
    return result

def scaled(count, current, target):
    return math.ceil(count * target / current)

all_results = {}
with open("/data/home/chh/v2-runtime/gpu.lock", "a") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    for name in cases:
        all_results[name] = {}
        for method in ("M1", "M2", "M3"):
            target = {"M1": 0, "M2": 10, "M3": 50}[method]
            if method == "M1":
                count = 15
            else:
                count = 64 if method == "M2" else 500
                pilot = run(name, method, count, 1, f"{method}-pilot")
                count = scaled(count, pilot["min_event_ms"], target)
                if method == "M3":
                    count = max(count, 500)
            for attempt in range(6):
                result = run(name, method, count, 12, f"{method}-attempt{attempt}")
                if result["min_event_ms"] >= target:
                    all_results[name][method] = result
                    (scratch / "comparison/summary.json").write_text(json.dumps(all_results, indent=2) + "\n")
                    break
                count = max(count + 1, scaled(count, result["min_event_ms"], target))
            else:
                raise RuntimeError(f"unable to reach timing target for {name} {method}")
