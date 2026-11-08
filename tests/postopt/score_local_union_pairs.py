import json,subprocess
from pathlib import Path
R=Path("/home/chh/kernel-benchmark-suite");O=R/"experiments/local-union-seven-pairs-20261108-v1";O.mkdir(exist_ok=False)
cat=json.loads((R/"experiments/logical-state-eight-catalog-20261108-v2/vllm-quant/debug/catalog.json").read_text())["candidates"]
rows=[]
for n in range(7):
 c=next(x for x in cat if x["logical_left"]==f"D16.L{n}" and x["logical_right"]==f"D16.L{n+1}")
 d=O/f"L{n}-L{n+1}";args=[str(R/"build/llvm24-tti/fusion-search-llvm24"),"--ir",str(R/"experiments/logical-state-vllm-20261108-v1/state-0.ll"),"--function","cache_eval","--out",str(O/f"L{n}-L{n+1}.ll"),"--debug-dir",str(d),"--adjacent-only","1","--local-copysign","1","--local-union","1","--cleanup","none","--scorer","llvm24","--split",c["split"],"--left",c["left"],"--right",c["right"]]
 p=subprocess.run(args,capture_output=True,text=True);(O/f"L{n}-L{n+1}.log").write_text(p.stdout+p.stderr)
 j=json.loads((d/"trial-0/trial.json").read_text());s=j["score_result"];m=s.get("metrics",{})
 row=dict(pair=f"L{n}+L{n+1}",exit=p.returncode,valid=j["valid"],reason=j["reason"],status=s["status"],before=m.get("work_before"),after=m.get("work_after"),gain=s.get("static_gain"),score=s.get("total"));rows.append(row)
 print(json.dumps(row),flush=True)
(O/"summary.json").write_text(json.dumps(rows,indent=2))
