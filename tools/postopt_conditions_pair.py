#!/usr/bin/env python3
"""Run predicate analysis using observed provenance and authenticated trial IR."""
import argparse,json,hashlib,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha1(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--trial',type=Path,required=True);p.add_argument('--profile-parent',type=Path);p.add_argument('--out',type=Path,required=True);p.add_argument('--admitted',action='store_true');a=p.parse_args()
 if not a.admitted:
  cmd=[sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','postopt-conditions-pair-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--trial',str(a.trial.resolve()),'--out',str(a.out.resolve()),'--admitted']
  if a.profile_parent:cmd+=['--profile-parent',str(a.profile_parent.resolve())]
  return subprocess.call(cmd)
 trial=a.trial.resolve();t=json.loads((trial/'trial.json').read_text());origin=json.loads((trial/'block-provenance.json').read_text());run=json.loads((trial.parent/'run.json').read_text())
 if not t['valid'] or any(origin[k]!=t[k] for k in ['candidate','parent_hash','cleaned_hash']):raise ValueError('trial/provenance mismatch')
 function,_,left,right=t['candidate'].split(':')
 if t['orientation_swapped']:left,right=right,left
 rows=[r for r in origin['blocks'] if [r['left_source_id'],r['right_source_id']]==[left,right]]
 if len(rows)!=1 or not rows[0]['cleaned_block']:raise ValueError('selected block provenance unavailable')
 row=rows[0];before=trial.parent/f'round-{t["version"]}-control.ll';after=trial/'after.ll';parent=a.profile_parent.resolve() if a.profile_parent else (trial/t['parent_ir']).resolve()
 expected_parent=run.get('replay_parent_hash',t['parent_hash']) if a.profile_parent else t['parent_hash']
 expected={before:t['control_hash'],after:t['cleaned_hash'],parent:expected_parent}
 for path,h in expected.items():
  if sha(path)!=h:raise ValueError('IR snapshot mismatch: '+str(path))
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);tool=ROOT/'build/fusion-search/postopt-conditions'
 cmd=[str(tool),str(before),str(after),function,row['left_alignment_label'],row['right_alignment_label'],row['cleaned_block'],str(parent)]
 plan=dict(schema='postopt-conditions-pair-v1',candidate=t['candidate'],command=cmd,input_sha1={str(p):h for p,h in expected.items()},provenance_sha256=hashlib.sha256((trial/'block-provenance.json').read_bytes()).hexdigest(),tool_sha256=hashlib.sha256(tool.read_bytes()).hexdigest())
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
 r=subprocess.run(cmd,capture_output=True,text=True,timeout=120);(out/'stderr.txt').write_text(r.stderr);(out/'terminal.json').write_text(json.dumps(dict(exit=r.returncode)))
 if r.returncode:raise RuntimeError('condition analysis unsupported/failed: '+r.stderr)
 data=json.loads(r.stdout)
 if data['before_ir_sha1']!=expected[before] or data['after_ir_sha1']!=expected[after] or data['parent_ir_sha1']!=expected[parent]:raise ValueError('parsed buffer identity mismatch')
 for path,h in expected.items():
  if sha(path)!=h:raise ValueError('source changed')
 (out/'conditions.json').write_text(r.stdout);print('union_proven',data['union_proven']);return 0
if __name__=='__main__':raise SystemExit(main())
