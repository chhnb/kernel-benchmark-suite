#!/bin/bash
set -euo pipefail
cd /home/chh/kernel-benchmark-suite
lc=/home/chh/darm-artifacts-repro/build/bin/llvm-config
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader asmparser analysis transformutils scalaropts ipo instcombine vectorize amdgpu x86 nvptx --system-libs | tr "\n" " ")"
b=build/llvm24-tti
objects=()
for n in postopt_profile_policy postopt_scorer ir_pressure ir_dependency fusion_search logical_region_state RegionAnalyzer RegionMelder RegionReplicator CFMelderUtils InstructionMatch; do objects+=("$b/$n.o"); done
python3 - <<'PYTEST'
from pathlib import Path
p=Path('tests/postopt/intrinsic_matching.cpp')
s=p.read_text().replace('auto hash=moduleHash(*m);auto trial=','pair.coalesceGaps=true;auto hash=moduleHash(*m);auto trial=')
assert 'pair.coalesceGaps=true' in s
Path('build/llvm24-tti/coalesce-intrinsic-on.cpp').write_text(s)
PYTEST
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -Itools -Itools/darm_pair_engine build/llvm24-tti/coalesce-intrinsic-on.cpp "${objects[@]}" "${libs[@]}" -lcrypto -o build/llvm24-tti/coalesce-intrinsic-on
build/llvm24-tti/coalesce-intrinsic-on
