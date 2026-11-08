from pathlib import Path
import json,shutil
R=Path('/home/chh/kernel-benchmark-suite');E=Path('/home/chh/divergence-strategy-search/explorations');F=Path('/home/chh/region-fusion-lab')
def cp(a,b):
 b.parent.mkdir(parents=True,exist_ok=True)
 if a.is_dir():shutil.copytree(a,b,dirs_exist_ok=True,ignore=shutil.ignore_patterns('.git','__pycache__'))
 else:shutil.copy2(a,b)
def add(name,key,record,mapping,artifact,kind):
 p=R/'cases'/name;j=json.loads((p/'case.json').read_text());raw=json.loads(record.read_text());cmd=raw['command'] if isinstance(raw,dict) else raw
 for i,a in enumerate(cmd):
  for old,new in sorted(mapping.items(),key=lambda x:-len(x[0])):a=a.replace(old,new)
  cmd[i]=a
 cmd[cmd.index('-o')+1]='{out}/'+artifact
 j['profiles'][key]={'argv':cmd,'artifact':artifact,'kind':kind,'origin_command':str(record),'gpu_execution':False}
 (p/'case.json').write_text(json.dumps(j,indent=2))
p=R/'cases/srad';old=E/'srad-nineway-20261104/build-v1/original';cp(old/'source.hip',p/'source/source.hip');cp(E/'srad-nineway-20261104/original.cu',p/'source/original.cu')
add('srad','hip-o3',old/'source-clang.json',{str(old):'{case}/source'},'start.ll','llvm-ir')
p=R/'cases/hipims';old=E/'hipims-integration-20261104'
cp(old/'upstream/lib',p/'source/lib')
for f in ['kernel.cu','kernel-body.inc']:cp(old/'cuda-baseline'/f,p/'source'/f)
add('hipims','cuda-hllc-nvcc-o3',old/'cuda-baseline/build-v1/command.json',{str(old/'cuda-baseline'):'{case}/source',str(old/'upstream/lib'):'{case}/source/lib'},'baseline.cubin','cuda-cubin')
p=R/'cases/tigre-siddon';old=F/'cases/tigre_siddon'
cp(old/'source',p/'source');cp(old/'case.json',p/'original-case.json');cp(old/'README.txt',p/'SOURCE-NOTES.txt')
add('tigre-siddon','hip-o3',old/'source/frontend.json',{str(old/'source'):'{case}/source'},'start.ll','llvm-ir')
# Source-only original vLLM snapshot, never replace with the experimental port.
p=R/'cases/vllm-quant';dst=p/'upstream/csrc/nvfp4_kv_cache_kernels.cu'
if not dst.exists():cp(F/'work/cuda-backend-check/upstream-nvfp4.cu',dst)
j=json.loads((p/'case.json').read_text());j['upstream_commit']='5d55ef1590c92213e3893dc8e8712f7f2e0bc508';j['preference']='original CUDA kernel';j['scope']='Original NVFP4 KV cache kernel, FOUR_OVER_SIX; native FP4 instructions, no software replacement';j['blockers']=['Audit native FP4 hardware compatibility on TITAN V sm70','Complete pinned upstream headers and torch build dependency','Fresh original-kernel launch harness and input oracle']
(p/'case.json').write_text(json.dumps(j,indent=2))
print('Added SRAD, HiPIMS, TIGRE source profiles; vLLM original-source audit recorded')
