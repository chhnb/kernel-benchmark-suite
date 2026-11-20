# 代价模型的反例与离线评测（2026-11-20）

分支 `scoring/cost-model-eval` 从 `anchor-release-20261120` 建立。本次读取已验证的 IR、对象和 GPU 批次；没有新的 GPU 测量。结果、原始逐轮比值、父子路径及 SHA-256、逐块分析和各机器循环计数见[评测数据](cost-model-eval-20261120-data.json)。

## 1. 两个反例

### PCM32，第 10 步的真实父 IR

GPU 的 12 轮配对中位数为 **0.942615**，95% 区间 **[0.942565, 0.942716]**。当前评分输入为 1262→1387，LLVM 12 O3 后为 1272→1396。GPU 快 5.74%，完整 O3 后 TTI 收益仍为 −124。来源为 cleanup 分支 `617b52a`。 [同父 GPU 校验记录](https://github.com/chhnb/kernel-benchmark-suite/blob/617b52a96a44a4c6a93ce5cc52e61c1e9ede430b/regression/records/cleanup-extended-20261120.md)

在评分输入上，循环深度 0 的 TTI 为 **59→59**，深度 1 为 **331→328**，深度 2 为 **872→1000**。O3 后对应为 **55→56、331→328、886→1012**。IR 主要增量落在热循环。O3 后父版消失的最大命名块为 `%.preheader26`、`%.preheader20`（各 139 TTI）及 `%unify.bb2`（132），深度均为 2，相对进入函数的 BFI 权重均为 512。子版出现 `%.preheader33`（139，深度 2，权重 512），以及 `%predication.tail`（36）、`%predication.join78/95/112/129`（各 31），后五个权重均为 1024。循环外的 `%merged.branch.split1` 仅 18→19，权重为 1。命名块的出现和消失按各自版本报告；拆块和重命名后不强行给这些块配一对一的身份。完整逐块表包括匿名块、深度和频率。

gfx906 机器循环从实际跳转和支配回边识别。按列为**条件跳转／EXEC 相关／VALU／SALU／访存**；EXEC 列可与 SALU 和条件跳转重叠，访存单列。循环并集不重复计入嵌套。机器循环头在两版间会变址。

| 区域（父→子） | 条件跳转 | EXEC | VALU | SALU | 访存 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 机器循环并集 | 26→25 | 75→113 | 318→316 | 84→145 | 122→113 |
| 两条被合并的内层循环（`0x196c`、`0x1c04` → `0x19b8`） | 2→3 | 0→44 | 146→142 | 4→69 | 36→27 |
| 循环外 | 2→2 | 6→6 | 24→29 | 15→16 | 2→2 |

省掉的九条静态访存指令集中在被合并的内层循环。一个后续内层循环（`0x1fd4→0x2074`）的五类计数完全相同。程序现在用更多掩码和标量操作组织内层访存，两个版本均无 SGPR/VGPR spill。静态 BFI 将更多代价放到了深度 2，可能发散的 IR 条件分支也从 15 增至 23，因此 T1、T2、T3 都进一步预测变慢。合并后的访存指令数和控制流形状提供了可跟踪的解释；只凭静态汇编不能定量判定动态访存或延迟占了多少。

### NQU64，Auto DARM 第二步

8 轮回放输出指纹和解数一致。中位数 **0.894865**，95% 区间 **[0.892745, 0.896101]**。这里实测的是 **Auto DARM 的父与子**：融合后、后端前的 TTI 为 **292→294**；LLVM 12 O3 后为 **281→273**。先前的 **274→274** 来自 Greedy 自己父 IR 上的备选试融，不能与这批 Auto DARM GPU 比值绑定，也不能替代实际父子的 TTI。

评分输入的循环外 TTI 完全相同（196），回溯热循环为 **96→98**，BFI 加权从 **945→1181**。循环头 `%unify.bb` 为 **23→27**（权重 16）；父版最大消失块 `%merged.bb16` 为 **33**（权重 4）；子版最大新增块 `%merged.bb32` 为 **41**（权重 8）。另有父版 `%merged.bb` 13（权重 16）和子版 `%merged.bb34` 17（权重 16）。这些块均在深度 1。BFI 把共享路径更高的估计权重乘到了整个块上，放大了误判。

| 区域（父→子） | 条件跳转 | EXEC | VALU | SALU | 访存 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 回溯热循环 `0x1ae4` | 4→3 | 20→14 | 33→30 | 19→17 | 7→7 |
| 循环外 | 8→8 | 24→24 | 36→36 | 25→25 | 24→24 |

在同一回溯循环，融合少了一次条件跳转及六个 EXEC 相关静态指令，访存条数和 spill 不变。T2 的分支开销能把方向从 T0 的变慢改为变快（336→334），只预测约 0.6% 的代价下降。按频率加权的 T1 和 T3 仍判反。O3 后，未加权 TTI 自身已能判对；因此此例同时包含**后端降低控制流成本**和**IR 静态频率无法反映 wave 活动掩码**这两个问题。

## 2. 评测集与排除

| 来源 | 转移数 | 取法 |
| --- | ---: | --- |
| HLLD 逐步 | 5 | 当前进程内、A/A 通过 |
| TPACF 逐步 | 12 | 细测批次的全部相邻状态，进程内、A/A 通过 |
| Landau coherent | 8 | 0→4→8→12→16 四组粗测与 16→17→18→19→20 四个细测相邻对，独立进程 A/A 通过 |
| NQU64 原版 Auto DARM | 2 | 两次相邻状态，各八轮，完整结果指纹，未记录 A/A |
| PCM32 第 10 步 | 1 | 真实父 IR，完整输出，进程内 A/A 通过 |
| 发布 DP1→anchor | 10 | 最终对象有差异，各按同批时间；HiPIMS-George 有通过的 A/A |
| **合计** | **38** | 其中 27 条有通过的 A/A |

所有纳入的批次均有输出校验证据。主表单列未归档 A/A 的 11 条，另算仅有通过 A/A 的子集。含多个提交的区间按整体比较。Landau 两种输入复用同一份代码，时间比值作为两条不同输入的转移。相关的相邻状态是描述性样本，未把它们视为独立重复实验。

排除项：

- Landau coherent 的进程内 A/A 为 0.98357、跨度 3.40%；保留通过的独立进程数据。未测的 1–15 单步不插值。
- HLLD 早期 bisect 停在五轮，重测又在 3.35% 配对跨度停止；排除两批早期性能标签，以较新的 12 轮 A/A 通过数据覆盖。 [早期 HLLD bisect](hlld-regression-bisect-20261119.md)
- NQU64 历史 DP2 的记录仍可核对 **+4.46%**；原始回放目录在 EPYC 上未找到，缺可绑定的父子 IR/HSACO、逐轮样本及 A/A。保留为旁证，未用旧中位数构造置信区间。 [历史 DP2 诊断](nqu-dp2-analysis-20261115.md)
- 历史 PCM32 Greedy trial-70 缺完整输出比对。TPACF 粗测重复、发布字节别名、SRAD16 stage1、SRAD stage2 1024、SasPoint5 的不稳定批次，以及无法启动的旧 SRAD32 stage1 和缺件的 CUDAflow、HiPIMS-HLLC、Reentry 均未进入统计。逐项原因见[数据文件](cost-model-eval-20261120-data.json)。

## 3. 模型和结果

用发布版 LLVM24 throughput TTI，保留现有 worker 对不可定价指令的处理。T0 为可达块的静态加和。T1 使用 LLVM24 默认 BFI，把基本块频率除以函数入口频率再乘该块 TTI。输入不含分支频率 profile 元数据。T2 单独对 LLVM UniformityInfo 判为可能发散的每个条件分支加 **4 TTI**。gfx906 的典型序列是 `s_and_saveexec_b64`、`s_cbranch_execz` 和 `s_or_b64 exec`。条件跳转对应现有条件分支 TTI 7；另用同一 worker 给掩码的 i64 AND 与 OR 各计 2，故增量 4。这个固定值在评测前取定。T3 对带同一分支附加费的块成本再做 BFI 加权。

方向主指标只计逐轮 bootstrap 95% 区间与 1 分离的转移，模型预测打平计为未判对。点值列覆盖所有样本，区间跨 1 的条目仍保留用于 Spearman。秩比较模型子/父比值与 GPU 子/父比值，打平取平均秩。

| 模型 | 方向，区间与 1 分离（29 条） | 方向，全部点值（38 条） | Spearman ρ | 仅 A/A 已通过，方向（19 条） | 仅 A/A 已通过，ρ（27 条） |
| --- | ---: | ---: | ---: | ---: | ---: |
| T0 | 15/29，51.7% | 17/38，44.7% | −0.189 | 11/19 | −0.161 |
| T1 | 13/29，44.8% | 16/38，42.1% | +0.001 | 8/19 | −0.009 |
| T2 | 17/29，58.6% | 19/38，50.0% | −0.092 | 11/19 | −0.107 |
| T3 | 14/29，48.3% | 16/38，42.1% | −0.017 | 9/19 | −0.032 |

T2 在主样本多判对的是两次 NQU64 Auto DARM，均未归档 A/A。严格子集的方向准确率没有净提升。T1 的秩相关接近 0，四种模型在这批样本均无稳定的排序能力。

各模型判错的转移（方向主指标）：

- **T0**：HLLD 2→3；HLLD 3→4；TPACF 1→2；TPACF 2→3；TPACF 5→6；Landau coherent 4→8；Landau coherent 16→17；NQU64 Auto DARM 1；NQU64 Auto DARM 2；PCM32 exact R2R 10；HLLD final A→N；MS32 final A→N；Landau coherent final A→N；TPACF final A→N。
- **T1**：HLLD 0→1；TPACF 0→1；TPACF 3→4；TPACF 4→5；TPACF 6→7；TPACF 8→9；TPACF 9→10；TPACF 10→11；Landau coherent 4→8；Landau coherent 8→12；NQU64 Auto DARM 1；NQU64 Auto DARM 2；PCM32 exact R2R 10；Map-Airy final A→N；MS32 final A→N；Landau coherent final A→N。
- **T2**：HLLD 2→3；HLLD 3→4；TPACF 1→2；TPACF 2→3；TPACF 5→6；Landau coherent 4→8；Landau coherent 16→17；PCM32 exact R2R 10；HLLD final A→N；MS32 final A→N；Landau coherent final A→N；TPACF final A→N。
- **T3**：HLLD 0→1；TPACF 0→1；TPACF 3→4；TPACF 4→5；TPACF 6→7；TPACF 9→10；TPACF 10→11；Landau coherent 4→8；Landau coherent 8→12；NQU64 Auto DARM 1；NQU64 Auto DARM 2；PCM32 exact R2R 10；Map-Airy final A→N；MS32 final A→N；Landau coherent final A→N。

点值口径的完整判错列表和九条区间含 1 的记录见[评测数据](cost-model-eval-20261120-data.json)。

## 4. T4 诊断

T4 延用 T3 的数值，并附上有定义的单笔 uniform gain 和目标 kernel 的 HSACO spill 变化。含多个提交的整体比较没有统一的真假臂，留空。共 20 条有 uniform 信息，37 条有 AMD spill 信息；HiPIMS 归档是 CUDA cubin。

按保守的同向线索统计：实测退化且一个已记录的 uniform gain 为负，或目标 kernel 的 spill 槽变化与耗时方向相符。T3 的 **15 条判错中，4 条**与 spill 变化一致，均来自 TPACF（0→1、3→4、6→7、10→11）；剩余错误没有同向的负 uniform 线索。这个计数表示有机制证据可追查，未将其当作单独因果证明。

对照 T0 的 14 条错误，HLLD 2→3、3→4 和 Landau coherent 16→17 有负 uniform 线索，TPACF 1→2、2→3、5→6 有 spill 上升线索，共 **6/14**。TPACF 4→5 还有一个槽数指标漏掉的例子：SGPR spill 槽仍为 50，但整个 kernel 的 `v_readlane` 从 274 降到 162，与耗时下降同向。PCM32 第 10 步的 −173/−197 uniform gain 与实际改善相反，且两个版本都没有 spill，T4 没有解释这个反例。

本次没有修改默认策略或融合代码。EPYC 的 `build/cost-model-eval/20261120-v1/` 保存只读 LLVM24 分析器、数据汇集与统计脚本、反汇编和逐块 CSV。
