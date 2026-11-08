from pathlib import Path
import json,subprocess,hashlib
S=Path('/home/chh/kernel-benchmark-suite');p=S/'experiments/tigre-scoped-cfg-20261109-v2';src=S/'results/tigre-baseline-binary-v1/post.ll';fn='_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture'
plan={'function':fn,'source':str(src),'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'upstream_commit':subprocess.check_output(['git','-C','/home/chh/darm-artifacts-repro/upstream/code','rev-parse','HEAD'],text=True).strip(),'upstream_status':subprocess.check_output(['git','-C','/home/chh/darm-artifacts-repro/upstream/code','status','--porcelain'],text=True),'commands':[]}
def run(n,cmd):
 plan['commands'].append({'stage':n,'argv':cmd});(p/'build-plan.json').write_text(json.dumps(plan,indent=2))
 with (p/(n+'.stdout')).open('w') as a,(p/(n+'.stderr')).open('w') as b:r=subprocess.run(cmd,stdout=a,stderr=b,timeout=600)
 plan['commands'][-1]['exit']=r.returncode;(p/'build-plan.json').write_text(json.dumps(plan,indent=2));r.check_returncode()
run('hybrid-cfg',[str(S/'build/llvm24-tti/fusion-search-llvm24'),'--ir',str(src),'--function',fn,'--structural','1','--adjacent-only','0','--cleanup','scoped-cfg','--scorer','llvm24','--rounds','256','--trials','100000','--debug-dir',str(p/'hybrid-cfg'),'--out',str(p/'hybrid-cfg.ll')])
run('raw-first-round',[str(S/'build/llvm24-tti/fusion-search-llvm24'),'--ir',str(src),'--function',fn,'--structural','1','--adjacent-only','0','--cleanup','none','--scorer','llvm24','--rounds','1','--trials','100000','--debug-dir',str(p/'raw-first-round'),'--out',str(p/'raw-first-round.ll')])
run('original-darm',['/home/chh/darm-artifacts-repro/build/bin/opt',str(src),'-cfmelder','-run-cfmelding-on-function='+fn,'-verify','-S','-o',str(p/'original-darm.ll')])
run('compile',['python3',str(S/'tools/postopt_compile_pair.py'),'--baseline',str(p/'original-darm.ll'),'--variant',str(p/'hybrid-cfg.ll'),'--case','tigre-siddon','--function',fn,'--scope','original-unmodified-artifacts-DARM-versus-hybrid-LLVM24-greedy-DarmCFG','--out',str(p/'pair'),'--admitted'])
print((p/'hybrid-cfg/result.json').read_text())
