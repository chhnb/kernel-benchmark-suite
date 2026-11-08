# Kernel Benchmark Suite

Current selection: 10 active cases, including Boost.Math Landau and Map-Airy. SW2D remains inactive; its files and historical acceptance are retained. Landau uses the shared C++ HIP runner and a source-built LLVM12 baseline with no helper extraction.

Full-kernel baselines with explicit CUDA/HIP compilation recipes and C++ execution. No optimizer adapter, new helper extraction or IR transformation is part of a runner.

## Build and run

On musa:

```sh
cd /home/chh/kernel-benchmark-suite
./build-runners

# Build a baseline; source/compiler argv is recorded in the case manifest.
python3 tools/suite.py build srad --profile hip-o3-binary --out results/srad-build-new

# Pass the build directly: no edits to case.json.
./bench srad validate --build results/srad-build-new --out results/srad-check-new
./bench srad benchmark --build results/srad-build-new   --validated results/srad-check-new --out results/srad-time-new
```

Use `--kernel /absolute/path/kernel.hsaco` or `.cubin` to select a binary directly. Without either option, the accepted default baseline is used. All output directories must be new. `--input` selects one input; otherwise the case's final input set runs. Default timing is 2 warmups + 5 measurements; `--warmup` and `--repeat` are explicit options, never automatic top-ups.

`./bench` only performs shared-machine admission, process scheduling and log collection. All allocation, upload, argument construction, kernel launch, output checks, synchronization and timing execute inside C++. Python never submits a GPU API call in the active runtime. Python remains for source build orchestration, optional result review and one-time fixture export.

## Direct C++ interface

The runner itself needs no Python:

```sh
build/bin/bench_hip --kernel results/srad-baseline-binary-v1/kernel.hsaco   --input cases/srad/fixtures-cpp/256/input.txt   --output results/direct-srad --mode benchmark --timing event --warmup 2 --repeat 5
```

On shared musa use `./bench`, so the canonical GPU lock and admission checks remain in force. Direct invocation is for an appropriately reserved or dedicated GPU.

## Timing

GPU Events surround one full kernel launch on the same stream. Every iteration restores inputs and outputs before the start Event, then synchronizes the stop Event and checks complete outputs after it. Transfers, file I/O, reference checks, graph construction and allocation are excluded from the Event interval. These are kernel timings, not end-to-end application latency.

The shared C++ runner also supports `--timing graph`: capture one kernel node once, then Event-time a single graph launch per iteration. Inputs are restored before every replay. No repeated in-place mutation or division by a hidden batch count occurs. Validation and benchmark must use the same mode. Graph and Event samples are separate experiments.

Graph is supported by the common runner for SW2D, Cholla, CuDAFLOW, SRAD and primary HIP vLLM; both CUDA and HIP paths were exercised using Cholla and SRAD. The dedicated Fluid-sims, TIGRE and HiPIMS runners currently support Event only and reject Graph explicitly. Moving to C++ reduces host submission overhead; it does not establish a speedup or eliminate clock, cache and device noise.

## Layout

- `CMakeLists.txt`, `runner/`: common C++ CLI and CUDA/HIP replay implementation.
- `cases/`: baseline sources/build profiles, final fixtures and specialized C++ harnesses where needed.
- `bench`, `build-runners`, `tools/`: admission/build orchestration and result review.
- `results/cpp-review.json`: reviewed results for all nine primary baseline cases.
- `archive/python-runtime/`: retired Python GPU harnesses, retained without compression.

Fixed input files carry the same original oracle and tolerance. SRAD and CuDAFLOW additionally retain historical full-output bitwise comparisons. vLLM's deterministic inputs and complete CPU outputs are frozen once; they need no NumPy at execution time. `tools/export_cpp_fixtures.py` is an offline migration utility, not a build/run prerequisite.

Toolchains and musa admission remain shared dependencies. See STATUS.md for case coverage and limits; vLLM is the historical software port, and its HIP build still depends on retained quant-unmerged.ll. BF/DARM integration is subsequent work on the selected baseline IR, reusing these runners unchanged.

## LLVM12 region analysis

All nine active cases have LLVM12 IR analysis profiles and read-only C++ CFG/Region inventories. See [docs/region-analysis.md](docs/region-analysis.md). Reports: `analysis/suite-regions-llvm12-v4`. This is static analysis, not new GPU baseline acceptance.

## Neighbor similarity

LLVM12 native DARM scoring is available for all nine cases, independently of the native candidate sorter. See [docs/region-similarity.md](docs/region-similarity.md) and `analysis/neighbor-similarity-llvm12-v2/index.html`. No fusion is performed.

## Explicit pair fusion trials

Specify a BB or Region pair, try one LLVM12 DARM merge, and retain complete before/after scoring data. See [docs/pair-trial.md](docs/pair-trial.md). The Landau (0,1) trial passed the three retained GPU input fixtures; generic BB/Region synthetic trials also passed. This is a trial interface, not a greedy search or runtime speedup claim.

## Native C++ greedy search

`build/fusion-search/fusion-search` now owns enumeration, isolated trial fusion, in-memory before/after scoring, winner selection and iterative commits. JSON is optional debug observer output, never an algorithm input. See [docs/cpp-greedy.md](docs/cpp-greedy.md) and `tools/fusion_search.h` for the replaceable C++ scorer interface. The initial policy is normalized static-cost reduction, not measured runtime.

## Incremental control scoring

Native C++ scoring now compares each normalized trial against one shared no-fusion control per round, retains legacy DARM weights, and returns a structured result with classified contributions and explicit unavailable features. See [docs/incremental-scoring.md](docs/incremental-scoring.md). Search and debug observers consume the same result; JSON remains optional.
