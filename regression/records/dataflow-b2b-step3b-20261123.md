# Dataflow B2B 第 3b 步

起点为 `8e9c3a1`。在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 上运行。统计见 [step3b-summary.md](../../tests/dataflow-b2b/results/step3b-summary.md)，逐区域、逐方案数据见 [step3b-small-raw.json.gz](../../tests/dataflow-b2b/results/step3b-small-raw.json.gz)。

## 配对和调度

- 配对不再要求操作可安全推测。两个兼容操作配对后，每条原路径各执行一次合并操作。不能推测的未配对操作保留在对应保护段。每侧潜在有副作用或访存的操作沿用原始顺序依赖。
- 内建调用要求函数、调用约定、属性相同，且调用非 convergent、无 operand bundle、非 musttail。将 §3.2 的常量参数解释为 LLVM 标记为 `immarg` 的参数，此类参数必须相同。一般值参数可以接收先选择出的值，包括两侧传入不同字面量的情况。指定回归 `2f29337da1ee` 需要合并首参数分别为 6 与 4 的 `llvm.copysign.f32`，两参数都是普通值参数。
- 每组配对、操作数对应和未配对操作的推测/保护决策，使用子集 DP。状态为已调度操作集合和末段类别（全体、左、右）。每次调度一个依赖已满足的操作。相邻左右保护臂按左、右规范顺序编码，共用一次控制开销。两臂之间没有直接依赖，因此同一菱形的两臂可以按这一顺序枚举。遇到全体操作即结束当前保护结构。DP 回溯具体序列并生成 LLVM IR。评估器独立计得的分支数和控制代价都与 DP 结果比较。
- 对给定调度和流出集合，流出值在产生它的保护段出口做一次合流。出口支配所有后续合法段外使用，可复用同一 SSA 值。合流费用按不同流出值计一次，移动使用点或为不同使用者重建合流没有计费收益，因此省略对放置位置的枚举。不同调度可以改变哪些值流出，以及一个需求可直接通过 PHI 实现还是需要额外选择。本步的完备标签采用指定标准，即每组决策保留一个最少控制开销的具体调度。该标签的范围依赖于当前兼容及副作用依赖规则，也不蕴含对所有并列调度和本轮待确认清理规则的完备性。
- 控制计费和选择等其余计费使用原评估器。原始候选也参与前沿。验证使用现有 LLVM 12 verifier、Fold oracle 和解释器。解释器每个方向比较 1,000 组有界随机输入及内存效果。

## 结果和不变式

188 个 small 区域中，44 个 diamond 和 143 个 triangle 完成枚举。236 个前沿代表全部通过解释器差分。三个指定区域的求解器、anchor、darm 的 (T_D) 分别为 16/27/16、2/2/2、4/4/4。187 个可计价区域通过总体不变式。另一个 diamond `b670a987cbd0b880da2265106c8e56fc5708a607` 的 `g_7_7` 和 `g_6_6` 是普通调用，缺少抽象代价，无法计算 T。

triangle 的两组对照均取原始 T。diamond 复用第 3 步按块名指定候选而生成的已清理 IR，并用本次评估器重新计价，包含可恢复的对照配对数据。原始多输出区域的写回 ABI 由清理前 IR 或清单确定。清理折叠 GEP 或引入 bitcast 后，评估器沿输出参数的地址运算识别这些写回，避免把提取函数的输出封装计作区域访存。

## 清理导致的代价变化

236 个前沿代表中 52 个文本不变，170 个文本变化但 T 相同，14 个 T 变化。14 个全是 triangle 的原始区域代表。汇总逐项列出区域和 T，压缩 JSON 保存逐项 IR diff。

- 11 个方案把只在受保护路径使用的 GEP 从共同入口下沉到保护侧。计费减少发生在空侧的统一场景，分歧和执行 GEP 的一侧保持原价。8 个减少 (T_R)，3 个减少 (T_L)。
- 3 个方案同时下沉入口的 GEP，并消除同一保护侧里重复计算的 GEP，令 load 和 store 复用相同地址。三个场景各减少 1。
- 待确认的规则包括在操作及其所有使用满足合法下沉条件时，将单侧使用的纯地址计算归入该保护段，以及在同一支配范围内对相同基址、索引、类型和相关属性的 GEP 做公共子表达式消除。第 3b 步保留这些差异供确认。

## 命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
work=build/dataflow-corpus
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
cfg="$llvm/lib/llvm-12/bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu"
export PYTHONDONTWRITEBYTECODE=1

for tool in reference_solver evaluate_cost compare_cleanup_cost; do
  g++ $("$cfg" --cxxflags) -std=c++17 -O2 -Wall -Wextra \
    -Wno-unused-parameter -Wno-deprecated-declarations -Wno-template-id-cdtor \
    "tools/dataflow_b2b/$tool.cpp" \
    $("$cfg" --ldflags --libs core irreader analysis transformutils support --system-libs) \
    -o "$work/$tool-step3b"
done

python3 tools/dataflow_b2b/check_costs.py "$work/evaluate_cost-step3b"
python3 tools/dataflow_b2b/run_step3b.py --work "$work/step3b-final" \
  --baselines "$work/step3-final" --solver "$work/reference_solver-step3b" \
  --evaluator "$work/evaluate_cost-step3b" --cleanup "$work/compare_cleanup_cost-step3b" \
  --interpreter "$work/interpret_region-step3"
```

34 个手写微型方案的计费回归通过。small 档枚举 35,821 个生成候选，DP 与评估器的分支和控制代价比较无不一致。Fold oracle 检查 34,751 个带保护的生成候选及其中 50,560 个保护段，预测与运行结果全部一致。

另使用 epyc 上的临时程序 `build/dataflow-corpus/test-schedule.cpp`，固定种子 1327，生成 1,000 张至多 7 节点的无环图，用全排列筛选合法拓扑顺序并比较最少保护段数。重建序列也逐项检查依赖和开段数。附加两例分别检查左右两臂共用一次开销，以及共同操作隔开同侧两段。全部通过。

```sh
g++ $("$cfg" --cxxflags) -std=c++17 -O2 -I. "$work/test-schedule.cpp" \
  $("$cfg" --ldflags --libs support --system-libs) -o "$work/test-schedule"
"$work/test-schedule"
```
