#!/usr/bin/env python3
"""Join frozen candidate decisions to independently measured paired labels."""
import argparse,hashlib,json,math,statistics
from pathlib import Path
def load(p):return json.loads(p.read_text())
def main():
 p=argparse.ArgumentParser();p.add_argument("--debug",type=Path,required=True)
 p.add_argument("--labels-file",type=Path,help="Explicit derived labels for exactly one measurement")
 p.add_argument("--labels-name",default="labels.json");p.add_argument("--measure",type=Path,action="append",default=[]);p.add_argument("--out",type=Path,required=True)
 a=p.parse_args()
 if a.labels_file and len(a.measure)!=1:raise ValueError("labels-file requires exactly one measurement")
 run_path=a.debug/"run.json"
 result_path=a.debug/"result.json"
 if run_path.exists():
  run=load(run_path)
  if run.get("schema")!="postopt-scoring-run-v1":raise ValueError("unknown scoring-run schema")
  policy=run.get("policy")
  if result_path.exists() and load(result_path).get("policy")!=policy:raise ValueError("run/result policy mismatch")
 else:
  run={"mode":"legacy_greedy_record","parameter_provenance":"trial metrics; no run manifest"}
  policy=load(result_path).get("policy")
 if policy!="v2":raise ValueError("comparison report requires v2 observation with explicit pressure configuration")
 rows=[];bykey={};byorigin={}
 for path in sorted(a.debug.glob("trial-*/trial.json")):
  t=load(path);s=t["score_result"];scored=s["status"]=="scored"
  if run_path.exists():
   if t["version"]==0 and t["parent_hash"]!=run["initial_parent_hash"]:raise ValueError("run/trial parent mismatch")
   if t["valid"]:
    for run_key,metric_key in [("work_absolute","absolute_threshold"),("work_relative","relative_threshold"),("pressure_weight","pressure_weight")]:
     if s["metrics"].get(metric_key)!=run[run_key]:raise ValueError("run/trial parameter mismatch: "+run_key)
    if "static_alloca_cost" in run and s["metrics"].get("static_alloca_cost")!=run["static_alloca_cost"]:
     raise ValueError("run/trial parameter mismatch: static_alloca_cost")
    if "dependency_features" in run and bool(s["metrics"].get("dependency_features_enabled"))!=run["dependency_features"]:
     raise ValueError("run/trial dependency feature mismatch")
  row={"candidate":t["candidate"],"parent_hash":t["parent_hash"],"cleaned_hash":t["cleaned_hash"],"control_hash":t.get("control_hash"),"identity_parent_hash":run.get("replay_parent_hash") or t["parent_hash"],
       "valid":t["valid"],"score_status":s["status"],"score_reason":s["reason"],"coverage":s["coverage"],"features":s["metrics"],"timings_ms":t["timings_ms"],
       "decisions":{"original_darm":t.get("original_darm_profitable"),
                    "v1":bool(scored and s["static_gain"]>s["metrics"]["absolute_threshold"] and s["static_score"]>s["metrics"]["relative_threshold"]),
                    "v2":t["eligible"]},"measurements":[]}
  rows.append(row);bykey[(t["candidate"],t["parent_hash"],t["cleaned_hash"])]=row
  if run.get("replay_parent_hash"):
   byorigin[(t["candidate"],run["replay_parent_hash"],t["cleaned_hash"])]=row
 unmatched=[]
 for measure in a.measure:
  plan=load(measure/"plan.json");pair=load(Path(plan["pair"])/"manifest.json")
  t=pair["trial"];key=(t["candidate"],t["parent_hash"],t["cleaned_hash"])
  row=bykey.get(key);binding="exact_trial_hashes"
  if row is None:
   row=byorigin.get(key);binding="authenticated_snapshot_origin_and_exact_control_candidate_hashes"
   if row is None or not row["control_hash"] or row["control_hash"]!=t.get("control_hash"):
    unmatched.append(str(measure));continue
  if not row["control_hash"] or row["control_hash"]!=t.get("control_hash"):
   unmatched.append(str(measure));continue
  labels=load(a.labels_file if a.labels_file else measure/a.labels_name)
  if labels["status"]=="complete_confirmation":
   if labels.get("schema")!="postopt-confirmation-v1" or labels.get("measurement_plan_sha256")!=hashlib.sha256((measure/"plan.json").read_bytes()).hexdigest():
    raise ValueError("confirmation labels do not bind to this measurement plan")
  row["measurements"].append({"path":str(measure),"status":labels["status"],"inputs":labels["inputs"],"label_schema":labels.get("schema","postopt-labels-v0"),"identity_binding":binding,"measured_parent_hash":t["parent_hash"]})
 summary={}
 for model in ("original_darm","v1","v2"):
  known=[r for r in rows if r["valid"] and r["decisions"][model] is not None]
  labels=[(r["decisions"][model],v) for r in known for m in r["measurements"] if m["status"] in ("complete_screening","complete_confirmation") for v in m["inputs"].values()]
  definite=[(accept,v) for accept,v in labels if v["label"] in ("beneficial","harmful")]
  accepted=[v for accept,v in definite if accept];good=[(accept,v) for accept,v in definite if v["label"]=="beneficial"]
  logs=[v["mean_log_ratio"] for accept,v in labels if accept]
  summary[model]={"known_candidates":len(known),"accepted_candidates":sum(r["decisions"][model] for r in known),
    "complete_measured_candidate_inputs":len(labels),"definite_candidate_inputs":len(definite),
    "accepted_harmful_fraction":sum(v["label"]=="harmful" for v in accepted)/len(accepted) if accepted else None,
    "beneficial_retention":sum(accept for accept,v in good)/len(good) if good else None,
    "measured_accepted_geomean":math.exp(statistics.mean(logs)) if logs else None,
    "measured_accepted_worst_speedup":math.exp(min(logs)) if logs else None}
 costs=[r["timings_ms"]["trial_total"]+r["timings_ms"]["score_with_analysis"] for r in rows]
 score_costs=[r["timings_ms"]["score_with_analysis"] for r in rows if r["valid"]]
 control_ms=sum(load(f).get("control_ms",0) for f in a.debug.glob("round-*.json"))
 coverage={"trial_count":len(rows),"illegal_or_failed":sum(not r["valid"] for r in rows),
           "unsupported_legal":sum(r["valid"] and r["score_status"]!="scored" for r in rows)}
 timing={"control_total_ms":control_ms,"candidate_total_ms":sum(costs),
         "candidate_median_ms":statistics.median(costs) if costs else None,
         "candidate_max_ms":max(costs) if costs else None,
         "scoring_median_ms":statistics.median(score_costs) if score_costs else None}
 report={"run":run,"timing":timing,"coverage":coverage,"schema":"postopt-candidate-report-v0","scope":"candidate screening; selected samples, not generalization or full-kernel search evidence",
         "unknown_denominators_are_null":True,"summary":summary,"unmatched_measurements":unmatched,"candidates":rows}
 with a.out.open("x") as f:json.dump(report,f,indent=2)
 print(json.dumps(summary,indent=2))
if __name__=="__main__":main()
