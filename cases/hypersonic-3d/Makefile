SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

CASE := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SUITE ?= $(abspath $(CASE)/../..)
BUILD ?= $(abspath $(CASE)/../../build/hypersonic-3d)
BUILD := $(abspath $(BUILD))
LLVM_BIN ?= /usr/bin
CUDA ?= /usr/local/cuda
JOBS ?= 3
DARM_OPT ?= $(LLVM_BIN)/opt
DARM_PLUGIN ?=
KERNEL := _Z6k_stepPKfS0_S0_S0_S0_S0_PfS1_S1_S1_S1_S1_ffS1_PKh
SOURCE_SHA := 533edca7dacd1f6353ecae8ad643028e7c16ea72bae71098000ed03cec19602a
SOURCE_URL := https://raw.githubusercontent.com/seanwevans/fluid-sims/cffb0e8f5e137193c50e9812fd88cb628ded4ccf/tau_hypersonic_3d_cuda.cu
CUDA_FLAGS := -std=c++17 -O3
OPT := $(LLVM_BIN)/opt
GREEDY := $(SUITE)/build/decision-fuse/decision-greedy
FUSER := $(SUITE)/build/decision-fuse/decision-fuse
TTI := $(SUITE)/build/llvm24-tti/llvm24-tti
BASELINE := $(BUILD)/baseline.cubin
GREEDY_CUBIN := $(BUILD)/greedy.cubin
DARM := $(BUILD)/darm.cubin
VARIANTS := $(BASELINE) $(GREEDY_CUBIN)
ifneq ($(strip $(DARM_PLUGIN)),)
VARIANTS += $(DARM)
endif

.PHONY: all baseline greedy darm benchmark benchmark-darm audit
all: $(BUILD)/bench $(VARIANTS)
baseline: $(BASELINE)
greedy: $(GREEDY_CUBIN)
darm: $(DARM)
benchmark: all
	grep -Eq '"commits"[[:space:]]*:[[:space:]]*[1-9]' "$(BUILD)/greedy/summary.json"
	"$(BUILD)/bench" 64 -5.2 $(foreach file,$(VARIANTS),"$(file)") > "$(BUILD)/64.csv"
	"$(BUILD)/bench" 96 -4.65 $(foreach file,$(VARIANTS),"$(file)") > "$(BUILD)/96.csv"
benchmark-darm: $(BUILD)/bench $(BASELINE) $(GREEDY_CUBIN) $(DARM)
	grep -Eq '"commits"[[:space:]]*:[[:space:]]*[1-9]' "$(BUILD)/greedy/summary.json"
	"$(BUILD)/bench" 64 -5.2 "$(BASELINE)" "$(GREEDY_CUBIN)" "$(DARM)" > "$(BUILD)/64-three-way.csv"
	"$(BUILD)/bench" 96 -4.65 "$(BASELINE)" "$(GREEDY_CUBIN)" "$(DARM)" > "$(BUILD)/96-three-way.csv"
audit: $(BUILD)/greedy/final.ll
	python3 "$(SUITE)/tests/decision-model/check_greedy_report.py" "$(BUILD)/greedy/summary.json"

$(BUILD):
	mkdir -p "$@"

ifeq ($(strip $(SOURCE)),)
SOURCE := $(BUILD)/upstream.cu
$(SOURCE): | $(BUILD)
	curl --fail --location --silent --show-error "$(SOURCE_URL)" -o "$@"
endif

$(BUILD)/device.cu: $(SOURCE) $(CASE)/Makefile | $(BUILD)
	printf '%s  %s\n' "$(SOURCE_SHA)" "$<" | sha256sum --check
	sed -e '/^static void draw_slice_z/,$$d' \
	    -e '/^static inline Vector3 v3_add/,/^static inline Vector3 v3_rotate_axis_angle/{ /^static inline Vector3 v3_rotate_axis_angle/!d; }' \
	    -e '/^static inline Vector3 v3_rotate_axis_angle/,/^}/d' \
	    -e '/^#include "raylib.h"$$/d' -e '/^#include "rlgl.h"$$/d' "$<" > "$@"

$(BUILD)/start.ll: $(BUILD)/device.cu
	"$(LLVM_BIN)/llvm-config" --version | grep -Eq '^12\.'
	"$(LLVM_BIN)/clang" -x cuda --cuda-device-only --cuda-path="$(CUDA)" \
	  --no-cuda-version-check -nocudalib --cuda-gpu-arch=sm_70 $(CUDA_FLAGS) \
	  -Xclang -fcuda-allow-variadic-functions -Xclang -target-feature -Xclang +ptx60 \
	  -Xclang -mlink-builtin-bitcode -Xclang "$(CUDA)/nvvm/libdevice/libdevice.10.bc" \
	  -S -emit-llvm "$<" -o "$@"

$(BUILD)/inlined.ll: $(BUILD)/start.ll
	sed -E 's/, !(alias.scope|noalias) ![0-9]+//g; /^[[:space:]]*(tail )?call void @llvm.experimental.noalias.scope.decl\(/d' \
	  "$<" > "$(BUILD)/compatible.ll"
	"$(OPT)" "$(BUILD)/compatible.ll" -inline-threshold=100000 -inline -verify -S -o "$@"

$(BUILD)/occupancy: $(CASE)/occupancy.cpp | $(BUILD)
	$(CXX) -std=c++17 -I"$(CUDA)/include" "$<" -lcuda -o "$@"

$(BUILD)/greedy/final.ll: $(BUILD)/inlined.ll $(BUILD)/occupancy $(GREEDY) $(FUSER) $(TTI) $(CASE)/checkpoint.sh $(CASE)/codegen.sh
	DECISION_SPECULATION=cost DECISION_CFG_CLEANUP=structural \
	  DECISION_CHECKPOINT_MODE=enforce DECISION_GREEDY_JOBS="$(JOBS)" \
	  DECISION_CHECKPOINT_TOOL="$(CASE)/checkpoint.sh" \
	  HYPERSONIC3D_LLVM_BIN="$(LLVM_BIN)" HYPERSONIC3D_CUDA="$(CUDA)" \
	  HYPERSONIC3D_OUTPUT="$(BUILD)" \
	  "$(GREEDY)" "$<" "$(KERNEL)" "$(SUITE)" "$(BUILD)/greedy"

$(BUILD)/darm.ll: $(BUILD)/inlined.ll $(DARM_PLUGIN)
	flags=(); if [[ -n "$(DARM_PLUGIN)" ]]; then flags=(-load "$(DARM_PLUGIN)" -enable-new-pm=0); fi; \
	  "$(DARM_OPT)" "$${flags[@]}" "$<" -cfmelder -run-cfmelding-on-function="$(KERNEL)" \
	    -verify -S -o "$@" > "$(BUILD)/darm.log" 2>&1

$(BASELINE): $(BUILD)/inlined.ll $(CASE)/codegen.sh
$(GREEDY_CUBIN): $(BUILD)/greedy/final.ll $(CASE)/codegen.sh
$(DARM): $(BUILD)/darm.ll $(CASE)/codegen.sh
$(BASELINE) $(GREEDY_CUBIN) $(DARM):
	"$(CASE)/codegen.sh" "$(LLVM_BIN)" "$(CUDA)" "$<" "$@" 2> "$@.ptxas.log"

$(BUILD)/bench: $(CASE)/bench.cu $(BUILD)/device.cu
	"$(CUDA)/bin/nvcc" $(CUDA_FLAGS) -arch=sm_70 -I"$(BUILD)" "$<" -lcuda -o "$@"
