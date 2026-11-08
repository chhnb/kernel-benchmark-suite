from pathlib import Path
import json,hashlib
S=Path('/home/chh/kernel-benchmark-suite');C=S/'cases/boost-saspoint5';E=S/'experiments/saspoint5-cuda-v1';B=S/'results/saspoint5-cuda-baseline-v1'
p=E/'run_gpu.py';s=p.read_text().replace('spec.loader.exec_module(ad)\n','spec.loader.exec_module(ad);ad.UUID="GPU-15f5b4da-5dfd-4953-31a1-f4eeb93e2023"\n');p.write_text(s)
m=json.loads((C/'case.json').read_text());m['status']='cuda_built_gpu_validation_pending';m['validation']={'status':'not_run_admission_denied','record':'results/saspoint5-cuda-validate-v1/admission.json','reason':'competing compute process observed, PID1489313'};m['benchmark']={'status':'not_run'};m['limitations']=['New synthetic inputs; not a replication of the missing historical CUDA experiment.','GPU output validation and timing have not run.','Explicit Boost GPU annotations and Clang allow-variadic-functions compatibility flag; shared pinned headers unmodified.','All variants start from same aggressively inlined LLVM12 O3 baseline; NVCC is not the baseline compiler.'];m['optimization_experiments']=[{'path':'experiments/saspoint5-cuda-v1','roles':['baseline','auto_DARM','manual_FP','manual_CFG'],'manual_tree':'(0,1)|2|(((3,4),(5,6)),((7,8),9))|10','manual_steps':7,'automatic_melds':9,'status':'built_unvalidated'}];(C/'case.json').write_text(json.dumps(m,indent=2))
(B/'receipt.json').write_text(json.dumps({'case':'boost-saspoint5','profile':'cuda-llvm12-o3','build_passed':True,'artifact':str(B/'kernel.cubin'),'build_script':str(E/'build.sh'),'build_log':'/home/chh/region-fusion-lab/work/saspoint5-cuda-build-v6/output.log','artifact_sha256':hashlib.sha256((B/'kernel.cubin').read_bytes()).hexdigest(),'gpu_validated':False},indent=2))
(C/'README.md').write_text('''# Saspoint5 CUDA experiment — GPU validation pending

Full Boost.Math `pdf(saspoint5_distribution<double>(), x)` API, FP64, LLVM12/NVPTX sm_70 and CUDA12.9 ptxas. Headers remain pinned/shared with boost-landau. Explicit Boost GPU annotations and Clang variadic compatibility flag are used. Large inline threshold brings the original Boost implementation into evaluate for every variant; no extracted fusion helper.

Three new deterministic synthetic fixtures (seed20261106), 65539 elements each: interval-mixture spanning all11 PDF intervals with positive/negative values; identical values stably sorted by absolute value; uniform-01 from Python RNG (not the original Boost.Random performance sequence). CPU references regenerated with long double.

Four binaries are built in experiments/saspoint5-cuda-v1/trial: baseline, automaticDARM, manual originalCFG cleanup, manual scalar fixed-point cleanup. Manual tree `(0,1)|2|(((3,4),(5,6)),((7,8),9))|10`; this is a newly chosen controlled tree, not a claim to reproduce the missing CUDA hand-optimized version. The driver's L labels denote PDF intervals here, not lower-tail quantile branches.

GPU validation request saspoint5-cuda-validate-v1 was denied because of another user's active compute process. No GPU kernels executed and no timing claim. Keep that record immutable. After the GPU becomes available, start a new validation output directory, then benchmark only against that accepted validation:

```sh
python3 experiments/saspoint5-cuda-v1/run_gpu.py validate --out results/saspoint5-cuda-validate-v2
python3 experiments/saspoint5-cuda-v1/run_gpu.py benchmark --out results/saspoint5-cuda-benchmark-v1 --validated results/saspoint5-cuda-validate-v2
```

The wrapper performs canonical lock/admission checks; do not bypass or terminate other users' processes. Shared C++ CUDA Driver API runner, 3 warmups +30 measurements with CUDA Event and mirrored cyclic role order; all outputs checked outside the event.
''')
