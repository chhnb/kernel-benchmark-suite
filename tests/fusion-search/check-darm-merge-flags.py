#!/usr/bin/env python3
"""Verify that shared DARM instructions retain only common IR properties."""

from pathlib import Path
import json
import re
import subprocess
import sys
import tempfile


search, worker, opt = map(Path, sys.argv[1:])
fixture = Path(__file__).with_name("darm-merge-flags.ll")


def merged_ir(root, function):
    prefix = root / function
    debug = prefix.with_suffix(".debug")
    result = prefix.with_suffix(".ll")
    command = [
        search, "--ir", fixture, "--function", function,
        "--split", "B0", "--left", "B1", "--right", "B2",
        "--b2b-strategy", "darm", "--tti-worker", worker,
        "--out", result, "--debug-dir", debug,
    ]
    subprocess.run(command, check=True)
    trial = debug / "trial-0"
    report = json.loads((trial / "trial.json").read_text())
    assert report["valid"] and "darm" in report["merge_path"], report
    raw = trial / "after-raw.ll"
    subprocess.run([opt, "-verify", "-disable-output", raw], check=True)
    return (raw.read_text().split(f"@{function}(", 1)[1]
            .split("\n}", 1)[0].splitlines())


def instruction(lines, opcode):
    matched = [line.strip() for line in lines
               if re.match(rf"\s*(?:%[^ ]+ = )?{opcode} ", line)]
    assert len(matched) == 1, (opcode, matched)
    return matched[0].split(" = ")[-1]


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    integer = merged_ir(root, "integer_flags")
    for opcode in ("add", "shl"):
        assert instruction(integer, opcode).startswith(f"{opcode} nuw i32 ")
    assert instruction(integer, "lshr").startswith("lshr i32 ")

    floating = merged_ir(root, "float_flags")
    assert instruction(floating, "fadd").startswith("fadd float ")

    memory = merged_ir(root, "memory_metadata")
    load = instruction(memory, "load")
    assert "!tbaa" not in load and "!tbaa" not in instruction(memory, "store")
    assert "!range" not in load

print("PASS DARM flags and metadata intersection in shared IR")
