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
