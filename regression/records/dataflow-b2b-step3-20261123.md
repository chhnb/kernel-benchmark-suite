# Dataflow B2B 第 3 步

起点为 `21ca2a0caa308b5203259e23399101bb1334e8f9`。在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 运行。

## 强制推测规则和 oracle

按 LLVM 12.0.1 的 `FoldTwoEntryPHINode` 更新了问题定义和实现。模型先检查汇合块前驱和 PHI 个数，排除可直接简化的 PHI，通过其余 PHI 的入值反向遍历依赖，再用 LLVM 安全性和 SizeAndLatency 计价。只有第一个剩余 i1 PHI 参与二元运算限制。默认微型用例使用抽象代价，语料库运行显式选用 `--c-sl=real`。真实报价统一采用 gfx906 和 `+sramecc,-xnack`，沿用输入模块的数据布局。用同一个 gfx906 TTI 运行本步两条清理检查路径。工具按项目的选项关闭条件分支简化及公共指令上提、下沉，阈值设为 7，并反复运行 SimplifyCFG。额外的 EarlyCSE、DCE、InstCombine 各运行一次。[LLVM 12.0.1 源码](https://github.com/llvm/llvm-project/blob/llvmorg-12.0.1/llvm/lib/Transforms/Utils/SimplifyCFG.cpp)

先对 376 个原始抽取区域运行 oracle，预测与实测全部一致，16 个区域实际推测。此后才开始求解器的两阶段调整。最终运行验证了 25,050 个带守卫且通过 LLVM verifier 的生成候选，其中 small 档 19,923 个、微型用例 5,127 个，未发现预测偏差。用 WeakVH 跟踪原始守卫指令，检查清理后仍存在的指令是否进入所有路径必经块。没有实际操作被提到全体路径时，仅删除空块或分支不计为推测。每个原始区域的对照结果见 `step3-fold-oracle.json`。

两份 inventory 中 B2B 顶层 Fold 字段已更新。顶层 `fold_scope=extracted_region` 表示这是独立抽取函数上的实测。occurrence 中记录的源 CFG facts 保留其来源。变化如下。

| 区域 ID | 旧 | 新 | 原因 |
|---|---|---|---|
| `09239a0a1c3e906563e3d7f69509b39affe247d5` | true | false | 无 PHI 或没有可移动操作 |
| `0fe86869fdec238ea7d7985ef9108efeb2497c62` | true | false | 同上 |
| `12313062c67f1f6f0bdca391d7b33b316845b7c8` | true | false | 同上 |
| `3fb86534ef06fbcedb855140ab37d0b25059e467` | true | false | 同上 |
| `499fd4c8d2882103ce63752ba0341c0c8f12adc1` | true | false | 同上 |
| `5380fef61ac979d9d1cd4eeacf2afa82bee4264d` | true | false | 同上 |
| `92bea0bfd413b9cf1e3230516e6002fc25416c08` | true | false | 同上 |
| `ae44ba11b2562eac686d557661d0a9496575ecee` | false | true | gfx906 实测符合推测条件 |
| `f0f80d975e3540bdf11f952e4feddbbe3efdcf2e` | true | false | 无 PHI 或没有可移动操作 |
| `f166377cb45774086320092c6465aadd17b0ff12` | true | false | 同上 |

## 代价表和重计价

按要求给 fneg、insertelement、extractelement、uitofp、sitofp、fptoui、fptosi 增加抽象代价 1。前一步未能计价的区域中，九个获得真实 c_SL 模式下的 T。另一个区域包含无抽象吞吐代价的普通调用 `g_7_7` 和 `g_6_6`，保留明确失败原因。

| 区域 ID | 原始 T |
|---|---|
| `1bae2080fbe9064b81804403e6d26813359c003f` | (55, 51, 51) |
| `4691ec0c105801022e72f775009d892015e9257c` | (20, 9, 15) |
| `6fb506a6f70ecbaeca83b9c996e86011b6d417dd` | (55, 51, 51) |
| `74fc20b5ec4ff611c3d438a6e45703c11b787a62` | (23, 8, 19) |
| `9e181e8cd0f2b0456ccd5a95ca23e0eddeee65e3` | (17, 5, 16) |
| `b670a987cbd0b880da2265106c8e56fc5708a607` | unsupported |
| `cdd7f2ba84a3d0dd73db35b0acafcee20442d513` | (23, 8, 19) |
| `d3df5ecd243c1254b3987743f619db9727ea9097` | (17, 5, 16) |
| `daa252c4257499441151e25b02ea63f077d199de` | (23, 8, 19) |
| `ebb7e70a0716afe044f981e66a85e2c0e6de48d7` | (17, 5, 16) |

评估器识别并分别检查多个以 C 守卫的局部结构，拒绝仍可推测的生成守卫。全体路径执行的 C 选择按同一有序 SSA 值对去重，普通选择计入原操作。原始 Fold 路径对合流需求去重。仅从成品 IR 推断的 SSA 值对还无法校验所有源级 $D \setminus P$，例如生成后已折叠而无 select 的需求以及跨来源的等价值。

## 求解和验证的完成范围

- 配对阶段独立枚举一对一匹配和操作数对应，允许兼容、非 volatile 非 atomic 的 load/load 与 store/store。对每侧访存和有副作用的操作保留原顺序作为保守约束，构建 P、D，排除成环方案。当前 K 排序使用候选操作项之和作为乐观值，选择、守卫和流出以零估计。排序和配对计数仅用于当前搜索范围。
- 生成阶段枚举未配对操作的推测或保护，再生成 IR、验证和计价。现有生成器仍最多构造一个剩余守卫结构，未做任意多段调度、全部流出放置和规范闭包。188 个 small 区域的完备枚举数为 0，16 个微型用例保留 `partial`。16 个用例的已观测 Pareto T 向量与手算一致，34 个原有手写方案仍通过逐项计费检查。
- 有界解释器对每个前沿代表在 C 的两值各比较 1,000 组有效输入。模型按同名同参函数和同一抽样种子处理 GPU 内建量，模拟有界内存，区别跟踪定义值、undef 与 poison。原始无确定值的返回或存储字节不参与相等检查。Atomic 用单 lane 顺序模型并比较有序事件。所有 253 个前沿代表都通过了解释器差分，其中含微型测试。此验证的范围是抽样及所述内存模型。
- 清理一致性得到 54 个不变、199 个文本差异。按 opcode 计数先分类，逐方案的 opcode 和 CFG 变化见原始 JSON，完整差异在运行目录的 `*.cleanup.diff`。清理差异意味着规范闭包仍未完成。
- 对全部 small 区域按抽取后的基本块位置显式运行 anchor 和 darm。第 2 步没有候选的 143 个区域在两种策略中均得到 `unsupported_split_location`，两种策略另各有一个 `convergent_call_in_trial_scope`，其余 44 个均有代价。每个拒绝的区域 ID、显式块号、catalog 数量、拒绝原因见 `step3-small-raw.json`。
- 收益、K 漏失和 baseline 差距均基于当前已找到的代表。结果汇总 [step3-summary.md](../../tests/dataflow-b2b/results/step3-summary.md) 未将这些数据作为全局最优性结论。

## 命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
work=build/dataflow-corpus
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
cfg="$llvm/lib/llvm-12/bin/llvm-config"
engine="$HOME/simplify-v2/build/artifact-14b.5ZY6U4/source/build/llvm24-tti"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
export PYTHONDONTWRITEBYTECODE=1

for tool in extract_regions evaluate_cost reference_solver check_fold_oracle check_cleanup_fixpoint interpret_region; do
  g++ $("$cfg" --cxxflags) -std=c++17 -O2 -Wall -Wextra \
    -Wno-unused-parameter -Wno-deprecated-declarations -Wno-template-id-cdtor \
    "tools/dataflow_b2b/$tool.cpp" \
    $("$cfg" --ldflags --libs core irreader analysis transformutils support --system-libs) \
    -o "$work/$tool-step3"
done

python3 tools/dataflow_b2b/update_fold_inventory.py "$work/check_fold_oracle-step3" \
  tests/dataflow-b2b/results/step3-fold-oracle.json
python3 tools/dataflow_b2b/check_costs.py "$work/evaluate_cost-step3"
python3 tools/dataflow_b2b/run_step3.py --work "$work/step3-final" \
  --output tests/dataflow-b2b/results --jobs 6 \
  --solver "$work/reference_solver-step3" --evaluator "$work/evaluate_cost-step3" \
  --interpreter "$work/interpret_region-step3" --cleanup "$work/check_cleanup_fixpoint-step3" \
  --engine "$engine/fusion-search-llvm24" --tti-worker "$engine/llvm24-tti" \
  --clang "$llvm/lib/llvm-12/bin/clang"
```
