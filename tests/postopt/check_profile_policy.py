#!/usr/bin/env python3
import argparse,copy,json,subprocess,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
R=Path(__file__).resolve().parents[2];source=R/'work/postopt/landau-continuous-cached-v2/state-4.ll';trial=R/'work/postopt/landau-continuous-cached-v2/trial-415';old=json.loads((trial/'trial.json').read_text())
binary=R/'build/fusion-search/fusion-search';binary_digest=hashlib.sha256(binary.read_bytes()).hexdigest()
profiles=[json.loads((R/f).read_text()) for f in ['analysis/postopt-step5-wave-profile-v1/portable-profile.json','analysis/postopt-step5-selected-profile-v1/portable-profile-v2.json']]
base=dict(schema='postopt-profile-bundle-v1',workload_id=profiles[0]['records'][0]['workload_id'],min_visits=100,profiles=profiles)
scenarios=[('static',None,None),('mixed',base,'accept'),('coherent',base|{'workload_id':profiles[0]['records'][1]['workload_id']},'reject'),('missing',None,'profile_missing')]
for name,edit,reason in [('stale',lambda b:b['profiles'][0].update(parent_hash='0'*40),'stale_parent_hash'),('unseen',lambda b:b.update(workload_id='unseen'),'workload_not_covered'),('undersampled',lambda b:b.update(min_visits=2000),'insufficient_visits'),('corrupt',lambda b:b['profiles'][0]['records'][0].update(counter_sha256='0'*64),'counter_hash_mismatch'),('wrong_target',lambda b:b['profiles'][0].update(target='gfx90a'),'stale_target'),('ambiguous',lambda b:b['profiles'][0]['records'].append(copy.deepcopy(b['profiles'][0]['records'][0])),'ambiguous_workload')]:
 b=copy.deepcopy(base);edit(b);scenarios.append((name,b,reason))
results=[];baseline=None
for name,bundle,expected in scenarios:
 d=a.out/name;d.mkdir();cmd=[str(R/'build/fusion-search/fusion-search'),'--ir',str(source),'--function','evaluate','--split','B23','--left','B24','--right','B37','--cleanup','darm-cfg-earlycse','--scorer','v2' if name=='static' else 'v5','--pressure-weight','0.1','--replay-parent-hash',old['parent_hash'],'--out',str(d/'result.ll'),'--debug-dir',str(d/'debug')]
 if bundle is not None:
  (d/'bundle.json').write_text(json.dumps(bundle,indent=2));cmd+=['--profile-bundle',str(d/'bundle.json')]
 run=subprocess.run(cmd,capture_output=True,text=True);(d/'run.log').write_text(run.stdout+run.stderr);assert run.returncode==0,(name,run.stderr)
 t=json.loads((d/'debug/trial-0/trial.json').read_text());s=t['score_result'];m=s['metrics']
 assert t['cleaned_hash']==old['cleaned_hash'] and t['control_hash']==old['control_hash'],name
 assert (d/'debug/trial-0/after.ll').read_bytes()==(trial/'after.ll').read_bytes(),name
 if name in ['missing','stale','wrong_target']:assert m['profile_condition_analysis_runs']==0
 if name in ['mixed','coherent']:assert m['profile_condition_analysis_runs']==1
 if name=='static':baseline=s
 elif expected in ['accept','reject']:
  assert t['decision']==expected and m['profile_used']==1,(name,t['decision'],s)
  i=0 if name=='mixed' else 1;offline=json.loads((R/f'analysis/postopt-step5-conditions-v2/weighted-{i}.json').read_text())
  assert m['profile_gain_lower']==offline['gain_lower'] and m['profile_gain_upper']==offline['gain_upper'],name
 else:
  assert m['profile_used']==0 and expected in s['reason'],(name,s)
  assert s['total']==baseline['total'] and s['static_gain']==baseline['static_gain'],name
 results.append(dict(case=name,decision=t['decision'],reason=s['reason'],profile_used=m.get('profile_used',0),score=s['total']))
assert hashlib.sha256(binary.read_bytes()).hexdigest()==binary_digest
(a.out/'verification.json').write_text(json.dumps(dict(compiler_sha256=binary_digest,unchanged_candidate_ir=True,all_tests_passed=True,cases=results),indent=2))
print('PASS compiler profile decisions, Python/C++ bound parity, seven fallbacks and unchanged IR')
