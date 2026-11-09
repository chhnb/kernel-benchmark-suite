#!/bin/bash
set -euo pipefail
cd /home/chh/kernel-benchmark-suite
bash experiments/mapairy-full-convergence-20261109-v1/run.sh
build/llvm24-tti/fusion-search-llvm24 --ir results/mapairy-llvm12-baseline-v1/post.ll --function evaluate --structural 1 --adjacent-only 0 --cleanup scoped-cfg --scorer llvm24 --rounds 256 --trials 100000 --debug-dir experiments/mapairy-full-convergence-20261109-v1/greedy --out experiments/mapairy-full-convergence-20261109-v1/greedy.ll
