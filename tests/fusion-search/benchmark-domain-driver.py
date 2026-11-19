#!/usr/bin/env python3
"""Sequential alternating ordered/legacy runs with frozen input and binary provenance."""
import argparse,hashlib,json,os,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("--driver",type=Path,required=True);p.add_argument("--tool-root",type=Path,required=True);p.add_argument("--input",type=Path,required=True);p.add_argument("--function",required=True);p.add_argument("--out",type=Path,required=True);p.add_argument("--repeats",type=int,default=2);a=p.parse_args()
root=Path(__file__).resolve().parents[2];a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
env=dict(os.environ,LD_LIBRARY_PATH=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu"),LLVM24_LIBDIR=str(root/"build/llvm24-pinned/lib"),DECISION_GREEDY_JOBS="16")
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
provenance=dict(driver=str(a.driver.resolve()),driver_sha256=sha(a.driver),engine_sha256=sha(a.tool_root/"build/llvm24-tti/fusion-search-llvm24"),input_sha256=sha(a.input),jobs=16,quote_cache="on",cleanup="darm-cfg-dce-instcombine",repeats=a.repeats)
(a.out/"provenance.json").write_text(json.dumps(provenance,indent=2));rows=[]
for rep in range(a.repeats):
 for mode in (["legacy","ordered"] if rep%2==0 else ["ordered","legacy"]):
  dest=a.out/(mode+str(rep));start=time.monotonic()
  command=[str(a.driver.resolve()),str(a.input.resolve()),a.function,str(a.tool_root.resolve()),str(dest),"--domain-schedule",mode]
  with (a.out/(dest.name+".stdout")).open("w") as stdout,(a.out/(dest.name+".stderr")).open("w") as stderr:
   child=subprocess.Popen(command,env=env,stdout=stdout,stderr=stderr)
   (a.out/"active-process.json").write_text(json.dumps(dict(pid=child.pid,mode=mode,rep=rep,command=command,start=time.time())))
   code=child.wait()
  row=dict(mode=mode,rep=rep,seconds=time.monotonic()-start,exit=code)
  if (dest/"summary.json").exists():
   s=json.loads((dest/"summary.json").read_text());row.update({k:s.get(k) for k in ["status","commits","trials","final_cost","driver_phase_timings"]})
  rows.append(row);(a.out/"results.json").write_text(json.dumps(rows,indent=2));print(row,flush=True)
  if code:raise SystemExit(code)
(a.out/"completed.json").write_text(json.dumps(dict(runs=len(rows),completed=True)))
