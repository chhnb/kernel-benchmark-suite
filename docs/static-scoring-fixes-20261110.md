# 静态评分实现修复：跨层级边界、单侧成本、试融合异常隔离

基于 `e4138fb`。默认行为不变：新 guard 默认关闭，边界修正只从默认候选集中移除跨层级 E 对。

## 1. 现有静态分数度量的是什么

融合只改动 split 到 join 之间的代码，所以全函数可达指令的 TTI 差：

```
Δ = [C(T侧块) + C(F侧块)] − C(融合后块)
```

这等于**一个 wave 的两侧都执行时**节省的成本，即隐含假设每个 wave 都发散。计算本身正确，但"静态更便宜 ⇒ 更快"只在这个假设下成立。跨层级 R2B 能拿到 Δ>0，一侧路径上新增的 `select(choose, cond, const)` 却只在静态总量里计一次。

## 2. 改动

### 2.1 完整叶子的跨层级边界（默认）

`4ac5a90` 的同 SSA 判别值规则挡住 Map-Airy，原因是上尾比较的是 `1−p`，属于巧合。在同一个变量上展开的平衡树（`x<0.5`、`x<0.25`、`x<0.75`）里，判别值相同，`(下尾整棵子树, 上尾单块)` 仍会被默认枚举。

现在额外要求：**任一侧内部不得有条件分支依赖该决策判别值**（按 SSA def-use 判断）。如果有，该侧本身就是同一决策的子树，这对候选记为 cross-level，默认不枚举。显式 pair 被拒绝时给出 `complete_leaf_cross_level_requires_opt_in`。`--cross-decision-leaves 1` 保留这项能力。Hypersonic 本来就需要 opt-in，不受影响。

### 2.2 单侧（uniform-wave）成本：只报告，不改默认选择

每个 trial 额外计算 split 条件固定为 false/true 时的可达块。替换常量后只折叠可以确定的分支，其他分支保持两边都可达；被简化的指令仍在原函数里计成本。LLVM24 scorer 按 worker 的 `instruction_costs` 对这些块求和，写入 metrics：

| metric | 含义 |
|---|---|
| `side_false_before/after`、`side_true_before/after` | 只走一侧的 wave 在融合前后执行的成本 |
| `uniform_gain_false/true` | 融合前减融合后；负值表示该侧变慢 |
| `side_metrics_available` | 1 表示可用 |

before 侧取父状态 S。scoped 清理模式下 S 与 control 相同；其他清理模式下 before 侧不含 control 清理，解读时需要注意。

`--max-uniform-loss X`（默认关闭，仅限 llvm24 scorer）：任一侧 `uniform_gain < −X` 即判为 ineligible；缺少 side metrics 时也视为 ineligible。阈值单位是 TTI，**需要校准后才能启用**。

实现说明：split 条件在 trial 克隆里用 metadata 标记，以便穿过 CloneModule 和清理后重新找到；最外层 `tryPair` 返回前会去掉所有标记，提交的模块、调试 IR 和 hash 都不含标记。complete-leaf 的嵌套 trial 使用外层（gate 之前）的 before 侧。

### 2.3 试融合异常隔离

`greedy` 中的 `tryPair` 和 `evaluateTrial` 加了 try/catch。清理不收敛、审计失败等异常记为该 trial 的 `trial_exception:` 或 `score_exception:`，搜索继续进行。此前任一候选抛出异常，整个搜索都会返回 2。`beam_search.cpp` 原本就有这层处理。

### 2.4 过期测试

`tests/postopt/complete-leaf-plan/check.cpp` 的 fixture 使用不同的 SSA 谓词（`%pickL`/`%pickR`）。`4ac5a90` 之后候选在判别值边界处就被拒绝，测试在 "convergent leaf accepted" 失败；在当前提交上，不加本补丁也会失败。现已补上 `crossDecisionLeaves=true`，与 Hypersonic 的使用方式一致。

## 3. 本地验证范围

环境：conda-forge LLVM 12.0.1，只在临时副本里加了 4 处 API 兼容改动（`ElementCount`、`InstructionCost`、`SplitBlock`、`simplifyCFG` 签名），仓库代码未改；未修改的 `llvm24_tti_main.cpp` 编译在 LLVM 23.1.5 上。**不是** musa 上的 DARM fork LLVM12 和 LLVM24 `6be16f356d3e`。

- 原始提交与补丁各自完整构建。能脱离 musa 运行的 C++ 测试输出 IR 逐字节相同：adjacent_entry、guard_pairs、complete-leaf、coalesce-gaps（两项）、scoped-triangle。intrinsic_matching、scoped_cfg、scoped_local、dependency、pressure、block_work、scorer、union_implication 通过。ordered/recursive_local_union 需要 vLLM IR，hybrid 需要 TIGRE IR，本地未运行。
- 新的 complete-leaf 平衡树断言在原代码上失败（"cross-level leaf pair in default enumeration"），在补丁上通过。
- 新增 `tests/postopt/side-metrics/`：侧集合、guard 语义、标记不泄漏、注入异常后搜索仍能提交。`run.sh` 中的端到端部分用真实 worker 跑通。
- 端到端 `tests/postopt/side-metrics/tree-amdgcn.ll`（gfx906，同 SSA 平衡树）：

| 候选 | 类型 | Δ | uniform(F,T) |
|---|---|---:|---|
| B1:B2:B3 / B4:B5:B6 | 同层 B2B | 24 | +3 / +3 |
| B0:R2:R3 | 两棵子树 R2R | 42 | −8 / −8 |
| B0:E*_7（opt-in） | 跨层级 R2B | 13～15 | −14～−16 |

guard 关闭时，原始和补丁版本的最终 IR 逐字节相同（`--cross-decision-leaves` 为 0 或 1 都一样）。原始默认枚举会给出 4 个跨层级 E 对，补丁默认枚举不再给出。`--max-uniform-loss 10` 拒绝全部 R2B；取 5 时贪心改为自底向上的计划，每一步两侧的 uniform gain 都 ≥ 0。

## 4. 合入前须在 musa 上确认

1. 用正式工具链重新构建，运行既有回归：vLLM 224 次融合、Map-Airy 16 次、TIGRE 的最终二进制 SHA 应与冻结版本相同；Hypersonic 显式 opt-in 后仍应是 4 对锚点、+92。
2. 每轮多一次父状态的 worker 查询，每个 trial 多两次 CloneFunction。用 Map-Airy/Reentry 记录搜索耗时的变化。
3. 在 Map-Airy state-8 上读出 `L1+L2`（7）与 `B3:E88_96:E5_96`（16）的 uniform gain，作为 `--max-uniform-loss` 的第一组校准数据。启用前，先在已知正例（vLLM、TIGRE）上确认 guard 不会拒绝已提交的融合。
