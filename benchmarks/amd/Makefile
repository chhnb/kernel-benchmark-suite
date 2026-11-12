SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
.DEFAULT_GOAL := benchmark

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
SUITE ?= $(ROOT)
CASE ?= vllm
LLVM_BIN ?= /usr/bin
ROCM ?= /opt/rocm
ROCM_LLVM_BIN ?= $(ROCM)/llvm/bin
DARM_OPT ?= $(LLVM_BIN)/opt
DARM_PLUGIN ?=
JOBS ?= 3
BUILD ?= $(ROOT)/build/benchmarks/amd/$(CASE)
BUILD := $(abspath $(BUILD))
OPT := $(LLVM_BIN)/opt
GREEDY := $(SUITE)/build/decision-fuse/decision-greedy
FUSER := $(SUITE)/build/decision-fuse/decision-fuse
TTI := $(SUITE)/build/llvm24-tti/llvm24-tti
CPU := gfx906
FEATURES := +sramecc,-xnack
HIP_FLAGS := -std=c++17 -O2 -D__HIP_PLATFORM_AMD__ -I"$(ROCM)/include"
HIP_LIBS := -L"$(ROCM)/lib" -Wl,-rpath,"$(ROCM)/lib" -lamdhip64

ifeq ($(CASE),vllm)
SOURCE ?= $(ROOT)/cases/vllm-quant/start.ll
KERNEL := cache_eval
BLOCK := 64
else ifeq ($(CASE),mapairy)
SOURCE ?= $(ROOT)/cases/boost-mapairy/start.ll
KERNEL := evaluate
BLOCK := 256
else
$(error Unknown AMD CASE=$(CASE); choose vllm or mapairy)
endif

.PHONY: benchmark variants inputs audit list
list:
	@printf '%s\n' 'vllm   (64K and 128K generated inputs)' 'mapairy (generated interval mixture)'

variants: $(BUILD)/baseline.hsaco $(BUILD)/darm.hsaco $(BUILD)/greedy.hsaco
inputs: $(BUILD)/generated/generation.json
audit: $(BUILD)/greedy/final.ll
	python3 "$(SUITE)/tests/decision-model/check_greedy_report.py" "$(BUILD)/greedy/summary.json"

benchmark: variants inputs $(BUILD)/bench_hip audit
	sha256sum "$(BUILD)"/{baseline,darm,greedy}.hsaco > "$(BUILD)/SHA256SUMS"
	run_dir=$$(mktemp -d "$(BUILD)/replay.XXXXXX"); \
	  for spec in "$(BUILD)"/generated/*/input.txt; do \
	    fixture=$$(basename "$$(dirname "$$spec")"); \
	    "$(BUILD)/bench_hip" --kernel "$(BUILD)/baseline.hsaco" \
	      --darm "$(BUILD)/darm.hsaco" --greedy "$(BUILD)/greedy.hsaco" \
	      --input "$$spec" --output "$$run_dir/$$fixture" \
	      --mode benchmark --timing event --warmup 3 --repeat 15; \
	    cat "$$run_dir/$$fixture/result.json"; \
	  done; \
	  printf 'Reports: %s\n' "$$run_dir"

$(BUILD):
	mkdir -p "$@"

$(BUILD)/generated/generation.json: $(ROOT)/regression/generators/prepare.py $(ROOT)/regression/generators/generated_fixtures.cpp | $(BUILD)
	python3 "$(ROOT)/regression/generators/prepare.py" "$(CASE)" "$(BUILD)/generated"

$(BUILD)/bench_hip: $(ROOT)/runner/replay.cpp $(ROOT)/runner/gpu.hpp $(ROOT)/runner/options.hpp | $(BUILD)
	$(CXX) $(HIP_FLAGS) -DBENCH_HIP "$<" $(HIP_LIBS) -o "$@"

$(BUILD)/occupancy: $(ROOT)/tools/decision_amdgpu_occupancy.cpp | $(BUILD)
	$(CXX) $(HIP_FLAGS) "$<" $(HIP_LIBS) -o "$@"

$(BUILD)/input.ll: $(SOURCE) | $(BUILD)
	"$(LLVM_BIN)/llvm-config" --version | grep -Eq '^12\.'
	"$(OPT)" "$<" -verify -disable-output
	cp "$<" "$@"

$(BUILD)/darm.ll: $(BUILD)/input.ll $(DARM_PLUGIN)
	flags=(); if [[ -n "$(DARM_PLUGIN)" ]]; then flags=(-load "$(DARM_PLUGIN)" -enable-new-pm=0); fi; \
	  "$(DARM_OPT)" "$${flags[@]}" "$<" -cfmelder -run-cfmelding-on-function="$(KERNEL)" \
	    -verify -S -o "$@" > "$(BUILD)/darm.log" 2>&1 || { tail -40 "$(BUILD)/darm.log" >&2; exit 1; }

$(BUILD)/greedy/final.ll: $(BUILD)/input.ll $(BUILD)/occupancy $(GREEDY) $(FUSER) $(TTI)
	DECISION_SPECULATION=cost DECISION_CFG_CLEANUP=structural DECISION_CHECKPOINT_MODE=enforce \
	  DECISION_GREEDY_JOBS="$(JOBS)" DECISION_CHECKPOINT_TOOL="$(ROOT)/tools/decision_amdgpu_checkpoint.py" \
	  DECISION_AMDGPU_LLVM_BIN="$(LLVM_BIN)" DECISION_ROCM_LLVM_BIN="$(ROCM_LLVM_BIN)" \
	  DECISION_AMDGPU_CPU="$(CPU)" DECISION_AMDGPU_FEATURES="$(FEATURES)" \
	  DECISION_AMDGPU_BLOCK_SIZE="$(BLOCK)" DECISION_AMDGPU_OCCUPANCY_TOOL="$(BUILD)/occupancy" \
	  "$(GREEDY)" "$<" "$(KERNEL)" "$(SUITE)" "$(BUILD)/greedy"

$(BUILD)/baseline.hsaco: $(BUILD)/input.ll
$(BUILD)/darm.hsaco: $(BUILD)/darm.ll
$(BUILD)/greedy.hsaco: $(BUILD)/greedy/final.ll
$(BUILD)/baseline.hsaco $(BUILD)/darm.hsaco $(BUILD)/greedy.hsaco:
	tmp=$$(mktemp -d "$(BUILD)/codegen.XXXXXX"); trap 'rm -rf "$$tmp"' EXIT; \
	  "$(OPT)" "$<" -O3 -verify-each -S -o "$$tmp/optimized.ll"; \
	  "$(LLVM_BIN)/llc" "$$tmp/optimized.ll" -O3 -mtriple=amdgcn-amd-amdhsa \
	    -mcpu="$(CPU)" -mattr="$(FEATURES)" -amdhsa-code-object-version=4 -filetype=obj -o "$$tmp/kernel.o"; \
	  "$(ROCM_LLVM_BIN)/ld.lld" -shared "$$tmp/kernel.o" -o "$@"
