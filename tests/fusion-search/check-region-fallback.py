#!/usr/bin/env python3
"""Region catalog fallback is scored and committed in the same queue."""
import json,os,shlex,subprocess,tempfile,re
from pathlib import Path
root=Path(__file__).resolve().parents[2]
env=dict(os.environ)
env["LD_LIBRARY_PATH"]=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu")+":"+env.get("LD_LIBRARY_PATH","")
env.setdefault("LLVM24_LIBDIR",str(root/"build/llvm24-pinned/lib"))
lc=env.get("LLVM_CONFIG",str(root/"build/llvm12-jammy/usr/bin/llvm-config-12"))
def flags(*a):return shlex.split(subprocess.check_output([lc,*a],env=env,text=True))
objects=["ir_pressure","fusion_search","b2b_anchor","logical_region_state","RegionAnalyzer","RegionMelder","RegionReplicator","CFMelderUtils","InstructionMatch",
         "darm-artifact-RegionAnalyzer","darm-artifact-RegionMelder",
         "darm-artifact-RegionReplicator","darm-artifact-CFMelderUtils",
         "darm-artifact-InstructionMatch","darm-artifact-bridge"]
with tempfile.TemporaryDirectory(prefix="catalog-regions-") as d:
 p=Path(d);exe=p/"test";fixture=root/"tests/fusion-search/catalog-regions.ll"
 subprocess.run([env.get("CXX","c++"),*flags("--cxxflags"),"-std=c++17","-fexceptions","-UNDEBUG","-O1","-Wno-deprecated-declarations","-I"+str(root/"tools"),str(root/"tests/fusion-search/probe-isolated-real.cpp"),*[str(root/"build/llvm24-tti"/(x+".o")) for x in objects],*flags("--ldflags","--link-shared","--libs","--system-libs"),"-o",str(exe)],env=env,check=True)
 subprocess.run([str(exe),str(fixture),"choose",str(root/"tools/run-llvm24-tti"),str(p),"identity"],env=env,check=True)
 r=json.loads(subprocess.check_output([str(exe),str(fixture),"choose",str(root/"tools/run-llvm24-tti"),str(p),"catalog"],env=env,text=True))
 assert r["exact_step_parity"] and r["commits"]==1 and r["fallback_commits"]==1,r
 assert r["identities"][0].startswith("catalog:") and r["costs"]==[18],r
 assert r["fallback_outcomes"].get("valid:darm-R2R")==1,r
 assert r["reused_trials"]==0 and r["full_trials"]==r["cached_trials"],r
 clang=Path(subprocess.check_output([lc,"--bindir"],env=env,text=True).strip())/"clang"
 (p/"main.c").write_text('#include <stdio.h>\nextern int choose(_Bool,_Bool,int);\nint main(){for(int p=0;p<2;p++)for(int q=0;q<2;q++)for(int x=-20;x<=20;x++)for(int y=-20;y<=20;y++)printf("%d\\n",choose(p,q,x));}\n')
 def execute(path):
  ir=re.sub(r'target triple = ".*"','target triple = "x86_64-unknown-linux-gnu"',path.read_text())
  ir=ir.replace('"target-cpu"="gfx906"',"nounwind")
  (p/"cpu.ll").write_text(ir)
  subprocess.run([str(clang),"-O0",str(p/"cpu.ll"),str(p/"main.c"),"-o",str(p/"run")],env=env,check=True,capture_output=True)
  return subprocess.check_output([str(p/"run")],env=env)
 assert execute(fixture)==execute(p/"full-0.ll")==execute(p/"cached-0.ll")
 print("PASS R2R catalog candidate scored and committed; exact full/cached chain and CPU outputs")
