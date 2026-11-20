# 区域融合审计与相对 baseline 的退化定位

2026-11-20，EPYC / gfx906。代码基准为 feature/anchor-default 的 6733db3。
N 是默认 V2+P anchor，A 是 DP1。审计使用独立的观测二进制，生产融合、cleanup 和计价沿用该提交。
原始计时、校验 CSV、HSACO、重放 IR、原版 DARM 父 IR 快照及审计辅助程序保存在 EPYC 的
/data/home/chh/simplify-v2/build/region-audit/。

## 2.1 相对不融合的逐提交 GPU 退化

从完整 Greedy 的已接受 trial 取所有已提交状态，用相同 LLVM 12 O3/gfx906 管线编译。
A/A 通过标准为同一二进制的中位比值偏离 1 不超过 1%、跨度不超过 3%。
每批 12 轮，轮内交错。每次启动均还原缓冲区并完整校验输出及 guard。全数通过。
沿用 v3 第 0 节的 10,000 次配对中位数 bootstrap 与 1.02 门槛。

| case | 方式 | A/A 中位数 | 轮间跨度 | A/A判定 |
| --- | --- | --- | --- | --- |
| TPACF | 进程内 | 1.0008 | 1.20% | 通过 |
| Landau | 进程内 | 0.9836 | 3.40% | 未通过 |
| Landau | 独立进程 | 0.9965 | 1.44% | 通过 |
| HLLD | 进程内 | 1.0070 | 0.47% | 通过 |

### TPACF

| 粗测状态 | 相对 state-0 | 95% 区间 | 跨度 | 固定判定 |
| --- | --- | --- | --- | --- |
| 4 | 1.8206 | [1.8185, 1.8228] | 1.57% | 超过 1.02 |
| 8 | 1.4471 | [1.4437, 1.4480] | 0.68% | 超过 1.02 |
| 12 | 1.2004 | [1.1906, 1.2015] | 2.35% | 超过 1.02 |

三个粗测区间均达到细测门槛，第二批覆盖所有状态。输入为 synthetic-v1，种子 2026111901。

| 状态 | trial／候选 | 类型／布局 | 复制 | 相对 state-0 | 95% 区间 | 总 TTI | 非 CFG | CFG/PHI | uniform false | uniform true |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 不融合 | — | — | 1.0000（9714.47 µs） | — | — | — | — | — | — |
| 1 | trial-28／B4:B5:B7 | B2R／darm-B2R | 是 | 0.9876 | [0.9869, 0.9888] | 10 | 0 | 10 | 3 | -5 |
| 2 | trial-495／B6:B5:B9 | B2B／b2b-anchor-1 | 否 | 1.5338 | [1.5312, 1.5365] | 2 | 2 | 0 | 10 | 11 |
| 3 | trial-930／B8:B5:B9 | B2B／b2b-anchor-1 | 否 | 1.8376 | [1.8346, 1.8456] | 13 | 2 | 11 | 9 | 12 |
| 4 | trial-1336／B8:B7:B9 | B2B／b2b-anchor-1 | 否 | 1.8196 | [1.8163, 1.8233] | 12 | 1 | 11 | 7 | 11 |
| 5 | trial-1714／B8:B7:B9 | B2B／b2b-anchor-1 | 否 | 1.4488 | [1.4465, 1.4510] | 13 | 2 | 11 | 6 | 12 |
| 6 | trial-2065／B8:B7:B9 | B2B／b2b-anchor-1 | 否 | 1.4607 | [1.4587, 1.4641] | 12 | 1 | 11 | 4 | 11 |
| 7 | trial-2390／B8:B7:B9 | B2B／b2b-anchor-1 | 否 | 1.4462 | [1.4418, 1.4499] | 13 | 2 | 11 | 3 | 12 |
| 8 | trial-2690／B8:B7:B9 | B2B／b2b-anchor-1 | 否 | 1.4458 | [1.4424, 1.4494] | 12 | 1 | 11 | 1 | 11 |
| 9 | trial-2902／B47:B48:B50 | B2R／darm-B2R | 是 | 1.4349 | [1.4312, 1.4397] | 10 | -1 | 11 | 3 | 0 |
| 10 | trial-3141／B45:B46:B47 | B2B／b2b-anchor-2 | 否 | 1.3790 | [1.3780, 1.3840] | 4 | 0 | 4 | -3 | -3 |
| 11 | trial-3357／B43:B44:B45 | B2B／b2b-anchor-1 | 否 | 1.2054 | [1.2000, 1.2066] | 3 | -1 | 4 | -4 | -8 |
| 12 | trial-3606／B8:B7:B9 | B2B／b2b-anchor-1 | 否 | 1.2002 | [1.1972, 1.2055] | 2 | 3 | -1 | 2 | 1 |

| 相邻状态 | 逐轮比值中位数 | 95% 区间 |
| --- | --- | --- |
| 0→1 | 0.9876 | [0.9869, 0.9888] |
| 1→2 | 1.5523 | [1.5504, 1.5562] |
| 2→3 | 1.1985 | [1.1950, 1.2017] |
| 3→4 | 0.9893 | [0.9868, 0.9913] |
| 4→5 | 0.7967 | [0.7954, 0.7979] |
| 5→6 | 1.0084 | [1.0075, 1.0095] |
| 6→7 | 0.9887 | [0.9866, 0.9913] |
| 7→8 | 1.0002 | [0.9975, 1.0025] |
| 8→9 | 0.9923 | [0.9905, 0.9946] |
| 9→10 | 0.9623 | [0.9606, 0.9632] |
| 10→11 | 0.8715 | [0.8699, 0.8745] |
| 11→12 | 0.9988 | [0.9944, 1.0001] |

第一次带复制的 darm-B2R 略快（0.9876）。主要损失来自第 2、3 次 anchor B2B，分别比上一状态慢 55.2% 和 19.9%。
这两次的 uniform gain 都为正。第 5 和 11 次收回主要损失。第 11 次的 uniform gain 为 −4／−8，实际快约 13%。
最终比不融合慢 20.0%，与原有 1.19971 相符。

条件确实合并了。原程序内层是对同一 dot product 的 31 项 if/else 阈值链。
第 2、3 次后部分条件变成共享分派、布尔组合及结果选择。最终清理后的 IR 仍有 24 个条件分支和 31 个 fcmp。
从第 1 到第 3 次提交，机器码条件跳转从 32 条降到 30 条，
SGPR spill 槽由 34 增到 52，整个 ACFKernel 的 v_readlane 指令从 34 增到 276。

| 状态 | 条件跳转 | v_cndmask | SGPR spill 槽 | v_readlane | v_writelane |
| --- | --- | --- | --- | --- | --- |
| 0 | 32 | 0 | 36 | 36 | 36 |
| 1 | 32 | 2 | 34 | 34 | 34 |
| 2 | 31 | 3 | 46 | 174 | 46 |
| 3 | 30 | 4 | 52 | 276 | 52 |
| 4 | 29 | 5 | 50 | 274 | 50 |
| 5 | 28 | 6 | 50 | 162 | 50 |
| 6 | 27 | 7 | 52 | 164 | 52 |
| 7 | 26 | 8 | 50 | 162 | 50 |
| 8 | 25 | 9 | 50 | 162 | 50 |
| 9 | 25 | 11 | 48 | 160 | 48 |
| 10 | 24 | 12 | 48 | 144 | 48 |
| 11 | 22 | 13 | 42 | 106 | 42 |
| 12 | 22 | 13 | 42 | 106 | 42 |

各状态均为 104 SGPR、16 VGPR、0 字节私有段。新增 spill 通过 VGPR lane 保存与读回。
第 5、11 次的读回条数分别降到 162 和 106，与性能追回同向。证据指向合并改变活跃区间、
增加内层循环里的 SGPR spill 读回。静态条数无法量出每个 wave 的动态执行次数。

### Landau（coherent）

| 粗测状态 | 相对 state-0 | 95% 区间 | 跨度 | 固定判定 |
| --- | --- | --- | --- | --- |
| 4 | 1.0068 | [0.9966, 1.0069] | 2.77% | 未超过 1.02 |
| 8 | 1.0172 | [1.0136, 1.0205] | 3.42% | 不确定 |
| 12 | 1.0034 | [0.9898, 1.0069] | 12.80% | 未超过 1.02 |
| 16 | 1.0000 | [0.9865, 1.0000] | 2.77% | 未超过 1.02 |
| 20 | 1.0274 | [1.0204, 1.0276] | 2.75% | 超过 1.02 |

粗测定位到 [16,20]，随后交错 state-0 细测 16–20。1–15 的空白状态未计时。
采用 coherent 冻结输入的 65,539 个样本，种子 2026110301。

| 状态 | trial／候选 | 类型／布局 | 复制 | 相对 state-0 | 95% 区间 | 总 TTI | 非 CFG | CFG/PHI | uniform false | uniform true |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 不融合 | — | — | 1.0000（23.36 µs） | — | — | — | — | — | — |
| 1 | trial-4／B14:B13:B15 | B2B／b2b-anchor-1 | 否 | — | — | 263 | 286 | -23 | -19 | -19 |
| 2 | trial-26／B16:B15:B17 | B2B／b2b-anchor-1 | 否 | — | — | 255 | 274 | -19 | -31 | -27 |
| 3 | trial-55／B27:B26:B28 | B2B／b2b-anchor-1 | 否 | — | — | 252 | 272 | -20 | -16 | -16 |
| 4 | trial-81／B29:B28:B30 | B2B／b2b-anchor-1 | 否 | 1.0068 | [0.9966, 1.0069] | 252 | 272 | -20 | -16 | -16 |
| 5 | trial-110／B31:B30:B32 | B2B／b2b-anchor-1 | 否 | — | — | 252 | 272 | -20 | -16 | -16 |
| 6 | trial-142／B33:B32:B34 | B2B／b2b-anchor-1 | 否 | — | — | 252 | 272 | -20 | -16 | -16 |
| 7 | trial-152／B14:R11:R12 | R2R／darm-R2R | 否 | — | — | 189 | 172 | 17 | -15 | -11 |
| 8 | trial-191／B25:R18:R19 | R2R／darm-R2R | 否 | 1.0172 | [1.0136, 1.0205] | 189 | 172 | 17 | -12 | -12 |
| 9 | trial-223／B27:R21:R22 | R2R／darm-R2R | 否 | — | — | 189 | 172 | 17 | -12 | -12 |
| 10 | trial-241／B25:R19:R21 | R2R／darm-R2R | 否 | — | — | 253 | 217 | 36 | -4 | -4 |
| 11 | trial-245／B12:B11:B13 | B2B／b2b-anchor-1 | 否 | — | — | 154 | 162 | -8 | -1 | -7 |
| 12 | trial-255／B6:B5:B7 | B2B／b2b-anchor-1 | 否 | 1.0034 | [0.9898, 1.0069] | 68 | 57 | 11 | — | — |
| 13 | trial-272／B18:B17:B19 | B2B／b2b-anchor-1 | 否 | — | — | 66 | 55 | 11 | — | — |
| 14 | trial-276／B6:B5:B7 | B2B／b2b-anchor-1 | 否 | — | — | 16 | 57 | -41 | — | — |
| 15 | trial-288／B18:B15:B19 | B2B／b2b-anchor-1 | 否 | — | — | 18 | 24 | -6 | — | — |
| 16 | trial-307／B41:B42:B43 | B2B／b2b-anchor-1 | 否 | 1.0000 | [0.9932, 1.0000] | 105 | 94 | 11 | -7 | -7 |
| 17 | trial-322／B18:R17:R18 | R2R／darm-R2R | 否 | 1.0205 | [1.0137, 1.0275] | 130 | 171 | -41 | -63 | -59 |
| 18 | trial-335／B20:B22:B21 | B2B／b2b-anchor-2 | 否 | 1.0205 | [1.0171, 1.0310] | 1 | 1 | 0 | -1 | -2 |
| 19 | trial-349／B32:B33:B34 | B2B／b2b-anchor-1 | 否 | 1.0274 | [1.0171, 1.0310] | 110 | 99 | 11 | -16 | -32 |
| 20 | trial-363／B5:B19:B18 | B2B／b2b-anchor-2 | 否 | 1.0205 | [1.0205, 1.0241] | 1 | 1 | 0 | -1 | -2 |

| 相邻状态 | 逐轮比值中位数 | 95% 区间 |
| --- | --- | --- |
| 16→17 | 1.0205 | [1.0137, 1.0241] |
| 17→18 | 1.0067 | [0.9933, 1.0068] |
| 18→19 | 1.0000 | [0.9967, 1.0067] |
| 19→20 | 1.0000 | [0.9933, 1.0034] |

第 17 次 darm-R2R 是细测中第一个明确上升的相邻台阶（1.0205，95% 区间 [1.0137, 1.0241]，uniform −63／−59）。
第 18–20 次无同等大小的逐步上升。最终相对 state-0 在两批分别为 1.0274 与 1.0205，均判为退化。粗测状态 8 的区间跨过 1.02，单独保留为不确定。
粗测的第 12 次跨度为 12.80%，该状态的 95% 上限仍低于 1.02。第 17 次之前仅粗采样。

### HLLD

采用 65,536 个冻结输入。旧的 v2 独立进程批次 N/baseline 为 1.093，本次进程内为 1.152。
以下使用本批配对结果定位。

| 状态 | trial／候选 | 类型／布局 | 复制 | 相对 state-0 | 95% 区间 | 总 TTI | 非 CFG | CFG/PHI | uniform false | uniform true |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 不融合 | — | — | 1.0000（65.76 µs） | — | — | — | — | — | — |
| 1 | trial-0／B4:B5:B7 | B2R／darm-B2R | 是 | 0.9781 | [0.9721, 0.9817] | 7 | -4 | 11 | -11 | -69 |
| 2 | trial-7／B20:B23:B22 | B2B／b2b-anchor-4 | 否 | 0.9440 | [0.9417, 0.9464] | 100 | 89 | 11 | — | — |
| 3 | trial-21／B9:B16:B12 | R2B／darm-R2B | 是 | 1.1168 | [1.1141, 1.1206] | 41 | 40 | 1 | -133 | -29 |
| 4 | trial-28／B13:B20:B15 | R2B／darm-R2B | 是 | 1.1559 | [1.1529, 1.1582] | 7 | 3 | 4 | -155 | -78 |
| 5 | trial-33／B13:B15:B16 | B2B／b2b-anchor-1 | 否 | 1.1521 | [1.1505, 1.1535] | 3 | -1 | 4 | — | — |

| 相邻状态 | 逐轮比值中位数 | 95% 区间 |
| --- | --- | --- |
| 0→1 | 0.9781 | [0.9721, 0.9817] |
| 1→2 | 0.9652 | [0.9627, 0.9688] |
| 2→3 | 1.1830 | [1.1817, 1.1856] |
| 3→4 | 1.0349 | [1.0327, 1.0359] |
| 4→5 | 0.9979 | [0.9958, 0.9989] |

第 1、2 次合计快约 5.6%。第 3 次带复制的 darm-R2B 相对上一状态慢 18.3%，
第 4 次 darm-R2B 再慢约 3.5%。两步 uniform gain 都显著为负。最终慢约 15.2%。

## 2.2 区域候选、拒绝与提交

按完整 Greedy 的 round attempts 计数，包括同一候选在不同父 IR 上的尝试。
有效表示 verifier 通过且有 TTI 报价。正收益指同父 cleanup 后的 TTI 降低。
过早拒绝而尚未确定类型的条目单列。只进入结构目录且被预筛选的条目另列。

| case | 类型 | 候选尝试 | 有效试融 | TTI 正收益 | 提交 | 前 5 项未提交原因 |
| --- | --- | --- | --- | --- | --- | --- |
| vllm | B2R | 0 | 0 | 0 | 0 | — |
| vllm | R2B | 0 | 0 | 0 | 0 | — |
| vllm | R2R | 0 | 0 | 0 | 0 | — |
| vllm | 类型未判定 | 11 | 0 | 0 | 0 | scope_has_backedge_or_external_edge 7、pair_not_exclusive_on_opposite_sides 4 |
| MapAiry | B2R | 0 | 0 | 0 | 0 | — |
| MapAiry | R2B | 18 | 18 | 12 | 6 | positive_but_outscored 6、tti_regression 6 |
| MapAiry | R2R | 24 | 24 | 14 | 6 | tti_regression 10、positive_but_outscored 8 |
| MapAiry | 类型未判定 | 14 | 0 | 0 | 0 | scope_contains_different_loop 14 |
| tigre | B2R | 0 | 0 | 0 | 0 | — |
| tigre | R2B | 0 | 0 | 0 | 0 | — |
| tigre | R2R | 6 | 6 | 6 | 3 | positive_but_outscored 3 |
| tigre | 类型未判定 | 4 | 0 | 0 | 0 | %if.then485:   %270 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %265, float %266, float %267, <8 x i32> %268, <4 x i32> %269, i1 false, i32 0, i32 0) 2、%decision.dispatch:   %275 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %270, float %271, float %272, <8 x i32> %273, <4 x i32> %274, i1 false, i32 0, i32 0) 1、scope_contains_different_loop 1 |
| HLLD | B2R | 1 | 1 | 1 | 1 | — |
| HLLD | R2B | 16 | 16 | 7 | 2 | tti_regression 9、positive_but_outscored 5 |
| HLLD | R2R | 0 | 0 | 0 | 0 | — |
| HLLD | 类型未判定 | 2 | 0 | 0 | 0 | %merged.bb78:   store double %386, double addrspace(1)* %410, align 8, !tbaa !8 2 |
| NQU64 | B2R | 3 | 3 | 2 | 1 | tti_regression 1、positive_but_outscored 1 |
| NQU64 | R2B | 3 | 3 | 0 | 0 | tti_regression 3 |
| NQU64 | R2R | 0 | 0 | 0 | 0 | — |
| MS32 | B2R | 0 | 0 | 0 | 0 | — |
| MS32 | R2B | 0 | 0 | 0 | 0 | — |
| MS32 | R2R | 0 | 0 | 0 | 0 | — |
| PCM32 | B2R | 0 | 0 | 0 | 0 | — |
| PCM32 | R2B | 0 | 0 | 0 | 0 | — |
| PCM32 | R2R | 1 | 1 | 0 | 0 | tti_regression 1 |
| SRAD16 | B2R | 7 | 7 | 0 | 0 | tti_regression 7 |
| SRAD16 | R2B | 0 | 0 | 0 | 0 | — |
| SRAD16 | R2R | 0 | 0 | 0 | 0 | — |
| SRAD32 | B2R | 7 | 7 | 0 | 0 | tti_regression 7 |
| SRAD32 | R2B | 0 | 0 | 0 | 0 | — |
| SRAD32 | R2R | 0 | 0 | 0 | 0 | — |
| TPACF | B2R | 3481 | 3464 | 79 | 2 | tti_regression 3377、positive_but_outscored 77、raw_verifier_failed 17、tti_tie 8 |
| TPACF | R2B | 0 | 0 | 0 | 0 | — |
| TPACF | R2R | 0 | 0 | 0 | 0 | — |
| Landau | B2R | 0 | 0 | 0 | 0 | — |
| Landau | R2B | 28 | 0 | 0 | 0 | raw_verifier_failed 28 |
| Landau | R2R | 20 | 20 | 20 | 5 | positive_but_outscored 15 |

positive_but_outscored 表示其他候选胜出。预筛选目录项以父哈希及候选名去重。

| case | 去重的预筛选目录项 | 原因 |
| --- | --- | --- |
| vllm | 109975 | b2r_replicates_same_decision_chain_requires_opt_in 109975 |
| MapAiry | 2326 | b2r_replicates_same_decision_chain_requires_opt_in 2326 |
| HLLD | 2 | b2r_replicates_same_decision_chain_requires_opt_in 2 |
| SRAD16 | 17 | b2r_replicates_same_decision_chain_requires_opt_in 17 |
| SRAD32 | 17 | b2r_replicates_same_decision_chain_requires_opt_in 17 |
| Landau | 6200 | b2r_replicates_same_decision_chain_requires_opt_in 6200 |

Cholla HLLD 已计入 HLLD。HiPIMS-HLLC 用 CUDA 11 成功生成 LLVM 12 IR，但初始 TTI 因
未报价的 opaque 调用 __internal_accurate_pow 退出。Reentry 的 LLVM 12 设备编译卡在 HIP 头，
而归档 ROCm 6.3.3 产物是 LLVM 12 无法接受的 opaque-pointer IR。这两个 case 无候选数。

下表 select 和 PHI 是同父 cleanup 后按类型的净变化，正值表示净新增。

| case | # | 全局轮 | 候选 | 类型 | 布局 | 复制 | 总 TTI | 非 CFG | CFG/PHI | uniform false | uniform true | select/PHI 净变化 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MapAiry | 5 | 5 | B98:R65:R66 | R2R | darm-R2R | 否 | 189 | 172 | 17 | -12 | -12 | phi:double -2、select:i32 +2 |
| MapAiry | 6 | 6 | B100:R68:R69 | R2R | darm-R2R | 否 | 189 | 172 | 17 | -12 | -12 | phi:double -2、select:i32 +2 |
| MapAiry | 7 | 7 | B98:R66:R68 | R2R | darm-R2R | 否 | 253 | 217 | 36 | -4 | -4 | phi:double -27、phi:i1 +1、phi:i32 +1、select:double -6 |
| MapAiry | 12 | 13 | B9:B11:B12 | R2B | darm-R2B | 是 | 5 | -5 | 10 | -21 | 0 | phi:double +1、select:double +3 |
| MapAiry | 14 | 16 | B16:B18:B19 | R2B | darm-R2B | 是 | 5 | -5 | 10 | -21 | 0 | phi:double +1、select:double +3 |
| MapAiry | 16 | 19 | B23:B25:B26 | R2B | darm-R2B | 是 | 5 | -5 | 10 | -21 | 0 | phi:double +1、select:double +3 |
| MapAiry | 18 | 22 | B30:B32:B33 | R2B | darm-R2B | 是 | 5 | -5 | 10 | -21 | 0 | phi:double +1、select:double +3 |
| MapAiry | 20 | 25 | B37:B39:B40 | R2B | darm-R2B | 是 | 5 | -5 | 10 | -21 | 0 | phi:double +1、select:double +3 |
| MapAiry | 22 | 28 | B43:B45:B46 | R2B | darm-R2B | 是 | 6 | -4 | 10 | -20 | 1 | phi:double +1、select:double +3 |
| MapAiry | 24 | 39 | B51:H52_54:H53_54 | R2R | darm-R2R | 否 | 5 | 25 | -20 | -34 | -30 | phi:double +4、select:double +6、select:i1 +1 |
| MapAiry | 26 | 59 | B59:R57:R58 | R2R | darm-R2R | 否 | 130 | 171 | -41 | -63 | -59 | phi:double +54、phi:i1 -1、phi:i32 -1、select:i32 +3 |
| MapAiry | 29 | 89 | B88:H44_46:H45_46 | R2R | darm-R2R | 否 | 5 | 25 | -20 | -34 | -30 | phi:double +4、select:double +6、select:i1 +1 |
| tigre | 1 | 1 | B5:R6:R7 | R2R | darm-R2R | 否 | 30 | -2 | 32 | 11 | 10 | phi:float -3、select:float +7 |
| tigre | 2 | 2 | B5:R6:R7 | R2R | darm-R2R | 否 | 30 | -2 | 32 | 11 | 10 | phi:float -3、select:float +7 |
| tigre | 3 | 3 | B5:R6:R7 | R2R | darm-R2R | 否 | 30 | -2 | 32 | 11 | 10 | phi:float -3、select:float +7 |
| HLLD | 1 | 2 | B4:B5:B7 | B2R | darm-B2R | 是 | 7 | -4 | 11 | -11 | -69 | select:double +7 |
| HLLD | 3 | 4 | B9:B16:B12 | R2B | darm-R2B | 是 | 41 | 40 | 1 | -133 | -29 | phi:double +7、select:double +15 |
| HLLD | 4 | 5 | B13:B20:B15 | R2B | darm-R2B | 是 | 7 | 3 | 4 | -155 | -78 | select:double +56、select:i1 +1 |
| NQU64 | 1 | 1 | B2:B3:B6 | B2R | darm-B2R | 是 | 6 | -4 | 10 | 2 | -23 | phi:i32 +1、select:i32 +3 |
| TPACF | 1 | 1 | B4:B5:B7 | B2R | darm-B2R | 是 | 10 | 0 | 10 | 3 | -5 | phi:i32 +1、select:i32 +2 |
| TPACF | 9 | 9 | B47:B48:B50 | B2R | darm-B2R | 是 | 10 | -1 | 11 | 3 | 0 | select:i32 +3 |
| Landau | 7 | 7 | B14:R11:R12 | R2R | darm-R2R | 否 | 189 | 172 | 17 | -15 | -11 | phi:double -2、select:i32 +2 |
| Landau | 8 | 8 | B25:R18:R19 | R2R | darm-R2R | 否 | 189 | 172 | 17 | -12 | -12 | phi:double -2、select:i32 +2 |
| Landau | 9 | 9 | B27:R21:R22 | R2R | darm-R2R | 否 | 189 | 172 | 17 | -12 | -12 | phi:double -2、select:i32 +2 |
| Landau | 10 | 10 | B25:R19:R21 | R2R | darm-R2R | 否 | 253 | 217 | 36 | -4 | -4 | phi:double -27、phi:i1 +1、phi:i32 +1、select:double -6 |
| Landau | 17 | 21 | B18:R17:R18 | R2R | darm-R2R | 否 | 130 | 171 | -41 | -63 | -59 | phi:double +54、phi:i1 -1、phi:i32 -1、select:i32 +3 |

## 2.3 同父重放的块内对齐

26 次区域提交均用实际送入试融器的父 IR 重放，包括逻辑准备后的父 IR。布局和 TTI 收益与归档相同。
DARM 统计取自 fixOperends 实际添加的 select，包括 select 本身与合并分支的条件位。
异阈值比较指谓词相同且至少一个相同操作数位置上的常量不同。

anchor 反事实在 DARM 实际对齐的块上复用 V2+P 的传播、分段与空对齐，以块内估分选择候选。
没有发射区域 CFG，估算 select 不含分支条件，代表合并工作指令的操作数代价。
复制中途的 IR 若暂不满足 PHI verifier，就从已验证的父 IR 按指令签名取唯一报价，
查无唯一报价时按 anchor 的回退方式估算。

共 174 对块，24 对使用父 IR 签名报价，0 对触发过回退。实际发射有 12 对 select 条件位、57 对分支条件位、12 对三操作数均需 select 的 select，及 7 对同谓词异阈值比较。

| case／提交 | 类型 | select 条件 i1 | 分支条件 i1 | 三操作数均不同 | 同谓词异阈值 | DARM→anchor 估算 select |
| --- | --- | --- | --- | --- | --- | --- |
| MapAiry／5 | R2R | 0 | 0 | 0 | 1 | 11→3 |
| MapAiry／6 | R2R | 0 | 0 | 0 | 1 | 11→3 |
| MapAiry／7 | R2R | 0 | 1 | 0 | 0 | 50→50 |
| MapAiry／12 | R2B | 0 | 1 | 0 | 0 | 0→0 |
| MapAiry／14 | R2B | 0 | 1 | 0 | 0 | 0→0 |
| MapAiry／16 | R2B | 0 | 1 | 0 | 0 | 0→0 |
| MapAiry／18 | R2B | 0 | 1 | 0 | 0 | 0→0 |
| MapAiry／20 | R2B | 0 | 1 | 0 | 0 | 0→0 |
| MapAiry／22 | R2B | 0 | 1 | 0 | 0 | 0→0 |
| MapAiry／24 | R2R | 0 | 1 | 0 | 0 | 7→5 |
| MapAiry／26 | R2R | 0 | 0 | 0 | 1 | 15→3 |
| MapAiry／29 | R2R | 0 | 1 | 0 | 0 | 7→5 |
| tigre／1 | R2R | 0 | 0 | 0 | 0 | 2→0 |
| tigre／2 | R2R | 0 | 0 | 0 | 0 | 2→0 |
| tigre／3 | R2R | 0 | 0 | 0 | 0 | 2→0 |
| HLLD／1 | B2R | 0 | 9 | 0 | 0 | 7→6 |
| HLLD／3 | R2B | 0 | 4 | 0 | 0 | 32→32 |
| HLLD／4 | R2B | 12 | 1 | 12 | 0 | 80→0 |
| NQU64／1 | B2R | 0 | 2 | 0 | 0 | 0→0 |
| TPACF／1 | B2R | 0 | 30 | 0 | 0 | 1→0 |
| TPACF／9 | B2R | 0 | 1 | 0 | 0 | 1→1 |
| Landau／7 | R2R | 0 | 0 | 0 | 1 | 11→3 |
| Landau／8 | R2R | 0 | 0 | 0 | 1 | 11→3 |
| Landau／9 | R2R | 0 | 0 | 0 | 1 | 11→3 |
| Landau／10 | R2R | 0 | 1 | 0 | 0 | 50→50 |
| Landau／17 | R2R | 0 | 0 | 0 | 1 | 15→3 |

以下为估算 select 差距最大的 10 条提交。换配同时计入旧配对移除与新配对加入。

| case／提交 | trial | DARM→anchor | DARM 配对被截断或替换 | anchor 新增配对 |
| --- | --- | --- | --- | --- |
| HLLD／4 | trial-28 | 80→0 | fmul×12、select×12、getelementptr×7、store×7、fsub×6、fadd×5 | — |
| MapAiry／26 | trial-281 | 15→3 | fsub×30、call×28、fadd×18、fmul×10、insertelement×8、fneg×6、extractelement×4、select×3、zext×1、fcmp×1、sub×1 | — |
| Landau／17 | trial-322 | 15→3 | fsub×30、call×28、fadd×18、fmul×10、insertelement×8、fneg×6、extractelement×4、select×3、sub×1、zext×1、fcmp×1 | — |
| MapAiry／5 | trial-70 | 11→3 | insertelement×8、extractelement×4、call×2 | — |
| MapAiry／6 | trial-96 | 11→3 | insertelement×8、extractelement×4、call×2 | — |
| Landau／7 | trial-152 | 11→3 | insertelement×8、extractelement×4、call×2 | — |
| Landau／8 | trial-191 | 11→3 | insertelement×8、extractelement×4、call×2 | — |
| Landau／9 | trial-223 | 11→3 | insertelement×8、extractelement×4、call×2 | — |
| MapAiry／24 | trial-228 | 7→5 | fmul×2、fdiv×1、fadd×1、call×1 | fdiv×1、fsub×1 |
| MapAiry／29 | trial-348 | 7→5 | fmul×2、call×1、fadd×1、fdiv×1 | fsub×1、fdiv×1 |

## 2.4 LLVM 12 O3 与现有 cleanup 对照

每个设计 case 选通过 verifier、被 TTI 拒绝且负得最少的区域候选，最多 20 个。
对每个 raw candidate 与原父 IR 分别跑 LLVM12 O3，再用同一 LLVM24 TTI 打分。

| case | 重放数 | 现有 cleanup gain | O3 gain | O3 反转为接受 | O3 打平 |
| --- | --- | --- | --- | --- | --- |
| vllm | 0 | — | — | 0 | 0 |
| MapAiry | 16 | -6～-2 | -3～0 | 0 | 10 |
| tigre | 0 | — | — | 0 | 0 |
| HLLD | 9 | -72～-25 | -105～-38 | 0 | 0 |
| NQU64 | 4 | -19～-2 | -19～-2 | 0 | 0 |
| MS32 | 0 | — | — | 0 | 0 |
| PCM32 | 1 | -202～-202 | -130～-130 | 0 | 0 |
| SRAD16 | 7 | -25～-11 | -22～-11 | 0 | 0 |
| SRAD32 | 7 | -25～-11 | -22～-11 | 0 | 0 |

44 次中没有 reject→accept。当前 PCM32 的 R2R trial-33 从 1138→1340 改善为 1138→1268，仍被拒。

历史 PCM32 用 3510dfb 重建，重现 trial-70 同父 cleanup 的 1137→1311，以及 LLVM12 O3 下的 1137→1132。
从 1311 开始，InstCombine 到 1302，SimplifyCFG 到 1236，带 MemorySSA 的 EarlyCSE 到 1230，
CorrelatedValuePropagation 到 1209，再由 SimplifyCFG 降至 1132。

最终 1096→1034 条指令，PHI 55→21，条件分支 29→16，无条件分支 17→4，select 126→124。
load 115、store 89、icmp 38 均相同。额外的第一轮 SimplifyCFG 将部分控制流改成 select，
值传播消去 21 个 PHI，后一轮 SimplifyCFG 再消去 7 个条件分支和 7 个无条件跳转。

## 2.5 独立 Auto DARM 对照

使用归档原版可执行文件和 0.2 相似度阈值，在一次完整运行中于 RegionMelder::merge 入口只读导出真实父 IR。
在每个父 IR 上重新枚举当前候选，按相同 split 与块或区域入口映射做显式试融。
候选通过局部 TTI 门槛并不保证它在 Greedy 的其他候选中胜出。后续父 IR 来自原版自己的提交轨迹。

### PCM32

历史同批 GPU 计时为 baseline 893.659 ms、Auto DARM 650.322 ms、Greedy 707.902 ms。
原版 18 步里，当前同父目录有 17 步。第 1 步循环入口对未入目录，第 10 步 R2R 被 TTI 拒绝，其余为正收益。

| 原版步 | split | 块／区域入口对 | 当前候选 | 当前布局 | TTI gain | 当前结果 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | %1 | %14 ↔ %12 | 未枚举 | — | — | — |
| 2 | %270 | %283 ↔ %285 | B7:B8:B9 | b2b-anchor-3 | 15 | 可接受 |
| 3 | %unify.bb2 | %739 ↔ %737 | B7:B23:B22 | b2b-anchor-3 | 15 | 可接受 |
| 4 | %unify.bb2 | %751 ↔ %749 | B7:B23:B22 | b2b-anchor-3 | 15 | 可接受 |
| 5 | %unify.bb2 | %763 ↔ %761 | B7:B23:B22 | b2b-anchor-3 | 15 | 可接受 |
| 6 | %unify.bb2 | %775 ↔ %773 | B7:B23:B22 | b2b-anchor-3 | 15 | 可接受 |
| 7 | %unify.bb2 | %787 ↔ %785 | B7:B23:B22 | b2b-anchor-3 | 15 | 可接受 |
| 8 | %unify.bb2 | %799 ↔ %797 | B7:B23:B22 | b2b-anchor-3 | 15 | 可接受 |
| 9 | %unify.bb2 | %811 ↔ %809 | B7:B23:B22 | b2b-anchor-3 | 15 | 可接受 |
| 10 | %143 | %145 ↔ %unify.bb2 | B5:H6_8:H7_8 | darm-R2R | -125 | TTI 退化 |
| 11 | %354 | %367 ↔ %369 | B10:B11:B12 | b2b-anchor-3 | 15 | 可接受 |
| 12 | %unify.bb170 | %583 ↔ %581 | B10:B17:B16 | b2b-anchor-3 | 15 | 可接受 |
| 13 | %unify.bb170 | %595 ↔ %593 | B10:B17:B16 | b2b-anchor-3 | 15 | 可接受 |
| 14 | %unify.bb170 | %607 ↔ %605 | B10:B17:B16 | b2b-anchor-3 | 15 | 可接受 |
| 15 | %unify.bb170 | %619 ↔ %617 | B10:B17:B16 | b2b-anchor-3 | 15 | 可接受 |
| 16 | %unify.bb170 | %631 ↔ %629 | B10:B17:B16 | b2b-anchor-3 | 15 | 可接受 |
| 17 | %unify.bb170 | %643 ↔ %641 | B10:B17:B16 | b2b-anchor-3 | 15 | 可接受 |
| 18 | %unify.bb170 | %655 ↔ %653 | B10:B17:B16 | b2b-anchor-3 | 15 | 可接受 |

### HLLD

第 1 对和当前完整 Greedy 的首笔相同。第 2 对同父试融损失 114 TTI。第 3 对达到局部门槛，当前由 anchor 发射。

| 原版步 | split | 块／区域入口对 | 当前候选 | 当前布局 | TTI gain | 当前结果 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | %22 | %261 ↔ %296 | B4:B5:B7 | darm-B2R | 7 | 可接受 |
| 2 | %unify.bb | %merged.bb80 ↔ %merged.bb81 | B4:B14:B15 | darm-B2R | -114 | TTI 退化 |
| 3 | %merged.bb167 | %merged.bb175 ↔ %merged.bb166 | B13:B37:B12 | b2b-anchor-4 | 88 | 可接受 |

### MapAiry

同父目录覆盖 28 步。第 3 步因循环边界不合法被拒，第 4、7、11、13、16、18、25 步 TTI 为负。
第 5、9、10 步打平，其余达到局部门槛。

| 原版步 | split | 块／区域入口对 | 当前候选 | 当前布局 | TTI gain | 当前结果 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | %if.then.i.i.i | %if.then3.i.i.i.i ↔ %if.then.i.i.i.i | B4:B5:B7 | b2b-anchor-2 | 55 | 可接受 |
| 2 | %cond.false7.i.i.i | %if.then3.i27.i.i.i ↔ %if.then.i21.i.i.i | B5:B6:B8 | b2b-anchor-1 | 65 | 可接受 |
| 3 | %if.end14.i.i | %merged.bb135 ↔ %merged.bb229 | B3:R59:R71 | — | — | scope_contains_different_loop |
| 4 | %cond.false7.i.i.i | %merged.bb224 ↔ %merged.bb234 | B5:B106:B98 | b2b-anchor-2 | -13 | TTI 退化 |
| 5 | %merged.bb84 | %merged.bb123 ↔ %merged.bb118 | B11:B52:B47 | b2b-anchor-1 | 0 | TTI 打平 |
| 6 | %merged.bb85 | %merged.bb97 ↔ %merged.bb113 | B12:B26:B42 | b2b-anchor-1 | 9 | 可接受 |
| 7 | %merged.bb87 | %merged.bb122 ↔ %merged.bb109 | B16:H48_54:H37_54 | darm-R2R | -6 | TTI 退化 |
| 8 | %merged.bb88 | %merged.bb162 ↔ %merged.bb156 | B17:B83:B77 | b2b-anchor-1 | 9 | 可接受 |
| 9 | %merged.bb92 | %merged.bb127 ↔ %merged.bb121 | B21:B50:B46 | b2b-anchor-1 | 0 | TTI 打平 |
| 10 | %merged.bb93 | %merged.bb134 ↔ %merged.bb120 | B22:B55:B45 | b2b-anchor-1 | 0 | TTI 打平 |
| 11 | %merged.bb95 | %merged.bb146 ↔ %merged.bb141 | B24:H63_68:H58_68 | darm-R2R | -6 | TTI 退化 |
| 12 | %merged.bb104 | %merged.bb90 ↔ %merged.bb148 | B32:B19:B63 | b2b-anchor-1 | 9 | 可接受 |
| 13 | %merged.bb106 | %merged.bb89 ↔ %merged.bb110 | B33:H18_60:H36_60 | darm-R2R | -6 | TTI 退化 |
| 14 | %merged.bb112 | %merged.bb126 ↔ %merged.bb153 | B36:B44:B64 | b2b-anchor-1 | 9 | 可接受 |
| 15 | %merged.bb114 | %merged.bb138 ↔ %merged.bb99 | B37:H51_11:H25_11 | darm-R2R | 5 | 可接受 |
| 16 | %merged.bb133 | %merged.bb163 ↔ %merged.bb155 | B47:H67_37:H61_37 | darm-R2R | -6 | TTI 退化 |
| 17 | %merged.bb150 | %merged.bb144 ↔ %merged.bb154 | B57:H53_36:H60_36 | darm-R2R | 5 | 可接受 |
| 18 | %merged.bb152 | %merged.bb100 ↔ %merged.bb108 | B57:H24_43:H32_43 | darm-R2R | -6 | TTI 退化 |
| 19 | %merged.bb307 | %merged.bb315 ↔ %merged.bb317 | B62:B70:B71 | darm-B2R | 229 | 可接受 |
| 20 | %merged.bb307 | %merged.bb705 ↔ %merged.bb712 | B62:B127:B133 | darm-B2R | 259 | 可接受 |
| 21 | %merged.bb307 | %merged.bb913 ↔ %merged.bb916 | B62:B134:B137 | darm-B2R | 259 | 可接受 |
| 22 | %merged.bb307 | %merged.bb1103 ↔ %merged.bb1100 | B62:B132:B130 | darm-B2R | 259 | 可接受 |
| 23 | %merged.bb307 | %merged.bb1297 ↔ %merged.bb1292 | B62:B137:B133 | darm-B2R | 72 | 可接受 |
| 24 | %merged.bb307 | %merged.bb1483 ↔ %merged.bb1485 | B62:B160:B161 | b2b-anchor-1 | 321 | 可接受 |
| 25 | %merged.bb307 | %merged.bb1784 ↔ %merged.bb1798 | B62:B138:B151 | darm-B2R | -181 | TTI 退化 |
| 26 | %merged.branch.split | %merged.bb117 ↔ %merged.bb105 | B70:B35:B28 | b2b-anchor-1 | 8 | 可接受 |
| 27 | %merged.branch.split449 | %merged.bb140 ↔ %merged.bb160 | B77:B45:B57 | b2b-anchor-1 | 8 | 可接受 |
| 28 | %merged.branch.split456 | %merged.bb101 ↔ %merged.bb91 | B75:B24:B17 | b2b-anchor-1 | 8 | 可接受 |

### vllm

原版相似度 0.5 的首选进入左区域复制后，45 秒内没有提交或产物。
当前目录有同一对，因同 decision-chain 复制被预筛掉。没有后续原版提交可比较。

| 原版步 | split | 块／区域入口对 | 当前候选 | 当前布局 | TTI gain | 当前结果 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | %for.body34 | %_Z4enc8f.exit.thread ↔ %_Z4enc8f.exit.thread396 | B5:B7:B6 | — | — | b2r_replicates_same_decision_chain_requires_opt_in |
