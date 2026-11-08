#!/usr/bin/env python3
import argparse,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
R=Path(__file__).resolve().parents[2];source=R/'work/postopt/landau-continuous-cached-v2/state-4.ll';bundle=R/'work/postopt/profile-policy-check-v1/mixed/bundle.json';binary=R/'build/fusion-search/fusion-search'
results=[]
for name,extra in [('greedy',[]),('changed-source',['--split','B23','--left','B24','--right','B37'])]:
 d=a.out/name;d.mkdir();input=source
 if name=='changed-source':input=d/'input.ll';input.write_text(source.read_text()+'\n@profile_stale_sentinel = private constant i8 0\n')
 cmd=[str(binary),'--ir',str(input),'--function','evaluate','--out',str(d/'result.ll'),'--debug-dir',str(d/'debug'),'--scorer','v5','--profile-bundle',str(bundle),'--pressure-weight','0.1','--cleanup','darm-cfg-earlycse','--rounds','2','--trials','256',*extra]
 r=subprocess.run(cmd,capture_output=True,text=True,timeout=180);(d/'run.log').write_text(r.stdout+r.stderr);assert r.returncode==0,r.stderr
 trials=[json.loads(f.read_text()) for f in (d/'debug').glob('trial-*/trial.json')]
 if name=='greedy':
  used=[t for t in trials if t['score_result']['metrics'].get('profile_used')==1];assert used and all(t['version']==0 for t in used)
  later=[t for t in trials if t['version']>0];assert later
  assert all(t['score_result']['metrics'].get('profile_used',0)==0 for t in later)
  summary=json.loads((d/'debug/result.json').read_text());results.append(dict(case=name,initial_profile_uses=len(used),later_trials=len(later),later_profile_uses=0,result=summary))
 else:
  t=trials[0];assert t['score_result']['metrics']['profile_used']==0 and 'stale_parent_hash' in t['score_result']['reason'];results.append(dict(case=name,reason=t['score_result']['reason']))
(a.out/'verification.json').write_text(json.dumps(dict(all_tests_passed=True,cases=results),indent=2))
print('PASS initial source binding, post-commit profile invalidation, changed-source fallback')
