# VLLM and Map-Airy on another machine

The portable entry point builds a gfx906 kernel and HIP runner, generates inputs
and CPU references, then checks GPU outputs and reports the median kernel time.
It needs Linux, Python 3, a C++17 compiler, LLVM 12 opt and llc with AMDGPU support,
and a ROCm installation with HIP development files, libamdhip64 and LLVM lld.
Use a gfx906 device allocated for your job. Set HIP_VISIBLE_DEVICES if needed.
On a shared machine, run through its scheduler. Use --prepare-only for a CPU
build and input generation job.

```bash
python3 tools/run_portable_benchmark.py vllm \
  --llvm12-bin /path/to/llvm12/bin --rocm /opt/rocm --out build/vllm-portable

python3 tools/run_portable_benchmark.py mapairy \
  --llvm12-bin /path/to/llvm12/bin --rocm /opt/rocm --out build/mapairy-portable
```

Map-Airy uses the bundled Boost.Math headers from revision
`4a6ce7851dc3e54ca7a6e3db3181e86e39d6d9ce`. An alternate header directory
can be provided with `--boost-math-include`.

Choose a fresh output directory. The generator uses fixed seeds for the 65,536
and 131,072 token VLLM workloads and the 65,539 input Map-Airy workload. VLLM
checks exact output bytes. Map-Airy compares against the Boost.Math long-double
quantile with the tolerances in the generated input spec. The runner checks
outputs during validation and timing. Timing uses 3 warmups and 15 measured
launches per size. The output contains the generated fixtures, kernel, runner,
sample CSVs and summary.json.

The two checked-in start.ll files are the full LLVM 12 kernels used as starting
points for the fusion experiments. They come from
`experiments/recursive-all32-greedy-20261108-v1/state-0.ll` (VLLM) and
`experiments/mapairy-full-convergence-20261109-v1/steps-final/state-0.ll`
(Map-Airy) in the original benchmark workspace. To benchmark a transformed
kernel, pass its LLVM 12 IR using `--ir`. Keep the kernel ABI and gfx906 target.

For fusion, build with `LLVM_CONFIG=/path/to/llvm12/bin/llvm-config bash
tools/build-decision-fuse`. For TTI-based search, also build the worker against
LLVM 24 revision `6be16f356d3e` with AMDGPU and NVPTX support and shared LLVM
libraries:

```bash
LLVM24_CONFIG=/path/to/llvm24/bin/llvm-config bash tools/build-llvm24-tti --worker-only
export LLVM24_LIBDIR=/path/to/llvm24/lib
tools/run-llvm24-tti cases/vllm-quant/start.ll cache_eval
LLVM_CONFIG=/path/to/llvm12/bin/llvm-config bash tools/build-decision-greedy
```

Use the same LLVM revision for comparable TTI costs. The portable runner
measures the kernel you build against generated CPU references. For a performance
comparison against the historical frozen HSACO artifacts, use the separate
generated regression workflow with its frozen manifest.

The preparation commands were checked on Linux with LLVM 12.0.0git and ROCm
6.3.3. Both rebuilt HSACOs matched their previously built baseline hashes.
The HIP runner builds and the LLVM 24 worker returns a VLLM TTI report.
GPU validation and timing with this portable entry point remain to be checked
on the destination machine.
