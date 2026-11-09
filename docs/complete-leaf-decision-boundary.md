# 完整叶子候选的决策边界修复

## 行为

LLVM24 搜索入口新增 `--cross-decision-leaves 0|1`，默认0。

- 默认：完整 E-leaf 候选的相邻判断必须都是 `icmp`/`fcmp` 与常量比较，且使用同一个 SSA 判别值。常量在左、在右均可。
- 不同 SSA 值（例如 `p` 与 `1-p`）、复合布尔条件或无法判定的形式，不自动进入完整叶子候选队列。
- `--cross-decision-leaves 1` 显式允许这些跨边界或无法归类的完整叶子候选；后续 SESE、合法性、verifier、局部审计和评分检查全部保留。
- 显式 `--split/--left/--right` 同样受约束，`tryPair()` 在实际父 IR 上重新核对，不能伪造候选字段绕过默认检查。
- 现有 B2B/R2R/B2R、G组和 vLLM 逻辑标签路径保持原有行为；没有全局禁止区域复制或某一种结构分派。

这是一条保守的 **IR 判别值边界**，不是完整恢复源码决策树的证明。不推导不同表达式的语义等价，不把所有无法归类的条件断言为不同源码决策。对已有融合组仍使用现有递归候选/逻辑状态；新增 E 路径每次在当前 IR 上重查边界，识别不出时需要显式选项，不能声称所有复杂 CFG 都自动覆盖。

## Map-Airy

回退候选 `B3:E88_96:E5_96` 的外层条件比较输入 p，下一层比较1−p，判别值不同，默认排除。原有下尾平衡树和 L1+L2 仍可枚举。它是通用判定，不依据函数名、block编号或测试输入。

## Hypersonic

L1+L2 的判断包含复合布尔值，超出默认的同SSA常量比较识别范围。既有多锚点 prepare.py 显式加入 `--cross-decision-leaves 1`。这表明用户选择了这项能力，不表示这些源码叶子事实上属于不同决策树。

## 测试

`tests/postopt/complete-leaf/check.cpp` 覆盖：同一判别值的完整 B2R/R2R 可以融合并通过 verifier；不同判别值默认不枚举；手动构造显式候选不能绕过；启用选项后仍能合法试融合；拒绝时父IR不变。既有 unsafe predicate 检查和CPU运行时等价测试继续执行。

`logical_region_state.cpp` 另加不存在单元的保护：严格相邻逻辑状态尚不支持的 E/G 单元直接跳过，不使用 map::at 抛出异常。没有据此把未知单元视作已证明相邻。

本轮重新生成 vLLM、Map-Airy，并复验 Hypersonic 指定区域；实际结果见后文。生产引擎没有回退，评分公式、TTI版本、清理和最终codegen未改。

## 验收结果

- Map-Airy：默认边界下完整搜索16次融合、1370次trial，停止于no_positive_candidate。第9次恢复L1+L2（收益7）。二进制SHA与冻结优胜版完全一致：`affe64a238c73c36aa5704f46b50becdd2f8d4902b355536fa83745bea098422`。
- Map-Airy随机混合输入GPU回归：完整输出通过，3批中位数24.480/24.640/24.640 μs，综合24.640 μs；本批baseline49.441 μs，耗时减少50.16%。candidate/reference为相同二进制，明确共用测量，不声称两份独立样本的性能恰好相等。准入曾在启动前拒绝两次，既有有界重试后成功，没有执行中失败。
- vLLM：重新生成224次融合，二进制与冻结版本以及本日已经通过随机64K/128K GPU验收的版本相同。本轮未重复GPU计时。
- Hypersonic：显式开启后，旧单锚点收益+2；多锚点仍为4对、22条前移指令、收益+92，IR除ModuleID外与既有 `outer-selector/multi.ll` 一致。本轮是IR/结构回归，没有重跑GPU，也没有消除旧runner异常的未定因边界。
- 完整叶子C++测试及CPU运行时等价检查通过；Git diff whitespace检查通过。

数据与详细日志在musa `regression/runs/20261110-decision-boundary/` 和 `regression/runs/20261110-decision-boundary-mapairy-gpu/`。临时生成输入已删除。Git仅保存代码、文档和小型结果收据。
