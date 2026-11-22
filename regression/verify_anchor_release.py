#!/usr/bin/env python3
"""Replay Anchor and verify SHA-256 of the original IR and device object bytes."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
import re
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


def verify_lud8_shape(case_out, env):
    # Replay the selected writeback on the same parent without a launch shape.
    # The thread-pattern policy should select the same guarded layout.
    folder = case_out / "default"
    active = folder / "active"
    summary = json.loads((active / "summary.json").read_text())
    for round_row in summary["rounds"]:
        if not round_row["selected"]:
            continue
        selected = folder / round_row["selected"]
        trial_path = selected / "structural/trial-0/trial.json"
        if not trial_path.exists():
            continue
        trial = json.loads(trial_path.read_text())
        if trial.get("anchor", {}).get("emission") == "guarded-linear":
            break
    else:
        raise ValueError("LUD8 shaped search did not commit guarded writeback")
    if trial["anchor"]["wave"]["classification"] != "must-diverge":
        raise ValueError("LUD8 shaped writeback lacks its must-diverge exemption")

    command = json.loads((selected / "request.json").read_text())["argv"]
    pos = command.index("--anchor-wave-shape")
    del command[pos:pos + 2]
    command[command.index("--debug-dir") + 1] = str(case_out / "missing-shape")
    command[command.index("--out") + 1] = str(case_out / "missing-shape.ll")
    result = subprocess.run(command, cwd=folder, env=env, capture_output=True, text=True)
    (case_out / "missing-shape.log").write_text(result.stdout + result.stderr)
    path = case_out / "missing-shape/trial-0/trial.json"
    report = json.loads(path.read_text())
    guarded = [layout for layout in report["layout_profitability"]
               if layout["anchor"]["emission"] == "guarded-linear" and layout["tti_eligible"]]
    if (result.returncode != 0
            or "using optimistic TTI" not in result.stderr
            or report["anchor"]["wave"]["classification"] != "unknown"
            or report["anchor"]["wave"]["condition_source"] != "thread-pattern"
            or not report["anchor"]["wave"].get("optimistic_without_shape")
            or not guarded or not any(g["eligible"] for g in guarded)
            or report["anchor"]["emission"] != "guarded-linear"
            or not report["eligible"]
            or (case_out / "missing-shape.ll").read_bytes() != (selected / "fused.ll").read_bytes()):
        raise ValueError("LUD8 unshaped writeback differs from the shaped writeback")
    return True


def rebuild_binary(final, binary, llvm, rocm, ptxas, ptxas_sha, env, log, codegen):
    if binary.suffix == ".hsaco":
        if codegen.get("correct_srad32_launch_bound"):
            # The frozen SRAD32 input uses the 256-thread LLVM bound. The
            # release comparison uses its documented 1024-thread diagnostic build.
            corrected = binary.with_suffix(".launch.ll")
            text, replacements = re.subn(r'"amdgpu-flat-work-group-size"="1,256"',
                                         '"amdgpu-flat-work-group-size"="1,1024"',
                                         final.read_text())
            if not replacements and '"amdgpu-flat-work-group-size"="1,1024"' not in text:
                raise ValueError("SRAD32 diagnostic build lacks the expected launch bound")
            corrected.write_text(text)
            final = corrected
        compile_kernel(final, binary, llvm, rocm,
                       features=codegen.get("amdgpu_features", "+sramecc,-xnack"), env=env)
        return

    if digest(ptxas.read_bytes()) != ptxas_sha:
        raise ValueError("ptxas checksum mismatch")
    post, ptx = binary.with_suffix(".post.ll"), binary.with_suffix(".ptx")
    commands = ([llvm / "opt", final, "-O3", "-verify-each", "-S", "-o", post],
                [llvm / "llc", post, "-O3", "-march=nvptx64", "-mcpu=sm_70",
                 "-mattr=+ptx70", "-o", ptx],
                [ptxas, "-O3", "-arch=sm_86", ptx, "-o", binary])
    for command in commands:
        subprocess.run(command, env=env, stdout=log, stderr=log, check=True)


def verify_profiles(row, source, case_out, tool_root, llvm, rocm, ptxas, ptxas_sha, env):
    expected = row["anchor_profiles"]
    metadata = json.loads((ROOT / row["case_metadata"]).read_text())["anchor_workgroups"][row["case"]]
    if metadata != {"function": row["function"], **row["workgroup"]}:
        raise ValueError(f"{row['case']}: manifest and case workgroup disagree")
    shape = ",".join(map(str, metadata["shape"]))
    folder = case_out / "default"
    folder.mkdir()
    command = [tool_root / "build/decision-fuse/decision-greedy", source, row["function"], tool_root,
               "active", "--anchor-wave-shape", shape]
    with (folder / "run.log").open("w") as log:
        subprocess.run(command, cwd=folder, env=env, stdout=log, stderr=log, check=True)
        final = folder / "active/final.ll"
        subprocess.run([llvm / "opt", "-verify", "-disable-output", final],
                       env=env, stdout=log, stderr=log, check=True)
    summary = json.loads((folder / "active/summary.json").read_text())
    if summary["status"] != "completed":
        raise ValueError(f"{row['case']}: default search incomplete")
    actual = {"commits": summary["commits"], "tti": summary["final_cost"],
              "ir_sha256": digest(final.read_bytes())}

    # Compare with the frozen old D, which is reproduced by c7dded07.
    legacy = expected["legacy"]
    delta = actual["tti"] - legacy["tti"]
    if delta > 0:
        print(f"WARNING: {row['case']}: default TTI {actual['tti']} > "
              f"legacy {legacy['tti']} (+{delta})", file=sys.stderr, flush=True)
    frozen = expected["default"]
    if any(frozen[key] != value for key, value in actual.items()):
        raise ValueError(f"{row['case']}: default profile differs: {actual} != {frozen}")
    if "binary" in frozen:
        fmt = frozen["binary"]["format"]
        binary = folder / ("kernel." + fmt)
        with (folder / "build.log").open("w") as log:
            rebuild_binary(final, binary, llvm, rocm, ptxas, ptxas_sha, env, log,
                           row.get("anchor_codegen", {}))
        actual["binary"] = {"format": fmt, "sha256": digest(binary.read_bytes())}
        if actual["binary"] != frozen["binary"]:
            raise ValueError(f"{row['case']}: default machine code differs from the frozen profile")
    missing_shape_verified = verify_lud8_shape(case_out, env) if row["case"] == "LUD8" else None
    print(f"{row['case']}: default verified", flush=True)
    return {"case": row["case"], "verified": True, "profiles": {"default": actual},
            "legacy_reference": legacy, "default_matches_legacy_ir": actual["ir_sha256"] == legacy["ir_sha256"],
            "tti_delta": delta,
            **({"lud8_missing_shape_verified": missing_shape_verified} if missing_shape_verified is not None else {})}


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
    release_cases = manifest["cases"] + manifest.get("anchor_additional_cases", [])
    cases = [row for row in release_cases if not args.case or row["case"] in args.case]
    if args.case and set(args.case) != {row["case"] for row in cases}:
        parser.error("--case contains an unknown name")
    env = os.environ.copy()
    env.setdefault("DECISION_GREEDY_JOBS", "8")
    llvm = args.llvm12_bin
    if llvm is None:
        if "LLVM_CONFIG" not in env:
            parser.error("set LLVM_CONFIG or pass --llvm12-bin")
        llvm = Path(subprocess.check_output([env["LLVM_CONFIG"], "--bindir"], text=True).strip())
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    tool_root = args.tool_root.resolve()
    ptxas = args.ptxas or Path(manifest["tools"]["ptxas"]["path"])
    ptxas_sha = manifest["tools"]["ptxas"]["sha256"]

    def reproduce(row):
        name = row["case"]
        source = Path(row["source_path"])
        case_out = out / name
        case_out.mkdir()
        if "anchor_profiles" in row:
            if "archive_entry" in row["input"]:
                content = packed[row["input"]["archive_entry"]]
                if digest(content) != row["input"]["sha256"]:
                    raise ValueError(f"{name}: frozen input checksum mismatch")
                ensure_frozen_source(source, content)
            if digest(source.read_bytes()) != row["input"]["sha256"]:
                raise ValueError(f"{name}: frozen input checksum mismatch")
            return verify_profiles(row, source, case_out, tool_root, llvm, args.rocm, ptxas, ptxas_sha, env)

        active = Path(row["serialization_output_path"])
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
                rebuild_binary(final, binary, llvm, args.rocm, ptxas, ptxas_sha, env, log, {})
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
    warnings = [r for r in results if r.get("tti_delta", 0) > 0]
    if warnings:
        print("Default TTI above legacy: " + ", ".join(
            f"{r['case']} +{r['tti_delta']}" for r in warnings), file=sys.stderr)
    (out / "results.json").write_text(json.dumps(results, indent=2) + "\n")


if __name__ == "__main__":
    main()
