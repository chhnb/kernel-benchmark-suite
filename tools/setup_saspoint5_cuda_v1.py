from pathlib import Path
import json,shutil,struct,random
S=Path('/home/chh/kernel-benchmark-suite');C=S/'cases/boost-saspoint5';C.mkdir();(C/'source').mkdir();L=S/'cases/boost-landau'
(C/'source/boost-math').symlink_to('../../boost-landau/source/boost-math',target_is_directory=True)
(C/'source/kernel.cu').write_text('''#include <cuda_runtime.h>
#include <boost/math/distributions/saspoint5.hpp>
extern "C" __global__ void evaluate(const double* input, double* output, int n) {
 int i=blockIdx.x*blockDim.x+threadIdx.x;
 if(i<n) output[i]=boost::math::pdf(boost::math::saspoint5_distribution<double>(),input[i]);
}
''')
(C/'source/oracle.cpp').write_text((L/'source/oracle.cpp').read_text().replace('landau','saspoint5').replace('quantile','pdf'))
shutil.copy2(S/'cases/cholla-hlld/source/legacy-launch.h',C/'source/legacy-launch.h')
n=65539;r=random.Random(20261106);anchors=[.0625,.1875,.375,.75,1.5,3.,6.,12.,24.,48.,96.];mix=[anchors[i%11]*(-1 if i%2 else 1) for i in range(n)];r.shuffle(mix);inputs={'interval-mixture':mix,'coherent-blocks':sorted(mix,key=abs),'uniform-01':[r.random() for _ in range(n)]}
for name,vals in inputs.items():
 d=C/'fixtures-cpp'/name;d.mkdir(parents=True);(d/'input.bin').write_bytes(struct.pack('<'+str(n)+'d',*vals));(d/'output-init.bin').write_bytes(bytes(n*8));(d/'input.txt').write_text((L/'fixtures-cpp/interval-mixture/input.txt').read_text())
m={'name':'boost-saspoint5','enabled':True,'status':'pending','helper_extraction':False,'baseline_profile':'cuda-llvm12-o3','profiles':{'cuda-llvm12-o3':{'argv':['bash','{case}/compile_cuda.sh','{case}','{out}'],'artifact':'kernel.cubin','kind':'cubin','gpu_execution':False}},'runtime':{'kind':'cpp','backend':'cuda','runner':'build/bin/bench_cuda','default_kernel':str(S/'results/saspoint5-cuda-baseline-v1/kernel.cubin'),'inputs':[f'fixtures-cpp/{f}/input.txt' for f in inputs],'timing_modes':['event','graph'],'scope':'Full Boost Saspoint5 PDF FP64; three synthetic 65539-element inputs; sm70; block256; long-double CPU oracle','environment':{'CUDA_VISIBLE_DEVICES':'0'}},'provenance':{'boost_commit':'4a6ce7851dc3e54ca7a6e3db3181e86e39d6d9ce','input_seed':20261106,'inputs':'new deterministic synthetic fixtures, not historical CUDA inputs or official Boost.Random sequence'}}
(C/'case.json').write_text(json.dumps(m,indent=2));E=S/'experiments/saspoint5-cuda-v1';E.mkdir();(E/'trial').mkdir()
