#!/usr/bin/env python3
"""Fixed CPU-only compiler-cost comparison; no kernel timing or GPU work."""
import argparse,json,subprocess,time,hashlib,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
R=Path(__file__).resolve().parents[2];old=R/'work/postopt/profile-cost-v1/before-fusion-search';new=R/'build/fusion-search/fusion-search';source=R/'work/postopt/landau-continuous-cached-v2/state-4.ll';bundle=R/'analysis/postopt-profile-policy-v1/mixed-bundle.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files={str(p):sha(p) for p in [old,new,source,bundle]};orders=[['static_v2','old_v5','new_v5'],['new_v5','old_v5','static_v2'],['old_v5','static_v2','new_v5']]
(a.out/'plan.json').write_text(json.dumps(dict(schema='postopt-profile-compile-cost-v1',cpu_only=True,orders=orders,rounds=2,trials_budget=256,file_sha256=files),indent=2))
runs=[];semantics={}
for repeat,order in enumerate(orders):
 for name in order:
  d=a.out/f'{repeat}-{name}';d.mkdir();exe=old if name=='old_v5' else new;cmd=[str(exe),'--ir',str(source),'--function','evaluate','--out',str(d/'result.ll'),'--debug-dir',str(d/'debug'),'--scorer','v2' if name=='static_v2' else 'v5','--cleanup','darm-cfg-earlycse','--pressure-weight','0.1','--rounds','2','--trials','256']
  if name!='static_v2':cmd+=['--profile-bundle',str(bundle)]
  start=time.perf_counter()
  with (d/'stdout.txt').open('w') as o,(d/'stderr.txt').open('w') as e:r=subprocess.run(cmd,stdout=o,stderr=e,timeout=180)
  elapsed=time.perf_counter()-start;assert r.returncode==0,(name,r.returncode)
  trials=[json.loads(f.read_text()) for f in sorted((d/'debug').glob('trial-*/trial.json'),key=lambda x:int(x.parent.name.split('-')[1]))]
  semantic=[]
  for t in trials:
   score=t['score_result'];semantic.append({k:t[k] for k in ['candidate','parent_hash','control_hash','cleaned_hash','decision']}|{k:score[k] for k in ['total','static_gain','parent_gain']})
  if name in semantics:assert semantic==semantics[name],'repeat semantic instability'
  semantics[name]=semantic
  record=dict(repeat=repeat,policy=name,wall_seconds=elapsed,trials=len(trials),output_sha256=sha(d/'result.ll'),score_ms=sum(t['timings_ms']['score_with_analysis'] for t in trials),profile_uses=sum(t['score_result']['metrics'].get('profile_used',0) for t in trials),condition_runs=sum(t['score_result']['metrics'].get('profile_condition_analysis_runs',0) for t in trials) if name=='new_v5' else None)
  runs.append(record);print(json.dumps(record),flush=True)
assert semantics['old_v5']==semantics['new_v5'],'optimized policy changed a candidate or score'
for path,digest in files.items():assert sha(Path(path))==digest,'benchmark input/executable changed'
summary={}
for name in orders[0]:
 rows=[r for r in runs if r['policy']==name];summary[name]={k:statistics.median(r[k] for r in rows) for k in ['wall_seconds','score_ms']};summary[name]['output_hashes']=sorted({r['output_sha256'] for r in rows});summary[name]['trials']=sorted({r['trials'] for r in rows})
report=dict(schema='postopt-profile-compile-cost-v1',unchanged_old_new_decisions_and_scores=True,source_and_binaries_unchanged=True,runs=runs,summary=summary,scope='one frozen Landau state; three ordered CPU-only runs per mode; exploratory compiler cost, not statistical generalization or GPU speedup')
(a.out/'report.json').write_text(json.dumps(report,indent=2))
