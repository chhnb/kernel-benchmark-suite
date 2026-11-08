#!/usr/bin/env python3
"""Compile explicit full-pipeline comparison IRs with the same AMD backend."""
import argparse,hashlib,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
BIN=Path("/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin")
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser()
 for name in ("baseline","variant","out"):p.add_argument("--"+name,type=Path,required=True)
 for name in ("case","function","scope"):p.add_argument("--"+name,required=True)
 p.add_argument("--admitted",action="store_true",help=argparse.SUPPRESS);a=p.parse_args()
 if not a.admitted:
  args=[sys.executable,str(Path(__file__).resolve())]
  for name in ("baseline","variant","out","case","function","scope"):
   value=getattr(a,name);args+=["--"+name,str(value.resolve() if isinstance(value,Path) else value)]
  return subprocess.call([sys.executable,"/home/chh/region-fusion-lab/work/run-cpu.py","postopt-full-pair-"+str(time.time_ns()),*args,"--admitted"],cwd=ROOT)
 case=json.loads((ROOT/"cases"/a.case/"case.json").read_text())
 if case["runtime"]["backend"]!="amd":raise ValueError("AMD backend only")
 d=a.out.resolve();d.mkdir(parents=True,exist_ok=False)
 m={"schema":"postopt-full-pipeline-comparison-v0","case":a.case,"scope":a.scope,
    "candidate":None,"context":{"function":a.function},"files":{},"commands":[],
    "semantic_validation":"not_run","status":"preparing","further_melding":False}
 def save():(d/"manifest.json").write_text(json.dumps(m,indent=2))
 def run(stage,argv):
  cmd=list(map(str,argv));m["commands"].append({"stage":stage,"argv":cmd});save()
  with (d/(stage+".stdout")).open("w") as o,(d/(stage+".stderr")).open("w") as e:
   subprocess.run(cmd,stdout=o,stderr=e,check=True,timeout=600)
 try:
  for side in ("baseline","variant"):
   source=getattr(a,side).resolve();dest=d/(side+".ll");dest.write_bytes(source.read_bytes())
   m["files"][side]={"source":str(source),"sha256":sha(dest)}
   run(side+"-opt",[BIN/"opt",dest,"-O3","-verify-each","-S","-o",d/(side+"-final.ll")])
   run(side+"-llc",[BIN/"llc",d/(side+"-final.ll"),"-O3","-mtriple=amdgcn-amd-amdhsa","-mcpu=gfx906","-mattr=+sram-ecc,-xnack","-filetype=obj","-o",d/(side+".o")])
   run(side+"-link",["/opt/rocm/llvm/bin/ld.lld","-shared",d/(side+".o"),"-o",d/(side+".hsaco")])
   run(side+"-resources",["/opt/rocm/llvm/bin/llvm-readobj","--notes",d/(side+".hsaco")])
   m["files"][side+"_binary"]={"sha256":sha(d/(side+".hsaco"))}
   m["files"][side+"_resources"]={"path":side+"-resources.stdout","sha256":sha(d/(side+"-resources.stdout"))}
  m["status"]="compiled_pair_not_validated";save()
 except Exception:
  m["status"]="failed_preserved";save();raise
 return 0
if __name__=="__main__":raise SystemExit(main())
