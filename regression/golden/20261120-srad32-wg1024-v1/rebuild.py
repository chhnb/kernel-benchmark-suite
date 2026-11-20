#!/usr/bin/env python3
"""Rebuild the SRAD32 workgroup-only freeze in a new directory."""

import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

VERSION = Path(__file__).resolve().parent
ROOT = VERSION.parents[2]
RELEASE = VERSION.parent / "20261120-anchor-release"
OLD_ATTR = b'"amdgpu-flat-work-group-size"="1,256"'
NEW_ATTR = b'"amdgpu-flat-work-group-size"="1,1024"'
sys.path.insert(0, str(ROOT / "tools"))
from compile_kernel import compile_kernel


def check_digest(data, expected, label):
    if hashlib.sha256(data).hexdigest() != expected:
        raise RuntimeError(f"SHA-256 mismatch for {label}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="New directory outside the freezes")
    parser.add_argument("--llvm12-bin", required=True, type=Path)
    parser.add_argument("--rocm", default=Path("/opt/rocm-6.3.3"), type=Path)
    parser.add_argument("--runner", type=Path, help="Validate each HSACO on the GPU")
    args = parser.parse_args()
    output = args.output.resolve()
    if VERSION in output.parents or RELEASE in output.parents:
        parser.error("choose an output directory outside the frozen versions")
    output.mkdir(parents=True)

    source = json.loads((RELEASE / "manifest.json").read_text())
    freeze = json.loads((VERSION / "manifest.json").read_text())
    srad = next(row for row in source["cases"] if row["case"] == "SRAD32")
    for name, digest in freeze["fixture"]["files"].items():
        data = gzip.decompress((VERSION / f"{name}.gz").read_bytes())
        check_digest(data, digest, name)
        (output / name).write_bytes(data)

    # Verify the frontend's spelling before changing only that attribute in
    # the frozen modules. Re-running source optimization would change the IR.
    probe = output / "workgroup-probe.ll"
    subprocess.run(
        [
            args.llvm12_bin / "clang", "-cc1", "-triple", "amdgcn-amd-amdhsa",
            "-target-cpu", "gfx906", "-fcuda-is-device", "-x", "hip",
            freeze["compiler_flag"], "-emit-llvm", "-o", probe, "-",
        ],
        input=b'extern "C" __attribute__((global)) void probe(int *p) { *p = 1; }\n',
        check=True,
    )
    if NEW_ATTR not in probe.read_bytes():
        raise RuntimeError("Clang did not emit the expected SRAD32 workgroup limit")

    with tarfile.open(RELEASE / source["archive"]["file"]) as archive:
        entries = {
            "baseline": srad["input"],
            "anchor": srad["anchor_reference"]["ir"],
            "darm": srad["darm_reference"]["ir"],
        }
        for role, entry in entries.items():
            old = archive.extractfile(entry["archive_entry"]).read()
            expected = freeze["roles"][role]
            check_digest(old, expected["old_ir_sha256"], f"old {role} IR")
            new = old.replace(OLD_ATTR, NEW_ATTR)
            if new == old or new.replace(NEW_ATTR, OLD_ATTR) != old:
                raise RuntimeError(f"unexpected attribute change for {role}")
            check_digest(new, expected["ir_sha256"], f"new {role} IR")
            ir = output / f"{role}.ll"
            ir.write_bytes(new)
            hsaco = ir.with_suffix(".hsaco")
            compile_kernel(ir, hsaco, args.llvm12_bin, args.rocm)
            check_digest(hsaco.read_bytes(), expected["hsaco_sha256"], f"{role} HSACO")
            if args.runner:
                subprocess.run(
                    [
                        args.runner.resolve(), "--kernel", hsaco, "--input",
                        output / "input.txt", "--output", output / f"validate-{role}",
                        "--mode", "validate",
                    ],
                    check=True,
                )


if __name__ == "__main__":
    main()
