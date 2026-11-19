#!/usr/bin/env python3
"""Rebuild the anchor release references from their frozen IR inputs."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "regression/golden/20261120-anchor-release/manifest.json"
sys.path.insert(0, str(ROOT / "tools"))
from compile_kernel import compile_kernel


def digest(data):
    return hashlib.sha256(data).hexdigest()


def load_references(manifest_path, manifest):
    archive = manifest_path.parent / manifest["archive"]["file"]
    if digest(archive.read_bytes()) != manifest["archive"]["sha256"]:
        raise ValueError("frozen archive checksum mismatch")
    references = {}
    with tarfile.open(archive, "r:gz") as stream:
        for entry in stream:
            if not entry.isfile():
                raise ValueError("unexpected archive entry: " + entry.name)
            references[entry.name] = stream.extractfile(entry).read()
    return references


def ensure_frozen_source(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        with path.open("xb") as stream:
            stream.write(content)
    except FileExistsError:
        if path.read_bytes() != content:
            raise ValueError(f"existing input differs from frozen input: {path}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--tool-root", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--case", action="append")
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--llvm12-bin", type=Path)
    parser.add_argument("--rocm", type=Path, default=Path("/opt/rocm-6.3.3"))
    parser.add_argument("--ptxas", type=Path)
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be positive")

    manifest = json.loads(args.manifest.read_text())
    packed = load_references(args.manifest, manifest)
    cases = [row for row in manifest["cases"] if not args.case or row["case"] in args.case]
    if args.case and set(args.case) != {row["case"] for row in cases}:
        parser.error("--case contains an unknown name")
    env = os.environ | {"FUSION_TTI_MODE": "llvm24", "FUSION_TTI_COST_KIND": "throughput"}
    env.setdefault("DECISION_GREEDY_JOBS", "8")
    env.pop("FUSION_TTI_OVERRIDES", None)
    llvm = args.llvm12_bin
    if llvm is None:
        if "LLVM_CONFIG" not in env:
            parser.error("set LLVM_CONFIG or pass --llvm12-bin")
        llvm = Path(subprocess.check_output([env["LLVM_CONFIG"], "--bindir"], text=True).strip())
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    tool_root = args.tool_root.resolve()
    ptxas = args.ptxas or Path(manifest["tools"]["ptxas"]["path"])

    def reproduce(row):
        name = row["case"]
        source = Path(row["source_path"])
        active = Path(row["serialization_output_path"])
        case_out = out / name
        case_out.mkdir()
        if active.exists():
            raise FileExistsError(f"canonical Greedy output already exists: {active}")
        active.parent.mkdir(parents=True, exist_ok=True)
        compare = row["anchor_reference"]
        frozen_ir = packed[compare["ir"]["archive_entry"]]
        frozen_binary = packed[compare["binary"]["archive_entry"]]
        frozen_input = packed[row["input"]["archive_entry"]]
        for entry, content in ((row["input"], frozen_input),
                               (compare["ir"], frozen_ir), (compare["binary"], frozen_binary)):
            if digest(content) != entry["sha256"]:
                raise ValueError(f"{name}: mismatching component in reference archive")
        ensure_frozen_source(source, frozen_input)
        binary = case_out / ("kernel." + compare["binary"]["format"])
        try:
            with (case_out / "run.log").open("w") as log:
                def run(command):
                    subprocess.run(command, env=env, stdout=log, stderr=log, check=True)

                run([tool_root / "build/decision-fuse/decision-greedy", source, row["function"],
                     tool_root, active])
                final = active / "final.ll"
                run([llvm / "opt", "-verify", "-disable-output", final])
                if binary.suffix == ".hsaco":
                    compile_kernel(final, binary, llvm, args.rocm, env=env)
                else:
                    if digest(ptxas.read_bytes()) != manifest["tools"]["ptxas"]["sha256"]:
                        raise ValueError("ptxas checksum mismatch")
                    post, ptx = case_out / "post.ll", case_out / "kernel.ptx"
                    run([llvm / "opt", final, "-O3", "-verify-each", "-S", "-o", post])
                    run([llvm / "llc", post, "-O3", "-march=nvptx64", "-mcpu=sm_70", "-mattr=+ptx70",
                         "-o", ptx])
                    run([ptxas, "-O3", "-arch=sm_86", ptx, "-o", binary])
                result = json.loads((active / "summary.json").read_text())
                if result["status"] != "completed" or result["b2b_strategy"] != "anchor":
                    raise ValueError(f"{name}: incomplete anchor search")
                if result["commits"] != compare["commits"] or result["final_cost"] != compare["tti"]:
                    raise ValueError(f"{name}: commit count or TTI differs")
                if final.read_bytes() != frozen_ir or binary.read_bytes() != frozen_binary:
                    raise ValueError(f"{name}: IR or machine code differs from the frozen reference")
            print(f"{name}: bit-identical IR and machine code", flush=True)
            return {"case": name, "verified": True, "ir_sha256": digest(frozen_ir),
                    "binary_sha256": digest(frozen_binary)}
        finally:
            if active.exists():
                shutil.move(active, case_out / "greedy")

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = list(pool.map(reproduce, cases))
    (out / "results.json").write_text(json.dumps(results, indent=2) + "\n")


if __name__ == "__main__":
    main()
