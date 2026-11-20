# Saspoint5 CUDA — validated; non-exclusive timing completed

See docs/saspoint5-cuda-results.md. Four variants passed 408 output checks with the corrected CUDA upload ordering. Mixed input medians: baseline17.408us, autoDARM15.360us, manualCFG14.336us, manualFP14.336us. External CUDA process remained present; no exclusive performance confirmation.

## Preparation history (superseded by results above)

# Saspoint5 CUDA experiment — GPU validation pending

Full Boost.Math `pdf(saspoint5_distribution<double>(), x)` API, FP64, LLVM12/NVPTX sm_70 and CUDA12.9 ptxas. Headers remain pinned/shared with boost-landau. Explicit Boost GPU annotations and Clang variadic compatibility flag are used. Large inline threshold brings the original Boost implementation into evaluate for every variant; no extracted fusion helper.

Three new deterministic synthetic fixtures (seed20261106), 65539 elements each: interval-mixture spanning all11 PDF intervals with positive/negative values; identical values stably sorted by absolute value; uniform-01 from Python RNG (not the original Boost.Random performance sequence). CPU references regenerated with long double.

Four binaries are built in experiments/saspoint5-cuda-v1/trial: baseline, automaticDARM, manual originalCFG cleanup, manual scalar fixed-point cleanup. Manual tree `(0,1)|2|(((3,4),(5,6)),((7,8),9))|10`; this is a newly chosen controlled tree, not a claim to reproduce the missing CUDA hand-optimized version. The driver's L labels denote PDF intervals here, not lower-tail quantile branches.

GPU validation request saspoint5-cuda-validate-v1 was denied because of another user's active compute process. No GPU kernels executed and no timing claim. Keep that record immutable. After the GPU becomes available, start a new validation output directory, then benchmark only against that accepted validation:

```sh
python3 experiments/saspoint5-cuda-v1/run_gpu.py validate --out results/saspoint5-cuda-validate-v2
python3 experiments/saspoint5-cuda-v1/run_gpu.py benchmark --out results/saspoint5-cuda-benchmark-v1 --validated results/saspoint5-cuda-validate-v2
```

The wrapper performs canonical lock/admission checks; do not bypass or terminate other users' processes. Shared C++ CUDA Driver API runner, 3 warmups +30 measurements with CUDA Event and mirrored cyclic role order; all outputs checked outside the event.
