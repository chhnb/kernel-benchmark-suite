#!/bin/bash
# Side reachability, uniform-loss guard, tag hygiene and greedy exception isolation.
set -euo pipefail
r=${ROOT:-/home/chh/kernel-benchmark-suite}
lc=${LLVM12_CONFIG:-/home/chh/darm-artifacts-repro/build/bin/llvm-config}
read -r -a flags <<< "$($lc --cxxflags)"
read -r -a libs <<< "$($lc --ldflags --libs core irreader asmparser analysis transformutils scalaropts ipo instcombine vectorize amdgpu x86 nvptx --system-libs | tr '\n' ' ')"
b=$r/build/llvm24-tti
objects=()
for n in postopt_profile_policy postopt_scorer ir_pressure ir_dependency fusion_search logical_region_state RegionAnalyzer RegionMelder RegionReplicator CFMelderUtils InstructionMatch; do objects+=("$b/$n.o"); done
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER -I"$r/tools" -I"$r/tools/darm_pair_engine" "$r/tests/postopt/side-metrics/check.cpp" "${objects[@]}" "${libs[@]}" -lcrypto -o "$b/side-metrics-test"
"$b/side-metrics-test" "$b/side-metrics.ll"
g++ "${flags[@]}" -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER -I"$r/tools" -I"$r/tools/darm_pair_engine" "$r/tests/postopt/side-metrics/b2r_budget.cpp" "${objects[@]}" "${libs[@]}" -lcrypto -o "$b/b2r-budget-test"
"$b/b2r-budget-test" "$b/b2r-budget.ll"
# End to end with the real LLVM24 worker: the balanced tree must report negative
# uniform gains for cross-level R2B (opt-in) and the guard must reject them.
worker=${TTI_WORKER:-$r/tools/run-llvm24-tti}
if [ -x "$worker" ] && [ -x "$b/fusion-search-llvm24" ]; then
  d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
  "$b/fusion-search-llvm24" --ir "$r/tests/postopt/side-metrics/tree-amdgcn.ll" --function tree --out "$d/out.ll" \
    --structural 1 --cleanup scoped-cfg --scorer llvm24 --tti-worker "$worker" --cross-decision-leaves 1 \
    --max-uniform-loss 10 --debug-dir "$d/run" >/dev/null 2>&1
  python3 - "$d/run" <<'PY'
import json,glob,sys
seen=0
for f in glob.glob(sys.argv[1]+'/trial-*/trial.json'):
    j=json.load(open(f));m=j['score_result'].get('metrics',{})
    if j['valid'] and m.get('side_metrics_available')!=1: raise SystemExit('side metrics missing: '+j['candidate'])
    if 'R2B' in j['merge_path']:
        seen+=1
        assert min(m['uniform_gain_false'],m['uniform_gain_true'])<-10, j['candidate']
        assert not j['eligible'], 'guard accepted cross-level '+j['candidate']
assert seen, 'no cross-level R2B trial'
print('side-metrics e2e ok')
PY
fi
