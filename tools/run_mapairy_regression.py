#!/usr/bin/env python3
"""Build and compare three Map-Airy variants from the same frozen LLVM IR."""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "regression/mapairy-v2.json"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("out", "darm-opt", "greedy", "llvm-bin", "rocm", "runner"):
        parser.add_argument("--" + name, type=lambda p: Path(p).resolve(), required=True)
    args = parser.parse_args()
    config = json.loads(CONFIG.read_text())
    source = ROOT / config["parent"]
    if sha(source) != config["parent_sha256"] or sha(args.darm_opt) != config["darm_opt_sha256"]:
        raise RuntimeError("Frozen parent IR or original DARM executable hash changed")
    args.out.mkdir()
    parent = args.out / "parent.ll"
    parent.write_bytes(source.read_bytes())
    env = dict(os.environ)
    env["LD_LIBRARY_PATH"] = f"{args.rocm}/lib:" + env.get("LD_LIBRARY_PATH", "")
    commands = []

    def run(argv, log):
        cmd = list(map(str, argv))
        commands.append(cmd)
        (args.out / "commands.json").write_text(json.dumps(commands, indent=2))
        with (args.out / log).open("w") as stream:
            subprocess.run(cmd, check=True, cwd=ROOT, env=env, timeout=600,
                           stdout=stream, stderr=subprocess.STDOUT)

    generated = args.out / "input"
    run([sys.executable, ROOT / "regression/generators/prepare.py",
         "mapairy", generated], "input.log")
    row, = json.loads((generated / "generation.json").read_text())["rows"]
    if any(row[key] != config[key] for key in ("count", "seed", "files")):
        raise RuntimeError("Generated fixture differs from frozen input or reference")
    spec = generated / str(row["count"]) / "input.txt"
    darm = args.out / "darm.ll"
    greedy = args.out / "greedy"
    run([args.darm_opt, "-S", "-cfmelder", "-cf-merging-similarity-threshold=0.2",
         parent, "-o", darm], "darm.log")
    run([args.greedy, parent, "evaluate", greedy], "greedy.log")
    variants = {"baseline": parent, "auto-darm": darm, "auto-greedy": greedy / "final.ll"}
    binaries = {}
    for role, ir in variants.items():
        post = args.out / f"{role}.post.ll"
        obj = args.out / f"{role}.o"
        binary = args.out / f"{role}.hsaco"
        run([args.llvm_bin / "opt", "-O3", "-verify-each", "-S", ir, "-o", post],
            f"{role}.opt.log")
        run([args.llvm_bin / "llc", "-O3", "-mtriple=amdgcn-amd-amdhsa",
             "-mcpu=gfx906", "-mattr=+sramecc", "-amdhsa-code-object-version=4",
             "-filetype=obj", post, "-o", obj], f"{role}.llc.log")
        run([args.rocm / "llvm/bin/ld.lld", "-shared", obj, "-o", binary], f"{role}.link.log")
        binaries[role] = binary
    batches = {role: [] for role in variants}
    for index, order in enumerate(config["orders"]):
        for role in order:
            result = args.out / f"{index}-{role}"
            run([args.runner, "--kernel", binaries[role], "--input", spec,
                 "--mode", "benchmark", "--warmup", "3", "--repeat", "15",
                 "--output", result], f"{index}-{role}.log")
            with (result / "samples.csv").open() as stream:
                rows = list(csv.DictReader(stream))
            samples = [float(row["microseconds"]) for row in rows if row["warmup"] == "0"]
            if len(samples) != 15 or any(row["full_output_passed"] != "1" for row in rows):
                raise RuntimeError(f"Invalid samples or output mismatch in {result}")
            batches[role].append(statistics.median(samples))
    medians = {role: statistics.median(times) for role, times in batches.items()}
    ratio = medians["auto-greedy"] / medians["auto-darm"]
    limit = config["reference_greedy_to_darm_ratio"] * (
        1 + config["relative_slowdown_limit_pct"] / 100
    )
    summary = {
        "protocol": config["schema"],
        "input_sha256": row["files"]["input.bin"],
        "parent_sha256": sha(parent),
        "tool_sha256": {role: sha(path) for role, path in {
            "darm-opt": args.darm_opt, "decision-greedy": args.greedy,
            "llc": args.llvm_bin / "llc", "opt": args.llvm_bin / "opt",
            "ld.lld": args.rocm / "llvm/bin/ld.lld", "runner": args.runner,
        }.items()},
        "binary_sha256": {role: sha(path) for role, path in binaries.items()},
        "darm_commits": (args.out / "darm.log").read_text().count("Melding entry blocks"),
        "greedy_commits": json.loads((greedy / "summary.json").read_text())["commits"],
        "batch_medians_us": batches,
        "median_us": medians,
        "greedy_to_darm_ratio": ratio,
        "greedy_to_darm_ratio_limit": limit,
        "performance_passed": ratio <= limit,
        "correctness_passed": True,
    }
    (args.out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))
    return 0 if summary["performance_passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
