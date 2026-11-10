"""Prepare fixed benchmark probes; invoke under tools/run_cpu.py admission.
Case-specific names here are test expectations, never discovery rules.
"""
from pathlib import Path
import subprocess,json,hashlib,argparse
p=argparse.ArgumentParser();p.add_argument('--suite',type=Path,required=True);p.add_argument('--tool',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();s=a.suite.resolve();d=a.out.resolve();d.mkdir(exist_ok=False);exe=a.tool.resolve()
def run(args):subprocess.run(list(map(str,args)),check=True,stdout=subprocess.DEVNULL)
def cat(p,fn):return json.loads(subprocess.check_output([exe,p,fn]))
records={}
for case,rel,fn in [('mapairy','experiments/mapairy-full-convergence-20261109-v1/steps-final/state-0.ll','evaluate'),('vllm','experiments/recursive-all32-greedy-20261108-v1/state-0.ll','cache_eval')]:
 original=s/rel;current=original;cs=cat(current,fn);steps=[]
 if case=='mapairy':
  root=next(x for x in cs if len(x['arms'])==13 and x['arms'][0]['entry']=='%if.then.i21.i.i.i')['root'];targets=[(root,4)]
 else:targets=[(x['root'],0) for x in cs if len(x['arms'])==8 and all(a['kind']!='Unsupported' for a in x['arms'])];assert len(targets)==32
 for k,(root,left) in enumerate(targets):
  cs=cat(current,fn);di=next(i for i,x in enumerate(cs) if x['root']==root);dec=cs[di];out=d/(case+'-normalized-'+str(k)+'.ll')
  run([exe,current,fn,di,left,out]);steps.append({'root':root,'left':dec['arms'][left]['entry'],'right':dec['arms'][left+1]['entry']});current=out
 pair=d/(case+'-pair')
 run(['python3',s/'tools/postopt_compile_pair.py','--baseline',original,'--variant',current,'--case','boost-mapairy' if case=='mapairy' else 'vllm-quant','--function',fn,'--scope','short-circuit-normalization-only','--out',pair,'--admitted'])
 hashes={role:hashlib.sha256((pair/(role+'.hsaco')).read_bytes()).hexdigest() for role in ['baseline','variant']}
 records[case]={'original':str(original),'normalized':str(current),'steps':steps,'binary_sha256':hashes,'binary_identical':hashes['baseline']==hashes['variant']}
 print(case,'normalizations',len(steps),'binary_identical',records[case]['binary_identical'],flush=True)
(d/'compile-summary.json').write_text(json.dumps(records,indent=2))
