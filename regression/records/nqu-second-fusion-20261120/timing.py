from pathlib import Path
from statistics import median,quantiles
import csv,fcntl,json,os,random,subprocess
d=Path(__file__).resolve().parent
env=os.environ|{'HIP_VISIBLE_DEVICES':'0','ROCR_VISIBLE_DEVICES':'0'}
def run(roles,label):
 with (d/(label+'.csv')).open('w') as out,(d/(label+'.log')).open('w') as log:
  subprocess.run([d/'replay',d/'input.bin',d/'reference.bin','12','timed',*[d/(r+'.hsaco') for r in roles]],
      cwd=d,stdout=out,stderr=log,env=env,check=True)
 parsed=[{} for _ in range(12)]
 with (d/(label+'.csv')).open() as f:
  for row in csv.DictReader(f):
   if row['warmup']=='0': parsed[int(row['round'])][int(row['role'])]=float(row['milliseconds'])
 assert all(len(z)==len(roles) and all(v>0 for v in z.values()) for z in parsed)
 results={}
 for i,role in enumerate(roles):
  v=[z[i]/z[0] for z in parsed]
  rng=random.Random(20261120)
  q=quantiles([median(rng.choices(v,k=12)) for _ in range(10000)],n=40,method='inclusive')
  results[role if i!=1 or role!=roles[0] else 'P2']=dict(ms=median(z[i] for z in parsed),
     ratio=median(v),ci95=[q[0],q[-1]],spread=(max(v)/min(v)-1),ratios=v)
 return results
with open('/data/home/chh/v2-runtime/gpu.lock','a') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 aa=run(['P','P'],'aa')
 x=aa['P2']
 result={'aa':aa,'passed':abs(x['ratio']-1)<=.01 and x['spread']<=.03}
 (d/'timing.json').write_text(json.dumps(result,indent=2)+'\n')
 print(result,flush=True)
 if result['passed']:
  result['ablation']=run(['P','V-branch','V-share','C'],'ablation')
  (d/'timing.json').write_text(json.dumps(result,indent=2)+'\n')
  print(result['ablation'],flush=True)
