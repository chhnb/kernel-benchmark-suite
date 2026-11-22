#!/usr/bin/env python3
"""Compile LLVM 12 AMDGPU IR to an HSACO using Auto Greedy V2."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def compile_kernel(source, output, llvm, rocm, *, function=None, work_dir=None,
                   target="gfx906", features="+sramecc,-xnack", code_object_version=4,
                   preopt=True, anchor_wave_shape=None, env=None):
    source = source.resolve(strict=True)
    output = output.absolute()
    if os.path.lexists(output):
        raise FileExistsError(f"Output already exists: {output}")

    def run(*argv):
        subprocess.run(argv, check=True, env=env)

    # Stage the linked file alongside the destination and publish it only
    # after the linker succeeds. A concurrent build cannot replace it.
    with tempfile.TemporaryDirectory(prefix=".kernel-build-", dir=output.parent) as directory:
        staging = Path(directory)
        work = staging
        if work_dir is not None:
            work = work_dir.absolute()
            work.mkdir(parents=True, exist_ok=False)

        kernel_ir = source
        if function is not None:
            search = work / "greedy"
            command = [ROOT / "build/decision-fuse/decision-greedy", source, function, search]
            if anchor_wave_shape is not None:
                command += ["--anchor-wave-shape", anchor_wave_shape]
            if work_dir is not None:
                command += ["--ir-snapshots", "full"]
            run(*command)
            kernel_ir = search / "final.ll"

        if preopt:
            prepared = work / "kernel-final.ll"
            run(llvm / "opt", kernel_ir, "-O3", "-verify-each", "-S", "-o", prepared)
            kernel_ir = prepared
        else:
            run(llvm / "opt", "-verify", "-disable-output", kernel_ir)

        obj = work / "kernel.o"
        flags = ["-O3", "-mtriple=amdgcn-amd-amdhsa", f"-mcpu={target}",
                 f"-mattr={features}", "-filetype=obj"]
        if code_object_version is not None:
            flags.append(f"-amdhsa-code-object-version={code_object_version}")
        run(llvm / "llc", kernel_ir, *flags, "-o", obj)
        binary = staging / "kernel.hsaco"
        run(rocm / "llvm/bin/ld.lld", "-shared", obj, "-o", binary)
        os.link(binary, output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ir", type=Path)
    parser.add_argument("function", help="LLVM function name to optimize")
    parser.add_argument("--out", type=Path, required=True, help="New HSACO output file")
    parser.add_argument("--llvm12-bin", type=Path, required=True)
    parser.add_argument("--rocm", type=Path, default=Path("/opt/rocm"))
    parser.add_argument("--mcpu", default="gfx906")
    parser.add_argument("--mattr", default="+sramecc,-xnack")
    parser.add_argument("--no-preopt", action="store_true",
                        help="Verify input to llc and skip the separate opt -O3 pass")
    parser.add_argument(
        "--anchor-wave-shape", metavar="X,Y,Z",
        help=("Exact workgroup launch shape for Anchor to prove wave divergence. "
              "If omitted, use exact reqd_work_group_size metadata when present. "
              "With neither source, Anchor uses conservative gating "
              "(LUD8 final TTI 666, compared with 637 using 16,1,1)."),
    )
    parser.add_argument("--work-dir", type=Path, help="New directory for full search and build diagnostics")
    args = parser.parse_args()
    try:
        compile_kernel(args.ir, args.out, args.llvm12_bin.resolve(), args.rocm.resolve(),
                       function=args.function, work_dir=args.work_dir, target=args.mcpu,
                       features=args.mattr, preopt=not args.no_preopt,
                       anchor_wave_shape=args.anchor_wave_shape)
    except (OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"compile_kernel: {error}\n")


if __name__ == "__main__":
    main()
