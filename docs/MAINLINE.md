# 主线目标与实现边界

更新：2026-11-10，融合实现已包含 `4ac5a90`。

## 要解决的问题

给定真实GPU kernel的baseline LLVM IR，识别可融合的控制流区域，尝试不同合并选择，用可解释的静态收益选出方案，并验证它相对baseline和原始artifacts自动DARM的实际收益。

核心研究问题有三个：候选是否完整且合理；试融合能否共享应当共享的计算且正确保留副作用；评分能否选出实际更快的方案。不要把所有收益都归因于评分器，匹配器和候选集合也在变化。

## 两层边界

| 层 | 职责 | 当前主要代码 |
|---|---|---|
| Benchmark suite | 源码/版本、构建profile、输入生成、CPU参考、kernel ABI、C++执行和计时 | cases、runner、bench、tools/suite.py、regression |
| Fusion engine | LLVM12区域分析、候选、克隆试融合、清理、LLVM24评分、贪心提交 | tools/fusion_search.*、logical_region_state.*、darm_pair_engine、llvm24_scorer.h |

Runner不识别区域、不抽取优化helper、不改变IR。不同case可以有专用C++ harness来表达真实ABI/几何结构；这不等于要求每个case实现一个优化adapter。Python仅保留构建、准入、运行编排和报告，不能把“主体为C++”误写成“项目完全不含Python”。

```text
固定源码/移植说明 + 显式编译参数
  → baseline IR（按case选择O0准备/O2/O3/no-JumpThreading）
  ├→ 不融合
  ├→ 原始artifacts自动DARM
  └→ 当前C++候选枚举 → 克隆试融合 → 固定局部清理 → TTI评分 → 贪心提交
  → 各版本使用相同最终后端流水线
  → C++完整输出验证 → 同批GPU event计时 → 回归判定
```

搜索中的cleanup与最后codegen的O3是两个阶段。不能因某个case需要不同baseline准备，就只改变新策略的起点而保持对照不变。

## 当前评分

每轮共享无融合control B；候选A经过相同cleanup后：

`score = (C(B) - C(A)) / max(C(B), 1)`

C是目标函数入口可达指令的LLVM24 `TCK_RecipThroughput` 总成本。它没有输入路径概率、wave分歧比例、寄存器/spill或依赖链校准。TTI固定revision为 `6be16f356d3e`；LLVM24不替代LLVM12执行变换。未知成本不能当零。

默认只提交合法且正分最高的候选，重新枚举直到无正分或预算结束。不是全局最优保证。vLLM的逐决策组相邻贪心、Map-Airy/TIGRE的structural枚举和Hypersonic指定区域实验，目前还不是完全统一的一种搜索配置。

## 当前case范围

| 程序/Kernel | 当前定位 |
|---|---|
| vLLM Quant | HIP软件cache_eval，随机64K/128K收益回归；不是原生NVFP4或端到端推理 |
| Map-Airy | 混合下尾输入收益回归；连续分块输入曾慢19%，保留反例 |
| TIGRE Siddon | 完整kernel收益回归；最终共享到1处纹理采样 |
| Hypersonic | no-JT共同baseline上的L1+L2指定试验；多锚点收益，尚非完整搜索验收 |
| SRAD stage1 / stage2 | 两个kernel；当前默认贪心0提交，作为不误融合与正确性回归 |
| HiPIMS–HLLC | 静态候选已评分，最新prepared baseline GPU比较待验收 |
| Cholla–HLLD | 识别、合法性和成本覆盖，当前新路径GPU收益未确认 |
| Reentry | 大IR/复杂结构覆盖，当前新路径GPU收益未确认 |

Landau、CuDAFLOW、Saspoint5、SW2D、HiPIMS–George不在当前重点；TPACF/CED保留为旁支实验。物理目录仍在，不等于应删除。

## 验收标准

能从固定源码/明确移植输入重建baseline；输出验证通过；原始DARM与新策略同起点同后端；保存候选/停止原因、编译版本、输入身份、原始CSV和资源信息；收益必须明确设备与输入范围。新策略不能覆盖旧reference来“通过”回归。

近期优先顺序：冻结可复现的基线与回归入口 → 统一case/策略manifest和工具入口 → 补齐原生DARM同批对照 → 再扩展评分和复杂结构支持。beam、概率模型、更多case不作为当前整理阶段的主线。
