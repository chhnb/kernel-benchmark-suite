# 归一化对照提交复验

分支从 feature/anchor-default 的 `86cd7d8` 开始。`decision-greedy` 新增默认关闭的 `--commit-normalize-only` 开关。

开启时，每轮对已经通过原有准备检查的每一组条件归一化输入，走与融合试验相同的 cleanup，导出未融合对照并验证 IR。每个准备输入只给未融合对照报价一次。对照的 throughput TTI 严格低于当前父状态时，进入本轮候选。无法报价的对照跳过。融合仍需严格优于自身同 cleanup 对照与当前父状态，也须按原顺序严格优于当前最优候选。多个同分对照沿用候选枚举顺序。

归一化对照获胜时，提交清理后的 IR，在该轮记录写入 `selected_kind=normalize-only`。有活动的顺序臂绑定时，清除临时边界标记并重新发现 CFG。归一化没有合并两个臂，因此不调用用于融合赢家的臂范围合并逻辑。回归测试使用冻结 NQU64 输入，检查默认一笔融合、开启后增加一笔归一化提交，以及打平的融合候选依然被拒绝。

[Greedy driver](../../tools/decision_greedy_main.cpp) · [NQU64 回归测试](../../tests/fusion-search/check-normalize-commit.py)

## 离线复跑

EPYC 干净构建通过。测试矩阵 16 项通过、4 项按 `KNOWN_FAILURES` 缺件跳过，`tests/run-v1` 中新增的 NQU64 检查通过。冻结输入上完整运行 16×2 次 Greedy。同一 case 两档使用发布 manifest 中相同的路径，排除了序列化路径造成的 IR 差异。32 份最终 IR 都过 LLVM verifier。关闭开关时，16 例最终 IR 与 HSACO／cubin 均与 `86cd7d8` 对应的最终复验产物逐字节一致。

开启时，**8 例最终 IR 变化，其中 4 例代码对象变化**。下面的提交编号以开启后的提交链为准。

| Case | 提交数 关 → 开 | 最终 TTI 关 → 开 | 最终 IR | HSACO／cubin | normalize-only 提交 |
| --- | ---: | ---: | --- | --- | --- |
| vllm | 224 → 225 | 2619 → 2619 | 变化 | 相同 | 1 (5423→5243) |
| MapAiry | 29 → 31 | 4099 → 4065 | 变化 | 变化 | 11 (4602→4591)、12 (4591→4582)、14 (4573→4564)、16 (4555→4546)、18 (4537→4528)、20 (4519→4510)、22 (4501→4492)、24 (4481→4472) |
| tigre | 6 → 6 | 946 → 946 | 相同 | 相同 | — |
| HLLD | 5 → 5 | 1696 → 1696 | 变化 | 相同 | 5 (1699→1696) |
| NQU64 | 1 → 2 | 282 → 274 | 变化 | 变化 | 2 (282→274) |
| MS32 | 1 → 2 | 212 → 198 | 变化 | 变化 | 1 (370→218) |
| PCM32 | 17 → 17 | 1138 → 1138 | 相同 | 相同 | — |
| SRAD16 | 4 → 4 | 452 → 452 | 相同 | 相同 | — |
| SRAD32 | 4 → 4 | 452 → 452 | 相同 | 相同 | — |
| Landau | 20 → 20 | 1708 → 1708 | 相同 | 相同 | — |
| SW2D | 0 → 1 | 1926 → 1925 | 变化 | 相同 | 1 (1926→1925) |
| CED | 5 → 5 | 280 → 280 | 相同 | 相同 | — |
| TPACF | 12 → 23 | 483 → 325 | 变化 | 变化 | 1 (592→580)、2 (580→568)、3 (568→556)、4 (556→544)、5 (544→532)、6 (532→520)、7 (520→508)、8 (508→496)、9 (496→484)、10 (484→472)、11 (472→460)、12 (460→448)、13 (448→436)、14 (436→424)、15 (424→412)、16 (412→400)、17 (400→388)、18 (388→376)、19 (376→364)、20 (364→352) |
| SRAD-stage2 | 2 → 2 | 210 → 210 | 相同 | 相同 | — |
| SasPoint5 | 8 → 8 | 491 → 491 | 相同 | 相同 | — |
| HiPIMS-George | 4 → 5 | 5572 → 5572 | 变化 | 相同 | 1 (5588→5583) |

候选定位按上表中的提交号索引。

| Case | 提交／搜索轮 | 准备臂（左／右） |
| --- | --- | --- |
| vllm | 1／1 | `%cond.false.i72.i`／`%cond.true.i69.i` |
| MapAiry | 11／11 | `%if.then20.i.i.i.i`／`%decision.dispatch)` |
| MapAiry | 12／13 | `%if.else21.i.i.i634.i.i.i.i`／`%if.then14.i.i.i627.i.i.i.i` |
| MapAiry | 14／16 | `%if.else21.i.i.i513.i.i.i.i`／`%if.then14.i.i.i506.i.i.i.i` |
| MapAiry | 16／19 | `%if.else21.i.i.i400.i.i.i.i`／`%if.then14.i.i.i393.i.i.i.i` |
| MapAiry | 18／22 | `%if.else21.i.i.i287.i.i.i.i`／`%if.then14.i.i.i280.i.i.i.i` |
| MapAiry | 20／25 | `%if.else21.i.i.i206.i.i.i.i`／`%if.then14.i.i.i199.i.i.i.i` |
| MapAiry | 22／28 | `%if.else21.i.i.i125.i.i.i.i`／`%if.then14.i.i.i118.i.i.i.i` |
| MapAiry | 24／31 | `%if.else21.i.i.i44.i.i.i.i`／`%if.then14.i.i.i37.i.i.i.i` |
| HLLD | 5／6 | `%merged.bb31`／`%merged.bb32` |
| NQU64 | 2／2 | `%merged.bb13`／`%merged.bb` |
| MS32 | 1／1 | `%188`／`%189` |
| SW2D | 1／3 | `%694`／`%697` |
| TPACF | 1／1 | `%105`／`%111` |
| TPACF | 2／2 | `%decision.dispatch`／`%109` |
| TPACF | 3／3 | `%110`／`%116` |
| TPACF | 4／4 | `%decision.dispatch`／`%114` |
| TPACF | 5／5 | `%115`／`%121` |
| TPACF | 6／6 | `%decision.dispatch`／`%119` |
| TPACF | 7／7 | `%120`／`%126` |
| TPACF | 8／8 | `%decision.dispatch`／`%124` |
| TPACF | 9／9 | `%125`／`%131` |
| TPACF | 10／10 | `%decision.dispatch`／`%129` |
| TPACF | 11／11 | `%130`／`%136` |
| TPACF | 12／12 | `%decision.dispatch`／`%134` |
| TPACF | 13／13 | `%135`／`%141` |
| TPACF | 14／14 | `%decision.dispatch`／`%139` |
| TPACF | 15／15 | `%140`／`%146` |
| TPACF | 16／16 | `%decision.dispatch`／`%144` |
| TPACF | 17／17 | `%145`／`%151` |
| TPACF | 18／18 | `%decision.dispatch`／`%149` |
| TPACF | 19／19 | `%150`／`%156` |
| TPACF | 20／20 | `%decision.dispatch`／`%154` |
| HiPIMS-George | 1／1 | `%391`／`%398` |

NQU64 的第二笔提交直接采用 TTI 274 的未融合对照。其 HSACO 已与历史 G1 原件使用 `cmp` 逐字节核对，SHA-256 同为 `83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b`。 [历史原件校验和](https://github.com/chhnb/kernel-benchmark-suite/blob/14775f2/regression/records/nqu-second-fusion-20261120/followup-hsaco-sha256.txt)

TPACF 的前 20 笔提交均为归一化，每笔降低 12 点 throughput TTI，后面仍有 3 笔融合。其最终 IR 与 HSACO 均变化，性能结论取决于后面的计时门槛。

## GPU 复跑

覆盖所有 8 个最终产物变化的 case，共 9 个输入。四个同进程交错角色为冻结 baseline、关闭开关、开启开关、Auto DARM。A/A 用两份关闭开关的对象，每个批次预热至少 200 ms，12 轮完整输出校验。A/A 门槛为中位数在 1±1%、跨度不超过 3%，失败允许立即重试一次。正式对照同样跑 12 轮，对逐轮耗时比做 10,000 次配对 bootstrap，报告中位数与 95% 区间。MapAiry 沿用发布复验每角色每轮 300 次取中位数的方式。AMD 使用 Radeon VII（gfx906），CUDA 使用 RTX 3090。vLLM 的 Auto DARM 角色沿用无区域复制版本。

5 个输入通过门槛并完成四角色测量。4 个输入连续两次 A/A 超限，结束各自计时。所有已执行的完整输出校验均通过。

| 输入 | 开／关，95% 区间 | 开／Auto DARM，95% 区间 | A/A 中位数／跨度 | 状态 |
| --- | --- | --- | --- | --- |
| NQU64 | 0.86991 [0.86645, 0.87166] | 0.97980 [0.97622, 0.98667] | 1.00046／1.31% | 12 轮完整输出通过 |
| HLLD/65536 | — | — | 0.99189／35.28%、1.00001／30.36% | 无法可靠计时 |
| TPACF/16384 | — | — | 0.99873／10.87%、1.00341／10.64% | 无法可靠计时 |
| SW2D/258x259 | — | — | 1.00001／10.45%、0.99629／12.11% | 无法可靠计时 |
| MS32 | — | — | 1.00026／3.04%、0.99926／3.07% | 无法可靠计时 |
| MapAiry/65539 | 1.00000 [1.00000, 1.00000] | 0.69595 [0.69595, 0.69595] | 1.00000／0.00% | 12 轮完整输出通过 |
| vllm/64K | 1.00060 [0.99847, 1.00079] | 0.82559 [0.82469, 0.82742] | 0.99974／0.69% | 12 轮完整输出通过 |
| vllm/128K | 1.00011 [0.99721, 1.00961] | 0.82808 [0.82115, 0.83351] | 1.00000／2.15% | 12 轮完整输出通过 |
| HiPIMS-George/128x128 | 0.99930 [0.99850, 1.00000] | 0.99932 [0.99850, 1.00000] | 1.00007／0.76% | 12 轮完整输出通过 |

### 字节匹配的历史参考

- **MS32。** 本轮两次 A/A 跨度为 3.0438% 和 3.0737%。从上轮保存的实验归档提取历史 off 和 on 对象，与本轮两档分别作 `cmp`，均逐字节相同。历史正式批次通过 A/A 和完整输出校验。开／关为 **0.97492 [0.97327, 0.97616]**。另一场历史同批测量中，开启对象和本轮 Auto DARM 对象的 SHA-256 均匹配，开／Auto DARM 为 **0.99356 [0.99274, 0.99589]**。 [历史开关批次](https://github.com/chhnb/kernel-benchmark-suite/blob/1904899/regression/records/normalize-candidate-20261120/gpu-all-historical-v5.json) · [历史 Auto DARM 批次](https://github.com/chhnb/kernel-benchmark-suite/blob/1904899/regression/records/normalize-candidate-20261120/gpu-on-vs-auto-darm-v6.json)
- **HLLD。** 两档 HSACO 都与发布对象逐字节一致。相同发布对象的历史发布／baseline 为 **1.09276 [1.08917, 1.09846]**。历史 Auto DARM 对象的哈希与本轮的角色不同，当前角色对照留空。 [历史发布测量](final-rerun-20261121.md#计时排除的历史参考)
- **SW2D。** 四个角色的 HSACO 均与冻结发布对象逐字节一致。相同发布对象的历史发布／baseline 为 **1.00000 [0.99754, 1.00123]**。 [历史发布测量](final-rerun-20261121.md#计时排除的历史参考)
- **TPACF。** 开启后的 HSACO 发生变化，仓库中的历史测量记录没有匹配的开启对象 SHA-256。

### 退化门槛

通过 A/A 的新测量中，开／关的 95% 区间没有一项完全高于 1.02。MS32 的字节匹配历史数据也低于该门槛。TPACF 的新代码对象没有可靠时比，本轮无法判定其性能方向。

## 原始数据

EPYC 目录为 `/data/home/chh/simplify-v2/build/normalize-commit.cZRDHj/`。逐例汇总保留完整提交日志、两档最终 IR 和代码对象，计时目录保存各角色逐轮输出验证和 A/A 原始值。

| 文件 | SHA-256 |
| --- | --- |
| `offline/results.json` | `7b213d9669d67c055b51693cf2f670193e7b01eee39f14b9e47120a1a6e8f5af` |
| `gpu-roles/roles.json` | `d103c4c61ff64eda0cd5fe4369f029a80274f624aca53d05bdd8d94c2a8da6fb` |
| `gpu-results/results.json` | `d9cd0fa5aa3cbf08f6d5c951eb3082a5e10fc09d6be3bf03abcc0393607862cb` |
