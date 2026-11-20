#!/usr/bin/env python3
"""Whole-function fallback competes before local candidates; exact-parent epochs."""
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
with tempfile.TemporaryDirectory(prefix="hybrid-priority-") as d:
 p=Path(d);exe=p/"test";fixture=root/"tests/fusion-search/hybrid-priority.ll"
 subprocess.run([env.get("CXX","c++"),*flags("--cxxflags"),"-std=c++17","-fexceptions","-UNDEBUG","-O1","-Wno-deprecated-declarations","-I"+str(root/"tools"),str(root/"tests/fusion-search/probe-isolated-real.cpp"),*[str(root/"build/llvm24-tti"/(x+".o")) for x in objects],*flags("--ldflags","--link-shared","--libs","--system-libs"),"-o",str(exe)],env=env,check=True)
 r=json.loads(subprocess.check_output([str(exe),str(fixture),"f",str(root/"tools/run-llvm24-tti"),str(p),"hybrid"],env=env,text=True))
 assert r["exact_step_parity"] and r["commits"]==2 and r["fallback_commits"]==1,r
 assert r["identities"][0].startswith("fallback:") and r["identities"][1].startswith("b2b:"),r
 assert r["costs"]==[43,23],r
 # The prior IR has 35 instructions. New block IDs after the fallback must
 # belong to a fresh epoch, never recycle the old B<n>/terminator identities.
 assert min(map(int,r["identities"][1].split(":")[1:]))>35,r
 clang=Path(subprocess.check_output([lc,"--bindir"],env=env,text=True).strip())/"clang"
 (p/"main.c").write_text('#include <stdio.h>\nextern int f(_Bool,_Bool,int,int);\nint main(){for(int p=0;p<2;p++)for(int q=0;q<2;q++)for(int x=-20;x<=20;x++)for(int y=-20;y<=20;y++)printf("%d\\n",f(p,q,x,y));}\n')
 def execute(path):
  ir=re.sub(r'target triple = ".*"','target triple = "x86_64-unknown-linux-gnu"',path.read_text())
  ir=ir.replace('"target-cpu"="gfx906"',"nounwind")
  (p/"cpu.ll").write_text(ir)
  subprocess.run([str(clang),"-O0",str(p/"cpu.ll"),str(p/"main.c"),"-o",str(p/"run")],env=env,check=True,capture_output=True)
  return subprocess.check_output([str(p/"run")],env=env)
 assert execute(fixture)==execute(p/"full-1.ll")==execute(p/"cached-1.ll")
 print("PASS fallback wins before local candidate, fresh identity epoch, exact full/cached chain, 6724 CPU inputs")
