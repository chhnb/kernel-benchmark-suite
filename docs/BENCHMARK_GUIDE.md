# Benchmark构建、搜索和验证

以下是musa现有入口的说明，不是宣称全平台安装指南。路径 `/home/chh/kernel-benchmark-suite`；需要既有CUDA/ROCm、LLVM12、固定LLVM24 worker、设备准入和CPU配额服务。

## 1. 一个case应该提供什么

固定源码版本/移植补丁、目标kernel和ABI、baseline编译profile、输入生成或数据来源、完整输出oracle与容差、C++ runner、准确计时范围。允许专用harness；不要求优化adapter，不为融合人为提取helper。

当前这些信息散在 `case.json`、源码/脚本和实验记录中，尚未全部标准化。`case.json`的 `profiles[NAME].argv` 是已有构建命令，`artifact`是输出文件。每次构建写 `command.json`、stdout/stderr和receipt。LLVM IR profile的构建还会调用verifier；构建成功不等于GPU正确性通过。

## 2. 构建C++ runner与baseline

```sh
cd /home/chh/kernel-benchmark-suite
./build-runners
python3 tools/suite.py list
python3 tools/suite.py build boost-mapairy --profile hip-llvm12-o3-ir --out results/mapairy-ir-new
python3 tools/suite.py build boost-mapairy --profile hip-llvm12-o3 --out results/mapairy-binary-new
```

分别生成 `start.ll` 与 `kernel.hsaco`。Map-Airy的LLVM12 profile使用显式clang设备编译参数和固定ROCm bitcode，并非简单换成系统 `clang -O3` 就等价。要查看完全展开的编译argv：

```sh
cat results/mapairy-ir-new/command.json
```

也可从 `cases/boost-mapairy/case.json` 读取指定profile。这里保留每个case实际可用的编译命令，不伪造一个适用全部CUDA/HIP kernel的通用命令。

| Case目录 | 已有常用profile | 注意 |
|---|---|---|
| boost-mapairy | hip-llvm12-o3-ir / hip-llvm12-o3 | 当前融合主线为LLVM12 |
| vllm-quant | hip-software-baseline | 历史软件移植，仍依赖保留IR；不是原始NVFP4 |
| vllm-quant | cuda-software-llvm-ir / cuda-software-llvm / cuda-software-nvcc | CUDA软件路线，不能混用HIP的性能结果 |
| tigre-siddon | hip-o3 / hip-o3-binary | 专用几何/纹理runner |
| srad、srad-stage2 | hip-o3 / hip-o3-binary | 两个独立kernel |
| hypersonic、reentry | hip-llvm12-o2-ir / hip-native-o2-binary | LLVM12 IR与native runtime profile不可直接当相同baseline；Hypersonic最新实验另有no-JT准备 |
| hipims | cuda-hllc-llvm-o3 / cuda-hllc-nvcc-o3 | HLLC范围，尚未统一paired codegen入口 |
| cholla-hlld | cuda-o3 / nvcc-o3 | 当前常规runner为CUDA |

## 3. 构建和运行当前LLVM24评分搜索

搜索构建尚未接入统一CMake；已有构建脚本是 `tools/build-llvm24-tti`。在musa通过CPU配额包装器执行：

```sh
python3 tools/run_cpu.py build-search-new bash /home/chh/kernel-benchmark-suite/tools/build-llvm24-tti
```

公共入口现在位于tools；旧Saspoint5路径保留兼容转发。不要绕开配额运行重编译。

Map-Airy示例（命令中所有输出必须不存在）：

```sh
python3 tools/run_cpu.py mapairy-search-new \
  /home/chh/kernel-benchmark-suite/build/llvm24-tti/fusion-search-llvm24 \
  --ir /home/chh/kernel-benchmark-suite/results/mapairy-ir-new/start.ll \
  --function evaluate --structural 1 --scorer llvm24 \
  --cleanup scoped-cfg --cross-decision-leaves 0 \
  --rounds 256 --trials 100000 \
  --debug-dir /home/chh/kernel-benchmark-suite/results/mapairy-search-new \
  --out /home/chh/kernel-benchmark-suite/results/mapairy-fused-new.ll
```

这展示使用新构建baseline的接口；正式重放冻结结果需核对IR hash与冻结baseline一致。`--cross-decision-leaves 0`只限制新增完整E叶子候选：不同/未知SSA判别值不默认加入；1显式放开，仍需合法性检查。Hypersonic复合条件的指定区域入口已显式开启。不要把该开关等同于禁止全部B2R。

## 4. 统一最终后端

已有paired编译工具目前**只支持AMD**：

```sh
python3 tools/postopt_compile_pair.py \
  --baseline results/mapairy-ir-new/start.ll \
  --variant results/mapairy-fused-new.ll \
  --case boost-mapairy --function evaluate --scope full-kernel \
  --out results/mapairy-pair-new
```

它对两版都运行同一个LLVM12 `opt -O3`、gfx906 `llc`、link，保存最终IR、二进制hash和资源信息；不做GPU验证。原始artifacts DARM也必须从同一个baseline IR出发，再经相同最终后端。当前尚没有覆盖全部case的一条native-DARM对照命令，勿拿legacy权重greedy代替原始DARM。

## 5. 完整输出验证与计时

```sh
./bench boost-mapairy validate --kernel results/mapairy-pair-new/variant.hsaco --out results/mapairy-check-new
./bench boost-mapairy benchmark --kernel results/mapairy-pair-new/variant.hsaco \
  --validated results/mapairy-check-new --warmup 3 --repeat 15 --out results/mapairy-time-new
```

上述是普通case最终输入集，不是仅混合输入的冻结回归。普通case默认可含多个输入，`--input`可选定输入。一个计时目录只是一批，不能把单批写成三批正式confirm。

C++负责分配、恢复输入、启动、GPU event同步和完整输出检查。Event只包围一次kernel launch，排除传输、文件I/O、oracle与初始化。通用runner支持Graph的case可显式选择，但专用runner未必支持，不能把Graph/Event样本混合。每次计时后仍验证完整输出。

## 6. 日常收益回归

```sh
python3 tools/run_generated_regression.py mapairy --candidate /absolute/current-mapairy.hsaco --out /absolute/new-mapairy-regression
python3 tools/run_generated_regression.py vllm --candidate /absolute/current-vllm.hsaco --out /absolute/new-vllm-regression
python3 tools/run_golden_regression.py tigre --candidate /absolute/current-tigre.hsaco --out /absolute/new-tigre-regression
```

vLLM：C++固定种子随机BF16，64K/128K；不使用Qwen输入包。Map-Airy：C++生成混合下尾输入；TIGRE沿用原冻结几何数据。reference与candidate先完整校验，再3批轮换、每批3+15；默认每个输入慢超过2%即失败。相同二进制记录别名，不重复测量并声称独立比较。临时输入成功后删除，Git只保留生成器、配置、hash、收据和小型统计。

## 7. 新增或重建一个case的完成条件

先选择原始完整kernel并固定来源；记录设备兼容移植；提供显式baseline profile及ABI；准备可再生输入和最终输出oracle；接C++通用runner或小型专用harness；验证baseline；再冻结共同IR，比较原始DARM与新策略。归档清单必须包含构建命令、源码/IR/二进制hash、输入生成配置、设备、输出验证和CSV。

只有完成baseline并不代表完成融合接入；只有静态正分并不代表实测收益；指定区域验证也不等于自动搜索收敛。
