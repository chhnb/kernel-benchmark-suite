# PCM32 R2R cleanup 强度诊断

## 结论

- 当前发布搜索的 D/R 都只出现一个被拒的 R2R，即 `trial-33`，没有被拒的 B2R。五档 cleanup 都没有让它翻转，DARM 第 10 步也始终判亏。
- 对重建的两条历史 R2R，测试范围内最短可翻转序列是 **InstCombine → SpeculativeExecution → SimplifyCFG**，各得到 2 点 TTI 收益。在 SimplifyCFG 前加 Correlated Value Propagation 后，两条各得 5 点收益，与 LLVM12 O3 相同。原始历史 `trial-70` 的归档路径未找到，此结论基于两个可重建的同类实例。当前发布搜索没有这两个试融实例。
- NQU64 加 GVN 后首轮原有平手被打破，改选 `trial-2`。续跑产物的时间比为 **1.09425 [1.09343, 1.09479]**。LUD8 的指定五档中，只有 O3 使一个原未选出的末轮布局足以追加融合。新对象相对 R 为 **1.00043 [1.00001, 1.00081]**。
- CED 的新 HIP Graph 计时通过 A/A。R/D 为 **1.00032 [0.99638, 1.00968]**，观察不到稳定差异。

## 起点与方法

- 起点 `84e30a76a95bdbae55c66e31e57155c82fbef11e`，分支 `feat/anchor-unified-dp`。EPYC 工作目录为 `/data/home/chh/simplify-v2/build/pcm32-cleanup-strength.m8qAyS`。复用 6c 已验证的 Greedy、search 和固定 LLVM12/LLVM24 工具链。只新增本记录。
- D 为无参默认，R 为 `--anchor-gap auto --anchor-guarded-gap 1 --anchor-auto-assume classify --anchor-uniform-gate on --anchor-uniform-missing reject`，dedup 关。R 传入 6a 核实的 launch 形状。PCM32、NQU64 和 LUD8 依次为 32×1×1、64×1×1、16×1×1。发布输入和 LUD8 shared.ll 经原 SHA-256 核实。
- `step7-fresh.py` 重新从冻结 IR 跑 PCM32 D/R、NQU64 R、LUD8 R 四次完整 Greedy，最终 IR 与 6c 归档逐字节一致。PCM32 D/R 的 50 条尝试 ID、候选择序、报价和资格一致，包括 33 条 B2B、16 条仅归一化，以及一条 R2R。记录目录为 `fresh/<case>/<role>/active`。
- 对每条已生成 IR 的候选，从该请求实际用的父 IR（含 prepared 父 IR）调用 `fusion-search-llvm24 --control-only 1`，重新导出默认清理的同父对照。候选直接使用对应请求清理后的 `fused.ll`。扩展档对同父对照和候选使用同一 `opt` 参数。当前 Greedy 还要求候选代价低于未准备的轮父状态，该状态也单独应用相同附加 pass。默认档复现归档报价与资格。仅归一化请求同未准备父状态对比分数。
- O3 从默认清理后的各自状态单独开始，作为上限参照。没有把 GVN/DSE 档的输出再喂给 O3。第一次调用尝试了 LLVM12 不支持的 New PM `early-cse<memssa>` 拼法，改为 LLVM12 legacy `-early-cse-memssa` 后从新目录完整复跑。
- 默认打分、接受规则、编译器源码和发布配置均沿用原值。重建和计时辅助脚本仅保存在 EPYC 工件目录。现有回归 16 项通过、4 项按 `tests/KNOWN_FAILURES.md` 跳过。

```sh
"$search" --ir "$parent_for_trial" --function "$symbol" --control-only 1 --out "$control"
"$opt" -enable-new-pm=0 -early-cse-memssa -verify-each -S "$default_ir" -o "$early"
"$opt" -enable-new-pm=0 -early-cse-memssa -gvn -verify-each -S "$default_ir" -o "$gvn"
"$opt" -enable-new-pm=0 -early-cse-memssa -gvn -dse -verify-each -S "$default_ir" -o "$dse"
"$opt" -O3 -verify-each -S "$default_ir" -o "$o3"
"$tool_root/tools/run-llvm24-tti" "$result" "$symbol" --summary-only
```

## PCM32 五档重放

| 固定候选 | 默认 | + EarlyCSE MemorySSA | + GVN | + DSE | LLVM12 O3 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 当前 D/R `trial-33`，`B4:H5_7:H6_7` | 1138 → 1340 | 1138 → 1340 | 1138 → 1340 | 1138 → 1340 | 1138 → 1268 |
| DARM 第 10 步的同父试融 | 1262 → 1387 | 1262 → 1387 | 1304 → 1429 | 1304 → 1429 | 1272 → 1396 |
| 历史重建 `trial-138`，`B7:H8_10:H9_10` | 1152 → 1254 | 1152 → 1254 | 1152 → 1254 | 1152 → 1254 | **1152 → 1147** |
| 历史重建 `trial-139`，`B5:H6_8:H7_8` | 1137 → 1239 | 1137 → 1239 | 1137 → 1239 | 1137 → 1239 | **1137 → 1132** |

当前 `trial-33` 的父 IR SHA-256 为 `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2`，候选为 `536220f739f11b825153e2b5a9b6fed51ecc551ab4bfd9a680b3aea3fb5be021`。两项均在 D/R 一致。DARM 第 10 步沿用 `cleanup-passes/20261120-v1/exact` 的同父对照及试融产物。当前 `trial-33` 的默认亏损 202，O3 后仍亏 130。第 10 步 O3 后亏 124。

旧记录所列的 `memory-match.YIwp9c` 原工件目录无法找到，在第 6c 前的磁盘清理归档中也没有匹配条目。用历史检查点 `3510dfb74de85e02dd6f8f4e8d3a2dfcdf2fe267` 从同一冻结输入重建，并沿用其 `darm-cfg-dce`。历史源码用现有 LLVM12、共享 LLVM24 worker 以及本地解包的 libssl-dev 构建。首次构建缺 OpenSSL 头文件和异常编译开关，补齐后重建成功。此次编号 `trial-70` 是中途获选的 B2B。两个末端 R2R 为 `trial-138` 和 `trial-139`。其中 `trial-139` 复现了旧记录的 **O3 1137 → 1132**，默认试融为 1239，和旧记录的 1311 有差异，不能认定为原始 `trial-70`。参考 [历史记录](pcm32-r2r-20261114.md)。

### 定位改变判定的 pass

用 LLVM12 O3 的逐 pass IR 转储重放两个末端 R2R。候选 `trial-139` 的轨迹为 1239 → InstCombine 1230 → SpeculativeExecution 1230 → Value Propagation 1209 → SimplifyCFG 1132，此处同阶段对照保持 1137。`trial-138` 有同样的步进 Δ（−9、0、−21、−77）。后续 O3 中的循环规范化会暂时增加报价，最终稳定为上表的 +5。

在保持上述次序的候选 pass 组合中，枚举 InstCombine、SpeculativeExecution、Correlated Value Propagation、SimplifyCFG、JumpThreading 和 SCCP 的长度 1–4 子序列。未发现能让两个实例一起翻转的一步或两步序列。最短找到的是：

| 追加序列 | `trial-138` | `trial-139` | 第 10 步 | 当前 `trial-33` |
| --- | ---: | ---: | ---: | ---: |
| InstCombine → SpeculativeExecution → SimplifyCFG | **1152 → 1150** | **1137 → 1135** | 1258 → 1383 | 1138 → 1274 |
| InstCombine → SpeculativeExecution → CVP → SimplifyCFG | **1152 → 1147** | **1137 → 1132** | 1258 → 1382 | 1138 → 1268 |

历史两个 R2R 分别用上述三档可翻转种子（3 pass、4 pass、O3）喂给当前未改动的 Greedy，各以 D/R 继续搜索。`trial-138` 后续再提交 1 次，`trial-139` 后续 0 次。续跑从种子 IR 重新发现决策域，没有注入旧 driver 的队列状态。12 条续跑均得到同一个 HSACO `5b7adc29cd6f0938d17bbc3b226ce04f96805003eeb05987f960ae41303e9c6e`。同字节角色在 GPU 批次只测一次。该对象在完整输出校验下比发布 D 快 6.83%，与 Auto DARM 持平。

### PCM32 GPU

沿用冻结 `PCM32.input` 和 `PCM32.reference`（各 1 GiB），SHA-256 逐项校验。一次进程内预热 ≥200 ms，12 个轮换窗口，每角色每窗口 31 次采样，逐次将完整排序结果与冻结 reference 比较。计时只覆盖 kernel，报告配对比值与 10,000 次 bootstrap 95% 区间。使用原版 Auto DARM native pass at 0.2 产物。

PCM32 A/A 31 次时中位数 1.00000，跨度 0.01%，通过。

| 角色 | 中位耗时（ms） | 相对发布 D | 相对 Auto DARM |
| --- | ---: | ---: | ---: |
| 发布 Greedy D | 707.596 | 1.00000 [1.00000, 1.00000] | 1.07326 [1.07324, 1.07330] |
| Auto DARM | 659.283 | 0.93174 [0.93171, 0.93175] | 1.00000 [1.00000, 1.00000] |
| 历史 R2R 续跑产物 | 659.288 | 0.93174 [0.93171, 0.93175] | 1.00000 [0.99999, 1.00002] |

## NQU64 / LUD8 副作用

按原 Greedy 给每对块返回的获选布局，NQU64 的 13 个融合请求、LUD8 的 4 个融合请求在五档均无接受资格翻转。NQU64 另有 4 个仅归一化请求。其中未获选的 `normalize-0-1-0` 由 289 → 288 的微小正收益变为 288 → 288，所有追加档都不再合格。

- **NQU64 排序变化。** 首轮 `trial-0`（`B2:B3:B6`）和 `trial-2`（`B2:B3:B8`）在默认和 EarlyCSE 下都是 288 → 282，原 Greedy 取先枚举的 `trial-0`。GVN、DSE 或 O3 后变成 288 → 282 对 288 → 281。用新胜者续跑 R 得两次后续提交，最终 TTI 268。三档同一新 HSACO，和 R 在同批比较为 **1.09425 [1.09343, 1.09479]**。A/A 在 31 次时中位数 1.00007、跨度 0.86%，全部输出通过冻结指纹及 2,279,184 解数检查。EarlyCSE 仍从 `trial-0` 续跑，机器码与 R 逐字节一致。
- **LUD8 扩到内部布局。** 额外用 `FUSION_OBSERVE_B2B_DP` 重放这两案所有 Anchor 布局，共 NQU64 12 个、LUD8 32 个。保留原 R 的 gate 决定，改变的变量是 throughput 报价。NQU64 无布局翻转。LUD8 只有 O3 出现 4 个 reject→accept。第一处的 `trial-0/b2b-anchor-{1,2}` 各 641，仍输给同父 558。下一轮 `trial-1/b2b-anchor-5` 为 557，仍输给同轮写回的 536。末轮 `trial-3/b2b-anchor-5` 为 535，比只清理的 536 严格低 1，确实产生额外续跑产物。只续跑原两个获选布局时，四个附加档的设备对象均与 R 逐字节相同。
- 额外测试的 3 pass 和 4 pass 两组，在这两个 case 的 Greedy 获选布局上没有改变判定或排序。没有把 EarlyCSE/GVN 的副作用归因于这两组。

LUD8 复用原 `create_matrix(16384)` 和原 perimeter-only 2047-launch 顺序。计时 event 包住 launch 序列，输入恢复和输出检查在事件外。预热后首先核对既有全输出指纹 `99f686c239322d34`，之后每次对全矩阵做逐字节比对。用进程内交替的 12×31 窗口；如 A/A 失败，允许一个 61 次窗口版本。

LUD8 A/A 31 次时中位数 1.00007，跨度 0.28%，通过。O3 末轮新增布局续跑对象相对 R 为 **1.00043 [1.00001, 1.00081]**。

## CED 新计时协议

使用与 6c 相同的冻结 110 帧，逐文件核对 manifest SHA-256。输入、输出及每个 buffer 两侧 256 字节 guard 每个样本全量比对。每个样本执行原 39×22 grid、16×16 block 和原动态 LDS 配置，110 帧 GPU buffer 独立、预先常驻。每次样本先重置输出，event 测一整个 110-launch HIP Graph，传输及校验在 event 区间外；测得的是整段设备事件时间，包含图调度开销。设备未改时钟。

冻结角色在同一进程轮换，先累计预热至少 200 ms，然后每角色 12 个窗口。窗口内交替配对，按每角色事件中位数算成对比值，10,000 次 bootstrap。初次 31 次不通过时只重试一次 61 次。先做过 110 次常规 HIP launch 合并成一个计时段，A/A 仍两次超限。HIP Graph 测量开始前未读任何 R/D 时间。

| CED A/A 协议 | 每角色每窗口次数 | 中位数 | 跨度 | 结论 |
| --- | ---: | ---: | ---: | --- |
| 110 次直接 launch 共用事件 | 31 | 0.99988 | 6.61% | 超限 |
| 110 次直接 launch 共用事件 | 61 | 0.99455 | 3.59% | 超限 |
| HIP Graph | 31 | 0.99458 | 6.86% | 超限 |
| HIP Graph | 61 | 0.99222 | 2.23% | 通过 |

R/D 为 **1.00032 [0.99638, 1.00968]**，使用 61 次 ×12，全部 110 帧及 guard 校验通过。脚本为 `step7-ced.py`、`step7-ced-graph.py`，两份 runner 源为 `ced-train.hip` 和 `ced-graph.hip`。

## 收据

| 文件 | SHA-256 |
| --- | --- |
| `../anchor-dp-step6c.2u7qrZ/source/build/decision-fuse/decision-greedy` | `a228699b9418d3fd39a7e69a212c20a2bd256e4492148fbf5a610fa0460eb125` |
| `../anchor-dp-step6c.2u7qrZ/source/build/llvm24-tti/fusion-search-llvm24` | `5a2cecb3112d411a8954fbd6cb27f5d451769ec6ecfec70cbe56567558099295` |
| `../anchor-dp-step6c.2u7qrZ/source/build/llvm24-tti/llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| `historical/build/historical-greedy` | `b52dc0a87ba00c81bf61dffe8dfbd2b5f0b0dde5783bf3e0b29ec61a0efb7e3e` |
| `historical/build/llvm24-tti/fusion-search-llvm24` | `8bdf2dedf7a34854ff078504a8b1d0fefb084f970deb1f5f7a89e097e3b09591` |
| `pcm-runner` | `7dda0a621f334a6bf0c3a8c3b07d1a1c7367a37e6587467e5957d0642f2011c2` |
| `../final-release.kzxLp5/gpu-tools/full-nqu` | `a7afbbb2e33ac9f3c186050cdaf70439eb463f8a49bd0504fc63371cfa0816e1` |
| `lud-window` | `444fe07f7f1dda2e2ea04f24fa378d9a886370b9c8f549d72699e145cac93e85` |
| `ced-train` | `8e4772f5ca55b890dd4fd1c518139c08cb7d5fe92616a779a265b9620ced69b5` |
| `ced-graph` | `4deda69cfd5c0377e49b951a6517fc58d979cf087900e24f83ce322d58ccae01` |
| `replay.json` | `71a2ff78b2f9b9aa048004c50198ec87941f276e7337fd1c799c55f0f4c30fdf` |
| `history-replay.json` | `846c0f40ceb9c190dcbffc62eee24928cdad4c02d5aa127af8192034ed916139` |
| `o3-trace/scores.json` | `df58bb1ab330588ecd68deb55ff6227e3a9e31bdf17ddd600d19485f2337541c` |
| `minimal/results.json` | `271c1ebb17bd2ff493285351eb3863ba76b15e618fdb6947c52622af38919ad9` |
| `layouts.json` | `d2fc5e9f9324653b3856bcffb913fb78430190200f1c720ebdfe5d818b4e1d85` |
| `side-nqu.json` | `c50f3410b46299590827d6ec2401da440f05d01eee681502862b02482d488089` |
| `side-minimal.json` | `84d2ed6edf4f94fb23d62a9bec5b0ea3372cfc463c3589d4ea12813094e0da66` |
| `pcm-objects.json` | `fbd13f6e22756c5f7fbb96f553db0f9f348d80cc865c45cea17d6809b250489e` |
| `pcm-minimal-objects.json` | `f3e67945399cc30e778d41b407d1c7e8b7248dce11302e17dc8032cc8ac5cde0` |
| `pcm-gpu-results.json` | `7252717895644f37bf286b43ba8b721d6359193fc457c6a344bb7f976382dc1b` |
| `nqu-gpu-results.json` | `c2c19dda1326b3eae9520d782281b79c99f8c2e679838a6a1c553dbfbd9c7756` |
| `lud8-gpu-results.json` | `4e12d6b12434e04e37458d3363c32ff6b48579fa18c60ea45b1b9b750577057a` |
| `ced-graph-results.json` | `5b18b5bc05b3759a4c21b95a37b5809f0f492d07c04987560fe6d7b4314ac2e9` |
| `../anchor-dp-step6c.2u7qrZ/source/build/simplify-fingerprint/final-pcm32-cleanup-strength/results.json` | `54700b3396da17fe3ee8e3820f32543ee1bf54ae2ec10aa7ca0629e949151a04` |
