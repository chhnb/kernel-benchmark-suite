#!/usr/bin/env bash
set -euo pipefail

case_name=${1:?usage: run_step6_gpu.sh NQU64|MapAiry EXPERIMENT_DIRECTORY}
work=$(realpath "${2:?missing experiment directory}")
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
rocm=/opt/rocm-6.3.3
prof="$HOME/simplify-v2/build/b2b-layouts/anchor-heldout/rocm/prof/opt/rocm-6.3.3"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$rocm/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export HIP_VISIBLE_DEVICES=0 ROCR_VISIBLE_DEVICES=0
lock="$HOME/v2-runtime/gpu.lock"
dir="$work/$case_name"
gpu="$dir/gpu"
mkdir -p "$gpu/profile"
case "$case_name" in
  NQU64)
    symbol=_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i
    block_size=64
    runner="$PWD/tests/dataflow-b2b/replay-nqu64.py"
    input="$HOME/simplify-v2/build/dp1-removal/nqu"
    export NQU64_REPLAY="$HOME/simplify-v2/build/final-release.kzxLp5/gpu-tools/full-nqu"
    ;;
  MapAiry)
    symbol=evaluate
    block_size=256
    runner="$HOME/v2-runtime/cases/mapairy/runner"
    input="$HOME/v2-runtime/cases/mapairy/inputs/65539/input.txt"
    ;;
  *) exit 2 ;;
esac

for role in original anchor darm dataflow-ilp; do
  ir="$dir/$role/final.ll"
  if [[ $role == original ]]; then ir="$dir/input.ll"; fi
  "$llvm/lib/llvm-12/bin/opt" -verify -disable-output "$ir"
  "$llvm/lib/llvm-12/bin/llc" -O3 -march=amdgcn -mcpu=gfx906 -mattr=+sramecc \
    -amdhsa-code-object-version=4 -filetype=obj "$ir" -o "$gpu/$role.o"
  "$rocm/llvm/bin/ld.lld" -shared "$gpu/$role.o" -o "$gpu/$role.hsaco"
  "$rocm/llvm/bin/llvm-objdump" -d --mcpu=gfx906 "$gpu/$role.hsaco" > "$gpu/$role.s"
  flock "$lock" "$runner" --kernel "$gpu/$role.hsaco" --input "$input" --mode benchmark \
     --warmup 0 --repeat 1 --output "$gpu/validate-$role" > "$gpu/validate-$role.log"
done
python3 regression/measure_anchor_gpu.py --runner "$runner" --input "$input" \
  --output "$gpu/timing" --baseline "$gpu/original.hsaco" --reference "$gpu/anchor.hsaco" \
  --darm "$gpu/darm.hsaco" --candidate "$gpu/dataflow-ilp.hsaco" \
  --lock "$lock" --warmup 3 --repeat 15 > "$gpu/timing.log" || [[ $? == 3 ]]

printf 'pmc: Wavefronts VALUInsts SALUInsts VALUBusy MemUnitBusy MemUnitStalled\n' \
  > "$gpu/profile/metrics.txt"
"$rocm/bin/hipcc" -O2 tests/dataflow-b2b/query-gfx906-occupancy.cpp -o "$gpu/occupancy"
flock "$lock" "$gpu/occupancy" "$symbol" "$block_size" "$gpu"/{anchor,dataflow-ilp}.hsaco \
  > "$gpu/profile/occupancy.txt"
export LD_LIBRARY_PATH="$prof/lib:$LD_LIBRARY_PATH"
for role in anchor dataflow-ilp; do
  if [[ $case_name == NQU64 ]]; then
    args=("$NQU64_REPLAY" "$input/baseline.input" "$input/baseline.output" 18 profile "$gpu/$role.hsaco")
  else
    args=("$runner" --kernel "$gpu/$role.hsaco" --input "$input" --mode benchmark --warmup 3 \
          --repeat 15 --output "$gpu/profile/$role-replay")
  fi
  flock "$lock" timeout 150 "$prof/bin/rocprof" -i "$gpu/profile/metrics.txt" --timestamp on \
       -o "$gpu/profile/$role.csv" "${args[@]}" > "$gpu/profile/$role.log" 2>&1
  test "$(wc -l < "$gpu/profile/$role.csv")" -gt 1
done
