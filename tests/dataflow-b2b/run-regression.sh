#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$root"
llvm12="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
llvm24="$HOME/v2-runtime/toolchains/llvm24-pinned"
export LLVM_CONFIG=${LLVM_CONFIG:-"${KBS_LLVM12_BIN:-"$llvm12/lib/llvm-12/bin"}/llvm-config"}
export KBS_LLVM12_BIN=${KBS_LLVM12_BIN:-"$(dirname "$LLVM_CONFIG")"}
export LLVM12_LIBDIR=${LLVM12_LIBDIR:-"$llvm12/lib/x86_64-linux-gnu"}
export LLVM24_CONFIG=${LLVM24_CONFIG:-"$llvm24/bin/llvm-config"}
export LLVM24_LIBDIR=${LLVM24_LIBDIR:-"$llvm24/lib"}
export LD_LIBRARY_PATH="$LLVM12_LIBDIR:$LLVM24_LIBDIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PYTHONDONTWRITEBYTECODE=1

base="$root/build/dataflow-regression"
mkdir -p "$base"
work=$(mktemp -d "$base/run.XXXXXX")
echo "Work directory: $work"
start=$SECONDS
build_tools() {
    if [[ ! -x build/llvm24-tti/llvm24-tti ]]; then
        tools/build-llvm24-tti --worker-only || return
    fi
    tools/build-decision-greedy --with-structural || return
    local compile_flags link_flags
    compile_flags=$("$LLVM_CONFIG" --cxxflags) || return
    link_flags=$("$LLVM_CONFIG" --ldflags --libs core irreader analysis transformutils support --system-libs | tr '\n' ' ') || return
    read -r -a cflags <<< "$compile_flags"
    read -r -a libs <<< "$link_flags"
    "${CXX:-g++}" "${cflags[@]}" -std=c++17 -fexceptions -O2 \
        tools/dataflow_b2b/check_fold_oracle.cpp "${libs[@]}" -o "$work/check_fold_oracle"
}
if ! build_tools >"$work/build.log" 2>&1; then
    cat "$work/build.log" >&2
    exit 1
fi
echo "Build and tool setup: $((SECONDS - start)) s"
python3 tests/dataflow-b2b/regression.py "$work" --jobs "${KBS_DATAFLOW_JOBS:-12}"
