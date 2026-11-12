#!/usr/bin/env bash
set -euo pipefail
llvm=$1 cuda=$2 input=$3 output=$4
scratch=$(mktemp -d "$(dirname "$output")/codegen.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
"$llvm/opt" "$input" -O3 -verify-each -S -o "$scratch/opt.ll"
"$llvm/llc" "$scratch/opt.ll" -O3 -march=nvptx64 -mcpu=sm_70 -o "$scratch/kernel.ptx"
"$cuda/bin/ptxas" -v -arch=sm_70 "$scratch/kernel.ptx" -o "$output"
