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
print("Multi-anchor and swapped catalog: 2744 CPU cases each, including NaN, infinities and signed zeros")
