# Hypersonic gap 归并：实现与验证

新增独立开关 --coalesce-gaps 1，默认 0。实现位于 suite 的 RegionMelder::coalesceGapRanges，原始 artifacts checkout 未修改。

## 实现

在对齐、内部清理完成后、unpredication 之前，只对同一块内连续的 gap 做稳定分组，保持每侧原有指令和内存顺序，仍用原来的互斥条件保护两侧。
共享指令、PHI、terminator、调用、fence、volatile/atomic 访问构成重排边界；段内跨侧 SSA 依赖会阻止归并。
重建 SplitRanges 后复用已有的互补 gap diamond 与 PHI 生成。
未改对齐算法、评分器、store 保护策略，未加入 TTI 投机成本选择。
固定候选的 parent hash、匹配锚点、复制方式和 DARM 相似度前后一致。
trial.json 新增 coalesce_gaps、coalesced_gap_groups。

## L0+L1 固定候选结果

| 指标 | 关闭 | 开启 |
|---|---:|---:|
| 原始融合后基本块 | 99 | 70 |
| 原始融合后指令 | 878 | 831 |
| 原始融合后条件 br | 44 | 34 |
| 原始融合后 PHI | 58 | 40 |
| 原始融合后 select | 44 | 44 |
| 局部清理后基本块 | 92 | 63 |
| 局部清理后指令 | 867 | 820 |
| 局部清理后条件 br | 43 | 33 |
| 局部清理后 PHI | 54 | 36 |
| LLVM24 TTI 收益 | -201 | -37 |

coalesced_gap_groups=1 表示归并了一个连续交错段。10 个小 diamond 及其后的单边尾段集中为更完整的左右计算段。
静态收益仍为负，贪心仍拒绝这个候选。
L1+L2 没有可归并段，开启/关闭的原始 IR 字节完全相同，收益仍为 -11。

## GPU 结果

最终代码生成使用共同 LLVM12 O3。off/on 的 hsaco 字节完全相同。
只对唯一二进制验证和计时，on 是 off 的别名，不是两次独立测量。
最终 O3/后端已能将两条路线收敛为同一二进制；本轮没有证明新开关带来额外 GPU 加速。

| 单 kernel 时间，三批中位数的中位数 | 冻结输入 1 | 冻结输入 2 |
|---|---:|---:|
| 未融合 baseline | 1813.920 μs | 1813.280 μs |
| L0+L1，gap off/on 同一二进制 | 1785.600 μs | 1790.560 μs |
| 本轮相对 baseline 时间降低 | 1.56% | 1.25% |

每批 3 次预热、15 次测量，3 批轮换唯一二进制顺序，GPU event 计时。
完整输出、输入只读、guard 检查通过。这不是端到端应用加速。
不能把上述收益归因于新开关。
静态负分与本轮 GPU 小幅加速并存，说明现有评分仍会错过实际较快候选。

## 验证

- 关闭开关：两组候选的原始 IR 与上版字节一致；L0+L1 baseline/variant 二进制与上版一致。
- 完整叶子测试：12,006 组输入，每组比较 baseline 和四个融合版本（两对候选，开关各两种）。
- 专用正向归并测试：从两个 Hypersonic 锚点构造 CPU 测试，不替代真实 GPU case。38 块降至 9 块；192 组输入位级对照通过，包含未选侧 NULL 指针、8 个输出值、输出 guard。
- 开启归并的 intrinsic 回归通过：immarg/convergence、未匹配调用保护、parent 不变。
- 原有相邻入口及 scoped CFG 回归通过，含 signed zero、infinity、NaN。
- LLVM verifier 和 diff whitespace 检查通过。

## 复现

项目 /home/chh/kernel-benchmark-suite。
实验 experiments/hypersonic-coalesce-gaps-20261109-v1。
prepare.py 固定候选，compile.py 公共最终 O3，measure.py 验证和计时。
reviewed.json 保存静态结果、二进制哈希及计时；summary.json 保存计时别名和逐批结果。
原始融合 IR 位于 L0-L1-off/trial-0/after-raw.ll、L0-L1-on/trial-0/after-raw.ll；同目录 after.ll 是局部清理后。

已有命令加 --coalesce-gaps 1 即可。完整固定候选命令（输出路径需尚不存在）：

~~~bash
/home/chh/kernel-benchmark-suite/build/llvm24-tti/fusion-search-llvm24 --ir /home/chh/kernel-benchmark-suite/experiments/hypersonic-complete-leaf-20261109-v1/input.ll --function face_kernel --structural 1 --split B5 --left E6_23 --right E8_23 --coalesce-gaps 1 --cleanup scoped-cfg --scorer llvm24 --debug-dir /tmp/hypersonic-gap-trial --out /tmp/hypersonic-gap-trial.ll
~~~

自动贪心也接收该开关；本轮只做固定候选对比，没有运行完整搜索。
