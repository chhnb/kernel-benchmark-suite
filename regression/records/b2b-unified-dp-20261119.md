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

## K=16 的 Greedy 与 GPU 回测 · 2026-11-19

产物 U 由 `f8203d9` 显式选择 `--b2b-planner unified` 得到。默认 legacy 的七份产物均与 A `4a91a50` 的提交序列、最终 IR 和 HSACO 逐字节一致。27 项测试通过，4 项按已记录的缺件原因跳过。

最终 IR 与 A 原始字节相同的 case 登记为别名。每个实测轮次交错执行 baseline、A、U，记录各自的 GPU event 中位数。稳定性对 A/baseline、U/baseline 分别使用已取得轮次的最大比值除以最小比值减一。12 轮性能门槛使用成对 U/A 的中位数。HLLD 的 A 在历史 65,536 单元输入上比未融合版慢约 6.9%。

| Case | 输入 | 状态 | 完整轮数 | baseline µs | A µs | U µs | 成对 U/A |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| vllm | 64K | A 别名 | 0 | — | — | — | — |
| vllm | 128K | A 别名 | 0 | — | — | — | — |
| tigre | 50 投影／6 批 | A 别名 | 0 | — | — | — | — |
| MapAiry | 65539 | 超出 2% 门槛 | 12 | 84.720 | 37.120 | 39.200 | 1.0560 |
| HLLD | 65536 | A 别名 | 0 | — | — | — | — |
| NQU64 | — | A 别名 | 0 | — | — | — | — |
| MS32 | — | A 别名 | 0 | — | — | — | — |
| PCM32 | — | A 别名 | 0 | — | — | — | — |

MapAiry/65539 的 12 轮成对 U/A 中位数为 1.0560，超过 1.02。

### 提交差异

| Case | 首个标签差异 | 首个候选或 IR 差异 | A | U | 诊断 |
| --- | --- | --- | --- | --- | --- |
| vllm | 第 1 次提交 | — | — | — | 提交候选和清理后哈希一致 |
| tigre | 第 4 次提交 | — | — | — | 提交候选和清理后哈希一致 |
| MapAiry | 第 1 次提交 | 第 8 次提交（轮次 A 8 / U 8） | `evaluate:B6:B5:B7` · `single-branch-segment-dp-4` · TTI 4781 → 4734 · 非 CFG 57 / CFG／PHI -10 | `evaluate:B6:B5:B7` · `b2b-unified-75` · TTI 4781 → 4730 · 非 CFG 63 / CFG／PHI -12 | 同父 IR、同候选，布局变化改变了清理后 TTI |
| HLLD | 第 2 次提交 | — | — | — | 提交候选和清理后哈希一致 |
| NQU64 | — | — | — | — | 提交候选和清理后哈希一致 |
| MS32 | 第 1 次提交 | — | — | — | 提交候选和清理后哈希一致 |
| PCM32 | 第 1 次提交 | — | — | — | 提交候选和清理后哈希一致 |

Map-Airy 的 36 次运行共校验 648 次 kernel 启动（含预热），全部通过。A/baseline 的轮间最大相对跨度为 0.863%，U/baseline 为 1.227%，均在 3% 内。绝对轮中位数范围为 baseline 84.480–84.800 µs，A 36.960–37.279 µs，U 39.040–39.519 µs。

Map-Airy 第 8 次提交的 block 坐标、决策归属及父 IR 哈希一致。A 的 21 对前向分段配对、零下沉方案在 U 中仍完整存在（`b2b-unified-8`），评分同为 4734。U 选择 `b2b-unified-75`，将 10 对保留为前向配对，另把 14 对纯计算下沉到汇合点之后，清理后的 TTI 为 4730。该轮是 TTI 严格更优的布局改选。最终贪心链从 A 的 32 次、TTI 4259 变为 U 的 31 次、TTI 4377。GPU 数据对应完整提交链，未单独测量第 8 次提交。

回测未达到切换默认值的门槛。默认规划器仍为 legacy，后续删除阶段停在门槛处。

### 搜索开销

请求数取 Greedy 汇总的 trial 计数。布局评分调用取各请求的 `evaluate_score` 计数，同请求内经过清理后模块哈希去重。搜索时间为对应完整运行的墙钟秒数。

| Case | 提交数 A → U | 请求数 A → U | 评分调用 A → U | 搜索秒数 A → U |
| --- | ---: | ---: | ---: | ---: |
| vllm | 224 → 224 | 1083 → 1083 | 4124 → 2972 | 170.130 → 141.564 |
| tigre | 6 → 6 | 18 → 18 | 163 → 234 | 2.950 → 3.698 |
| MapAiry | 32 → 31 | 420 → 473 | 2732 → 4089 | 65.613 → 95.471 |
| HLLD | 4 → 4 | 34 → 34 | 97 → 65 | 1.691 → 1.245 |
| NQU64 | 1 → 1 | 11 → 11 | 14 → 13 | 0.205 → 0.204 |
| MS32 | 1 → 1 | 6 → 6 | 112 → 64 | 0.628 → 0.485 |
| PCM32 | 17 → 17 | 34 → 34 | 131 → 130 | 3.356 → 3.428 |

逐请求、逐提交和逐轮原始记录位于 `build/b2b-layouts/k16-gpu/`。

## 限制 unified 的候选组合 · 2026-11-19

实现提交为 `e1a6812`。默认仍为 legacy，unified 的扩展组合需显式传入 `--b2b-unified-extended on`。扩展模式区分 recipe 的规划依赖。

### Map-Airy 第 8 次提交的组合

此前 U 的 `b2b-unified-75` 在 `evaluate:B6:B5:B7` 上使用 10 对前向分段 DP 配对。剩余臂坐标为 (0,0) 至 (2,2) 及 (4,4) 至 (10,10)，before 为空。后向 14 对与 legacy 的 `single-branch-join-dp-2` 相同，来自 reverse DP。贪心后缀只有 11 对。legacy 只会将该 14 对 tail 与零前向配对或完整臂的 3 对贪心前缀组合，并独立生成无 tail 的分段方案。

用同一审计父 IR 做显式候选重放。扩展关时最优 TTI 为 4734，目标组合不在集合中。扩展开时原组合以 `b2b-unified-77` 出现，TTI 为 4730。此前完整扩展链在 GPU 上慢 5.60%。

关闭扩展时，生成顺序为贪心前缀、merged-exit、贪心后缀及其前缀组合、每条 join-DP tail 的纯下沉与前缀组合、前向分段按排名及其 resplit。join-DP 的纯下沉和前缀变体按 legacy 实际代码逐条交错。存在有效且已评分的获胜方案时，只在 `result.total` 严格更大时替换，因此同分取发射顺序中第一个。清理后哈希相同的有效方案只评分一次。

### 离线复现

| 规划器 | 复现 | 每候选平均生成 | 去重后有效评分 |
| --- | ---: | ---: | ---: |
| legacy | 274/274 | 12.50 | 2308 |
| 旧 unified K=16 | 274/274 | 10.27 | 2101 |
| 限制后 unified K=16 | 270/274 | 7.54 | 1394 |

| 历史布局族 | 复现 |
| --- | ---: |
| `common-join-dp` | 0/1 |
| `prefix` | 90/90 |
| `prefix-merged-exit` | 2/2 |
| `prefix-suffix` | 6/6 |
| `segment-dp` | 170/173 |
| `separate` | 1/1 |
| `suffix` | 1/1 |

| Case | 提交序号 | 历史布局 | 历史 TTI | 限制后最低 TTI | 旧 unified 的获胜组合 |
| --- | ---: | --- | ---: | ---: | --- |
| MapAiry | 29 | `single-branch-segment-dp-32` | 4276 | 4292 | 3 对分段 + 1 对下沉 |
| MapAiry | 30 | `single-branch-common-join-dp-2` | 4271 | 4272 | 1 对分段 + 3 对下沉 |
| SRAD16 | 3 | `single-branch-segment-dp-28` | 451 | 457 | 3 对分段 + 1 对下沉 |
| SRAD32 | 3 | `single-branch-segment-dp-28` | 451 | 457 | 3 对分段 + 1 对下沉 |

三个原分段获胜者的 legacy 排名为第 28 或 32 名。Map-Airy 第 30 次原布局为 common-join，超出本轮允许的前缀／tail 组合。旧 unified 在这四处均靠分段加下沉达到历史 TTI。

### 完整 Greedy 逐字节检查

| Case | U 的最终 IR | A → U 提交数 | A → U 最终 TTI |
| --- | --- | ---: | ---: |
| vllm | A 别名 | 224 → 224 | 2619 → 2619 |
| tigre | A 别名 | 6 → 6 | 946 → 946 |
| MapAiry | 有差异 | 32 → 34 | 4259 → 4271 |
| HLLD | A 别名 | 4 → 4 | 1701 → 1701 |
| NQU64 | A 别名 | 1 → 1 | 282 → 282 |
| MS32 | A 别名 | 1 → 1 | 212 → 212 |
| PCM32 | A 别名 | 17 → 17 | 1138 → 1138 |

MapAiry 第 29 次提交首次分歧。A 为第 47 轮 `evaluate:B54:B65:B64`，`single-branch-segment-dp-32`，TTI 4276。U 为第 47 轮 `evaluate:B54:B65:B64`，`b2b-unified-3`，TTI 4292。
在相同父 IR 上，A 的布局没有进入 U 的候选集。
第 8 次提交的清理后 IR 已恢复与 A 一致，前 28 次均一致。第 29 次的 A 布局是 legacy 的第 32 名分段方案，受限 unified 的预算为 16。U 改选纯下沉，TTI 为 4292。该处分歧由候选缺失触发。

默认 legacy 的七份产物与 A 的提交序列、最终 IR 和 HSACO 逐字节一致。测试 27 项通过、4 项已知缺件跳过。本轮只进行离线验证和编译，完整门槛未达到，步骤 5 停在切换默认值之前。

B2B 行数按 `using B2BMatch` 到 `makeRound` 之前计算，从 1258 行到 1279 行。本轮新增模式隔离与受限生成，尚未进入 legacy 删除阶段。

原始评分、完整提交链与差异位于 `build/b2b-layouts/restricted-replay/`。
