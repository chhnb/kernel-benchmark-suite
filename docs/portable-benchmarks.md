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

## Offline scoring for frozen searches

Build the search engine and the LLVM12 instruction reader with
`LLVM_CONFIG=/path/to/llvm12/bin/llvm-config tools/build-v1 --search-only`.
The recording host also needs the pinned LLVM24 worker. Use a separate
database per frozen case and run the full search once to record the scores.

```bash
export FUSION_TTI_DB=/absolute/path/to/case.sqlite
FUSION_TTI_MODE=record build/decision-fuse/decision-greedy INPUT.ll FUNCTION record-out
FUSION_TTI_MODE=strict build/decision-fuse/decision-greedy INPUT.ll FUNCTION strict-out
```

Strict mode requires an exact recorded score request. Compare the candidate
scores, selected candidates and final IR with those from the recording run.
Missing strict requests fail the replay and are recorded in
`offline-tti-errors.log` in its output directory. Keep the original input
path when the IR has no explicit `source_filename`, since LLVM derives
that field from the path. The database contains compressed LLVM24 reports and a smaller set
of reusable instruction quotes keyed by the available target and instruction
context.

For an experiment with adjustable costs, use `FUSION_TTI_MODE=offline`.
It uses the recorded quotes when available and charges 1 for a missing
instruction quote. Greedy appends warnings to `offline-tti-warnings.log` in the output directory,
or to the path given by `FUSION_TTI_WARNINGS`. When a changed score changes the
selected fusion, subsequent requests can need additional fallback quotes.

Set `FUSION_TTI_OVERRIDES=/absolute/path/to/overrides.json` in offline mode.
This example overrides 8-byte-aligned global double loads on gfx906.

```json
[
  {"cpu": "gfx906", "key": "load:double", "address_space": 1, "alignment": 8, "cost": 4}
]
```

Rules match the given fields. If multiple rules match, the last match wins.
Both offline modes use Python 3 with SQLite and the LLVM12 build. The pinned
LLVM24 binary and libraries are used only for recording.

Set `FUSION_TTI_COST_KIND=latency` to use LLVM24 `TCK_Latency` for either live
worker queries or recording and offline replay. Without it, the cost kind is
`TCK_RecipThroughput`.

```bash
FUSION_TTI_COST_KIND=latency tools/run-llvm24-tti INPUT.ll FUNCTION > latency.json
FUSION_TTI_COST_KIND=latency FUSION_TTI_MODE=record \
  FUSION_TTI_DB=/absolute/path/to/latency.sqlite \
  build/decision-fuse/decision-greedy INPUT.ll FUNCTION latency-record
FUSION_TTI_COST_KIND=latency FUSION_TTI_MODE=strict \
  FUSION_TTI_DB=/absolute/path/to/latency.sqlite \
  build/decision-fuse/decision-greedy INPUT.ll FUNCTION latency-replay
```

Latency and throughput reports use separate lookup keys. Latency replay uses
the exact recorded IR requests. The reusable per-instruction cache is verified
for throughput only.

The [gfx906 memory cost table](../regression/tti-gfx906/memory-costs.csv)
contains both cost kinds for the checked-in probe. The offline regression
checks those quotes and records both cost kinds in one database to verify
that replay never reads a quote from the wrong mode.
