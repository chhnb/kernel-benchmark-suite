#!/usr/bin/env python3
"""Audit coverage, all committed verifier results and first scheduling divergence."""
import argparse,json,os,re,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("reference",type=Path);p.add_argument("candidate",type=Path,nargs="?");p.add_argument("--out",type=Path,required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];env=dict(os.environ,LD_LIBRARY_PATH=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu"))
reports=[];chains=[]
directories=[a.reference]+([a.candidate] if a.candidate else [])
for directory in directories:
 s=json.loads((directory/"summary.json").read_text());assert s["status"]=="completed"
 chain=[]
 for r in s["rounds"]:
  if not r.get("selected"):continue
  selected=next(t for t in r["attempts"] if t["directory"]==r["selected"])
  assert selected["eligible"]
  ir=Path(r["selected"])/"fused.ll"
  subprocess.run([str(root/"build/llvm12-jammy/usr/bin/opt-12"),"-verify","-disable-output",str(ir)],env=env,check=True,capture_output=True)
  chain.append(dict(candidate=selected["candidate"],cost=r["selected_cost"],ir=str(ir)))
 last=s["rounds"][-1]["parent"]
 terminal=[r for r in s["rounds"] if r["parent"]==last]
 assert not any(t.get("eligible") for r in terminal for t in r["attempts"])
 attempted={t["candidate"] for r in terminal for t in r["attempts"]}
 catalogs=sorted(directory.glob("structural-*/catalog.json"),key=lambda f:int(f.parent.name.split("-")[-1]))
 assert catalogs,"missing terminal candidate catalog"
 c=json.loads(catalogs[-1].read_text())
 assert Path(c["source_ir"]).samefile(last),(directory,"catalog parent differs from terminal IR")
 required={x["candidate"] for x in c["candidates"] if not x.get("preflight_rejection")}
 assert not required-attempted,(directory,"terminal candidates omitted",required-attempted)
 reports.append(dict(directory=str(directory),commits=s["commits"],trials=s["trials"],tti=s["final_cost"],terminal_required=len(required),terminal_attempted=len(attempted),all_committed_ir_verified=True))
 chains.append(chain)
first=None
def normalize(path):
 text=re.sub(r"^; ModuleID = .*\n","",Path(path).read_text())
 return re.sub(r"(?m)^([-.$_a-zA-Z0-9]+:)[ \t]+; preds = .*$",r"\1",text)
for i,(x,y) in enumerate(zip(*chains) if a.candidate else []):
 if x["candidate"]!=y["candidate"] or x["cost"]!=y["cost"] or normalize(x["ir"])!=normalize(y["ir"]):
  first=dict(step=i+1,reference=x,trees=y);break
if a.candidate and first is None and len(chains[0])!=len(chains[1]):first=dict(step=min(map(len,chains))+1,reason="different commit counts")
result=dict(runs=reports,first_divergence=first,final_ir_equal=(normalize(a.reference/"final.ll")==normalize(a.candidate/"final.ll")) if a.candidate else None,scope="Verifier and terminal candidate coverage; execution correctness requires separate tests")
a.out.write_text(json.dumps(result,indent=2)+"\n");print(json.dumps(result,indent=2))
