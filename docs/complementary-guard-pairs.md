# 相邻互补保护区：生成紧凑 if–else（2026-11-09）

修改位置：`tools/darm_pair_engine/RegionMelder.cpp` 的 `runUnpredicationPass()`。

这次在生成阶段合并相邻、方向相反、处于同一基本块且没有跨臂数据依赖的两个 unmatched instruction range。共同入口按原来的分歧条件选择一个臂；两个臂各自只执行本路径的指令，再进入共同出口。没有全函数 CFG 清理，也没有新增推测执行。

对生成的结果承接 PHI，如果后续同条件 select 正在选择两侧结果，则直接改成一个带两侧实际值的 PHI。只处理此次生成的承接值的使用者。其余跨块使用保留独立承接 PHI；非相邻、有共享指令夹在中间、方向相同或存在跨臂依赖的范围不进入新处理。

## X 轴候选的实际变化

候选为 `B5:R6:R7`。原始两个 Region 各有两个块，先共享乘加，再分别执行 ceil 或 floor。修复后的第一对调用结构如下（实际名字和指令）：

```llvm
predication.tail:
  %319 = phi float [ undef, %merged.bb ], [ %318, %predication.split ]
  %320 = fmul float %cond, %35
  %321 = fadd float %source.sroa.0.0.copyload, %320
  br i1 %cmp184, label %predication.first, label %predication.second

predication.first:
  %322 = tail call float @llvm.ceil.f32(float %321) #3
  br label %predication.join

predication.second:
  %323 = tail call float @llvm.floor.f32(float %321) #3
  br label %predication.join

predication.join:
  %guard.result = phi float [ %322, %predication.first ], [ %323, %predication.second ]
  %merged.select = select i1 %cmp184, float 1.000000e+00, float %319
  %324 = select i1 %cmp186, float %merged.select, float %guard.result
  %325 = fcmp oeq float %37, %31
  br i1 %325, label %merged.bb8, label %merged.bb7
```

第二对 floor/ceil 也成为一个互斥 diamond，但两侧结果在后续索引上下界的 PHI 链中分别使用，所以仍保留两个包含 undef 的承接 PHI。这不表示会执行两个调用：入口分支仍然只选择一个臂。

当前仍保留右侧独有 `conv115 - 1` 的保护区，以及 Region 出口的分支和 PHI；本次没有继续改写这些结构。

| 指令 | 融合前 | 上版融合后 | 本版融合后 | LLVM24 TTI 单价 |
|---|---:|---:|---:|---:|
| 条件 br | 28 | 32 | 30 | 7 |
| 无条件 br | 16 | 24 | 24 | 4 |
| fadd float | 44 | 42 | 42 | 1 |
| fmul float | 53 | 51 | 51 | 1 |
| fcmp | 39 | 38 | 38 | 1 |
| phi float | 25 | 31 | 30 | 1 |
| select float | 37 | 38 | 37 | 1 |
| 函数总成本 | 1182 | 1244 | 1228 | — |

本版静态收益为 `1182 - 1228 = -46`，比上版 -62 改善 16：少两条条件 br（14）、一条 PHI（1）、一条 select（1）。三组轴向 R2R 的变化相同。仍然负分，故自动贪心未提交它们。

## 验证

- LLVM12/LLVM24 工具完整构建通过。
- 新 guard_pairs 测试检查共同入口、共同出口、调用不被推测执行、select 改 PHI 和父状态不变。
- 生成的两种 ceil/floor 顺序编译为本机代码，在两种条件、11 个输入上进行 44 次结果比较通过，含正负数、带符号零、无穷和 NaN。
- 既有 intrinsic_matching、hybrid、scoped_local 回归通过。
- TIGRE 完整自动搜索重新执行：19 trials、2 commits，仍为 X+(Y,Z)，因无正收益候选停止。
- 最终自动搜索 IR 与二进制均与上一版字节一致；上一版 3.088162 ms 属于同一二进制的已测结果。本次没有重新计时，不宣称新的性能提升。
- 为实际覆盖新增 R2R 路径，在自动融合结果上强制应用 X 轴候选（trial-18），使用共同后端编译并进行完整 GPU 输出验证，通过。尚未测该强制候选的 GPU 性能。
- 原始 artifacts 仓库未修改。

实验目录：`/home/chh/kernel-benchmark-suite/experiments/tigre-guard-pairs-20261109-v1/`。
自动搜索源码与编译流程见 `prepare.py`；强制候选二进制在 `forced-axis-pair/`，验证回执在 `forced-x-validation/accepted.json`。

新增测试通过 CPU 准入入口运行：

```sh
python3 /home/chh/kernel-benchmark-suite/experiments/saspoint5-cuda-v1/run_cpu.py UNIQUE_LABEL bash /home/chh/kernel-benchmark-suite/tests/postopt/build_guard_pairs.sh
```
