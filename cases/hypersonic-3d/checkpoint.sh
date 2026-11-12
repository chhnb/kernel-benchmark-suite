#!/usr/bin/env bash
set -euo pipefail
case_dir=$(cd "$(dirname "$0")" && pwd)
input=$1 function=$2
scratch=$(mktemp -d "$HYPERSONIC3D_OUTPUT/checkpoint.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
if ! "$case_dir/codegen.sh" "$HYPERSONIC3D_LLVM_BIN" "$HYPERSONIC3D_CUDA" \
        "$input" "$scratch/kernel.cubin" 2> "$scratch/ptxas.log"; then
    cat "$scratch/ptxas.log" >&2
    exit 1
fi
read -r registers spills < <(awk -v function_name="$function" '
    /Function properties for / { selected = ($NF == function_name) }
    selected && /bytes spill stores/ {
        for (i=2; i<NF; i++) {
            if ($i == "bytes" && $(i+1) == "spill") spills += $(i-1)
        }
    }
    selected && /Used [0-9]+ registers/ {
        for (i=1; i<NF; i++) if ($i == "Used") {
            print $(i+1), spills+0
            exit
        }
    }
' "$scratch/ptxas.log")
blocks=$("$HYPERSONIC3D_OUTPUT/occupancy" "$scratch/kernel.cubin" "$function")
# The decision transaction interface names these fields for AMDGPU.
printf '{"vgpr_count":%d,"sgpr_count":0,"vgpr_spill_count":%d,"sgpr_spill_count":0,"active_blocks_per_cu":%d}\n' \
    "$registers" "$spills" "$blocks"
