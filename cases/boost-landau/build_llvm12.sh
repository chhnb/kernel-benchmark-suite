#!/bin/sh
set -eu
CASE=$1
OUT=$2
OPT=/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt
LLC=/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/llc
"$OPT" "$OUT/start.ll" -always-inline -O3 -internalize -internalize-public-api-list=evaluate -globaldce -verify -S -o "$OUT/post.ll"
"$LLC" "$OUT/post.ll" -O3 -mtriple=amdgcn-amd-amdhsa -mcpu=gfx906 -mattr=+sram-ecc,-xnack -filetype=obj -o "$OUT/kernel.o"
/opt/rocm/llvm/bin/ld.lld -shared "$OUT/kernel.o" -o "$OUT/kernel.hsaco"
