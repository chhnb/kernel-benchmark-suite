#!/usr/bin/env python3
"""Execute the replicated memory path on CPU, including invalid bypass pointers."""
import argparse
import json
import os
from pathlib import Path
import re
import sqlite3
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("llvm12_bin", type=Path)
args = parser.parse_args()
engine = root / "build/llvm24-tti/fusion-search-llvm24"
fixture = Path(__file__).with_name("guarded-load.ll")

with tempfile.TemporaryDirectory() as directory:
    work = Path(directory)
    debug = work / "trial"
    fused = work / "fused.ll"
    subprocess.run([
        engine, "--ir", fixture, "--function", "choose", "--split", "B0",
        "--left", "B1", "--right", "B3", "--b2r-strategy", "guarded",
        "--debug-dir", debug, "--out", fused, "--tti-worker", "/bin/false",
    ], check=True, capture_output=True, text=True)
    report = json.loads((debug / "trial-0/trial.json").read_text())
    assert report["valid"] and report["replication_required"], report["reason"]
    assert report["merge_path"] == "guarded-B2R"
    raw_ir = (debug / "trial-0/after-raw.ll").read_text()
    raw_ir = raw_ir.split("define i32 @choose(", 1)[1].split("\n}", 1)[0]
    assert raw_ir.count("load i8,") == 1 and raw_ir.count("store i8 ") == 1
    # The replica's constant branch bypasses `special`, so its load and
    # arithmetic can retain the original guard. Only the shared entry needs
    # a new split for the mask access and store.
    assert len(re.findall(r"^predication\.split\d*:", raw_ir, flags=re.MULTILINE)) == 1

    # Use deterministic fallback quotes for this CPU fixture. The folded
    # layout should win by removing control flow and a duplicate load.
    database = work / "empty-quotes.sqlite"
    with sqlite3.connect(database) as db:
        db.executescript("""
            CREATE TABLE reports (digest TEXT PRIMARY KEY, data BLOB NOT NULL);
            CREATE TABLE quotes (key TEXT PRIMARY KEY, histogram TEXT, cost INTEGER);
        """)
    env = os.environ | {"FUSION_TTI_MODE": "offline", "FUSION_TTI_DB": str(database),
                        "FUSION_TTI_WARNINGS": str(work / "warnings.log"),
                        "FUSION_TTI_COST_KIND": "throughput"}
    env.pop("FUSION_TTI_OVERRIDES", None)
    folded, boundary_debug = work / "folded.ll", work / "boundary-trial"
    subprocess.run([
        engine, "--ir", fused, "--function", "choose_boundary", "--split", "B0",
        "--left", "B4", "--right", "B6", "--b2r-strategy", "guarded",
        "--debug-dir", boundary_debug, "--out", folded,
        "--tti-worker", root / "tools/run-llvm24-tti",
    ], env=env, check=True, capture_output=True, text=True)
    boundary = json.loads((boundary_debug / "trial-0/trial.json").read_text())
    assert boundary["merge_path"] == "guarded-R2B-boundary-fold", boundary["layout_profitability"]
    assert [row["layout"] for row in boundary["layout_profitability"]] == [
        "guarded-R2B", "guarded-R2B-boundary-fold"]
    assert all(row["cost"] is not None for row in boundary["layout_profitability"])

    harness = work / "main.c"
    harness.write_text("""
#include <assert.h>
#include <stdbool.h>

extern int choose(bool outside, unsigned char *mask, int *data, unsigned char *written);
extern int choose_boundary(bool region, int x, unsigned char *mask, int *left, int *right);

int main(void) {
    int data = 42;
    unsigned char mask = 0, written = 255;
    assert(choose(true, 0, &data, 0) == 42);
    assert(choose(false, &mask, &data, &written) == 42 && written == 0);
    mask = 1;
    assert(choose(false, &mask, &data, &written) == -42 && written == 1);
    int left[] = {10, 11, 12, 13};
    int right[] = {20, 21, 22, 23, 24, 25};
    unsigned char boundary_mask[] = {0, 0, 1, 0};
    assert(choose_boundary(true, 4, 0, left, 0) == 13);
    assert(choose_boundary(false, 4, 0, 0, right) == 25);
    assert(choose_boundary(true, 1, boundary_mask, left, 0) == 11);
    assert(choose_boundary(true, 2, boundary_mask, left, 0) == 10);
    return 0;
}
""")
    for ir in (fixture, folded):
        obj, executable = work / "choose.o", work / "check"
        subprocess.run([args.llvm12_bin / "opt", "-verify", "-disable-output", ir], check=True)
        subprocess.run([args.llvm12_bin / "llc", "-filetype=obj", ir, "-o", obj], check=True)
        subprocess.run(["cc", harness, obj, "-o", executable], check=True)
        subprocess.run([executable], check=True)
print("PASS guarded B2R preserves memory paths for independent and folded guards")
