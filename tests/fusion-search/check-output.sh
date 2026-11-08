#!/usr/bin/env bash
set -euo pipefail
suite_root=$(cd "$(dirname "$0")/../.." && pwd)
run_dir=$1
clang=/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/clang
for kind in blocks regions chain blocks-darm-cfg regions-darm-cfg blocks-earlycse regions-earlycse blocks-scalar-fp regions-scalar-fp; do
  sed -e 's/@choose(/@before(/g' -e 's/@unrelated(/@before_unrelated(/g' "$run_dir/$kind-before.ll" > "$run_dir/$kind-before-named.ll"
  sed -e 's/@choose(/@after(/g' -e 's/@unrelated(/@after_unrelated(/g' "$run_dir/$kind-after.ll" > "$run_dir/$kind-after-named.ll"
  "$clang" -O2 -c "$run_dir/$kind-before-named.ll" -o "$run_dir/$kind-before.o"
  "$clang" -O2 -c "$run_dir/$kind-after-named.ll" -o "$run_dir/$kind-after.o"
  # x=1..100 avoids division by zero in the chain fixture.
  cat > "$run_dir/compare.cpp" <<'CPP'
#include <cstdio>
extern "C" int before(int,int,int);
extern "C" int after(int,int,int);
int main(){for(int x=1;x<=100;++x)for(int a=0;a<2;++a)for(int b=0;b<2;++b)if(before(x,a,b)!=after(x,a,b)){std::fprintf(stderr,"mismatch %d %d %d\n",x,a,b);return 1;}return 0;}
CPP
  g++ "$run_dir/compare.cpp" "$run_dir/$kind-before.o" "$run_dir/$kind-after.o" -o "$run_dir/$kind-check"
  "$run_dir/$kind-check"
done
# Debug-disabled operation must produce only requested IR outputs, no JSON dependency.
mkdir "$run_dir/no-json"
"$suite_root/build/fusion-search/fusion-search" --ir "$run_dir/chain-before.ll" --function choose --out "$run_dir/no-json/result.ll" --rounds 2 --trials 256
"$suite_root/build/fusion-search/fusion-search" --ir "$run_dir/chain-before.ll" --function choose --out "$run_dir/debug-result.ll" --rounds 2 --trials 256 --debug-dir "$run_dir/debug"
cmp "$run_dir/no-json/result.ll" "$run_dir/debug-result.ll"
[[ $(find "$run_dir/no-json" -type f | wc -l) -eq 1 ]]
echo 'PASS 3600 native CPU comparisons, identical debug on/off output, no JSON needed'
if [[ -f "$run_dir/loop-before.ll" ]]; then python3 "$suite_root/tests/fusion-search/check-loop-output.py" "$run_dir"; fi
