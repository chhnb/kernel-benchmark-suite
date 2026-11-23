# Dataflow B2B 测试

问题和计费定义见 [PROBLEM.md](../../docs/dataflow-b2b/PROBLEM.md)，阶段结论见 [STATUS.md](../../docs/dataflow-b2b/STATUS.md)。

| 目录 | 内容和用途 |
|---|---|
| [micro](micro/) | 16 个微型 IR 用例及其期望。每个用例目录下的 `schemes/` 共含 34 个手写方案，用于核对计费和局部折叠边界。 |
| [corpus](corpus/) | 区域 IR、输入来源及区域清单。用 `inventory-b2b.json` 查找区域并定位 `regions/` 中的文件。 |
| [truth](truth/small.json) | 188 个 small 区域的真值，其中 187 个可计价。每种代价模式记录原始、最小 $T_D$、按 §7.2 选择、全部不同的 Pareto 代价向量和两种策略的对照。 |
| [context](context/candidates.json) | 116 条上下文候选与去重后的父 IR。每条记录保存候选键、块位置、所属轮次及历史报价。单步替换结果关联到实际替换的候选。 |
| [results](results/README.md) | 各阶段的报告和原始测量证据。 |

`truth/small.json` 的 `ir` 路径相对于 `corpus/`。引用的真实代价目标属性用于恢复原始编译目标；原始区域文件保留在语料库。三角形的 anchor 和 DARM 对照取原始区域。普通调用无报价的 `b670a987cbd0` 在两种模式中标为 unpriced。

`context/candidates.json` 的 `parent.ir` 路径相对于 `context/`，SHA-256 对应解压后的原始字节。父 IR 压缩保存，可用 `gzip -dc` 解压后配合候选的函数名和 `B…:B…:B…` 块索引重放。遗憾值可能来自尚未证明最优的历史可行解，`optimal` 记录证明状态。两份 LUD8 的 `best_known_T` 来自 DARM 同窗口实测。未测单步替换的候选保留空的最终 TTI，按 case 查阅第 7 步已测的替换结果可用 `single_replacement_by_case`。

## 回归测试

从仓库根目录运行。

```sh
tests/dataflow-b2b/run-regression.sh
```

脚本构建 LLVM12 搜索工具和参考求解器，按需构建 LLVM24 报价 worker。它依次检查微型 IR 和手写方案、376 个 Fold oracle、抽象和真实真值，以及 DCT8 的 dataflow-exact 整核 TTI。脚本逐项打印失败和各阶段耗时，并将构建日志和中间产物写到打印出的 `build/dataflow-regression/run.*` 目录。运行不需要 GPU。

默认工具链路径与 epyc 的固定环境相同。可用 `LLVM_CONFIG`、`LLVM12_LIBDIR`、`LLVM24_CONFIG` 和 `LLVM24_LIBDIR` 指向其他安装路径中的同版本工具链。用 `KBS_DATAFLOW_JOBS` 设置 Fold 和真值回归的并发数。
