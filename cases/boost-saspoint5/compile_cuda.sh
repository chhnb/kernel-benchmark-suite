#!/bin/bash
set -euo pipefail
c=$1
out=$2
t=/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin
"$t/clang" -Xclang -fcuda-allow-variadic-functions -x cuda --cuda-device-only --cuda-path=/usr/local/cuda --no-cuda-version-check -nocudalib -Xclang -mlink-builtin-bitcode -Xclang /usr/local/cuda/nvvm/libdevice/libdevice.10.bc --cuda-gpu-arch=sm_70 -include "$c/source/legacy-launch.h" -std=c++17 -O3 -ffp-contract=off -DBOOST_MATH_STANDALONE -I"$c/source/boost-math/include" -S -emit-llvm "$c/source/kernel.cu" -o "$out/start.ll"
"$t/opt" "$out/start.ll" -always-inline -inline-threshold=1000000 -inline -O3 -internalize -internalize-public-api-list=evaluate -globaldce -verify -S -o "$out/post.ll"
"$t/llc" "$out/post.ll" -O3 -march=nvptx64 -mcpu=sm_70 -mattr=+ptx70 -o "$out/kernel.ptx"
/usr/local/cuda/bin/ptxas -O3 -arch=sm_70 "$out/kernel.ptx" -o "$out/kernel.cubin"
