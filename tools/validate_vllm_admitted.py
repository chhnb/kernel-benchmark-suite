from pathlib import Path
import json,sys,os,fcntl,importlib.util,subprocess,shutil
S=Path('/home/chh/kernel-benchmark-suite');R=Path('/home/chh/divergence-strategy-search');P=S/'cases/vllm-quant';D=S/'results/vllm-cuda-validation-v1';D.mkdir(exist_ok=False)
A=D/'artifacts';A.mkdir();shutil.copy2(S/'results/vllm-cuda-software-v1/cache.cubin',A/'cache.cubin');shutil.copy2(S/'results/vllm-cuda-llvm-binary-v1/llvm-cache.cubin',A/'llvm-cache.cubin')
rid='kernel-benchmark-suite-vllm-cuda-validation-v1'
cmd=['/home/chh/region-fusion-lab/.venv/bin/python',str(P/'harness/validate_cuda.py'),'gpu',str(D/'output'),str(A)]
req=dict(id=rid,main_scope_review=True,single_kernel_scope='Full software cache_eval; no timing. CPU model forward and oracle outside kernel.',budget='60 frozen KV fixtures per compiler, NVCC and LLVM12:120 launches, no retries',oracle='four complete byte outputs, input immutability, tail guards and corruption negatives',command=cmd,source=str(P/'source'),inputs=str(P/'inputs/kv/manifest.json'),historical_gpu_requests_reused=False)
(D/'request.json').write_text(json.dumps(req,indent=2))
spec=importlib.util.spec_from_file_location('ad',R/'tools/gpu_admission.py');ad=importlib.util.module_from_spec(spec);spec.loader.exec_module(ad);ad.UUID='GPU-15f5b4da-5dfd-4953-31a1-f4eeb93e2023'
def update(status):
 with (R/'cases/.queue-update.lock').open('a') as a,(R/'.queue.lock').open('a') as b:
  fcntl.flock(a,2);fcntl.flock(b,2);f=R/'cases/queue.json';q=json.loads(f.read_text())
  if status=='running':
   assert not q.get('active_gpu') and not q.get('active_gpu_job');q['active_gpu']={'id':rid,'pid':os.getpid(),'owner':str(S)};q['active_gpu_job']=rid
  elif (q.get('active_gpu') or {}).get('id')==rid:q['active_gpu']=None;q['active_gpu_job']=None
  q[rid]=dict(status=status,owner=str(S),request=str(D/'request.json'));t=f.with_suffix('.benchmark.tmp');t.write_text(json.dumps(q,indent=2));t.replace(f)
with ad.gpu_batch_lock():
 probes=[ad.probe(512) for _ in range(3)];(D/'admission.json').write_text(json.dumps(probes,indent=2))
 if not all(x['admitted'] for x in probes):
  update('denied_retired');print('Admission denied; zero GPU launches');sys.exit(2)
 update('running');rc=-1
 try:
  with (D/'stdout').open('w') as o,(D/'stderr').open('w') as e:rc=subprocess.run(cmd,cwd=P,stdout=o,stderr=e,timeout=600).returncode
  (D/'terminal.json').write_text(json.dumps({'exit':rc}));print('GPU validation exit',rc)
 finally:update('pending_root_review' if rc==0 else 'failed_preserved_retired')
 raise SystemExit(rc)
