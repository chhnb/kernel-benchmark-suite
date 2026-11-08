from pathlib import Path
import json,subprocess,time
R=Path('/home/chh/kernel-benchmark-suite');O=R/'experiments/llvm24-adjacent-v1-eight-v1';O.mkdir(exist_ok=False)
S=R/'build/llvm24-tti/fusion-search-llvm24';W=R/'tools/run-llvm24-tti'
items=json.loads((R/'experiments/llvm24-focus-nine-20261108-v1/plan.json').read_text());items=[i for i in items if i['case']!='hipims-george'];items.sort(key=lambda x:x['case']=='vllm-quant')
rows=[]
for it in items:
 d=O/it['case'];d.mkdir();t=time.monotonic()
 cmd=[str(S),'--ir',it['source'],'--function',it['function'],'--cleanup','postopt-fp','--adjacent-only','1','--rounds','4','--trials','2000','--out',str(d/'result.ll'),'--debug-dir',str(d/'debug')]
 (d/'command.json').write_text(json.dumps(cmd))
 with (d/'run.log').open('w') as log:p=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,timeout=1100)
 row=dict(case=it['case'],exit=p.returncode,seconds=time.monotonic()-t)
 if p.returncode==0:
  row['result']=json.loads((d/'debug/result.json').read_text());row['commits']=[]
  for f in sorted((d/'debug').glob('commit-*.json'),key=lambda p:int(p.stem.split('-')[1])):
   j=json.loads(f.read_text());sc=j['score_result'];row['commits'].append(dict(version=j['version'],candidate=j['candidate'],before=sc['metrics'].get('work_before'),after=sc['metrics'].get('work_after'),gain=sc['static_gain']))
  reasons={};roundcounts={}
  for f in (d/'debug').glob('trial-*/trial.json'):
   j=json.loads(f.read_text());k=str(j['version']);roundcounts[k]=roundcounts.get(k,0)+1
   reason=j['reason'] if not j['valid'] else j['score_result']['reason'];reasons[reason]=reasons.get(reason,0)+1
  row['round_candidates']=roundcounts;row['reasons']=reasons
  # Re-enumerate the committed state to document newly available neighbors.
  cp=subprocess.run([str(S),'--ir',str(d/'result.ll'),'--function',it['function'],'--cleanup','postopt-fp','--adjacent-only','1','--catalog-only','1','--out',str(d/'final-catalog.ll'),'--debug-dir',str(d/'final-catalog')],capture_output=True,text=True,timeout=120)
  if cp.returncode==0:row['final_adjacent_candidates']=json.loads((d/'final-catalog/catalog.json').read_text())['count']
  # Independently query final IR. This does not time or execute the GPU.
  cp=subprocess.run([str(W),str(d/'result.ll'),it['function']],capture_output=True,text=True,timeout=90)
  (d/'final-cost.log').write_text(cp.stderr)
  if cp.returncode==0:
   (d/'final-cost.json').write_text(cp.stdout);j=json.loads(cp.stdout);row['final_cost']=j['cost'];row['final_unknown']=j['unknown']
   if row['commits']:assert j['cost']==row['commits'][-1]['after'],it['case']
 rows.append(row);(O/'summary.json').write_text(json.dumps(rows,indent=2));print(json.dumps(row),flush=True)
