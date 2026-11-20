# Benchmark case inventory

The `cases/` directory contains 18 case manifests. The case directories
carry kernel sources, harnesses, build recipes, and provenance where those
files were available in the musa suite. Some manifests describe multiple
input scenarios for the same kernel.

| Backend | Cases |
| --- | --- |
| AMD/HIP | boost-landau, boost-mapairy, ced, hypersonic, reentry, srad, srad-stage2, sw2d, tigre-siddon, tpacf, vllm-quant, vllm-quant-large, vllm-quant-kv-dump, vllm-quant-qwen64k |
| NVIDIA/CUDA | boost-saspoint5, cholla-hlld, cudaflow-particles, hipims |

VLLM and Map-Airy have a generated-input entry point described in
[portable benchmarks](portable-benchmarks.md). The other manifests retain
the original build and runtime recipes. For those cases, consult each
case's README and manifest for the toolchain, paths and input specifications.
Recipes with musa absolute paths need those paths resolved on the new host.
The listed input paths describe the original runs. Historical input buffers
and generated binaries are external artifacts. The VLLM KV dump and Qwen
scenarios require their own captured inputs to replay those specific runs.

The original enablement and validation status come from the case manifests.
A historical validation record describes the configuration tested on musa.
