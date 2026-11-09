# Benchmark contract

Each case supplies pinned source provenance, explicit build argv, a chosen baseline IR profile, a full-kernel binary, launch ABI, final inputs and its established complete-output oracle. C++ handles GPU execution and GPU Event timing. A runner never discovers regions, extracts helpers or transforms IR.

The active CLI accepts --kernel, --input, --output, --mode, --timing, --warmup and --repeat. Output directories must be new. The scheduler can resolve --build from its successful build receipt. No manifest mutation is needed to select a rebuilt binary.

Routine validation uses final benchmark inputs only. Historical tiny/stress/negative matrices are archived. Every timed launch also checks full outputs; existing tolerances, bitwise checks, guards, input immutability and case-specific geometry checks are preserved. Failure exits nonzero and cannot authorize timing. Runtime data are immutable; generic fixtures carry raw input/reference files and declarative ABI arguments.

Timing is a GPU Event interval around one launch, with same-stream Events. Initialization, reset, transfers and checks are excluded. Graph mode, when supported, captures exactly one kernel node outside the timed interval and resets all state before every replay. No timing-mode pooling; no repeated mutation hidden inside a graph. Fixed default budget: 2 warmups + 5 measured launches per input. This is screening, not independent performance confirmation.

On musa the external canonical compile quota, GPU locks and admission still apply. The Python scheduler does not call CUDA/HIP and does not participate in the per-launch timing sequence. A denied bench request performs no GPU execution. Regression orchestration may use bounded retries only for confirmed prelaunch admission denial, preserving the denied receipt; executed failures are not retried.

Compiler/backend profiles remain distinct. O0/O2/O3 refer to actual compiler stages, not performance claims. Fusion strategies must consume the same chosen baseline IR and common finalization. Existing upstream device functions are allowed; no optimizer-specific helper preparation belongs in this suite.

Current navigation: [mainline](MAINLINE.md), [build/run guide](BENCHMARK_GUIDE.md), [known issues](KNOWN_ISSUES.md). Generated regression inputs are temporary and reproducible; their generators/seeds/hashes are retained instead of checking raw data into Git.
