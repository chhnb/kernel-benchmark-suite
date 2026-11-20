# 按静态 occupancy 切换 TTI 的离线评测（2026-11-20）

从 experiment/tti-memory-42 的 `8f29cb7` 建立 scoring/occupancy-aware-cost。使用现有 LLVM24 TTI worker，显式设置 `FUSION_TTI_MODE=llvm24`、`FUSION_TTI_MEMORY_COST_PROFILE=native`，分别设置 `FUSION_TTI_COST_KIND=throughput`、`latency`。未运行新的 GPU 试验。

## 1. 发布产物的静态 occupancy

发布清单 16 份 GPU 对象均与清单 SHA-256 一致。工作组取冻结输入或发布 runner 的实际 launch。gfx906 采用每 CU 4 个 SIMD、每 SIMD 10 个 wave64 槽、每 SIMD 256 个 VGPR 和 800 个 SGPR 的资源上限。VGPR/SGPR 分别按 4/16 向上取整，每组静态加动态 LDS 按 512 B 向上取整，CU 预算 64 KiB。每组 wave 数取线程数除以 64 向上取整。将寄存器 wave 上限换算成完整工作组后，与 LDS／硬件工作组上限取最小值。最后用常驻组数乘每组 wave 数再除以 4，得到平均 wave/SIMD。此值为静态上限，未计入 wave 调度、scratch 带宽与内存系统动态影响。 [LLVM 12 AMDGPU 资源计算](https://github.com/llvm/llvm-project/blob/llvmorg-12.0.1/llvm/lib/Target/AMDGPU/Utils/AMDGPUBaseInfo.cpp#L331-L457)

SasPoint5 和 HiPIMS-George 发布件是 sm_86 cubin。用冻结 PTX 和原 ptxas 带 `-v` 重建，cubin 字节相同。按 48 warp/SM、16 blocks/SM、64K 寄存器，寄存器按每 warp 256 个取整，报告 blocks/SM 与 warps/SM。两例没有 shared memory 约束。SRAD32 原冻结件上限 256，实际需要 1024，标为无法启动。表中同时列出独立冻结的 wg1024 版本。 [NVIDIA Ampere 资源上限](https://docs.nvidia.com/cuda/ampere-tuning-guide/index.html#occupancy) · [寄存器分配粒度及 ptxas](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#calculating-occupancy)

| Case | 架构 | 线程/组 | LDS 或 shared：静态+动态（B） | VGPR/SGPR 或 CUDA registers | 组/CU 或 blocks/SM | 平均 wave/SIMD 或 warp/SM | 限制 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| vLLM 64K / 128K | gfx906 | 64 | 512+0 | 55/76 | 16 | 4.0 | VGPR |
| TIGRE | gfx906 | 729 | 0+0 | 44/50 | 1 | 3.0 | VGPR |
| Map-Airy | gfx906 | 256 | 0+0 | 75/46 | 3 | 3.0 | VGPR |
| HLLD | gfx906 | 128 | 0+0 | 134/32 | 2 | 1.0 | VGPR |
| NQU64 | gfx906 | 64 | 10496+0 | 10/22 | 6 | 1.5 | LDS |
| MS32 | gfx906 | 32 | 0+0 | 34/44 | 28 | 7.0 | VGPR |
| PCM32 | gfx906 | 32 | 65536+0 | 23/24 | 1 | 0.25 | LDS |
| SRAD16 stage1 | gfx906 | 256 | 6144+0 | 19/30 | 10 | 10.0 | LDS、硬件波槽 |
| SRAD32 stage1，原冻结件 | gfx906 | 1024 | 24576+0 | 20/30 | — | — | 启动上限 256 < 1024 |
| SRAD32 stage1，wg1024 | gfx906 | 1024 | 24576+0 | 19/30 | 2 | 8.0 | LDS、硬件波槽 |
| Landau mixed / coherent | gfx906 | 256 | 0+0 | 66/30 | 3 | 3.0 | VGPR |
| SW2D | gfx906 | 1024 | 0+0 | 64/104 | 1 | 4.0 | VGPR、SGPR |
| CED | gfx906 | 256 | 0+1296 | 14/18 | 10 | 10.0 | 硬件波槽 |
| TPACF | gfx906 | 128 | 0+3072 | 16/104 | 14 | 7.0 | SGPR |
| SRAD stage2 256 / 1024 | gfx906 | 256 | 5120+0 | 16/26 | 10 | 10.0 | 硬件波槽 |
| SasPoint5（三个输入） | sm_86 | 256 | 0+0 | 36 | 6 | 48 warp/SM | 寄存器、硬件波槽 |
| HiPIMS-George | sm_86 | 128 | 0+0 | 130 | 3 | 12 warp/SM | 寄存器 |

## 2. PCM32 第 10 步 R2R

只用 `pcm32-r2r-ir-20261120` 已归档的三对 IR。差值为融合后减对照，正值代表模型预测变慢。

| 阶段 | throughput 前 → 后（Δ） | latency 前 → 后（Δ） |
| --- | ---: | ---: |
| 原始 | 1264 → 1673（+409） | 1617 → 1917（+300） |
| cleanup 后 | 1262 → 1387（+125） | 1616 → 1665（+49） |
| O3 后 | 1272 → 1396（+124） | 1612 → 1661（+49） |

以下报价在三对 PCM32 IR 中一致。

| IR 指令 | throughput 单价 | latency 单价 |
| --- | ---: | ---: |
| LDS load | 1 | 4 |
| LDS store | 1 | 1 |
| select | 1 | 1 |
| PHI | 1 | 0 |
| 条件分支 | 7 | 7 |
| 无条件分支 | 4 | 4 |

O3 后切换 latency 缩小了 75 分差。LDS load 单价 1→4，14 条减少的 LDS load 额外贡献 42 分。PHI 单价 1→0，消去 R2R 多出 33 个 PHI 的分数。LDS store 仍计 1。两版的实际 occupancy 都只有 0.25 wave/SIMD。Latency 在三个阶段仍判亏，与 GPU 的 5.74% 同父收益方向相反。 [已验证的同父 GPU 消融](https://github.com/chhnb/kernel-benchmark-suite/blob/617b52a96a44a4c6a93ce5cc52e61c1e9ede430b/regression/records/cleanup-extended-20261120.md) · [运行时 LDS 计数](pcm32-r2r-runtime-20261120.md)

## 3. 九条历史转移

对 NQU 后续记录使用的同一份评分 IR 重算。Throughput 的九对绝对分数全部复现。GPU 方向用既有比值相对 1 的符号。Occupancy 切换规则以父状态的静态 wave/SIMD 为准，低于 2 时父子均用 latency，否则父子均用 throughput。这样同一对 IR 用同一标尺。阈值 2 的依据是要靠同一 SIMD 的其他就绪 wave 覆盖一个 wave 的 LDS 或全局访存等待，至少要有第二个 wave 可切换。能遮蔽多少延迟还取决于依赖链、可并行访存和调度，2 是本实验固定的启发式。另核对了父子任一侧低于 2 就统一用 latency 的判定。 [延迟隐藏机制](https://rocm.docs.amd.com/projects/HIP/en/latest/understand/hardware_implementation.html#latency-hiding-through-multithreading) · [转移与 GPU 来源](https://github.com/chhnb/kernel-benchmark-suite/blob/14775f2/regression/records/nqu-second-fusion-20261120.md#2-跨转移的机器码静态变化)

| 转移 | GPU 子/父 | 平均 wave/SIMD 父 → 子 | throughput Δ | latency Δ | 按 occupancy Δ |
| --- | ---: | ---: | ---: | ---: | ---: |
| NQU P→C | 0.87383 | 1.5 → 1.5 | +2 ✗ | +13 ✗ | +13 ✗ |
| NQU G→G1 | 0.87145 | 1.5 → 1.5 | -8 ✓ | -8 ✓ | -8 ✓ |
| NQU G→G2 | 0.87073 | 1.5 → 1.5 | -7 ✓ | -7 ✓ | -7 ✓ |
| PCM32 R2R #10 | 0.94261 | 0.25 → 0.25 | +125 ✗ | +49 ✗ | +49 ✗ |
| HLLD R2B #3 | 1.18301 | 2.0 → 1.0 | -41 ✗ | -48 ✗ | -41 ✗ |
| Landau coherent R2R #17 | 1.02055 | 2.0 → 3.0 | -130 ✗ | -182 ✗ | -130 ✗ |
| NQU DP2 #3 | 1.04460 | 1.5 → 1.5 | -5 ✗ | -4 ✗ | -4 ✗ |
| TPACF B2B #2 | 1.55228 | 7.0 → 7.0 | -11 ✗ | -11 ✗ | -11 ✗ |
| TPACF B2B #3 | 1.19852 | 7.0 → 7.0 | -12 ✗ | -12 ✗ | -12 ✗ |

三种模式都是 **2/9**，仅判对 G1 和 G2。这两条子版本同一个 HSACO，按二进制转移去重为 **1/8**。HLLD 是唯一跨过阈值的转移（2→1）。如果任一侧低于 2 就统一用 latency，它的 Δ 是 −48，仍与 GPU 变慢方向相反。NQU DP2 使用已复现 TTI 与机器码特征的历史重建，原计时对象已丢失。

Occupancy 切换在这组样本上没有改善预测方向。第 4 节的完整 Greedy 扩大样本没有触发。

[发布产物校验值、资源预算、逐条分数和判定](occupancy-aware-cost-20261120.json)
