#!/usr/bin/env python3
"""Build and run a generated-input benchmark on an allocated gfx906 GPU."""
import argparse
import csv
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CASES = {"vllm": "vllm-quant", "mapairy": "boost-mapairy"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case", choices=CASES)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--ir", type=Path, help="LLVM 12 IR with the original kernel ABI")
    parser.add_argument("--llvm12-bin", type=Path, required=True)
    parser.add_argument("--rocm", type=Path, default=Path("/opt/rocm"))
    parser.add_argument("--boost-math-include", type=Path)
    parser.add_argument("--prepare-only", action="store_true", help="Build and generate inputs without launching a GPU job")
    args = parser.parse_args()
    out = args.out.resolve()
    llvm = args.llvm12_bin.resolve()
    rocm = args.rocm.resolve()
    source = (args.ir or ROOT / "cases" / CASES[args.case] / "start.ll").resolve()
    if not source.is_file():
        parser.error(f"missing IR: {source}")
    env = os.environ.copy()
    if args.boost_math_include:
        env["BOOST_MATH_INCLUDE"] = str(args.boost_math_include.resolve())
    if args.case == "mapairy":
        headers = Path(env.get("BOOST_MATH_INCLUDE", ROOT / "cases/boost-mapairy/source/boost-math/include"))
        if not (headers / "boost/math/distributions/mapairy.hpp").is_file():
            parser.error("provide Boost.Math headers with --boost-math-include")
    if "LLVM version 12." not in subprocess.check_output([llvm / "opt", "--version"], text=True):
        parser.error("--llvm12-bin must contain LLVM 12")
    out.mkdir(parents=True, exist_ok=False)

    def run(*command):
        subprocess.run(command, check=True, env=env)

    optimized = out / "kernel-final.ll"
    obj = out / "kernel.o"
    binary = out / "kernel.hsaco"
    runner = out / "bench_hip"
    run(llvm / "opt", source, "-O3", "-verify-each", "-S", "-o", optimized)
    run(llvm / "llc", optimized, "-O3", "-mtriple=amdgcn-amd-amdhsa", "-mcpu=gfx906",
        "-mattr=+sram-ecc,-xnack", "-filetype=obj", "-o", obj)
    run(rocm / "llvm/bin/ld.lld", "-shared", obj, "-o", binary)
    run(env.get("CXX", "g++"), "-std=c++17", "-O2", "-DBENCH_HIP", "-D__HIP_PLATFORM_AMD__",
        "-I" + str(rocm / "include"), ROOT / "runner/replay.cpp",
        "-L" + str(rocm / "lib"), "-Wl,-rpath," + str(rocm / "lib"),
        "-lamdhip64", "-o", runner)
    generated = out / "generated"
    run(sys.executable, ROOT / "regression/generators/prepare.py", args.case, generated)
    if args.prepare_only:
        print(f"Prepared kernel, runner and input specs in {out}")
        return

    generation = json.loads((generated / "generation.json").read_text())
    results = []
    for row in generation["rows"]:
        count = row["count"]
        command = [runner, "--kernel", binary, "--input", row["spec"]]
        run(*command, "--mode", "validate", "--output", out / f"validate-{count}")
        timing = out / f"benchmark-{count}"
        run(*command, "--mode", "benchmark", "--warmup", "3", "--repeat", "15", "--output", timing)
        with (timing / "samples.csv").open() as samples:
            rows = list(csv.DictReader(samples))
        measured = [float(sample["microseconds"]) for sample in rows if sample["warmup"] == "0"]
        if (len(measured) != 15 or any(not math.isfinite(t) or t <= 0 for t in measured)
                or any(sample["full_output_passed"] != "1" for sample in rows)):
            raise RuntimeError(f"Invalid benchmark samples at {count} inputs")
        results.append({"count": count, "correctness_passed": True,
                        "median_us": statistics.median(measured)})
    summary = {"case": args.case, "target": "gfx906", "results": results}
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
