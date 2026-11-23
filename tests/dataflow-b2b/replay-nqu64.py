#!/usr/bin/env python3
"""Expose the release NQU64 replay through the paired event-timing interface."""

import argparse
import csv
import os
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("kernel", "input", "output"):
        parser.add_argument(f"--{name}", required=True, type=Path)
    parser.add_argument("--mode", choices=("benchmark",), required=True)
    parser.add_argument("--warmup", required=True, type=int)
    parser.add_argument("--repeat", required=True, type=int)
    args = parser.parse_args()
    args.output.mkdir()
    command = [os.environ["NQU64_REPLAY"], args.input / "baseline.input",
               args.input / "baseline.output", str(args.warmup + args.repeat), "timed", args.kernel]
    with (args.output / "release.csv").open("w") as stream:
        subprocess.run(command, stdout=stream, check=True)
    with (args.output / "release.csv").open() as stream:
        records = list(csv.DictReader(stream))
    fields = ("warmup", "microseconds", "full_output_passed")
    with (args.output / "samples.csv").open("w") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for expected_round, row in enumerate(records):
            if (int(row["round"]) != expected_round or row["role"] != "0" or
                    row["solutions"] != "2279184" or row["output_fingerprint"] != "3fa1162a3cadaeea"):
                raise ValueError(f"unexpected validation record {row}")
            writer.writerow({"warmup": int(expected_round < args.warmup),
                             "microseconds": float(row["milliseconds"]) * 1000,
                             "full_output_passed": 1})


if __name__ == "__main__":
    main()
