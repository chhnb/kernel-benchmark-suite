# Kernel Benchmark Suite / Region Fusion

本项目的主线是：**在可复现的完整 GPU kernel baseline 上，用 LLVM12 枚举与试融合区域，以 LLVM24 TTI 评价候选，再用 C++ GPU runner 验证正确性和实际性能。** 搜索主体是 C++；JSON用于记录，不是算法接口。

当前重点为8个程序、9个kernel条目：vLLM Quant、Map-Airy、Hypersonic、TIGRE Siddon、SRAD两个阶段、HiPIMS–HLLC、Cholla–HLLD、Reentry。目录中其他case与实验保留历史，不代表当前重点。

## Auto Greedy v1

本分支 `release/greedy-v1` 只维护当前可复现路径，整理前 checkpoint 为 `48fb41e`。

- B2B：默认 DP1，唯一策略参数是 `--b2b-strategy dp1|darm`。DP1 不回退到 DARM。
- B2R / R2B / R2R：DARM。R2R 使用 DARM 对齐的区域对，不做区域笛卡尔积搜索。
- 清理：DARM SimplifyCFG（PHI folding threshold 7）→ EarlyCSE → DCE → InstCombine。
- 条件规范化预算固定为 4；未匹配的普通指令由分支保护。删除显式 SpecL/SpecR、Gap Search、DP2/DP3、旧评分/清理策略。
- 保留 LLVM 的合法性检查与安全化简，以及 DARM 原生 B2R 区域复制。禁止规划器投机不等于禁止 SimplifyCFG 化简。
- LLVM12 变换，LLVM24 常驻 worker 评分，严格正收益提交，失败保留父 IR。

```sh
tools/build-v1 --search-only  # 已有 LLVM24 worker 时
build/decision-fuse/decision-greedy INPUT.ll FUNCTION NEW_OUTPUT
python3 tools/run_v1_regression.py --out build/v1-regression-new
```

`LLVM_CONFIG` / `LLVM24_CONFIG` 可指定外部工具链；默认使用本机固定的 LLVM12 / LLVM24 安装。LLVM24 revision 仍须为 `6be16f356d3e`。`--search-only` 不重建 worker。

[冻结清单](regression/greedy-v1/manifest.json) 包含 40 个函数/尺寸配置及压缩输入、输入 SHA256、最终 IR SHA256、提交次数和 TTI。默认回归 38 个已完成配置；`--include-slow` 额外运行 checkpoint 已超时的 PCM128/256。超时不计为通过。此入口验证变换复现，GPU 性能使用已有冻结 runner 单独测量。

执行参数只有 `DECISION_GREEDY_JOBS`（默认 8）和可选的 `DECISION_CHECKPOINT_TOOL`（后端观测）。历史实验请切换 checkpoint 查阅，不作为 v1 可选策略。

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
- v1 候选单位为 B / R；完整 E-leaf 与跨判别值实验入口已删除。
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

已完成首轮实际精简：归档16份历史专题、统一公共CPU入口、裁剪未选中的重复trial IR，净释放约792MiB。见 [执行记录](docs/REPOSITORY_CLEANUP_20261110.md)。case与实验目录尚未大规模搬迁。旧运行时迁移说明见 [2026-11-05历史状态](docs/history/runtime-migration-20261105.md)。

历史策略文档见 [专题归档索引](docs/history/topics/README.md)。

For a fresh checkout on another machine, see [portable VLLM and Map-Airy benchmarks](docs/portable-benchmarks.md).

The [benchmark case inventory](docs/benchmark-case-inventory.md) lists the checked-in case manifests and their runtime requirements.
