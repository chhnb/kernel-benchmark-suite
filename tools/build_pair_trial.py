import json
import os
from pathlib import Path
import shlex
import subprocess

root = Path(__file__).resolve().parents[1]
build = root / "build/pair-trial"
build.mkdir(parents=True, exist_ok=True)
config = os.environ.get("LLVM_CONFIG", "/home/chh/darm-artifacts-repro/build/bin/llvm-config")
compiler = os.environ.get("CXX", "g++")


def llvm_flags(*options):
    return shlex.split(subprocess.check_output([config, *options], text=True))


def run(command, name):
    (build / f"{name}-command.json").write_text(json.dumps(command, indent=2))
    with (build / f"{name}.stderr").open("w") as errors:
        result = subprocess.run(command, stderr=errors)
    if result.returncode:
        print((build / f"{name}.stderr").read_text()[-6000:])
        raise SystemExit(result.returncode)


flags = llvm_flags("--cxxflags")
packaged = subprocess.run(
    [compiler, *flags, "-x", "c++", "-fsyntax-only", "-"],
    input='#include "llvm/Support/InstructionCost.h"\n',
    text=True,
    capture_output=True,
).returncode == 0
if packaged:
    flags.append("-DFUSION_PACKAGED_LLVM12")
    libraries = llvm_flags("--ldflags", "--link-shared", "--libs", "--system-libs")
else:
    libraries = llvm_flags(
        "--ldflags", "--libs", "core", "irreader", "asmparser", "analysis",
        "transformutils", "scalaropts", "ipo", "instcombine", "vectorize",
        "amdgpu", "x86", "nvptx", "--system-libs",
    )
flags += ["-std=c++17", "-fexceptions", "-O2"]
engine = root / "tools/darm_pair_engine"
sources = [
    root / "tools" / f"{name}.cpp"
    for name in ("pair_trial", "fusion_search", "logical_region_state", "ir_dependency", "ir_pressure")
]
sources += [
    engine / f"{name}.cpp"
    for name in ("RegionAnalyzer", "RegionMelder", "RegionReplicator", "CFMelderUtils", "InstructionMatch")
]
objects = []
for source in sources:
    obj = build / (source.stem + ".o")
    run([compiler, *flags, "-I" + str(engine), "-c", str(source), "-o", str(obj)], source.stem)
    objects.append(str(obj))
run([compiler, *objects, *libraries, "-o", str(build / "pair-trial")], "link")
