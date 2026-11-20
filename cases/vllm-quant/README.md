# vLLM software KV-cache benchmark

Continue the existing experiment, per user instruction. Primary: HIP gfx906 full cache_eval. Secondary: CUDA sm70 software port. Native upstream NVFP4 is reference only and does not block these profiles.

Differences from pinned upstream 5d55ef1590c92213e3893dc8e8712f7f2e0bc508: software E4M3/E2M1, precise reciprocal, scalar BF16 decoding, original experimental V-scale layout. Do not describe this as unchanged upstream CUDA or end-to-end vLLM inference.

HIP links the retained UNMERGED quant LLVM module into the existing full cache source, followed by the historical common always-inline/O3/internalize pipeline. This preserves the previous baseline; no fusion or new helper extraction runs. Source reconstruction of that quant module is still pending.

CUDA inputs: existing 60 SmolLM2 post-RoPE KV records with original manifest and NumPy oracle. CPU checks regenerate references; they are not GPU acceptance. Fresh HIP final-input validation and fixed 2+5 timing now pass all five historical token counts. Historical timing remains separate from new suite measurements.

Build through tools/suite.py; select the successful build with `./bench vllm-quant validate|benchmark --build BUILD_DIR`. The primary runtime is the shared C++ HIP runner, using frozen inputs/reference bytes under fixtures-cpp. All five final inputs passed fresh C++ full-byte validation and 2+5 Event timing. The old Python GPU harnesses, including the secondary CUDA validation harness, are archived under archive/python-runtime/vllm-quant. Secondary CUDA timing remains pending.

## Real Qwen 64K KV input archive

[Qwen3.5-0.8B 64K inputs](inputs/qwen35-64k/README.md) are now copied into the suite: 6 full-attention layers, 12 BF16-bit NPY arrays of shape [65536, 2, 256]. Source/target SHA-256 checks passed. The directory includes original manifests, selected input/token IDs, generation script and historical AMD/TITAN validation and timing records. This is a data import; C++ fixture export and new GPU validation/timing are pending. Existing default fixtures remain unchanged.
