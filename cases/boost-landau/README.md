# Boost.Math Landau quantile

Complete `evaluate(input, output, n)` HIP kernel calling the original `boost::math::quantile(landau_distribution<double>(), p)`. Boost.Math pinned to commit `4a6ce7851dc3e54ca7a6e3db3181e86e39d6d9ce`; unmodified upstream math headers are under source/boost-math/include. Kernel source only enables the pinned release's GPU execution-space macros for HIP; no formula/branch rewrite or helper extraction.

The selected lower-tail dispatch has 13 arms (12 numerical intervals plus fallback). The benchmark executes the complete public API, not an isolated leaf/helper.

## Build and run

From the suite root:

```sh
python3 tools/suite.py build boost-landau --profile hip-llvm12-o3 --out results/landau-build-new
./bench boost-landau validate --build results/landau-build-new --out results/landau-check-new
./bench boost-landau benchmark --build results/landau-build-new --validated results/landau-check-new --out results/landau-time-new
```

The shared C++ HIP runner uses original block256, full input/guard checks, CPU reference tolerance abs1e-14 + rel5e-13, and default Event timing with 2 warmups + 5 measurements. No Python GPU API or optimizer adapter. Graph is available through the shared runner; the case acceptance here used Event.

LLVM12 source compilation generates start.ll and post.ll plus kernel.hsaco; this profile's machine-code .text is byte-identical to the retained historical original baseline. hip-llvm12-o3-ir exposes the same frontend recipe independently. Native ROCm18 binary/IR profiles are supplemental and separately validated/timed; do not pool them with LLVM12.

## Final inputs and reproduction

Two unchanged retained synthetic performance fixtures, each 65,539 FP64 probabilities: interval-mixture and coherent-blocks. They were generated with seed 2026110301 and have retained original long-double references. Fresh source/oracle.cpp recompilation reproduces all reference bytes exactly. The C++ runner needs only the frozen binary files; no Python/NumPy input generation occurs during execution. Original manifest and oracle execution receipts are in provenance/.

The previous 2026102507 timing dataset was removed with partition-darm cleanup. Therefore this is not a rerun of the old 23.8% result. The old best tree and binary are retained under historical/ as evidence only. Fresh optimization comparisons must validate the full output against the same chosen GPU baseline, including exact output bits for transformed variants, and run all arms on the same inputs/compiler profile.

First native build failed because the pinned Boost release does not automatically annotate HIP functions; failure is preserved. Explicit execution-space macros fixed compilation without editing upstream headers. Current LLVM12 and native profiles passed fresh final-input validation and Event timing. Shared toolchain paths remain external.

## First full-kernel automatic comparison

See ../../experiments/landau-auto-v1/README.md and review.json. Original Git BF makes zero changes; DARM records 17 block melds. All outputs pass. Fixed 2+5 screen: DARM reduces mixed-anchor time by 39.23% but increases coherent-block time by 16.35%. This is an input-dependent screening result, not independent confirmation or the historical helper-based winner.

## Historical selected-tree replay

See `../../experiments/landau-selected-tree-v1/README.md`: the frozen prior best tree and exact same-tree unfused control are now runnable with the C++ Event harness (3+15). Current mixed input: 37.54% lower time versus baseline, 38.12% lower versus plain; coherent input: 29.41% slower versus baseline. All final outputs pass. Historical seed-2026102507 input file is absent, so this does not recreate the old 23.8% conditions.

## Historical input recovered

The original input is recovered from baseline-profile-20261031/runs-v3/landau/validation/host/inputs.bin. SHA256 matches the original full-gpu-prep input receipt exactly: dbdeaa61d1acb9d4503ee90be20a5fcb8971956d4d6a5022723412481d7dbb22. Earlier unavailability statements are superseded. Stored in cases/boost-landau/inputs/historical-2026102507. Regenerated long-double references match recovered bytes.

Original binaries and original input using C++ Event 3+15: baseline 55.840 us, FUSED 40.800 us, PLAIN 56.000 us, DARM_ADJACENT 57.120 us, HELPER_DARM_ADJACENT 56.481 us. All checks passed. See historical-input-review.json and results/landau-historical-{validation,timing}-v1. Timing harness differs from historical Python; this restores inputs and artifacts, not every environmental condition.
