.DEFAULT_GOAL := benchmark
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
CASE ?= hypersonic-3d
BUILD ?= $(ROOT)/build/benchmarks/cuda/$(CASE)
BUILD := $(abspath $(BUILD))

.PHONY: benchmark variants list
list:
	@printf '%s\n' 'hypersonic-3d (64³ and 96³ sphere-flow replay)'

ifeq ($(CASE),hypersonic-3d)
benchmark:
	$(MAKE) -C "$(ROOT)/cases/hypersonic-3d" benchmark-darm BUILD="$(BUILD)"
variants:
	$(MAKE) -C "$(ROOT)/cases/hypersonic-3d" baseline darm greedy BUILD="$(BUILD)"
else
$(error Unknown CUDA CASE=$(CASE); choose hypersonic-3d)
endif

LLVM_BIN ?= /usr/bin
CUDA ?= /usr/local/cuda
EULER_SOURCE ?=
EULER_BUILD ?= $(ROOT)/build/benchmarks/cuda/euler-hllc-screen
EULER_REV := 484819550cc47be88b7a0429c186f7718a652123

.PHONY: screen-euler
screen-euler:
	test -n "$(EULER_SOURCE)" || { echo 'Set EULER_SOURCE to the pinned CUDA-optimization checkout' >&2; exit 2; }
	test "$$(git -C "$(EULER_SOURCE)" rev-parse HEAD)" = "$(EULER_REV)"
	"$(LLVM_BIN)/llvm-config" --version | grep -Eq '^12\.'
	mkdir -p "$(EULER_BUILD)"
	"$(LLVM_BIN)/clang" -x cuda --cuda-device-only --cuda-path="$(CUDA)" \
	  --no-cuda-version-check -nocudalib --cuda-gpu-arch=sm_70 -std=c++17 -O3 \
	  -Xclang -fcuda-allow-variadic-functions -Xclang -target-feature -Xclang +ptx60 \
	  -Xclang -mlink-builtin-bitcode -Xclang "$(CUDA)/nvvm/libdevice/libdevice.10.bc" \
	  -I"$(EULER_SOURCE)/includes/GPU" -S -emit-llvm "$(ROOT)/benchmarks/cuda/euler-hllc.cu" \
	  -o "$(EULER_BUILD)/start.ll"
	"$(LLVM_BIN)/opt" "$(EULER_BUILD)/start.ll" -verify -disable-output
	grep -E '^define .*@_Z15ComputeX_kernel' "$(EULER_BUILD)/start.ll"
