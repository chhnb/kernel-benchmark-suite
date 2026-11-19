# 统一 B2B 规划器离线复现 · 2026-11-19

规划器提交为 `dbb7dea`。以 `4a91a50` 默认编译产物为 A。显式选择 unified，只重放布局审计中实际提交的 B2B 候选。
使用各候选 `request.json` 指定的父 IR 和 B/B 坐标，包括 prepared IR。核对候选键、父 IR 哈希，以及所有有效已评分方案的父 TTI。同一版本的 LLVM24 以 reciprocal throughput 计算布局清理后的 `work_after`。只要至少一个有效方案的 TTI 不高于已提交布局即计为复现。

默认 legacy 路径的七份产物已通过 A 的提交序列、原始 `final.ll` 和 HSACO 比较。现行测试集合 27 项通过、4 项预期缺件跳过，两种规划器模式均通过单分支 CPU 回放。

复现 **261/274**。发现离线复现缺口，停在 GPU 回测入口。

| 历史布局族 | 复现 | 总数 | 复现率 |
| --- | ---: | ---: | ---: |
| `segment-dp` | 166 | 173 | 96.0% |
| `prefix` | 90 | 90 | 100.0% |
| `prefix-merged-exit` | 1 | 2 | 50.0% |
| `prefix-suffix` | 2 | 6 | 33.3% |
| `suffix` | 0 | 1 | 0.0% |
| `common-join-dp` | 1 | 1 | 100.0% |
| `separate` | 1 | 1 | 100.0% |

## 未复现实例

| Case | 提交序号 | 请求 | 候选 | 历史布局 | 历史 TTI | Unified 最低 TTI |
| --- | ---: | --- | --- | --- | ---: | ---: |
| HLLD | 2 | `trial-7` | `_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii:B20:B23:B22` | `single-branch-prefix-merged-exit` | 1745 | 1848 |
| MapAiry | 1 | `trial-5` | `evaluate:B98:B97:B99` | `single-branch-prefix-suffix` | 6174 | 6402 |
| MapAiry | 2 | `trial-20` | `evaluate:B102:B101:B103` | `single-branch-prefix-suffix` | 5946 | 6174 |
| MapAiry | 4 | `trial-49` | `evaluate:B100:B99:B101` | `single-branch-prefix-suffix` | 5481 | 5709 |
| MapAiry | 6 | `trial-74` | `evaluate:B100:B99:B101` | `single-branch-prefix-suffix` | 5017 | 5245 |
| MapAiry | 10 | `trial-99` | `evaluate:B92:B89:B93` | `single-branch-suffix` | 4675 | 4693 |
| MapAiry | 29 | `trial-277` | `evaluate:B54:B65:B64` | `single-branch-segment-dp-32` | 4276 | 4288 |
| MapAiry | 31 | `trial-339` | `evaluate:B5:B62:B61` | `single-branch-segment-dp-13` | 4264 | 4270 |
| SRAD16 | 2 | `trial-6` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B26:B27:B28` | `single-branch-segment-dp-13` | 457 | 459 |
| SRAD16 | 3 | `trial-8` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B22:B23:B25` | `single-branch-segment-dp-28` | 451 | 458 |
| SRAD32 | 2 | `trial-6` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B26:B27:B28` | `single-branch-segment-dp-13` | 457 | 459 |
| SRAD32 | 3 | `trial-8` | `_Z11srad_cuda_1PfS_S_S_S_S_iif:B22:B23:B25` | `single-branch-segment-dp-28` | 451 | 458 |
| tigre | 5 | `trial-14` | `_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture:B24:B23:B25` | `single-branch-segment-dp-9` | 950 | 955 |

逐条结果及各方案评分保存在 `build/b2b-layouts/unified-replay-20261119/results.json` 和同目录的候选记录中。
