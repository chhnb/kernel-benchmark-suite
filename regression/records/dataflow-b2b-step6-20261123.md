# Dataflow B2B 第 6 步

在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 从 `ad1af16` 开始。NQU64 和 MapAiry 的四个角色分别从各自同一份冻结 IR 生成。改写后沿用默认清理、LLVM 24 裁决和贪心接受流程。

## 求解器与接入

- 将依赖和访存顺序边转为两侧的可达集合。两个配对存在相反方向的可达边时在 CP-SAT 加互斥。选中的配对形成长度更大的环时，记录环上的配对，添加 `sum(x_on_cycle) <= |cycle| - 1` 后重搜。用一个交替取自两侧的四配对环检查，两两互斥未排除它，加入见证约束后变为不可行。重搜保留已访问决策和已验证报价。
- 原模型先逐个取得 LLVM 报价，再建立精确目标表。超时只在已报价的子集优化会得到上界。本步在任何懒约束之前各跑一次目标松弛，记录 CP-SAT 的 `best_objective_bound`。以 join PHI 和 store 为存活根，遇到可被折叠吸收的 select 时停止反向传播。松弛只计确定存活且目标属性、类型足以决定报价的算术，以及必保留保护段的控制。配对只计一次，未配对的保护按场景分摊。原始区域保留为已知可行解。省略其余指令、select、流出和其他筛选约束，因此取得的下界对后续删除解的模型有效。未确定的目标、指令或上下文项不进入松弛。[LLVM 24 固定版本的 AMDGPU TTI](https://github.com/llvm/llvm-project/blob/6be16f356d3e/llvm/lib/Target/AMDGPU/AMDGPUTargetTransformInfo.cpp)
- 完成枚举后用逐项核对过的 LLVM 报价决定两个目标，按原有 §7.2 顺序和原始方案平手规则选择。删解包括单保护段限制、强制推测和生成器无法验证的形态。超时保存 incumbent，并为重新生成和比对报价预留时间。复跑每区域预算 600 秒。
- Anchor 提示记录原臂索引和对应方式，略过抽取阶段外置的内建值。将对齐投影到参考生成器的决策空间。分段布局尝试将未配对操作保护，线性布局补齐不能推测的未配对操作。不相容及非一对一的配对不进入初值。先向 LLVM 桥尝试此决策，再把变量写作 CP-SAT hint。投影可能无法在单段模型里复现 anchor 的多段布局。
- `dataflow-ilp` 共享 `dataflow-exact` 的抽取和回填。≤10 条操作调用参考求解器，其余在 60 秒预算内调用 ILP。LLVM 桥核对生成的 IR 和三场景报价，回填仍经过 LLVM12 verifier。未得到可用改写时走 anchor。已证明 §7.2 选择原始时直接保留。OR-Tools venv 的 `python3` 启动 ILP。候选日志保留处理方式、报价和原因。
- 特意用 MapAiry 的 12 指令区域 `97ae90e9ed6a` 测试可行解接入。60 秒内取得 `(21,21,21)`，CP-SAT 下界为 8。LLVM12 verifier、评估二次报价、回填后的真实 kernel 裁决和每侧 1,000 组解释器结果均通过。另用 NQU64 的 `80f0bef62b48` 检查 §7.2 保留原始的出口。
- 复跑 `6ecd5daad815` 时，报价请求越过搜索截止时刻，旧响应曾被当成重新发射响应。修复后在发出下一请求前读取在途响应。模拟延迟的独立测试覆盖了该情况。只对受影响区域重新运行 600 秒，其余有效复跑结果复用。
- 全部 441 次回归的两个完整三场景向量和旧结果一致。每个目标都通过语义差分。重新构建的评估器通过 34 个手写方案回归。
- 57 个超时区域复跑后，5 个新增双目标证明。其余 52 个均取得上下界，42 个有正下界。`6ecd5daad815` 的修复复跑返回最小 D 上界 81 和 §7.2 上界 96，两者下界均为 16。

## 回归与计量命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
bin="$llvm/lib/llvm-12/bin"
export LLVM_CONFIG="$bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib:/opt/rocm-6.3.3/lib"
export OPENBLAS_NUM_THREADS=1 PYTHONDONTWRITEBYTECODE=1
w="$PWD/build/dataflow-corpus/step6"
export PATH="$PWD/build/dataflow-corpus/step5/venv/bin:$PATH"
mkdir -p "$w"/{NQU64,MapAiry}
tools/build-llvm24-tti --search-only
tools/build-decision-greedy
cp build/llvm24-tti/reference_solver "$w/reference_solver"
python3 tools/dataflow_b2b/run_step6_solver.py "$w/solver" --jobs 88 \
  --reference "$w/reference_solver" --interpreter build/dataflow-corpus/step5b/interpret_region
python3 tools/dataflow_b2b/run_step6_solver.py "$w/solver" --phase retry --jobs 88 \
  --reference "$w/reference_solver" --interpreter build/dataflow-corpus/step5b/interpret_region
python3 tools/dataflow_b2b/check_costs.py build/llvm24-tti/evaluate_cost

gzip -dc regression/greedy-v1/inputs/41d0f06783569a08.ll.gz > "$w/NQU64/input.ll"
gzip -dc regression/greedy-v1/inputs/130d89d31e175129.ll.gz > "$w/MapAiry/input.ll"
for c in NQU64 MapAiry; do
  fn=evaluate
  [[ $c != NQU64 ]] || fn=_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i
  tools/run-llvm24-tti "$w/$c/input.ll" "$fn" > "$w/$c/original-tti.json"
  for role in anchor darm; do
    DECISION_GREEDY_JOBS=8 build/decision-fuse/decision-greedy "$w/$c/input.ll" "$fn" \
      "$PWD" "$w/$c/$role" --b2b-strategy "$role" --ir-snapshots compact
  done
  jobs=32
  [[ $c != NQU64 ]] || jobs=24
  DECISION_GREEDY_JOBS="$jobs" build/decision-fuse/decision-greedy "$w/$c/input.ll" "$fn" \
    "$PWD" "$w/$c/dataflow-ilp" --b2b-strategy dataflow-ilp --ir-snapshots compact
done

nqu="$HOME/simplify-v2/build/dp1-removal/nqu"
map="$HOME/v2-runtime/cases/mapairy/inputs/65539"
nqu_cpu="$HOME/simplify-v2/build/artifact-14b.5ZY6U4/source/artifact/runners/nqu-fixtures.cpp"
g++ -std=c++17 -O3 "$nqu_cpu" -o "$w/NQU64/nqu-fixtures"
"$w/NQU64/nqu-fixtures" "$w/NQU64/cpu"
cmp "$w/NQU64/cpu/input" "$nqu/baseline.input"
cmp "$w/NQU64/cpu/reference" "$nqu/baseline.output"
g++ -std=c++17 -O2 -DBOOST_MATH_STANDALONE -Icases/boost-mapairy/source/boost-math/include \
  cases/boost-mapairy/source/oracle.cpp -o "$w/mapairy-oracle"
"$w/mapairy-oracle" "$map/input.bin" "$w/MapAiry/cpu.bin"
cmp "$w/MapAiry/cpu.bin" "$map/reference.bin"

tools/dataflow_b2b/run_step6_gpu.sh NQU64 "$w"
tools/dataflow_b2b/run_step6_gpu.sh MapAiry "$w"
python3 tools/dataflow_b2b/collect_step6.py "$w" build/dataflow-corpus/step4a/extract_regions \
  "$bin/llc" tests/dataflow-b2b/results/step6-evidence.json.gz
python3 tools/dataflow_b2b/report_step6.py "$w" tests/dataflow-b2b/results/step6-evidence.json.gz
```

## 设备与分支归因

- NQU64 使用项目的三批 15 皇后 GPU 回放。CPU 独立重新计算 block 计数，生成的输入及参考逐字节相同。GPU 对每批每个结果字做检验，恢复的总解数为 2,279,184。计时为三次 dispatch 的 HIP event 时间之和。适配器把原有回放的窗口映射为第 4a 步的 3 个预热和 15 个测量窗口，保留回放自身的首轮设备预热。
- MapAiry 使用 65,539 元素的冻结概率输入，重新生成 long-double CPU oracle。GPU 时间为单次 dispatch。两个 case 都用第 4a 步的四角色平衡轮换、12 轮、轮内与跨轮中位数、固定种子的 10,000 次 bootstrap。
- NQU64 首次 rocprof 用 mangled symbol 过滤得到空表。复跑取消采集端过滤，解析时按 demangled 名称保留目标 kernel dispatch，并排除运行时清零 kernel。统计最后 15 个计时窗口。时间由 BeginNs 和 EndNs 得到。记录实际 dispatch 的 wave 数和 HIP occupancy 的静态驻留上限。gfx906 的现有指标未提供动态占用率。
- 反汇编用最终 HSACO。以相同后端选项生成 LLVM12 带基本块注释的汇编，将机器基本块与 HSACO 地址对照。以谓词的 SSA 操作、类型和常量签名追踪到最终 IR，要求唯一匹配才归因到区域，无法对应的保留原始位置。exec 指令计数包含显式读写 exec 或 saveexec 的操作，条件分支另计。只在寄存器中运算的中间掩码不进入这个计数。两边代码对象不同的整核净变化可能包含其他贪心改写。
- 汇总最后一节手工核对 `gpu/{anchor,dataflow-ilp}.annotated.s`、对应 objdump 及第 19 步的 MapAiry `normalize-25-47-0/fused.ll`，确认 `%merged.bb5` 谓词合取的来源和最终地址。

[结果汇总](../../tests/dataflow-b2b/results/step6.md)
