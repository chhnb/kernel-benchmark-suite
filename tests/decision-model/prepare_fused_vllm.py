"""Fixed-order test, not greedy: three true fusions in each of 32 trees.
Invoke through tools/run_cpu.py. Preserve every accepted/rejected trial.
"""
from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--suite',type=Path,required=True);p.add_argument('--tool-root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();s=a.suite.resolve();r=a.tool_root.resolve();out=a.out.resolve();out.mkdir(exist_ok=False)
original=s/'experiments/recursive-all32-greedy-20261108-v1/state-0.ll';current=original
catalog=json.loads(subprocess.check_output([r/'build/decision-model/decision-model',current,'cache_eval']))
roots=[d['root'] for d in catalog if len(d['arms'])==8 and all(x['kind']=='Linear' for x in d['arms'])];assert len(roots)==32
report={'scope':'fixed left-deep order through L3; no greedy scoring','source':str(original),'source_sha256':hashlib.sha256(original.read_bytes()).hexdigest(),'steps':[],'phases':[]}
def calls(path):return sum('call float @llvm.copysign.f32' in l for l in path.read_text().splitlines())
assert calls(original)==256
for phase in range(3):
 for n,root in enumerate(roots):
  di=next(i for i,d in enumerate(catalog) if d['root']==root);d=out/(str(phase)+'-'+str(n));before=calls(current)
  with (out/(str(phase)+'-'+str(n)+'.log')).open('w') as log:
   rc=subprocess.run([r/'build/decision-fuse/decision-fuse',current,'cache_eval',str(di),'0',d],stdout=log,stderr=log).returncode
  t=json.loads((d/'trial.json').read_text());report['steps'].append({'phase':phase,'tree':n,**t});(out/'search.json').write_text(json.dumps(report,indent=2))
  assert rc==0,t
  current=d/'fused.ll';assert calls(current)==before-1,(phase,n,'no actual call sharing')
  catalog=json.loads((d/'decisions.json').read_text());arm=next(x for x in catalog if x['root']==root)['arms'][0];assert len(arm['merged_from'])==phase+2
 checkpoint=out/('phase-'+str(phase+1)+'.ll');checkpoint.write_bytes(current.read_bytes());report['phases'].append({'fusions':(phase+1)*32,'copysign_calls':calls(checkpoint),'ir':str(checkpoint)})
 print('phase',phase+1,'calls',calls(checkpoint),flush=True)
(out/'search.json').write_text(json.dumps(report,indent=2))
subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(original),'--variant',str(current),'--case','vllm-quant','--function','cache_eval','--scope','decision-RegionMelder-three-levels-all32','--out',str(out/'vllm-pair'),'--admitted'],check=True)
