import json,subprocess,collections
from pathlib import Path
r=Path('/home/chh/kernel-benchmark-suite');o=r/'experiments/logical-state-eight-catalog-20261108-v2';o.mkdir(exist_ok=False)
items=json.loads((r/'experiments/llvm24-focus-nine-20261108-v1/plan.json').read_text());summary=[]
for it in items:
 if it['case']=='hipims-george':continue
 d=o/it['case'];d.mkdir()
 p=subprocess.run([str(r/'build/llvm24-tti/fusion-search-llvm24'),'--ir',it['source'],'--function',it['function'],'--catalog-only','1','--adjacent-only','1','--cleanup','postopt-fp','--out',str(d/'source.ll'),'--debug-dir',str(d/'debug')],capture_output=True,text=True,timeout=120)
 (d/'command.log').write_text(p.stdout+p.stderr);assert p.returncode==0,(it['case'],p.stderr[-500:])
 cat=json.loads((d/'debug/catalog.json').read_text());s=json.loads((d/'debug/logical-state-0.json').read_text());record={'case':it['case'],'candidate_realizations':cat['count'],'logical_pairs':len({(c['logical_decision'],c['logical_left'],c['logical_right']) for c in cat['candidates']}),'ordered_groups':sum(g['status']=='ordered' for g in s['decisions']),'unsupported':dict(collections.Counter(g['reason'] for g in s['decisions'] if g['status']!='ordered'))};summary.append(record);print(record,flush=True)
 if it['case']=='vllm-quant':
  g=next(g for g in s['decisions'] if g['join']=='%quant_decide.exit685');leaves=g['leaves'];a=next(x['id'] for x in leaves if x['initial_block']=='%if.then19.i680');b=next(x['id'] for x in leaves if x['initial_block']=='%if.then23.i683');c=next(x['id'] for x in leaves if x['initial_block']=='%if.end29.i684');pairs={(x['logical_left'],x['logical_right']) for x in cat['candidates']};assert (a,c) not in pairs and (a,b) in pairs and (b,c) in pairs,(a,b,c,pairs);record['tail_3_4_6_verified']=True
(o/'summary.json').write_text(json.dumps(summary,indent=2))
