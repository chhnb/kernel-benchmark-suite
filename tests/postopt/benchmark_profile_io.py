#!/usr/bin/env python3
"""Fixed four-mode CPU-only audit of profile policy and debug export cost."""
import argparse,hashlib,json,resource,subprocess,time,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
R=Path(__file__).resolve().parents[2];old=R/'work/postopt/profile-cost-v1/before-fusion-search';new=R/'build/fusion-search/fusion-search';source=R/'work/postopt/landau-continuous-cached-v2/state-4.ll';bundle=R/'analysis/postopt-profile-policy-v1/mixed-bundle.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files={str(p):sha(p) for p in [old,new,source,bundle]};orders=[['old_debug','new_plain','new_debug','old_plain'],['old_plain','new_debug','new_plain','old_debug'],['new_debug','old_debug','old_plain','new_plain']]
plan=dict(schema='profile-policy-debug-cost-v1',cpu_only=True,file_sha256=files,orders=orders,rounds=2,trials_budget=256,timeout_seconds=180)
(a.out/'plan.json').write_text(json.dumps(plan,indent=2));runs=[]
for repeat,order in enumerate(orders):
 for name in order:
  d=a.out/f'{repeat}-{name}';d.mkdir();exe=old if name.startswith('old') else new
  cmd=[str(exe),'--ir',str(source),'--function','evaluate','--out',str(d/'result.ll'),'--scorer','v5','--profile-bundle',str(bundle),'--cleanup','darm-cfg-earlycse','--pressure-weight','0.1','--rounds','2','--trials','256']
  if name.endswith('debug'):cmd+=['--debug-dir',str(d/'debug')]
  before=resource.getrusage(resource.RUSAGE_CHILDREN);start=time.perf_counter()
  with (d/'stdout.txt').open('w') as o,(d/'stderr.txt').open('w') as e:r=subprocess.run(cmd,stdout=o,stderr=e,timeout=180)
  elapsed=time.perf_counter()-start;after=resource.getrusage(resource.RUSAGE_CHILDREN);assert r.returncode==0,(name,r.returncode)
  stdout=(d/'stdout.txt').read_text();assert 'commits=2 trials=135 stop=round_budget' in stdout,stdout
  paths=[f for f in d.rglob('*') if f.is_file()]
  record=dict(repeat=repeat,mode=name,wall_seconds=elapsed,user_seconds=after.ru_utime-before.ru_utime,system_seconds=after.ru_stime-before.ru_stime,output_blocks=after.ru_oublock-before.ru_oublock,output_files=len(paths),output_bytes=sum(f.stat().st_size for f in paths),result_sha256=sha(d/'result.ll'))
  runs.append(record);print(json.dumps(record),flush=True)
assert len({r['result_sha256'] for r in runs})==1,'debug or policy optimization changed output'
for path,h in files.items():assert sha(Path(path))==h,'source or binary changed'
summary={}
for name in orders[0]:
 rows=[x for x in runs if x['mode']==name];summary[name]={k:statistics.median(r[k] for r in rows) for k in ['wall_seconds','user_seconds','system_seconds','output_blocks','output_files','output_bytes']}
report=dict(schema=plan['schema'],all_output_ir_identical=True,all_runs_commits=2,all_runs_trials=135,runs=runs,summary=summary,scope='three repetitions per mode on one frozen kernel; exploratory CPU/compiler diagnostics, no GPU performance claim')
(a.out/'report.json').write_text(json.dumps(report,indent=2));print(json.dumps(summary),flush=True)
