# Kernel Benchmark Suite / Region Fusion

本项目的主线是：**在可复现的完整 GPU kernel baseline 上，用 LLVM12 枚举与试融合区域，以 LLVM24 TTI 评价候选，再用 C++ GPU runner 验证正确性和实际性能。** 搜索主体是 C++；JSON用于记录，不是算法接口。

当前重点为8个程序、9个kernel条目：vLLM Quant、Map-Airy、Hypersonic、TIGRE Siddon、SRAD两个阶段、HiPIMS–HLLC、Cholla–HLLD、Reentry。目录中其他case与实验保留历史，不代表当前重点。

## Auto Greedy V2

全函数试跑默认使用有序 arm 调度。每个 decision 按逻辑顺序存放分支体，在相邻分支体之间枚举融合。一次提交把两个相邻区间合并为一个区间，再根据清理后的 CFG 确认它是单块 B 还是区域 R。入口、出口或未参与融合的分支体无法唯一定位时，驱动重新发现 CFG 边界。

处理一棵指定 decision 树时，同时评估相邻 arm 的规范化候选和当前 split 的直接结构候选。结构扫尾处理其他 split。如果不同域的候选争用同一个基本块，且满足当前同后继和共同指令数量的触发条件，就对相关域联合评分。

- B2B 默认 anchor，可显式选择 DARM 或上游 DARM 对照。DP1 的历史入口保存在 pre-dp1-removal。B2R、R2B 和 R2R 使用 DARM。
- 合法 trial 依次执行 DARM SimplifyCFG（PHI folding threshold 7）、EarlyCSE、DCE、InstCombine。LLVM24 TTI 要求提交后的成本低于 trial 对照及当前父 IR。
- 默认 16 路连续队列，使用常驻评分 worker。

```sh
tools/build-v1 --search-only  # 已有 LLVM24 worker 时，构建当前驱动
build/decision-fuse/decision-greedy INPUT.ll FUNCTION NEW_OUTPUT
python3 tools/run_v1_regression.py --out build/v1-regression-new
```

构建脚本接受 `LLVM_CONFIG` 和 `LLVM24_CONFIG`，报价版本为 LLVM24 `6be16f356d3e`。V2 的 `summary.json` 记录 `pipeline_version: v2` 和 `domain_schedule: ordered`。`tools/run_v1_regression.py` 使用[有序调度冻结清单](regression/greedy-v1/manifest-ordered-20261119.json)，核对 38 个常规配置的提交次数、TTI 和最终 IR。带 `--include-slow` 时同时运行 PCM128/256。[原 v1 清单](regression/greedy-v1/manifest.json)保留历史对照。

V2 默认保留评分、拒绝原因、重放请求及清理后的候选产物。排查某项改写时可传 `--ir-snapshots full`，同时导出每次试跑的父 IR、对照 IR 和清理前产物。单独执行 `fusion-search-llvm24` 默认导出完整诊断。

直接生成 GPU 二进制，使用完整编译入口：

```sh
python3 tools/compile_kernel.py INPUT.ll FUNCTION --llvm12-bin /path/to/llvm12/bin \
  --rocm /opt/rocm --out kernel.hsaco
```

这个入口默认执行 V2 融合、LLVM 12 后端和链接，只交付 HSACO。需要保留试跑、IR 和目标文件时，用 `--work-dir` 指定新的目录。默认后端为 gfx906，使用 code object v4。PCM 等直接把融合结果交给 `llc` 的配置可用 `--no-preopt`。可移植 GPU benchmark 使用相同的编译函数，用 `--auto-greedy` 选择融合版本。

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

- LLVM12 负责 IR 变换和最终代码生成。TTI 支持 LLVM24 实时报价和离线记录回放。
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

发布门槛和冻结复现材料见 [RELEASE](docs/RELEASE.md)。
