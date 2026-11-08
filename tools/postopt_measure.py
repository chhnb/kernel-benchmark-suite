#!/usr/bin/env python3
"""Predeclared paired batches through suite admission; stop on first failure."""
import argparse,hashlib,json,math,subprocess,sys
from pathlib import Path
from postopt_labels import summarize
ROOT=Path(__file__).resolve().parents[1]
def save(p,o):p.write_text(json.dumps(o,indent=2)+"\n")
def main():
 p=argparse.ArgumentParser();p.add_argument("--pair",type=Path,required=True);p.add_argument("--out",type=Path,required=True)
 p.add_argument("--batches",type=int,default=3);p.add_argument("--warmup",type=int,default=2)
 p.add_argument("--repeat",type=int,default=5);p.add_argument("--minimum-log-effect",type=float,required=True)
 a=p.parse_args()
 if a.batches<3 or a.warmup<0 or a.repeat<1 or not math.isfinite(a.minimum_log_effect) or a.minimum_log_effect<0:p.error("invalid fixed measurement budget")
 pair=a.pair.resolve();d=a.out.resolve();d.mkdir(parents=True,exist_ok=False)
 m=json.loads((pair/"manifest.json").read_text())
 if m["status"]!="compiled_pair_not_validated":raise ValueError("pair not compiled")
 for side in ("baseline","variant"):
  digest=hashlib.sha256((pair/(side+".hsaco")).read_bytes()).hexdigest()
  if digest!=m["files"][side+"_binary"]["sha256"]:raise ValueError("binary digest mismatch")
 plan={"schema":"postopt-measure-v0","pair":str(pair),"case":m["case"],
       "batches":a.batches,"warmup":a.warmup,"repeat":a.repeat,"minimum_log_effect":a.minimum_log_effect,
       "order":[["baseline","variant"] if i%2==0 else ["variant","baseline"] for i in range(a.batches)],
       "binary_sha256":{side:m["files"][side+"_binary"]["sha256"] for side in ("baseline","variant")},
       "retry":False,"status":"planned","commands":[]}
 # Persist full budget and effect threshold before any GPU validation or timing.
 save(d/"plan.json",plan)
 def run(phase,side,out):
  if hashlib.sha256((pair/(side+".hsaco")).read_bytes()).hexdigest()!=plan["binary_sha256"][side]:raise RuntimeError("binary changed before launch")
  cmd=[str(ROOT/"bench"),m["case"],phase,"--kernel",str(pair/(side+".hsaco")),"--out",str(out),
       "--warmup",str(a.warmup),"--repeat",str(a.repeat)]
  if phase=="benchmark":cmd+=["--validated",str(d/(side+"-validation"))]
  plan["commands"].append(cmd);save(d/"progress.json",plan)
  rc=subprocess.run(cmd,cwd=ROOT).returncode
  if hashlib.sha256((pair/(side+".hsaco")).read_bytes()).hexdigest()!=plan["binary_sha256"][side]:raise RuntimeError("binary changed during launch")
  if rc:raise RuntimeError("request stopped, no retry: "+str(rc))
 try:
  for side in ("baseline","variant"):run("validate",side,d/(side+"-validation"))
  for batch,order in enumerate(plan["order"]):
   for side in order:run("benchmark",side,d/("paired-"+side+"-batch-"+str(batch)))
  plan["status"]="completed"
 except Exception as e:
  plan["status"]="stopped_preserved";plan["error"]=str(e)
 finally:
  save(d/"terminal.json",plan)
  save(d/"labels.json",summarize(d,"paired",a.batches,a.minimum_log_effect))
 return 0 if plan["status"]=="completed" else 2
if __name__=="__main__":raise SystemExit(main())
