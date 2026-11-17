#!/usr/bin/env python3
"""Compare real-driver reference/scoped-full/scoped-reuse chains, not just finals."""
import argparse,json,os,re,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('reference',type=Path);p.add_argument('full',type=Path);p.add_argument('reuse',type=Path);p.add_argument('--out',type=Path,required=True)
p.add_argument('--require-reuse',action='store_true')
a=p.parse_args();root=Path(__file__).resolve().parents[2]
env=dict(os.environ);env['LD_LIBRARY_PATH']=str(root/'build/llvm12-jammy/usr/lib/x86_64-linux-gnu')+':'+env.get('LD_LIBRARY_PATH','')
reports=[json.loads((d/'summary.json').read_text()) for d in (a.reference,a.full,a.reuse)]
assert all(s['status']=='completed' for s in reports)
def chain(s):
 out=[]
 for r in s['rounds']:
  if not r['selected']:continue
  x=next(x for x in r['attempts'] if x['directory']==r['selected'])
  out.append((r,x))
 return out
chains=list(map(chain,reports));assert len({len(c) for c in chains})==1
rows=[]
for n,triplet in enumerate(zip(*chains)):
 signatures=[(r['decision'],x['candidate'],r['selected_cost']) for r,x in triplet]
 assert signatures[0]==signatures[1]==signatures[2],(n,signatures)
 paths=[Path(r['selected'])/'fused.ll' for r,x in triplet]
 normalize=lambda path:re.sub(r'^; ModuleID = .*\n','',path.read_text())
 assert normalize(paths[1])==normalize(paths[2]),('scoped IR mismatch',n)
 for path in paths:
  subprocess.run([str(root/'build/llvm12-jammy/usr/bin/opt-12'),'-verify','-disable-output',str(path)],env=env,check=True,capture_output=True)
 d=subprocess.run([str(root/'build/llvm12-jammy/usr/bin/llvm-diff-12'),str(paths[0]),str(paths[1])],env=env,text=True,capture_output=True)
 assert d.returncode==0,(n,d.stderr)
 rows.append(dict(step=n+1,candidate=signatures[0][1],cost=signatures[0][2],reference_llvm_diff=0,scoped_ir_equal=True))
full,reuse=reports[1]['scoped_trials'],reports[2]['scoped_trials']
assert full['whole_trials_reused']==0
if a.require_reuse:assert reuse['whole_trials_reused']>0, 'parity alone does not prove cross-commit trial reuse'
assert full['local_trials']-reuse['local_trials']==reuse['whole_trials_reused']
# No reused local candidate is sent to the external trial queue, and no trial
# cleanup/debug directory exists for it. A selected candidate may have fused.ll
# from commit-only replay; that is not another generation/cleanup/scoring trial.
requests=set()
for path in a.reuse.glob('trial-queue-*.json'):
 for r in json.loads(path.read_text()):requests.add(str(Path(r['status']).parent))
hits=[]
for r in reports[2]['rounds']:
 for x in r['attempts']:
  if x.get('whole_trial_reused'):
   path=Path(x['directory']);assert str(path) not in requests
   assert not (path/'structural').exists()
   hits.append(x['stable_identity'])
assert len(hits)==reuse['whole_trials_reused']
result=dict(steps=rows,full=full,reuse=reuse,reused_local_candidates_not_dispatched=len(hits),default_driver_policy='whole-function',scoped_policy_is_separate=True)
a.out.write_text(json.dumps(result,indent=2)+'\n')
print('PASS',len(rows),'steps: identities/ties/costs/verifier/IR; skipped',len(hits),'entire local trials')
