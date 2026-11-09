# L1＋L2 小 gap 局部清理：实现与测量

## 本轮范围

修正 RegionMelder::setOperendsForBr 中第二次写入 LeftValues 的 typo，改为 RightValues。
旧清理模式的原始融合 IR 与此前字节一致，说明本例只是映射 bookkeeping 修复，没有改变实际生成 IR。

新增独立清理模式 --cleanup scoped-cfg-triangles，保留原 scoped-cfg 行为与默认值。
仅折叠 trial 新建块中的短单侧三角形：最多 5 条、标量整数（不超过 64 位）的 icmp/select/trunc/zext/sext，且通过 isSafeToSpeculativelyExecute。
head/body/join 都必须是 trial 新块，body 单前驱单后继，所有修改的 PHI 都在许可范围。
没有移动加载、调用、除法、浮点计算；没有启用全函数 SimplifyCFG/O3。
新增选择和 PHI 修复随后使用已有局部清理，不修改外部指令的审计继续执行。

这是针对小 gap 的保守结构实验，不是 TTI 引导的通用投机策略。
LLVM24 reciprocal-throughput 权重、锚点选择、gap 归并策略保持不变。
本轮尚未实现 leaf 单元重排、多锚点或 beam。

## 静态结果

固定候选 B7:E8_23:E15_23。旧/新模式的 raw IR 字节相同，仅外层清理不同。

| 局部清理后 | 旧模式 | 新模式 |
|---|---:|---:|
| 基本块 | 61 | 59 |
| 指令 | 800 | 796 |
| 条件 br | 33 | 32 |
| PHI | 20 | 18 |
| select | 42 | 42 |
| TTI 成本 | 1926 | 1913 |
| 相对 control=1915 的收益 | -11 | +2 |
| eligible | false | true |

改善 13：少 1 条条件 br（7）、1 条无条件 br（4）、2 个 PHI（2）。
五条边界计算被提前到共享块，原保护三角形和一处直线边界消失。
选择指令净数不变。+2 表示成为可接受候选，不代表已在完整搜索中胜出。

## GPU 性能

完整 Hypersonic kernel，gfx906，冻结的两份输入；每批预热 3 次、测量 15 次，三个批次轮换版本顺序，GPU event 计时。
baseline、旧 L1+L2、新 L1+L2 均独立验证和测量；三个二进制不同，没有别名复用计时。
最终代码生成仍使用同一 LLVM12 O3。完整输出、只读输入和 guard 检查通过。

| 三批中位数的中位数 | 输入 1 | 输入 2 |
|---|---:|---:|
| baseline | 1813.121 μs | 1813.761 μs |
| 旧 L1+L2 | 1741.761 μs | 1738.721 μs |
| 新局部清理 L1+L2 | 1741.601 μs | 1740.641 μs |
| 新版相对 baseline 耗时降低 | 3.94% | 4.03% |

新旧之间约 0.01%～0.11%，没有明确的额外加速证据。
旧版也快约 3.94%～4.14%，因此不能将约 4% 的收益归因于此次清理。
关键变化是：旧评分 -11 漏掉了实际更快的候选；新清理减少静态冗余，使它在不改权重的情况下转为 +2。
本次未进行端到端应用性能评估，也未重新跑完整贪心搜索。

## 回归

- 新增 7,595 组 CPU 输入比较：安全短整数段可以消除；未选路径的除零、NULL load 仍被保护。
- LLVM raw/cleaned verifier、父模块不可变及 scoped 外部审计通过。
- 既有相邻入口、局部 CFG 运行回归通过。
- gap 归并正向 fixture 仍然 38→9 块，192 组位级比较通过。
- 新模式默认不开启；未校准或修改任何指令权重。

## 复现

项目 /home/chh/kernel-benchmark-suite。
实验 experiments/hypersonic-scoped-triangle-20261109-v1。
prepare.py 固定候选对比；compile.py 公共最终代码生成；measure.py GPU 验证和轮换计时。
reviewed.json 汇总结果；summary.json 含逐批时间；measure/ 保存接受收据和输入快照。
old/trial-0/after.ll 与 triangle/trial-0/after.ll 是应对比的局部清理 IR。
在此前显式候选命令中把 --cleanup scoped-cfg 改为 --cleanup scoped-cfg-triangles 即可。
