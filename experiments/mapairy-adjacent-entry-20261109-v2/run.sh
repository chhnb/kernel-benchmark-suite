#!/bin/bash
set -euo pipefail
r=/home/chh/kernel-benchmark-suite
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader asmparser analysis transformutils scalaropts ipo instcombine vectorize amdgpu x86 nvptx --system-libs | tr '\n' ' ')"
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER -I"$r/tools" -I"$r/tools/darm_pair_engine" "$r/experiments/mapairy-adjacent-entry-20261109-v2/replay.cpp" "$r"/build/llvm24-tti/*.o "${libs[@]}" -lcrypto -o "$r/experiments/mapairy-adjacent-entry-20261109-v2/replay"
"$r/experiments/mapairy-adjacent-entry-20261109-v2/replay" "$r/results/mapairy-llvm12-baseline-v1/post.ll" "$r/experiments/mapairy-adjacent-entry-20261109-v2/steps-final" cfg
