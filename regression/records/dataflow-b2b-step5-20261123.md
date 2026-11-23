# Dataflow B2B 第 5 步

从 `e2b4ef6` 开始，工作目录为 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b`。运行结果见 [汇总](../../tests/dataflow-b2b/results/step5-summary.md)。

## PCM32 诊断

复用第 4b 步的最终 IR、HSACO、逐步 trial JSON 和 profiler CSV。对最终 HSACO 计数。用相同 LLVM12 后端另输出带循环和基本块注释的汇编以跟踪机器块。用 HSACO notes 核对寄存器用量及溢出。逐步提交对照使用冻结的第 4b 步区域哈希和第 3b 步独立区域结果。诊断未修改 PCM32 kernel、融合策略或计时。

## CP-SAT 实现与范围

- epyc 的 Python 3.13 venv 可安装 OR-Tools 9.15.6755，使用其 CP-SAT。条件来源由调用方传入。抽取函数已经把原条件变为参数，函数内无法还原其来源。[OR-Tools CP-SAT 文档](https://developers.google.com/optimization/cp/cp_solver/)
- LLVM bridge 与参考枚举复用同一个 `compatible`、投影前依赖、代码生成、Fold 检查和代价评估。CP-SAT 自己枚举配对和推测／保护决策。成对拓扑序号相等，依赖边至少相差一，逻辑蕴含代替显式 big-M。规范化到最小拓扑序号，消除同一配对和保护组合的重复序号见证。
- p、d、s 通常只约束需求关系。保护臂与产生段外需求的值通过 y、G、e 表达。实际 SSA 合流可能替代某个 select，也可能由多个需求共享一个流出。每一组离散决策用现有生成器输出 verifier 可接受的 IR，精确报价为指令、选择、控制、流出四组列。每个场景的 T 是这四项的线性和。允许值表将离散决策关联到其唯一报价列。这样保留了折叠、DCE、PHI 共享和 LLVM24 上下文相关报价；代价是需要先检查全部决策列，尚无按操作报价的稀疏、可扩展 ILP 公式。
- 单段版本在溢出到多保护结构时排除当前决策。small 用参考 DP 重建调度。若超过其暴力 DP 的 16 节点范围，桥提供把所有保护操作缩成一个顶点的单段调度，检测保护、公共、再保护的依赖。对强制推测由现有 Fold 检查拒绝。每次排除写禁配子句，在收集价格列后重新执行目标求解。候选级 `iterations` 逐次记录检查，目标的 `cp_sat_solve_calls` 另计。两个模式各检查 35,821 个组合、定价 6,546 列；各排除多段 14,653、强制推测 14,622 列。
- 分别求最小 D 与 §7.2 目标。工作组统一的主目标为 max(L,R)。数据相关时施加统一场景约束。平局遵循参考输出顺序与保留原始的规则。选中向量再次生成并以评估器确认，解释器在 C 两值各用 1,000 组输入。两种模式合计 748 个目标输出均通过语义差分（含选择相同 IR 的重复目标）。
- 600 秒预算用于报价和两次目标。报价阶段提前结束时，报告已报价最优候选和保守下界 0，间隙按当前目标计算。该下界只依赖非负 TTI 和抽象计费；没有覆盖未定价决策列的更紧界。medium 门槛未达成，尚无该档的性能和超时实测。

## small 门槛

第一次用未经补充的抽取 IR 跑 LLVM24 参考枚举，181 个定价完成。六个没有 `target-cpu`，一个普通调用未定价。三个 HiPIMS-HLLC libdevice 抽取使用原始 `start.ll` 中父 kernel 的 sm_70 与 `+ptx32,+sm_70`，沿用 worker 的旧 PTX 兼容调整。三个 vLLM helper 使用 `cases/vllm-quant/recipes/llc.json` 的 gfx906 及 SRAM ECC、XNACK 配置。只给六个工作目录内副本补充属性，对照双方使用同一份副本。

最终 44 个 diamond 和 143 个 triangle 在抽象和真实模式下的最小 D 与 §7.2 向量均一致。唯一的 diamond `b670a987cbd0b880da2265106c8e56fc5708a607` 在第 3b 步缺少抽象真值。独立抽取只保留 `g_7_7`、`g_6_6` 的普通调用声明，LLVM24 拒绝把调用点的 TTI 充当被调用函数总价。其原始 TU 中虽有实现，把它们内联会改变该区域的操作图和与第 3b 步的对照基础。现有计价保留未支持状态，两套模式的数值验收均为 187/188。按照用户定义的门槛，未启动任何 medium 求解或对照。

small 对照复用第 3b 步抽象结果。真实报价重放已清理的第 3 步 anchor／DARM IR，三角形取原始向量。全部 34 个手写微型方案继续通过评估器计价。前 15 名按 small 的真实代价效果列出。

## 命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
w=build/dataflow-corpus/step5
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
export LLVM_CONFIG="$llvm/lib/llvm-12/bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
export OPENBLAS_NUM_THREADS=1 PYTHONDONTWRITEBYTECODE=1
mkdir -p "$w"
python3 -m venv "$w/venv"
"$w/venv/bin/pip" install ortools==9.15.6755
tools/build-llvm24-tti --search-only
python3 tools/dataflow_b2b/check_costs.py build/llvm24-tti/evaluate_cost

region=tests/dataflow-b2b/corpus/regions/d23a7c228c5b39f95910f0b1d4eb8b9318e5c775.ll
"$w/venv/bin/python" tools/dataflow_b2b/ilp_solver "$region" \
  docs/dataflow-b2b/COST_TABLE.json "$w/installed-smoke" --cost=real --condition-source=data

# The gate returns 1 when it records any unavailable row.
"$w/venv/bin/python" tools/dataflow_b2b/check_step5_small.py "$w/gate-final" \
  build/llvm24-tti/reference_solver build/llvm24-tti/interpret_region --jobs 18
python3 tools/dataflow_b2b/summarize_step5.py "$w/gate-final" \
  build/llvm24-tti/evaluate_cost build/dataflow-corpus/step3-final \
  tests/dataflow-b2b/results/step5-summary.md tests/dataflow-b2b/results/step5-small.json.gz

pcm=build/dataflow-corpus/step4b/pcm32
rocm=/opt/rocm-6.3.3
for role in anchor dataflow-exact; do
  "$rocm/llvm/bin/llvm-objdump" -d --mcpu=gfx906 "$pcm/gpu/$role.hsaco" > "$w/$role.s"
  "$rocm/llvm/bin/llvm-readelf" --notes "$pcm/gpu/$role.hsaco" > "$w/$role.notes"
  "$llvm/lib/llvm-12/bin/llc" -O3 -march=amdgcn -mcpu=gfx906 -mattr=+sramecc \
    -amdhsa-code-object-version=4 -filetype=asm "$pcm/$role/final.ll" -o "$w/$role.annotated.s"
done
```

正式对拍先用同一编译选项构建在 `build/dataflow-corpus/step5` 的 LLVM12 reference_solver、evaluate_cost，以及已链接的 `build/dataflow-corpus/interpret_region-step3`。默认目录的构建命令如上，正式矩阵只运行两种 small 模式。
