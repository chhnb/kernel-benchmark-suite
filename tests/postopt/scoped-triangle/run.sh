#!/bin/bash
set -euo pipefail
cd /home/chh/kernel-benchmark-suite
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader asmparser analysis transformutils scalaropts ipo instcombine vectorize amdgpu x86 nvptx --system-libs | tr "\n" " ")"
b=build/llvm24-tti
objects=()
for n in postopt_profile_policy postopt_scorer ir_pressure ir_dependency fusion_search logical_region_state RegionAnalyzer RegionMelder RegionReplicator CFMelderUtils InstructionMatch; do objects+=("$b/$n.o"); done
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -Itools -Itools/darm_pair_engine tests/postopt/scoped-triangle/check.cpp "${objects[@]}" "${libs[@]}" -lcrypto -o build/llvm24-tti/scoped-triangle-test
build/llvm24-tti/scoped-triangle-test build/llvm24-tti/scoped-triangle.ll
/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/clang -O0 -c build/llvm24-tti/scoped-triangle.ll -o build/llvm24-tti/scoped-triangle-runtime.obj
g++ tests/postopt/scoped-triangle/runtime.cpp build/llvm24-tti/scoped-triangle-runtime.obj -o build/llvm24-tti/scoped-triangle-runtime
build/llvm24-tti/scoped-triangle-runtime
