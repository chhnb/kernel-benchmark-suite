#!/usr/bin/env python3
"""Compile the upstream DARM inputs absent from the ordered manifest."""


from pathlib import Path
import argparse
import json
import os
import shlex
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--work", type=Path, required=True)
work = parser.parse_args().work.resolve()
upstream = work / "upstream"
rev = subprocess.check_output(["git", "-C", upstream, "rev-parse", "HEAD"], text=True).strip()
hist = Path.home() / "simplify-v2/build/darm-paper-repro.AtXc3N"
rocm = hist / "rocm-root/opt/rocm-4.2.0"
llvm = Path.home() / "v2-runtime/toolchains/llvm12-jammy/usr"
env = os.environ.copy()
env["LD_LIBRARY_PATH"] = ":".join(map(str, [
    hist / "rocm-root/lib/x86_64-linux-gnu", hist / "rocm-root/usr/lib/x86_64-linux-gnu",
    llvm / "lib/x86_64-linux-gnu", Path("/opt/rocm-6.3.3/lib")]))
env["LC_ALL"] = "C"
old = shlex.split((hist / "build/LUD64/baseline/build.log").read_text().splitlines()[0])
jobs = [
    ("LUD", 128, upstream / "benchmarks/LUD/lud_kernel.hip.cpp"),
    ("gpu_example", 32, upstream / "customization/gpu_example/gpu_example.cpp"),
]
records = []
for case, size, source in jobs:
    target = work / f"{case}{size}.ll"
    if case == "LUD":
        assert old.count("lud_kernel.hip.cpp") == 2 and old.count("BLOCK_SIZE=64") == 1
        cmd = [str(target) if a.endswith("/device.ll") else "BLOCK_SIZE=128" if a == "BLOCK_SIZE=64" else a for a in old]
        cmd[max(i for i, a in enumerate(old) if a == "lud_kernel.hip.cpp")] = str(source)
    else:
        cmd = [str(rocm / "llvm/bin/clang++"), f"--rocm-path={rocm}", f"--hip-path={rocm/'hip'}",
               "--offload-arch=gfx906", "-x", "hip", "--cuda-device-only", "-S", "-emit-llvm",
               "-O3", "-fno-unroll-loops", str(source), "-o", str(target)]
    print(shlex.join(cmd), flush=True)
    completed = subprocess.run(cmd, cwd=source.parent, env=env, capture_output=True, text=True)
    print(completed.stderr, end="", flush=True)
    if completed.returncode == 0 and target.is_file():
        verify = subprocess.run([llvm/"lib/llvm-12/bin/opt", "-verify", "-disable-output", target],
                                env=env, capture_output=True, text=True)
        print(verify.stderr, end="", flush=True)
    else:
        verify = None
    records.append({"case": case, "block_size": size, "path": str(target),
                    "generation": {"repository": "https://github.com/charitha22/cgo22ae-darm-benchmarks",
                    "revision": rev, "path": str(source.relative_to(upstream)), "cwd": str(source.parent),
                    "argv": cmd, "environment": {k: env[k] for k in ("LD_LIBRARY_PATH", "LC_ALL")}},
                    "ok": verify is not None and verify.returncode == 0,
                    "error": (completed.stderr if verify is None else verify.stderr).strip()})
    (work / "compiled.json").write_text(json.dumps(records, indent=2) + "\n")
