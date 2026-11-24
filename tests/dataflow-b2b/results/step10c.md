# 第 10c 步 父 IR 中的裁决和端到端对照

五个变体使用同一冻结输入。差值为变体减 anchor，负值表示代价更低或时间更短。全流程提交和逐候选配对、最低整核报价、放置及 gate 结果分别见 [提交明细](step10c-commits.tsv) 与 [B2B 候选明细](step10c-candidates.tsv)。重复评估按该步当时的父 IR 记录。区域 ID 由抽取工具按当前父 IR 计算。相同位置的结构 ID 可以随上一步生成的 IR 改变。路径对照同时检查区域 ID 序列和提交后的函数体。

放置标签 all-speculate、convex-guard、all-protect、min-cut 分别对应全推测、凸包保护、全保护、最小割。附记 +convex-guard 和 +repair 表示对该放置的凸包或边界修复。每条记录给出最低整核报价的布局及其 gate 结果。

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
- `anchor-unified` 评估 1 个直接 B2B，保留原样 1 个。`anchor/min-cut` 1（提交 0）。
- `dataflow` 评估 1 个直接 B2B，保留原样 0 个。`dataflow/all-speculate` 1（提交 1）。
- `anchor-unified` 与 anchor 的提交区域序列相同。最终 TTI 差值 +0。
- `dataflow` 最先在第 1 步提交不同的区域，anchor 为 已结束，该策略为 `d23a7c228c5b`（`%2`，TTI 44）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -18。



### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | — | — | TTI 差异 0.00%，未达门槛 |
| anchor | 693.115 | — | 基准 |
| darm | 692.794 | -0.05% | [0.99896, 1.00012] |
| anchor-unified | — | — | TTI 差异 0.00%，未达门槛 |
| dataflow | 692.795 | -0.02% | [0.99931, 1.00000] |

该用例未列入本次 rocprof 对照。

## PCM32

输入 SHA-256 `db3b35287f1ef284e3c8dac514b05fc952a6892345b5ff0077b2840927aaab47`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 1392 | 0 | 通过 | 38 | 46 | 107 | 384 | 145 | 40 |
| anchor | 1136 | 18 | 通过 | 17 | 21 | 23 | 355 | 77 | 122 |
| darm | 1136 | 18 | 通过 | 17 | 21 | 23 | 355 | 77 | 122 |
| anchor-unified | 1136 | 18 | 通过 | 17 | 21 | 23 | 355 | 77 | 122 |
| dataflow | 1136 | 18 | 通过 | 17 | 21 | 23 | 355 | 77 | 122 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 00bc16cfd8ae(1377) → e3b15e5220a0(1362) → 00bc16cfd8ae(1347) → ed0b563f1288(1332) → 00bc16cfd8ae(1317) → e3b15e5220a0(1302) → 00bc16cfd8ae(1287) → ed0b563f1288(1272) → ed0b563f1288(1257) → 00bc16cfd8ae(1242) → e3b15e5220a0(1227) → 00bc16cfd8ae(1212) → ed0b563f1288(1197) → 6dfa89ca4f97(1187) → 00bc16cfd8ae(1168) → e3b15e5220a0(1153) → 00bc16cfd8ae(1138) → 791c6dcfa478(1136)。
- `darm` 的区域及提交后 TTI 为 00bc16cfd8ae(1377) → 6dfa89ca4f97(1367) → 00bc16cfd8ae(1348) → e3b15e5220a0(1333) → 00bc16cfd8ae(1318) → ed0b563f1288(1303) → 00bc16cfd8ae(1288) → e3b15e5220a0(1273) → 00bc16cfd8ae(1258) → ed0b563f1288(1243) → 00bc16cfd8ae(1228) → ed0b563f1288(1213) → 00bc16cfd8ae(1198) → e3b15e5220a0(1183) → 00bc16cfd8ae(1168) → ed0b563f1288(1153) → e3b15e5220a0(1138) → 791c6dcfa478(1136)。
- `anchor-unified` 的区域及提交后 TTI 为 00bc16cfd8ae(1377) → 6dfa89ca4f97(1367) → 00bc16cfd8ae(1348) → e3b15e5220a0(1333) → 00bc16cfd8ae(1318) → ed0b563f1288(1303) → 00bc16cfd8ae(1288) → e3b15e5220a0(1273) → 00bc16cfd8ae(1258) → ed0b563f1288(1243) → 00bc16cfd8ae(1228) → ed0b563f1288(1213) → 00bc16cfd8ae(1198) → e3b15e5220a0(1183) → 00bc16cfd8ae(1168) → ed0b563f1288(1153) → e3b15e5220a0(1138) → ef97ad20b297(1136)。
- `dataflow` 的区域及提交后 TTI 为 00bc16cfd8ae(1377) → 6dfa89ca4f97(1367) → 00bc16cfd8ae(1348) → e3b15e5220a0(1333) → 00bc16cfd8ae(1318) → ed0b563f1288(1303) → 00bc16cfd8ae(1288) → e3b15e5220a0(1273) → 00bc16cfd8ae(1258) → ed0b563f1288(1243) → 00bc16cfd8ae(1228) → ed0b563f1288(1213) → 00bc16cfd8ae(1198) → e3b15e5220a0(1183) → 00bc16cfd8ae(1168) → ed0b563f1288(1153) → e3b15e5220a0(1138) → ef97ad20b297(1136)。
- `anchor-unified` 评估 34 个直接 B2B，保留原样 2 个。`anchor/all-speculate` 32（提交 16）、`anchor/min-cut` 2（提交 0）。
- `dataflow` 评估 34 个直接 B2B，保留原样 2 个。`anchor/all-speculate` 32（提交 16）、`dataflow/min-cut` 2（提交 0）。
- `anchor-unified` 最先在第 2 步提交不同的区域，anchor 为 `e3b15e5220a0`（`%275`，TTI 1362），该策略为 `6dfa89ca4f97`（`%1`，TTI 1367）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +0。
- `dataflow` 最先在第 2 步提交不同的区域，anchor 为 `e3b15e5220a0`（`%275`，TTI 1362），该策略为 `6dfa89ca4f97`（`%1`，TTI 1367）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +0。



### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 892898.956 | +35.55% | [1.35534, 1.35549] |
| anchor | 658754.272 | — | 基准 |
| darm | — | — | TTI 差异 0.00%，未达门槛 |
| anchor-unified | — | — | TTI 差异 0.00%，未达门槛 |
| dataflow | — | — | TTI 差异 0.00%，未达门槛 |

该用例未列入本次 rocprof 对照。

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
- `anchor-unified` 评估 12 个直接 B2B，保留原样 12 个。`anchor/all-speculate` 3（提交 0）、`anchor/convex-guard` 5（提交 0）、`anchor/min-cut` 4（提交 0）。
- `dataflow` 评估 12 个直接 B2B，保留原样 12 个。`dataflow/all-speculate` 3（提交 0）、`dataflow/convex-guard` 5（提交 0）、`dataflow/min-cut` 4（提交 0）。
- `anchor-unified` 与 anchor 的提交区域序列相同。最终 TTI 差值 +0。
- `dataflow` 与 anchor 的提交区域序列相同。最终 TTI 差值 +0。



### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 10368.826 | +18.85% | [1.18694, 1.19350] |
| anchor | 8725.702 | — | 基准 |
| darm | — | — | TTI 差异 0.00%，未达门槛 |
| anchor-unified | — | — | TTI 差异 0.00%，未达门槛 |
| dataflow | — | — | TTI 差异 0.00%，未达门槛 |

该用例未列入本次 rocprof 对照。

## SRAD16

输入 SHA-256 `ecf89ddfdc19aca349c70571b29ea5be2b95049fbce5d9815cabc7b73de016d1`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 484 | 0 | 通过 | 21 | 23 | 46 | 264 | 90 | 6 |
| anchor | 436 | 4 | 通过 | 18 | 20 | 26 | 273 | 67 | 19 |
| darm | 455 | 3 | 通过 | 19 | 21 | 34 | 273 | 79 | 14 |
| anchor-unified | 407 | 10 | 通过 | 14 | 16 | 15 | 279 | 57 | 35 |
| dataflow | 404 | 11 | 通过 | 14 | 16 | 15 | 268 | 57 | 32 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 701ab76d676a(470) → 69b92fc9723f(457) → 88091c4b8b24(445) → 3ea49ee220ea(436)。
- `darm` 的区域及提交后 TTI 为 701ab76d676a(470) → 69b92fc9723f(457) → cae5d76e62ec(455)。
- `anchor-unified` 的区域及提交后 TTI 为 701ab76d676a(470) → 9916a96229c8(457) → e38dc6234893(445) → b3bd75625514(435) → f59d072aa167(432) → 520e6922648b(429) → 7d7b01f9e417(426) → 7e522fb1ca72(410) → b16639dbcb30(408) → 6b8c2aa0a294(407)。
- `dataflow` 的区域及提交后 TTI 为 701ab76d676a(470) → 44be0ad40ca8(456) → 4a0fd7cfbd12(444) → e9cf515b3bfb(433) → 3d4cac4dbd30(430) → 4b4413b827c0(427) → aef306a0e9ff(424) → 97dd4402a8b7(408) → 6993d2110e01(407) → b16639dbcb30(405) → 6b8c2aa0a294(404)。
- `anchor-unified` 评估 20 个直接 B2B，保留原样 10 个。`anchor/all-speculate` 20（提交 10）。
- `dataflow` 评估 21 个直接 B2B，保留原样 10 个。`dataflow/all-speculate` 21（提交 11）。
- `anchor-unified` 最先在第 2 步提交不同的区域，anchor 为 `69b92fc9723f`（`%167`，TTI 457），该策略为 `9916a96229c8`（`%167`，TTI 457）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -29。
- `dataflow` 最先在第 2 步提交不同的区域，anchor 为 `69b92fc9723f`（`%167`，TTI 457），该策略为 `44be0ad40ca8`（`%167`，TTI 456）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -32。



### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 18.399 | -0.87% | [0.83954, 1.00000] |
| anchor | 18.480 | — | 基准 |
| darm | 18.400 | -0.87% | [0.84790, 1.00000] |
| anchor-unified | 18.400 | -0.43% | [0.84728, 1.02179] |
| dataflow | 18.559 | -0.36% | [0.93413, 1.01309] |

| 变体 | 计时 dispatch 数 | VALUInsts | SALUInsts | VALUBusy % | MemUnitBusy % | MemUnitStalled % | waves / dispatch | dispatch µs | sweep µs |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| anchor | 15 | 246.438 | 55.875 | 16.142 | 7.968 | 2.942 | 1024 | 14.240 | — |
| anchor-unified | 15 | 252.312 | 45.875 | 17.750 | 8.838 | 3.518 | 1024 | 12.480 | — |
| dataflow | 15 | 241.438 | 45.875 | 17.554 | 9.104 | 3.826 | 1024 | 12.160 | — |

gfx906 没有暴露动态 wave 驻留率。以下为 HIP 占用查询得到的资源上限。

```text
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10c/final/SRAD16/gpu/anchor.hsaco 8 WG/CU 32 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10c/final/SRAD16/gpu/anchor-unified.hsaco 8 WG/CU 32 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10c/final/SRAD16/gpu/dataflow.hsaco 8 WG/CU 32 waves/CU 40 max waves/CU
```

## MapAiry

输入 SHA-256 `130d89d31e175129c35386aa68f040556a3addb5c0615a26948b75ee7963dce2`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 6402 | 0 | 通过 | 99 | 101 | 263 | 3177 | 1281 | 108 |
| anchor | 3997 | 30 | 通过 | 68 | 74 | 184 | 2460 | 749 | 328 |
| darm | 3999 | 27 | 通过 | 69 | 75 | 198 | 2559 | 741 | 438 |
| anchor-unified | 4115 | 36 | 通过 | 63 | 67 | 168 | 2577 | 740 | 336 |
| dataflow | 3871 | 36 | 通过 | 60 | 64 | 163 | 2537 | 701 | 425 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 0293233d29ce(6150) → ff1168a5e9e9(5898) → 0c18c540bf3b(5646) → 648c95be256e(5394) → a5cfe0d60dd4(5205) → 5f3baf654110(5016) → ff1604326a42(4763) → 9d54fbd14628(4692) → 22be0fbece1d(4636) → 471b9e214c26(4602) → a7b44b193c09(4591) → e1db8db31449(4582) → b9d27685035d(4573) → e1db8db31449(4564) → b9d27685035d(4555) → e1db8db31449(4546) → b9d27685035d(4537) → e1db8db31449(4528) → b9d27685035d(4519) → e1db8db31449(4510) → b9d27685035d(4501) → e1db8db31449(4492) → 9696f4c5696f(4430) → a89f0dc46f01(4417) → a89f0dc46f01(4412) → 03d55c7d3db7(4394) → 3508515f5f4d(4264) → 76ba4e0e8a89(4123) → 872d77ef5109(4102) → f94e0989bb18(3997)。
- `darm` 的区域及提交后 TTI 为 0293233d29ce(6129) → ff1168a5e9e9(5856) → a54b179ecc9e(5583) → 0c18c540bf3b(5310) → 648c95be256e(5037) → e02ca96ad888(4764) → c15b3420c0ff(4491) → eca051b49cfa(4306) → 9d54fbd14628(4246) → 22be0fbece1d(4190) → e185fac0fe0e(4150) → e1db8db31449(4139) → b9d27685035d(4130) → e1db8db31449(4121) → b9d27685035d(4112) → e1db8db31449(4103) → b9d27685035d(4094) → e1db8db31449(4085) → b9d27685035d(4076) → e1db8db31449(4067) → b9d27685035d(4058) → e1db8db31449(4049) → 9696f4c5696f(4040) → bd348550e48a(4031) → 9696f4c5696f(4009) → b32b9061ae07(4004) → b32b9061ae07(3999)。
- `anchor-unified` 的区域及提交后 TTI 为 0293233d29ce(6150) → ff1168a5e9e9(5898) → 0c18c540bf3b(5646) → 648c95be256e(5394) → 7f0c89fc71b6(5202) → 8dbdec03c485(5010) → 02690afb4550(4761) → 22be0fbece1d(4705) → 9d54fbd14628(4669) → 3937cfbcda28(4638) → e1db8db31449(4629) → b9d27685035d(4620) → e1db8db31449(4611) → b9d27685035d(4602) → e1db8db31449(4593) → b9d27685035d(4584) → e1db8db31449(4575) → b9d27685035d(4566) → e1db8db31449(4557) → b9d27685035d(4548) → e1db8db31449(4539) → 9696f4c5696f(4477) → a89f0dc46f01(4464) → fcfc55a8380f(4362) → 51444681c96b(4357) → 4fe764dc7dc4(4341) → a89f0dc46f01(4336) → 9e90170aa6f3(4321) → f97e0be9962c(4317) → ebd71b4553d4(4312) → 2d1cd4deff08(4181) → dac0da066e74(4160) → 88adefb48b28(4156) → e5a4e362a3ff(4139) → 9f6653e9f62d(4127) → 9f6653e9f62d(4115)。
- `dataflow` 的区域及提交后 TTI 为 0293233d29ce(6129) → ff1168a5e9e9(5856) → b08d3b1f8067(5583) → 0c18c540bf3b(5310) → 648c95be256e(5037) → 39f4438f6dff(4764) → 158f9349f28b(4491) → 1373db69f2f0(4383) → 22be0fbece1d(4331) → fd3f45e605d6(4283) → e1db8db31449(4274) → b9d27685035d(4265) → e1db8db31449(4256) → b9d27685035d(4247) → e1db8db31449(4238) → b9d27685035d(4229) → e1db8db31449(4220) → b9d27685035d(4211) → e1db8db31449(4202) → b9d27685035d(4193) → e1db8db31449(4184) → 9696f4c5696f(4122) → a89f0dc46f01(4109) → aaaffa9522ae(4097) → 8582a179c560(4095) → 375ef578d89f(4080) → a89f0dc46f01(4075) → 3daef453e3ac(4060) → d2d01d9e6e5a(4049) → 2c2410073449(3989) → cd22dc7bc1af(3964) → b1097a679b5c(3942) → 6965094e4e84(3912) → e5a4e362a3ff(3895) → 9f6653e9f62d(3883) → 9f6653e9f62d(3871)。
- `anchor-unified` 评估 247 个直接 B2B，保留原样 158 个。`anchor/all-protect` 75（提交 14）、`anchor/all-speculate` 20（提交 8）、`anchor/min-cut` 152（提交 2）。
- `dataflow` 评估 250 个直接 B2B，保留原样 142 个。`anchor/all-protect` 14（提交 1）、`anchor/all-speculate` 2（提交 1）、`darm/all-protect` 1（提交 0）、`darm/all-speculate` 22（提交 7）、`dataflow/all-protect` 59（提交 10）、`dataflow/all-speculate` 17（提交 7）、`dataflow/min-cut` 135（提交 0）。
- `anchor-unified` 最先在第 5 步提交不同的区域，anchor 为 `a5cfe0d60dd4`（`%decision.dispatch4`，TTI 5205），该策略为 `7f0c89fc71b6`（`%decision.dispatch4`，TTI 5202）。首个提交 IR 差异在第 1 步，最终 TTI 差值 +118。
- `dataflow` 最先在第 3 步提交不同的区域，anchor 为 `0c18c540bf3b`（`%decision.dispatch2`，TTI 5646），该策略为 `b08d3b1f8067`（`%decision.dispatch2`，TTI 5583）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -126。



### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 85.520 | +162.13% | [2.60391, 2.69034] |
| anchor | 32.960 | — | 基准 |
| darm | — | — | TTI 差异 0.05%，未达门槛 |
| anchor-unified | 36.319 | +13.83% | [1.12990, 1.14721] |
| dataflow | 31.359 | -2.97% | [0.95820, 0.97573] |

| 变体 | 计时 dispatch 数 | VALUInsts | SALUInsts | VALUBusy % | MemUnitBusy % | MemUnitStalled % | waves / dispatch | dispatch µs | sweep µs |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| anchor | 15 | 802.601 | 110.662 | 45.691 | 4.133 | 0.226 | 1028 | 27.840 | — |
| anchor-unified | 15 | 898.094 | 148.505 | 50.508 | 3.239 | 0.249 | 1028 | 32.160 | — |
| dataflow | 15 | 853.508 | 107.694 | 44.890 | 4.442 | 0.226 | 1028 | 25.760 | — |

gfx906 没有暴露动态 wave 驻留率。以下为 HIP 占用查询得到的资源上限。

```text
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10c/final/MapAiry/gpu/anchor.hsaco 3 WG/CU 12 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10c/final/MapAiry/gpu/anchor-unified.hsaco 3 WG/CU 12 waves/CU 40 max waves/CU
/data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step10c/final/MapAiry/gpu/dataflow.hsaco 4 WG/CU 16 waves/CU 40 max waves/CU
```

## LUD8

输入 SHA-256 `f362469c52c83af4343b4dc76abb63117af94f5d89fdf97c013b6c8e41e1b172`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 819 | 0 | 通过 | 6 | 6 | 15 | 400 | 104 | 0 |
| anchor | 628 | 2 | 通过 | 3 | 3 | 7 | 349 | 26 | 24 |
| darm | 681 | 2 | 通过 | 4 | 4 | 12 | 376 | 25 | 37 |
| anchor-unified | 624 | 5 | 通过 | 3 | 3 | 7 | 354 | 26 | 23 |
| dataflow | 624 | 5 | 通过 | 3 | 3 | 7 | 354 | 26 | 23 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 49986d3337c9(666) → bf01af5a3927(628)。
- `darm` 的区域及提交后 TTI 为 49986d3337c9(698) → 39f66cca5b43(681)。
- `anchor-unified` 的区域及提交后 TTI 为 49986d3337c9(666) → 1df59745ea53(654) → 629095e24a9d(630) → cab59a8cea30(625) → e00f6348067d(624)。
- `dataflow` 的区域及提交后 TTI 为 49986d3337c9(666) → 1df59745ea53(654) → 629095e24a9d(630) → cab59a8cea30(625) → e00f6348067d(624)。
- `anchor-unified` 评估 9 个直接 B2B，保留原样 4 个。`anchor/all-speculate` 4（提交 3）、`anchor/convex-guard` 5（提交 2）。
- `dataflow` 评估 9 个直接 B2B，保留原样 4 个。`anchor/all-speculate` 2（提交 2）、`anchor/convex-guard` 5（提交 2）、`dataflow/all-speculate` 2（提交 1）。
- `anchor-unified` 最先在第 2 步提交不同的区域，anchor 为 `bf01af5a3927`（`%394`，TTI 628），该策略为 `1df59745ea53`（`%dataflow`，TTI 654）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -4。
- `dataflow` 最先在第 2 步提交不同的区域，anchor 为 `bf01af5a3927`（`%394`，TTI 628），该策略为 `1df59745ea53`（`%dataflow`，TTI 654）。首个提交 IR 差异在第 1 步，最终 TTI 差值 -4。



### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 529931.305 | +14.44% | [1.14061, 1.14826] |
| anchor | 462735.183 | — | 基准 |
| darm | 460590.332 | -0.42% | [0.99372, 0.99710] |
| anchor-unified | — | — | TTI 差异 0.64%，未达门槛 |
| dataflow | — | — | TTI 差异 0.64%，未达门槛 |

该用例未列入本次 rocprof 对照。

## HiPIMS-George

输入 SHA-256 `c8069ddd3515465106ee3cad9dcd39441b5ca45ffad4b8ebc79b7a38f3b5e76f`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 5588 | 0 | 通过 | 146 | 252 | — | — | — | — |
| anchor | 5572 | 5 | 通过 | 142 | 246 | — | — | — | — |
| darm | 5577 | 3 | 通过 | 145 | 252 | — | — | — | — |
| anchor-unified | 5539 | 25 | 通过 | 140 | 244 | — | — | — | — |
| dataflow | 5537 | 24 | 通过 | 140 | 244 | — | — | — | — |

SASS 统计按（总指令、重汇合、选择）排列。
- original `(3800, 224, 105)`
- anchor `(3752, 218, 123)`
- darm `(3792, 220, 123)`
- anchor-unified `(3760, 214, 143)`
- dataflow `(3760, 214, 143)`

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 eb327257556f(5583) → bae3055aff2f(5578) → 4f045e74e33a(5577) → f276b3295a2c(5575) → c9ab53d356c7(5572)。
- `darm` 的区域及提交后 TTI 为 eb327257556f(5583) → 4f045e74e33a(5580) → c9ab53d356c7(5577)。
- `anchor-unified` 的区域及提交后 TTI 为 eb327257556f(5583) → bae3055aff2f(5578) → 4f045e74e33a(5577) → 1c0ddd6f66c9(5575) → c9ab53d356c7(5572) → 06e356d57ca1(5562) → 3ac118d742bb(5560) → f67181eff94d(5559) → 62a46e491617(5557) → f67181eff94d(5556) → f67181eff94d(5555) → f67181eff94d(5554) → f67181eff94d(5553) → f67181eff94d(5552) → 62a46e491617(5550) → f67181eff94d(5549) → f67181eff94d(5548) → f67181eff94d(5547) → f67181eff94d(5546) → f67181eff94d(5545) → 62a46e491617(5543) → f67181eff94d(5542) → f67181eff94d(5541) → f67181eff94d(5540) → f67181eff94d(5539)。
- `dataflow` 的区域及提交后 TTI 为 eb327257556f(5583) → bae3055aff2f(5578) → 4f045e74e33a(5575) → c9ab53d356c7(5570) → 06e356d57ca1(5560) → 3ac118d742bb(5558) → f67181eff94d(5557) → 62a46e491617(5555) → f67181eff94d(5554) → f67181eff94d(5553) → f67181eff94d(5552) → f67181eff94d(5551) → f67181eff94d(5550) → 62a46e491617(5548) → f67181eff94d(5547) → f67181eff94d(5546) → f67181eff94d(5545) → f67181eff94d(5544) → f67181eff94d(5543) → 62a46e491617(5541) → f67181eff94d(5540) → f67181eff94d(5539) → f67181eff94d(5538) → f67181eff94d(5537)。
- `anchor-unified` 评估 1251 个直接 B2B，保留原样 1013 个。`anchor/all-protect` 6（提交 3）、`anchor/all-speculate` 458（提交 6）、`anchor/convex-guard` 242（提交 15）、`anchor/min-cut` 334（提交 0）。 无可用方案。`dataflow_context_no_layout` 165、`dataflow_context_no_valid_layout` 42、`dataflow_exact_solver_failed` 4。
- `dataflow` 评估 1236 个直接 B2B，保留原样 1007 个。`dataflow/all-protect` 164（提交 2）、`dataflow/all-speculate` 449（提交 6）、`dataflow/convex-guard` 242（提交 15）、`dataflow/min-cut` 337（提交 0）。 无可用方案。`dataflow_context_no_valid_layout` 42、`dataflow_exact_solver_failed` 2。
- `anchor-unified` 最先在第 4 步提交不同的区域，anchor 为 `f276b3295a2c`（`%3871`，TTI 5575），该策略为 `1c0ddd6f66c9`（`%dataflow`，TTI 5575）。首个提交 IR 差异在第 2 步，最终 TTI 差值 -33。
- `dataflow` 最先在第 4 步提交不同的区域，anchor 为 `f276b3295a2c`（`%3871`，TTI 5575），该策略为 `c9ab53d356c7`（`%3965`，TTI 5570）。首个提交 IR 差异在第 2 步，最终 TTI 差值 -35。



### GPU 时间与硬件计数

所有变体与 anchor 的 TTI 差异均未超过 1%，因此未计时。

此用例按绝对 TTI 差异入选，使用 RTX 3090。rocprof 不支持该设备，Nsight Compute 返回 ERR_NVGPUCTRPERM。用下一名可采集的 SRAD16 补测。

## tigre-siddon

输入 SHA-256 `acacbad8f0990ae9bef99a404a48e767ec72c000e099c21d358080de5c302a46`。

| 变体 | LLVM 24 TTI | 提交数 | CPU/GPU | 条件分支 | 全部分支 | exec | VALU | SALU | v_cndmask |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| original | 1182 | 0 | 通过 | 28 | 30 | 70 | 1265 | 152 | 209 |
| anchor | 942 | 5 | 通过 | 18 | 20 | 33 | 980 | 98 | 185 |
| darm | 948 | 5 | 通过 | 20 | 22 | 39 | 986 | 105 | 176 |
| anchor-unified | 947 | 6 | 通过 | 18 | 20 | 33 | 1024 | 98 | 194 |
| dataflow | 947 | 6 | 通过 | 18 | 20 | 33 | 1024 | 98 | 194 |

### 贪心路径和候选

- `anchor` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1017) → 7de8e9ed211b(942)。
- `darm` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1020) → a37cbfd19d16(948)。
- `anchor-unified` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1017) → df0f503fb5f9(1003) → 68bba7563221(947)。
- `dataflow` 的区域及提交后 TTI 为 4c0889aae0d2(1152) → 9200a0266be7(1122) → f74ef306e847(1092) → 9af6e697e11c(1017) → df0f503fb5f9(1003) → 68bba7563221(947)。
- `anchor-unified` 评估 10 个直接 B2B，保留原样 5 个。`anchor/all-protect` 2（提交 1）、`anchor/all-speculate` 3（提交 2）、`anchor/min-cut` 5（提交 0）。
- `dataflow` 评估 10 个直接 B2B，保留原样 5 个。`anchor/all-protect` 2（提交 1）、`anchor/all-speculate` 3（提交 2）、`dataflow/min-cut` 5（提交 0）。
- `anchor-unified` 最先在第 5 步提交不同的区域，anchor 为 `7de8e9ed211b`（`%decision.dispatch2`，TTI 942），该策略为 `df0f503fb5f9`（`%decision.dispatch2`，TTI 1003）。首个提交 IR 差异在第 4 步，最终 TTI 差值 +5。
- `dataflow` 最先在第 5 步提交不同的区域，anchor 为 `7de8e9ed211b`（`%decision.dispatch2`，TTI 942），该策略为 `df0f503fb5f9`（`%decision.dispatch2`，TTI 1003）。首个提交 IR 差异在第 4 步，最终 TTI 差值 +5。



### GPU 时间与硬件计数

| 变体 | GPU µs | 相对 anchor | 95% 区间 |
|---|---:|---:|---:|
| original | 6282.637 | +119.64% | [2.18876, 2.20336] |
| anchor | 2864.142 | — | 基准 |
| darm | — | — | TTI 差异 0.64%，未达门槛 |
| anchor-unified | — | — | TTI 差异 0.53%，未达门槛 |
| dataflow | — | — | TTI 差异 0.53%，未达门槛 |

该用例未列入本次 rocprof 对照。

## 汇总

| 用例 | anchor TTI | anchor-unified ΔTTI | dataflow ΔTTI | dataflow 相对 anchor-unified ΔTTI | anchor-unified ΔGPU | dataflow ΔGPU |
|---|---:|---:|---:|---:|---:|---:|
| DCT8 | 62 | +0 | -18 | -18 | — | -0.02% |
| PCM32 | 1136 | +0 | +0 | +0 | — | — |
| NQU64 | 274 | +0 | +0 | +0 | — | — |
| SRAD16 | 436 | -29 | -32 | -3 | -0.43% | -0.36% |
| MapAiry | 3997 | +118 | -126 | -244 | +13.83% | -2.97% |
| LUD8 | 628 | -4 | -4 | +0 | — | — |
| HiPIMS-George | 5572 | -33 | -35 | -2 | — | — |
| tigre-siddon | 942 | +5 | +5 | +0 | — | — |

### 三项指定核查

- **MapAiry 首步。** 两条路径都提交了 `0293233d29ce`。anchor-unified 保留父 IR 的 141 对配对，最低报价 6129 的推测方案因两侧一致收益均为 −3 被 gate 拒绝。通过 gate 的全保护方案报价 6150，与原 anchor 首步持平。dataflow 选中 DARM 的 148 对，整核报价 6129。虽然该布局的生成标签是 all-speculate，148 对覆盖了两条臂的 296 条操作，实际没有 R5，因此允许通过。
  原 anchor 的最终 TTI 为 3997。anchor-unified 为 4115，相对 anchor 的 GPU 时间 +13.83%。dataflow 为 3871，相对 anchor 的 GPU 时间 -2.97%。
- **LUD8 首步。** 父 IR 中的 64 对映射为 63 对，移除的是两臂已提升为同一入口值的工作组 ID。两条路径都使用这 63 对把首步整核 TTI 降到 666，与 anchor 首步相同。最终 TTI 都是 624，比 628 低 4 点（0.64%），未触发新的 GPU 计时。五个产物均通过完整输出校验。
- **高于 anchor 的终值。**
  - MapAiry `anchor-unified` 高 118 点。第 1 步提交后 IR 首次变化，第 5 步的区域序列出现差异。
    同一父 IR 上还有 2 次提交的报价高于原 anchor 布局。第 8 步 4700 → 4705、第 9 步 4639 → 4669。这里也有布局生成差距。
    有 5 次评估在该父 IR 上已有正收益原 anchor 报价，统一布局被 `missing_uniform_gain` 排除。
  - tigre-siddon `anchor-unified` 高 5 点。第 4 步提交后 IR 首次变化，第 5 步的区域序列出现差异。
  - tigre-siddon `dataflow` 高 5 点。第 4 步提交后 IR 首次变化，第 5 步的区域序列出现差异。
  MapAiry 的 anchor-unified 前四步区域及整核报价与 anchor 相同，随后第五步的 R2R 输入已改变。TIGRE 两条统一路径从第 4 步生成不同 IR，第 5 步接到不同的区域，第 6 步追回 56 点，最终各差 5 点。这些是后续父 IR 和候选发生变化的实例。

整核布局审计覆盖 3,151 个直接候选及 714,241 个布局，其中 714,073 个取得报价。707,411 个推测布局被 gate 排除，737 个候选从原最低布局转到通过 gate 的下一布局。这 168 个未报价布局都来自 HiPIMS-George，回填时检测到入口参数类型不相同。该用例另有 6 次求解子进程未返回布局清单。候选和提交数据见报告开头的明细。

## 第 10b 步 LUD8 的 ISA 诊断

对第 10b 步存档的两个 HSACO，从 ELF 的 `lud_perimeter` 函数地址起按符号大小反汇编。用同一代码生成配置的 LLVM 12 带注释汇编核对基本块，再用两条 `s_barrier` 对齐数据装载、局部三角递推和写回。下表的地址为各片段的首末指令。边界上的同步和转移指令不计入 VALU 或访存列。中间两段分别对应第一、第二次 exec 条件跳转后的两条计算路径。

| 阶段 | anchor 地址 | dataflow 地址 | VALU | 访存指令 | v_cndmask |
|---|---|---|---:|---:|---:|
| 首次同步前，装载 staging tile | `2f00–3328` | `2f00–32bc` | 138 → 133 | 26 → 22 | 21 → 22 |
| 两次同步之间，第一个计算路径 | `333c–3778` | `32d0–371c` | 118 → 122 | 29 → 29 | 0 → 0 |
| 两次同步之间，第二个计算路径 | `377c–3940` | `3720–3978` | 30 → 57 | 20 → 20 | 0 → 5 |
| 第二次同步之后，读回及写出 | `3950–3b30` | `397c–3b18` | 63 → 57 | 16 → 14 | 3 → 0 |
| 整个 kernel | — | — | 349 → 369 | 91 → 85 | 24 → 27 |

访存计数包括 LDS、global 和 scalar load。第一次同步前，两版都有 12 条 `global_load_dword`。anchor 使用 12 条 `ds_write_b32`，dataflow 使用 4 条 `ds_write_b32` 和 4 条 `ds_write2_b32`。第二个计算路径的起始序列由 `s_cbranch_execz; ds_read2_b32; v_mov_b32; ds_read2_b32` 变为 `s_cbranch_execz; v_lshlrev_b32; ds_read2_b32; v_mov_b32; ds_read_b32`。该路径后续增加的地址运算和选择抵消了入口和写回段的静态精简。第二次同步后两版均有 8 条 `global_store_dword`。整核均有 3 条 `s_cbranch_execz` 和 7 条非分支的显式 exec 操作，静态占用上限均为 20 waves/CU。

第 10b 步 TTI 从 628 升至 640（+1.91%），未插桩计时从 463.10 ms 升至 546.23 ms，配对中位数 +17.97%。同次复放的 rocprof 中位数显示，每波 VALUInsts 从 349 升到 369，MemUnitBusy 从 59.09% 升到 62.47%，MemUnitStalled 从 45.92% 升到 47.06%。每 dispatch 的 wave 数中位数相同。VGPR 报告为 48 → 44，SGPR 为 16 → 16。证据把差异定位在计算段新增的 VALU、数据选择及访存组织上。现有计数器无法进一步分解访存地址分布、LDS bank 冲突和关键路径各自贡献多少时间，因此无法把 18% 全部归给某一种指令或停顿。
