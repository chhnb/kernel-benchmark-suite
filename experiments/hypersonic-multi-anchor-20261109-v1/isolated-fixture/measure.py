from pathlib import Path
import subprocess,json,hashlib,statistics,math
p=Path(__file__).resolve().parent;s=Path('/home/chh/kernel-benchmark-suite');e=p.parent;out=p/'measure';out.mkdir(exist_ok=False)
roles={'baseline':e/'outer-selector/old-pair/baseline.hsaco','old':e/'outer-selector/old-pair/variant.hsaco','multi':e/'outer-selector/multi-pair/variant.hsaco'}
hashes={r:hashlib.sha256(f.read_bytes()).hexdigest() for r,f in roles.items()}
plan={'protocol':'one frozen fixture per process; full kernel; event timing; no retry','warmup':3,'repeat':15,'batches':3,'binary_sha256':hashes,'status':'running','commands':[]}
def save():(out/'plan.json').write_text(json.dumps(plan,indent=2))
def run(r,step,phase,batch=None):
 label=r+'-'+str(step);dest=out/(label+'-validate' if phase=='validate' else label+'-batch-'+str(batch))
 cmd=['python3',str(p/'admit.py'),'hypersonic',phase,'--kernel',str(roles[r]),'--input',str(s/'cases/hypersonic/input'/('hypersonic-'+str(step))),'--out',str(dest),'--warmup','0' if phase=='validate' else '3','--repeat','1' if phase=='validate' else '15']
 if phase=='benchmark':cmd+=['--validated',str(out/(label+'-validate'))]
 assert hashlib.sha256(roles[r].read_bytes()).hexdigest()==hashes[r]
 plan['commands'].append(cmd);save();subprocess.run(cmd,check=True)
try:
 for step in [1,24]:
  for r in roles:run(r,step,'validate')
 order=list(roles)
 for batch in range(3):
  for r in order[batch:]+order[:batch]:
   for step in [1,24]:run(r,step,'benchmark',batch)
 medians={};batches={}
 for r in roles:
  batches[r]={};medians[r]={}
  for step in [1,24]:
   vals=[]
   for batch in range(3):
    d=out/(r+'-'+str(step)+'-batch-'+str(batch));assert json.loads((d/'accepted.json').read_text())['passed']
    files=list((d/'output').glob('*/*/checks.jsonl'));assert len(files)==1
    rows=[json.loads(x) for x in files[0].read_text().splitlines()];assert len(rows)==18
    assert all(all(x[k] for k in ['pass','guards','readonly']) and x['mismatches']==0 for x in rows)
    samples=[x['milliseconds']*1000 for x in rows if x['measurement']];assert len(samples)==15
    assert all(math.isfinite(v) and v>0 for v in samples);vals.append(statistics.median(samples))
   batches[r][str(step)]=vals;medians[r][str(step)]=statistics.median(vals)
 summary={'median_us':medians,'batch_medians_us':batches,'decrease_vs_baseline_pct':{r:{k:100*(1-v/medians['baseline'][k]) for k,v in row.items()} for r,row in medians.items()},'full_output_checks_passed':True,'protocol':plan['protocol'],'binary_sha256':hashes}
 (p/'summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2));plan['status']='completed'
except Exception as exc:plan['status']='failed_preserved';plan['error']=str(exc);raise
finally:save()
