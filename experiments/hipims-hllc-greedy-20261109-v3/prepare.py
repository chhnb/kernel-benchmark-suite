from pathlib import Path
import subprocess,json,hashlib
s=Path('/home/chh/kernel-benchmark-suite');p=s/'experiments/hipims-hllc-greedy-20261109-v3';src=s/'results/hipims-hllc-llvm-o3-v2/start.ll';fn='_ZN2GC2fv31cuAdvectionMSWEsCartesianKernelEPdS1_S1_S1_S1_PNS_7Vector2ES3_S3_jPNS_15ShortDualHandleEjS1_S1_S3_';t=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin')
plan={'source':str(src),'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'function':fn,'commands':[]}
def run(name,cmd):
 plan['commands'].append({'name':name,'argv':list(map(str,cmd))});(p/'build-plan.json').write_text(json.dumps(plan,indent=2))
 with (p/(name+'.stdout')).open('w') as a,(p/(name+'.stderr')).open('w') as b:r=subprocess.run(cmd,stdout=a,stderr=b,timeout=900)
 plan['commands'][-1]['exit']=r.returncode;(p/'build-plan.json').write_text(json.dumps(plan,indent=2));r.check_returncode()
run('build-inline',['bash',p/'inline.sh'])
run('inline-baseline',[p/'inline-baseline',src,fn,p/'inline-raw.ll'])
run('prepare-baseline',[t/'opt',p/'inline-raw.ll','-O3','-verify','-S','-o',p/'prepared.ll'])
src=p/'prepared.ll'
for mode in ['scoped-local','scoped-cfg']:
 run(mode,[s/'build/llvm24-tti/fusion-search-llvm24','--ir',src,'--function',fn,'--structural','1','--adjacent-only','0','--cleanup',mode,'--scorer','llvm24','--rounds','256','--trials','100000','--debug-dir',p/mode,'--out',p/(mode+'.ll')])
run('original-darm',['/home/chh/darm-artifacts-repro/build/bin/opt',src,'-cfmelder','-run-cfmelding-on-function='+fn,'-verify','-S','-o',p/'original-darm.ll'])
for role,ir in [('llvm_baseline',src),('original_darm',p/'original-darm.ll'),('scoped_local',p/'scoped-local.ll'),('scoped_cfg',p/'scoped-cfg.ll')]:
 run(role+'-opt',[t/'opt',ir,'-O3','-verify','-S','-o',p/(role+'-final.ll')])
 run(role+'-llc',[t/'llc',p/(role+'-final.ll'),'-O3','-march=nvptx64','-mcpu=sm_70','-mattr=+ptx70','-o',p/(role+'.ptx')])
 run(role+'-ptxas',['/usr/local/cuda/bin/ptxas','-O3','-arch=sm_70','-v',p/(role+'.ptx'),'-o',p/(role+'.cubin')])
print({mode:json.loads((p/mode/'result.json').read_text()) for mode in ['scoped-local','scoped-cfg']})
