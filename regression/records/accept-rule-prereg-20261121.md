# 静态接受规则预注册 v1

冻结日期为 2026-11-21。规则入口为 `decision-greedy --accept-rule tti|RIR|R|RB`，默认 `tti`。实现分别见 `tools/decision_greedy_main.cpp`、`tools/accept_rule.py`、`tools/accept_rule_ir.h` 和 `tools/llvm24_tti_main.cpp`。远端没有 `scoring/hot-loop-rule`，本次实现直接复用现有 LLVM24 worker 和 LLVM12 HSACO 构建路径。

每个候选是现有 Greedy 枚举、显式融合器成功改写并导出的候选 IR。单个结构候选的内部布局仍由原融合器挑选。与 Greedy 当前已提交的父状态比较。非法或 verifier 拒绝的改写仍无法接受。规则启用后，按新状态的规则目标值选最低的合格候选，同分沿用枚举顺序。全部规则只能依据本节固定的静态信息。合成或试运行中的 GPU 性能不用于确定系数。

| 规则 | 输入与接受条件 |
| --- | --- |
| tti | 原 Greedy。候选 TTI 必须同时严格低于同 cleanup 的 control 和当前父状态，沿用现有盈利性判断与排序 |
| RIR | 固定 LLVM12 `opt -O3`，以 LLVM24 LoopInfo、ScalarEvolution 和目标感知 UniformityAnalysis 统计。热循环加权的 AS3 访存、AS1 访存、发散运算与发散条件分支之和严格下降，估算 VGPR 峰值不增。另记录一致运算 |
| R | 父与候选各生成 gfx906 HSACO，使用实际代码对象的元数据和指令。通过硬约束后，热循环加权 VALU、LDS、条件分支总量严格下降 |
| RB | 硬约束同 R。把资源账换算成 CU 资源周期。父状态的最大周期资源若有并列，取整个并列集合。该集合在新状态的最大周期必须严格下降，其余资源不得超过这个新值 |

## 循环、数据流和指令口径

- 只对自然循环内的块累计热循环账。循环层用 SCEV 的精确小常数 trip count，未知层用 8。块权重为各包含循环层因子的乘积。全部未知时等于 8 的深度次方。无自然循环时热循环账为零。
- RIR 对 load、store、原子 RMW、cmpxchg 和可能访存的指针实参按地址空间计数。同一指令可命中 AS1 和 AS3，命中后只计入访存类别。其他非 PHI、非调试、非终结指令按定义发散性计为发散或一致，void 指令按操作数使用。条件分支与 switch 使用终结指令的发散性。寄存器压力以 CFG 活跃集合估算，PHI 的输入在前驱边上生效；每个活跃发散 SSA 值按类型位宽向上取整到 32 位寄存器。取热循环内指令边界的最大总和。
- R/RB 按 HSACO 中目标函数符号范围读取真实反汇编。用 Vega SOPP 相对分支位移恢复 CFG，取目标支配源的回边并向前驱闭包形成自然循环。O3 后用 LLVM12 instnamer 提供稳定名称，再用同输入的汇编块符号和 IR 名称把机器循环头映射到 SCEV trip count。没有直接映射时，该循环层用 8。七类计数为 VALU、SALU、LDS、全局访存、标量访存、条件分支和 EXEC 操作，每条指令只归入一类。等待、屏障和无条件分支没有计入七类资源账。寄存器与 lane 硬约束使用整函数范围。

## R/RB 硬约束和编译预筛选

- VGPR、SGPR spill 分别不得增加。整函数 readlane 和 writelane 各自不得超过父状态的 110%，父状态为零时要求仍为零。
- 静态 occupancy 为按 VGPR、SGPR、静态 LDS 和完整工作组约束计算的每 CU 驻留 wave 数。使用代码对象声明的 required workgroup size，缺省时以声明的 max flat workgroup size 为假设。gfx906 使用 wave64、4 SIMD/CU、10 wave/SIMD、每 SIMD 256 VGPR 和 800 SGPR，分别按 4/16 个寄存器分配，LDS 按 512 字节分配，容量 64 KiB，单 CU 最多 16 个需屏障资源的多 wave 工作组。新值不得低于父状态。无法提取所需资源信息时该规则拒绝。
- TTI 预筛选只作用于 R 和 RB。用 **throughput** 口径的候选减当前父状态。**亏损严格大于 128** 或无有效报价时，跳过机器编译。128 是覆盖规定的 PCM32 +124 的最小二次幂。EPYC 上空缓存的 SRAD16、TPACF、Map-Airy、vLLM 单状态 O3、HSACO 和汇编映射的编译耗时约 0.165、0.286、0.340、0.349 秒。端到端静态提取为 0.212–0.441 秒。父状态按输入内容缓存，因此每过滤一个候选主要节省一份候选构建。基于该开销量级，将闸门贴近已知必须覆盖的 +124，避免为更大亏损扩大编译队列。RIR 对每个导出的合法候选计算，跳过机器编译。非 AMDGPU 目标的 R/RB 为不支持，算作拒绝并报告原因。

## RB 周期换算

这些是硬件发射或数据通路的周期下界。忽略 cache miss、bank conflict、依赖和实际 wave 路径。由 ISA 文档确定常量，系数与上述编译耗时无关。

| 资源 | 估计周期 |
| --- | --- |
| VALU 和使用向量通路的 EXEC 操作 | wave64 / (4 SIMD × 16 lanes) = 1 个 CU 发射周期 |
| SALU、标量访存、使用标量通路的 EXEC 操作 | 共享标量发射槽，每条 1 个周期，三项加总 |
| 全局访存 | 每条 1 个 VMEM 发射周期 |
| 条件分支 | 每条 1 个 Branch/Message 发射周期 |
| LDS | 每条取 1 与 wave64 × 每 lane 传输字节 / 128 的较大者。128 = 32 bank × 4 字节。双传输按两个元素，未带宽度的队列及跨 lane 操作按一个 dword |

来源为 [AMD Vega 7nm ISA 70655](https://docs.amd.com/v/u/en-US/vega-7nm-shader-instruction-set-architecture)、[AMD GCN 架构讲义第 29 页](https://dci.dci-gitlab.cines.fr/webextranet/_downloads/7ce42fb9fb3b40a6ebe4b5ba7d25b657/GCN_Architecture.pdf)、[AMD MI50 硬件规格](https://rocm.docs.amd.com/en/docs-6.3.1/reference/gpu-arch-specs.html)和 [LLVM AMDGPU IsaInfo](https://llvm.org/docs/doxygen/AMDGPUBaseInfo_8cpp_source.html)。

## 冻结和后续评估

本提交冻结版本 1 的四条判定、所有阈值、循环与硬件系数。提交后才运行 PCM32 第 10 步 R2R 的静态合理性检查。它与 NQU64、TPACF、此前区域审计 26 次、HLLD R2B #3 和 Landau R2R #17 一起按已见样本标记。后续若需要调整规则，使用新版本并按原版本保留已收集的评估。前瞻抽样和 GPU 测量待确认后执行。

## RIRv2 补充预注册

RIRv2 在 PCM32 第 10 步合理性检查之后、3B 样本收集之前加入。RIR v1 的 VGPR 峰值门槛没有考虑静态 LDS 和实际驻留限制。PCM32 第 10 步继续标为已见。v1 的计数、门槛和排序沿用原定义。

RIRv2 使用同一份 O3 IR、热循环加权工作量及 SSA 活跃 VGPR 估算。加权工作量必须严格下降，同时估算 occupancy 不得下降。gfx906 的每 SIMD 驻留 wave 数取以下三项最小值，允许 LDS 限制产生小数。SGPR 不参与估算。

- 架构上限为 10 wave/SIMD。
- VGPR 上限为每 SIMD 的 256 个 VGPR 除以向上取整到 4 个一组的峰值 VGPR，再向下取整。至少计一个分配组。
- LDS 上限按目标 kernel 及其直接可追踪调用引用到的已定义 AS3 全局变量，累计 DataLayout 分配大小，按 512 字节向上取整。以 64 KiB 除以 LDS 分配量并向下取整得到每 CU 的工作组数，乘每组 wave 数（线程数除以 64 向上取整），再除以四个 SIMD。工作组尺寸优先取 `reqd_work_group_size` 的三维乘积，其次取 `amdgpu-flat-work-group-size` 的上界。尺寸缺失时标记 `missing` 并采用 LDS 不限的估算。静态 LDS 为零也不限制驻留。

非 gfx906 的 RIRv2 返回不支持。资源规则见 [AMD Vega 7nm ISA 70655 §3.6.4–5](https://docs.amd.com/api/khub/documents/QCer_iui4EP~tr~Xlf4VGA/content)。
