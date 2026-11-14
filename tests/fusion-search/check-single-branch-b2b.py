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
                    "--structural", "1", "--speculation", "cost", "--cleanup", "darm-cfg-dce",
                    "--single-branch-b2b", "1", "--tti-worker", worker]
            run(*args, "--gap-trials", "4", "--out", fused, "--debug-dir", out / "reports")
            report = out / "reports/trial-0/trial.json"
            trial = json.loads(report.read_text())
            assert trial["merge_path"] == f"single-branch-{shape.removeprefix('pure-').removeprefix('paired-')}", trial["merge_path"]
            assert trial["eligible"] == (shape != "separate"), trial["score_result"]
            assert not trial["gap_choices"] and not trial["alignment_choices"]
            raw = report.with_name("after-raw.ll").read_text()
            assert raw.count("br i1 %p") == 1 and "[ 77, %external ]" in raw
            run(opt, "-verify", "-disable-output", fused)
            run(*args, "--gap-replay", report, "--out", replay)
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
        assert bool(summary["commits"]) == (shape != "separate"), summary
        assert summary["shared_arm_trials"]
        assert any(
            "--single-branch-b2b" in json.loads(request.read_text())["argv"]
            for request in (out / "auto").glob("trial-*/request.json")
        )
