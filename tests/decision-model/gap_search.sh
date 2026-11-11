#!/usr/bin/env bash
# Invoke through the shared CPU admission wrapper on shared machines.
set -euo pipefail
r=$(cd "$(dirname "$0")/../.." && pwd)
cd "$r"
bash tools/build-decision-fuse
lc=${LLVM_CONFIG:-/home/chh/darm-artifacts-repro/build/bin/llvm-config}
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core asmparser analysis transformutils --system-libs | tr '\n' ' ')"
${CXX:-g++} "${flags[@]}" -std=c++17 -fexceptions -UNDEBUG -O2 -Itools tests/decision-model/gap_plan_check.cpp "${libs[@]}" -o build/decision-fuse/gap-plan-check
build/decision-fuse/gap-plan-check
python3 tests/decision-model/gap_search_check.py
