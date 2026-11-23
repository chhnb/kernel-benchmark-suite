# Dataflow B2B 第 2 步

起点为 `7bcd0d74f59dace30c990f3b9c2a89e263be5d85`，工作目录为 epyc 上的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b`。

## 语料库与计费

按源 IR 的 SHA-256 合并确认为同一输入的项目 case 别名，保留原名和来源。目录对应不同 IR 时用 block size 或 SHA-256 前缀区分。主表按结构和源文件哈希的组合计数，快照按 run 记录最早步骤。921 条来源对应 912 个独立源文件哈希、4,378 个结构和 376 个 B2B 文件。原始出现次数为 111,628。逐条复核了源索引、两份 inventory 的 B2B 集合、`distinct_sources` 和 `first_seen_step`。全部 376 个 B2B Fold 字段为布尔值，抽取件通过 LLVM 12 verifier。

LLVM 12 的安全性判定和 Fold 条件由 extractor、evaluator 与 solver 共用。代价表中新加的 intrinsic 数值是本步的抽象假设。lifetime 标记为 0，FMA 和 `llvm.sqrt.f64` 为 2，AMDGPU image sample 为 4，其余列出的 intrinsic 为 1。普通调用和未列出的 intrinsic 拒绝 Fold；缺少吞吐代价时，评估器也拒绝给出 T 向量。多返回值的末尾写回作为输出 ABI 排除；原始区域用 `--original` 应用 Fold。融合方案直接识别 C 路径和两路 join PHI，条件不是 C 或其反值时报不支持。

手写 34 个方案 IR，覆盖 16 个微型用例（08、09 各有两个边界变体）。全部方案通过 verifier，计费与既有 `expect.json` 完全一致。未出现需要改手算或评估器的数值差异。

## 搜索与对照

当前求解器枚举 R1/R2/R3 配对以及各未配对操作的 R5/R6 选择，将 R6 调度到同一个剩余菱形或三角形。它支持共享输入 select、直接合流、带 poison 的流出值和依赖允许的交叉配对。完成的候选经 LLVM 12 verifier 后调用同一个评估器。每种已观测 Pareto T 向量保留一个代表，遇到 10^7 次候选尝试或 600 秒停止。

当前实现仍缺任意多保护段调度、全部流出合并放置、同一代价向量下的所有方案，以及完整的 S_loc 重写闭包。因此 16 个微型用例和 188 个 small 区域都标为未完成。微型用例的已观测前沿代价向量与手算一致，`expect.json` 的 `enumeration` 保持 `partial`。开发中 02 等用例曾因 PHI 使用了保护段之后才能计算的值而无法验证，已改为先合流流出值、再选择结果。最终运行没有候选 verifier 失败。

主机差分复用微型检查器的确定性 C 驱动，对 C 两值各比较 1,000 次返回值及可观测内存。部分类型化指针输入改为主机地址空间，用有界数组和同类型别名输入测试。含 GPU intrinsic、convergent、未知内存访问边界、超出驱动类型范围以及有 undef/poison 的原始输出，保留具体不支持原因。以字节哈希比较含 undef 的输出会得到不稳定的结果，因此这类原始输入不作相等性断言。最终有 41 个前沿代表通过差分、202 个不支持，含微型用例；没有复现语义不一致。

`run_step2.py` 对全部 188 个 small 区域尝试现有 anchor 和 darm 的同父单次融合。调用发布的 `fusion-search-llvm24` catalog，再用明确的 split/left/right 调用，输出采用工具本身的 `darm-cfg-dce-instcombine` 清理。未修改现有工具。143 个区域没有唯一显式候选；其他拒绝和计费错误列入 JSON。原始代价缺失的 10 个区域涉及 fneg（6 个）、insertelement（2 个）、uitofp（1 个）和 call（1 个）。每个未完成区域的 ID、原因、候选、计时和比较结果见 `step2-small-raw.json` 和 `step2-small.tsv`。`best_found_T` 和差值基于已搜索的候选，尚无全局最优证明。

## 复现命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
work=build/dataflow-corpus
corpus=tests/dataflow-b2b/corpus
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
engine="$HOME/simplify-v2/build/artifact-14b.5ZY6U4/source/build/llvm24-tti"
cfg="$llvm/lib/llvm-12/bin/llvm-config"
opt="$llvm/lib/llvm-12/bin/opt"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
export PYTHONDONTWRITEBYTECODE=1

for tool in extract_regions evaluate_cost reference_solver; do
    g++ $("$cfg" --cxxflags) -std=c++17 -O2 -Wall -Wextra \
        -Wno-unused-parameter -Wno-deprecated-declarations -Wno-template-id-cdtor \
        "tools/dataflow_b2b/$tool.cpp" \
        $("$cfg" --ldflags --libs core irreader analysis transformutils support --system-libs) \
        -o "$work/$tool"
done
python3 tools/dataflow_b2b/collect_sources.py --work "$work" --output "$corpus"
python3 tools/dataflow_b2b/build_inventory.py --sources "$corpus/sources.json" \
    --extractor "$work/extract_regions" --opt "$opt" --work "$work" \
    --output "$work/step2-final" --jobs 4
cp "$work/step2-final"/{inventory-b2b.json,inventory-all.json.gz,SUMMARY.md} "$corpus/"
python3 tools/dataflow_b2b/check_costs.py "$work/evaluate_cost"
python3 tools/dataflow_b2b/run_step2.py --work "$work/step2-final-analysis" \
    --output tests/dataflow-b2b/results --solver "$work/reference_solver" \
    --evaluator "$work/evaluate_cost" --engine "$engine/fusion-search-llvm24" \
    --tti-worker "$engine/llvm24-tti" --clang "$llvm/lib/llvm-12/bin/clang"
python3 tests/dataflow-b2b/check-micro.py --clang "$llvm/lib/llvm-12/bin/clang"
```

评估器入口为 `evaluate_cost INPUT.ll COST_TABLE.json [--original]`。求解器入口为 `reference_solver INPUT.ll COST_TABLE.json OUTPUT_DIRECTORY`。上述运行的前沿代表 IR 位于 `build/dataflow-corpus/step2-final-analysis/{micro,corpus}/<case-or-id>/`。增量构建及分析使用新的输出目录。

## 与问题定义第二版的差异

以下核对基于 `5a63a7b1370fd5cd081b313c1a80157ad0e97152`。结果直接取自同一次 epyc 运行的输出目录 `tests/dataflow-b2b/results/`。`step2-summary.md` 为 4,507 字节，`step2-small.tsv` 为 39,774 字节，`step2-small-raw.json` 为 252,690 字节，均低于 5 MB，按原格式提交。

1. **访存和内建配对（§3.2–3.4、§9）**。v2 允许访问类型和地址空间相同、均非 volatile 或 atomic 的 load/store 配对，按地址对和（对 store）写入值对生成操作，同时保持每个线程的访存次数和副作用顺序。现有 `reference_solver.cpp` 的 `compatible` 排除全部 load/store 和 `CallBase`，也就排除了 v2 允许的同一内建函数、相同常量参数的配对。枚举配对前还要求两条操作各自通过 `speculate`，因此没有独立验证「在各侧保持原访存语义」的合法性路径。单个剩余保护结构内按原侧顺序发射操作。评估器对成品 IR 的 load/store 按场景报价，未核对源操作配对、每线程访存次数或跨保护段的副作用顺序。
2. **按不同值对计数（§3.3、§4.2、§5）**。v2 从输出和配对操作数构造需求集合 $D$，从配对和相同入口值构造产出集合 $P$，对 $D \setminus P$ 中每个不同值对按折叠后的 $\kappa$ 计价一次。求解器的 `choices` 确实复用同一有序 SSA 值对生成的 select 或 PHI，也局部折叠同值、部分常量及同条件嵌套 select，但未显式构造 $D$、$P$，也未校验每项未满足的需求恰好实现一次。评估器按输入 IR 中实际出现的 select 和可折叠的 join PHI 逐条计数，没有按原始值对去重。因此，重复的 select 或多个折叠后需要同一选择的 PHI 可能重复收费；原有计算里的 select 也会计入报告的 select 总数。
3. **保护段与流出（§4.4–4.5、§5）**。求解器只生成一个剩余保护结构，最多每侧一个保护段，并先后贪心发射可就绪的全体执行操作。它不能搜索同侧分成多段、段间夹有共享操作的调度，也未枚举流出值放置。评估器可以给手写的多个 C 守卫计价，同一菱形的左右侧共用一次分支费用；它按可达性标记和实际存活的二入边 PHI 计费，未按源值与所属保护段审计流出需求。
4. **SimplifyCFG 强制推测（§4.3、§6）**。现有评估器仅在 `--original` 模式应用一次 `foldFailure`，并要求只有一个条件分支。求解器会用这个模式检查生成的单个剩余保护结构；判定可 Fold 时丢弃该候选，依赖另一个 R5 选择覆盖相应方案。它未在生成结果上逐段强制推测，也未按 v2 的次序应用 SimplifyCFG 至不动点。Fusion 模式的评估器不会拒绝或重写仍可推测的守卫。共享的 `disallowedI1Input` 还允许按位取反模式，而 v2 的 i1 PHI 规则未列出该例外。
5. **合并标志、元数据及规范闭包（§4.1、§6）**。求解器要求指令的可选标志位相同，合并时克隆左侧并删除部分元数据，没有计算两侧标志和元数据的交集。R1 是可选枚举项，结构相同的计算未强制配对。生成器有局部 select 折叠和一次逆序死指令清理，未覆盖完整的 EarlyCSE/InstCombine 规范闭包，例如没有强制把 `select(C, a op x, b op x)` 算作对应计算的配对。评估器也未验证输入是否已处于这一规范形式。
6. **清理一致性（§6、§13）**。求解器运行 LLVM verifier 并调用评估器计费。外部脚本对支持的前沿代表执行主机差分检查。这些步骤分别核对 IR 合法性和抽样可观察行为。求解器和评估器均未对候选执行 v2 指定的 SimplifyCFG、EarlyCSE、DCE、InstCombine 流程，再比较清理前后的区域内 IR，也未报告模型与实测清理结果的偏差 $\varepsilon$。现有 anchor/darm 对照中的清理属于基线工具自身的流程。
7. **两阶段搜索和选择策略（§7–8、§13）**。现有求解器直接枚举配对和 R5/R6 组合，按成品计价，只保留每个已观测 Pareto 向量的一个代表，所有结果仍标为未完成。没有实现按折叠需求代价和保护段下界筛选前若干配对后再精确生成，也没有完备枚举可用于验证该筛选方法。输出只提供按 D 优先排序的前沿和要求 $T_D$ 严格改善、$T_L$ 与 $T_R$ 不退化的保守索引；未按条件来源或场景概率选择方案。
