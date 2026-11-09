#!/bin/bash
set -euo pipefail
cd /home/chh/kernel-benchmark-suite
build/llvm24-tti/fusion-search-llvm24 --ir results/mapairy-llvm12-baseline-v1/post.ll --function evaluate --structural 1 --adjacent-only 0 --cleanup scoped-cfg --scorer llvm24 --rounds 1 --trials 100000 --debug-dir experiments/mapairy-intrinsic-match-20261109-v2/auto-round --out experiments/mapairy-intrinsic-match-20261109-v2/auto-round.ll
