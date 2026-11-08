from pathlib import Path
import json,shutil
S=Path('/home/chh/kernel-benchmark-suite');E=Path('/home/chh/divergence-strategy-search/explorations')
def cp(a,b):
 b.parent.mkdir(parents=True,exist_ok=True)
 if a.is_dir():shutil.copytree(a,b,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__'))
 else:shutil.copy2(a,b)
# Cholla: retain the exact full production snapshot, omit old tiny/diagnostic fixtures in routine runner.
p=S/'cases/cholla-hlld';old=E/'cholla-hlld-cuda-fusion-20261104'
cp(old/'fixture',p/'fixture');cp(old/'cuda_driver_local.py',p/'cuda_driver_local.py')
s=(old/'runner.py').read_text();a=s.index("if mode=='correctness':\n");b=s.index("blobs=[",a);s=s[:a]+s[b:]
s=s.replace("(out/(label+'-'+str(round)+'.bin')).write_bytes(raw)","None # Full output checked in memory; no successful array persistence")
(p/'run.py').write_text(s)
j=json.loads((p/'case.json').read_text());j['profiles']['nvcc-o3']={'argv':['/usr/local/cuda/bin/nvcc','-std=c++17','-O3','-arch=sm_70','--fmad=false','-DMHD','-DHLLD','-DPRECISION=2','-cubin','{case}/source/src/riemann_solvers/hlld_cuda.cu','-o','{out}/baseline.cubin'],'artifact':'baseline.cubin','kind':'cuda-cubin','gpu_execution':False}
j['runtime']={'backend':'cuda','runner':'run.py','fixture':'fixture/ot-first-x.meta.txt','scope':'Original captured OT startup X-face; complete output comparison to fixed CPU reference, readonly/guards; no tiny historical fixture matrix','roles':[{'name':'BASELINE','binary':str(S/'results/cholla-nvcc-baseline-v1/baseline.cubin'),'symbol':'_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii'}]};(p/'case.json').write_text(json.dumps(j,indent=2))
# SW2D: accepted fixed-domain snapshots are exactly the benchmark input set.
p=S/'cases/sw2d';old=E/'sw2d-flux-20261104'
cp(old/'input/fixed-domain-v1',p/'input/fixed-domain-v1')
for n in ['hip.py','enums.json']:cp(old/'harness'/n,p/'harness'/n)
for src,dst,indent in [('run_v2.py','validate.py',6),('timing.py','benchmark.py',7)]:
 s=(old/'harness'/src).read_text();start=s.index(' '*indent+'for kind in ');end=s.index(' '*(indent-1)+'else:\n',start);s=s[:start]+s[end:]
 (p/'harness'/dst).write_text(s)
(p/'recipes').mkdir(exist_ok=True)
for name in ['post','llc','link-hsaco']:
 cmd=json.loads((old/'build/v1/natural/UNFUSED'/(name+'.json')).read_text())['command']
 cmd=[a.replace(str(old/'build/v1/natural/UNFUSED'),'{out}') for a in cmd]
 (p/'recipes'/(name+'.json')).write_text(json.dumps(cmd,indent=2))
j=json.loads((p/'case.json').read_text());j['profiles']['hip-o3-binary']={'argv':['python3','{case}/build_binary.py','{out}'],'artifact':'kernel.hsaco','kind':'hip-code-object','gpu_execution':False}
j['runtime']={'backend':'amd','validate':'harness/validate.py','benchmark':'harness/benchmark.py','fixtures':'input/fixed-domain-v1/fixtures.json','scope':'Three original benchmark startup snapshots, common authorized N=rows*cols; no stress or historical negative matrix','roles':[{'name':'NATURAL','hsaco':str(S/'results/sw2d-baseline-binary-v1/kernel.hsaco'),'symbol':'_Z4fluxPdddPiS_S0_S0_S_S_S_S_S_S_S_S_S_S_S_S_iiiddd'}]};(p/'case.json').write_text(json.dumps(j,indent=2))
print('SW2D/Cholla final-input runtime migrated')
