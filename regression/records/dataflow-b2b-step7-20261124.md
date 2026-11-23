# Dataflow B2B 第 7 步

实验在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 从 `f4eda0a` 开始，跨越上海时间 2026-11-23 至 2026-11-24。使用冻结 manifest 中的输入。LUD8 额外重放以往实验的共同父 `lud8-identical-input.6VjBaq/shared.ll`，SHA-256 为 `a52a8746779c561db1be7bc66026508f909e9eeba2223c966d7fe201435782b9`。

## 追踪与代价

- 按 LLVM24 试验回执的 `fusion_plan.kind == B2B` 收集真实被评估的候选。使用每个回执的 `parent_ir`，覆盖 prepared IR 以及前一次提交的 IR。每个实际出现位置保留独立行。相同抽取 IR 和相同提示仅复用一次求解。可直接抽取的候选需要拥有和当时试验相同的两条分支边。带独立出口、需复制或者非直接臂的候选保留整核清理报价和试验位置，独立评估器对这些方案的区域代价无定义。
- 单独重放不附加标记的 anchor 和 DARM 候选，检查原角色的清理后整核报价复现真实轨迹。标记重放在输入的区域外操作上附加临时 ID，在根谓词上附加单独标记。引用同一 LLVM24 worker 的逐指令报价，对 C 真、假分别遍历可达块，并按 D/L/R 汇总。只在标记重放选中同一布局且整核价格相等时使用该重放。
- 区域清理后计价优先用完整保留区域外标记的上下文产物。若清理删掉或改写了外部标记，尝试在独立抽取 IR 上重放相同布局，按配对索引、对应方式、布局、段数、保护和截断等信息核对。没有可靠清理后对应的试验不参与遗憾统计。清理前报价仍保留在证据里。例如 PCM32 的 15 点分支代价在清理时消失，遗憾的最终统计使用清理后的值。
- ILP 调用第 6 步求解器，单个独立问题 120 秒。证明限于现有配对和生成空间。对尚未证明的结果，单列 incumbent 差值。路径实验用可比的最大最小 D 遗憾，在副本中替换一次候选，继续运行原 anchor 搜索。对齐前缀的提交目录、提交代价和同一替换父 IR，忽略重新解析生成的第一行 `ModuleID`。
- LUD8 两个入口样本清理后都从相同的 workitem/比较前缀执行到第一道 fence。原入口两臂的最后 store 之后就是该 fence/屏障。把这个共同窗口内的所有指令报价，并另记整个清理后 kernel。其他 LUD8 候选用上下文清理前的共同测量口径，避免丢失区域外标记后把不同区域混在一起。
- LUD8 的 DARM 值映射探针仅在临时编译的二进制打印映射，比较其输出的清理后 kernel TTI 与正常重放一致。保护分类取 DARM 成形时的 guarded gap 状态，select、保护段和流出数另记清理后入口窗口。ILP 临时 CLI 副本将上限扩到 1800 秒，其它逻辑和报价均沿用原实现。两份输入的 DARM 提示投影都能找到相同配对，单保护段生成器拒绝原样生成。此时提示用于搜索并从原始候选保留已知上界。
- 附加标记的第一次做法还标记了原臂上的 workgroup/workitem 内建量，使 LUD8 第一个方案的配对发生变化。去掉臂内标记，按外部值口径排除这些内建量，重新重放。最终的标记试验与正常轨迹的布局和清理后 kernel 代价一致。另一次预试用了清理前的遗憾选择路径，正式五案均用清理后重新挑选并复跑。

## 命令

1800 秒作为此次启动的预算过长。收到反馈后，在上海时间 00:27:26 确认两个进程的 CP-SAT 正在处理 SIGINT，发出信号让它们返回当前解。两条运行分别用时 1475.8 和 1475.7 秒，均返回已有最好解和下界。求解器的通用 `search deadline` 状态在本次代表提前结束。两条搜索各只找到一个可报价的改写，其余 513,691 和 335,450 个决策需要多个保护段。复跑脚本的默认预算改为 120 秒，1800 秒仍可显式指定。

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
cfg="$llvm/lib/llvm-12/bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
export OPENBLAS_NUM_THREADS=1 PYTHONDONTWRITEBYTECODE=1
w="$PWD/build/dataflow-corpus/step7"
py="$PWD/build/dataflow-corpus/step5/venv/bin/python"
mkdir -p "$w"/{lud8,lud8-common}
gzip -dc regression/greedy-v1/inputs/f362469c52c83af4.ll.gz > "$w/lud8/input.ll"
cp "$HOME/simplify-v2/build/lud8-identical-input.6VjBaq/shared.ll" "$w/lud8-common/input.ll"
for fn in _Z12lud_diagonalPfii _Z13lud_perimeterPfii _Z12lud_internalPfii; do
  for role in anchor darm; do
    DECISION_GREEDY_JOBS=8 build/decision-fuse/decision-greedy "$w/lud8/input.ll" "$fn" "$PWD" \
      "$w/lud8/$fn-$role" --b2b-strategy "$role" --ir-snapshots compact
  done
done
for role in anchor darm; do
  DECISION_GREEDY_JOBS=8 build/decision-fuse/decision-greedy "$w/lud8-common/input.ll" \
    _Z13lud_perimeterPfii "$PWD" "$w/lud8-common/$role" --b2b-strategy "$role" --ir-snapshots compact
done
for row in "DCT8 21a5ddb82636744c _Z27CUDAkernelQuantizationShortPsi" \
  "NQU64 41d0f06783569a08 _Z24solve_nqueen_cuda_kerneliiPjS_S_S_i" \
  "PCM32 db3b35287f1ef284 _Z3pcmPi" "SRAD16 ecf89ddfdc19aca3 _Z11srad_cuda_1PfS_S_S_S_S_iif" \
  "MapAiry 130d89d31e175129 evaluate"; do
  read -r case hash fn <<< "$row"
  mkdir -p "$w/$case"
  gzip -dc "regression/greedy-v1/inputs/$hash.ll.gz" > "$w/$case/input.ll"
  DECISION_GREEDY_JOBS=12 build/decision-fuse/decision-greedy "$w/$case/input.ll" "$fn" "$PWD" \
    "$w/$case/anchor" --b2b-strategy anchor --ir-snapshots compact
done

obj=build/llvm24-tti
common=("$obj"/{ir_pressure,b2b_anchor,b2b_anchor_observe,CFMelderUtils,InstructionMatch,RegionAnalyzer,RegionMelder,RegionReplicator,darm-artifact-bridge,darm-artifact-CFMelderUtils,darm-artifact-InstructionMatch,darm-artifact-RegionAnalyzer,darm-artifact-RegionMelder,darm-artifact-RegionReplicator}.o)
g++ $("$cfg" --cxxflags) -std=c++17 -fexceptions -O2 -Itools tools/dataflow_b2b/step7_context.cpp \
  "$obj/fusion_search.o" "${common[@]}" $("$cfg" --ldflags --libs all --system-libs) -o "$w/step7_context"
python3 tools/dataflow_b2b/build_step7_replay.py "$w/replay.cpp"
g++ $("$cfg" --cxxflags) -std=c++17 -fexceptions -O2 -Itools tools/decision_model.cpp "$w/replay.cpp" \
  "$obj/fusion_search.o" "${common[@]}" $("$cfg" --ldflags --libs all --system-libs) -o "$w/step7_replay"
python3 tools/dataflow_b2b/build_step7_darm_probe.py "$w/darm-probe.cpp"
g++ $("$cfg" --cxxflags) -std=c++17 -fexceptions -O2 -DFUSION_DETERMINISTIC_REGION_ORDER \
  -DFUSION_PACKAGED_LLVM12 -Itools -Itools/darm_pair_engine "$w/darm-probe.cpp" \
  tools/fusion_search_llvm24_main.cpp "${common[@]}" $("$cfg" --ldflags --libs all --system-libs) -o "$w/darm-probe"

"$py" tools/dataflow_b2b/measure_step7.py "$w"
python3 tools/dataflow_b2b/measure_step7.py "$w" --replay
python3 tools/dataflow_b2b/measure_step7.py "$w" --context
python3 tools/dataflow_b2b/replay_step7.py "$w"
"$py" tools/dataflow_b2b/run_lud8_step7.py "$w" --seconds 1800
python3 tools/dataflow_b2b/report_step7.py "$w"
```

[汇总和压缩证据](../../tests/dataflow-b2b/results/step7.md)
