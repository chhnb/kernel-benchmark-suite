"""Fixed complete left-deep/balanced trees, with explicit original leaf order."""
from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--suite',type=Path,required=True);p.add_argument('--tool-root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();s=a.suite.resolve();r=a.tool_root.resolve();out=a.out.resolve();out.mkdir(exist_ok=False)
original=s/'experiments/recursive-all32-greedy-20261108-v1/state-0.ll'
legacy=json.loads((original.parent/'logical-state-0.json').read_text())['decisions'];trees=[d for d in legacy if len(d['leaves'])==8];assert len(trees)==32
order=out/'leaf-order.json';order.write_text(json.dumps([{'entry':l['initial_block'],'family':d['id'],'index':i} for d in trees for i,l in enumerate(d['leaves'])],indent=2))
initial=json.loads(subprocess.check_output([r/'build/decision-model/decision-model',original,'cache_eval']))
def calls(p):return sum('call float @llvm.copysign.f32' in l for l in p.read_text().splitlines())
for strategy,indices in [('recursive',[0]*7),('balanced',[0,1,2,3,0,1,0])]:
 folder=out/strategy;folder.mkdir();current=original;catalog=initial;steps=[]
 for n,tree in enumerate(trees):
  for step,left in enumerate(indices):
   di=next(i for i,d in enumerate(catalog) if d['root']==tree['root']);target=folder/(str(n)+'-'+str(step));before=calls(current)
   with (folder/(str(n)+'-'+str(step)+'.log')).open('w') as log:
    rc=subprocess.run([r/'build/decision-fuse/decision-fuse',current,'cache_eval',str(di),str(left),target,order],stdout=log,stderr=log).returncode
   t=json.loads((target/'trial.json').read_text());steps.append({'tree':tree['id'],'step':step,**t});(folder/'search.json').write_text(json.dumps({'strategy':strategy,'steps':steps},indent=2))
   assert rc==0,t
   current=target/'fused.ll';assert calls(current)==before-1,(strategy,n,step,'not actually sharing a call')
   catalog=json.loads((target/'decisions.json').read_text())
  assert t.get('completed_decision'),t
  print(strategy,'tree',n+1,'copysign',calls(current),flush=True)
 final=folder/'final.ll';final.write_bytes(current.read_bytes());assert calls(final)==32
 subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(original),'--variant',str(final),'--case','vllm-quant','--function','cache_eval','--scope','decision-RegionMelder-full-'+strategy,'--out',str(folder/'vllm-pair'),'--admitted'],check=True)
 print(strategy,'224 verified fusions; compiled',flush=True)
