#!/usr/bin/env python3
"""Export candidate labels with explicit program-family grouping; do not fit."""
import argparse,collections,hashlib,json
from pathlib import Path
def main():
 p=argparse.ArgumentParser()
 p.add_argument("--report",action="append",required=True,help="FAMILY=REPORT_JSON; related kernels must share FAMILY")
 p.add_argument("--out",type=Path,required=True);a=p.parse_args()
 rows=[];seen={};sources=[]
 for spec in a.report:
  family,path=spec.split("=",1)
  if not family:raise ValueError("empty family")
  source=Path(path);report=json.loads(source.read_text());sources.append({"family":family,"path":str(source.resolve()),"sha256":hashlib.sha256(source.read_bytes()).hexdigest()})
  for c in report["candidates"]:
   key=(c["candidate"],c.get("identity_parent_hash",c["parent_hash"]),c["cleaned_hash"])
   candidate_id=hashlib.sha256(json.dumps(key).encode()).hexdigest()
   if candidate_id in seen and seen[candidate_id]!=family:raise ValueError("candidate leaks across families")
   seen[candidate_id]=family
   for m in c["measurements"]:
    if m["status"] not in ("complete_screening","complete_confirmation"):continue
    for inp,v in m["inputs"].items():
     rows.append({"family":family,"candidate_id":candidate_id,"candidate":c["candidate"],"input":inp,
       "log_speedup":v["mean_log_ratio"],"label":v["label"],"features":c["features"],"measurement":m["path"],"measurement_label_schema":m.get("label_schema","postopt-labels-v0")})
 identities=[(r["candidate_id"],r["input"]) for r in rows]
 if len(set(identities))!=len(identities):raise ValueError("duplicate candidate/input; explicitly aggregate repeated experiments first")
 definite=[r for r in rows if r["label"] in ("beneficial","harmful")]
 families=sorted({r["family"] for r in definite})
 counts=dict(collections.Counter(r["label"] for r in definite))
 reasons=[]
 if len(families)<3:reasons.append("fewer_than_three_families_with_definite_labels")
 if not counts.get("harmful"):reasons.append("no_harmful_candidate_labels")
 if not counts.get("beneficial"):reasons.append("no_beneficial_candidate_labels")
 reasons.append("exploratory_extreme_sampling_not_representative")
 result={"schema":"postopt-grouped-calibration-data-v0","rows":rows,"sources":sources,
         "readiness":{"ready_for_deployment_calibration":False,"reasons":reasons,"definite_label_counts":counts,"families_with_definite_labels":families},
         "split_rule":"All candidates, inputs and launch variants of one program family stay in one split. Freeze train/validation/test before tuning.",
         "model_fitted":False,"test_evaluated":False}
 with a.out.open("x") as f:json.dump(result,f,indent=2)
 print(json.dumps(result["readiness"],indent=2))
if __name__=="__main__":main()
