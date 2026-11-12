# 3D Hypersonic CUDA regression

This case uses the full `k_step` kernel from fluid-sims at commit
`cffb0e8f5e137193c50e9812fd88cb628ded4ccf`. The runner checks the SHA-256 of the
upstream file and removes its host-side visualization code in the build
directory. It preserves the complete solver kernel, its device helpers, and
the upstream geometry and initialization kernels.

## Run on TITAN V

From the suite root, with the LLVM12 decision tools and the pinned LLVM24
NVPTX worker built in their usual locations:

```sh
CUDA_VISIBLE_DEVICES=0 make -C cases/hypersonic-3d benchmark \
  LLVM_BIN=/path/to/llvm12/bin BUILD=/path/to/new-hypersonic-3d-run
```

The case follows the DARM artifact layout of a native CUDA program and a
per-case Makefile with separate variant targets. `make` builds the binaries,
and `make benchmark` runs the C++ replay and performance gate. Use
`make benchmark-darm DARM_PLUGIN=/path/to/CFMelder.so` for the LLVM12 plugin
build of original DARM (`e9bc054`), or pass `DARM_OPT=/path/to/darm/opt`
for an artifact opt with the pass built in. Use a fresh `BUILD` directory
when changing the compiler or source.

Set `SUITE` if the compiled decision tools and the worker live in a different
suite checkout. Set `SOURCE` to use a local copy of the pinned upstream
CUDA file. CUDA defaults to `/usr/local/cuda`. Set `LD_LIBRARY_PATH`
when your LLVM installations require it. The existing Python report auditor
is available as the optional `make audit` target.

1. Clang/LLVM12 compiles the CUDA device translation unit at `-O3` for
   `sm_70` and PTX 6.0, with CUDA libdevice linked into the frontend IR.
   The runner removes legacy alias-scope metadata rejected by LLVM24 and
   runs the LLVM12 inliner so that the six WENO reconstruction calls can
   be scored as part of the complete kernel.
2. `decision-greedy` takes that normalized IR and the mangled `k_step`
   symbol. It uses `cost` speculation, structural CFG cleanup, and enforced
   compilation checkpoints. LLVM24 TTI scores candidates. The checkpoints
   compile with LLVM12 and PTXAS and check CUDA registers, spill and active
   blocks per SM at the original 256-thread launch and 49,000 bytes of
   dynamic shared memory. The search writes its transaction report to `greedy/summary.json`.
3. The unfused IR and `greedy/final.ll` go through the same LLVM12
   `opt -O3 -verify-each`, NVPTX `llc -O3`, and CUDA `ptxas` pipeline.
   Optional DARM runs from the same unfused IR and uses the same backend.
4. NVCC builds the headless harness and upstream initialization code.
   The harness advances the sphere-flow state by 12 fixed steps, then
   replays one `k_step` on that frozen state. It rotates the order of
   the CUDA cubins for 3 warmups and 20 timed rounds on each grid. All six
   arrays and the maximum wave speed are compared against the LLVM12
   baseline on every launch (`atol=3e-5`, `rtol=5e-5`). It logs NVCC
   differences separately because the LLVM12 baseline itself exceeded
   that tolerance in the original run.

The executable prints paired timing deltas and a pass/fail verdict, and
writes raw timing CSV to standard output. The Makefile saves the per-grid CSVs,
PTXAS logs, and the greedy report in the build directory.
The gate requires at least one retained fusion and paired greedy time at
least 5.20% lower than the same-batch baseline on 64³ and 4.65% lower on 96³.
These floors leave about two percentage points of headroom from the
[reference run](../../regression/records/20261112/hypersonic-3d-sm70.json)
(7.20% and 6.65%). They apply to TITAN V single-kernel replay. DARM is an
optional timing comparator and does not affect the performance gate.
