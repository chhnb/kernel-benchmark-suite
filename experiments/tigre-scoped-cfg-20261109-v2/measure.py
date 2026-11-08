from pathlib import Path
import json,subprocess,hashlib,time,importlib.util
S=Path('/home/chh/kernel-benchmark-suite');root=S/'experiments/tigre-scoped-cfg-20261109-v2';out=root/'measure';out.mkdir(exist_ok=False)
binaries={'unmerged':S/'experiments/tigre-new-greedy-vs-artifact-darm-20261108-v1/pair/baseline.hsaco','original_darm':root/'pair/baseline.hsaco','hybrid':root/'pair/variant.hsaco','previous_greedy':S/'experiments/tigre-intrinsic-match-20261109-v1/pair/variant.hsaco'}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
plan={'case':'tigre-siddon','scope':'TIGRE full Siddon head64 50 projections; scoped CFG cleanup versus previous greedy and original artifacts DARM versus original artifacts DARM; common final O3','timing':'event','batches':4,'warmup':3,'repeat':15,'order':[['unmerged','original_darm','previous_greedy','hybrid'],['original_darm','previous_greedy','hybrid','unmerged'],['previous_greedy','hybrid','unmerged','original_darm'],['hybrid','unmerged','original_darm','previous_greedy']],'binaries':{k:{'path':str(v),'sha256':sha(v)} for k,v in binaries.items()},'status':'planned','commands':[],'execution_retry':False,'prelaunch_admission_attempts':3,'prelaunch_readonly_wait_seconds':60,'minimum_log_effect':0.02,'admission_waits':[]}
def save(n):(out/n).write_text(json.dumps(plan,indent=2))
save('plan.json');spec=importlib.util.spec_from_file_location('ad','/home/chh/divergence-strategy-search/tools/gpu_admission.py');ad=importlib.util.module_from_spec(spec);spec.loader.exec_module(ad)
def run(role,phase,dest):
 for attempt in range(3):
  if dest.exists():
   assert not (dest/'output').exists() and not (dest/'terminal.json').exists(),'executed work must not be retried'
   probes=json.loads((dest/'admission.json').read_text());assert not all(x['admitted'] for x in probes)
   denied=dest.with_name(dest.name+'-denied-prelaunch-'+str(attempt));assert not denied.exists();dest.rename(denied)
  ready=False
  for _ in range(30):
   r=ad.probe_amd('/home/chh/divergence-strategy-search/explorations/darm-next-stage-main-20260923/owners.jsonl',512);plan['admission_waits'].append({'time':r['time'],'admitted':r['admitted'],'errors':r['errors']});save('progress.json')
   if r['admitted']:ready=True;break
   time.sleep(2)
  assert ready,'no admitted snapshot within bounded wait'
  assert sha(binaries[role])==plan['binaries'][role]['sha256']
  cmd=[str(S/'bench'),plan['case'],phase,'--kernel',str(binaries[role]),'--out',str(dest),'--warmup','3','--repeat','15']
  if phase=='benchmark':cmd+=['--validated',str(out/(role+'-validation'))]
  plan['commands'].append(cmd);save('progress.json');rc=subprocess.run(cmd,cwd=S).returncode
  assert sha(binaries[role])==plan['binaries'][role]['sha256']
  if rc==0:return
  if (dest/'output').exists() or (dest/'terminal.json').exists():raise RuntimeError('GPU execution failed; no retry')
 raise RuntimeError('bounded prelaunch admission attempts exhausted')
try:
 for role in binaries:run(role,'validate',out/(role+'-validation'))
 for b,order in enumerate(plan['order']):
  for role in order:run(role,'benchmark',out/(role+'-batch-'+str(b)))
 plan['status']='completed'
except Exception as e:plan['status']='stopped_preserved';plan['error']=str(e);raise
finally:save('terminal.json')
