from pathlib import Path
import json,shutil
R=Path('/home/chh/kernel-benchmark-suite'); E=Path('/home/chh/divergence-strategy-search/explorations'); F=Path('/home/chh/region-fusion-lab')
R.mkdir(exist_ok=True)
for n in ['cases','tools','results','docs']: (R/n).mkdir(exist_ok=True)
def dump(p,j):p.write_text(json.dumps(j,indent=2)+'\n')
def cp(a,b):
 b.parent.mkdir(parents=True,exist_ok=True)
 if a.is_dir():shutil.copytree(a,b,dirs_exist_ok=True,ignore=shutil.ignore_patterns('.git','__pycache__'))
 else:shutil.copy2(a,b)
def init(name,origin,note):
 p=R/'cases'/name;p.mkdir(exist_ok=True)
 return p,dict(name=name,status='migration_in_progress',origin=str(origin),scope=note,helper_extraction=False,profiles={},validation={'status':'pending fresh suite validation'},benchmark={'status':'pending fresh suite timing'})
def recipe(p,m,key,record,mapping,output,kind):
 j=json.loads(record.read_text());cmd=j['command'] if isinstance(j,dict) else j
 argv=[]
 for arg in cmd:
  for a,b in sorted(mapping.items(),key=lambda x:-len(x[0])):arg=arg.replace(a,b)
  argv.append(arg)
 argv[argv.index('-o')+1]='{out}/'+output
 m['profiles'][key]={'argv':argv,'artifact':output,'kind':kind,'origin_command':str(record),'gpu_execution':False}
 dump(p/'case.json',m)
p,m=init('sw2d',E/'sw2d-flux-20261104','Complete original flux body; CUDA includes adapted to HIP. Runtime N=M domain change must be explicit.')
cp(E/'sw2d-flux-20261104/build/flux.hip',p/'source/flux.hip')
for key,sub in [('hip-o3','natural'),('hip-o0','prepared')]:
 recipe(p,m,key,E/f'sw2d-flux-20261104/build/v1/{sub}/front.json',{str(E/'sw2d-flux-20261104/build'):'{case}/source'},'start.ll','llvm-ir')
p,m=init('cholla-hlld',E/'cholla-hlld-cuda-fusion-20261104','Original complete Cholla HLLD CUDA function, FP64/MHD; no helper extraction.')
cp(E/'cholla-hlld-repro-20261103/upstream/src',p/'source/src')
cp(E/'cholla-hlld-cuda-fusion-20261104/build/v3/legacy-launch.h',p/'source/legacy-launch.h')
recipe(p,m,'cuda-o3',E/'cholla-hlld-cuda-fusion-20261104/build/v3/front.json',{str(E/'cholla-hlld-repro-20261103/upstream/src'):'{case}/source/src',str(E/'cholla-hlld-cuda-fusion-20261104/build/v3/legacy-launch.h'):'{case}/source/legacy-launch.h'},'start.ll','llvm-ir')
p,m=init('cudaflow-particles',E/'cudaflow-particles-20261104','Full partPushK; original particle configuration provenance and numerical blockers remain explicit.')
for name in ['particles_kernel.cu','common.h','metrics.cuh']:cp(E/'cudaflow-particles-20261104/build'/name,p/'source'/name)
cp(E/'cudaflow-particles-20261104/build/v1/legacy-launch.h',p/'source/legacy-launch.h')
mapping={str(E/'cudaflow-particles-20261104/build/v1/legacy-launch.h'):'{case}/source/legacy-launch.h',str(E/'cudaflow-particles-20261104/build'):'{case}/source'}
recipe(p,m,'cuda-o3',E/'cudaflow-particles-20261104/build/v1/front.json',mapping,'start.ll','llvm-ir')
recipe(p,m,'nvcc-o3',E/'cudaflow-particles-20261104/build/v1/nvcc.json',mapping,'baseline.cubin','cuda-cubin')
for name in ['hypersonic','reentry']:
 p,m=init(name,E/'fluid-sims-repro-20261104','Corrected upstream native CUDA baseline. Keep original and corrected semantics distinct; this build is an executable, not an IR profile.')
 cp(E/'fluid-sims-repro-20261104/fixes-v1/source',p/'source')
 cp(E/'fluid-sims-repro-20261104/fixes-v1/REPORT.txt',p/'SOURCE-CHANGES.txt')
 recipe(p,m,'nvcc-o2',E/f'fluid-sims-repro-20261104/fixes-v1/build/{name}.command.json',{str(E/'fluid-sims-repro-20261104/fixes-v1/source'):'{case}/source'},'baseline','cuda-executable')
for name,origin,note in [('hipims',E/'hipims-integration-20261104','Full original CUDA operators; HLLC/George/MSWE have distinct validation status.'),('tigre-siddon',F/'cases/tigre_siddon','Native full kernel; retained environment-specific adaptations must be listed.'),('srad',E/'srad-nineway-20261104','Original full SRAD kernel; do not import extracted nine-way helper as the natural baseline.'),('vllm-quant',F/'runs/amd-vllm-cache-port-v1','Separate original CUDA baseline from experimental HIP port; port contains quant_decide and is not an untouched natural source.')]:
 p,m=init(name,origin,note);dump(p/'case.json',m)
(R/'README.md').write_text('''# Kernel Benchmark Suite

Independent benchmark preparation project on musa. This repository does not perform helper extraction, region discovery, fusion or search.

Each case supplies explicit argv recipes, source provenance, baseline profile, inputs, correctness and timing contracts. CUDA/HIP and O0/O3 profiles are separate experiments. Identical starting IR and common finalization will be required when optimizers are added later.

Current stage: migration in progress. Source build recipes exist for SW2D, Cholla HLLD, CuDAFLOW and corrected Hypersonic/Reentry. Other case records are pending implementation. A successful build is not GPU correctness or performance acceptance. No old GPU request is replayed.

`python3 tools/suite.py list`
`python3 tools/suite.py build sw2d --profile hip-o3 --out results/NEW_NAME`

Compilation uses the existing canonical CPU quota wrapper. LLVM12/ROCm/CUDA toolchains remain external and are recorded in each argv. Source snapshots are independent copies, not hardlinks. Input/harness migration and fresh GPU acceptance remain outstanding.
''')
(R/'.gitignore').write_text('results/\n__pycache__/\n*.pyc\n')
print('Created',R)
