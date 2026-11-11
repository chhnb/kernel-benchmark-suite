"""Verify pair-local ownership, rejection of escaping leaves, and CPU output."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
MODEL = ROOT / "build/decision-model/decision-model"
FUSE = ROOT / "build/decision-fuse/decision-fuse"
IR = """define i32 @evaluate(i1 %first, i1 %second, i1 %early, i32 %x) {
entry:
  br i1 %first, label %left, label %test
test:
  br i1 %second, label %right, label %third
left:
  %a = mul i32 %x, 3
  br label %shared
right:
  %b = mul i32 %x, 5
  br label %shared
third:
  br label %exit
shared:
  %v = phi i32 [ %a, %left ], [ %b, %right ]
  %w = add i32 %v, 7
  br label %exit
exit:
  %out = phi i32 [ %w, %shared ], [ 0, %third ]
  ret i32 %out
}
"""


def discover(path):
    catalog = json.loads(subprocess.check_output([MODEL, path, "evaluate"]))
    return next((i, row) for i, row in enumerate(catalog) if row["root"] == "%entry")


def run_fuse(path, index, left, out):
    env = dict(os.environ, DECISION_SPECULATION="none",
               DECISION_CFG_CLEANUP="structural", DECISION_CHECKPOINT_MODE="off",
               DECISION_UNIFORM_REPORT="1")
    env.pop("DECISION_GAP_SEARCH", None)
    result = subprocess.run([FUSE, path, "evaluate", str(index), str(left), out],
                            env=env, capture_output=True, text=True)
    return result, json.loads((out / "trial.json").read_text())


with tempfile.TemporaryDirectory(prefix="pair-join-") as tmp:
    work = Path(tmp)
    original = work / "before.ll"
    original.write_text(IR)
    index, decision = discover(original)
    assert decision["join"] == "%exit"
    assert [a["exit_targets"] for a in decision["arms"]] == [
        ["%shared"], ["%shared"], ["%exit"]]
    assert "%shared" not in decision["arms"][0]["blocks"]
    assert decision["pairs"] == [{"join": "%shared", "reason": ""},
                                  {"join": "", "reason": "pair_exit_targets_mismatch"}]
    result, report = run_fuse(original, index, 0, work / "fused")
    assert result.returncode == 0, (report, result.stderr)
    assert report["pair_join"] == "%shared" and report["decision_join"] == "%exit"
    assert all(row["before_path_invariant"] for row in report["uniform_before"])
    result, report = run_fuse(original, index, 1, work / "mismatch")
    assert result.returncode != 0 and report["reason"] == "pair_exit_targets_mismatch"

    escapes = work / "escape.ll"
    escapes.write_text(IR.replace("br label %shared\nright:",
                                 "br i1 %early, label %exit, label %shared\nright:")
                       .replace("[ 0, %third ]", "[ 0, %third ], [ %a, %left ]"))
    index, decision = discover(escapes)
    assert set(decision["arms"][0]["exit_targets"]) == {"%shared", "%exit"}
    result, report = run_fuse(escapes, index, 0, work / "escape")
    assert result.returncode != 0 and report["reason"] == "pair_exit_targets_mismatch"

    harness = work / "main.c"
    harness.write_text("""
extern int evaluate(_Bool, _Bool, _Bool, int);
int main(void) {
    for (int a = 0; a < 2; ++a)
        for (int b = 0; b < 2; ++b)
            for (int x = -100; x <= 100; ++x)
                if (evaluate(a, b, 0, x) != (a ? 3*x+7 : b ? 5*x+7 : 0))
                    return 1;
    return 0;
}
""")
    binary = work / "check"
    subprocess.run([os.getenv("CLANG", "clang"), harness, work / "fused/fused.ll",
                    "-o", binary], check=True)
    subprocess.run([binary], check=True)
print("Pair-local join, escaping arm rejection and 804 CPU outputs verified")
