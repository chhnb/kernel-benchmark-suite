#!/bin/bash
set -euo pipefail
r=/home/chh/kernel-benchmark-suite
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader asmparser analysis transformutils scalaropts ipo instcombine vectorize amdgpu x86 nvptx --system-libs | tr '\n' ' ')"
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER -I"$r/tools" -I"$r/tools/darm_pair_engine" "$r/tests/postopt/scoped_cfg_runtime.cpp" "$r"/build/llvm24-tti/*.o "${libs[@]}" -lcrypto -o "$r/build/llvm24-tti/scoped-cfg-runtime-test"

"$r/build/llvm24-tti/scoped-cfg-runtime-test" "$r/build/llvm24-tti/scoped-cfg-runtime.ll"
/home/chh/darm-artifacts-repro/build/bin/clang -O0 -c "$r/build/llvm24-tti/scoped-cfg-runtime.ll" -o "$r/build/llvm24-tti/scoped-cfg-runtime-runtime.obj"
g++ -std=c++17 -O0 "$r/tests/postopt/guard_pairs_runtime.cpp" "$r/build/llvm24-tti/scoped-cfg-runtime-runtime.obj" -lm -o "$r/build/llvm24-tti/scoped-cfg-runtime-runtime"
"$r/build/llvm24-tti/scoped-cfg-runtime-runtime"
