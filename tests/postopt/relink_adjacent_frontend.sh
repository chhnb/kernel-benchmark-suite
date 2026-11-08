#!/bin/bash
set -euo pipefail
r=/home/chh/kernel-benchmark-suite
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader asmparser analysis transformutils scalaropts ipo instcombine vectorize amdgpu x86 nvptx --system-libs | tr '\n' ' ')"
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER -I"$r/tools" -I"$r/tools/darm_pair_engine" "$r/tools/fusion_search_llvm24_main.cpp" "$r"/build/llvm24-tti/*.o "${libs[@]}" -lcrypto -o "$r/build/llvm24-tti/fusion-search-llvm24"
