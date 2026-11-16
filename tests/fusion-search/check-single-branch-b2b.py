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
                    "--structural", "1", "--speculation", "cost", "--cleanup", "darm-cfg-dce",
                    "--single-branch-b2b", "1", "--tti-worker", worker]
            run(*args, "--gap-trials", "4", "--out", fused, "--debug-dir", out / "reports")
            report = out / "reports/trial-0/trial.json"
            trial = json.loads(report.read_text())
            expected = f"single-branch-{shape.removeprefix('pure-').removeprefix('paired-')}"
            if shape == "complete-common-dp":
                expected = "single-branch-separate"
            merged_exit = trial["merge_path"] == "single-branch-prefix-merged-exit"
            segmented = trial["merge_path"].startswith("single-branch-segment-dp")
            complete_common = trial["merge_path"].startswith("single-branch-complete-common-dp")
            assert (trial["merge_path"] == expected or segmented or merged_exit or
                    (shape == "pure-aligned-hoist" and complete_common) or
                    (shape.startswith("paired-") and trial["merge_path"] == "single-branch-prefix")), (shape, trial["merge_path"])
            if shape == "paired-common-dp":
                score = trial["score_result"]
                assert score["status"] == "scored", score
                assert trial["eligible"] == (score["total"] > 0 and not score["profitability_rejection"]), score
            else:
                assert trial["eligible"] == (shape not in {"separate", "complete-common-dp"}), trial["score_result"]
            assert not trial["gap_choices"] and not trial["alignment_choices"]
            raw = report.with_name("after-raw.ll").read_text()
            assert "[ 77, %external ]" in raw
            if shape == "paired-join-spec":
                assert segmented
                xor_block = r"^fusion\.%s[^\n]*:\s*[^\n]*\n(?:  .*\n)*?  .*xor i32 .*73"
                raw_block = "common" if trial["merge_path"].endswith("-speculate-arms") else "side"
                assert re.search(xor_block % raw_block, raw, re.M), raw
                cleaned = report.with_name("after.ll").read_text()
                assert re.search(xor_block % "common", cleaned, re.M), cleaned
            if shape == "paired-segment-dp":
                assert raw.count("br i1 %") == 3  # Outside edge and two protection segments.
                assert raw.count("mul i32") == 4
                assert raw.count("store i32") == 2
            elif merged_exit:
                assert raw.count("br i1 %") == 1 and "br i1 %outside" in raw
            elif not segmented and not complete_common:
                assert raw.count("br i1 %") == 2
            if shape == "paired-prefix":
                assert raw.count("store i32") == 1
                if not merged_exit:
                    assert raw.index("store i32") < raw.index("br i1 %", raw.index("split:"))
            if shape == "complete-common-dp":
                assert re.search(r"^left:[^\n]*\n  .*mul i32", raw, re.M)
                assert re.search(r"^right:[^\n]*\n  .*xor i32", raw, re.M)
            if shape == "paired-common-dp" and not segmented:
                assert "xor i32 %x, 73" in raw.split("br i1 %p")[0]
                assert raw.count("mul i32") == 3
                assert raw.count("store i32") == 3
            run(opt, "-verify", "-disable-output", fused)
            run(*args, "--gap-replay", report, "--out", replay)
            assert fused.read_bytes() == replay.read_bytes()
            if shape == "paired-resplit":
                resplit = out / "resplit.json"
                replay = out / "resplit.ll"
                for rank in ("", "-2", "-3", "-4"):
                    path = f"single-branch-segment-dp{rank}-resplit"
                    resplit.write_text(json.dumps(dict(trial, merge_path=path)))
                    cmd = [*args, "--gap-replay", resplit, "--out", replay,
                           "--debug-dir", out / "resplit"]
                    attempt = subprocess.run(list(map(str, cmd)), capture_output=True, text=True)
                    if attempt.returncode == 0:
                        break
                    assert "replay layout unavailable" in attempt.stderr, attempt.stderr
                else:
                    raise AssertionError("no resplit plan for fixture")
                resplit_report = out / "resplit/trial-0/trial.json"
                raw = resplit_report.with_name("after-raw.ll").read_text()
                assert "fusion.exit:" in raw and "[ 77, %external ]" in raw
                run(opt, "-verify", "-disable-output", replay)
                second_replay = out / "resplit-replay.ll"
                run(*args, "--gap-replay", resplit_report, "--out", second_replay)
                assert replay.read_bytes() == second_replay.read_bytes()
                fused = replay
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

    out = root / "dp2-paired-phi"
    out.mkdir()
    source = out / "input.ll"
    source.write_text(template.replace(
        "LEFT", "  %a = load i32, i32* %mem, align 4\n  %l = mul i32 %a, %x"
    ).replace(
        "RIGHT", "  %b = load i32, i32* %mem, align 8\n  %r = mul i32 %b, %x"
    ))
    args = [search, "--ir", source, "--function", "choose", "--split", "B2",
            "--left", "B3", "--right", "B4", "--structural", "1", "--speculation", "cost",
            "--cleanup", "darm-cfg-dce", "--b2b-strategy", "dp2", "--tti-worker", worker]
    run(*args, "--out", out / "winner.ll", "--debug-dir", out / "report")
    trial = json.loads((out / "report/trial-0/trial.json").read_text())
    for rank in range(1, 13):
        replay = out / "request.json"
        replay.write_text(json.dumps(dict(trial, merge_path=f"single-branch-dp2-{rank}")))
        cmd = [*args, "--gap-replay", replay, "--out", out / f"replay-{rank}.ll",
               "--debug-dir", out / f"replay-{rank}"]
        result = subprocess.run(list(map(str, cmd)), capture_output=True, text=True)
        if result.returncode:
            assert "replay layout unavailable" in result.stderr, result.stderr
            continue
        raw = (out / f"replay-{rank}/trial-0/after-raw.ll").read_text()
        if raw.count("load i32") == 2 and raw.count("mul i32") == 1:
            break
    else:
        raise AssertionError("no paired-PHI plan was generated")
    common = raw.split("fusion.common:", 1)[1].split("\n\n", 1)[0]
    assert common.count("phi i32") == 1 and "poison" not in common, common
    assert "[ 77, %external ]" in raw
    run(opt, "-verify", "-disable-output", out / f"replay-{rank}.ll")

    # Leave the mismatched loads at the ends of the two guarded arms.
    source = out / "exit-input.ll"
    source.write_text(template.replace("LEFT", "  %l = load i32, i32* %mem, align 4")
                      .replace("RIGHT", "  %r = load i32, i32* %mem, align 8"))
    args[2] = source
    run(*args, "--out", out / "exit-winner.ll", "--debug-dir", out / "exit-report")
    trial = json.loads((out / "exit-report/trial-0/trial.json").read_text())
    assert trial["merge_path"].endswith("-direct")
    rank = int(trial["merge_path"].split("-")[3])
    request = out / "exit-close.json"
    request.write_text(json.dumps(dict(trial, merge_path=f"single-branch-dp2-{rank + 1}-close")))
    run(*args, "--gap-replay", request, "--out", out / "exit-close.ll",
        "--debug-dir", out / "exit-close-report")
    raw = (out / "exit-close-report/trial-0/after-raw.ll").read_text()
    common = raw.split("fusion.common:", 1)[1].split("\n\n", 1)[0]
    assert common.count("phi i32") == 1 and "poison" not in raw, raw
    assert "[ 77, %external ]" in raw
    run(opt, "-verify", "-disable-output", out / "exit-close.ll")

    # A condition frozen by an earlier transform must remain the single
    # decision for the shared instructions and the replacement edges.
    out = root / "dp2-existing-freeze"
    out.mkdir()
    source = out / "input.ll"
    left, right = cases["paired-prefix"]
    source.write_text(template.replace("LEFT", left).replace("RIGHT", right).replace(
        "  br i1 %p,", "  %stable = freeze i1 %p\n  br i1 %stable,"))
    args = [search, "--ir", source, "--function", "choose", "--split", "B2",
            "--left", "B3", "--right", "B4", "--structural", "1", "--speculation", "cost",
            "--cleanup", "darm-cfg-dce", "--b2b-strategy", "dp2", "--tti-worker", worker]
    run(*args, "--out", out / "winner.ll", "--debug-dir", out / "report")
    report = out / "report/trial-0/trial.json"
    raw = report.with_name("after-raw.ll").read_text()
    assert raw.count("freeze i1") == 1 and "%stable = freeze i1 %p" in raw
    assert "select i1 %stable," in raw and "[ 77, %external ]" in raw
    run(opt, "-verify", "-disable-output", out / "winner.ll")
    run(*args, "--gap-replay", report, "--out", out / "replay.ll")
    assert (out / "winner.ll").read_bytes() == (out / "replay.ll").read_bytes()

    # DP2 has a different search budget and may choose a different legal
    # layout. Exercise every fixture in both orientations through its CLI.
    for shape in cases:
        for swapped in (False, True):
            out = root / f"{shape}-{int(swapped)}"
            source = out / "source.ll"
            fused, replay = out / "dp2.ll", out / "dp2-replay.ll"
            args = [search, "--ir", source, "--function", "choose", "--split", "B2",
                    "--left", "B4" if swapped else "B3", "--right", "B3" if swapped else "B4",
                    "--structural", "1", "--speculation", "cost", "--cleanup", "darm-cfg-dce",
                    "--b2b-strategy", "dp2", "--tti-worker", worker]
            run(*args, "--out", fused, "--debug-dir", out / "dp2-report")
            report = out / "dp2-report/trial-0/trial.json"
            trial = json.loads(report.read_text())
            assert trial["merge_path"].startswith("single-branch-dp2-"), trial["merge_path"]
            layouts = trial["layout_profitability"]
            selected, = (row for row in layouts if row["layout"] == trial["merge_path"])
            assert selected["eligible"] == trial["eligible"]
            if any(row["eligible"] for row in layouts):
                assert selected["eligible"]
            for row in layouts:
                if row["total_gain"] is not None:
                    assert row["total_gain"] == row["work_gain"] + row["cfg_phi_gain"]

            raw = report.with_name("after-raw.ll").read_text()
            assert "[ 77, %external ]" in raw
            assert raw.count("freeze i1") == 1
            if shape == "separate":
                assert "fusion.side:" in raw
                assert trial["merge_path"].endswith("-direct")
            if shape == "paired-prefix":
                assert raw.count("br i1") == 1
                assert raw.count("store i32") == 1
                rank = int(trial["merge_path"].rsplit("-", 1)[1])
                resplit_request = out / "dp2-resplit.json"
                resplit_request.write_text(json.dumps(dict(
                    trial, merge_path=f"single-branch-dp2-{rank + 1}-resplit")))
                run(*args, "--gap-replay", resplit_request, "--out", out / "dp2-resplit.ll",
                    "--debug-dir", out / "dp2-resplit-report")
                resplit_raw = (out / "dp2-resplit-report/trial-0/after-raw.ll").read_text()
                assert "fusion.exit:" in resplit_raw and "[ 77, %external ]" in resplit_raw
                run(opt, "-verify", "-disable-output", out / "dp2-resplit.ll")

            run(opt, "-verify", "-disable-output", fused)
            run(*args, "--gap-replay", report, "--out", replay)
            assert fused.read_bytes() == replay.read_bytes()

            programs = [fused]
            if shape == "separate":
                rank = int(trial["merge_path"].split("-")[3])
                close_request = out / "dp2-close.json"
                close_request.write_text(json.dumps(dict(
                    trial, merge_path=f"single-branch-dp2-{rank + 1}-close")))
                close = out / "dp2-close.ll"
                run(*args, "--gap-replay", close_request, "--out", close,
                    "--debug-dir", out / "dp2-close-report")
                close_report = out / "dp2-close-report/trial-0/trial.json"
                close_raw = close_report.with_name("after-raw.ll").read_text()
                assert "fusion.common:" in close_raw and "[ 77, %external ]" in close_raw
                assert "poison" not in close_raw
                run(opt, "-verify", "-disable-output", close)
                repeat = out / "dp2-close-replay.ll"
                run(*args, "--gap-replay", close_report, "--out", repeat)
                assert close.read_bytes() == repeat.read_bytes()
                programs.append(close)
            if shape == "paired-prefix":
                programs.append(out / "dp2-resplit.ll")
            # The original object was compiled during the DP1 pass above.
            guard = "if (outside)" if shape.startswith("paired-") else "if (outside || p)"
            (root / "check.c").write_text(driver.replace("if (outside || p)", guard))
            for program in programs:
                cpu = out / "dp2-cpu.ll"
                ir = program.read_text().replace("amdgcn-amd-amdhsa", "x86_64-unknown-linux-gnu")
                ir = re.sub(r"^attributes #0 = .*\n", "", ir, flags=re.M)
                cpu.write_text(ir.replace(" #0 {", " {").replace("@choose(", "@after("))
                run(clang, "-O2", "-c", cpu, "-o", out / "dp2.o")
                run(clang, out / "before.o", out / "dp2.o", root / "check.c", "-o", out / "check-dp2")
                run(out / "check-dp2")


    for shape in cases:
        out = root / f"{shape}-0"
        run(greedy, out / "source.ll", "choose", out / "auto")
        summary = json.loads((out / "auto/summary.json").read_text())
        assert summary["shared_arm_trials"] and summary["b2b_strategy"] == "dp1"
        assert summary["pipeline_version"] == "v1"
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

    # DP3 can emit a segmented finalist beyond DP1's fourth slot. Check
    # replay, the exit PHI with its external edge, and memory on both arms.
    out = root / "paired-segment-dp-0"
    source = out / "source.ll"
    args = [search, "--ir", source, "--function", "choose", "--split", "B2",
            "--left", "B3", "--right", "B4", "--structural", "1", "--speculation", "cost",
            "--cleanup", "darm-cfg-dce", "--b2b-strategy", "dp3", "--tti-worker", worker]
    run(*args, "--out", out / "dp3.ll", "--debug-dir", out / "dp3-report")
    trial = json.loads((out / "dp3-report/trial-0/trial.json").read_text())
    request = out / "dp3-fifth.json"
    request.write_text(json.dumps(dict(trial, merge_path="single-branch-dp3-segment-5")))
    fifth, repeat = out / "dp3-fifth.ll", out / "dp3-fifth-replay.ll"
    run(*args, "--gap-replay", request, "--out", fifth, "--debug-dir", out / "dp3-fifth-report")
    report = out / "dp3-fifth-report/trial-0/trial.json"
    run(*args, "--gap-replay", report, "--out", repeat)
    assert fifth.read_bytes() == repeat.read_bytes()
    raw = report.with_name("after-raw.ll")
    assert "[ 77, %external ]" in raw.read_text()
    for program in (raw, fifth):
        run(opt, "-verify", "-disable-output", program)
    cpu = out / "dp3-cpu.ll"
    ir = fifth.read_text().replace("amdgcn-amd-amdhsa", "x86_64-unknown-linux-gnu")
    ir = re.sub(r"^attributes #0 = .*\n", "", ir, flags=re.M)
    cpu.write_text(ir.replace(" #0 {", " {").replace("@choose(", "@after("))
    (root / "check.c").write_text(driver.replace("if (outside || p)", "if (outside)"))
    run(clang, "-O2", "-c", cpu, "-o", out / "dp3.o")
    run(clang, out / "before.o", out / "dp3.o", root / "check.c", "-o", out / "check-dp3")
    run(out / "check-dp3")
    rejected = subprocess.run([greedy, source, "choose", out / "auto-dp3",
                               "--b2b-strategy", "dp3"], capture_output=True, text=True)
    assert rejected.returncode != 0 and "invalid value" in rejected.stderr
    run(greedy, source, "choose", out / "auto-darm", "--b2b-strategy", "darm")
    summary = json.loads((out / "auto-darm/summary.json").read_text())
    assert summary["b2b_strategy"] == "darm"
    trials = [json.loads(path.read_text()) for path in
              (out / "auto-darm").glob("trial-*/structural/trial-0/trial.json")]
    assert any(trial["merge_path"] in {"darm-B2B", "darm-adjacent-B2B"} for trial in trials)
    run(opt, "-verify", "-disable-output", out / "auto-darm/final.ll")

    # Preserve a conditional exit with a live value while sharing arm work.
    out = root / "independent-exits"
    out.mkdir()
    left, right = cases["paired-segment-dp"]
    source = out / "source.ll"
    ir = template.replace("LEFT", left).replace("RIGHT", right)
    ir = ir.replace("right:\n" + right + "\n  br label %join",
                    "right:\n" + right + "\n  %leave = icmp eq i32 %x, 0"
                    "\n  br i1 %leave, label %other, label %join\n"
                    "other:\n  ret i32 %r")
    source.write_text(ir)
    args = [search, "--ir", source, "--function", "choose", "--split", "B2",
            "--left", "B3", "--right", "B4", "--structural", "1", "--speculation", "cost",
            "--b2b-strategy", "dp1", "--cleanup", "darm-cfg-dce", "--tti-worker", worker]
    run(*args, "--out", out / "winner.ll", "--debug-dir", out / "winner")
    trial = json.loads((out / "winner/trial-0/trial.json").read_text())
    request = out / "segment.json"
    request.write_text(json.dumps(dict(trial, merge_path="single-branch-segment-dp")))
    run(*args, "--gap-replay", request, "--out", out / "fused.ll", "--debug-dir", out / "segment")
    raw = out / "segment/trial-0/after-raw.ll"
    assert re.search(r"br i1 .*label %other, label %join", raw.read_text())
    run(opt, "-verify", "-disable-output", raw)
    run(opt, "-verify", "-disable-output", out / "fused.ll")
    (root / "check.c").write_text(driver.replace("if (outside || p)", "if (outside)"))
    for variant, path in (("before", source), ("after", out / "fused.ll")):
        cpu = out / f"{variant}.ll"
        text = path.read_text().replace("amdgcn-amd-amdhsa", "x86_64-unknown-linux-gnu")
        text = re.sub(r"^attributes #0 = .*\n", "", text, flags=re.M)
        cpu.write_text(text.replace(" #0 {", " {").replace("@choose(", f"@{variant}("))
        run(clang, "-O2", "-c", cpu, "-o", cpu.with_suffix(".o"))
    run(clang, out / "before.o", out / "after.o", root / "check.c", "-o", out / "check")
    run(out / "check")
