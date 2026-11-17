#!/usr/bin/env python3
"""Check single-branch B2B plans through the explicit LLVM24 entry point."""
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

search, worker, opt, clang, greedy = map(Path, sys.argv[1:])
template = '''target triple = "amdgcn-amd-amdhsa"
define i32 @choose(i1 %outside, i1 %p, i32 %x, i32 %y, i32* %mem) #0 {
entry:
  br i1 %outside, label %external, label %split
external:
  br label %join
split:
  br i1 %p, label %left, label %right
left:
LEFT
  br label %join
right:
RIGHT
  br label %join
join:
  %result = phi i32 [ %l, %left ], [ %r, %right ], [ 77, %external ]
  ret i32 %result
}
attributes #0 = { "target-cpu"="gfx906" }
'''
cases = {
    "pure-aligned-hoist": (
        "  %a = xor i32 %x, 73\n  %lm = mul i32 %x, %y\n  %l = add i32 %a, %lm",
        "  %b = or i32 %x, 19\n  %rm = mul i32 %x, %y\n  %r = xor i32 %b, %rm",
    ),
    "paired-aligned-hoist": (
        "  %a = load i32, i32* %mem, align 4\n  %lm = mul i32 %x, %y\n  %l = add i32 %a, %lm",
        "  %b = load i32, i32* %mem, align 4\n  %rm = mul i32 %x, %y\n"
        "  %r = xor i32 %b, %rm\n  store i32 %r, i32* %mem, align 4",
    ),
    "prefix": (
        "  %l = mul i32 %x, %y",
        "  %r = mul i32 %x, %y\n  store i32 %r, i32* %mem, align 4",
    ),
    "suffix": (
        "  %lv = add i32 %x, 7\n  %lm = mul i32 %lv, %y\n"
        "  %l = mul i32 %lm, %x",
        "  %rv = load i32, i32* %mem, align 4\n  %rm = mul i32 %rv, %y\n"
        "  %r = mul i32 %rm, %x",
    ),
    "aligned-hoist": (
        "  %a = xor i32 %x, 73\n  %lm = mul i32 %x, %y\n"
        "  %l = add i32 %a, %lm",
        "  %b = load i32, i32* %mem, align 4\n  %rm = mul i32 %x, %y\n"
        "  %r = xor i32 %b, %rm\n  store i32 %r, i32* %mem, align 4",
    ),
    "join-dp": (
        "  %lv = add i32 %x, 7\n  %lm = mul i32 %lv, %y\n"
        "  %l = mul i32 %lm, %x",
        "  %rv = load i32, i32* %mem, align 4\n  %rm = mul i32 %rv, %y\n"
        "  store i32 %rv, i32* %mem, align 4\n  %r = mul i32 %rm, %x",
    ),
    "prefix-join-dp": (
        "  %lp = mul i32 %x, %y\n  %lv = add i32 %lp, 7\n"
        "  %lm = mul i32 %lv, %y\n  %l = mul i32 %lm, %x",
        "  %rp = mul i32 %x, %y\n  %loaded = load i32, i32* %mem, align 4\n"
        "  %rv = xor i32 %loaded, %rp\n  %rm = mul i32 %rv, %y\n"
        "  store i32 %rv, i32* %mem, align 4\n  %r = mul i32 %rm, %x",
    ),
    "paired-prefix": (
        "  %l = mul i32 %x, %y\n  store i32 %l, i32* %mem, align 4",
        "  %r = mul i32 %x, %x\n  store i32 %r, i32* %mem, align 4",
    ),
    "paired-common-dp": (
        "  %a = xor i32 %x, 73\n  store i32 %a, i32* %mem, align 4\n"
        "  %lm = mul i32 %a, %y\n  %ln = mul i32 %lm, %y\n"
        "  %l = mul i32 %ln, %y\n  store i32 %l, i32* %mem, align 4",
        "  %rm = mul i32 %x, %y\n  %rn = mul i32 %rm, %y\n"
        "  %r = mul i32 %rn, %y\n  store i32 %r, i32* %mem, align 4",
    ),
    "paired-segment-dp": (
        "  store i32 %x, i32* %mem, align 4\n"
        "  %a = load i32, i32* %mem, align 4\n"
        "  %lm = mul i32 %a, %y\n  %ln = mul i32 %lm, %y\n"
        "  %lo = mul i32 %ln, %x\n  %l = mul i32 %lo, %y\n  store i32 %l, i32* %mem, align 4",
        "  %b = load i32, i32* %mem, align 4\n"
        "  %rm = mul i32 %b, %y\n  %rn = mul i32 %rm, %y\n"
        "  %ro = mul i32 %rn, %x\n  %r = mul i32 %ro, %y",
    ),
    "paired-join-spec": (
        "  store i32 %x, i32* %mem, align 4\n"
        "  %a = load i32, i32* %mem, align 4\n"
        "  %odd = xor i32 %a, 73\n  %lm = mul i32 %odd, %y\n  %ln = mul i32 %lm, %y\n"
        "  %lo = mul i32 %ln, %x\n  %l = mul i32 %lo, %y\n  store i32 %l, i32* %mem, align 4",
        "  %b = load i32, i32* %mem, align 4\n"
        "  %rm = mul i32 %b, %y\n  %rn = mul i32 %rm, %y\n"
        "  %ro = mul i32 %rn, %x\n  %r = mul i32 %ro, %y",
    ),
    "paired-resplit": (
        "  store i32 %x, i32* %mem, align 4\n"
        "  %a = load i32, i32* %mem, align 4\n"
        "  %odd = xor i32 %a, 73\n  %lm = mul i32 %odd, %y\n  %ln = mul i32 %lm, %y\n"
        "  %lo = mul i32 %ln, %x\n  %lt = mul i32 %lo, %y\n  store i32 %lt, i32* %mem, align 4\n  %l = mul i32 %lt, %x",
        "  %b = load i32, i32* %mem, align 4\n"
        "  %rm = mul i32 %b, %y\n  %rn = mul i32 %rm, %y\n"
        "  %ro = mul i32 %rn, %x\n  %rt = mul i32 %ro, %y\n  %r = mul i32 %rt, %x",
    ),
    "complete-common-dp": (
        "  %l = mul i32 %x, %y",
        "  %r = xor i32 %x, %y",
    ),
    "separate": (
        "  %l = add i32 %x, 7",
        "  %r = xor i32 %x, %y\n  store i32 %r, i32* %mem, align 4",
    ),
}
driver = '''
#include <stdint.h>
extern int32_t before(_Bool, _Bool, int32_t, int32_t, int32_t*);
extern int32_t after(_Bool, _Bool, int32_t, int32_t, int32_t*);
int main(void) {
  for (int outside = 0; outside < 2; ++outside)
    for (int p = 0; p < 2; ++p)
      for (int x = -20; x <= 20; ++x)
        for (int y = -5; y <= 5; ++y) {
          int32_t a = 37, b = a;
          if (before(outside, p, x, y, &a) != after(outside, p, x, y, &b) || a != b)
            return 1;
          if (outside || p)
            if (before(outside, p, x, y, 0) != after(outside, p, x, y, 0))
              return 2;
        }
  return 0;
}
'''


def run(*args):
    subprocess.run(list(map(str, args)), check=True)


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    for shape, (left, right) in cases.items():
        null_guard = "if (outside)" if shape.startswith("paired-") else "if (outside || p)"
        (root / "check.c").write_text(driver.replace("if (outside || p)", null_guard))
        for swapped in (False, True):
            out = root / f"{shape}-{int(swapped)}"
            out.mkdir()
            source, fused, replay = (out / f"{name}.ll" for name in ("source", "fused", "replay"))
            source.write_text(template.replace("LEFT", left).replace("RIGHT", right))
            args = [search, "--ir", source, "--function", "choose", "--split", "B2",
                    "--left", "B4" if swapped else "B3", "--right", "B3" if swapped else "B4",
                    "--structural", "1", "--cleanup", "darm-cfg-dce-instcombine",
                    "--b2b-strategy", "dp1", "--tti-worker", worker]
            run(*args, "--out", fused, "--debug-dir", out / "reports")
            report = out / "reports/trial-0/trial.json"
            trial = json.loads(report.read_text())
            assert trial["merge_path"].startswith("single-branch-"), trial["merge_path"]
            assert trial["valid"]
            assert trial["score_result"]["status"] == "scored"
            merged_exit = trial["merge_path"] == "single-branch-prefix-merged-exit"
            segmented = trial["merge_path"].startswith("single-branch-segment-dp")
            complete_common = trial["merge_path"].startswith("single-branch-complete-common-dp")
            raw = report.with_name("after-raw.ll").read_text()
            assert "[ 77, %external ]" in raw
            # Shared memory must preserve the external incoming edge and execute correctly.
            if shape == "paired-prefix":
                assert raw.count("store i32") == 1
            if shape == "paired-segment-dp":
                assert raw.count("mul i32") == 4
                assert raw.count("store i32") == 2
            run(opt, "-verify", "-disable-output", fused)
            run(*args, "--out", replay)
            assert fused.read_bytes() == replay.read_bytes()
            for variant, path in (("before", source), ("after", fused)):
                cpu = out / f"{variant}.ll"
                text = path.read_text().replace("amdgcn-amd-amdhsa", "x86_64-unknown-linux-gnu")
                text = re.sub(r"^attributes #0 = .*\n", "", text, flags=re.M)
                cpu.write_text(text.replace(" #0 {", " {").replace("@choose(", f"@{variant}("))
                run(clang, "-O2", "-c", cpu, "-o", cpu.with_suffix(".o"))
            run(clang, out / "before.o", out / "after.o", root / "check.c", "-o", out / "check")
            run(out / "check")
            score = trial["score_result"]["metrics"]
            print(shape, swapped, score["work_before"], "->", score["work_after"])

    for shape in cases:
        out = root / f"{shape}-0"
        run(greedy, out / "source.ll", "choose", out / "auto")
        summary = json.loads((out / "auto/summary.json").read_text())
        assert summary["shared_arm_trials"] and summary["b2b_strategy"] == "dp1"
        assert summary["pipeline_version"] == "v1"
        assert summary["candidate_scheduler"] == "continuous-queue"
        assert summary["persistent_trial_workers"]
        assert not any(a.get("queue_recovery") for r in summary["rounds"] for a in r["attempts"])
        assert summary["condition_budget"] == 4 and summary["phi_fold_threshold"] == 7
        assert summary["structural_cleanup"] == "darm-cfg-dce-instcombine"
        for request in (out / "auto").glob("trial-*/request.json"):
            argv = json.loads(request.read_text())["argv"]
            assert "--speculation" not in argv
            assert "--gap-trials" not in argv
        if shape == "prefix":
            assert summary["commits"] > 0, summary
        final_ir = out / "auto/final.ll"
        run(opt, "-verify", "-disable-output", final_ir)
        null_guard = "if (outside)" if shape.startswith("paired-") else "if (outside || p)"
        (root / "check.c").write_text(driver.replace("if (outside || p)", null_guard))
        cpu = out / "auto-cpu.ll"
        ir = final_ir.read_text().replace("amdgcn-amd-amdhsa", "x86_64-unknown-linux-gnu")
        ir = re.sub(r"^attributes #0 = .*\n", "", ir, flags=re.M)
        cpu.write_text(ir.replace(" #0 {", " {").replace("@choose(", "@after("))
        run(clang, "-O2", "-c", cpu, "-o", out / "auto.o")
        run(clang, out / "before.o", out / "auto.o", root / "check.c", "-o", out / "check-auto")
        run(out / "check-auto")

    # Experimental strategies and transformations must not be accepted by v1.
    source = root / "prefix-0/source.ll"
    for option, value in (("--b2b-strategy", "dp2"), ("--b2b-strategy", "dp3"),
                          ("--speculation", "cost"), ("--gap-trials", "4"),
                          ("--gap-replay", "unused"), ("--b2r-strategy", "guarded"),
                          ("--cleanup", "o3"), ("--profile-bundle", "unused")):
        rejected = subprocess.run([str(search), "--ir", str(source), "--function", "choose",
                                   "--out", str(root / "rejected.ll"), option, value],
                                  capture_output=True, text=True)
        assert rejected.returncode == 2, (option, rejected.stderr)
    print("v1 B2B verifier, determinism, CPU outputs/memory and removed-option checks passed")
