#!/bin/bash
set -euo pipefail
r=/home/chh/kernel-benchmark-suite
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER -I"$r/tools" -I"$r/tools/darm_pair_engine" -c "$r/tools/logical_region_state.cpp" -o "$r/build/llvm24-tti/logical_region_state.o"
bash "$r/tests/postopt/relink_adjacent_frontend.sh"
