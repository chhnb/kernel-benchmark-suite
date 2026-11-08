#!/usr/bin/env python3
from pathlib import Path
import argparse,json,sys,os,fcntl,subprocess,importlib.util,time
S=Path(__file__).resolve().parents[1];R=Path('/home/chh/divergence-strategy-search')
p=argparse.ArgumentParser();p.add_argument('case');p.add_argument('phase',choices=['validate','benchmark']);p.add_argument('--out',required=True);p.add_argument('--validated',type=Path);p.add_argument('--kernel',type=Path);p.add_argument('--build',type=Path);p.add_argument('--input',type=Path);p.add_argument('--timing',choices=['event','graph'],default='event');p.add_argument('--warmup',type=int,default=2);p.add_argument('--repeat',type=int,default=5);a=p.parse_args()
assert a.warmup>=0 and a.repeat>0
assert not (a.kernel and a.build),'choose --kernel or --build'
P=S/'cases'/a.case;m=json.loads((P/'case.json').read_text());rt=m['runtime'];assert m.get('enabled',True),'case inactive: '+m.get('inactive_reason','');D=Path(a.out).resolve();D.mkdir(parents=True,exist_ok=False)
assert rt['kind']=='cpp'
if a.build:
 receipt=json.loads((a.build/'receipt.json').read_text());assert receipt['build_passed'] and receipt['case']==a.case
 a.kernel=a.build/m['profiles'][receipt['profile']]['artifact']
kernel=(a.kernel or Path(rt['default_kernel'])).resolve();runner=(S/rt['runner']).resolve()
assert a.timing in rt['timing_modes'],'timing mode not supported by this case'
inputs=[a.input.resolve()] if a.input else [(P/x).resolve() for x in rt['inputs']]
snap={str(x):[x.stat().st_size,x.stat().st_mtime_ns] for x in [kernel,runner]}
input_snapshot={}
for x in inputs:
 files=sorted(x.rglob('*')) if x.is_dir() else [x] if x.is_file() else sorted(x.parent.glob(x.name+'*'))
 if x.is_file() and x.name=='input.txt':
  for line in x.read_text().splitlines():
   parts=line.split()
   if not parts:continue
   refs=([parts[2]]+([parts[4]] if parts[4]!='-' else [])) if parts[0]=='buffer' else [parts[2]] if parts[0]=='exactref' or parts[:2]==['arg','file'] else []
   files.extend((x.parent/r).resolve() for r in refs)
 assert files,'missing input'
 for f in files:
  if f.is_file():input_snapshot[str(f)]=[f.stat().st_size,f.stat().st_mtime_ns]
if a.phase=='benchmark':
 assert a.validated is not None
 prev=json.loads((a.validated/'accepted.json').read_text());assert prev['passed'] and prev['binary_snapshot']==snap
 assert prev['input_snapshot']==input_snapshot and prev['timing_mode']==a.timing,'validate same inputs and timing mode first'
commands=[]
for i,x in enumerate(inputs):
 commands.append([str(runner),'--kernel',str(kernel),'--input',str(x),'--output',str(D/'output'/str(i)),'--mode',a.phase,'--timing',a.timing,'--warmup',str(a.warmup),'--repeat',str(a.repeat)])
cmd=commands
rid='benchmark-suite-'+a.case+'-'+a.phase+'-'+str(time.time_ns());req=dict(id=rid,main_scope_review=True,scope=rt['scope'],phase=a.phase,command=cmd,binary_snapshot=snap,budget='one full-output validation per final benchmark fixture' if a.phase=='validate' else f'{a.warmup} warmups and {a.repeat} measurements per final benchmark fixture, full outputs checked; no retry',no_historical_requests_replayed=True)
(D/'request.json').write_text(json.dumps(req,indent=2))
def queue(status):
 with (R/'cases/.queue-update.lock').open('a') as x,(R/'.queue.lock').open('a') as y:
  fcntl.flock(x,2);fcntl.flock(y,2);f=R/'cases/queue.json';q=json.loads(f.read_text())
  if status=='running':
   assert not q.get('active_gpu') and not q.get('active_gpu_job');q['active_gpu']={'id':rid,'pid':os.getpid(),'owner':str(S)};q['active_gpu_job']=rid
  elif (q.get('active_gpu') or {}).get('id')==rid:q['active_gpu']=None;q['active_gpu_job']=None
  q[rid]={'status':status,'owner':str(S),'request':str(D/'request.json')};tmp=f.with_suffix('.suite.tmp');tmp.write_text(json.dumps(q,indent=2));tmp.replace(f)
spec=importlib.util.spec_from_file_location('ad',R/'tools/gpu_admission.py');ad=importlib.util.module_from_spec(spec);spec.loader.exec_module(ad);ad.UUID='GPU-15f5b4da-5dfd-4953-31a1-f4eeb93e2023'
with ad.gpu_batch_lock():
 # Let the privileged collector observe this newly started request process.
 # This is a pre-probe settling barrier, not an admission retry.
 if rt['backend']=='amd':time.sleep(3)
 probes=[]
 for _ in range(3):
  probes.append(ad.probe_amd(str(R/'explorations/darm-next-stage-main-20260923/owners.jsonl'),512) if rt['backend']=='amd' else ad.probe(512))
 (D/'admission.json').write_text(json.dumps(probes,indent=2))
 if not all(x['admitted'] for x in probes):queue('denied_retired');print('Admission denied; no GPU execution');raise SystemExit(2)
 queue('running');rc=-1
 try:
  env=os.environ.copy();env['LD_LIBRARY_PATH']=Path('/home/chh/region-fusion-lab/work/rocm-library-path.txt').read_text().strip()+':/usr/local/cuda/lib64';env['PYTHONPATH']='/home/chh/region-fusion-lab';env.update(rt.get('environment',{}))
  (D/'output').mkdir()
  for i,command in enumerate(commands):
   with (D/f'stdout-{i}').open('w') as o,(D/f'stderr-{i}').open('w') as e:
    proc=subprocess.Popen(command,cwd=P,stdout=o,stderr=e,env=env,start_new_session=True)
    try:rc=proc.wait(timeout=900)
    except subprocess.TimeoutExpired:
     import signal
     os.killpg(proc.pid,signal.SIGKILL);proc.wait();rc=124
   if rc:break
  (D/'terminal.json').write_text(json.dumps({'exit':rc}))
  if rc==0:(D/'accepted.json').write_text(json.dumps({'passed':True,'phase':a.phase,'binary_snapshot':snap,'input_snapshot':input_snapshot,'timing_mode':a.timing,'scope':rt['scope'],'result':str(D/'output')},indent=2))
 finally:queue('completed_retired' if rc==0 else 'failed_preserved_retired')
 print(a.case,a.phase,'exit',rc)
 if rc:print((D/f'stderr-{i}').read_text()[-2500:])
 raise SystemExit(rc)
