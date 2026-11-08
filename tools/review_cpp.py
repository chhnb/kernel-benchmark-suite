from pathlib import Path
import json,csv,statistics,collections
S=Path(__file__).resolve().parents[1]
counts={'boost-landau':2,'cholla-hlld':1,'cudaflow-particles':2,'srad':2,'vllm-quant':5,'hypersonic':2,'reentry':4,'tigre-siddon':6,'hipims':2}
review={}
for case,n in counts.items():
 pair=[S/f'results/cpp-{case}-validation-v1',S/f'results/cpp-{case}-timing-v1'];samples=collections.defaultdict(list)
 for D,timed in zip(pair,[False,True]):
  accepted=json.loads((D/'accepted.json').read_text());assert accepted['passed'] and accepted['timing_mode']=='event';assert json.loads((D/'terminal.json').read_text())['exit']==0
  out=D/'output';rows=[]
  if case in ['hypersonic','reentry']:
   for f in sorted(out.glob('*/*/checks.jsonl')):
    r=[json.loads(l) for l in f.read_text().splitlines()];assert all(x['pass'] and x['guards'] and x['readonly'] and x['mismatches']==0 and x['negatives']==0 for x in r);rows+=r
    if timed:samples[f.parent.name]=[x['milliseconds']*1000 for x in r if x['measurement']]
  elif case=='tigre-siddon':
   if timed:
    rows=list(csv.DictReader((out/'0/timing.csv').open()))
    for x in rows:
     if x['warmup']=='0':samples['batch'+x['batch']].append(float(x['ms'])*1000)
   else:rows=[l for l in (D/'stdout-0').read_text().splitlines() if l.startswith('VALID baseline batch=')];assert all('bitwise=1' in l for l in rows)
   assert 'COMPLETE' in (D/'stdout-0').read_text()
  else:
   for f in sorted(out.glob('*/samples.csv')):
    r=list(csv.DictReader(f.open()));assert all(x['full_output_passed']=='1' for x in r);rows+=r
    if timed:samples[f.parent.name]=[float(x['microseconds']) for x in r if x['warmup']=='0']
  assert len(rows)==n*(7 if timed else 1),(case,len(rows),timed)
 assert len(samples)==n and all(len(v)==5 for v in samples.values())
 review[case]={'passed':True,'validation_launches':n,'warmup_launches':n*2,'measurement_launches':n*5,'runtime':'C++','timing':'GPU Event','validation':str(pair[0].relative_to(S)),'benchmark':str(pair[1].relative_to(S)),'median_us':{k:statistics.median(v) for k,v in samples.items()},'samples_us':dict(samples)}
 p=S/'cases'/case/'case.json';m=json.loads(p.read_text());m['cpp_migration']={'status':'validated_and_timed','review':'results/cpp-review.json'}
 if (S/'archive/python-runtime'/(case+'-runtime.json')).exists():m['cpp_migration']['historical_python_runtime']='archive/python-runtime/'+case+'-runtime.json';m['status']='cpp_baseline_validated_and_timed';m['validation']['cpp']=review[case]['validation'];m['benchmark']={'status':'C++ fixed 2+5 completed','review':'results/cpp-review.json'};p.write_text(json.dumps(m,indent=2)+'\n')
(S/'results/cpp-review.json').write_text(json.dumps(review,indent=2)+'\n');print(f'{len(review)} active C++ cases accepted: {sum(counts.values())} validation + {sum(counts.values())*2} warmup + {sum(counts.values())*5} measured launches')
