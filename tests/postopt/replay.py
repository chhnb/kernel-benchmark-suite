#!/usr/bin/env python3
"""CPU-only deterministic replay test for a user-selected fixed LLVM snapshot.
Invoke under the site's canonical CPU admission wrapper on shared musa.
"""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument("--ir",type=Path,required=True);p.add_argument("--function",required=True)
p.add_argument("--out",type=Path,required=True);p.add_argument("--trials",type=int,default=256);a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False);source_hash=hashlib.sha256(a.ir.read_bytes()).hexdigest();runs=[]
for n in range(3):
 d=a.out/f"run-{n}"
 cmd=[str(ROOT/"build/fusion-search/fusion-search"),"--ir",str(a.ir.resolve()),"--function",a.function,
      "--out",str(a.out/f"run-{n}.ll"),"--rounds","1","--trials",str(a.trials),"--scorer","v2","--pressure-weight","0.1","--debug-dir",str(d)]
 with (a.out/f"run-{n}.log").open("x") as log:subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
 records=[json.loads(f.read_text()) for f in d.glob("trial-*/trial.json")]
 if not records:raise RuntimeError("no candidate evaluated; replay test has no coverage")
 runs.append({r["candidate"]:(r["valid"],r["cleaned_hash"],r["score_result"]["total"]) for r in records})
 if hashlib.sha256(a.ir.read_bytes()).hexdigest()!=source_hash:raise RuntimeError("parent IR mutated")
if not runs[0]==runs[1]==runs[2]:raise RuntimeError("candidate identity, output IR or score changed across processes")
(a.out/"result.json").write_text(json.dumps({"passed":True,"runs":3,"candidates":len(runs[0]),"parent_sha256":source_hash},indent=2))
print("PASS stable candidates, cleaned IR, scores and immutable parent")
