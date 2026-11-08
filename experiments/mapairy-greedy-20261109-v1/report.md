# Map-Airy 当前自动贪心复测（2026-11-09）

## 结果
完整 Boost.Math Map-Airy quantile<double>，LLVM12/gfx906；无 helper 提取。实现版本 4edb0b3，原始 artifacts DARM e9bc0540325ad9806313d34e84fc901496fd8be6。LLVM24 TTI 静态评分，structural=1、adjacent-only=0，rounds=256、trials=100000。

| 方案 | 融合次数 | 混合输入 μs | 连续分块输入 μs |
|---|---:|---:|---:|
| baseline | 0 | 49.440 | 16.000 |
| 新贪心 scoped-local | 0 | 同 baseline 二进制 | 同 baseline 二进制 |
| 新贪心 scoped-cfg | 7 | 49.440 | 16.000 |
| 原始 artifacts 自动 DARM | 25 | 32.960 | 18.400 |

新贪心尚未带来可确认收益。原始 DARM 混合输入耗时减少33.33%（约1.50×），连续分块输入耗时增加15.00%。不存在跨两种输入统一最优的版本。

每个不同二进制先完整输出验证，再3批、每批3预热+15测量，C++ HIP event计时。每个输入取三批中位数的中位数；同二进制明确去重。三批顺序循环轮换。全部输出检查通过。固定65539个有限FP64输入、block256、长双精度CPU oracle，abs1e-14+rel5e-13；仅单kernel。

原始批次中位数（混合 / 连续分块 μs）：
- baseline：49.440/16.000，49.440/16.000，49.440/16.000。
- scoped-cfg：49.440/16.000，49.440/15.840，49.600/18.560。
- 原始 DARM：32.960/18.240，32.960/18.560，33.120/18.400。
scoped-cfg 连续分块第三批明显偏高，已保留，未剔除或补测。

## 搜索与差异
scoped-local：116次trial，其中104次合法、12次因循环范围限制拒绝；提交0。
scoped-cfg：900次跨轮trial，其中804次合法、96次因循环范围限制拒绝；提交7。900不是首轮唯一配对数。均以no_positive_candidate停止，不是预算停止。

7次提交的每次静态收益均为+2：
evaluate:B12:B13:B14、B22:B23:B24、B32:B33:B34、B42:B43:B44、B52:B53:B54、B61:B62:B63、B67:B68:B69。
编号各自属于当轮父IR，不能当作跨轮固定源码叶子标签。

以首个候选为例，融合的是内联数值实现中的两个缩放分支：
左分支计算 1<<exp 后转double再乘；右分支计算 1<<other_exp 后转double再除。
共享后少一条shl(cost2)、一条uitofp(cost8)，但增加无条件br(cost4)、两个PHI(cost2)、两个select(cost2)，净收益+2。zext计0。
因此本轮选中的主要是小型整数/浮点转换共享，并没有重现原始DARM那种带来明显混合输入收益的大规模融合。

每次trial只用指定局部清理；所有方案最终统一LLVM12 O3/llc/link。这一结果说明当前静态评分加变换支持范围仍可能错过实际有利的融合，不能由“贪心不选”推断baseline最优。输入激活模式也没有进入当前评分。

## 证据与复现
musa：/home/chh/kernel-benchmark-suite/experiments/mapairy-greedy-20261109-v1/
prepare.py、build-plan.json：输入哈希、搜索、原始DARM、共同后端。
scoped-local/、scoped-cfg/：每轮父状态、候选IR、评分及提交。
measure.py、measure/：输入/二进制快照、准入、正确性、原始CSV。
summary.json：精确计时和三批样本。
此次未改融合算法或权重。
