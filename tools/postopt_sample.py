#!/usr/bin/env python3
"""Freeze deterministic strata before measuring; never retry failed requests."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser();p.add_argument("--debug",type=Path,required=True);p.add_argument("--case",required=True)
 p.add_argument("--selection",choices=["extreme","hash"],default="extreme")
 p.add_argument("--seed",default="postopt-screening-2026-11-07")
 p.add_argument("--exclude-root",type=Path,help="Exclude every previously prepared candidate, including failed/denied experiments")
 p.add_argument("--out",type=Path,required=True);p.add_argument("--measure",action="store_true");a=p.parse_args()
 d=a.out.resolve();d.mkdir(parents=True,exist_ok=False);rows=[]
 for f in a.debug.resolve().glob("trial-*/trial.json"):
  r=json.loads(f.read_text());s=r["score_result"]
  if r["valid"]:rows.append((f.parent,r))
 rows.sort(key=lambda v:v[1]["candidate"])
 selected=[];seen=set();excluded=set()
 if a.exclude_root:
  for manifest in sorted(a.exclude_root.rglob("manifest.json")):
   m=json.loads(manifest.read_text());t=m.get("trial")
   if isinstance(t,dict) and all(k in t for k in ("candidate","parent_hash","cleaned_hash")):
    excluded.add((t["candidate"],t["parent_hash"],t["cleaned_hash"]))
 rows=[v for v in rows if (v[1]["candidate"],v[1]["parent_hash"],v[1]["cleaned_hash"]) not in excluded]
 strata=[
  ("positive",lambda r:r["eligible"],lambda r:-r["score_result"]["total"]),
  ("negative",lambda r:r["score_result"]["status"]=="scored" and r["score_result"]["static_score"]<0,lambda r:r["score_result"]["static_score"]),
  ("pressure_flip",lambda r:r["score_result"]["status"]=="scored" and not r["eligible"] and r["score_result"]["static_score"]>0,lambda r:r["score_result"]["static_score"]),
  ("unsupported",lambda r:r["score_result"]["status"]!="scored",lambda r:r["after"]["instructions"])]
 if a.selection=="hash":
  strata=[("native_rejected",lambda r:r["eligible"] and not r["original_darm_profitable"],None),
          ("positive",lambda r:r["eligible"] and r["original_darm_profitable"],None),
          ("negative",strata[1][1],None),("pressure_flip",strata[2][1],None),
          ("neutral",lambda r:r["score_result"]["status"]=="scored" and r["score_result"]["static_score"]==0,None),
          ("unsupported",strata[3][1],None)]
 for name,condition,key in strata:
  if a.selection=="hash":
   key=lambda r:hashlib.sha256(json.dumps([a.seed,r["parent_hash"],r["candidate"],r["cleaned_hash"]]).encode()).hexdigest()
  choices=sorted((v for v in rows if condition(v[1]) and v[1]["candidate"] not in seen),key=lambda v:(key(v[1]),v[1]["candidate"]))
  if not choices:continue
  path,r=choices[0];seen.add(r["candidate"])
  selected.append({"stratum":name,"trial":str(path),"candidate":r["candidate"],"parent_hash":r["parent_hash"],"cleaned_hash":r["cleaned_hash"]})
 plan={"schema":"postopt-sample-v0","case":a.case,"debug":str(a.debug.resolve()),"minimum_log_effect":0.02,
       "batches":3,"warmup":2,"repeat":5,"selection":("one deterministic extreme per available stratum; exploratory, not representative" if a.selection=="extreme" else "one seeded hash sample per disjoint stratum among previously unprepared candidates; exploratory, not population-weighted"),
       "seed":a.seed,"excluded_candidate_count":len(excluded),"remaining_legal_population":len(rows),
       "samples":selected}
 (d/"plan.json").write_text(json.dumps(plan,indent=2))
 outcomes=[]
 for item in selected:
  pair=d/(item["stratum"]+"-pair");cmd=[sys.executable,str(ROOT/"tools/postopt_pair.py"),"--trial",item["trial"],"--case",a.case,"--out",str(pair)]
  with (d/(item["stratum"]+"-prepare.log")).open("w") as stream:rc=subprocess.run(cmd,stdout=stream,stderr=subprocess.STDOUT).returncode
  outcome={"stratum":item["stratum"],"prepare_exit":rc}
  if rc==0 and a.measure:
   measure=d/(item["stratum"]+"-measure")
   cmd=[sys.executable,str(ROOT/"tools/postopt_measure.py"),"--pair",str(pair),"--out",str(measure),"--minimum-log-effect","0.02"]
   with (d/(item["stratum"]+"-measure.log")).open("w") as stream:outcome["measure_exit"]=subprocess.run(cmd,stdout=stream,stderr=subprocess.STDOUT).returncode
  outcomes.append(outcome);(d/"progress.json").write_text(json.dumps(outcomes,indent=2))
 print(json.dumps(outcomes))
 return 2 if any(x["prepare_exit"] or x.get("measure_exit",0) for x in outcomes) else 0
if __name__=="__main__":raise SystemExit(main())
