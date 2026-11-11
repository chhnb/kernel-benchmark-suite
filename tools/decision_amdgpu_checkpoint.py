#!/usr/bin/env python3
"""Compile one IR snapshot and measure kernel resources and HIP occupancy."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

from postopt_resources import extract


def main():
    ir, function = sys.argv[1:]
    llvm = Path(os.environ["DECISION_AMDGPU_LLVM_BIN"])
    rocm = Path(os.environ.get("DECISION_ROCM_LLVM_BIN", "/opt/rocm/llvm/bin"))
    cpu = os.environ["DECISION_AMDGPU_CPU"]
    block_size = os.environ["DECISION_AMDGPU_BLOCK_SIZE"]
    occupancy_tool = os.environ["DECISION_AMDGPU_OCCUPANCY_TOOL"]
    with tempfile.TemporaryDirectory(prefix="decision-checkpoint-") as directory:
        optimized = Path(directory) / "optimized.ll"
        obj = Path(directory) / "kernel.o"
        binary = Path(directory) / "kernel.hsaco"
        subprocess.run([llvm / "opt", ir, "-O3", "-verify-each", "-S",
                        "-o", optimized], check=True)
        target = [f"-mcpu={cpu}", "-mtriple=amdgcn-amd-amdhsa",
                  "-amdhsa-code-object-version=4"]
        if attrs := os.environ.get("DECISION_AMDGPU_FEATURES"):
            target.append(f"-mattr={attrs}")
        subprocess.run([llvm / "llc", optimized, "-O3", *target,
                        "-filetype=obj", "-o", obj], check=True)
        subprocess.run([rocm / "ld.lld", "-shared", obj, "-o", binary], check=True)
        notes = subprocess.check_output([rocm / "llvm-readobj", "--notes", binary],
                                        text=True)
        metrics = extract(notes, function)
        metrics["active_blocks_per_cu"] = int(subprocess.check_output(
            [occupancy_tool, binary, function, block_size], text=True))
        print(json.dumps(metrics))


if __name__ == "__main__":
    main()
