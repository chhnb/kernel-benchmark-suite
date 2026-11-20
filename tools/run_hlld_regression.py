#!/usr/bin/env python3
"""Replay the frozen Cholla HLLD GPU regression with optional candidate binaries."""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
from statistics import median
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "regression/golden/20261115-hlld-gfx906-v1/manifest.json"
GENERATOR = ROOT / "regression/generators/hlld.py"
ORDERS = (("baseline", "darm", "dp1"), ("darm", "dp1", "baseline"), ("dp1", "baseline", "darm"))


def sha(path):
    with path.open("rb") as stream:
        digest = hashlib.sha256()
        for chunk in iter(lambda: stream.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify(directory, expected):
    for name, digest in expected.items():
        if sha(directory / name) != digest:
            raise RuntimeError(f"Frozen file changed: {directory / name}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--golden", type=Path, default=ROOT / "build/hlld-golden-gfx906-v1")
    parser.add_argument("--rocm", type=Path, default=Path("/opt/rocm-6.3.3"))
    parser.add_argument("--dp1", type=Path)
    args = parser.parse_args()
    config = json.loads(MANIFEST.read_text())
    verify(args.golden, config["artifact_sha256"])
    args.out.mkdir()
    fixture = args.out / "input"
    subprocess.run([sys.executable, GENERATOR, fixture, str(config["count"])], check=True)
    verify(fixture, config["fixture_sha256"])

    env = dict(os.environ)
    env["LD_LIBRARY_PATH"] = str(args.rocm / "lib") + (
        ":" + env["LD_LIBRARY_PATH"] if env.get("LD_LIBRARY_PATH") else ""
    )
    env["ROCR_VISIBLE_DEVICES"] = str(config["device"])
    env["HIP_VISIBLE_DEVICES"] = "0"
    binaries = {role: args.golden / f"{role}.hsaco" for role in ORDERS[0]}
    for role in ("dp1",):
        candidate = getattr(args, role)
        if candidate is not None:
            binaries[role] = candidate
    samples = {role: [] for role in binaries}
    for index in range(config["rounds"]):
        for role in ORDERS[index % len(ORDERS)]:
            result = args.out / f"{role}-{index}"
            with result.with_suffix(".log").open("w") as log:
                subprocess.run([
                    args.golden / "runner", "--kernel", binaries[role],
                    "--input", fixture / "input.txt", "--mode", "benchmark",
                    "--warmup", str(config["warmup"]), "--repeat", str(config["repeat"]),
                    "--output", result,
                ], check=True, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=180)
            with (result / "samples.csv").open() as stream:
                rows = list(csv.DictReader(stream))
            times = [float(row["microseconds"]) for row in rows if row["warmup"] == "0"]
            if (len(times) != config["repeat"] or len(rows) != config["repeat"] + config["warmup"]
                    or any(row["full_output_passed"] != "1" for row in rows)):
                raise RuntimeError(f"Invalid samples or output mismatch in {result}")
            samples[role].append(times)

    round_medians = {role: [median(batch) for batch in batches] for role, batches in samples.items()}
    ratios = {
        role: median(candidate / baseline for candidate, baseline
                     in zip(round_medians[role], round_medians["baseline"]))
        for role in ("darm", "dp1")
    }
    limit = config["max_candidate_to_baseline_ratio"]
    passed = all(ratios[role] <= limit for role in ("dp1",))
    summary = {
        "schema": config["schema"],
        "binary_sha256": {role: sha(path) for role, path in binaries.items()},
        "round_medians_us": round_medians,
        "median_us": {role: median(sum(batches, [])) for role, batches in samples.items()},
        "median_paired_ratio_to_baseline": ratios,
        "max_candidate_to_baseline_ratio": limit,
        "correctness_passed": True,
        "performance_passed": passed,
    }
    report = json.dumps(summary, indent=2) + "\n"
    (args.out / "summary.json").write_text(report)
    print(report, end="")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
