#!/usr/bin/env python3
"""Export post-opt per-block work for one authenticated trial, without a backend."""
import argparse,hashlib,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p,kind='sha256'):return hashlib.new(kind,p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--trial',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--admitted',action='store_true');a=p.parse_args()
 if not a.admitted:
  return subprocess.call([sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','postopt-work-pair-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--trial',str(a.trial.resolve()),'--out',str(a.out.resolve()),'--admitted'])
 trial=a.trial.resolve();t=json.loads((trial/'trial.json').read_text())
 if not t['valid']:raise ValueError('legal trial required')
 context=json.loads((trial/t['round_context']).read_text());function=t['candidate'].split(':')[0]
 files={'before':trial.parent/f'round-{t["version"]}-control.ll','after':trial/'after.ll'}
 expected={'before':t['control_hash'],'after':t['cleaned_hash']}
 for name,path in files.items():
  if sha(path,'sha1')!=expected[name]:raise ValueError('snapshot mismatch: '+name)
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);tool=ROOT/'build/fusion-search/postopt-work'
 records={}
 for stage,path in files.items():
  proc=subprocess.run([str(tool),str(path),function],capture_output=True,text=True,timeout=120)
  (out/(stage+'.stderr')).write_text(proc.stderr)
  if proc.returncode:raise RuntimeError('feature extraction failed: '+stage)
  data=json.loads(proc.stdout);records[stage]=data;(out/(stage+'.json')).write_text(proc.stdout)
  if sha(path,'sha1')!=expected[stage]:raise ValueError('source changed during extraction')
 metrics=t['score_result'].get('metrics',{})
 checks={}
 for stage in files:
  for field in ['work','instructions','unknown']:
   key=field+'_'+stage
   if key in metrics:
    checks[key]=records[stage][field]==metrics[key]
    if not checks[key]:raise ValueError('frozen score mismatch: '+key)
 result=dict(schema='postopt-block-work-pair-v1',candidate=t['candidate'],parent_hash=t['parent_hash'],cleanup=context['cleanup'],snapshots=expected,tool_sha256=sha(tool),feature_sha256={stage:sha(out/(stage+'.json')) for stage in files},frozen_score_checks=checks,work_delta=records['before']['work']-records['after']['work'],scope='post-opt static work partition only; execution weights and transformation provenance not inferred')
 (out/'report.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));return 0
if __name__=='__main__':raise SystemExit(main())
