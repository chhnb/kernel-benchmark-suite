import json,subprocess,hashlib
from pathlib import Path
R=Path('/home/chh/kernel-benchmark-suite');O=R/'experiments/llvm24-focus-nine-20261108-v1';O.mkdir(exist_ok=False)
W=R/'tools/run-llvm24-tti';S=R/'build/llvm24-tti/fusion-search-llvm24'
items=[]
for c in ['boost-mapairy','hypersonic','tigre-siddon','srad','hipims','cholla-hlld','reentry']:
 d=R/'experiments/postopt-suite-comparison-v2'/c;p=json.loads((d/'plan.json').read_text());items.append(dict(case=c,source=p['source'],function=p['function'],debug=str(d/'v1-debug')))
v=R/'work/postopt/vllm-catalog-trials-v1/sample-2';items.insert(0,dict(case='vllm-quant',source=str(v/'state-0.ll'),function='cache_eval',debug=str(v),scope='existing HIP software quantization port, not original CUDA NVFP4'))
g=Path('/home/chh/divergence-strategy-search/explorations/hipims-integration-20261104');role=json.loads((g/'george-manual-ssa-v1/roles.json').read_text())['george_cartesian'];items.append(dict(case='hipims-george',source=role['rows']['original']['output'],function=role['symbol'],scope='historical original full-kernel IR; not registered as standalone suite case'))
(O/'plan.json').write_text(json.dumps(items,indent=2));results=[]
for item in items:
 c=item['case'];d=O/c;d.mkdir();row=dict(item);src=Path(item['source']);row['source_sha256']=hashlib.sha256(src.read_bytes()).hexdigest()
 p=subprocess.run([str(W),str(src),item['function']],capture_output=True,text=True,timeout=60);(d/'tti.stderr').write_text(p.stderr);row['tti_exit']=p.returncode
 if p.returncode==0:
  (d/'tti.json').write_text(p.stdout);j=json.loads(p.stdout);row.update(cost=j['cost'],instructions=j['instructions'],unknown=j['unknown'],target=j['cpu'],adjustment=j['compatibility_adjustment'],unknown_instructions=[x for x in j['instruction_costs'] if x['reason']])
 else:row['error']=p.stderr[-1500:]
 if item.get('debug'):
  debug=Path(item['debug']);candidates=[]
  for f in debug.glob('trial-*/trial.json'):
   t=json.loads(f.read_text())
   if t['valid'] and t['version']==0:candidates.append((int(f.parent.name.split('-')[1]),t))
  if candidates:
   _,t=min(candidates);_,split,left,right=t['candidate'].split(':');parent=debug/'state-0.ll'
   cmd=[str(S),'--ir',str(parent),'--function',item['function'],'--cleanup','postopt-fp','--split',split,'--left',left,'--right',right,'--out',str(d/'pair.ll'),'--debug-dir',str(d/'pair-debug')]
   p=subprocess.run(cmd,capture_output=True,text=True,timeout=120);(d/'pair.log').write_text(p.stdout+p.stderr);row['pair_exit']=p.returncode
   f=d/'pair-debug/trial-0/trial.json'
   if f.exists():
    t=json.loads(f.read_text());score=t['score_result'];row.update(pair_candidate=t['candidate'],pair_valid=t['valid'],pair_score_status=score['status'],pair_reason=score['reason'],pair_gain=score['static_gain'])
  else:row['pair_status']='no archived valid version-0 trial'
 else:row['pair_status']='not registered; historical IR audit only'
 results.append(row);(O/'summary.json').write_text(json.dumps(results,indent=2));print(c,row.get('unknown',row.get('error')),row.get('pair_score_status',row.get('pair_status')),flush=True)
