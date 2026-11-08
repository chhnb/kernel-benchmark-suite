#!/usr/bin/env python3
"""Audit fixed paired batches; incomplete experiments never receive labels."""
import argparse,csv,json,math,statistics
from pathlib import Path
def read_batch(path):
    receipt=json.loads((path/"accepted.json").read_text())
    if not receipt["passed"] or receipt["phase"]!="benchmark":raise ValueError("not accepted benchmark")
    samples={}
    for f in sorted((path/"output").glob("*/samples.csv")):
        with f.open() as stream:rows=list(csv.DictReader(stream))
        if not rows or any(r["full_output_passed"]!="1" for r in rows):raise ValueError("output validation failed")
        values=[float(r["microseconds"]) for r in rows if r["warmup"]=="0"]
        if not values or any(not math.isfinite(v) or v<=0 for v in values):raise ValueError("invalid times")
        if any(r["timing"]!=receipt["timing_mode"] for r in rows):raise ValueError("timing mismatch")
        samples[f.parent.name]={"median_us":statistics.median(values),"samples_us":values}
    if not samples and any(Path(k).name=="bench_tigre" for k in receipt["binary_snapshot"]):
        # This suite runner checks complete outputs after each recorded launch;
        # its accepted receipt is emitted only after the checker exits zero.
        if receipt["timing_mode"]!="event":raise ValueError("unsupported TIGRE timing mode")
        for f in sorted((path/"output").glob("*/timing.csv")):
            with f.open() as stream:rows=list(csv.DictReader(stream))
            if len({r["variant"] for r in rows})!=1:raise ValueError("mixed internal variants")
            groups={}
            for row in rows:
                if row["warmup"]!="0":continue
                v=float(row["ms"])*1000
                if not math.isfinite(v) or v<=0:raise ValueError("invalid TIGRE times")
                groups.setdefault(row["batch"],[]).append(v)
            if set(groups)!=set(map(str,range(6))):raise ValueError("missing TIGRE projection batch")
            for group,values in groups.items():
                samples[f.parent.name+":projection_batch"+group]={"median_us":statistics.median(values),"samples_us":values}
    if not samples and any(Path(k).name in ("bench_hypersonic","bench_reentry") for k in receipt["binary_snapshot"]):
        if receipt["timing_mode"]!="event":raise ValueError("unsupported fluid timing mode")
        for f in sorted((path/"output").glob("*/*/checks.jsonl")):
            rows=[json.loads(line) for line in f.read_text().splitlines() if line.strip()]
            if not rows or len({(r["slot"],r["role"]) for r in rows})!=1:raise ValueError("mixed fluid variants")
            if any(not all(r[k] for k in ("pass","guards","readonly")) or r["mismatches"] or r["negatives"] for r in rows):raise ValueError("fluid output check failed")
            values=[float(r["milliseconds"])*1000 for r in rows if r["measurement"]]
            if not values or any(not math.isfinite(v) or v<=0 for v in values):raise ValueError("invalid fluid times")
            key=f.parent.parent.name+":"+f.parent.name
            samples[key]={"median_us":statistics.median(values),"samples_us":values}
    if not samples:raise ValueError("no samples")
    return receipt,samples
def summarize(root,prefix,batches,min_effect):
    out={"schema":"postopt-labels-v0","expected_batches":batches,
         "minimum_log_effect":min_effect,"batches":[],"issues":[],"inputs":{}}
    reference=None
    binaries={}
    for batch in range(batches):
        pair={}
        for side in ("baseline","variant"):
            path=root/(prefix+"-"+side+"-batch-"+str(batch))
            try:
                receipt,samples=read_batch(path)
                config=(receipt["input_snapshot"],receipt["timing_mode"])
                if reference is None:reference=config
                if config!=reference:raise ValueError("input/timing configuration differs")
                binary=receipt["binary_snapshot"]
                if side in binaries and binaries[side]!=binary:raise ValueError("binary changed across batches")
                binaries[side]=binary
                pair[side]={"path":str(path),"samples":samples,"binary_snapshot":receipt["binary_snapshot"]}
            except (OSError,ValueError,KeyError) as e:
                out["issues"].append({"batch":batch,"side":side,"error":str(e)})
        if len(pair)==2:
            if pair["baseline"]["samples"].keys()!=pair["variant"]["samples"].keys():raise ValueError("input sets differ")
            out["batches"].append({"batch":batch,**pair})
    complete=len(out["batches"])==batches and not out["issues"] and batches>=3
    out["status"]="complete_screening" if complete else "incomplete_no_label"
    if out["batches"]:
        for inp in out["batches"][0]["baseline"]["samples"]:
            ys=[math.log(b["baseline"]["samples"][inp]["median_us"]/b["variant"]["samples"][inp]["median_us"]) for b in out["batches"]]
            # Observed batch range is a screening range, not a confidence interval.
            label="unclear"
            if complete and min(ys)>min_effect:label="beneficial"
            elif complete and max(ys)<-min_effect:label="harmful"
            if not complete:label="unlabeled_incomplete"
            out["inputs"][inp]={"log_ratios":ys,"mean_log_ratio":statistics.mean(ys),
                "observed_batch_range":[min(ys),max(ys)],"label":label}
    return out
def main():
    p=argparse.ArgumentParser();p.add_argument("--root",type=Path,required=True);p.add_argument("--prefix",required=True)
    p.add_argument("--batches",type=int,default=3);p.add_argument("--minimum-log-effect",type=float,required=True)
    p.add_argument("--out",type=Path,required=True);a=p.parse_args()
    if a.batches<3 or not math.isfinite(a.minimum_log_effect) or a.minimum_log_effect<0:p.error("invalid screening configuration")
    report=summarize(a.root,a.prefix,a.batches,a.minimum_log_effect)
    with a.out.open("x") as f:json.dump(report,f,indent=2)
    print(report["status"]);return 0
if __name__=="__main__":raise SystemExit(main())
