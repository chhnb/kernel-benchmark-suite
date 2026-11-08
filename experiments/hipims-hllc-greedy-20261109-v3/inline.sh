#!/bin/bash
set -euo pipefail
p=/home/chh/kernel-benchmark-suite/experiments/hipims-hllc-greedy-20261109-v3
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader transformutils analysis --system-libs | tr '\n' ' ')"
g++ "${flags[@]}" -std=c++17 -O2 "$p/inline_baseline.cpp" "${libs[@]}" -o "$p/inline-baseline"
