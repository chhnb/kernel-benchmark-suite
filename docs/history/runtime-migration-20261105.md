> 历史运行时迁移记录，包含后来追加的备注。下文“Current/active/尚无融合”只表示当时状态；当前入口为根README与STATUS。

# C++ runtime migration — 2026-11-05

Current selection: 9 active cases, including Boost.Math Landau. SW2D remains inactive; its files and historical acceptance are retained. Landau uses the shared C++ HIP runner and a source-built LLVM12 baseline with no helper extraction.

All nine primary baseline cases now execute through C++ and have fresh final-input GPU validation and fixed 2 warmup + 5 measurement runs. Whole outputs are checked on every launch. No BF/DARM optimization is included.

| Case | Accepted input scope | Validation launches | Timed launches (includes warmup) |
|---|---|---:|---:|
|boost-landau|interval-mixture / coherent-blocks, 65,539 elements each|2|14|
|cholla-hlld|OT X-face snapshot|1|7|
|srad|256 / 1024 random|2|14|
|tigre-siddon|head64, 50 projections / 6 batches|6|42|
|cudaflow-particles|65,536 / 1,048,576 particles|2|14|
|hipims|HLLC Cartesian step 0 / 100|2|14|
|hypersonic|step 1 / 24|2|14|
|reentry|step 1 / 24 / 256 / 1024|4|28|
|vllm-quant|HIP software, five token counts 1,024–131,072|5|35|

Total: 26 final-input validation launches, 52 warmup launches, 130 measured launches across the active cases. See `results/cpp-review.json` and `results/cpp-CASE-{validation,timing}-v1` for scope, raw sample links and medians.

Remaining boundaries:

- HiPIMS acceptance covers HLLC Cartesian only; George/MSWE remain outside this migration.
- vLLM primary HIP is the historical software port and still links retained quant-unmerged.ll. CUDA NVCC/LLVM12 already have 120 fresh full-output validations; CUDA timing remains pending. Native upstream NVFP4 does not run on sm70.
- Fluid-sims runtime is the historical ROCm18 native O2 full X-face baseline; its fresh LLVM18 IR is separate from the existing CUDA whole-solver build and from prior LLVM12 experiments. Do not pool their timing.
- CuDAFLOW uses synthetic particle initialization on an official grid. Its established state-v2 oracle checks floats against CPU and active cell indices geometrically; it does not require CPU/GPU index identity.
- Toolchains, GPU admission and some low-level drivers remain external shared dependencies. This is not yet a self-contained portable archive.

Operational history: SW2D validation-v1 failed on mixed ROCm libraries before launch; v2 passed after using the native runtime. SRAD validation-v1 was denied before launch due to incomplete owner visibility; after adding a pre-probe settling barrier, new validation-v2 passed. Failed/denied requests remain retained. Cholla’s initial migrated validation also ran two host-only checker negatives; these were subsequently removed from the routine entrypoint as requested. No repeated GPU test was needed for that removal.

C++ Graph smoke acceptance: Cholla CUDA full final input and SRAD HIP 256 final input, each one validation plus 2+5 replay timing; all full-output checks passed. These samples are separate from Event measurements. Native specialized runners currently reject Graph.

Active CLI: `./build-runners`, then `./bench CASE validate|benchmark --build BUILD_DIR` or `--kernel FILE`. Old Python GPU harnesses are archived in `archive/python-runtime`; retained build/admission/review Python never launches GPU kernels directly.

Landau: fresh LLVM12 source build .text equals historical original; native ROCm18 supplemental source build also passes. Both 65,539-element CPU references reproduce byte-for-byte from pinned long-double source. Old 23.8% result used removed inputs and is not transferred. See cases/boost-landau/README.md.

TPACF (2026-11-08): added helper-free full ACFKernel HIP/LLVM12 no-unroll profile and dedicated C++ runner. Baseline and prescribed eight adjacent-four groups pass all 67,108,864 output words per launch. Three fixed 2+5 paired batches: 4437.444 -> 4527.043 us (+2.019% time); no speedup claim. Synthetic 16384-point catalogs, not official astronomical data. See cases/tpacf/INTEGRATION.txt and experiments/tpacf-adjacent-four-v1/summary.json.

CED NMS (2026-11-08): full-kernel C++ runner and 110 retained frame fixtures added. Current V1 accepts two target-only region merges; common pre-switch code unchanged. All outputs exact. One paired 2+5 batch: 1833.920 -> 1787.520 us for 110 launches (-2.53%), baseline drift present; not confirmed. Remaining two batches stopped after renewed GPU-admission denial. Evidence: experiments/ced-target-only-v1/summary.json.

CED NMS follow-up (2026-11-08): user-authorized remaining two batches completed, all full outputs pass. Three per-batch time changes: -2.53%, -0.22%, -0.16%. Predeclared label unclear; no stable material speedup. This supersedes the earlier partial-measurement status, while retaining its records.
