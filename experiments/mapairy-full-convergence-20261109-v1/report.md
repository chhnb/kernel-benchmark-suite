# Map-Airy：八叶平衡树与自动贪心完整收敛

日期：2026-11-09。匹配器版本 5d82263。输入为完整 evaluate 的原始 suite LLVM12 baseline；LLVM24 gfx906 reciprocal-throughput TTI。融合后保持 scoped-cfg 清理，没有增加搜索阶段 O3；最终 GPU 代码生成统一使用既有 LLVM12 O3。

## 指定平衡树可继续合并

```text
T = (((L4,L5),(L6,L7)),((L8,L9),(L10,L11)))
```

指定计划的 7 步全部成功、LLVM verifier 通过，最终合并也是 adjacent B2B，未复制后续区域。由于匹配修复后各融合组是单个共享计算块，组与组仍可复用 B2B 路径。

| 步骤 | 合并 | 本步收益 | 合并后整个函数成本 |
|---|---|---:|---:|
| 0 | baseline | — | 6402 |
| 1 | L4+L5 | 272 | 6130 |
| 2 | L6+L7 | 272 | 5858 |
| 3 | L45+L67 | 271 | 5587 |
| 4 | L8+L9 | 272 | 5315 |
| 5 | L10+L11 | 272 | 5043 |
| 6 | L89+L1011 | 271 | 4772 |
| 7 | L4567+L891011 | **270** | **4502** |

最后一步也在普通 enumerate 候选中，由 replay 选择并调用 tryPair，不是手写替换 IR。

## 自动搜索确实收敛

配置：structural=1、adjacent-only=0、scoped-cfg、LLVM24、require-parent-gain=1、maxRounds=256、maxTrials=100000。当前 structural 模式使用通用 CFG 枚举，因此不是严格相邻专用模式；本次 L4～L11 的实际选择均是相邻叶子或相邻组。

实际 **16 次提交、1337 次 trial**，停止原因 **no_positive_candidate**，并非预算耗尽。最后一轮有 69 个候选：46 个通过 IR 检查并评分，最高收益 -4；12 个因循环作用域不支持拒绝、9 个 raw verifier 失败、2 个 region 结构不匹配。失败 trial 均未提交，保存了诊断。这里的收敛限定于当前候选枚举、合法性检查和评分器，不能当作所有合法融合的全局最优。

| 自动步骤 | 选择 | 收益 |
|---|---|---:|
| 1 | L6+L7 | 272 |
| 2 | L8+L9 | 272 |
| 3 | L10+L11 | 272 |
| 4 | L4+L5 | 272 |
| 5 | (L8,L9)+(L10,L11) | 271 |
| 6 | (L4,L5)+(L6,L7) | 271 |
| 7 | ((L4,L5),(L6,L7))+((L8,L9),(L10,L11)) | 270 |
| 8 | L3+T | 53 |
| 9 | L1+L2 | 7 |
| 10～16 | 7 处内部数值计算的小分支 | 每处 2 |

自动步骤 7 的函数成本同样为 4502，最终成本 **4428**。内部小分支不是额外七组原始 L 叶子。按原始区间顺序表示，下尾主树为：

```text
L0 | (L1,L2) | (L3,(((L4,L5),(L6,L7)),((L8,L9),(L10,L11)))) | L12
```

L12 表示保持独立的 fallback。树由逐步 commit 的源块、保留下来的原始唯一系数锚点还原；trial 的左右方向可能交换（步骤 9 记录为 L2/L1），上述表示按原始叶子顺序排列。并不意味着整个函数只剩这几个块。完整逐步映射见 trace.json。

## 同批 GPU 正确性与性能

AMD gfx906，完整 Map-Airy kernel，65,539 个固定输入，interval-mixture 与 coherent-blocks。每版本 3 次预热、15 次 event 计时，三批轮换版本顺序；先进行完整输出检查，计时运行也记录 full-output 通过。所有版本通过。原始 artifacts 自动 DARM 的比较基线二进制与本次 baseline 字节一致。

| 版本 | 混合输入 μs | 连续分块 μs |
|---|---:|---:|
| baseline | 49.600 | **16.000** |
| 原始 artifacts 自动 DARM | 32.960 | 18.400 |
| 仅指定 L4～L11 平衡树 | 27.680 | 18.560 |
| 完整自动贪心 | **24.640** | 19.040 |

完整贪心：混合输入相对 baseline 耗时降低 **50.32%（约 2.01×）**，相对原始 DARM 降低 **25.24%**，相对指定八叶树降低 **10.98%**。连续分块输入相对 baseline 慢 **19%**，相对原始 DARM 慢约 **3.48%**。

不能把完整贪心优于八叶树的全部差异单独归因于 L3，因为它还包含 L1+L2 与七处内部融合；要隔离 L3，需要额外消融。

三批混合输入中位数：baseline 49.440/49.600/49.600；指定树 27.680/27.680/27.840；贪心 24.640/24.640/24.800；原始 DARM 32.960/32.960/32.960 μs。

一次 GPU admission 在执行前拒绝，按既有入口有界重试后成功；无执行中失败。拒绝收据与后续成功收据均保留。

## 保存位置

musa `/home/chh/kernel-benchmark-suite/experiments/mapairy-full-convergence-20261109-v1/`：

- `steps-final/`：指定树各步 raw、cleaned IR 和 steps.tsv；最后是 state-7.ll。
- `greedy/`：所有 trial 的 raw/cleaned IR、评分、拒绝原因、commit 与 state；result.json 记录收敛。
- `greedy.ll`：自动贪心最终 IR。
- `balanced-pair/`、`greedy-pair/`：公共最终 O3 后 IR、GPU binary、资源信息和构建 manifest。
- `measure/`、`summary.json`：完整正确性收据、三批 CSV、汇总；`evidence.json`：关键 hash 和比较基线身份。
- `trace.json`、`convergence.json`：合并树映射和最后一轮统计。

CPU 日志：`/home/chh/region-fusion-lab/work/mapairy-full-convergence-20261109-v1/` 与 `mapairy-full-convergence-codegen-20261109-v1/`。没有改动原始 artifacts DARM 实现。
