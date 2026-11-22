# Anchor B2B 第 6a 步：清理与逐 wave 条件诊断

## 旧方案与本步范围

执行前，本地 `feat/anchor-unified-dp` 和 `origin/feat/anchor-unified-dp` 均在 `a4f2b34ced1d3368e0b71e7dd684360883e82305`。旧第 6 步草稿尚未提交或推送。已将整个工作树草稿（含未跟踪文件）保存于本地 stash `d78e90ff8601566f49f267daa2ea1b786f47b75d`，再从干净的第 5 步重做。该 stash 包含旧的条件分类、auto 定价、发射和 gate 草稿。

删除 live cutoff、eager gap ranking 和各自专用用例。保留 `--anchor-cutoff static`、`--anchor-gap-rank lazy` 的兼容拼法。分类走 `--anchor-condition-only 1` 观测入口。只读诊断可额外接收 `--anchor-wave-shape X,Y,Z`。新的分类不参与布局生成、发射、cleanup、打分或接受。

## 结论

- LUD8 的两处均为 **must-diverge**，对应 L/G0 共 3 条记录。G0 的写回收益 +19，两侧报价 −27/−5，因 must-diverge 豁免。
- NQU64 的 G0 第 3 次守护提交（`B2:B19:B21`，`%decision.dispatch / %merged.bb16`）为 **unknown**。launch 是 64×1×1，一个 wave。条件依赖多个地址空间中的 load 和归并 PHI，无法证明混合 wave 数。cleanup TTI 274 → 270，侧向报价 −5/+4。两种政策都拒绝该历史方案。此前该提交回退与 D 产物相同，同批 G0/D 为 1.04886 [1.04364, 1.05543]。
- 247 条记录中 **11 must-diverge、4 mixed、232 unknown、0 must-uniform**。放行缺失报价拒绝 **88** 条（7 个 case），拒绝缺失报价拒绝 **168** 条（9 个 case）。既有收益和退化仍同时落在 unknown 内。此推算使用历史父 IR，拒掉一条后完整搜索可能进入别的路径，不能外推新的最终产物或 GPU 时比。

## 方法与命令

使用第 5 步 `profiles-final.json`（SHA-256 `1bdf5e98ca38029aca822b1d500d06fc891b20c9b676a2c7c22b1fa73ef91b3e`），逐项验证所选融合请求实际读取的父 IR SHA-256、分支位置及条件文本。参与归一化的请求使用准备后的父 IR。每个已冻结的 launch 形状由对应 kernel 的输入说明 `block` 或对应 host launch 证实；无外部形状才查 `!reqd_work_group_size`。单独的 flat-work-group-size 和 workitem `!range` 不推断形状。

gfx906 取 64，NVPTX 取 32。按 x 最快、再 y、再 z 的次序把 workgroup 切成 wave，最后一个不足额的 wave 只计有效线程。使用 LLVM APInt 按 IR 整数位宽求值，检查 `!range` 和 `nuw/nsw`，无法安全求值则记 unknown。本步支持目标 workitem ID、常量及受支持的纯整数计算。缺少确定值的 kernel 参数、workgroup ID、load、PHI 和未支持操作保守归入 unknown。分类表示完整 launch wave 的谓词取值，外层控制流在实际执行中可能屏蔽部分 lane。

- EPYC 在 `/data/home/chh/simplify-v2/build/anchor-dp-step6a.Gkh2mR`。第 4 步静态参考是同一 build 根目录的 `anchor-dp-step4.hrZeK1/static-final.json`。
- 远端脚本和日志均留在该目录。构建使用 `compile-anchor-step3.sh diagnostic`、`link-anchor-step2.sh diagnostic`。使用 `/data/home/chh/v2-runtime/reproduce.json` 中的固定工具链环境。第 4 步对照用 `anchor-step6-cleanup.py`，c7 对照用 `anchor-step6a-parity.py`，分类用 `anchor-step6a-profile.py`，HLLD复跑用 `anchor-step6a-hlld-repeat.py`。
- `tests-r2.log` 记录 `bash test-anchor-step1.sh diagnostic final-anchor-dp-step6a-r2`。
- 本步无 GPU 新计时，GPU 数据引用[第 4 步](anchor-unified-dp-step4-20261122.md)和[第 5 步](anchor-unified-dp-step5-20261122.md)。未改冻结输入或 reference。

```sh
"$search" --ir "$trial_parent" --function "$function" --split "$split" \
  --anchor-condition-only 1 --anchor-wave-shape "$x,$y,$z" --out "$diagnostic_json"
DECISION_GREEDY_JOBS=8 "$greedy" "$frozen_ir" "$function" "$tool_root" active
"$opt" -verify -disable-output active/final.ll
```

## 确切形状与重点核对

下表中的 fixture 按发布 manifest 的 `gpu_workloads` 查找，其 `input.txt` 第 3 行为 workgroup 形状。host 源码若为 build 树中的路径，相对于 `/data/home/chh/simplify-v2/build`。

| Case | workgroup x×y×z | 来源 |
| --- | --- | --- |
| CED | 16×16×1 | `cases/ced/harness/bench.hip:14` |
| HiPIMS-George | 128×1×1 | HiPIMS-George/128x128 |
| HLLD | 128×1×1 | HLLD/65536 |
| Landau | 256×1×1 | Landau/mixed、Landau/coherent |
| LUD8 | 16×1×1 | `darm-paper-repro.AtXc3N/validated-source/LUD/block_size.h:5`、`darm-paper-repro.AtXc3N/validated-source/LUD/lud_kernel.hip.cpp:215` |
| MapAiry | 256×1×1 | MapAiry/65539 |
| MS32 | 32×1×1 | `auto-darm-release-compare/20261120-v1/sort.hip:17,92–93` |
| NQU64 | 64×1×1 | `retest-release-315.BRiNaz/nqu-original.hip:41,85` |
| PCM32 | 32×1×1 | `auto-darm-release-compare/20261120-v1/sort.hip:17,85–86` |
| SasPoint5 | 256×1×1 | SasPoint5/interval-mixture、SasPoint5/coherent-blocks、SasPoint5/uniform-01 |
| SRAD-stage2 | 16×16×1 | SRAD-stage2/256、SRAD-stage2/1024 |
| SRAD16 | 16×16×1 | SRAD16/256 |
| SRAD32 | 32×32×1 | SRAD32/256 |
| SW2D | 1024×1×1 | SW2D/258x259 |
| tigre | 9×9×9 | `srad-stability/20261120-v2/tigre.hip:66` |
| TPACF | 128×1×1 | `cases/tpacf/harness/bench.hip:37` |
| vllm | 64×1×1 | vllm/64K、vllm/128K |

- **LUD8**。源码 `BLOCK_SIZE=8`，perimeter 用 `dim3(BLOCK_SIZE*2)`。两处谓词都是 `tid.x < 8`。同一个 partial wave 中 8 真、8 假，混合 1/1。
- **CED**。冻结 runner 用 16×16×1。两个分支都是 `tid.x == 0`。x 最快，每 wave 覆盖 4 行，每行 1 真、15 假，混合 4/4。两种配置各命中 2 次。历史 A/A 两次离散度超限，仍无 GPU 时比。
- **SRAD16**。16×16×1，每 wave 4 行。`tid.x == 15` 每行有 1 真，混合 4/4。`tid.y == 0` 仅第一 wave 混合，其余 wave 全假，混合 1/4。
- **SRAD32**。32×32×1，每 wave 2 行。`tid.x == 31` 混合 16/16；`tid.y == 0` 混合 1/16。fixture 名末尾的 `256` 是输入规格，实际 workgroup 有 1024 个线程。
- **NQU64**。`nqu-original.hip` 用 64×1×1。`%decision.take` 汇合 workitem/workgroup 相关值、load（addrspace 1/3/4）与 PHI。可数得总 wave 1，混合数未知。

## GPU 证据与 gate 推算

同一 case/配置的历史 GPU 结论附到其每条记录，表示该最终产物的上下文。只有 NQU64、SasPoint5 守护等已有回退对照的位置可以单独归因。收益或退化以已有可靠方向为准，SRAD 区间跨过 1 记为未分辨，CED 单独记为未测，HiPIMS-George 为 GPU 对象别名。相反方向可分别计入两栏，例如同一 Landau 产物在 mixed 受益、coherent 退化。

| 分类 | 条数 | 已知收益 | 已知退化 | 已计时未分辨 | 对象别名 | 无可靠计时 | 缺失放行时拒绝 | 缺失拒绝时拒绝 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| must-diverge | 11 | 3 | 0 | 4 | 0 | 4 | 0 | 0 |
| must-uniform | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| mixed | 4 | 0 | 0 | 4 | 0 | 0 | 4 | 4 |
| unknown | 232 | 95 | 174 | 0 | 2 | 0 | 84 | 164 |

对非豁免项要求 false/true 的同父一致代价收益都非负。已知负值优先拒绝；仅有缺失时，分别模拟放行和拒绝。下表每格是「缺失放行时拒绝数／缺失拒绝时拒绝数」，具体步骤见逐条表。

| Case | L | G0 |
| --- | ---: | ---: |
| CED | 0 / 0 | 0 / 0 |
| HiPIMS-George | 1 / 1 | 1 / 1 |
| HLLD | 0 / 2 | 0 / 2 |
| Landau | 13 / 17 | 13 / 17 |
| LUD8 | 0 / 0 | 0 / 0 |
| MapAiry | 23 / 25 | 23 / 25 |
| NQU64 | — | 1 / 1 |
| SasPoint5 | 4 / 4 | 5 / 5 |
| SRAD16 | 1 / 1 | 1 / 1 |
| SRAD32 | 1 / 1 | 1 / 1 |
| tigre | 0 / 0 | 0 / 0 |
| vllm | 0 / 32 | 0 / 32 |

两种政策都保住 LUD8 的历史线性和写回提交，都拒掉 NQU64 的历史守护提交，也都会挡掉 MapAiry、Landau、SasPoint5 的收益路径。拒绝缺报价额外覆盖 vLLM 的 64 条记录（每配置 32、另一半仍通过），也覆盖 HLLD 的 4 条、Landau 的 8 条和 MapAiry 的 4 条。tigre 的两条 +1/+9 均通过。

## 构建、测试与逐字节核对

EPYC 构建成功。回归 **16 通过、4 跳过**。跳过项为 `condition`、`pair-trial`、`regions`、`similarity`（`tests/KNOWN_FAILURES.md`）。保留 Anchor segment/发射、normalize-only、TTI quotes、trial queue、commit-score 相关回归。新增的 8 个断言覆盖 wave64 的 16/256 一维线程组、二维 x=16、阈值 64 的两种形状、仅有上界、load 条件与 NVPTX wave32。首次测试重复使用同一输出路径触发诊断拒绝覆盖；修正测试路径后完整复跑通过。LLVM12 首次编译发现较新 API 不可用，改用 LLVM12 的 APInt 与比较接口后重建。

删除分支后实际 Greedy 重跑 **68/68** 次（D/L/G0/G1 × 17），最终 IR SHA-256、提交数、最终 throughput TTI 都与第 4 步一致，并通过 LLVM verifier。D 另用实际含只读诊断的二进制与 `c7dded07` 同输入、同相对序列化路径完整复跑。对比每个落盘 `.ll`，仅允许同一行 `; preds =` 列表重排；评分比较逐轮尝试、获选项、同父对照、逐布局 `score_result` 和侧向报价，去除时间、环境和工具路径字段。最终 IR 逐字节一致 17/17，候选 IR 和评分验证 16/17。检查 7574 份共同路径 IR，其中 652 份差异仅为已知的 preds 注释顺序。

| Case | D 提交/TTI | L 提交/TTI | G0 提交/TTI | G1 提交/TTI | D 对 c7 的 IR 数 | 仅 preds 差异 | 其他 IR 差异 | 评分相同 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| CED | 5/280 | 3/281 | 3/281 | 3/281 | 29 | 1 | 0 | 是 |
| HiPIMS-George | 5/5572 | 4/5572 | 4/5572 | 4/5572 | 187 | 9 | 0 | 是 |
| HLLD | 5/1696 | 4/1700 | 4/1700 | 4/1700 | 66 | 2 | 2 | 否 |
| Landau | 20/1708 | 19/1066 | 19/1066 | 19/1061 | 849 | 88 | 0 | 是 |
| LUD8 | 1/735 | 1/666 | 2/637 | 3/638 | 9 | 0 | 0 | 是 |
| MapAiry | 31/4065 | 30/3660 | 30/3660 | 30/3661 | 745 | 36 | 0 | 是 |
| MS32 | 2/198 | 2/198 | 2/198 | 2/198 | 15 | 0 | 0 | 是 |
| NQU64 | 2/274 | 2/274 | 3/270 | 3/270 | 30 | 0 | 0 | 是 |
| PCM32 | 17/1138 | 17/1138 | 17/1138 | 17/1138 | 103 | 0 | 0 | 是 |
| SasPoint5 | 8/491 | 7/485 | 8/458 | 8/458 | 205 | 20 | 0 | 是 |
| SRAD-stage2 | 2/210 | 2/210 | 2/210 | 2/210 | 11 | 0 | 0 | 是 |
| SRAD16 | 4/452 | 4/437 | 4/437 | 4/437 | 30 | 0 | 0 | 是 |
| SRAD32 | 4/452 | 4/437 | 4/437 | 4/437 | 30 | 0 | 0 | 是 |
| SW2D | 1/1925 | 1/1925 | 1/1925 | 1/1925 | 33 | 1 | 0 | 是 |
| tigre | 6/946 | 5/944 | 5/944 | 5/944 | 49 | 2 | 0 | 是 |
| TPACF | 23/325 | 23/325 | 23/325 | 23/325 | 1874 | 203 | 0 | 是 |
| vllm | 225/2619 | 225/2619 | 225/2619 | 225/2619 | 3309 | 290 | 0 | 是 |

### HLLD 验收例外

HLLD 的 `B9:B22:B12` 与 `B9:B21:B12` 都走 DARM R2B 路径，分别落在 `trial-11/fused.ll` 和 `trial-23/fused.ll`，两者均未获选。差异包含 fcmp 谓词翻转和是否保留一个 `and i1`，不是 preds 注释。主对照中各自的 c7 → 6a 报价为 1839→1838 和 1804→1805，控制分别为 1847 和 1747，最终提交链相同，最终 TTI 1696，最终 IR 哈希 `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de`。

用第 5 步未改的二进制，对两份相同父 IR 分别独立重放 20 次（`anchor-step6a-hlld-isolated.py`）。第一处分别得到 1839（15 次）和 1838（5 次），第二处得到 1805（18 次）和 1804（2 次），两种 IR 哈希与跨版本对照中出现的两种形态相同。第二处仅凭同一份 6a 二进制完整重跑也能复现两个分数。证据定位到旧的 R2B 试融路径；具体触发环节未定位。严格候选和评分验收在 HLLD 未通过，本提交只记录该异常。

### 二进制与收据 SHA-256

| 工件 | SHA-256 |
| --- | --- |
| 6a `diagnostic/build/decision-fuse/decision-greedy` | `6ad0b0cf758e0b5dac44afe69c99cb630941ec44e47b22f36cc9f670b098323f` |
| 6a `diagnostic/build/llvm24-tti/fusion-search-llvm24` | `b1b0c9cb1bf19f6acfb959f3fc4f1c79654048cab6c484fe753c28e5af0f8de7` |
| 6a 固定 throughput worker `llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| 仅删除分支的 `cleanup/build/decision-fuse/decision-greedy` | `2ff4bcaf53154de0e544be55a14ea24875d35b26f0c5755bf54a65dfecdebf8b` |
| 仅删除分支的 `cleanup/build/llvm24-tti/fusion-search-llvm24` | `e558a7ed21538d28ea6028ad394fd676b59b091b0c1bfd13e68856a747f19b44` |
| c7 `decision-greedy` | `fa1795b80acec0a7afd72c435853455524a04aaef7fb992f7554368d9e61074d` |
| c7 `fusion-search-llvm24` | `892bcad9b23338819f446dde95bf9fda0e3bc9ce90af4efe96e838fb8dfdf4a2` |
| `wave-conditions.json` | `46c87d771af39cc86bdeeeef76a94355cda49a851263929b00735e735a7ad1f4` |
| `cleanup-static.json` | `db5f6ebee4d3b27f74cae208a9ec45609caeabfbfdcc1b90fc56019075d12aed` |
| 回归 `results.json` | `54700b3396da17fe3ee8e3820f32543ee1bf54ae2ec10aa7ca0629e949151a04` |

逐案 c7 对照在 `baseline-parity/<case>/report.json`，HLLD 固定父 IR 复验在 `hlld-step5-isolated.log`。

## 全部 247 条历史记录

每行对应一个 `case/config/commit`。位置为实际父 IR 的 split/left/right block ID，形状来源见前表。侧报价与普通 gain 来自第 5 步的同父报价。gate 两列顺序合并为「缺失放行／缺失拒绝」，「—」表示缺失或不可确定。

| Case | 配置 | 提交 | 父 IR block ID | 布局 | 分类 | 形状 | 混合/总 wave | Gain | False | True | Gate | 历史 GPU |
| --- | --- | ---: | --- | --- | --- | --- | --- | ---: | ---: | ---: | --- | --- |
| CED | L | 2 | B15/B16/B18 | linear | must-diverge | 16×16×1 | 4/4 | 13 | 7 | 1 | 豁免 | 未测：A/A 两次超限 |
| CED | L | 3 | B1/B2/B4 | linear | must-diverge | 16×16×1 | 4/4 | 13 | 5 | 1 | 豁免 | 未测：A/A 两次超限 |
| CED | G0 | 2 | B15/B16/B18 | linear | must-diverge | 16×16×1 | 4/4 | 13 | 7 | 1 | 豁免 | 未测：A/A 两次超限 |
| CED | G0 | 3 | B1/B2/B4 | linear | must-diverge | 16×16×1 | 4/4 | 13 | 5 | 1 | 豁免 | 未测：A/A 两次超限 |
| HiPIMS-George | L | 3 | B308/B309/B310 | linear | unknown | 128×1×1 | —/4 | 3 | -8 | -8 | 拒／拒 | 同 D：GPU 对象别名 |
| HiPIMS-George | G0 | 3 | B308/B309/B310 | linear | unknown | 128×1×1 | —/4 | 3 | -8 | -8 | 拒／拒 | 同 D：GPU 对象别名 |
| HLLD | L | 2 | B20/B23/B22 | linear | unknown | 128×1×1 | —/2 | 102 | — | — | 放／拒 | 益：−1.36% |
| HLLD | L | 4 | B14/B17/B18 | linear | unknown | 128×1×1 | —/2 | 4 | — | — | 放／拒 | 益：−1.36% |
| HLLD | G0 | 2 | B20/B23/B22 | linear | unknown | 128×1×1 | —/2 | 102 | — | — | 放／拒 | 益：−1.36% |
| HLLD | G0 | 4 | B14/B17/B18 | linear | unknown | 128×1×1 | —/2 | 4 | — | — | 放／拒 | 益：−1.36% |
| Landau | L | 1 | B14/B13/B15 | linear | unknown | 256×1×1 | —/4 | 284 | -6 | -6 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 2 | B16/B15/B17 | linear | unknown | 256×1×1 | —/4 | 276 | -18 | -14 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 3 | B14/B13/B15 | linear | unknown | 256×1×1 | —/4 | 280 | -29 | -41 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 4 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -3 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 5 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -19 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 6 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -35 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 7 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -51 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 8 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -67 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 9 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -83 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 10 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -99 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 11 | B12/B11/B13 | linear | unknown | 256×1×1 | —/4 | 267 | -3 | -96 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 12 | B21/B20/B22 | linear | unknown | 256×1×1 | —/4 | 262 | -2 | -126 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 15 | B6/B5/B7 | linear | unknown | 256×1×1 | —/4 | 64 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 16 | B11/B10/B12 | linear | unknown | 256×1×1 | —/4 | 64 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 17 | B13/B10/B14 | linear | unknown | 256×1×1 | —/4 | 50 | -54 | -340 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 18 | B8/B5/B9 | linear | unknown | 256×1×1 | —/4 | 60 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | L | 19 | B6/B7/B8 | linear | unknown | 256×1×1 | —/4 | 33 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 1 | B14/B13/B15 | linear | unknown | 256×1×1 | —/4 | 284 | -6 | -6 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 2 | B16/B15/B17 | linear | unknown | 256×1×1 | —/4 | 276 | -18 | -14 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 3 | B14/B13/B15 | linear | unknown | 256×1×1 | —/4 | 280 | -29 | -41 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 4 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -3 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 5 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -19 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 6 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -35 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 7 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -51 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 8 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -67 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 9 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -83 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 10 | B25/B24/B26 | linear | unknown | 256×1×1 | —/4 | 273 | -99 | -3 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 11 | B12/B11/B13 | linear | unknown | 256×1×1 | —/4 | 267 | -3 | -96 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 12 | B21/B20/B22 | linear | unknown | 256×1×1 | —/4 | 262 | -2 | -126 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 15 | B6/B5/B7 | linear | unknown | 256×1×1 | —/4 | 64 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 16 | B11/B10/B12 | linear | unknown | 256×1×1 | —/4 | 64 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 17 | B13/B10/B14 | linear | unknown | 256×1×1 | —/4 | 50 | -54 | -340 | 拒／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 18 | B8/B5/B9 | linear | unknown | 256×1×1 | —/4 | 60 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| Landau | G0 | 19 | B6/B7/B8 | linear | unknown | 256×1×1 | —/4 | 33 | — | — | 放／拒 | 益：mixed −19.57%；退：coherent +30.07% |
| LUD8 | L | 1 | B0/B1/B2 | linear | must-diverge | 16×1×1 | 1/1 | 97 | 7 | 2 | 豁免 | 益：−6.05% |
| LUD8 | G0 | 1 | B0/B1/B2 | linear | must-diverge | 16×1×1 | 1/1 | 97 | 7 | 2 | 豁免 | 益：−10.77% |
| LUD8 | G0 | 2 | B3/B4/B5 | guarded-linear | must-diverge | 16×1×1 | 1/1 | 19 | -27 | -5 | 豁免 | 益：−10.77% |
| MapAiry | L | 1 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -3 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 2 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -19 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 3 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -35 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 4 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -51 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 5 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -67 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 6 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -83 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 7 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -99 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 8 | B96/B95/B97 | linear | unknown | 256×1×1 | —/4 | 262 | -2 | -126 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 9 | B6/B5/B7 | linear | unknown | 256×1×1 | —/4 | 67 | — | — | 放／拒 | 益：−6.73% |
| MapAiry | L | 11 | B88/B87/B89 | linear | unknown | 256×1×1 | —/4 | 66 | — | — | 放／拒 | 益：−6.73% |
| MapAiry | L | 12 | B90/B87/B91 | linear | unknown | 256×1×1 | —/4 | 55 | -56 | -336 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 13 | B10/B11/B12 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 14 | B9/B10/B11 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 15 | B17/B18/B19 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 16 | B16/B17/B18 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 17 | B24/B25/B26 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 18 | B23/B24/B25 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 19 | B31/B32/B33 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 20 | B30/B31/B32 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 21 | B38/B39/B40 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 22 | B37/B38/B39 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 23 | B44/B45/B46 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 24 | B43/B44/B45 | linear | unknown | 256×1×1 | —/4 | 17 | -27 | 11 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 26 | B44/B45/B46 | linear | unknown | 256×1×1 | —/4 | 57 | 41 | 19 | 放／放 | 益：−6.73% |
| MapAiry | L | 28 | B55/B56/B57 | linear | unknown | 256×1×1 | —/4 | 15 | 5 | -13 | 拒／拒 | 益：−6.73% |
| MapAiry | L | 30 | B56/B57/B58 | linear | unknown | 256×1×1 | —/4 | 15 | 5 | -13 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 1 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -3 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 2 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -19 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 3 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -35 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 4 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -51 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 5 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -67 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 6 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -83 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 7 | B98/B97/B99 | linear | unknown | 256×1×1 | —/4 | 273 | -99 | -3 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 8 | B96/B95/B97 | linear | unknown | 256×1×1 | —/4 | 262 | -2 | -126 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 9 | B6/B5/B7 | linear | unknown | 256×1×1 | —/4 | 67 | — | — | 放／拒 | 益：−6.73% |
| MapAiry | G0 | 11 | B88/B87/B89 | linear | unknown | 256×1×1 | —/4 | 66 | — | — | 放／拒 | 益：−6.73% |
| MapAiry | G0 | 12 | B90/B87/B91 | linear | unknown | 256×1×1 | —/4 | 55 | -56 | -336 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 13 | B10/B11/B12 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 14 | B9/B10/B11 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 15 | B17/B18/B19 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 16 | B16/B17/B18 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 17 | B24/B25/B26 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 18 | B23/B24/B25 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 19 | B31/B32/B33 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 20 | B30/B31/B32 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 21 | B38/B39/B40 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 22 | B37/B38/B39 | linear | unknown | 256×1×1 | —/4 | 15 | -29 | 10 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 23 | B44/B45/B46 | linear | unknown | 256×1×1 | —/4 | 19 | 8 | -14 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 24 | B43/B44/B45 | linear | unknown | 256×1×1 | —/4 | 17 | -27 | 11 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 26 | B44/B45/B46 | linear | unknown | 256×1×1 | —/4 | 57 | 41 | 19 | 放／放 | 益：−6.73% |
| MapAiry | G0 | 28 | B55/B56/B57 | linear | unknown | 256×1×1 | —/4 | 15 | 5 | -13 | 拒／拒 | 益：−6.73% |
| MapAiry | G0 | 30 | B56/B57/B58 | linear | unknown | 256×1×1 | —/4 | 15 | 5 | -13 | 拒／拒 | 益：−6.73% |
| NQU64 | G0 | 3 | B2/B19/B21 | guarded-linear | unknown | 64×1×1 | —/1 | 4 | -5 | 4 | 拒／拒 | 退：+4.89% |
| SasPoint5 | L | 3 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -44 | -12 | 拒／拒 | 退：coherent +3.87%；另两输入未分辨 |
| SasPoint5 | L | 4 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -60 | -12 | 拒／拒 | 退：coherent +3.87%；另两输入未分辨 |
| SasPoint5 | L | 5 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -76 | -12 | 拒／拒 | 退：coherent +3.87%；另两输入未分辨 |
| SasPoint5 | L | 6 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -92 | -12 | 拒／拒 | 退：coherent +3.87%；另两输入未分辨 |
| SasPoint5 | G0 | 3 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -44 | -12 | 拒／拒 | 益：mixture −6.45%；退：coherent +17.39%、uniform +20.83% |
| SasPoint5 | G0 | 4 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -60 | -12 | 拒／拒 | 益：mixture −6.45%；退：coherent +17.39%、uniform +20.83% |
| SasPoint5 | G0 | 5 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -76 | -12 | 拒／拒 | 益：mixture −6.45%；退：coherent +17.39%、uniform +20.83% |
| SasPoint5 | G0 | 6 | B10/B9/B11 | linear | unknown | 256×1×1 | —/8 | 55 | -92 | -12 | 拒／拒 | 益：mixture −6.45%；退：coherent +17.39%、uniform +20.83% |
| SasPoint5 | G0 | 8 | B6/B7/B8 | guarded-linear | unknown | 256×1×1 | —/8 | 27 | -90 | -25 | 拒／拒 | 益：mixture −6.45%；退：coherent +17.39%、uniform +20.83% |
| SRAD16 | L | 3 | B24/B25/B26 | linear | must-diverge | 16×16×1 | 4/4 | 11 | 1 | -7 | 豁免 | 未分辨：区间跨 1 |
| SRAD16 | L | 4 | B22/B23/B24 | linear | mixed | 16×16×1 | 1/4 | 9 | -1 | -15 | 拒／拒 | 未分辨：区间跨 1 |
| SRAD16 | G0 | 3 | B24/B25/B26 | linear | must-diverge | 16×16×1 | 4/4 | 11 | 1 | -7 | 豁免 | 未分辨：区间跨 1 |
| SRAD16 | G0 | 4 | B22/B23/B24 | linear | mixed | 16×16×1 | 1/4 | 9 | -1 | -15 | 拒／拒 | 未分辨：区间跨 1 |
| SRAD32 | L | 3 | B24/B25/B26 | linear | must-diverge | 32×32×1 | 16/16 | 11 | 1 | -7 | 豁免 | 未分辨：区间跨 1 |
| SRAD32 | L | 4 | B22/B23/B24 | linear | mixed | 32×32×1 | 1/16 | 9 | -1 | -15 | 拒／拒 | 未分辨：区间跨 1 |
| SRAD32 | G0 | 3 | B24/B25/B26 | linear | must-diverge | 32×32×1 | 16/16 | 11 | 1 | -7 | 豁免 | 未分辨：区间跨 1 |
| SRAD32 | G0 | 4 | B22/B23/B24 | linear | mixed | 32×32×1 | 1/16 | 9 | -1 | -15 | 拒／拒 | 未分辨：区间跨 1 |
| tigre | L | 5 | B24/B23/B25 | linear | unknown | 9×9×9 | —/12 | 74 | 1 | 9 | 放／放 | 退：+0.58% |
| tigre | G0 | 5 | B24/B23/B25 | linear | unknown | 9×9×9 | —/12 | 74 | 1 | 9 | 放／放 | 退：+0.58% |
| vllm | L | 6 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 8 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 13 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 15 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 20 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 22 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 27 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 29 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 34 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 36 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 41 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 43 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 48 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 50 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 55 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 57 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 62 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 64 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 69 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 71 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 76 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 78 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 83 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 85 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 90 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 92 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 97 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 99 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 104 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 106 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 111 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 113 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 118 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 120 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 125 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 127 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 132 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 134 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 139 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 141 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 146 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 148 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 153 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 155 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 160 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 162 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 167 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 169 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 174 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 176 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 181 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 183 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 188 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 190 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 195 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 197 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 202 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 204 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 209 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 211 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 216 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 218 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 223 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | L | 225 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 6 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 8 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 13 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 15 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 20 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 22 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 27 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 29 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 34 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 36 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 41 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 43 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 48 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 50 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 55 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 57 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 62 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 64 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 69 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 71 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 76 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 78 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 83 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 85 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 90 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 92 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 97 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 99 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 104 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 106 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 111 | B37/B36/B38 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 113 | B35/B36/B37 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 118 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 120 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 125 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 127 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 132 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 134 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 139 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 141 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 146 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 148 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 153 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 155 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 160 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 162 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 167 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 169 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 174 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 176 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 181 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 183 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 188 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 190 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 195 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 197 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 202 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 204 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 209 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 211 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 216 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 218 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 223 | B52/B51/B53 | linear | unknown | 64×1×1 | —/1 | 11 | — | — | 放／拒 | 退：64K +0.75% / 128K +1.22% |
| vllm | G0 | 225 | B50/B51/B52 | linear | unknown | 64×1×1 | —/1 | 16 | 1 | 9 | 放／放 | 退：64K +0.75% / 128K +1.22% |
