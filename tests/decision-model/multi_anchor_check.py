"""Exercise the multi-anchor fuser and replay a deliberately reordered catalog."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
tools = root / "build/decision-fuse"
fixture = Path(__file__).with_name("multi-anchor.ll")
harness = r"""
#include <math.h>
#include <stdint.h>
#include <string.h>
extern double original(_Bool, _Bool, _Bool, double*, double*, double);
extern double fused(_Bool, _Bool, _Bool, double*, double*, double);
static int equal(double a, double b) {
    if (isnan(a) && isnan(b)) return 1;
    uint64_t x, y;
    memcpy(&x,&a,sizeof x); memcpy(&y,&b,sizeof y);
    return x == y;
}
int main(void) {
    double vals[]={-INFINITY, INFINITY, NAN, -0.0, 0.0, -3.0, 1.0};
    for (int a=0; a<2; ++a) for (int b=0; b<2; ++b) for (int c=0; c<2; ++c)
        for (int i=0; i<7; ++i) for (int j=0; j<7; ++j) for (int k=0; k<7; ++k) {
            double *p=a ? &vals[j] : 0;
            double *q=!a && b ? &vals[k] : 0;
            if (!equal(original(a,b,c,p,q,vals[i]), fused(a,b,c,p,q,vals[i]))) return 1;
        }
    return 0;
}
"""
with tempfile.TemporaryDirectory(prefix="multi-anchor-") as temp:
    out = Path(temp)
    env = dict(os.environ, DECISION_SPECULATION="none", DECISION_CFG_CLEANUP="structural")
    env.pop("DECISION_GAP_SEARCH", None)
    result = subprocess.run([tools/"decision-fuse",fixture,"evaluate","0","0",out/"trial"],
                            env=env,capture_output=True,text=True)
    trial = json.loads((out/"trial/trial.json").read_text())
    assert result.returncode == 0, (trial, result.stderr)
    assert trial["plan"] == "complete-leaf-multi-anchor"
    assert trial["pair_join"] == "%shared" and trial["moved_leaf_instructions"] == 2
    assert len(trial["leaf_anchors"]) >= 2
    assert any(not a["left_must_execute"] and not a["right_must_execute"]
               for a in trial["leaf_anchors"])
    swapped = subprocess.check_output([tools/"multi-anchor-check",fixture],text=True)
    (out/"main.c").write_text(harness)
    (out/"original.ll").write_text(fixture.read_text().replace("@evaluate(", "@original("))
    for ir in ((out/"trial/fused.ll").read_text(), swapped):
        (out/"fused.ll").write_text(ir.replace("@evaluate(", "@fused("))
        subprocess.run([os.getenv("CLANG", "clang"),out/"main.c",out/"original.ll",
                        out/"fused.ll","-o",out/"check"],check=True)
        subprocess.run([out/"check"],check=True)
    # Give all plans the same mock TTI so the initial catalogs can be audited
    # without committing a change. Exercise both equal and different joins.
    driver = out/"driver"
    (driver/"build/decision-fuse").mkdir(parents=True)
    (driver/"build/decision-fuse/decision-fuse").symlink_to(tools/"decision-fuse")
    (driver/"tools").mkdir()
    worker = driver/"tools/run-llvm24-tti"
    worker.write_text("#!/usr/bin/env python3\nprint(" + repr(json.dumps({
        "source_revision": "6be16f356d3e", "unknown": 0,
        "cost": 100, "instruction_costs": []})) + ")\n")
    worker.chmod(0o755)
    same = out/"same-join.ll"
    same.write_text(fixture.read_text().replace(
        "third:\n  br label %exit", "third:\n  br label %shared").replace(
        "[ %ro, %rt ]", "[ %ro, %rt ], [ -0.0, %third ]").replace(
        "[ %v, %shared ], [ -0.0, %third ]", "[ %v, %shared ]"))
    env["DECISION_CHECKPOINT_MODE"] = "off"
    for name, source, local in (("local", fixture, True), ("same", same, False)):
        result = out/name
        subprocess.run([tools/"decision-greedy", source, "evaluate", driver, result],
                       env=env, check=True)
        summary = json.loads((result/"summary.json").read_text())
        pair = [a for r in summary["rounds"] for a in r["attempts"]
                if (a["left"], a["right"]) == ("evaluate:%left", "evaluate:%right")]
        assert {a["anchor_plan"] for a in pair} == {"single-anchor", "multi-anchor"}
        for attempt in pair:
            report = json.loads((Path(attempt["directory"])/"trial.json").read_text())
            assert (report["pair_join"] != report["decision_join"]) == local
            if attempt["exit_code"] == 0:
                expected = ("complete-leaf-multi-anchor" if attempt["anchor_plan"] == "multi-anchor"
                            else "native-must-execute-anchors")
                assert report["plan"] == expected
            assert {s["plan"] for s in report["pair_plan_scores"]} == {
                "single-anchor", "multi-anchor"}
        subprocess.run(["python3", Path(__file__).with_name("check_greedy_report.py"),
                        result/"summary.json"],check=True)
    # Gap search must retain the actual initial-plan rejection for reporting.
    order = out/"order.json"
    order.write_text("[]")
    request = out/"request.json"
    request.write_text(json.dumps({"decision":"evaluate:%entry", "left":"evaluate:%a",
                                   "right":"evaluate:%b", "anchor_plan":"multi-anchor"}))
    linear = out/"linear.ll"
    linear.write_text("""define i32 @evaluate(i1 %flag, i32 %x) {
entry: br i1 %flag, label %a, label %b
a: %l = add i32 %x, 1
   br label %exit
b: %r = add i32 %x, 2
   br label %exit
exit: %out = phi i32 [ %l, %a ], [ %r, %b ]
      ret i32 %out
}
""")
    env["DECISION_GAP_SEARCH"] = "1"
    rejected = out/"rejected"
    result = subprocess.run([tools/"decision-fuse",linear,"evaluate","0","0",rejected,
                             order,request],env=env,capture_output=True,text=True)
    assert result.returncode != 0
    report = json.loads((rejected/"trial.json").read_text())
    assert report["reason"] == "multi_anchor_requires_se_se_arm"
print("Multi-anchor and swapped catalog: 2744 CPU cases each, including NaN, infinities and signed zeros")
