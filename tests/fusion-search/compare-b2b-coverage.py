#!/usr/bin/env python3
"""Compare legacy and planned B2B on small, deterministic coverage fixtures."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile

search, worker, opt = sys.argv[1:]
fixtures = {
    "paired-store": """define i32 @case(i1 %p, i32 %a, i32 %b, i32 addrspace(3)* %dst) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  store i32 %a, i32 addrspace(3)* %dst, align 4
  %l = add nsw i32 %a, -1
  br label %join
right:
  store i32 %b, i32 addrspace(3)* %dst, align 4
  %r = add nsw i32 %b, -1
  br label %join
join:
  %result = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %result
}
""",
    "dependent-polynomial": """define double @case(i1 %p, double %x, double %y) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %a = fadd double %x, 1.0
  %b = fmul double %a, %a
  %c = fadd double %b, 2.0
  %d = fmul double %c, %a
  %e = fsub double %d, %y
  %l = fdiv double %e, %c
  br label %join
right:
  %f = fadd double %x, 3.0
  %g = fmul double %f, %f
  %h = fsub double %g, 4.0
  %i = fmul double %h, %f
  %j = fadd double %i, %y
  %r = fdiv double %j, %h
  br label %join
join:
  %result = phi double [ %l, %left ], [ %r, %right ]
  ret double %result
}
""",
}

with tempfile.TemporaryDirectory() as temp:
    root = Path(temp)
    for name, body in fixtures.items():
        source = root / f"{name}.ll"
        source.write_text('target triple = "amdgcn-amd-amdhsa"\n' + body +
                          '\nattributes #0 = { "target-cpu"="gfx906" }\n')
        reports = []
        for planner in ("0", "1"):
            directory = root / f"{name}-{planner}"
            fused = directory.with_suffix(".ll")
            subprocess.run([
                search, "--ir", str(source), "--function", "case",
                "--split", "B0", "--left", "B1", "--right", "B2",
                "--structural", "1", "--speculation", "cost",
                "--cleanup", "darm-cfg-dce", "--gap-trials", "4",
                "--single-branch-b2b", planner, "--tti-worker", worker,
                "--debug-dir", str(directory), "--out", str(fused),
            ], check=True)
            subprocess.run([opt, "-verify", "-disable-output", str(fused)], check=True)
            report = json.loads((directory / "trial-0/trial.json").read_text())
            assert report["valid"] and report["score_result"]["status"] == "scored"
            cost = report["score_result"]["metrics"]
            reports.append(report)
            print(name, report["merge_path"], cost["work_before"], "->", cost["work_after"])
        assert reports[0]["parent_hash"] == reports[1]["parent_hash"]
        assert reports[0]["control_hash"] == reports[1]["control_hash"]
