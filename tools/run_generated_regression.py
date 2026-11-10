#!/usr/bin/env python3
"""Generated C++ inputs/oracles, C++ GPU runner; Python only orchestrates admission."""
from pathlib import Path
import argparse, csv, hashlib, json, math, statistics, subprocess, shutil, time
S=Path(__file__).resolve().parents[1]
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(8<<20),b''):h.update(b)
 return h.hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('case',choices=['vllm','mapairy']);ap.add_argument('--candidate',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--keep-generated',action='store_true');ap.add_argument('--max-slowdown-pct',type=float,default=2);a=ap.parse_args()
 if not math.isfinite(a.max_slowdown_pct) or a.max_slowdown_pct<0:ap.error('invalid slowdown limit')
 root=S/'regression/golden/20261110-generated-gfx906-v1';m=json.loads((root/'manifest.json').read_text());cfg=m['cases'][a.case]
 for rel,h in m['sha256'].items():assert sha(root/rel)==h,'reference hash changed: '+rel
 assert sha(S/m['generator_source'])==m['generator_sha256'],'generator changed; freeze a new protocol explicitly'
 candidate=a.candidate.resolve();assert candidate.is_file();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
 gen=out/'generated';label='generated-'+a.case+'-'+str(time.time_ns())
 subprocess.run(['python3',str(S/'tools/run_cpu.py'),label,'python3',str(S/'regression/generators/prepare.py'),a.case,str(gen)],check=True)
 generation=json.loads((gen/'generation.json').read_text());assert [r['count'] for r in generation['rows']]==cfg['counts'];assert [r['seed'] for r in generation['rows']]==cfg['seeds']
 (out/'generation.json').write_text(json.dumps(generation,indent=2))
 case=out/'case';case.mkdir();inputs=[r['spec'] for r in generation['rows']]
 (case/'case.json').write_text(json.dumps({'name':'generated-'+a.case,'enabled':True,'runtime':{'kind':'cpp','backend':'amd','runner':str(root/'runner/bench_hip'),'default_kernel':str(root/cfg['reference']),'inputs':inputs,'timing_modes':['event'],'scope':cfg['scope'],'environment':{'LD_LIBRARY_PATH':'/opt/rocm/lib:/opt/rocm/lib64:/usr/local/cuda/lib64','HIP_VISIBLE_DEVICES':'0','ROCR_VISIBLE_DEVICES':'0'}}},indent=2))
 binaries={'baseline':root/cfg['baseline'],'reference':root/cfg['reference'],'candidate':candidate};hashes={r:sha(p) for r,p in binaries.items()};unique={};aliases={}
 for role,h in hashes.items():
  unique.setdefault(h,role);aliases[role]=unique[h]
 roles=list(unique.values());orders=[roles[b%len(roles):]+roles[:b%len(roles)] for b in range(3)]
 plan={'case':a.case,'archive':str(root),'manifest_sha256':sha(root/'manifest.json'),'source_commit':subprocess.check_output(['git','-C',str(S),'rev-parse','HEAD'],text=True).strip(),'generation':generation,'binary_sha256':hashes,'binaries':{r:str(p) for r,p in binaries.items()},'aliases_by_identical_binary':aliases,'warmup':3,'repeat':15,'batches':3,'orders':orders,'commands':[],'status':'planned','generated_inputs_retained':True,'max_slowdown_pct':a.max_slowdown_pct}
 def save():(out/'plan.json').write_text(json.dumps(plan,indent=2))
 def run(role,phase,dest):
  cmd=[str(S/'bench'),str(case),phase,'--kernel',str(binaries[role]),'--out',str(dest),'--warmup','3','--repeat','15']
  if phase=='benchmark':cmd+=['--validated',str(out/(role+'-validate'))]
  for attempt in range(3):
   assert sha(binaries[role])==hashes[role];plan['commands'].append(cmd);save();rc=subprocess.run(cmd,cwd=S).returncode
   if rc==0:return
   if (dest/'output').exists() or (dest/'terminal.json').exists():raise RuntimeError('GPU execution failed; no retry')
   f=dest/'admission.json';assert f.exists() and not all(x['admitted'] for x in json.loads(f.read_text())),'not an admission denial'
   dest.rename(dest.with_name(dest.name+'-denied-'+str(attempt)))
   if attempt<2:time.sleep(3)
  raise RuntimeError('admission denied before execution')
 try:
  for role in roles:run(role,'validate',out/(role+'-validate'))
  for b,order in enumerate(orders):
   for role in order:run(role,'benchmark',out/(role+'-batch-'+str(b)))
  values={};snapshot=None
  for role in roles:
   values[role]=[]
   for b in range(3):
    d=out/(role+'-batch-'+str(b));receipt=json.loads((d/'accepted.json').read_text());assert receipt['passed']
    if snapshot is None:snapshot=receipt['input_snapshot']
    assert snapshot==receipt['input_snapshot'];samples=[]
    for i in range(len(inputs)):
     rows=list(csv.DictReader((d/'output'/str(i)/'samples.csv').open()));assert len(rows)==18 and all(x['full_output_passed']=='1' for x in rows)
     x=[float(r['microseconds']) for r in rows if r['warmup']=='0'];assert len(x)==15 and all(math.isfinite(t) and t>0 for t in x);samples.append(statistics.median(x))
    values[role].append(samples)
  med={r:[statistics.median(values[aliases[r]][b][i] for b in range(3)) for i in range(len(inputs))] for r in binaries}
  slow=[100*(x/y-1) for x,y in zip(med['candidate'],med['reference'])];gain=[100*(1-x/y) for x,y in zip(med['candidate'],med['baseline'])]
  for r,h in hashes.items():assert sha(binaries[r])==h
  for row in generation['rows']:
   for f,h in row['files'].items():assert sha(Path(row['spec']).parent/f)==h
  result={'case':a.case,'correctness_passed':True,'performance_passed':all(x<=a.max_slowdown_pct for x in slow),'counts':cfg['counts'],'median_us':med,'batch_medians_us':values,'candidate_slowdown_vs_reference_pct':slow,'candidate_decrease_vs_baseline_pct':gain,'threshold_pct':a.max_slowdown_pct,'aliases_by_identical_binary':aliases,'candidate_is_same_binary_as_reference':hashes['candidate']==hashes['reference'],'source_commit':plan['source_commit'],'dataset':'generated synthetic; not historical Qwen / original Map-Airy shuffle','generation_receipt':'generation.json'}
  (out/'summary.json').write_text(json.dumps(result,indent=2));plan['status']='passed' if result['performance_passed'] else 'performance_regression';print(json.dumps(result,indent=2))
  if not result['performance_passed']:raise RuntimeError('performance regression')
  if not a.keep_generated:shutil.rmtree(gen);plan['generated_inputs_retained']=False
 except Exception as exc:plan['status']='failed_preserved';plan['error']=str(exc);raise
 finally:save()
if __name__=='__main__':main()
