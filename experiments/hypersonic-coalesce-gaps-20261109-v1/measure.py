from pathlib import Path
import subprocess,json,hashlib,time,csv,statistics,math,argparse
parser=argparse.ArgumentParser();parser.add_argument('--output-name',default='measure');args=parser.parse_args()
assert Path(args.output_name).name==args.output_name and args.output_name not in ('.','..')
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent;out=p/args.output_name;out.mkdir(exist_ok=False)
roles={'prepared_baseline':p/'L0-L1-off-pair/baseline.hsaco','gap_off':p/'L0-L1-off-pair/variant.hsaco','gap_on':p/'L0-L1-on-pair/variant.hsaco'}

def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
hashes={r:sha(f) for r,f in roles.items()};unique={};alias={}
for r,h in hashes.items():
 if h not in unique:unique[h]=r
 alias[r]=unique[h]
active=list(unique.values());orders=[active[i:]+active[:i] for i in [0,1,2]]
plan={'case':'hypersonic','scope':'Full hypersonic; fixed L0+L1 alignment; gap grouping off/on; frozen inputs; common LLVM12 final O3 gfx906','warmup':3,'repeat':15,'batches':3,'order':orders,'aliases_by_identical_binary':alias,'roles':{r:{'path':str(f),'sha256':hashes[r]} for r,f in roles.items()},'status':'planned','commands':[]}
def save(n):(out/n).write_text(json.dumps(plan,indent=2))
save('plan.json')
def run(r,phase,d):
 cmd=[str(s/'bench'),'hypersonic',phase,'--kernel',str(roles[r]),'--out',str(d),'--warmup','3','--repeat','15']
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
   files=sorted((d/'output').glob('*/*/checks.jsonl'));assert len(files)==2
   for f in files:
    rows=[json.loads(l) for l in f.read_text().splitlines() if l.strip()]
    assert len(rows)==18 and all(all(x[k] for k in ['pass','guards','readonly']) and not x['mismatches'] and not x['negatives'] for x in rows)
    samples=[float(x['milliseconds'])*1000 for x in rows if x['measurement']];assert len(samples)==15 and all(math.isfinite(x) and x>0 for x in samples);vals.append(statistics.median(samples))
   times[r].append(vals)
 med={r:[statistics.median(times[alias[r]][b][i] for b in range(3)) for i in range(2)] for r in roles}
 summary={'median_us_by_input_order':med,'batch_medians_us':times,'aliases_by_identical_binary':alias,'decrease_vs_prepared_pct':{r:[100*(1-med[r][i]/med['prepared_baseline'][i]) for i in range(2)] for r in roles},'correctness_passed':True}
 (p/'summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2));plan['status']='completed'
except Exception as e:plan['status']='stopped_preserved';plan['error']=str(e);raise
finally:save('terminal.json')
