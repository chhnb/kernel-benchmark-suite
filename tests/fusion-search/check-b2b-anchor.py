#!/usr/bin/env python3
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile


search, worker, opt = map(Path, sys.argv[1:])
fixtures = Path(__file__).parent / "b2b-anchor"
cases = (
    ("vllm-7", "quant", "B2", "B1", 25),
    ("HLLD", "HLLD", "B1", "B2", 146),
    ("MapAiry", "MapAiry", "B1", "B2", 347),
    ("Tigre4", "Tigre4", "B1", "B2", 91),
    ("no-phi", "diamond", "B1", "B2", 10),
)

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    for name, fn, left, right, historical_tti in cases:
        debug = root / name
        result = debug.with_suffix(".ll")
        subprocess.run(
            [search, "--ir", fixtures / f"{name}.ll", "--function", fn,
             "--split", "B0", "--left", left, "--right", right,
             "--b2b-strategy", "anchor", "--tti-worker", worker,
             "--out", result, "--debug-dir", debug],
            check=True,
        )
        subprocess.run([opt, "-verify", "-disable-output", result], check=True)
        trial = debug / "trial-0"
        report = json.loads((trial / "trial.json").read_text())
        assert report["valid"] and report["score_result"]["status"] == "scored"
        score = report["score_result"]["metrics"]["work_after"]
        stats = report["anchor"]
        assert 1 <= stats["unique_normalized"] <= stats["generated"] <= 9
        assert stats["conflicts"] == 0
        if name == "no-phi":
            assert stats["anchors"] == 0 and stats["segments"] == 1
        if name == "HLLD":
            emissions = [row["anchor"]["emission"] for row in report["layout_profitability"]]
            assert stats["emission"] == "before-split"
            assert emissions.index("before-split") < emissions.index("merged-exit")
        if name == "vllm-7":
            assert stats["mode"] == "relaxed"
            assert any(
                {cutoff["left"], cutoff["right"]} == {"%s108", "%s112"}
                for row in report["layout_profitability"]
                if row["anchor"]["mode"] == "strict"
                for cutoff in row["anchor"]["cutoffs"]
            )
        if name == "Tigre4":
            assert any(
                {cutoff["left"], cutoff["right"]} == {"%add494", "%add508"}
                for row in report["layout_profitability"]
                if row["anchor"]["mode"] == "strict"
                for cutoff in row["anchor"]["forward_cutoffs"]
            )
        assert score <= historical_tti, (name, score)
        if name == "vllm-7":
            assert score == historical_tti
            text = result.read_text()
            local = text.split("%upper = fcmp", 1)[1]
            assert len(re.findall(r" = select ", local)) == 9
            assert len(re.findall(r" = fcmp ", local)) == 4
            assert len(re.findall(r"call float @llvm\.copysign", local)) == 1
            assert not re.search(r"select i1 [^\n,]+, i1 ", local)
            assert "float 3.500000e+00, float 1.750000e+00" in local
            assert "float 5.000000e+00, float 1.250000e+00" in local
        print(name, historical_tti, "->", score)


    # Query both target models on a kernel argument and a work-item ID.
    for triple, calling_conv, intrinsic in (
        ("amdgcn-amd-amdhsa", "amdgpu_kernel", "llvm.amdgcn.workitem.id.x"),
        ("nvptx64-nvidia-cuda", "ptx_kernel", "llvm.nvvm.read.ptx.sreg.tid.x"),
    ):
        for classification, value in (("uniform", "%arg"), ("divergent", "%tid")):
            source = root / f"{triple}-{classification}.ll"
            result = source.with_suffix(".json")
            source.write_text(f"""target triple = "{triple}"
declare i32 @{intrinsic}()
define {calling_conv} void @kernel(i32 %arg) {{
entry:
  %tid = call i32 @{intrinsic}()
  %cond = icmp eq i32 {value}, 0
  br i1 %cond, label %left, label %right
left:
  ret void
right:
  ret void
}}
""")
            subprocess.run([search, "--ir", source, "--function", "kernel", "--split", "B0",
                            "--anchor-condition-only", "1", "--out", result], check=True)
            report = json.loads(result.read_text())
            assert report["classification"] == classification, report
            assert (intrinsic in report["sources"]) == (classification == "divergent"), report

    source = root / "unsupported-target.ll"
    source.write_text('target triple = "x86_64-unknown-linux-gnu"\n' +
                      'define void @kernel(i1 %p) { entry: br i1 %p, label %l, label %r '
                      'l: ret void r: ret void }\n')
    result = source.with_suffix(".json")
    subprocess.run([search, "--ir", source, "--function", "kernel", "--split", "B0",
                    "--anchor-condition-only", "1", "--out", result], check=True)
    assert json.loads(result.read_text())["classification"] == "unknown"

    # A uniform AMDGPU kernel argument keeps the fork even when linear is
    # requested. The gate does not change the unrestricted linear entry point.
    source = root / "uniform-diamond.ll"
    source.write_text("""target triple = "amdgcn-amd-amdhsa"
define amdgpu_kernel void @kernel(i1 %flag, i32 %x, i32 addrspace(1)* %out) #0 {
entry:
  br i1 %flag, label %l, label %r
l:
  %a = add i32 %x, 1
  br label %join
r:
  %b = xor i32 %x, 7
  br label %join
join:
  %v = phi i32 [ %a, %l ], [ %b, %r ]
  store i32 %v, i32 addrspace(1)* %out
  ret void
}
attributes #0 = { "target-cpu"="gfx906" }
""")
    for requirement in ("any", "divergent", "divergent-or-unknown"):
        report = root / ("uniform-" + requirement)
        subprocess.run([search, "--ir", source, "--function", "kernel",
                        "--split", "B0", "--left", "B1", "--right", "B2",
                        "--anchor-gap", "linear", "--anchor-linear-require", requirement,
                        "--tti-worker", worker, "--debug-dir", report,
                        "--out", report.with_suffix(".ll")], check=True)
        trial = json.loads((report / "trial-0/trial.json").read_text())
        assert (trial["anchor"]["emission"] == "linear") == (requirement == "any"), trial["anchor"]


def check_wave(root, worker_input, shape, expression, expected, nvptx=False):
    triple = "nvptx64-nvidia-cuda" if nvptx else "amdgcn-amd-amdhsa"
    tid = "llvm.nvvm.read.ptx.sreg.tid.x" if nvptx else "llvm.amdgcn.workitem.id.x"
    cpu = "sm_70" if nvptx else "gfx906"
    worker_input.write_text(f'''
target triple = "{triple}"
declare i32 @{tid}()
define void @wave(i32* %input) #0 {{
entry:
  %x = call i32 @{tid}(), !range !0
  {expression}
  br i1 %cond, label %yes, label %no
yes:
  ret void
no:
  ret void
}}
attributes #0 = {{ "target-cpu"="{cpu}" "amdgpu-flat-work-group-size"="1,256" }}
!0 = !{{i32 0, i32 256}}
''')
    report = root / "wave.json"
    report.unlink(missing_ok=True)
    command = [search, "--ir", worker_input, "--function", "wave", "--split", "B0",
               "--anchor-condition-only", "1", "--out", report]
    if shape:
        command += ["--anchor-wave-shape", shape]
    subprocess.run(command, check=True)
    wave = json.loads(report.read_text())["wave"]
    assert (wave["classification"], wave["mixed_waves"], wave["total_waves"]) == expected, wave


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    source = root / "wave.ll"
    threshold8 = "%cond = icmp ult i32 %x, 8"
    threshold64 = "%cond = icmp ult i32 %x, 64"
    check_wave(root, source, "16,1,1", threshold8, ("must-diverge", 1, 1))
    check_wave(root, source, "256,1,1", threshold8, ("mixed", 1, 4))
    check_wave(root, source, "16,4,1", "%cond = icmp eq i32 %x, 0", ("must-diverge", 1, 1))
    check_wave(root, source, "128,1,1", threshold64, ("must-uniform", 0, 2))
    check_wave(root, source, "96,2,1", threshold64, ("mixed", 2, 3))
    check_wave(root, source, None, threshold8, ("unknown", None, None))
    check_wave(root, source, "16,1,1",
               "%v = load i32, i32* %input\n  %cond = icmp ult i32 %v, 8",
               ("unknown", None, 1))
    check_wave(root, source, "64,1,1", "%cond = icmp ult i32 %x, 32",
               ("must-uniform", 0, 2), nvptx=True)
