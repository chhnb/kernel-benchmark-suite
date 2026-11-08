#!/usr/bin/env python3
"""Freeze and compile one already verified isolated trial, without further melding."""
import argparse, hashlib, json, shutil, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
CPU=Path("/home/chh/region-fusion-lab/work/run-cpu.py")
BIN=Path("/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin")
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,o): p.write_text(json.dumps(o,indent=2)+"\n")
def main():
    p=argparse.ArgumentParser()
    p.add_argument("--trial",type=Path,required=True)
    p.add_argument("--out",type=Path,required=True)
    p.add_argument("--case",required=True)
    p.add_argument("--admitted",action="store_true",help=argparse.SUPPRESS)
    a=p.parse_args()
    if not a.admitted:
        return subprocess.call([sys.executable,str(CPU),"postopt-pair-"+str(time.time_ns()),
          sys.executable,str(Path(__file__).resolve()),"--trial",str(a.trial.resolve()),
          "--out",str(a.out.resolve()),"--case",a.case,"--admitted"])
    d=a.out.resolve();d.mkdir(parents=True,exist_ok=False)
    t=a.trial.resolve();r=json.loads((t/"trial.json").read_text())
    if not r["valid"]: raise ValueError("trial failed legality/verifier")
    context=json.loads((t/r["round_context"]).read_text())
    if context["target_triple"]!="amdgcn-amd-amdhsa":raise ValueError("this backend recipe requires AMDGPU")
    case=json.loads((ROOT/"cases"/a.case/"case.json").read_text())
    if case["runtime"]["backend"]!="amd":raise ValueError("case/backend mismatch")
    sources={"parent":(t/r["parent_ir"]).resolve(),"baseline":t.parent/("round-"+str(r["version"])+"-control.ll"),
             "raw_variant":t/"after-raw.ll","variant":t/"after.ll"}
    for key,expected in [("parent",r["parent_hash"]),("baseline",r["control_hash"]),("variant",r["cleaned_hash"])]:
        if hashlib.sha1(sources[key].read_bytes()).hexdigest()!=expected:raise ValueError("IR snapshot identity mismatch: "+key)
    git=subprocess.run(["git","-C","/home/chh/darm-artifacts-repro/upstream/code","rev-parse","HEAD"],capture_output=True,text=True)
    manifest={"llvm_commit":git.stdout.strip() if git.returncode==0 else None,
      "llvm_commit_status":"recorded" if git.returncode==0 else "unavailable",
      "concrete_alignment_id":hashlib.sha256((r["parent_hash"]+r["candidate"]+sha(sources["raw_variant"])).encode()).hexdigest(),
      "source_sha256":{str(x.relative_to(ROOT)):sha(x) for x in sorted((ROOT/"tools").rglob("*")) if x.suffix in (".cpp",".h")},
      "fusion_binary_sha256":sha(ROOT/"build/fusion-search/fusion-search"),
      "schema":"postopt-pair-v0","case":a.case,"candidate":r["candidate"],
      "context":context,"trial":r,"commands":[],"files":{},"status":"preparing",
      "semantic_validation":"not_run","performance_label":None,
      "further_melding":False,"backend_recipe":"llvm12-opt-O3-verify-each-llc-gfx906",
      "tools":{str(x):sha(x) for x in [BIN/"opt",BIN/"llc",Path("/opt/rocm/llvm/bin/ld.lld")]}}
    save(d/"manifest.json",manifest)
    for name,src in sources.items():
        dest=d/(name+".ll");shutil.copyfile(src,dest)
        manifest["files"][name]={"source":str(src),"sha256":sha(dest)}
    def run(name,cmd):
        cmd=list(map(str,cmd));manifest["commands"].append({"stage":name,"argv":cmd})
        save(d/"manifest.json",manifest)
        with (d/(name+".stdout")).open("w") as o,(d/(name+".stderr")).open("w") as e:
            r=subprocess.run(cmd,stdout=o,stderr=e,timeout=600)
        if r.returncode:raise RuntimeError(name+" failed: "+str(r.returncode))
    try:
        for name in ["baseline","variant"]:
            run(name+"-opt",[BIN/"opt",d/(name+".ll"),"-O3","-verify-each","-S","-o",d/(name+"-final.ll")])
            run(name+"-llc",[BIN/"llc",d/(name+"-final.ll"),"-O3","-mtriple=amdgcn-amd-amdhsa",
              "-mcpu=gfx906","-mattr=+sram-ecc,-xnack","-filetype=obj","-o",d/(name+".o")])
            run(name+"-link",["/opt/rocm/llvm/bin/ld.lld","-shared",d/(name+".o"),"-o",d/(name+".hsaco")])
            run(name+"-resources",["/opt/rocm/llvm/bin/llvm-readobj","--notes",d/(name+".hsaco")])
            manifest["files"][name+"_resources"]={"path":name+"-resources.stdout","sha256":sha(d/(name+"-resources.stdout"))}
            manifest["files"][name+"_binary"]={"sha256":sha(d/(name+".hsaco"))}
        for name,src in sources.items():
            if sha(src)!=manifest["files"][name]["sha256"]:raise RuntimeError("source changed during preparation")
        manifest["status"]="compiled_pair_not_validated"
    except Exception:
        manifest["status"]="failed_preserved";save(d/"manifest.json",manifest);raise
    save(d/"manifest.json",manifest)
    print(str(d));return 0
if __name__=="__main__":raise SystemExit(main())
