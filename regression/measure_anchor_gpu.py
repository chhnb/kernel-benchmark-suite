#!/usr/bin/env python3
"""Replay three validated GPU binaries and decide from paired round timings."""

import argparse
import csv
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
from random import Random
from statistics import median, quantiles
import subprocess

ROLES = ("baseline", "A", "N")
ROUNDS = 12


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def read_timing(directory, style, warmup, repeat):
    csv_path = directory / ("timing.csv" if style == "tigre" else "samples.csv")
    with csv_path.open() as stream:
        rows = list(csv.DictReader(stream))
    if style == "tigre":
        if len(rows) != 6 * (warmup + repeat):
            raise ValueError(f"Incomplete TIGRE timings in {csv_path}")
        groups = [
            [float(row["ms"]) * 1000 for row in rows
             if int(row["batch"]) == batch and row["warmup"] == "0"]
            for batch in range(6)
        ]
        # The TIGRE runner verifies the full CPU recurrence and guard regions
        # before emitting the timing CSV. A successful exit is required.
    else:
        if len(rows) != warmup + repeat or any(row["full_output_passed"] != "1" for row in rows):
            raise ValueError(f"Incomplete or failed output validation in {csv_path}")
        groups = [[float(row["microseconds"]) for row in rows if row["warmup"] == "0"]]
    if any(len(group) != repeat or any(not math.isfinite(x) or x <= 0 for x in group)
           for group in groups):
        raise ValueError(f"Invalid timing samples in {csv_path}")
    return sum(median(group) for group in groups)


def paired_summary(ratios):
    rng = Random(20261119)
    estimates = [median(rng.choices(ratios, k=len(ratios))) for _ in range(10000)]
    bounds = quantiles(estimates, n=40, method="inclusive")
    minimum, maximum = min(ratios), max(ratios)
    low, high = bounds[0], bounds[-1]
    if maximum <= 1.02:
        verdict, rule = "passed", "all_rounds"
    elif minimum > 1.02:
        verdict, rule = "performance_regression", "all_rounds"
    elif high <= 1.02:
        verdict, rule = "passed", "bootstrap"
    elif low > 1.02:
        verdict, rule = "performance_regression", "bootstrap"
    else:
        verdict, rule = "uncertain", "bootstrap"
    return {
        "median": median(ratios),
        "minimum": minimum,
        "maximum": maximum,
        "confidence_interval_95": [low, high],
        "verdict": verdict,
        "rule": rule,
    }


def spread(values):
    return max(values) / min(values) - 1


def measure(args):
    out = args.output.resolve()
    out.mkdir(parents=True)
    binaries = dict(zip(ROLES, (args.baseline, args.reference, args.candidate)))
    state = {
        "status": "running",
        "format": args.format,
        "warmup": args.warmup,
        "repeat": args.repeat,
        "runner_sha256": digest(args.runner),
        "binary_sha256": {role: digest(path) for role, path in binaries.items()},
        "rounds": [],
        "ratio_to_baseline": {role: [] for role in ROLES[1:]},
    }

    def save():
        temporary = out / "results.tmp"
        temporary.write_text(json.dumps(state, indent=2) + "\n")
        temporary.replace(out / "results.json")

    save()
    env = os.environ | {"HIP_VISIBLE_DEVICES": "0", "ROCR_VISIBLE_DEVICES": "0"}
    with args.lock.open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        for index in range(ROUNDS):
            # Each role occupies every position twice per six rounds and
            # each ordered pair of adjacent roles occurs equally often.
            shift = index % len(ROLES)
            order = ROLES[shift:] + ROLES[:shift]
            if index // len(ROLES) % 2:
                order = order[::-1]
            values = {}
            state["partial_round"] = values
            for role in order:
                target = out / f"round-{index + 1:02}-{role}"
                command = [
                    args.runner, "--kernel", binaries[role], "--input", args.input,
                    "--mode", "benchmark", "--warmup", str(args.warmup),
                    "--repeat", str(args.repeat), "--output", target,
                ]
                with target.with_suffix(".log").open("w") as log:
                    print(json.dumps(list(map(str, command))), file=log, flush=True)
                    try:
                        subprocess.run(command, check=True, timeout=240, env=env,
                                       stdout=log, stderr=subprocess.STDOUT)
                        values[role] = read_timing(target, args.format, args.warmup, args.repeat)
                    except (OSError, subprocess.SubprocessError, ValueError, KeyError) as error:
                        state.update(status="runner_or_validation_failed", error=str(error),
                                     stop={"role": role, "round": index + 1})
                        save()
                        return 2
            state.pop("partial_round")
            for candidate, ratios in state["ratio_to_baseline"].items():
                ratios.append(values[candidate] / values["baseline"])
            state["rounds"].append(values)
            save()
            print(f"Round {index + 1}: {values}", flush=True)
    verdict_ratios = [row["N"] / row["A"] for row in state["rounds"]]
    summary = paired_summary(verdict_ratios)
    all_spreads = {role: spread(ratios) for role, ratios in state["ratio_to_baseline"].items()}
    all_spreads["N/A"] = spread(verdict_ratios)
    state.update(
        status=summary["verdict"],
        candidate_over_reference=summary,
        paired_spread=all_spreads,
        uncertain_and_unstable=summary["verdict"] == "uncertain" and max(all_spreads.values()) > 0.05,
    )
    save()
    return 3 if state["status"] == "uncertain" else 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for option in ("runner", "input", "output", "baseline", "reference", "candidate", "lock"):
        parser.add_argument(f"--{option}", type=Path, required=True)
    parser.add_argument("--format", choices=("event", "tigre"), default="event")
    parser.add_argument("--warmup", type=int, default=3)
    parser.add_argument("--repeat", type=int, default=15)
    arguments = parser.parse_args()
    if arguments.repeat <= 0 or arguments.warmup < 0:
        parser.error("repeat must be positive and warmup must be nonnegative")
    raise SystemExit(measure(arguments))
