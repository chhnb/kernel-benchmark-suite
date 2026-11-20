"""Check discovery and execution of a region pair with distinct local exits, and a guarded private write."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("search", type=Path)
parser.add_argument("opt", type=Path)
parser.add_argument("clang", type=Path)
args = parser.parse_args()
fixture = Path(__file__).with_name("independent-region-exits.ll").resolve()
harness = r"""
#include <stdbool.h>
#include <stdlib.h>
extern int choose(bool side, bool test, int x);
int main(void) {
    for (int side = 0; side < 2; ++side)
        for (int test = 0; test < 2; ++test)
            for (int x = -100; x <= 100; ++x) {
                int expected = x * (test ? (side ? 7 : 11) : 1) + (side ? 1 : -2);
                if (choose(side, test, x) != expected) return EXIT_FAILURE;
            }
    return EXIT_SUCCESS;
}
"""

def run(*command):
    subprocess.run(command, check=True, capture_output=True)

with tempfile.TemporaryDirectory() as temp:
    out = Path(temp)
    command = [args.search.resolve(), "--ir", fixture, "--function", "choose",
               "--structural", "1", "--cleanup", "darm-cfg-dce-instcombine", "--b2b-strategy", "darm",
               "--tti-worker", str(fixture.parents[2] / "tools/run-llvm24-tti")]
    run(*command, "--catalog-only", "1", "--debug-dir", out / "catalog",
        "--out", out / "catalog.ll")
    catalog = json.loads((out / "catalog/catalog.json").read_text())
    regions = [p for p in catalog["candidates"] if p["left"].startswith("R") and p["right"].startswith("R")]
    assert len(regions) == 1, regions
    pair = regions[0]
    fused = out / "fused.ll"
    run(*command, "--split", pair["split"], "--left", pair["left"],
        "--right", pair["right"], "--debug-dir", out / "trial", "--out", fused)
    trial = json.loads((out / "trial/trial-0/trial.json").read_text())
    assert trial["valid"] and not trial["replication_required"]
    assert [(trial[s]["entry"], trial[s]["exit"]) for s in ("left", "right")] == [
        ("%left", "%left.exit"), ("%right", "%right.exit")]
    run(args.opt.resolve(), "-verify", "-disable-output", fused)
    source = out / "check.c"
    source.write_text(harness)
    for variant in (fixture, fused):
        executable = out / "check"
        run(args.clang.resolve(), "-O0", source, variant, "-o", executable)
        run(executable)
    print("Independent region exits, PHIs and live-outs verified on 804 inputs")

    fixture = fixture.with_name("guarded-anchor-store.ll")
    source.write_text(harness.replace(
        "x * (test ? (side ? 7 : 11) : 1) + (side ? 1 : -2)",
        "side ? 7*x + 23 : 12*(x + (test ? 3 : 0))"))
    command[2] = fixture
    pair_args = ("--split", "B0", "--left", "B1", "--right", "B4")
    fused = out / "guarded.ll"
    run(*command, *pair_args, "--debug-dir", out / "guarded", "--out", fused)
    trial = json.loads((out / "guarded/trial-0/trial.json").read_text())
    assert trial["valid"] and not trial["replication_required"]
    assert (trial["left"]["entry"], trial["right"]["entry"]) == ("%short", "%tail")
    run(args.opt.resolve(), "-verify", "-disable-output", fused)
    for variant in (fixture, fused):
        executable = out / "guarded-check"
        run(args.clang.resolve(), "-O0", source, variant, "-o", executable)
        run(executable)
    global_store = out / "guarded-global.ll"
    global_store.write_text("@scratch = global i32 0, align 4\n\n" + fixture.read_text()
                            .replace("  %scratch = alloca i32, align 4\n", "")
                            .replace("%scratch", "@scratch"))
    command[2] = global_store
    fused_global = out / "guarded-global-fused.ll"
    run(*command, *pair_args, "--debug-dir", out / "global", "--out", fused_global)
    trial = json.loads((out / "global/trial-0/trial.json").read_text())
    assert trial["valid"] and not trial["replication_required"]
    run(args.opt.resolve(), "-verify", "-disable-output", fused_global)
    for variant in (global_store, fused_global):
        executable = out / "global-check"
        run(args.clang.resolve(), "-O0", source, variant, "-o", executable)
        run(executable)

    negative = out / "volatile.ll"
    negative.write_text(fixture.read_text().replace("store i32 %x", "store volatile i32 %x"))
    command[2] = negative
    output = out / "rejected.ll"
    result = subprocess.run([*command, *pair_args, "--debug-dir", out / "negative",
                             "--out", output], capture_output=True)
    trial = json.loads((out / "negative/trial-0/trial.json").read_text())
    assert result.returncode == 4 and not output.exists()
    assert not trial["rewrite_started"] and trial["reason"] == "nonordinary_store_cannot_be_preserved"
print("Guarded private store verified on 804 inputs, volatile store rejected before rewriting")
