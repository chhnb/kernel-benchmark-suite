#!/usr/bin/env python3
"""Exercise the IR-only worker and machine prefilter without GPU launches."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


root = Path(__file__).resolve().parents[2]
source = """
target triple = "amdgcn-amd-amdhsa"

define amdgpu_kernel void @sample(i32 addrspace(1)* %output) #0 {
entry:
  %lane = call i32 @llvm.amdgcn.workitem.id.x()
  br label %loop
loop:
  %iv = phi i32 [ 0, %entry ], [ %next, %loop ]
  %value = add i32 %lane, %iv
  EXTRA
  %ptr = getelementptr i32, i32 addrspace(1)* %output, i32 %lane
  store volatile i32 RESULT, i32 addrspace(1)* %ptr
  %next = add nuw i32 %iv, 1
  %more = icmp ult i32 %next, 4
  br i1 %more, label %loop, label %exit, !llvm.loop !0
exit:
  ret void
}
declare i32 @llvm.amdgcn.workitem.id.x()
attributes #0 = { "target-cpu"="gfx906" }
!0 = distinct !{!0, !1}
!1 = !{!"llvm.loop.unroll.disable"}
"""

with tempfile.TemporaryDirectory() as directory:
    directory = Path(directory)
    parent, candidate = directory / "parent.ll", directory / "candidate.ll"
    parent.write_text(source.replace("EXTRA", "%masked = xor i32 %value, 117")
                      .replace("RESULT", "%masked"))
    candidate.write_text(source.replace("EXTRA", "").replace("RESULT", "%value"))
    report = json.loads(subprocess.check_output(
        [sys.executable, root / "tools/accept_rule.py", parent, candidate, "sample",
         "--rule", "all", "--tti-accepted", "0", "--tti-loss", "129",
         "--cache", directory / "cache"],
        env=os.environ | {"FUSION_TTI_COST_KIND": "throughput"},
        text=True,
    ))
    decisions = report["decisions"]
    assert not decisions["tti"]["accepted"]
    assert decisions["RIR"]["accepted"], report
    assert decisions["R"]["reason"] == decisions["RB"]["reason"] == "throughput_prefilter"
    assert "machine" not in report
    for state in report["ir"].values():
        assert state["ir"]["global"] == 4 and state["ir"]["trip_counts"], state
        assert state["ir"]["vgpr_peak"] > 0 and state["compile_seconds"] == 0

print("PASS static acceptance IR and machine prefilter")
