#!/usr/bin/env bash
# Run through the suite CPU admission wrapper on musa.
set -euo pipefail
r=$(cd "$(dirname "$0")/../.." && pwd)
cd "$r"
bash tools/build-decision-fuse
bash tools/build-decision-greedy
bash tools/build-decision-model
lc=${LLVM_CONFIG:-/home/chh/darm-artifacts-repro/build/bin/llvm-config}
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader asmparser analysis transformutils --system-libs | tr '\n' ' ')"
for test in condition trial_simplify_cfg review_policy scoped_cfg uniform_paths; do
  g++ "${flags[@]}" -std=c++17 -fexceptions -UNDEBUG -O2 -Itools "tests/decision-model/${test}_check.cpp" "${libs[@]}" -o "build/decision-fuse/${test//_/-}-check"
done
build/decision-fuse/trial-simplify-cfg-check
build/decision-fuse/review-policy-check
build/decision-fuse/scoped-cfg-check
build/decision-fuse/uniform-paths-check
python3 tests/decision-model/cleanup_mode_check.py
python3 tests/decision-model/pair_join_check.py
read -r -a engine_libs <<< "$($lc --ldflags --libs core irreader analysis transformutils scalaropts instcombine amdgpu x86 nvptx --system-libs | tr '\n' ' ')"
g++ "${flags[@]}" -std=c++17 -fexceptions -UNDEBUG -O2 -Itools -Itools/darm_pair_engine \
  tests/decision-model/multi_anchor_check.cpp tools/decision_model.cpp \
  build/decision-fuse/{RegionAnalyzer,RegionMelder,RegionReplicator,CFMelderUtils,InstructionMatch}.o \
  "${engine_libs[@]}" -o build/decision-fuse/multi-anchor-check
python3 tests/decision-model/multi_anchor_check.py
for test in review_policy run condition_check fuse_check full_tree_check identity_check; do
  python3 "tests/decision-model/$test.py"
done
