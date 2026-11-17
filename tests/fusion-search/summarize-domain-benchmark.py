#!/usr/bin/env python3
"""Report wall time separately from cumulative inclusive worker timings."""
import argparse,collections,hashlib,json,re,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("directory",type=Path);p.add_argument("--out",type=Path,required=True);a=p.parse_args()
rows=json.loads((a.directory/"results.json").read_text());runs=[]
for r in rows:
 if r.get("status")!="completed" or r.get("exit")!=0:continue
 d=a.directory/(r["mode"]+str(r["rep"]));totals=collections.defaultdict(lambda:dict(calls=0,inclusive_ms=0.0));requests=0
 for f in d.glob("trial-*/structural/request-profile.json"):
  requests+=1
  for name,v in json.loads(f.read_text()).items():
   totals[name]["calls"]+=v["calls"];totals[name]["inclusive_ms"]+=v["inclusive_ms"]
 if requests != r["trials"]:
  raise ValueError(f"{d}: {requests} profiles for {r['trials']} trial requests")
 text=re.sub(r"^; ModuleID = .*\n","",(d/"final.ll").read_text())
 trace=hashlib.sha256()
 rounds=json.loads((d/"summary.json").read_text())["rounds"]
 for row in rounds:
  if not row.get("selected"):continue
  choice=next(t for t in row["attempts"] if t["directory"]==row["selected"])
  ir=(Path(row["selected"])/"fused.ll").read_text()
  canonical=re.sub(r"^; ModuleID = .*\n","",ir)
  step=[choice["candidate"],row["selected_cost"],hashlib.sha256(canonical.encode()).hexdigest()]
  trace.update((json.dumps(step)+"\n").encode())
 runs.append(dict(**r,commit_trace_sha256=trace.hexdigest(),profiled_requests=requests,worker_inclusive_totals=dict(totals),canonical_final_sha256=hashlib.sha256(text.encode()).hexdigest()))
summary={}
for mode in ["legacy","trees"]:
 rr=[r for r in runs if r["mode"]==mode]
 if not rr:continue
 times=[r["seconds"] for r in rr]
 summary[mode]=dict(runs=len(rr),seconds_median=statistics.median(times),seconds_min=min(times),seconds_max=max(times),repeated_commit_trace_equal=len({r["commit_trace_sha256"] for r in rr})==1,repeated_final_ir_equal=len({r["canonical_final_sha256"] for r in rr})==1,commits=sorted({r["commits"] for r in rr}),trials=sorted({r["trials"] for r in rr}),final_tti=sorted({r["final_cost"] for r in rr}))
result=dict(complete=(a.directory/"completed.json").exists(),summary=summary,runs=runs,timing_scope="driver phase times are wall times; worker inclusive times accumulate parallel requests and overlap parent scopes, so cannot be added to wall time")
if all(mode in summary for mode in ["legacy","trees"]):result["median_wall_reduction_percent"]=100*(1-summary["trees"]["seconds_median"]/summary["legacy"]["seconds_median"])
a.out.write_text(json.dumps(result,indent=2)+"\n");print(json.dumps(summary,indent=2))
