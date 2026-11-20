# 条件归一化独立候选（2026-11-20）

分支 fix/normalize-only-candidate 从 anchor-release-20261120（d8f1729）建立。NQU64 动机来自 study/nqu-second-fusion 的 14775f2。

## 1. 只读影响面审计

只读取发布版的归档 run 和 trial JSON，对每个 case 核对了最终 IR 和代码对象的 SHA-256。审计覆盖 553 轮。1,731 个 prepared pair 可以与试融关联，其中 1,700 个能从存档读出 control，31 个缺分。另有 141 个 prepared IR 没有对应试融记录。以下统计均以可核对的分数为准，未为缺失数据补跑或代入分数。

每轮错过的 TTI 为 min(本轮父代价，实际提交代价) − 最低 control。没有提交时使用父状态。父→最低 control 的合计为 1,535 TTI。相对原选择的合计为 1,462 TTI。不同轮可能复用同一原父状态，或在另选提交后到达不同父状态，因此合计只表示这份历史存档的逐轮差值。

| Case | 轮次 | 已知 control／准备总数 | 确认错过轮次 | TTI 差值和 |
| --- | ---: | ---: | ---: | ---: |
| vllm | 241 | 902／902 | 6 | 1080 |
| MapAiry | 108 | 168／211 | 1 | 11 |
| tigre | 10 | 7／10 | 0 | 0 |
| HLLD | 8 | 7／10 | 0 | 0 |
| NQU64 | 3 | 3／4 | 1 | 8 |
| MS32 | 4 | 3／3 | 2 | 304 |
| PCM32 | 20 | 16／16 | 0 | 0 |
| SRAD16 | 11 | 0／0 | 0 | 0 |
| SRAD32 | 11 | 0／0 | 0 | 0 |
| Landau | 42 | 210／276 | 0 | 0 |
| SW2D | 6 | 3／5 | 1 | 1 |
| CED | 8 | 3／4 | 0 | 0 |
| TPACF | 14 | 312／317 | 10 | 48 |
| SRAD-stage2 | 4 | 0／0 | 0 | 0 |
| SasPoint5 | 12 | 56／64 | 0 | 0 |
| HiPIMS-George | 51 | 10／50 | 2 | 10 |

逐轮命中如下。并列的 prepared 路径用花括号写出序号范围。存档里的 uniform gain 属于试融，独立 control 没有这两项，因此本表留空。汇总和每个可关联 prepared pair 的原始代价见附表。 [审计附表](normalize-candidate-20261120/audit.json)

| Case | 轮次（从 1 开始） | decision / prepared | 父 TTI | 最低 control | 最低试融（是否提交） | 实际提交 TTI | 错过 TTI | control uniform F／T |
| --- | ---: | --- | ---: | ---: | --- | ---: | ---: | --- |
| vllm | 1 | `%if.end9.i` `prepared-0-4-0.ll` | 5423 | 5243 | 5243（否） | — | 180 | — |
| vllm | 2 | `%_Z4dec8i.exit74.i` `prepared-1-5-0.ll` | 5423 | 5243 | 5243（否） | — | 180 | — |
| vllm | 3 | `%_Z4dec8i.exit.i.2` `prepared-2-24-0.ll` | 5423 | 5243 | 5243（否） | — | 180 | — |
| vllm | 4 | `%_Z4dec8i.exit.i.3` `prepared-3-25-0.ll` | 5423 | 5243 | 5243（否） | — | 180 | — |
| vllm | 5 | `%_Z4dec8i.exit.i.4` `prepared-4-26-0.ll` | 5423 | 5243 | 5243（否） | — | 180 | — |
| vllm | 6 | `%_Z4dec8i.exit.i.5` `prepared-5-27-0.ll` | 5423 | 5243 | 5243（否） | — | 180 | — |
| MapAiry | 11 | `%if.end14.i.i` `prepared-10-3-10.ll` | 4602 | 4591 | 4591（否） | — | 11 | — |
| NQU64 | 2 | `%unify.bb` `prepared-1-1-0.ll` | 282 | 274 | 274（否） | — | 8 | — |
| MS32 | 1 | `%184` `prepared-0-2-0.ll` | 370 | 218 | 218（否） | — | 152 | — |
| MS32 | 2 | `%190` `prepared-1-3-0.ll` | 370 | 218 | 218（否） | — | 152 | — |
| SW2D | 3 | `%683` `prepared-2-26-0.ll` | 1926 | 1925 | 1932（否） | — | 1 | — |
| TPACF | 1 | `%89` `prepared-0-1-{0–29}.ll` | 592 | 580 | 580（否） | 582 | 2 | — |
| TPACF | 2 | `%unify.bb` `prepared-1-1-{1–28}.ll` | 582 | 570 | 570（否） | 571 | 1 | — |
| TPACF | 4 | `%unify.bb` `prepared-3-1-{1–26}.ll` | 559 | 547 | 547（否） | 548 | 1 | — |
| TPACF | 6 | `%unify.bb` `prepared-5-1-{1–24}.ll` | 536 | 524 | 524（否） | 525 | 1 | — |
| TPACF | 8 | `%unify.bb` `prepared-7-1-{1–22}.ll` | 513 | 501 | 501（否） | 502 | 1 | — |
| TPACF | 9 | `%unify.bb` `prepared-8-1-{1–21}.ll` | 502 | 490 | 490（否） | 492 | 2 | — |
| TPACF | 10 | `%unify.bb` `prepared-9-1-{1–19}.ll` | 492 | 480 | 480（否） | 488 | 8 | — |
| TPACF | 11 | `%unify.bb` `prepared-10-1-{1–18}.ll` | 488 | 476 | 476（否） | 485 | 9 | — |
| TPACF | 12 | `%unify.bb` `prepared-11-1-{1–17}.ll` | 485 | 472 | 472（否） | 483 | 11 | — |
| TPACF | 13 | `%unify.bb` `prepared-12-1-{1–16}.ll` | 483 | 471 | 471（否） | — | 12 | — |
| HiPIMS-George | 5 | `%_ZN2GC2fv17GeorgeRiemannTypeEddddddPdS1_S1_.exit.i` `prepared-4-67-0.ll` | 5588 | 5583 | 5583（否） | — | 5 | — |
| HiPIMS-George | 10 | `%_ZN2GC2fv17GeorgeRiemannTypeEddddddPdS1_S1_.exit1.i` `prepared-9-127-0.ll` | 5588 | 5583 | 5583（否） | — | 5 | — |

## 2. 实现与测试

实现提交 1a167e6。新增 --normalize-candidate on|off，默认 off。对每个成功 prepared pair，读回和结构 worker 同一份 IR，并共用同一套 cleanup 及 PHI 折叠配置。在原父 IR 与该 control 间使用同一 LLVM24 打分器。记录 legality、profitability_rejection 和两个 uniform gain；原谓词在归一化或 cleanup 中消失时写入原因。与试融打平时选试融。用独立的 normalize-N 目录保留原版试融编号。

只有 parent→control 严格降低 TTI 才允许提交。提交归一化后重新发现 decision，原来“配对后吃掉两臂”的有序追踪只用于真正的融合。全量运行检查每次提交都严格降低代价，没有代价停滞的反复提交。

NQU64 在第一次正常提交后开启开关提交 normalize-only（282→274），最终 HSACO 与 G1 逐字节相同，关闭时从该父状态没有提交。CED 的一项归一化使代价上升并被拒绝。TPACF 正例直接比对了候选 IR 和结构 worker 的 control-only 导出，逐字节一致。

全量 CPU 运行中逐项核对了 1894 条同时有结构试融记录和 normalize-only 分数的 prepared control 报价，均相同。默认 off 的 16 个发布 case 的最终 IR 和 HSACO/cubin 均与发布 manifest 逐字节相同。现有回归通过，condition、pair-trial、regions、similarity 四个已知缺件按 KNOWN_FAILURES 跳过。 [测试结果](normalize-candidate-20261120/test-status.txt) · [关闭开关的重建 SHA-256](normalize-candidate-20261120/release-off.json)

## 3. 完整 Greedy

| Case | off 提交／TTI／秒 | on 提交／TTI／秒 | normalize-only 轮次 | 首处分歧（提交序号，off→on） | 最终 IR／代码对象 |
| --- | ---: | ---: | --- | --- | --- |
| vllm | 224／2619／103.862 | 225／2619／164.033 | 1 | #1，b2b-anchor-1 5423→5232 → normalize-only 5423→5243 | 不同／相同 |
| MapAiry | 29／4099／28.788 | 30／4099／45.408 | 11 | #11，b2b-anchor-1 4602→4582 → normalize-only 4602→4591 | 不同／相同 |
| tigre | 6／946／1.107 | 6／946／1.406 | — | — | 相同／相同 |
| HLLD | 5／1696／0.891 | 5／1696／1.137 | — | — | 相同／相同 |
| NQU64 | 1／282／0.195 | 2／274／0.325 | 2 | #2，— → normalize-only 282→274 | 不同／不同 |
| MS32 | 1／212／0.339 | 2／198／0.295 | 1 | #1，b2b-anchor-6 370→212 → normalize-only 370→218 | 不同／不同 |
| PCM32 | 17／1138／3.476 | 17／1138／3.807 | — | — | 相同／相同 |
| SRAD16 | 4／452／0.827 | 4／452／0.801 | — | — | 相同／相同 |
| SRAD32 | 4／452／0.835 | 4／452／0.801 | — | — | 相同／相同 |
| Landau | 20／1708／14.766 | 20／1708／26.955 | — | — | 相同／相同 |
| SW2D | 0／1926／0.728 | 1／1925／1.563 | 3 | #1，— → normalize-only 1926→1925 | 不同／相同 |
| CED | 5／280／0.478 | 5／280／0.509 | — | — | 相同／相同 |
| TPACF | 12／483／14.562 | 29／263／14.653 | 1, 2, 9, 10, 17, 18, 25, 26 | #1，darm-B2R 592→582 → normalize-only 592→580 | 不同／不同 |
| SRAD-stage2 | 2／210／0.243 | 2／210／0.237 | — | — | 相同／相同 |
| SasPoint5 | 8／491／1.900 | 8／491／2.933 | — | — | 相同／相同 |
| HiPIMS-George | 4／5572／20.742 | 5／5572／38.933 | 1 | #1，b2b-anchor-1 5588→5582 → normalize-only 5588→5583 | 不同／相同 |

轮次从 1 开始，包含没有提交的轮次。秒数为本批各次完整 Greedy 的墙钟耗时。首处若新增或替换为 normalize-only，是该轮归一化 control 严格优于父状态且赢得本轮竞争。所有归一化的两个 uniform gain、无法计算的原因和完整提交序列见 [Greedy 原始结果](normalize-candidate-20261120/greedy.json)。

## 4. GPU 判定

A/A 的重测按 docs/RELEASE.md 新规则执行。第一次失败时，同一设备锁会话中只允许再试一次。通过后测 baseline、off、on 12 轮，阈值为 1.02。GPU 比均为逐轮比值的中位数。输出校验和所有原始数据按实际已执行的工作负载保存。

| 工作负载 | A/A 中位数／跨度（如有重测则两组） | on/off | 95% 区间 | on/baseline | off/baseline | 判定 |
| --- | --- | ---: | --- | ---: | ---: | --- |
| NQU64/release | 1.00059／129.56%；1.00395／189.79% | — | — | — | — | unmeasurable |
| MS32/release | 1.00004／3.61%；0.99488／3.28% | — | — | — | — | unmeasurable |
| vllm/64K | 0.99892／5.50%；1.00175／5.67% | — | — | — | — | unmeasurable |
| vllm/128K | 1.00147／2.39% | 0.99994 | [0.99457, 1.00067] | 0.73429 | 0.73549 | passed |
| MapAiry/65539 | 1.00000／2.07% | 1.00000 | [0.99745, 1.00513] | 0.36862 | 0.36862 | passed |
| TPACF/16384 | 0.99596／1.52% | 0.89920 | [0.89730, 0.90113] | 1.08026 | 1.20089 | passed |
| SW2D/258x259 | 0.99639／1.96% | 0.99278 | [0.98802, 0.99818] | 0.98856 | 0.99640 | passed |
| HiPIMS-George/128x128 | 1.00000／1.17% | 0.99865 | [0.99783, 1.00000] | 0.99791 | 1.00000 | passed |
| CED | — | — | — | — | — | ir_alias |
| HLLD | — | — | — | — | — | ir_alias |
| Landau | — | — | — | — | — | ir_alias |
| PCM32 | — | — | — | — | — | ir_alias |
| SRAD-stage2 | — | — | — | — | — | ir_alias |
| SRAD16 | — | — | — | — | — | ir_alias |
| SRAD32 | — | — | — | — | — | ir_alias |
| SasPoint5 | — | — | — | — | — | ir_alias |
| tigre | — | — | — | — | — | ir_alias |

[GPU 批次、完整验证与逐轮值](normalize-candidate-20261120/gpu.json)

## 5. 判定限制与归一化退化

已判定的 GPU 工作负载中未出现超过 2% 的退化。无法测量的工作负载没有新的性能判定。
- NQU64/release 无法测量，both A/A attempts failed。
- MS32/release 无法测量，both A/A attempts failed。
- vllm/64K 无法测量，both A/A attempts failed。

NQU64 的 baseline、off、on 均为 2,279,184 解，输入指纹 dce970f2732b8f02，输出指纹 3fa1162a3cadaeea。[本轮输出校验](normalize-candidate-20261120/nqu64-output-validation.csv)

NQU64 的 on 与此前 G1 的 HSACO 逐字节相同。历史同批 G1/G 为 0.8714，95% 区间 [0.8693, 0.8759]。本轮两次 A/A 均未通过，因此该历史结果不计作本轮通过。

TPACF 在第一轮由 off 的 darm-B2R（592→582）转为 normalize-only（592→580），随后整条搜索链改变。8 次归一化的 uniform_gain_false 交替为 +5、+4，uniform_gain_true 均为 −3。最终代码比 off 快约 10.1%，仍比不融合慢约 8.0%。本轮只比较最终产物，未隔离单次提交的 GPU 影响。

vLLM、Map-Airy、SW2D、HiPIMS-George 的最终 IR 有变化，代码对象与 off 字节相同，仍按非 IR 别名执行 A/A 与适用的正式计时。用通过的工作负载做判定，另外三项因 A/A 未通过而没有本轮速度结论，故不能确认发布清单的全量 GPU 门槛。
