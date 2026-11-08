#!/usr/bin/env python3
"""Freeze a bounded catalog sample, then run isolated CPU-only trials."""
import argparse,hashlib,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser();p.add_argument('--catalog',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--count',type=int,default=8);p.add_argument('--seed',default='postopt-catalog-2026-11-07')
 p.add_argument('--exclude-root',type=Path);p.add_argument('--static-alloca-cost',type=int);p.add_argument('--admitted',action='store_true',help=argparse.SUPPRESS)
 a=p.parse_args()
 if a.count<1 or a.count>64:raise ValueError('count must be 1..64')
 if a.static_alloca_cost is not None and a.static_alloca_cost<=0:raise ValueError('positive alloca cost required')
 if not a.admitted:
  argv=[sys.executable,str(Path(__file__).resolve()),'--catalog',str(a.catalog.resolve()),'--out',str(a.out.resolve()),'--count',str(a.count),'--seed',a.seed,'--admitted']
  if a.exclude_root:argv+=['--exclude-root',str(a.exclude_root.resolve())]
  if a.static_alloca_cost:argv+=['--static-alloca-cost',str(a.static_alloca_cost)]
  return subprocess.call([sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','postopt-catalog-trials-'+str(time.time_ns()),*argv])
 catalog=json.loads(a.catalog.read_text())
 if catalog['schema']!='postopt-candidate-catalog-v1':raise ValueError('unsupported catalog')
 source=Path(catalog['source_ir']);source_hash=hashlib.sha256(source.read_bytes()).hexdigest()
 excluded=set()
 if a.exclude_root:
  for f in a.exclude_root.rglob('manifest.json'):
   t=json.loads(f.read_text()).get('trial',{})
   if isinstance(t,dict) and t.get('parent_hash')==catalog['parent_hash']:excluded.add(t['candidate'])
 choices=[c for c in catalog['candidates'] if c['candidate'] not in excluded]
 rank=lambda c:hashlib.sha256(json.dumps([a.seed,catalog['parent_hash'],c['candidate']]).encode()).hexdigest()
 selected=sorted(choices,key=rank)[:a.count]
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
 plan={'catalog':str(a.catalog.resolve()),'catalog_sha256':hashlib.sha256(a.catalog.read_bytes()).hexdigest(),'parent_hash':catalog['parent_hash'],'source_sha256':source_hash,'seed':a.seed,'population':len(choices),'excluded_candidates':len(excluded),'selection':'seeded hash sample without replacement before scoring','samples':selected,'scorer':'v2','pressure_weight':.1,'static_alloca_cost':a.static_alloca_cost,'gpu_execution':False}
 (out/'plan.json').write_text(json.dumps(plan,indent=2));results=[]
 for index,c in enumerate(selected):
  name='sample-'+str(index);debug=out/name
  argv=[str(ROOT/'build/fusion-search/fusion-search'),'--ir',str(source),'--function',c['function'],'--split',c['split'],'--left',c['left'],'--right',c['right'],'--cleanup',catalog['cleanup'],'--opt-level',str(catalog['opt_level']),'--scorer','v2','--pressure-weight','0.1','--out',str(out/(name+'.ll')),'--debug-dir',str(debug)]
  if a.static_alloca_cost:argv+=['--static-alloca-cost',str(a.static_alloca_cost)]
  with (out/(name+'.log')).open('w') as f:
   try:code=subprocess.run(argv,stdout=f,stderr=subprocess.STDOUT,timeout=120).returncode
   except subprocess.TimeoutExpired:code='timeout_120s'
  row={'candidate':c['candidate'],'debug':str(debug),'argv':argv,'exit_code':code}
  trial=debug/'trial-0/trial.json'
  if trial.exists():
   t=json.loads(trial.read_text())
   if t['parent_hash']!=catalog['parent_hash']:raise ValueError('catalog/trial parent mismatch')
   row.update(valid=t['valid'],reason=t['reason'],score_status=t['score_result']['status'],eligible=t['eligible'])
  if hashlib.sha256(source.read_bytes()).hexdigest()!=source_hash:raise ValueError('source changed')
  results.append(row);(out/'results.json').write_text(json.dumps(results,indent=2))
  print(name,json.dumps(row),flush=True)
 return 2 if any(r['exit_code'] not in (0,4) for r in results) else 0
if __name__=='__main__':raise SystemExit(main())
