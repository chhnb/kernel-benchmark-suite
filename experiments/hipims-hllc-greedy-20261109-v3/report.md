# HiPIMS–HLLC 当前实现复测（2026-11-09）

## 结论与状态

编译和静态搜索已完成，GPU 正确性与性能测试尚未启动成功。TITAN V 存在其他用户的计算进程，现有 bench 准入规则拒绝运行。不能宣称这一版快于 baseline，也不能把静态负分当作实测变慢。

两种自动贪心模式均评估 23 个候选，23 个均通过 LLVM verifier 并获得完整 TTI 评分；全部负收益，提交 0 次，停止原因 no_positive_candidate。两种最终 cubin 都与共同准备的 baseline 字节相同。

| 配置 | 有效且已评分候选 | 最佳静态收益（control成本−候选成本） | 提交融合 |
|---|---:|---:|---:|
| scoped-local | 23 | −8 | 0 |
| scoped-cfg | 23 | −6 | 0 |
| 原始 artifacts 自动 DARM，同一 prepared baseline | 不使用新评分器 | 不适用 | 6 |

23 是结构候选条目数，包含部分方向相反的同一配对，不等于 23 个唯一无向配对。此实验 structural=1、adjacent-only=0，覆盖结构枚举候选，不局限于一棵量化树的相邻叶子。

## 以前是否有好结果

旧记录位于 /home/chh/divergence-strategy-search/explorations/hipims-integration-20261104/。

- FUSION-REPORT.txt：step100 的共同 LLVM baseline 为 90.112 μs，BF/DARM 为 89.088 μs，约降低 1.14%，但 IQR 重叠，未确认稳定收益。
- INLINE-REPORT.txt：另一条共同准备流水线中，BF/DARM 均未超过自身 baseline。
- middle-confirmation-v1/summary.json：手动 middle12 在 step0 为 48.128 μs，对照 49.152 μs；step100 为 89.088 μs，对照 89.088 μs。没有获得跨两种输入的稳定优势。
- hllc-acceptance.json 仍是 baseline-only，无融合性能验收结论。

这些是历史记录，不是本轮测量。

## Case、输入和公平对照

实际测试对象是 cases/hipims 的完整 Cartesian HLLC CUDA kernel，源码调用 cuHLLCRiemannSolverSWEs。不是 HiPIMS–George。

目标 TITAN V / sm_70，43,512 cells，step0 与 step100 两个官方输入快照，128 blocks × 256 threads。正确性由现有 C++ runner 对完整输出检查，容差 abs 1e-10 + rel 1e-10，并检查有限值和 guard。

原始 LLVM12 O3 输入含一个 __internal_accurate_pow 调用。评分器拒绝把未知整个 callee 的普通 call 成本当作完整工作量，所以直接评分得到 unavailable，而不是把这部分按零处理。

本实验在所有 LLVM 方案共同的 baseline 准备阶段，使用 LLVM12 InlineFunction 展开这一调用，再 O3；不改数学实现，不增加 helper。之后 baseline、原始 DARM、新贪心全部从 prepared.ll 出发。保留未进行此准备的 LLVM baseline 和 native NVCC baseline 作为额外对照，不能把 baseline 准备带来的差别归因于融合。

每个方案最终都走相同 LLVM12 O3 → llc sm_70/+ptx70 → ptxas。这里的最终编译 O3 与每次 trial 的 scoped-local/scoped-cfg 清理是两个独立阶段。评分使用 LLVM24 TTI reciprocal throughput，尚未以硬件校准。

## 实现修复与回归

发现“纯 B2B”不一定是 local-computation 引擎支持的闭合单输出计算。HLLC 有 select 根节点、多输出的纯基本块，原分派会误送进 local 引擎并拒绝。

修复：分派之前调用 describeLocalComputation 检查双方支持范围及根操作兼容性；不满足时直接交给 DARM RegionMelder。这不是失败后重试，也不修改原始 artifacts DARM 仓库。

新增多输出/select-root B2B 回归测试，验证 DARM 分派、模块合法性、父状态不变。完整构建、hybrid、guard-pairs、scoped-cfg 测试通过。

修复后 TIGRE 冻结优胜方案重新编译：仍提交 2 次，IR 除 ModuleID 注释外相同，GPU binary 字节相同。vLLM 的专用 local-copysign 路径不经过此次修改的 hybrid 分派；此次改动后没有重复运行完整 vLLM GPU 性能回归。此前保存的 vLLM/TIGRE 完整性能回归资料位于 regression/。

## 三个强制融合诊断候选

这些候选已生成 cubin，供检查“静态负分是否漏掉实际好结果”；不是自动贪心选中的结果。

| trial | 配对 | scoped-cfg 静态收益 |
|---|---|---:|
| 17 | %if.then33.i + %if.else36.i | −6 |
| 18 | %if.then42.i + %if.else45.i | −6 |
| 22 | %if.then99.i + %if.else101.i | −8 |

trial17 的 control 成本 730，候选 736。变化：少 1 条 fsub（收益 +2），多 1 条条件 br、2 条无条件 br、2 条 double PHI、3 条 double select（合计 −8），净收益 −6。这是静态指令成本，不能替代 GPU 时间。

## 性能验收计划与阻塞

measure.py 对所有唯一二进制先验证完整输出，再运行 3 批轮换版本顺序的测试，每批 3 次预热 + 15 次 GPU event 计时。每个快照取每批中位数，再取三批中位数。字节相同的二进制只测一次，明确记录别名，不伪造独立样本。

比较对象：native NVCC baseline、原始 LLVM baseline、prepared baseline、原始 artifacts DARM、新贪心的两个模式、3 个强制候选。

本轮启动在第一份 baseline 验证前连续 3 次被准入拒绝，没有执行 GPU kernel。拒绝记录保存于 measure/ 下，terminal.json 状态 stopped_preserved；不绕过占用检查、不终止他人进程。

空闲后在 musa 运行：
```bash
cd /home/chh/kernel-benchmark-suite
python3 experiments/hipims-hllc-greedy-20261109-v3/measure.py --output-name measure-confirm
```
输出目录必须不存在。完成后 summary.json 才会包含实测结果。

## 文件位置

主目录：/home/chh/kernel-benchmark-suite/experiments/hipims-hllc-greedy-20261109-v3/

- prepare.py / inline_baseline.cpp / inline.sh：共同 baseline、两种搜索、原始 DARM、编译。
- scoped-local/、scoped-cfg/：各候选融合前后 IR、评分、停止原因。
- diagnostics.py：三个强制候选的统一最终编译。
- measure.py：具备准入、完整输出验证、轮换计时和二进制去重的测量入口。
- build-plan.json、diagnostic-build-plan.json：真实编译命令与退出状态。
- measure/：本次拒绝记录。
- evidence-summary.json：精简静态结果与二进制哈希。

保留输入、oracle、CSV、IR 和配置；用户允许丢弃的仅是可重建的执行输出数据。
