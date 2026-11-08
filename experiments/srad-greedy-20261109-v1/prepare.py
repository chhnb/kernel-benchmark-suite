from pathlib import Path
import subprocess,json,hashlib
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
src=s/'results/srad-baseline-binary-v1/post.ll';fn='srad_cuda_1'
plan={'source':str(src),'sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'commands':[]}
def run(name,cmd):
 plan['commands'].append(list(map(str,cmd)));(p/'build-plan.json').write_text(json.dumps(plan,indent=2))
 with (p/(name+'.stdout')).open('w') as a,(p/(name+'.stderr')).open('w') as b:subprocess.run(cmd,stdout=a,stderr=b,check=True,timeout=900)
for mode in ['scoped-local','scoped-cfg']:
 run(mode,[s/'build/llvm24-tti/fusion-search-llvm24','--ir',src,'--function',fn,'--structural','1','--adjacent-only','0','--cleanup',mode,'--scorer','llvm24','--rounds','256','--trials','100000','--debug-dir',p/mode,'--out',p/(mode+'.ll')])
run('original-darm',['/home/chh/darm-artifacts-repro/build/bin/opt',src,'-cfmelder','-run-cfmelding-on-function='+fn,'-verify','-S','-o',p/'original-darm.ll'])
for role in ['scoped-local','scoped-cfg','original-darm']:
 run(role+'-compile',['python3',s/'tools/postopt_compile_pair.py','--baseline',src,'--variant',p/(role+'.ll'),'--case','srad','--function',fn,'--scope','full-srad-current-greedy-vs-original-artifacts','--out',p/(role+'-pair'),'--admitted'])
print({mode:json.loads((p/mode/'result.json').read_text()) for mode in ['scoped-local','scoped-cfg']})
