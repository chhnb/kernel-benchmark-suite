# SRAD 新实现自动贪心复测（2026-11-09）

完整 srad_cuda_1，LLVM12 / gfx906，未抽取九分支 helper。实现提交 4edb0b3，原始 artifacts DARM 提交 e9bc0540325ad9806313d34e84fc901496fd8be6。

## 实测结果

| 版本 | 融合次数 | 1024×1024，μs | 256×256，μs |
|---|---:|---:|---:|
| 共同 baseline | 0 | 101.760 | 23.680 |
| 新贪心 scoped-local | 0 | 同 baseline 二进制 | 同 baseline 二进制 |
| 新贪心 scoped-cfg | 0 | 同 baseline 二进制 | 同 baseline 二进制 |
| 原始 artifacts 自动 DARM | 6 | 112.480 | 23.840 |
| 强制 trial11（非贪心选择） | 1 | 100.640 | 23.680 |

原始 DARM 在 1024² 上耗时增加 10.53%，256² 增加 0.68%。强制 trial11 汇总中位数在 1024² 上减少 1.10%，但逐批比较方向翻转，不能认定稳定收益。没有证明“不融合全局最好”。

每种唯一二进制先验证完整输出，再测 3 批，每批 3 次预热＋15 次测量，C++ HIP event 计时；表中为三批中位数的中位数。三批顺序为 baseline/DARM/forced，forced/baseline/DARM，baseline/DARM/forced，并非完全平衡顺序设计。相同二进制去重测量；新贪心不是独立性能样本。

1024² 逐批中位数：
- baseline：103.360、98.560、101.760 μs。
- 原始 DARM：112.000、112.480、112.480 μs。
- 强制 trial11：98.880、100.640、102.720 μs。

固定随机图像，q0sqr=0.1，16×16 block。全部五输出通过 CPU oracle 容差 3e-5 + 3e-5×abs(ref)、既有 baseline exactref、输入不变和 guard 检查。只测完整单 kernel，不是迭代 solver。一次启动前准入拒绝后重试；未重试已执行的测量，记录保留。

## 静态结果及解释

structural=1、adjacent-only=0、LLVM24 TTI；rounds=256、trials=100000。两种模式均枚举 13 个候选：11 个合法且已评分，全负；2 个因 side_effect_in_trial_scope_not_supported 拒绝，并非负分。停止原因均 no_positive_candidate，提交 0 次。

- scoped-local 最高收益 −30。
- scoped-cfg 最高收益 −11，trial11：%if.then346 + %if.else370，DARM B2B。
- scoped-cfg trial11 control 成本 491，融合清理后 502。
- 少 1 条 add、4 条 GEP：+5。
- 多 1 条条件 br（7）、1 条无条件 br（4）、2 条 i32 PHI（2）、2 条 i32 select（2）、1 条共享内存指针 select（1）：−16。
- 净收益 5−16=−11。

基线已经把九个叶子的地址通过 PHI 汇合，load/fsub 位于共享汇合块；叶子主要是地址计算。因此不能套用旧 helper 试验中“合并可减少四组 load/fsub/store”的收益。所有版本最终统一 O3/llc/link；trial 内只运行指定局部清理。

后端资源：baseline/forced 为 SGPR32、VGPR19，原始 DARM SGPR40、VGPR20；三者 LDS6144 bytes、private segment0。这是资源差异，未建立变慢的因果证明。

历史 nine-way REPORT.txt 中 WI_then_E 在1024²有约2.31%的筛查改善，但 IQR 重叠，未获独立确认；该路线有共同 helper 准备，与本轮原始完整 IR 不同。

## 复现与证据

musa 主目录 /home/chh/kernel-benchmark-suite/experiments/srad-greedy-20261109-v1/。

prepare.py 保存共同输入、两种搜索、原始 DARM 和统一编译；build-plan.json 是命令记录。scoped-local/ 与 scoped-cfg/ 保存每个 trial 的 IR 和分数。forced-11-pair/manifest.json 保存强制候选编译命令。measure.py、measure/ 保存准入、完整输出检查、CSV 和二进制哈希；summary.json 保存所有汇总数据。

本次没有修改融合实现或评分权重。
