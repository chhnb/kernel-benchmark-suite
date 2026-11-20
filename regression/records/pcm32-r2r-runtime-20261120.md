# PCM32 第 10 步 R2R 的运行时采样（2026-11-20）

使用 Auto DARM 第 10 步的真实父 IR，以及从同一父 IR 出发只试融一次 `darm-R2R` 的产物。在 EPYC 的 gfx906 上使用 ROCm 6.3.3 的 `rocprof`。计数器和 HSA trace 各自独立采集。只取 `pcm(int*)` dispatch，排除 ROCm 拷贝 kernel。LDS/SQ 与 trace 每个版本各 4 次 dispatch（1 次预热、3 次计时），VMEM 组各 2 次。runner 对每次启动做完整输出校验。

| 指标 | R2R 前 | R2R 后 | 变化 |
| --- | ---: | ---: | ---: |
| kernel trace 中位数（ms） | 785.060522 | 739.943341 | −5.75% |
| SQ_INSTS_LDS | 1580797096 | 1429802152 | −9.55% |
| SQ_LDS_BANK_CONFLICT | 18510858429 | 17291560104 | −6.59% |
| SQ_INSTS_VALU | 5037234512 | 4971338064 | −1.31% |
| SQ_INSTS_SALU | 855080960 | 1943535616 | +127.29% |
| SQ_INSTS_VMEM_RD | 2097152 | 2097152 | 0% |
| SQ_INSTS_VMEM_WR | 2097152 | 2097152 | 0% |
| SQ_INSTS_SMEM | 65536 | 65536 | 0% |
| SQ_WAVES | 32768 | 32768 | 0% |

约少发射 1.51 亿条 LDS 指令。每条 LDS 指令对应的 bank-conflict 停顿计数升约 3.3%，总体停顿计数仍下降。硬件数据支持合并减少内层 LDS 工作量的解释。采样未隔离各项变化对约 45 ms 耗时差的贡献。两版的 `SQ_WAIT_INST_LDS` 均读到 0。包含 `FetchSize`、`WriteSize` 和 `GRBM_GUI_ACTIVE` 的计数组遇到 `Context Create failed`，因此没有用 VMEM 指令数代替实际显存流量。

完整 LLVM 12 O3 后，可达静态 IR 指令数为 1071 → 1102，默认 TTI 为 1272 → 1396。4/2 重计为 1568 → 1671。既有无 profiler 的 12 轮同父回测为 785.718 → 740.656 ms（−5.74%）。[原始同父实验](https://github.com/chhnb/kernel-benchmark-suite/blob/617b52a96a44a4c6a93ce5cc52e61c1e9ede430b/regression/records/cleanup-extended-20261120.md#1-pcm32-第-10-步的同父校验与-gpu)

两个被采样的 HSACO 的 SHA-256 分别为 `35a2c062b54b056a4b3c8e6e513e75abfce5a59edba2e7b1330a21d693a952c1` 与 `6a0f71b49a5856d08e1d2af6f085b5b0f4865c362c11cd1aee7f2008a747c66e`。

[原始计数、trace 和完整输出校验结果](pcm32-r2r-runtime-20261120/)

[PCM32 第 10 步的同父前后 IR](pcm32-r2r-ir-20261120/)
