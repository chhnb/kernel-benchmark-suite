"""Measure normalization alone against its parent with the admitted C++ runner."""
from pathlib import Path
import argparse,subprocess,json,hashlib,csv,statistics,time,shutil,math
p=argparse.ArgumentParser();p.add_argument('--suite',type=Path,required=True);p.add_argument('--compiled',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--cases',nargs='+',choices=['mapairy','vllm'],default=['mapairy','vllm']);p.add_argument('--scope',default='normalization only; no fusion');p.add_argument('--variant',action='append',default=[],help='ROLE=/absolute/file.hsaco; replaces default normalized variant');a=p.parse_args();s=a.suite.resolve();out=a.out.resolve();out.mkdir(exist_ok=False)
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(8<<20),b''):h.update(b)
 return h.hexdigest()
def save(name,x):(out/name).write_text(json.dumps(x,indent=2))
manifest=s/'regression/golden/20261110-generated-gfx906-v1/manifest.json';m=json.loads(manifest.read_text());archive=manifest.parent
for rel,h in m['sha256'].items():assert sha(archive/rel)==h
assert sha(s/m['generator_source'])==m['generator_sha256']
subprocess.run(['python3',str(s/'tools/run_cpu.py'),'decision-gpu-inputs-'+str(time.time_ns()),'python3',str(Path(__file__).with_name('prepare_gpu_inputs.py')),str(s),str(out/'generated')],check=True)
inputs=json.loads((out/'generated/inputs.json').read_text());save('generation.json',inputs)
results={};plan={'scope':a.scope,'warmup':3,'repeat':15,'batches':3,'commands':[],'status':'running'};save('plan.json',plan)
try:
 for case in a.cases:
  rows=[x for x in inputs if x['case']==case];cdir=out/(case+'-case');cdir.mkdir()
  binaries={r:a.compiled/(case+'-pair')/(f+'.hsaco') for r,f in [('baseline','baseline'),('normalized','variant')]}
  if a.variant:
   binaries={'baseline':binaries['baseline']}
   for item in a.variant:
    role,path=item.split('=',1);assert role and role.replace('-','').isalnum() and role not in binaries;binaries[role]=Path(path).resolve()
  hashes={r:sha(b) for r,b in binaries.items()}
  (cdir/'case.json').write_text(json.dumps({'name':'decision-normalize-'+case,'enabled':True,'runtime':{'kind':'cpp','backend':'amd','runner':str(archive/'runner/bench_hip'),'default_kernel':str(binaries['baseline']),'inputs':[x['spec'] for x in rows],'timing_modes':['event'],'scope':a.scope,'environment':{'LD_LIBRARY_PATH':'/opt/rocm/lib:/opt/rocm/lib64:/usr/local/cuda/lib64','HIP_VISIBLE_DEVICES':'0','ROCR_VISIBLE_DEVICES':'0'}}},indent=2))
  leaders={};aliases={}
  for role,h in hashes.items():leaders.setdefault(h,role);aliases[role]=leaders[h]
  roles=list(leaders.values())
  def run(role,phase,dest):
   assert sha(binaries[role])==hashes[role]
   cmd=[str(s/'bench'),str(cdir),phase,'--kernel',str(binaries[role]),'--out',str(dest),'--warmup','3','--repeat','15']
   if phase=='benchmark':cmd+=['--validated',str(out/(case+'-'+role+'-validate'))]
   for attempt in range(3):
    plan['commands'].append(cmd);save('plan.json',plan);rc=subprocess.run(cmd,cwd=s).returncode
    if rc==0:return
    if (dest/'output').exists() or (dest/'terminal.json').exists():raise RuntimeError('execution failed; preserved')
    adm=dest/'admission.json'
    if not adm.exists() or all(x['admitted'] for x in json.loads(adm.read_text())):raise RuntimeError('not an admission denial')
    dest.rename(dest.with_name(dest.name+'-denied-'+str(attempt)))
    if attempt<2:time.sleep(3)
   raise RuntimeError('admission denied')
  for role in roles:run(role,'validate',out/(case+'-'+role+'-validate'))
  values={r:[] for r in roles};snapshot=None
  for batch in range(3):
   order=roles[batch%len(roles):]+roles[:batch%len(roles)]
   for role in order:
    dest=out/(case+'-'+role+'-batch-'+str(batch));run(role,'benchmark',dest)
    receipt=json.loads((dest/'accepted.json').read_text());assert receipt['passed']
    if snapshot is None:snapshot=receipt['input_snapshot']
    assert snapshot==receipt['input_snapshot']
    med=[]
    for i in range(len(rows)):
     samples=list(csv.DictReader((dest/'output'/str(i)/'samples.csv').open()));assert len(samples)==18 and all(x['full_output_passed']=='1' for x in samples)
     ts=[float(x['microseconds']) for x in samples if x['warmup']=='0'];assert len(ts)==15 and all(math.isfinite(t) and t>0 for t in ts);med.append(statistics.median(ts))
    values[role].append(med)
  medians={r:[statistics.median(values[r][b][i] for b in range(3)) for i in range(len(rows))] for r in roles}
  for role,leader in aliases.items():medians[role]=medians[leader]
  results[case]={'scope':a.scope,'correctness_passed':True,'inputs':[{k:x[k] for k in ['count','layout','seed']} for x in rows],'binary_sha256':hashes,'binary_identical':len(roles)==1,'median_us':medians,'batch_medians_us':values,'variant_slowdown_pct':{role:[100*(n/b-1) for b,n in zip(medians['baseline'],medians[role])] for role in binaries if role!='baseline'},'aliases_by_identical_binary':aliases}
  save('summary.json',results);print(case,json.dumps(results[case]),flush=True)
  for role,b in binaries.items():assert sha(b)==hashes[role]
 for row in inputs:
  for f,h in row['files'].items():assert sha(Path(row['spec']).parent/f)==h
 plan['status']='completed';plan['output_cleanup']='generated inputs/oracles and task-owned .bin outputs removed; receipts and CSV retained'
 shutil.rmtree(out/'generated')
 for f in out.rglob('*.bin'):f.unlink()
except Exception as e:
 plan['status']='failed_preserved';plan['error']=str(e);raise
finally:save('plan.json',plan)
