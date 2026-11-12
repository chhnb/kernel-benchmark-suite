# 三组 GPU benchmark

两个入口按 GPU 后端维护。每次 benchmark 从同一份 LLVM12 起始 IR 构建
Baseline、原生自动 DARM、自动 greedy，用该 case 的同一组输入和输出校验。
Greedy 使用固定的 LLVM24 TTI worker 打分，并通过对应后端的真实编译事务检查。
原生 DARM 使用独立的 CFMelder。可传 `DARM_PLUGIN` 指定 LLVM12 插件，
也可用 `DARM_OPT` 指向内置原生 pass 的 `opt`。DARM 编译失败时，该次三组
benchmark 会报错并保留日志。

| 后端 | 入口 | 已接入 |
| --- | --- | --- |
| AMD gfx906 | `make -C benchmarks/amd benchmark` | `CASE=vllm`（64K、128K）、`CASE=mapairy`（混合输入） |
| CUDA sm_70 | `make -C benchmarks/cuda benchmark` | `CASE=hypersonic-3d`（64³、96³，TITAN V） |

## AMD

```sh
make -C benchmarks/amd benchmark CASE=vllm \
  LLVM_BIN=/path/to/llvm12/bin ROCM=/opt/rocm \
  DARM_PLUGIN=/path/to/CFMelder.so BUILD=/path/to/new-amd-run
```

AMD 入口重用套件的固定种子生成器和 CPU 参考。三版都经过同一条 LLVM12
AMDGPU codegen 路径。C++ HIP runner 每轮轮换三组顺序，按同一输入做
3 轮预热、15 轮计时，每次启动都校验完整输出。每份输入的目录里有
`samples.csv` 和 `result.json`，记录各版中位数和相对 Baseline 的配对差值。
`SHA256SUMS` 可以核对是否生成了相同的二进制。`make inputs` 可单独生成
输入和参考，`make variants` 可构建三组 GPU 产物，greedy 的编译事务需要 GPU。

## CUDA

```sh
make -C benchmarks/cuda benchmark CASE=hypersonic-3d \
  LLVM_BIN=/path/to/llvm12/bin CUDA=/usr/local/cuda \
  DARM_PLUGIN=/path/to/CFMelder.so BUILD=/path/to/new-cuda-run
```

CUDA 入口转发到 [3D Hypersonic 的原生 Makefile](../cases/hypersonic-3d/README.md)。
NVCC 构建的 C++ harness 用冻结的球体绕流状态重放同一个核，逐次验证输出，
报告三组时间和配对差值。性能回归门槛仍使用该 case 的 TITAN V 门槛。

两个入口都接受 `SUITE` 来定位已编译的 greedy、fuser 和 LLVM24 worker。
按目标机器配置 `LD_LIBRARY_PATH`、`LLVM24_LIBDIR` 和 GPU 可见设备。
更换 IR、工具链或 DARM 插件时使用新的 `BUILD` 目录。现有冻结回归清单
继续由 [regression](../regression/README.md) 维护。

## 2D Euler HLLC 编译预检

`make -C benchmarks/cuda screen-euler EULER_SOURCE=/path/to/CUDA-optimization
LLVM_BIN=/path/to/llvm12/bin` 编译固定提交的完整 `ComputeX_kernel<double>`，
入口只实例化上游模板。此目标生成起始 IR。它的 Shock Bubble 快照、三组
产物和 GPU 重放还在准备中。
