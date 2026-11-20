# 区域融合 cleanup 的 LLVM 12 pass 消融（2026-11-20）

分支 `scoring/cleanup-passes` 起于 `anchor-release-20261120`。实验使用 EPYC 的 gfx906、冻结版 LLVM 12 优化器、LLVM 24 throughput TTI 和 ROCm 6.3.3 链接器。生产测量与融合默认保持原样。

## 1. PCM32 第 10 步的同父校验与 GPU

从原版 Auto DARM 在第 10 次进入 RegionMelder 时捕获的父 IR 重放 `_Z3pcmPi:B5:H6_8:H7_8`。分支为 `%143`，两臂入口为 `%145` 与 `%unify.bb2`，共同出口为 `%371`。用当前工具只发射这一次 `darm-R2R`，父 IR 和试融合分别走发布的 LLVM 12 O3、llc、ld.lld 后端。当前 cleanup 的分数为同父对照 1262，试融 1387。捕获的父 IR SHA-256 为 `3fa569c2f5aed52b7cdeb800c99581fb04b04a8bf56009a1c709ec35570e3502`。

沿用 PCM32 排序输入、完整 CPU 排序参考和 HIP event 计时范围，在同一进程交错三个角色。A/A 的两份副本与参考比值中位数为 1.000001、0.999968，跨度为 0.0411%、0.0258%。正式 12 轮共 36 次 GPU 启动全部通过完整输出比较，每次比较 268,435,456 个整数。

| 角色 | GPU 中位耗时 ms | 同轮相对未融合 baseline 中位数 |
| --- | ---: | ---: |
| 未融合 baseline | 875.133 | 1.00000 |
| Auto DARM 第 10 步之前的父 IR | 785.718 | 0.89786 |
| 同父只加入第 10 步 R2R | 740.656 | 0.84631 |

12 轮的 R2R／父 IR 比值全部低于 1.02，中位数 0.94261，配对 bootstrap 95% 区间 [0.94256, 0.94272]，跨度 0.063%。因此该次融合使 GPU 耗时下降 5.74%。第 7 轮未融合 baseline 为 1028.446 ms，造成两个相对 baseline 比值的跨度约 17.5%。该轮完整输出通过校验，R2R 与父 IR 的对照稳定，按固定规则保留全部轮次。

## 2. LLVM 12 pass 子集

用 legacy PM 的 `opt -O3 -debug-pass=Arguments` 列出发布后端管线。以当前 cleanup 已完成的 IR 为起点，考察历史 trace 中从第一次有关的 InstCombine 到第二次有关的 SimplifyCFG 的七个有序位置：

```text
instcombine → simplifycfg → early-cse-memssa → speculative-execution
            → jump-threading → correlated-propagation → simplifycfg
```

按保留位置数逐层缩小，穷举这七个位置的 128 个有序子集，分别使用默认和 `-bonus-inst-threshold=0`。每组用相同序列处理试融产物与同父对照，再按同一 LLVM 24 TTI 打分。两份父 IR、两种 threshold、对照与候选合计 1024 条，均通过 LLVM verifier。历史 trial-70 父 IR 的 SHA-256 为 `577b790af347f86e305dc97e298a7640f19a01b31cb0e2d45a8c6db8042335d6`。

历史 Greedy trial-70 上，能达到 1132 的最短有序集合为四个 pass。阈值取 0 或默认值均达到 1132。下表的单独 TTI 从同一份 1311 IR 出发，累计列按四个 pass 的执行顺序取样。

| 追加 pass | 单独 TTI | 累计 TTI | 累计 PHI | 累计条件分支 | 累计 select |
| --- | ---: | ---: | ---: | ---: | ---: |
| 已有 cleanup | 1311 | 1311 | 55 | 29 | 126 |
| InstCombine | 1302 | 1302 | 55 | 29 | 117 |
| SpeculativeExecution | 1311 | 1302 | 55 | 29 | 117 |
| CorrelatedValuePropagation | 1311 | 1275 | 28 | 29 | 117 |
| SimplifyCFG | 1311 | 1132 | 21 | 16 | 124 |

历史同父对照经过这四个 pass 后仍为 1137，因此历史 trial-70 得到 **+5**。去掉 SpeculativeExecution 后，在已测子集中的最低候选分数为 **1230**。四个 pass 的结论限于上述有序窗口。更长的完整 O3 管线用于另外的交叉验证。

SpeculativeExecution 虽然当前步不改变指令总数或 TTI，但会把受保护的整数加法、GEP 和 select 移到 `predication.split` 前，使这些操作也在原来绕过分支的 lane 上执行。后续 SimplifyCFG 将一部分 PHI 和控制流折成 select，最后一阶段 select 从 117 增至 124。把额外指令阈值降到 0 仍保留这些变化。这与 NQU DP2 中被观察到的执行域扩大属于同一种风险，需要测量验证。

## 3. 真实父 IR 的离线门槛

| 真实父 IR 上的打分配置 | 同父对照 | R2R | 收益 |
| --- | ---: | ---: | ---: |
| current cleanup | 1262 | 1387 | −125 |
| current 加历史最小四 pass | 1258 | 1382 | −124 |
| current 后追加完整 LLVM 12 O3 | 1272 | 1396 | −124 |

真实父 IR 的 256 组“子集 × 阈值”中正收益为 **0**，最佳收益仍为 −124。作为交叉验证，比较完整 O3 trace 中改变 IR 的各个阶段。候选最低为 1382，同父对照最高为 1364，各阶段的分数区间均不重叠；这一结论不依赖用 pass 调用下标匹配两侧可能不同的循环 pass 次数。

本阶段止于离线准入：历史 trial-70 现象已复现，真实父 IR 虽经完整输出验证且 GPU 明显加速，新增 cleanup 仍不能让其 TTI 转正。未引入 `--cleanup-profile`，未进行 44 次负收益候选、274 次 B2B 重放、完整 Greedy 或 extended 的发布 GPU 回测。

## 复现材料

EPYC 工作区 `build/cleanup-passes/20261120-v1/` 保存逐轮 `aa.csv`、`paired.csv`、同父 IR、`subsets.jsonl`、`pass-search.py`、`prefix-scores.json`、`prefix.py` 和完整 O3 pass 列表。历史父 IR 和审计背景见 [原始 PCM32 消融](pcm32-r2r-20261114.md)及[区域融合审计](region-fusion-audit-20261120.md)。
