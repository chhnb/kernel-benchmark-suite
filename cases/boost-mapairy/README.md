# Boost.Math Map-Airy

Complete unmodified public API `quantile(mapairy_distribution<double>(), p)` kernel. LLVM12 / gfx906, FP64, no extracted helpers. C++ HIP runner and HIP Event timing.

Build from the suite root:

```sh
python3 tools/suite.py build boost-mapairy --profile hip-llvm12-o3 --out results/mapairy-new-build
./bench boost-mapairy validate --build results/mapairy-new-build --out results/mapairy-new-check
./bench boost-mapairy benchmark --build results/mapairy-new-build --validated results/mapairy-new-check --out results/mapairy-new-time --warmup 3 --repeat 30
```

Accepted default kernel is `results/mapairy-llvm12-baseline-v1/kernel.hsaco`. Two retained synthetic 65539-element fixtures: interval-mixture and coherent-blocks. References regenerated with the pinned Boost long-double Map-Airy CPU oracle. Both fixtures use p <= 0.5; upper-tail execution is outside this validation scope. No application-captured data or historical-input replication claimed.

Pinned Boost headers are shared through `source/boost-math` with the existing Landau case. Kernel and oracle sources, build recipes, fixture buffers, references, and provenance are maintained in this case directory.

`experiments/mapairy-integration-v1` compares baseline, automatic DARM, and the same manual lower-tail balanced tree with original CFG or fixed-point scalar intermediate cleanup. All receive final O3. See `docs/mapairy-integration.md` for results. This does not port the Landau-only Share/Bloat boundary heuristic to Map-Airy.
