# 第 10b 步 统一生成的端到端对照

五个变体使用同一冻结输入。差值为变体减 anchor，负值表示代价更低或时间更短。全流程提交和逐候选配对及放置分别见 [提交明细](step10b-commits.tsv) 与 [B2B 候选明细](step10b-candidates.tsv)。重复评估按该步当时的父 IR 记录。区域 ID 由抽取工具按当前父 IR 计算。相同位置的结构 ID 可以随上一步生成的 IR 改变。路径对照同时检查区域 ID 序列和提交后的函数体。

放置标签 all-speculate、convex-guard、all-protect、min-cut 分别对应全推测、凸包保护、全保护、最小割。附记 +convex-guard 和 +repair 表示对该放置的凸包或边界修复。候选因 §7.2 保留原样时没有放置。

GPU 采用第 4a 步的 event 计时方法，12 轮轮换、每轮每个角色预热 3 次并计量 15 次。表中区间为同轮时间比的 10,000 次 bootstrap 95% 区间。仅对绝对 TTI 差异超过 1% 的变体计时，并同轮计时 anchor。

AMD ISA 的分支包括条件分支、直接跳转和 PC 跳转。exec 列为非分支中的显式 exec 读写及 saveexec。VALU 计 v_*，SALU 排除访存、控制和等待类。HiPIMS-George 的目标为 NVIDIA，其 cubin 统计 SASS 总指令、分支、重汇合和选择。

## DCT8

输入 SHA-256 `21a5ddb82636744c691db57d4e78ffcfcaf0143b495f3129d14700d09ca9ae0d`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 62 | 0 | 通过 | 2 | 2 | 5 | 47 | 9 | 2 |
| anchor | 62 | 0 | 通过 | 2 | 2 | 5 | 47 | 9 | 2 |
| darm | 44 | 1 | 通过 | 0 | 0 | 0 | 33 | 4 | 2 |
| anchor-unified | 62 | 0 | 通过 | 2 | 2 | 5 | 47 | 9 | 2 |
| dataflow | 44 | 1 | 通过 | 0 | 0 | 0 | 33 | 4 | 2 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 无提交。
- `darm` 的区域及提交后 TTI 为 d23a7c228c5b(44)。
- `anchor-unified` 的区域及提交后 TTI 为 无提交。
- `dataflow` 的区域及提交后 TTI 为 d23a7c228c5b(44)。
- `anchor-unified` 评估 1 个直接 B2B，保留原样 1 个。无融合方案。
- `dataflow` 评估 1 个直接 B2B，保留原样 0 个。`dataflow/all-speculate` 1（提交 1）。
- `anchor-unified` 与 anchor 的提交区域序列相同。最终 TTI 差值 +0。
- `dataflow` 最先在第 1 步提交不同的区域，anchor 为 已结束，该策略为 `d23a7c228c5b`（`%2`，TTI 44）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -18。

固定 anchor 配对保留原样，新配对合并 sext 和 sdiv 后提交 d23a7c228c5b，区域报价从 (25,18,15) 到 (9,9,9)。整核清理前 46，清理后 44。这一差异来自配对。

### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | — | — | TTI 差异 0.00%，未达门槛 |
| anchor | 693.117 | — | 基准 |
| darm | 692.796 | -0.05% | [0.99942, 1.00000] |
| anchor-unified | — | — | TTI 差异 0.00%，未达门槛 |
| dataflow | 692.956 | -0.05% | [0.99942, 1.00023] |

该用例未列入本次两个 rocprof 对照。

## PCM32

输入 SHA-256 `db3b35287f1ef284e3c8dac514b05fc952a6892345b5ff0077b2840927aaab47`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 1392 | 0 | 通过 | 38 | 46 | 107 | 384 | 145 | 40 |
| anchor | 1136 | 18 | 通过 | 17 | 21 | 23 | 355 | 77 | 122 |
| darm | 1136 | 18 | 通过 | 17 | 21 | 23 | 355 | 77 | 122 |
| anchor-unified | 1136 | 18 | 通过 | 17 | 21 | 23 | 355 | 77 | 122 |
| dataflow | 1130 | 18 | 通过 | 17 | 21 | 23 | 352 | 76 | 102 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 00bc16cfd8ae(1377) → e3b15e5220a0(1362) → 00bc16cfd8ae(1347) → ed0b563f1288(1332) → 00bc16cfd8ae(1317) → e3b15e5220a0(1302) → 00bc16cfd8ae(1287) → ed0b563f1288(1272) → ed0b563f1288(1257) → 00bc16cfd8ae(1242) → e3b15e5220a0(1227) → 00bc16cfd8ae(1212) → ed0b563f1288(1197) → 6dfa89ca4f97(1187) → 00bc16cfd8ae(1168) → e3b15e5220a0(1153) → 00bc16cfd8ae(1138) → 791c6dcfa478(1136)。
- `darm` 的区域及提交后 TTI 为 00bc16cfd8ae(1377) → 6dfa89ca4f97(1367) → 00bc16cfd8ae(1348) → e3b15e5220a0(1333) → 00bc16cfd8ae(1318) → ed0b563f1288(1303) → 00bc16cfd8ae(1288) → e3b15e5220a0(1273) → 00bc16cfd8ae(1258) → ed0b563f1288(1243) → 00bc16cfd8ae(1228) → ed0b563f1288(1213) → 00bc16cfd8ae(1198) → e3b15e5220a0(1183) → 00bc16cfd8ae(1168) → ed0b563f1288(1153) → e3b15e5220a0(1138) → 791c6dcfa478(1136)。
- `anchor-unified` 的区域及提交后 TTI 为 00bc16cfd8ae(1377) → 6dfa89ca4f97(1367) → 00bc16cfd8ae(1348) → e3b15e5220a0(1333) → 00bc16cfd8ae(1318) → ed0b563f1288(1303) → 00bc16cfd8ae(1288) → e3b15e5220a0(1273) → 00bc16cfd8ae(1258) → ed0b563f1288(1243) → 00bc16cfd8ae(1228) → ed0b563f1288(1213) → 00bc16cfd8ae(1198) → e3b15e5220a0(1183) → 00bc16cfd8ae(1168) → ed0b563f1288(1153) → e3b15e5220a0(1138) → ef97ad20b297(1136)。
- `dataflow` 的区域及提交后 TTI 为 00bc16cfd8ae(1378) → 6dfa89ca4f97(1368) → 00bc16cfd8ae(1350) → e3b15e5220a0(1336) → 00bc16cfd8ae(1322) → ed0b563f1288(1308) → 00bc16cfd8ae(1294) → e3b15e5220a0(1280) → 00bc16cfd8ae(1266) → ed0b563f1288(1252) → 00bc16cfd8ae(1238) → ed0b563f1288(1224) → 00bc16cfd8ae(1210) → e3b15e5220a0(1196) → 00bc16cfd8ae(1182) → ed0b563f1288(1168) → e3b15e5220a0(1154) → 89f84284c390(1130)。
- `anchor-unified` 评估 34 个直接 B2B，保留原样 2 个。`anchor/all-speculate` 32（提交 16）。
- `dataflow` 评估 34 个直接 B2B，保留原样 2 个。`dataflow/all-speculate` 32（提交 16）。
- `anchor-unified` 最先在第 2 步提交不同的区域，anchor 为 `e3b15e5220a0`（`%275`，TTI 1362），该策略为 `6dfa89ca4f97`（`%1`，TTI 1367）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +0。
- `dataflow` 最先在第 2 步提交不同的区域，anchor 为 `e3b15e5220a0`（`%275`，TTI 1362），该策略为 `6dfa89ca4f97`（`%1`，TTI 1368）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -6。

两种统一策略第 1 步的区域相同。第 2 步 anchor 提交 e3b15e5220a0，两种统一生成均改为 6dfa89ca4f97，后者走既有间接 B2B 路径。固定配对模式最终回到 1136，新配对以 1130 收尾。

### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 892861.053 | +35.54% | [1.35533, 1.35553] |
| anchor | 658744.019 | — | 基准 |
| darm | — | — | TTI 差异 0.00%，未达门槛 |
| anchor-unified | — | — | TTI 差异 0.00%，未达门槛 |
| dataflow | — | — | TTI 差异 0.53%，未达门槛 |

该用例未列入本次两个 rocprof 对照。

## NQU64

输入 SHA-256 `41d0f06783569a082de6ce5fc01ac59b4860f89f787c607e4b81b9684938bc49`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 289 | 0 | 通过 | 13 | 15 | 36 | 69 | 47 | 0 |
| anchor | 274 | 2 | 通过 | 11 | 13 | 27 | 66 | 43 | 3 |
| darm | 274 | 2 | 通过 | 11 | 13 | 27 | 66 | 43 | 3 |
| anchor-unified | 274 | 2 | 通过 | 11 | 13 | 27 | 66 | 43 | 3 |
| dataflow | 274 | 2 | 通过 | 11 | 13 | 27 | 66 | 43 | 3 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 0ee2ac3a0c79(282) → 36fe0298cac8(274)。
- `darm` 的区域及提交后 TTI 为 0ee2ac3a0c79(282) → 36fe0298cac8(274)。
- `anchor-unified` 的区域及提交后 TTI 为 0ee2ac3a0c79(282) → 36fe0298cac8(274)。
- `dataflow` 的区域及提交后 TTI 为 0ee2ac3a0c79(282) → 36fe0298cac8(274)。
- `anchor-unified` 评估 12 个直接 B2B，保留原样 9 个。`anchor/all-speculate` 1（提交 0）、`anchor/min-cut` 2（提交 0）。
- `dataflow` 评估 12 个直接 B2B，保留原样 9 个。`dataflow/all-speculate` 1（提交 0）、`dataflow/min-cut` 2（提交 0）。
- `anchor-unified` 与 anchor 的提交区域序列相同。最终 TTI 差值 +0。
- `dataflow` 与 anchor 的提交区域序列相同。最终 TTI 差值 +0。

四条贪心轨迹都先做一次 B2R 再做一次仅归一。统一生成产生的直接 B2B 方案没有通过最终整核竞争，最终 TTI 同为 274。

### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 10358.396 | +18.69% | [1.18312, 1.18796] |
| anchor | 8732.938 | — | 基准 |
| darm | — | — | TTI 差异 0.00%，未达门槛 |
| anchor-unified | — | — | TTI 差异 0.00%，未达门槛 |
| dataflow | — | — | TTI 差异 0.00%，未达门槛 |

该用例未列入本次两个 rocprof 对照。

## SRAD16

输入 SHA-256 `ecf89ddfdc19aca349c70571b29ea5be2b95049fbce5d9815cabc7b73de016d1`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 484 | 0 | 通过 | 21 | 23 | 46 | 264 | 90 | 6 |
| anchor | 436 | 4 | 通过 | 18 | 20 | 26 | 273 | 67 | 19 |
| darm | 455 | 3 | 通过 | 19 | 21 | 34 | 273 | 79 | 14 |
| anchor-unified | 411 | 8 | 通过 | 14 | 16 | 15 | 275 | 58 | 33 |
| dataflow | 408 | 8 | 通过 | 14 | 16 | 15 | 268 | 57 | 32 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 701ab76d676a(470) → 69b92fc9723f(457) → 88091c4b8b24(445) → 3ea49ee220ea(436)。
- `darm` 的区域及提交后 TTI 为 701ab76d676a(470) → 69b92fc9723f(457) → cae5d76e62ec(455)。
- `anchor-unified` 的区域及提交后 TTI 为 701ab76d676a(470) → 9916a96229c8(457) → e38dc6234893(445) → b3bd75625514(436) → ce82c1c8dd96(433) → 52123c9b2359(430) → 353abd9ac931(427) → 83be02eada28(411)。
- `dataflow` 的区域及提交后 TTI 为 701ab76d676a(470) → 44be0ad40ca8(456) → 4a0fd7cfbd12(444) → e9cf515b3bfb(433) → 3d4cac4dbd30(430) → 4b4413b827c0(427) → aef306a0e9ff(424) → 97dd4402a8b7(408)。
- `anchor-unified` 评估 13 个直接 B2B，保留原样 5 个。`anchor/all-speculate` 8（提交 8）。
- `dataflow` 评估 13 个直接 B2B，保留原样 5 个。`dataflow/all-speculate` 8（提交 8）。
- `anchor-unified` 最先在第 2 步提交不同的区域，anchor 为 `69b92fc9723f`（`%167`，TTI 457），该策略为 `9916a96229c8`（`%167`，TTI 457）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -25。
- `dataflow` 最先在第 2 步提交不同的区域，anchor 为 `69b92fc9723f`（`%167`，TTI 457），该策略为 `44be0ad40ca8`（`%167`，TTI 456）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -28。

固定配对统一生成保住最初四步的报价降幅，并额外提交四步，最终从 436 降至 411。新配对把结果再降低 3 点。第一步 IR 已有差异，后续同名根的结构 ID 也随之变化。

### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 18.240 | +0.44% | [0.98268, 1.01317] |
| anchor | 18.240 | — | 基准 |
| darm | 18.240 | +0.00% | [0.99130, 1.00881] |
| anchor-unified | 18.240 | +0.00% | [0.99565, 1.01308] |
| dataflow | 18.240 | -0.00% | [0.99119, 1.00881] |

该用例未列入本次两个 rocprof 对照。

## MapAiry

输入 SHA-256 `130d89d31e175129c35386aa68f040556a3addb5c0615a26948b75ee7963dce2`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 6402 | 0 | 通过 | 99 | 101 | 263 | 3177 | 1281 | 108 |
| anchor | 3997 | 30 | 通过 | 68 | 74 | 184 | 2460 | 749 | 328 |
| darm | 3999 | 27 | 通过 | 69 | 75 | 198 | 2559 | 741 | 438 |
| anchor-unified | 5052 | 22 | 通过 | 78 | 84 | 197 | 3012 | 832 | 307 |
| dataflow | 5051 | 22 | 通过 | 78 | 84 | 197 | 3013 | 832 | 309 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 0293233d29ce(6150) → ff1168a5e9e9(5898) → 0c18c540bf3b(5646) → 648c95be256e(5394) → a5cfe0d60dd4(5205) → 5f3baf654110(5016) → ff1604326a42(4763) → 9d54fbd14628(4692) → 22be0fbece1d(4636) → 471b9e214c26(4602) → a7b44b193c09(4591) → e1db8db31449(4582) → b9d27685035d(4573) → e1db8db31449(4564) → b9d27685035d(4555) → e1db8db31449(4546) → b9d27685035d(4537) → e1db8db31449(4528) → b9d27685035d(4519) → e1db8db31449(4510) → b9d27685035d(4501) → e1db8db31449(4492) → 9696f4c5696f(4430) → a89f0dc46f01(4417) → a89f0dc46f01(4412) → 03d55c7d3db7(4394) → 3508515f5f4d(4264) → 76ba4e0e8a89(4123) → 872d77ef5109(4102) → f94e0989bb18(3997)。
- `darm` 的区域及提交后 TTI 为 0293233d29ce(6129) → ff1168a5e9e9(5856) → a54b179ecc9e(5583) → 0c18c540bf3b(5310) → 648c95be256e(5037) → e02ca96ad888(4764) → c15b3420c0ff(4491) → eca051b49cfa(4306) → 9d54fbd14628(4246) → 22be0fbece1d(4190) → e185fac0fe0e(4150) → e1db8db31449(4139) → b9d27685035d(4130) → e1db8db31449(4121) → b9d27685035d(4112) → e1db8db31449(4103) → b9d27685035d(4094) → e1db8db31449(4085) → b9d27685035d(4076) → e1db8db31449(4067) → b9d27685035d(4058) → e1db8db31449(4049) → 9696f4c5696f(4040) → bd348550e48a(4031) → 9696f4c5696f(4009) → b32b9061ae07(4004) → b32b9061ae07(3999)。
- `anchor-unified` 的区域及提交后 TTI 为 e1db8db31449(6393) → e1db8db31449(6384) → e1db8db31449(6375) → e1db8db31449(6366) → e1db8db31449(6357) → e1db8db31449(6348) → bd348550e48a(6339) → 9696f4c5696f(6337) → 48ae85eade58(6085) → 8264b874be9d(6020) → 2316dec2d40b(5768) → 293e874277a3(5516) → 7547e3be61f5(5264) → 57282e958a43(5209) → 3c578ac2aaff(5164) → a89f0dc46f01(5159) → a89f0dc46f01(5154) → 03d55c7d3db7(5136) → 89f312ccd54c(5115) → d6ce509da5c8(5094) → eadc457958f1(5073) → ddbdb52ee4c4(5052)。
- `dataflow` 的区域及提交后 TTI 为 e1db8db31449(6393) → e1db8db31449(6384) → e1db8db31449(6375) → e1db8db31449(6366) → e1db8db31449(6357) → e1db8db31449(6348) → bd348550e48a(6339) → 9696f4c5696f(6337) → 48ae85eade58(6085) → 8264b874be9d(6020) → 2316dec2d40b(5768) → 293e874277a3(5516) → 7547e3be61f5(5264) → 57282e958a43(5209) → 3c578ac2aaff(5164) → a89f0dc46f01(5159) → a89f0dc46f01(5154) → 03d55c7d3db7(5135) → 89f312ccd54c(5114) → d6ce509da5c8(5093) → eadc457958f1(5072) → ddbdb52ee4c4(5051)。
- `anchor-unified` 评估 228 个直接 B2B，保留原样 218 个。`anchor/all-speculate` 10（提交 5）。
- `dataflow` 评估 228 个直接 B2B，保留原样 218 个。`dataflow/all-speculate` 10（提交 5）。
- `anchor-unified` 最先在第 1 步提交不同的区域，anchor 为 `0293233d29ce`（`%decision.dispatch`，TTI 6150），该策略为 `e1db8db31449`（`%if.end7.i.i.i620.i.i.i.i`，TTI 6393）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +1055。
- `dataflow` 最先在第 1 步提交不同的区域，anchor 为 `0293233d29ce`（`%decision.dispatch`，TTI 6150），该策略为 `e1db8db31449`（`%if.end7.i.i.i620.i.i.i.i`，TTI 6393）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +1054。

原 anchor 首次提交的是准备后的 296 指令区域 0293233d29ce，其整核 TTI 从 6402 到 6150。两种统一策略在同一父 IR 都用 §7.2 保留该区域。单独重放显示两种策略中的最低分歧报价为 (292,292,292)，其中两个一致场景均比原区域 (570,289,289) 贵 3 点。两条新轨迹先做仅归一改写，稍后才提交结构候选。anchor 的 30 次提交得到 3997，两条新轨迹的 22 次提交分别停在 5052 和 5051。

### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 84.799 | +169.03% | [2.67675, 2.69035] |
| anchor | 31.520 | — | 基准 |
| darm | — | — | TTI 差异 0.05%，未达门槛 |
| anchor-unified | 57.040 | +80.71% | [1.80049, 1.81470] |
| dataflow | 57.120 | +81.01% | [1.80711, 1.81218] |

| 变体 | 计时 dispatch 数 | VALUInsts | SALUInsts | VALUBusy % | MemUnitBusy % | MemUnitStalled % | waves / dispatch | dispatch µs | sweep µs |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| anchor | 15 | 802.601 | 110.662 | 45.923 | 4.126 | 0.218 | 1028 | 27.999 | — |
| anchor-unified | 15 | 1309.33 | 191.35 | 64.501 | 2.591 | 0.183 | 1028 | 50.720 | — |
| dataflow | 15 | 1310.32 | 191.35 | 64.675 | 2.548 | 0.180 | 1028 | 50.880 | — |

gfx906 没有暴露动态 wave 驻留率。以下为 HIP 占用查询得到的资源上限。

```text
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10b/final/MapAiry/gpu/anchor.hsaco 3 WG/CU 12 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10b/final/MapAiry/gpu/anchor-unified.hsaco 5 WG/CU 20 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10b/final/MapAiry/gpu/dataflow.hsaco 5 WG/CU 20 waves/CU 40 max waves/CU
```

## LUD8

输入 SHA-256 `f362469c52c83af4343b4dc76abb63117af94f5d89fdf97c013b6c8e41e1b172`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 819 | 0 | 通过 | 6 | 6 | 15 | 400 | 104 | 0 |
| anchor | 628 | 2 | 通过 | 3 | 3 | 7 | 349 | 26 | 24 |
| darm | 681 | 2 | 通过 | 4 | 4 | 12 | 376 | 25 | 37 |
| anchor-unified | 730 | 4 | 通过 | 6 | 6 | 15 | 400 | 71 | 7 |
| dataflow | 640 | 3 | 通过 | 3 | 3 | 7 | 369 | 23 | 27 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 49986d3337c9(666) → bf01af5a3927(628)。
- `darm` 的区域及提交后 TTI 为 49986d3337c9(698) → 39f66cca5b43(681)。
- `anchor-unified` 的区域及提交后 TTI 为 49986d3337c9(734) → b22cbe089520(733) → 68772f9ceb93(732) → 635842a045f4(730)。
- `dataflow` 的区域及提交后 TTI 为 49986d3337c9(673) → 635842a045f4(668) → fd303f0161b6(640)。
- `anchor-unified` 评估 8 个直接 B2B，保留原样 4 个。`anchor/all-protect` 2（提交 2）、`anchor/min-cut` 2（提交 2）。
- `dataflow` 评估 6 个直接 B2B，保留原样 3 个。`anchor/min-cut` 1（提交 1）、`darm/all-speculate` 1（提交 1）、`darm/min-cut` 1（提交 1）。
- `anchor-unified` 最先在第 2 步提交不同的区域，anchor 为 `bf01af5a3927`（`%394`，TTI 628），该策略为 `b22cbe089520`（`%dataflow`，TTI 733）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +102。
- `dataflow` 最先在第 2 步提交不同的区域，anchor 为 `bf01af5a3927`（`%394`，TTI 628），该策略为 `635842a045f4`（`%dataflow`，TTI 668）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +12。

三个策略都从 49986d3337c9 开始。anchor 原生成首步到 666；固定抽取区域的 anchor 配对选择最小割，报价 (179,116,113)，回填清理后为 734；dataflow 选 DARM 配对和全推测，报价 (140,140,140)，整核到 673。两条新轨迹都没有复现 anchor 的第二步。复放父 IR 得到 64 对，其中一对工作组 ID 被提取为共享入口。剩下 63 对包含抽取区域重放 anchor 的全部 30 对。将这 63 对固定给同一个生成器，本地报价为 (154,154,154)。因此 102 点端到端差距同时含有配对输入、生成和后续路径的变化。

### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 529528.778 | +14.30% | [1.14029, 1.14714] |
| anchor | 463104.111 | — | 基准 |
| darm | 461027.893 | -0.38% | [0.99284, 0.99799] |
| anchor-unified | 518693.512 | +12.00% | [1.11811, 1.12279] |
| dataflow | 546228.302 | +17.97% | [1.17864, 1.18058] |

| 变体 | 计时 dispatch 数 | VALUInsts | SALUInsts | VALUBusy % | MemUnitBusy % | MemUnitStalled % | waves / dispatch | dispatch µs | sweep µs |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| anchor | 30705 | 349 | 26 | 1.643 | 59.090 | 45.917 | 1024 | 228.320 | 450141.080 |
| anchor-unified | 30705 | 400 | 71 | 1.700 | 51.226 | 44.248 | 1024 | 251.200 | 502552.214 |
| dataflow | 30705 | 369 | 23 | 1.444 | 62.472 | 47.062 | 1024 | 285.279 | 540782.286 |

gfx906 没有暴露动态 wave 驻留率。以下为 HIP 占用查询得到的资源上限。

```text
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10b/final/LUD8/gpu/anchor.hsaco 20 WG/CU 20 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10b/final/LUD8/gpu/anchor-unified.hsaco 32 WG/CU 32 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10b/final/LUD8/gpu/dataflow.hsaco 20 WG/CU 20 waves/CU 40 max waves/CU
```

## HiPIMS-George

输入 SHA-256 `c8069ddd3515465106ee3cad9dcd39441b5ca45ffad4b8ebc79b7a38f3b5e76f`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 5588 | 0 | 通过 | 146 | 252 | — | — | — | — |
| anchor | 5572 | 5 | 通过 | 142 | 246 | — | — | — | — |
| darm | 5577 | 3 | 通过 | 145 | 252 | — | — | — | — |
| anchor-unified | 5583 | 1 | 通过 | 145 | 251 | — | — | — | — |
| dataflow | 5581 | 2 | 通过 | 145 | 251 | — | — | — | — |

SASS 统计按（总指令、重汇合、选择）排列。
- original `(3800, 224, 105)`
- anchor `(3752, 218, 123)`
- darm `(3792, 220, 123)`
- anchor-unified `(3784, 222, 107)`
- dataflow `(3784, 222, 107)`

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 eb327257556f(5583) → bae3055aff2f(5578) → 4f045e74e33a(5577) → f276b3295a2c(5575) → c9ab53d356c7(5572)。
- `darm` 的区域及提交后 TTI 为 eb327257556f(5583) → 4f045e74e33a(5580) → c9ab53d356c7(5577)。
- `anchor-unified` 的区域及提交后 TTI 为 eb327257556f(5583)。
- `dataflow` 的区域及提交后 TTI 为 eb327257556f(5583) → 4f045e74e33a(5581)。
- `anchor-unified` 评估 111 个直接 B2B，保留原样 98 个。`anchor/all-speculate` 4（提交 0）。 无可用方案。`anchor_b2b_layout_unavailable` 9。
- `dataflow` 评估 124 个直接 B2B，保留原样 116 个。`dataflow/all-protect` 2（提交 1）、`dataflow/all-speculate` 6（提交 0）。
- `anchor-unified` 最先在第 2 步提交不同的区域，anchor 为 `bae3055aff2f`（`%decision.dispatch`，TTI 5578），该策略为 已结束。首个提交 IR 差异在第 2 步，最终 TTI 差值 +11。
- `dataflow` 最先在第 2 步提交不同的区域，anchor 为 `bae3055aff2f`（`%decision.dispatch`，TTI 5578），该策略为 `4f045e74e33a`（`%3871`，TTI 5581）。首个提交 IR 差异在第 2 步，最终 TTI 差值 +9。

选择第 5 步 cd507219fcce 所在的 hipims@c8069ddd3515 输入和 George Cartesian kernel。统一策略与 anchor 的首步都是归一；第 2 步 anchor 使用局部 decision.dispatch，dataflow 改选 4f045e74e33a，固定配对策略在第一步后结束。

### GPU 时间与硬件计数

所有变体与 anchor 的 TTI 差异均未超过 1%，因此未计时。

该用例未列入本次两个 rocprof 对照。

## tigre-siddon

输入 SHA-256 `acacbad8f0990ae9bef99a404a48e767ec72c000e099c21d358080de5c302a46`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 1182 | 0 | 通过 | 28 | 30 | 70 | 1265 | 152 | 209 |
| anchor | 942 | 5 | 通过 | 18 | 20 | 33 | 980 | 98 | 185 |
| darm | 948 | 5 | 通过 | 20 | 22 | 39 | 986 | 105 | 176 |
| anchor-unified | 1003 | 5 | 通过 | 20 | 22 | 38 | 1048 | 113 | 193 |
| dataflow | 1003 | 5 | 通过 | 20 | 22 | 38 | 1048 | 113 | 193 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1017) → 7de8e9ed211b(942)。
- `darm` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1020) → a37cbfd19d16(948)。
- `anchor-unified` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1017) → df0f503fb5f9(1003)。
- `dataflow` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1017) → df0f503fb5f9(1003)。
- `anchor-unified` 评估 9 个直接 B2B，保留原样 6 个。`anchor/all-protect` 1（提交 1）、`anchor/all-speculate` 2（提交 1）。
- `dataflow` 评估 9 个直接 B2B，保留原样 6 个。`anchor/all-protect` 1（提交 1）、`anchor/all-speculate` 2（提交 1）。
- `anchor-unified` 最先在第 5 步提交不同的区域，anchor 为 `7de8e9ed211b`（`%decision.dispatch2`，TTI 942），该策略为 `df0f503fb5f9`（`%decision.dispatch2`，TTI 1003）。首个提交 IR 差异在第 4 步，最终 TTI 差值 +61。
- `dataflow` 最先在第 5 步提交不同的区域，anchor 为 `7de8e9ed211b`（`%decision.dispatch2`，TTI 942），该策略为 `df0f503fb5f9`（`%decision.dispatch2`，TTI 1003）。首个提交 IR 差异在第 4 步，最终 TTI 差值 +61。

选择第 5 步 5380fef61ac9 所在的冻结输入。前 3 步都是既有 R2R。第 4 步提交相同结构位置而函数 IR 首次分叉，第 5 步的区域发生变化。两种统一生成最后都落到 1003。

### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 6272.291 | +119.37% | [2.18880, 2.19558] |
| anchor | 2858.707 | — | 基准 |
| darm | — | — | TTI 差异 0.64%，未达门槛 |
| anchor-unified | 3572.141 | +24.93% | [1.24624, 1.25282] |
| dataflow | 3571.439 | +24.99% | [1.24658, 1.25397] |

该用例未列入本次两个 rocprof 对照。

## 汇总

| 用例 | anchor TTI | anchor-unified ΔTTI | dataflow ΔTTI | dataflow 相对 anchor-unified ΔTTI | anchor-unified ΔGPU | dataflow ΔGPU |
|---|---:|---:|---:|---:|---:|---:|
| DCT8 | 62 | +0 | -18 | -18 | — | -0.05% |
| PCM32 | 1136 | +0 | -6 | -6 | — | — |
| NQU64 | 274 | +0 | +0 | +0 | — | — |
| SRAD16 | 436 | -25 | -28 | -3 | +0.00% | -0.00% |
| MapAiry | 3997 | +1055 | +1054 | -1 | +80.71% | +81.01% |
| LUD8 | 628 | +102 | +12 | -90 | +12.00% | +17.97% |
| HiPIMS-George | 5572 | +11 | +9 | -2 | — | — |
| tigre-siddon | 942 | +61 | +61 | +0 | +24.93% | +24.99% |

- **配对带来的静态收益。** DCT8 固定配对为 62，加入新配对降至 44。PCM32 固定配对的终值与 anchor 相同，新配对再省 6 点。SRAD16 的 28 点收益中，固定配对统一生成已取得 25 点，加入新配对再省 3 点。DCT8 与 SRAD16 的同轮 GPU 时间区间覆盖 1，PCM32 的 0.53% 静态差异低于计时门槛。
- **生成与路径。** MapAiry 的两种统一策略在同一个预处理候选上都保留原样，因而从第 1 步分叉。两版最终多 1,054–1,055 点，GPU 慢约 81%。相比 anchor，最终 ISA 多 10 条条件分支、13 条 exec 操作和 552–553 条 VALU。rocprof 记录的 VALUInsts 也从约 803 增至 1,309–1,310。相近的两条新轨迹表明，新配对对这次退化的影响很小。
- **TIGRE 与 LUD8。** TIGRE 的统一策略在相同配对下从第 4 步生成不同 IR，第 5 步改写因此改变，最后两版均高 61 点，GPU 慢约 25%。LUD8 的安全网把固定抽取配对的 102 点损失压到 12 点，但 GPU 时间的增幅从 12.00% 扩大到 17.97%。抽取区域和父 IR 上的 anchor 配对存在差别，LUD8 的差距同时含有配对、统一生成和路径变化。
- **覆盖。** 40 个产物通过 CPU/GPU 校验和最终 IR 的独立 LLVM 24 复报价。记录了 248 次最终提交及 843 次直接 B2B 候选评估。原始配对诊断、ISA、计时每轮结果和 profiler 汇总见 [原始数据](step10b-evidence.json.gz)。
