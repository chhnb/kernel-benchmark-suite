# Hypersonic 当前自动贪心复测（2026-11-09）

完整 face_kernel，未抽取 face_decide helper。使用套件既有修正语义的HIP源码所生成LLVM12 O2 IR，在各方案最终统一LLVM12 O3/llc gfx906/link。比较的是共同LLVM12 baseline，不是既有ROCm18 native O2默认二进制；不能把跨编译器差异算作融合收益。

## 实测
| 方案 | 融合次数 | 快照1 μs | 快照24 μs |
|---|---:|---:|---:|
| 共同 LLVM12 baseline | 0 | 1799.841 | 1801.441 |
| 新贪心 scoped-local | 1 | 1799.041 | 1800.161 |
| 新贪心 scoped-cfg | 1 | 与scoped-local二进制相同 | 与scoped-local二进制相同 |
| 原始 artifacts 自动 DARM | 失败，无可执行结果 | — | — |

耗时分别减少0.0444%和0.0711%，逐批方向翻转，不能认定稳定收益。新贪心没有确认超过baseline。

3批，每批3预热+15测量，C++ HIP event；表格是三批中位数的中位数。不同二进制先通过完整输出验证，计时每次输出也检查。固定真实快照1/24，完整X-face replay、block256；容差abs1e-12+rel1e-10，包含guards、readonly、holes和非法数检查。不包含完整solver运行。相同二进制测一次，不伪造独立样本。一项启动前准入拒绝后重试，未重试已执行批次。

逐批快照1/24中位数 μs：
- baseline：1799.681/1800.801，1799.841/1801.921，1800.161/1801.441。
- 新贪心：1795.521/1795.361，1799.041/1800.161，1803.361/1802.401。

## 静态结果
实现4edb0b3；LLVM24 TTI，structural=1、adjacent-only=0、rounds256、trials100000。
两种模式都选择初始父状态 face_kernel:B51:B53:B52，即 %if.end169.i.i 与 %if.then140.i.i 的 DARM B2B 融合。
scoped-local 静态收益+4；scoped-cfg +23。最终统一后端产生相同hsaco，说明静态分数差异没有变成这里的二进制差异。
均提交1次后no_positive_candidate停止，非预算耗尽。

scoped-local累计46次trial：26合法，14结构不匹配，4副作用范围拒绝，2原始融合IR verifier失败。
scoped-cfg累计44次trial：24合法，其他三类拒绝数相同。
失败trial保留，未参与提交；不声称所有区域都已支持。

原始artifacts DARM提交 e9bc0540325ad9806313d34e84fc901496fd8be6，进程退出-6。RegionAnalyzer.cpp:473 的 verifyRegionList(LeftRegions, DT) dominance-order断言再次触发，在首次融合前失败。此处不能写成“DARM零次融合所以等于baseline”，也不能使用失败产生的IR计时。

## 文件
musa：/home/chh/kernel-benchmark-suite/experiments/hypersonic-greedy-20261109-v1/
prepare.py/build-plan.json保存构建与搜索命令；scoped-local/、scoped-cfg/保存候选和IR；original-darm.stderr及original-darm-failure.json保存原始DARM失败。
measure.py、measure/保存准入、正确性、原始checks.jsonl和输入快照；summary.json保存精确计时。
本轮未修改融合实现或评分权重。
