# 发布 GPU 统一重测状态（2026-11-20）

## 启动门槛

M1（预热后逐次计时）、M2（预热后批量计时）和 M3（预热后连续异步逐次计时）均未在三个 A/A 样本同时达标。SRAD stage2 1024² 是共同的阻点。全部正式试跑通过输出校验。根据启动条件，发布矩阵未开始。 [校验器自测与 A/A 结果](srad-stability-20261120.md#4-修复校验器并比较三种进程内方式)

## 发布矩阵

旧状态来自发布清单。新列表示该发布用例的 baseline、anchor、DP1 比较是否执行。方法筛选使用 DP1 的 A/A 比值，不能用于新性能判定。

| 用例／输入 | 旧状态 | 新版发布比较 |
| --- | --- | --- |
| vLLM 64K | 字节别名，通过 | 未开始 |
| vLLM 128K | 字节别名，通过 | 未开始 |
| TIGRE | 字节别名，通过 | 未开始 |
| Map-Airy | 通过 | 未开始 |
| HLLD | 通过 | 未开始 |
| NQU64 | 字节别名，通过 | 未开始 |
| MS32 | 通过 | 未开始 |
| PCM32 | 字节别名，通过 | 未开始 |
| Landau mixed | 通过 | 未开始 |
| Landau coherent | 记录例外 | 未开始 |
| SW2D | 通过 | 未开始 |
| CED | 通过 | 未开始 |
| TPACF | 通过 | 未开始 |
| SRAD stage2 256² | 通过 | 未开始 |
| HiPIMS-George | 通过 | 未开始 |
| SRAD stage2 1024² | A/A 不稳定 | 未开始 |
| SRAD16 stage1 256² | 只报告正确性 | 未开始 |
| SRAD32 stage1 256² | 修复版五路校验通过，未取得性能判定 | 未开始 |
| SasPoint5 interval-mixture | 该 case 的三个输入未共同通过 A/A | 未开始 |
| SasPoint5 coherent-blocks | A/A 不稳定 | 未开始 |
| SasPoint5 uniform-01 | A/A 不稳定 | 未开始 |

[发布清单](../../docs/RELEASE.md)和[已知问题](../../docs/KNOWN_ISSUES.md)保留已发布的判定。未引入具名测量模式或新的发布 tag；旧冻结产物和实验开始前的 runner 均保持原样。
