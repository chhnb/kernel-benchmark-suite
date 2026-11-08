from pathlib import Path
import json,shutil
R=Path('/home/chh/region-fusion-lab');S=Path('/home/chh/kernel-benchmark-suite');P=S/'cases/vllm-quant'
for d in ['source','recipes','harness','inputs','historical']: (P/d).mkdir(exist_ok=True)
def cp(a,b):
 if a.is_dir():shutil.copytree(a,b,dirs_exist_ok=True)
 else:shutil.copy2(a,b)
cp(R/'work/titan-kv/cache.cu',P/'source/cache.cu');cp(R/'runs/titan-vllm-kv-v1/llvm-cache.cu',P/'source/llvm-cache.cu')
cp(R/'runs/amd-vllm-cache-port-v1/cache.hip',P/'source/cache.hip')
cp(R/'runs/amd-quant-greedy-vllm-v1/states/state-0/linked.ll',P/'source/quant-unmerged.ll')
cp(R/'runs/titan-vllm-kv-v1/kv',P/'inputs/kv')
cp(R/'work/titan-kv/oracle.py',P/'harness/oracle.py')
s=(R/'work/titan-kv/validate.py').read_text();s=s.replace("run=R/'runs/titan-vllm-kv-v1';data=run/'kv';", "run=Path(sys.argv[2]).resolve();run.mkdir(parents=True,exist_ok=False);data=Path(__file__).resolve().parents[1]/'inputs/kv';")
(P/'harness/validate_cuda.py').write_text(s)
for f in ['vllm-native-scale-report.md','vllm-native-scale-results.json']:cp(R/'work/vllm-native-scale-v1'/f,P/'historical'/f)
# Preserve input generation/oracle/timing logic as provenance, not executable old requests.
for f in ['gpu.py','analyze.py']:cp(R/'work/vllm-native-scale-v1'/f,P/'historical'/('hip-'+f))
old=R/'runs/amd-vllm-cache-port-v1'
for name,f in [('front',old/'cache-clang.json'),('prep',old/'cache-prep.json'),('link',old/'unmerged/link.json'),('post',old/'unmerged/post.json'),('llc',old/'unmerged/llc.json'),('link-hsaco',old/'unmerged/link-hsaco.json')]:
 j=json.loads(f.read_text());cmd=j['command']
 mapping={str(old/'cache.hip'):'{case}/source/cache.hip',str(R/'runs/amd-quant-greedy-vllm-v1/states/state-0/linked.ll'):'{case}/source/quant-unmerged.ll',str(old/'unmerged'):'{out}',str(old):'{out}'}
 for i,a in enumerate(cmd):
  for x,y in sorted(mapping.items(),key=lambda z:-len(z[0])):a=a.replace(x,y)
  cmd[i]=a
 (P/'recipes'/(name+'.json')).write_text(json.dumps(cmd,indent=2))
j=json.loads((P/'case.json').read_text());j['profiles']={
 'hip-software-baseline':{'argv':['python3','{case}/build_hip.py','{out}'],'artifact':'kernel.hsaco','kind':'hip-code-object','gpu_execution':False},
 'cuda-software-nvcc':{'argv':['/usr/local/cuda-12.9/bin/nvcc','-arch=sm_70','--fmad=false','-O3','-cubin','{case}/source/cache.cu','-o','{out}/cache.cubin'],'artifact':'cache.cubin','kind':'cuda-cubin','gpu_execution':False},
 'cuda-software-llvm-ir':{'argv':[str(R/'toolchains/llvm12/amd-bootstrap/bin/clang'),'-std=c++17','-x','cuda','--cuda-device-only','-nocudainc','-nocudalib','--cuda-gpu-arch=sm_70','-ffp-contract=off','-O3','-Xclang','-mlink-builtin-bitcode','-Xclang','/usr/local/cuda-12.9/nvvm/libdevice/libdevice.10.bc','-S','-emit-llvm','{case}/source/llvm-cache.cu','-o','{out}/start.ll'],'artifact':'start.ll','kind':'llvm-ir','gpu_execution':False}}
j['status']='historical_software_routes_migrating';j['preference']='User: execute the same implementation as before; HIP primary, CUDA software port secondary';j['scope']='Full cache_eval software 4/6 cache writer; existing quant_decide implementation retained and inlined, no new extraction';j['blockers']=[];j['original_upstream_status']='Native FP4 route unsupported on sm70; reference only, does not block software benchmark';j['baseline_dependency']='Retained unmerged quant LLVM module, not rebuilt from source yet';j['inputs']={'cuda':'inputs/kv/manifest.json','hip':'Historical deterministic BF16 synthetic generator in historical/hip-gpu.py; runtime migration pending'}
(P/'case.json').write_text(json.dumps(j,indent=2))
(P/'README.md').write_text('''# vLLM software KV-cache benchmark

Continue the existing experiment, per user instruction. Primary: HIP gfx906 full cache_eval. Secondary: CUDA sm70 software port. Native upstream NVFP4 is reference only and does not block these profiles.

Differences from pinned upstream 5d55ef1590c92213e3893dc8e8712f7f2e0bc508: software E4M3/E2M1, precise reciprocal, scalar BF16 decoding, original experimental V-scale layout. Do not describe this as unchanged upstream CUDA or end-to-end vLLM inference.

HIP links the retained UNMERGED quant LLVM module into the existing full cache source, followed by the historical common always-inline/O3/internalize pipeline. This preserves the previous baseline; no fusion or new helper extraction runs. Source reconstruction of that quant module is still pending.

CUDA inputs: existing 60 SmolLM2 post-RoPE KV records with original manifest and NumPy oracle. CPU checks regenerate references and reject corruption; they are not GPU acceptance. Historical HIP timing remains separate from new suite measurements.

Build through tools/suite.py. Run CPU oracle with a NumPy-enabled interpreter: python harness/validate_cuda.py cpu NEW_OUTPUT_DIRECTORY. GPU execution still requires fresh canonical admission; do not directly invoke the GPU mode or historical scripts.
''')
print('Migrated software routes and KV fixtures')
