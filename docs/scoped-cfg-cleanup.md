# 限定范围 CFG 清理试验（2026-11-09）

新增可选参数 `--cleanup scoped-cfg`（LLVM24 评分搜索入口）。原有 scoped-local 及默认配置保持不变。

## 实现范围

位置：`tools/fusion_search.cpp` 的 `cleanupScopedCFG()`。

在 DARM 内部处理完成后，记录本次试融合新建的基本块和变化指令；克隆候选，再做以下限定变换：

1. 对允许的指令做原有局部简化、CSE、非递归 DCE。
2. 只在新建块内折叠由支配边证明的条件。
3. 两个仅有无条件跳转的互斥出口通往同一汇合点时，把出口 PHI 的选择移为 head 中的 select，去掉空分流块。
4. 绕过新建的 branch-only 空块，保留 PHI 边兼容性检查。
5. 新建块只有一个无条件前驱时，将它接入该前驱，去掉直线边界；不跨条件分支移动计算。

允许更新的边界仅包括这些新块的前驱 terminator、后继 PHI。对范围外指令检查存活、位置、opcode、操作数；允许融合值被合法 RAUW 后更新使用者。每轮验证 IR，最多 32 轮。没有运行通用 SimplifyCFG、EarlyCSE、InstCombine 或 O3 搜索。

这个范围约束针对新增的外部清理阶段；DARM 本身的内部处理仍然存在，不宣称整个融合过程都只触碰新块。

无融合 control 没有本次新建块，清理范围为空，因此保持不变。这是按创建范围定义的候选清理，不是全函数归一化。当前有序 local-copysign CLI 路径仍只接受 none/scoped-local；本次 scoped-cfg 使用 structural/general CFG 路径。

## 三组轴向 R2R 的变化

三组分别计算 i、j、k 的索引边界，均有相同计数变化。以 X 轴候选 B5:R6:R7 为例：

| 指令 | 原始 IR | 紧凑保护区 + scoped-local | 新 scoped-cfg | 单条 TTI 成本 |
|---|---:|---:|---:|---:|
| 条件 br | 28 | 30 | 29 | 7 |
| 无条件 br | 16 | 24 | 21 | 4 |
| fadd float | 44 | 42 | 42 | 1 |
| fmul float | 53 | 51 | 51 | 1 |
| fcmp | 39 | 38 | 38 | 1 |
| phi float | 25 | 30 | 28 | 1 |
| select float | 37 | 37 | 39 | 1 |
| 函数总成本 | 1182 | 1228 | 1209 | — |
| 相对原始静态收益 | 0 | -46 | **-27** | — |

收益计算：`-1*7 -5*4 +2+2+1 -3 -2 = -27`。局部清理减少了冗余，但三组仍未达到正收益。

已去掉空入口连接和出口的重新分流，出口值改用 select。仍保留右侧独有 n-1 的保护区、两对 ceil/floor 的互斥选择，以及跨块上下界 PHI；没有移动 n-1 来强行消除保护区。

## 自动贪心

- 13 个候选试验，2 次提交，停止原因 no_positive_candidate。
- 第一次 X+Y：收益 65。
- 第二次 (X,Y)+Z：收益 33。
- 最终仍只有 1 处纹理采样调用。
- 上版先 Y+Z 再 X+(Y,Z)。排序因清理后的成本变化而改变。
- 不是达到 round/trial 上限后停止：配置仍为 rounds=256、trials=100000。
- 三组轴向 R2R 均为 -27，未提交。

## GPU 正确性和同批性能

AMD gfx906；TIGRE head64 phantom、50 projections 分 6 批；C++ HIP event。4 组完整轮换执行顺序，每次 3 次预热、15 次测量。各组各批取中位数，再跨组取中位数后求和。所有版本通过完整输出验证。

| 版本 | 本批耗时 ms |
|---|---:|
| 未融合基线 | 6.680881 |
| 原始 artifacts 自动 DARM | 3.898803 |
| 上版新实现 scoped-local，X+(Y,Z) | 3.089604 |
| scoped-cfg，(X,Y)+Z | 3.103844 |

本版比上版约慢 0.46%，未显示额外性能收益；仍比原始自动 DARM 耗时低约 20.39%。所有版本最终二进制编译统一使用 LLVM12 O3，不能把这些性能理解为完全不运行 O3。

另在新自动结果上强制应用 X 轴 R2R（trial-12），使用同一后端编译，并完成 GPU 正确性验证，覆盖负分候选的实际清理路径。该强制候选本次没有计时。

本次把 scoped-cfg 保留为可选对照，不替换原有配置。

## 测试与复现

- 完整构建通过。
- scoped_cfg 测试：融合范围外 add-zero、后续空 diamond 和冗余 PHI 保留；父状态和无融合 control 不变。
- scoped_cfg_runtime：ceil/floor 两种顺序生成紧凑分支；不投机执行；44 次本机结果比较通过，含正负数、带符号零、无穷和 NaN。
- 原有 hybrid 与 scoped_local 回归通过。
- 原始 artifacts 仓库保持干净，未修改。

运行参数：

```
--structural 1 --adjacent-only 0 --cleanup scoped-cfg --scorer llvm24 --rounds 256 --trials 100000
```

全部实验：`/home/chh/kernel-benchmark-suite/experiments/tigre-scoped-cfg-20261109-v2/`。
`prepare.py` 保存搜索及共同后端编译步骤；`measure.py` 为四版本轮换测量；`summarize.py` 汇总性能；`forced-x-validation/accepted.json` 为强制轴向融合验证回执。初版 v1 只用于实现对照，最终数据以 v2 为准。重新执行需新建输出目录，避免覆盖本次记录。
