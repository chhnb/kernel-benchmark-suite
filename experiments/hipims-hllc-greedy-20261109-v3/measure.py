from pathlib import Path
import subprocess,json,hashlib,time,csv,statistics,math,argparse
parser=argparse.ArgumentParser();parser.add_argument('--output-name',default='measure');args=parser.parse_args()
assert Path(args.output_name).name==args.output_name and args.output_name not in ('.','..')
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent;out=p/args.output_name;out.mkdir(exist_ok=False)
roles={'nvcc_baseline':s/'results/hipims-cuda-hllc-v1/baseline.cubin','original_llvm_baseline':s/'experiments/hipims-hllc-greedy-20261109-v1/llvm_baseline.cubin','prepared_baseline':p/'llvm_baseline.cubin','original_darm':p/'original_darm.cubin','scoped_local':p/'scoped_local.cubin','scoped_cfg':p/'scoped_cfg.cubin',**{f'forced_{n}':p/f'forced_{n}.cubin' for n in [17,18,22]}}
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
hashes={r:sha(f) for r,f in roles.items()};unique={};alias={}
for r,h in hashes.items():
 if h not in unique:unique[h]=r
 alias[r]=unique[h]
active=list(unique.values());orders=[active[i:]+active[:i] for i in [0,2,4]]
plan={'case':'hipims','scope':'HLLC full Cartesian only; step0/100; common LLVM12 final O3, sm70 PTX70, ptxas; forced candidates are diagnostics, not greedy commits','warmup':3,'repeat':15,'batches':3,'order':orders,'aliases_by_identical_binary':alias,'roles':{r:{'path':str(f),'sha256':hashes[r]} for r,f in roles.items()},'status':'planned','commands':[]}
def save(n):(out/n).write_text(json.dumps(plan,indent=2))
save('plan.json')
def run(r,phase,d):
 cmd=[str(s/'bench'),'hipims',phase,'--kernel',str(roles[r]),'--out',str(d),'--warmup','3','--repeat','15']
 if phase=='benchmark':cmd+=['--validated',str(out/(r+'-validation'))]
 for attempt in range(3):
  assert sha(roles[r])==hashes[r];plan['commands'].append(cmd);save('progress.json');rc=subprocess.run(cmd,cwd=s).returncode
  assert sha(roles[r])==hashes[r]
  if rc==0:return
  if (d/'output').exists() or (d/'terminal.json').exists():raise RuntimeError('execution failed; no retry')
  a=d/'admission.json';assert a.exists() and not all(v['admitted'] for v in json.loads(a.read_text()))
  d.rename(d.with_name(d.name+'-denied-'+str(attempt)))
  if attempt<2:time.sleep(3)
 raise RuntimeError('prelaunch admission exhausted')
try:
 for r in active:run(r,'validate',out/(r+'-validation'))
 for i,order in enumerate(orders):
  for r in order:run(r,'benchmark',out/(r+'-batch-'+str(i)))
 times={};snapshot=None
 for r in active:
  times[r]=[]
  for b in range(3):
   d=out/(r+'-batch-'+str(b));receipt=json.loads((d/'accepted.json').read_text());assert receipt['passed']
   if snapshot is None:snapshot=receipt['input_snapshot']
   assert receipt['input_snapshot']==snapshot;vals=[]
   for i in range(2):
    rows=list(csv.DictReader((d/'output'/str(i)/'samples.csv').open()));assert len(rows)==18 and all(x['full_output_passed']=='1' for x in rows)
    samples=[float(x['microseconds']) for x in rows if x['warmup']=='0'];assert len(samples)==15 and all(math.isfinite(x) and x>0 for x in samples);vals.append(statistics.median(samples))
   times[r].append(vals)
 med={r:[statistics.median(times[alias[r]][b][i] for b in range(3)) for i in range(2)] for r in roles}
 summary={'median_us_step0_step100':med,'batch_medians_us':times,'aliases_by_identical_binary':alias,'decrease_vs_prepared_pct':{r:[100*(1-med[r][i]/med['prepared_baseline'][i]) for i in range(2)] for r in roles},'decrease_vs_nvcc_pct':{r:[100*(1-med[r][i]/med['nvcc_baseline'][i]) for i in range(2)] for r in roles},'correctness_passed':True}
 (p/'summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2));plan['status']='completed'
except Exception as e:plan['status']='stopped_preserved';plan['error']=str(e);raise
finally:save('terminal.json')
