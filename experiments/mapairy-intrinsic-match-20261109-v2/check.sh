#!/bin/bash
set -euo pipefail
cd /home/chh/kernel-benchmark-suite
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER -Itools -Itools/darm_pair_engine -c tools/darm_pair_engine/InstructionMatch.cpp -o build/llvm24-tti/InstructionMatch.o
bash tests/postopt/relink_adjacent_frontend.sh
bash tests/postopt/build_intrinsic_matching.sh
bash experiments/mapairy-intrinsic-match-20261109-v2/run.sh
python3 experiments/mapairy-intrinsic-match-20261109-v2/compile.py
python3 experiments/tigre-mapairy-intrinsic-regression-20261109-v2/prepare.py
python3 experiments/vllm-mapairy-intrinsic-regression-20261109-v2/prepare.py
