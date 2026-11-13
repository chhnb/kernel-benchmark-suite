"""Exercise sibling-loop fusion with different trip counts and exit values."""
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
fixture = Path(__file__).with_name("sibling-single-block-loops.ll").resolve()
harness = """
#include <stdbool.h>
extern int choose(bool, int, int);
int main(void) {
    for (int side = 0; side <= 1; ++side)
        for (int n = -2; n <= 100; ++n)
            for (int x = -10; x <= 10; ++x) {
                int trips = n <= 0 ? 1 : side ? n : (n + 1) / 2;
                if (choose(side, n, x) != x + trips * (side ? 7 : 11))
                    return 1;
            }
    return 0;
}
"""

with tempfile.TemporaryDirectory() as temporary:
    out = Path(temporary)
    command = [args.search.resolve(), "--function", "choose", "--structural", "1",
               "--cleanup", "scoped-cfg", "--scorer", "legacy"]
    def trial(source, label):
        binary_ir = out / (label + ".ll")
        log = out / label
        result = subprocess.run([*command, "--ir", source, "--split", "B0",
                                 "--left", "R2", "--right", "R3", "--out", binary_ir,
                                 "--debug-dir", log], capture_output=True, timeout=15)
        return result, binary_ir, json.loads((log / "trial-0/trial.json").read_text())

    result, fused, report = trial(fixture, "fused")
    assert result.returncode == 0 and report["valid"], result.stderr
    assert report["fusion_plan"]["kind"] == "R2R"
    assert not report["replication_required"] and report["after"]["loops"] == 1
    subprocess.run([args.opt.resolve(), "-verify", "-disable-output", fused], check=True)
    source = out / "harness.c"
    source.write_text(harness)
    for variant in (fixture, fused):
        exe = out / "run"
        subprocess.run([args.clang.resolve(), "-O0", source, variant, "-o", exe],
                       check=True, capture_output=True)
        subprocess.run([exe], check=True, timeout=10)

    negative = out / "reversed.ll"
    negative.write_text(fixture.read_text().replace(
        "br i1 %right.more, label %right, label %join",
        "br i1 %right.more, label %join, label %right"))
    result, fused, report = trial(negative, "rejected")
    assert result.returncode == 4 and not fused.exists(), result.stderr
    assert not report["rewrite_started"]
    assert report["reason"] == "loop_in_trial_scope_not_supported"
print("Sibling loops verified on 4326 inputs; mismatched backedge directions rejected")
