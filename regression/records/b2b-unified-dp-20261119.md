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

## 补全结构性种子与前向候选后的复现

本轮规划器提交为 `93f213d`。生产 unified 使用前向 K=32 和 reverse-DP K=4。另外无条件纳入最大连续前缀及其合法 merged-exit 形式、贪心后缀、各非空 tail 的只下沉方案。过滤已下沉指令后，前缀仍使用原 IR 的支配树检查操作数，只有同一前缀内已经配对的值或支配 split 的值可用。保留 merged-exit 发射时对条件的 freeze。

### 原 13 个实例

先使用生产 K=32 在原父 IR 上核对结构，匹配 before、segments、after、resplit 和 merge-exit。将匹配方案单独重放以验证其 TTI，包括在整组中可能被清理后哈希去重的方案。

| Case | 提交序号 | 历史布局 | 历史 TTI | 同一方案重放 TTI | Unified 最低 TTI |
| --- | ---: | --- | ---: | ---: | ---: |
| HLLD | 2 | `single-branch-prefix-merged-exit` | 1745 | 1745 | 1745 |
| MapAiry | 1 | `single-branch-prefix-suffix` | 6174 | 6174 | 6174 |
| MapAiry | 2 | `single-branch-prefix-suffix` | 5946 | 5946 | 5946 |
| MapAiry | 4 | `single-branch-prefix-suffix` | 5481 | 5481 | 5481 |
| MapAiry | 6 | `single-branch-prefix-suffix` | 5017 | 5017 | 5017 |
| MapAiry | 10 | `single-branch-suffix` | 4675 | 4675 | 4675 |
| MapAiry | 29 | `single-branch-segment-dp-32` | 4276 | 4276 | 4276 |
| MapAiry | 31 | `single-branch-segment-dp-13` | 4264 | 4264 | 4264 |
| SRAD16 | 2 | `single-branch-segment-dp-13` | 457 | 457 | 457 |
| SRAD16 | 3 | `single-branch-segment-dp-28` | 451 | 451 | 449 |
| SRAD32 | 2 | `single-branch-segment-dp-13` | 457 | 457 | 457 |
| SRAD32 | 3 | `single-branch-segment-dp-28` | 451 | 451 | 449 |
| tigre | 5 | `single-branch-segment-dp-9` | 950 | 950 | 945 |

- HLLD 的两臂各 64 条，前向网格为 65 × 65，超过 4096 格门槛。旧 unified 路径在进入排名前已退出。最大前缀种子直接恢复 64 对指令以及 merged-exit。
- Map-Airy 的四条 prefix-suffix 的两臂各 148 条，单独 suffix 实例两臂为 31 和 142 条。reverse-DP 的网格均超过 4096 格。贪心后缀种子恢复这五个布局，其中四个与剩余指令上的最大前缀组合。
- 七个 segment-dp 缺口的历史排名分别落在第 9、13、28 或 32 名。补结构性种子后 K=4 仍漏掉这七个实例，K=32 的前向候选集中包含其历史布局。

### 274 个历史候选的 K 对照

对每组使用同一套父 IR、坐标、顺序、LLVM24 worker 和六路并发。计时用每候选的规划、发射和清理阶段 `b2b_plan_generate_clean_total`，加上 `evaluate_score` 的区间耗时并求和，单位为秒。实际评分数只计通过现有 `seenDP1` 去重、进入评分的有效模块。对照二进制只在临时构建中加入 K 参数和评分计数，共用生产的发射、清理与评分路径。

| 规划器 | 复现 | 复现率 | 生成方案总数 | 每候选平均生成 | 实际评分 | 较 legacy | 规划加评分秒数 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| legacy | 274/274 | 100.00% | 3424 | 12.50 | 2308 | — | 114.18 |
| unified K=4 | 267/274 | 97.45% | 1237 | 4.51 | 923 | -60.0% | 58.99 |
| unified K=8 | 272/274 | 99.27% | 1748 | 6.38 | 1346 | -41.7% | 72.62 |
| unified K=16 | 274/274 | 100.00% | 2815 | 10.27 | 2101 | -9.0% | 97.33 |
| unified K=32 | 274/274 | 100.00% | 4624 | 16.88 | 3388 | +46.8% | 143.88 |

K=16 已达到 TTI 复现门槛。原 13 个实例中，10 个包含历史布局本身。其余三个由其他方案复现。Map-Airy 第 29 次提交为 4276，对应历史 4276。SRAD16 和 SRAD32 第 3 次提交均为 449，对应历史 451。

K=32 复现全部 274 个历史候选。
K=32 实际评分 trial 数超过 legacy 的 120%，在选择 K 的决策点停止。

默认跨七份编译产物的提交序列、最终 IR 和 gfx906 HSACO 与 A 逐字节相同。现行测试 27 项通过、4 项按已知缺件原因跳过。新增的两个结构性种子用例进入 TTI 最优集合，另一个用例由第 32 名分段方案胜出。本轮为离线验证。

原始矩阵和逐候选结果位于 `build/b2b-layouts/seed-replay/`。
