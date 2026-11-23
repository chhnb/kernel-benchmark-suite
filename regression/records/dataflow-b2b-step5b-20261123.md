# Dataflow B2B 第 5b 步

起点为 `0f77309`，在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 运行。依照本步口径，第 5 步的 187 个可计价 small 区域全部通过。普通调用无报价的 `b670a987cbd0` 单列。

## 运行与口径

- 对全部 125 个 medium 区域用已构建的第 5 步 CP-SAT 求解器和相同的 LLVM 24 throughput worker，运行无约束最小 D 和 §7.2 目标。每个区域的搜索预算为 600 秒。证明以第 5 步单保护结构和现有生成器为范围。超时保留已报价的最好决策，未走完的列报价使其全局下界只能取非负费用给出的 0。
- 对全部 20 个合计不超过 14 条指令的区域并行运行 LLVM 参考枚举。比较无约束最小 D 的标量和 §7.2 的完整向量。不具备原始报价的区域退出数值比较。
- 对 diamond 以块索引显式调用现有 anchor 和 DARM 的试融入口，按原流程得到清理后 IR，再按同一评估器计价。沿用第 5 步的产物对照口径，逐区域证据另外保留现有裁决的 eligible 状态。triangle 两组对照均取原始 IR。
- `989fc49dfa138857002030b37e80a4ccfae0bb38` 的 LLVM12 输入含被升级的 lifetime 标记，逐指令行首先报顺序不一致。直接查看 LLVM24 worker 也证实 `quant_decide` 的 `accepted_cost` 为空，理由为 `opaque_call_cost_not_whole_callee_cost`。没有补估这个普通调用。
- DARM 的 `731e6cce7e1f`、`b5049a6c7989` 在末次 InstCombine 后保留了再运行 SimplifyCFG 时可推测的块。对照使用评估器的 `--after-cleanup` 给实际产物报价。求解中的强制推测筛选继续走默认严格模式。
- 语义回放为 C 真、假各 1,000 组。解释器补充了标量 `llvm.abs` 及最小有符号值的 poison 规则、标量平方根，以及固定向量常量与浮点内建函数的逐 lane 处理。需要重放的 incumbent 单独生成并核对其 T，然后做解释器验证。回放沿用原来的证明与间隙。
- 总计使用无约束 D 有最优证明并通过语义复核的区域。相对 anchor 的各计费项保留有符号增减，同时提供全可比样本净账和严格改善样本的净账。控制分项另外核对从 anchor 的条件分支变为无保护段的收益。

## 完成状态

- 53 个 diamond 中 15 个两目标均证明、38 个超时。72 个 triangle 中 52 个两目标均证明、19 个超时、1 个无报价。3 个超时 triangle 取得无约束 D 的证明，策略目标未出具证明。两目标均证明的 67 个区域通过两目标的语义复核。
- 20 个 ≤14 条指令的区域中，18 个有两边的证明且一致，1 个无报价。另一个 `de3e276c7858`（hipims）的参考枚举在约 96 秒完成。ILP 走完 503,040 个候选的枚举，得到 37,590 个有报价的方案，在目标求解阶段耗尽预算。两个 incumbent 分别为 `(22,22,22)` 和 `(25,18,18)`，均与参考最优一致并通过语义复核。
- `cf330aa86273` 的 ILP 子进程到外层截止时间仍未返回 incumbent。原始 T 为 `(81,39,81)`，汇总用它提供可行上界并标明来源。其余超时行使用返回的 incumbent。下界为 0 时，记录的是非负报价给出的 100% 相对间隙。
- 53 个 diamond 均有两种现有策略的清理后产物及报价。整体裁决中的 `eligible` 对 anchor 为 34 个、对 DARM 为 32 个。统计使用产物本身的区域报价，与第 5 步 small 对照保持同一口径。
- 56 个返回 incumbent 的超时区域中，52 个的两目标均通过语义复核，4 个遇到当前解释器未覆盖的 IR。区域 ID 和原因见汇总。用补充后的解释器另行复跑两目标已经证明的 134 份输出，均完成每侧 1,000 组对拍。评估器的 34 个微型方案回归全部通过。

## 命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
cfg="$llvm/lib/llvm-12/bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
export OPENBLAS_NUM_THREADS=1 PYTHONDONTWRITEBYTECODE=1
w=build/dataflow-corpus/step5b
py=build/dataflow-corpus/step5/venv/bin/python
mkdir -p "$w"

"$py" tools/dataflow_b2b/run_step5b.py "$w/run" --jobs 88 > "$w/driver.log" 2>&1
for tool in interpret_region evaluate_cost; do
  g++ $("$cfg" --cxxflags) -std=c++17 -fexceptions -O2 -Wall -Wextra \
    -Wno-unused-parameter -Wno-deprecated-declarations -Wno-template-id-cdtor \
    "tools/dataflow_b2b/$tool.cpp" \
    $("$cfg" --ldflags --libs core irreader analysis transformutils support --system-libs) \
    -o "$w/$tool"
done
python3 tools/dataflow_b2b/check_costs.py "$w/evaluate_cost"
python3 tools/dataflow_b2b/report_step5b.py "$w/run" \
  --evaluator "$w/evaluate_cost" --interpreter "$w/interpret_region"
```

汇总与逐区域发射、报价和状态见 [step5b-summary.md](../../tests/dataflow-b2b/results/step5b-summary.md) 和 [step5b-medium.json.gz](../../tests/dataflow-b2b/results/step5b-medium.json.gz)。
