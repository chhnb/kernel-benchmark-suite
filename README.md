# Kernel Benchmark Suite / Region Fusion

本项目的主线是：**在可复现的完整 GPU kernel baseline 上，用 LLVM12 枚举与试融合区域，以 LLVM24 TTI 评价候选，再用 C++ GPU runner 验证正确性和实际性能。** 搜索主体是 C++；JSON用于记录，不是算法接口。

当前重点为8个程序、9个kernel条目：vLLM Quant、Map-Airy、Hypersonic、TIGRE Siddon、SRAD两个阶段、HiPIMS–HLLC、Cholla–HLLD、Reentry。目录中其他case与实验保留历史，不代表当前重点。

## 从这里开始

| 想做什么 | 文档 |
|---|---|
| 理解目标、实现边界和主流程 | [主线与架构](docs/MAINLINE.md) |
| 构建baseline、运行搜索、验证与计时 | [Benchmark构建与运行](docs/BENCHMARK_GUIDE.md) |
| 查看未解决的问题及优先级 | [已知问题](docs/KNOWN_ISSUES.md) |
| 了解怎样精简目录与数据 | [仓库精简方案](docs/REPOSITORY_PLAN.md) |
| 跑冻结性能回归 | [回归入口](regression/README.md) |
| 查询case证据与历史性能 | [状态与对照说明](docs/project-status-and-darm-roadmap-20261110.md) |

## 当前事实

- LLVM12负责IR变换和既定最终代码生成；LLVM24 worker只查询TTI成本。
- 同一父状态枚举合法候选、克隆试融合、局部清理、评分、选择正分最优提交；不是穷举所有融合树。
- baseline、原始artifacts DARM、新策略必须使用同一个准备后的IR、同一后端流程与同批输入。
- 收益回归：vLLM随机64K/128K、Map-Airy混合输入、TIGRE。Hypersonic仍为实验性指定区域结果。
- 完整E-leaf候选默认按同SSA判别值检查边界；不同/未知判别值需显式 `--cross-decision-leaves 1`。这是保守IR规则，不是完整源码树恢复。
- Git尚无remote；本机目录并非全部受版本管理，不能声称clone后即可复现。完整限制见已知问题。

## 常用入口

```sh
cd /home/chh/kernel-benchmark-suite
./build-runners
python3 tools/suite.py list
python3 tools/suite.py build srad --profile hip-o3-binary --out results/srad-build-new
./bench srad validate --build results/srad-build-new --out results/srad-check-new
./bench srad benchmark --build results/srad-build-new --validated results/srad-check-new --warmup 3 --repeat 15 --out results/srad-time-new
```

目录必须是新目录。`suite.py list`显示历史manifest中的enabled/status，不等于当前研究重点。共享musa通过 `bench` 使用设备准入和队列，不直接绕过调度调用GPU。

这里的耗时是kernel event耗时，不含输入生成、传输、模型前向或CPU oracle。默认单次2+5适合初筛；正式回归采用3批、每批3次预热＋15次测量。

本次仅整理文档入口，未移动case/工具/实验目录，未删除任何复现材料。旧运行时迁移说明见 [2026-11-05历史状态](docs/history/runtime-migration-20261105.md)。
