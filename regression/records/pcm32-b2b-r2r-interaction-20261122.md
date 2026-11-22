# PCM32 的 B2B 布局与后续 R2R 报价（第 7e 步）

## 结论

决定 `trial-33` 报价的是原 Anchor 轨迹第 1–7 次 B2B。沿原顺序重放，把这七次的发射器换成 DARM B2B 后，同父对照 → R2R 候选从 **1138 → 1216（拒绝）** 变为 **1138 → 1136（接受）**。穷举所有少于七次的替换组合，共 21,778 种，均未翻转。第 8 次虽也引入一处 `freeze`，单独换掉对目标报价无影响。

关键七处的分支条件都依赖 LDS 取值，逐 wave 分类为 `unknown`。这七处都有通过 gate 且与所选布局 TTI 打平的 Anchor `linear` 布局，cleanup 后的 IR 同所选 `before-split` 逐字节相同。强制使用这些线性布局仍得到 1216。拟议的 must-diverge 线性平手规则不会在这些请求上触发，也无法恢复第 7d 步实测快 6.83% 的路径。本步未实现规则，其他 16 个 case 没有新规则产物供比较。本步没有 GPU 数据。

## 起点与复现

诊断分支起点为 `158f08f30c6c84f2e7058bdc7cd6e17959e959b9`。重放沿用草案 `87c7d8378ebe813bda4081212b8bf58da6a259c8` 的二进制和第 7d 步在发布配置 R 下记录的父 IR。发布线对照为 `3cf44a1`。设备为 gfx906，workgroup 形状 32×1×1，LLVM24 throughput TTI。冻结输入 IR SHA-256 为 `db3b35287f1ef284e3c8dac514b05fc952a6892345b5ff0077b2840927aaab47`。

| 工具 | SHA-256 |
| --- | --- |
| `decision-greedy`（产生第 7d 步轨迹） | `16a28c9e51a20b776b43786fc04b2dca8b103f3af69a2cf6227b8f513ede4a9a` |
| `fusion-search-llvm24` | `925a6ee70457a54119e3e31f28ef98f918ea770cfb4979ea46da31d5047a3679` |
| `tools/run-llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |

EPYC 的实验目录为 `/data/home/chh/simplify-v2/build/pcm32-b2b-r2r-interaction.urZa9c`。原父 IR 和轨迹在相邻的 `pcm32-darm-b2b-reachability.cMrURt/matrix/PCM32/draft-anchor/`。布局重放对同一父 IR 与同一 split/left/right 各用一次 `--b2b-strategy anchor` 和 `darm`。Anchor 观测模式导出所有布局，包括 cleanup 后重复的布局。分支分类读取该父 IR 的实际 split。

```sh
FUSION_OBSERVE_B2B_DP=dp.jsonl fusion-search-llvm24 \
  --ir PARENT.ll --function _Z3pcmPi --structural 1 \
  --cleanup darm-cfg-dce-instcombine --tti-worker TOOL_ROOT/tools/run-llvm24-tti \
  --anchor-wave-shape 32,1,1 --b2b-strategy anchor \
  --split SPLIT --left LEFT --right RIGHT --ir-snapshots full \
  --debug-dir structural --out fused.ll
fusion-search-llvm24 --ir PARENT.ll --function _Z3pcmPi --split SPLIT \
  --anchor-wave-shape 32,1,1 --anchor-condition-only 1 --out condition.json
python3 step7e-layouts.py "$PWD"
python3 step7e-blocks.py "$PWD" key
python3 step7e-blocks.py "$PWD" outer
python3 step7e-blocks.py "$PWD" linear
python3 step7e-exhaustive.py "$PWD"
python3 step7e-verify-exhaustive.py "$PWD"
python3 step7e-freeze.py "$PWD"
python3 step7e-diff.py "$PWD"
```

## 同父 IR 的 17 次对照

表内的 `1` 至 `9` 对应发射顺序 `b2b-anchor-1` 至 `b2b-anchor-9`。除第 9 次外，依次为 `segmented`、三个 `before-split`、`merged-exit`、两个 `linear` 和两个 `guarded-linear`。所有报价取默认 cleanup 后的 throughput TTI。“对照”列为该请求的只清理版本，第 10 次的 cleanup 本身已从父状态的 1262 降到 1258。

| B2B 次序 | 实际请求 | 同父对照 | Anchor 全布局 TTI（发射顺序） | Anchor 所选布局／TTI | 同父 DARM TTI |
| ---: | --- | ---: | --- | --- | ---: |
| 1 | `trial-0` `B9:B10:B11` | 1392 | 1392, 1392, 1377, 1378, 1377, 1377, 1378, 1399, 1400 | #3 before-split／1377 | 1377 |
| 2 | `trial-2` `B9:B25:B24` | 1377 | 1377, 1377, 1362, 1363, 1362, 1362, 1363, 1384, 1385 | #3 before-split／1362 | 1362 |
| 3 | `trial-4` `B9:B25:B24` | 1362 | 1362, 1362, 1347, 1348, 1347, 1347, 1348, 1369, 1370 | #3 before-split／1347 | 1347 |
| 4 | `trial-6` `B9:B25:B24` | 1347 | 1347, 1347, 1332, 1333, 1332, 1332, 1333, 1354, 1355 | #3 before-split／1332 | 1332 |
| 5 | `trial-8` `B9:B25:B24` | 1332 | 1332, 1332, 1317, 1318, 1317, 1317, 1318, 1339, 1340 | #3 before-split／1317 | 1317 |
| 6 | `trial-10` `B9:B25:B24` | 1317 | 1317, 1317, 1302, 1303, 1302, 1302, 1303, 1324, 1325 | #3 before-split／1302 | 1302 |
| 7 | `trial-12` `B9:B25:B24` | 1302 | 1302, 1302, 1287, 1288, 1287, 1287, 1288, 1309, 1310 | #3 before-split／1287 | 1287 |
| 8 | `trial-14` `B9:B25:B24` | 1287 | 1287, 1287, 1272, 1273, 1272, 1272, 1273, 1294, 1295 | #3 before-split／1272 | 1272 |
| 9 | `trial-16` `B0:B2:B1` | 1272 | 1262, 1272 | #1 segmented／1262 | 1262 |
| 10 | `trial-17` `B13:B14:B15` | 1258 | 1258, 1258, 1243, 1244, 1243, 1243, 1244, 1265, 1266 | #3 before-split／1243 | 1243 |
| 11 | `trial-19` `B12:B19:B18` | 1243 | 1243, 1243, 1228, 1229, 1228, 1228, 1229, 1250, 1251 | #3 before-split／1228 | 1228 |
| 12 | `trial-21` `B12:B19:B18` | 1228 | 1228, 1228, 1213, 1214, 1213, 1213, 1214, 1235, 1236 | #3 before-split／1213 | 1213 |
| 13 | `trial-23` `B12:B19:B18` | 1213 | 1213, 1213, 1198, 1199, 1198, 1198, 1199, 1220, 1221 | #3 before-split／1198 | 1198 |
| 14 | `trial-25` `B12:B19:B18` | 1198 | 1198, 1198, 1183, 1184, 1183, 1183, 1184, 1205, 1206 | #3 before-split／1183 | 1183 |
| 15 | `trial-27` `B12:B19:B18` | 1183 | 1183, 1183, 1168, 1169, 1168, 1168, 1169, 1190, 1191 | #3 before-split／1168 | 1168 |
| 16 | `trial-29` `B12:B19:B18` | 1168 | 1168, 1168, 1153, 1154, 1153, 1153, 1154, 1175, 1176 | #3 before-split／1153 | 1153 |
| 17 | `trial-31` `B12:B19:B18` | 1153 | 1153, 1153, 1138, 1139, 1138, 1138, 1139, 1160, 1161 | #3 before-split／1138 | 1138 |

17 组 Anchor/DARM 报价都打平。17 个 B2B 条件的 wave 分类均为 `unknown`。形状来自冻结 launch，只有一个部分占用 wave，运行时条件未知，混合 wave 数无法确定。第 9 次依赖 `amdgcn.dispatch.ptr` 及 `addrspace(4)` 的 load。其余 16 次均为 `icmp sgt` 比较 LDS 读出的值。目标 R2R 自己的外层条件仍是第 7d 步验证的 `must-diverge`。

对有九个布局的 16 次请求，#1、#2 与同父对照持平，普通 TTI 判据拒绝。#3–#5 属 fork 规划，无线性 gate 限制。#6、#7 两侧一致报价均非负，通过 gate。#8、#9 两侧报价均负，记录为 `negative_uniform_gain`，普通 TTI 也判亏。第 1–8 次 #6/#7 的 `uniform_gain_false/true` 分别为 +9/+9、+8/+8，#8/#9 为 −8/−8、−9/−9。第 10–17 次对应 +13/+13、+12/+12、−4/−4、−5/−5。第 9 次只生成 `segmented` 和 `before-split`，后者和同父对照持平。

16 次 #6 和 #3 的 cleanup 后 IR 都逐字节相同。搜索仍为 #6 计算自己的侧向报价，gate 通过后按 cleanup 后 IR 哈希去重。同分的非重复布局也不会覆盖当前最优，因 `fusion_search_llvm24_main.cpp` 要求 `result.total > score.total`。因此改变枚举顺序最多能在这 16 次平手中改布局标签，产物保持相同。

## 替换实验

替换按 Anchor 的 17 次操作排序。每一步在当前重放父 IR 上重新映射分支与左右块、重新发射并 cleanup，使用原块序列的归一化指纹、相邻块和两条边的方向检查同一操作。这样能区分布局差异与第 7d 步两种策略的调度差异。第 17 次后，在新目录用同一 split 和区域形状重新定位原 `B4:H5_7:H6_7`，无论局部编号是否改变。首次重放因脚本漏识别命名入口 `fusion.common` 退出。修正命名和隐式入口解析后重新执行，以成功批次的回执为准。

| 从 Anchor 路径换成 DARM B2B 的步骤 | `trial-33` 同父对照 → 候选 | 判定 |
| --- | ---: | --- |
| 无 | 1138 → 1216 | 拒绝 |
| 仅第 1 次 | 1138 → 1208 | 拒绝 |
| 仅第 2–7 次中的任一次 | 1138 → 1204 | 拒绝 |
| 仅第 8–17 次中的任一次 | 1138 → 1216 | 拒绝 |
| 第 2–7 次 | 1138 → 1144 | 拒绝 |
| 第 1–7 次中保留第 1 次，省掉第 2–7 次中的任一次 | 1138 → 1148 | 拒绝 |
| 第 1–7 次全部 | 1138 → 1136 | 接受 |
| 第 8–17 次全部 | 1138 → 1216 | 拒绝 |
| 17 次全部 | 1138 → 1136 | 接受 |

先测第 1–7 次的 128 个子集。候选报价为 `1216 − 8×是否替换第1次 − 12×第2–7次的替换数`。在这 128 个子集中，只有全替换接受。将第 8–17 次单独追加到成功的七次组合，报价始终为 1136。从全替换里逐个删掉一次，删第 1 次变为 1144，删第 2–7 次中任一次变为 1148，删第 8–17 次中任一次仍为 1136。

再穷举 17 次提交中替换 0–6 次的所有组合。共享重放前缀，每条链仍用实际发射和 cleanup 得到自己的父 IR。独立核对全部组合的掩码、目标报价和判定。21,778 条最终父 IR 的 SHA-256 各不相同，同父对照均为 1138。上述公式对全部 21,778 条成立，未发现后十次与关键七次的交互能补偿少做的一次。前七次因此是一个最小替换组合。

| 替换数 | 组合数 | 候选 TTI 范围 | 接受数 |
| ---: | ---: | ---: | ---: |
| 0 | 1 | 1216 | 0 |
| 1 | 17 | 1204–1216 | 0 |
| 2 | 136 | 1192–1216 | 0 |
| 3 | 680 | 1180–1216 | 0 |
| 4 | 2,380 | 1168–1216 | 0 |
| 5 | 6,188 | 1156–1216 | 0 |
| 6 | 12,376 | 1144–1216 | 0 |

另做三组 Anchor 线性对照。分别强制 16 个可用请求各自改用平手的 #6、同时在第 1–7 次使用 #6、同时在全部 16 个可用请求上使用 #6。18 条重放链最后均为 1138 → 1216，`trial-33` 均被拒绝。

## IR 差异与触发机制

在同父同块对的第 1 次报价中，LLVM12 `llvm-diff ANCHOR.ll DARM.ll _Z3pcmPi` 报告相同的计算及访存，条件的数据流多一层 `freeze`。第 2–7 次也有相同的局部差异。第 1 次的输出摘录如下，省略无关计算及原行末的 TBAA 附件。

```llvm
; Anchor before-split（linear #6 同字节）
%288 = freeze i1 %285
%289 = select i1 %288, i32 %281, i32 %284
store i32 %289, i32 addrspace(3)* %287, align 4

; DARM（局部编号不同）
%merged.select = select i1 %284, i32 %280, i32 %283
store i32 %merged.select, i32 addrspace(3)* %286, align 4
```

`emitB2BLinear` 的线性发射，以及本例包含访存的 before-split 发射，均复用冻结后的条件构造 select。LLVM24 对这些局部差异给出了相同的 B2B 报价。到 R2R 时，该草案的 `isCheapIntegerGapInstruction` 白名单没有 `Freeze`。不符合要求的 gap 保留守护，守护结果经 select 等使用链使依赖 gap 也保留守护。比较 `trial-33` 的两份 raw IR，第 1–7 次改用 DARM 的版本少 7 条 `freeze`、2 条条件跳转、3 条无条件跳转和 11 条 PHI，多 1 条 select。load/store 数量及 GEP 数量相同。

为隔离变量，先用 LLVM12 `opt -instnamer` 给父 IR 补名字，确认报价未变，再只改最终父 IR 的 R2R 右臂 `B6`。删除前七个为 `icmp sgt` 的 select 提供条件的 `freeze`，候选从 1216 降至 1136；只删第八个，仍为 1216。反向对照在成功组合的父 IR 显式插回前两个条件中任意一个的 `freeze`，报价分别回升至 1151 与 1155。插回前七个则为 1264。修改后的 IR 通过 verifier。这是诊断性 IR 干预，verifier 通过不足以证明去除 `freeze` 维持 poison/undef 语义。

Anchor 当前缺少能在保留原分支条件语义的前提下，使下游 R2R 共享这些整数 gap 的布局。可单独评估有充分 definedness 与支配证明时复用原比较值，或让 R2R 保留 `freeze` 语义并有针对性地处理含它的 gap。本步未修改发射器、报价或接受逻辑。

第 1–7 次替换的局部反事实候选按第 7d 步命令静态编译为 HSACO，SHA-256 为 `c5dcb2538877cbc88c61cd6a8c3b2a7c7cb87d264b01c5f0efb646ee95536157`。它与第 7d 步的 `5ba36c22…` 及第 7 步的 `5b7adc29…` 都不同，局部反事实的 `.text` 为 3940 字节，第 7d 步的为 3904 字节。沿 Anchor 原顺序替换全部 17 次时，最终 IR SHA-256 为 `b6b4ed6fadc9af268a885d016459218c2af7d9ce77896c9c65ca5d386c67bb49`，设备对象与第 7d 步实测对象逐字节相同（`5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816`）。因此发射选择足以在原调度顺序下复现快 6.83% 的对象。前七次组合的 1136 只说明接受判定翻转，该对象未测量。 [第 7d 步 GPU 记录](pcm32-darm-b2b-reachability-20261122.md#pcm32-gpu-对比)

## 回执

脚本、逐布局 IR、重放父 IR 和 `llvm-diff` 原始输出保存在 EPYC 实验目录。此提交只包含诊断记录。在草案二进制的构建目录使用固定工具链运行 `bash tests/run-v1`，退出码为 0，覆盖 Anchor 规划和发射、R2R 整数 gap、TTI 报价、trial queue、评分失效与 normalize-only。

| 回执 | SHA-256 |
| --- | --- |
| `layouts.json` | `d958f3aaf476e9137ea874e37494def0acc80dbbcaed67b18a6a4d992abcb8ac` |
| `aggregate-darm-1.json` | `a21f496da1b9514150a5132c48f7fe36113bb8af097874d2d5e0771e09af1c69` |
| `key.json` | `281a04d0c5e801c771eeff1e4664695068f0e38d6828586a1bfbdab88a598221` |
| `outer.json` | `0288c4e0733da8157009e9565b85565680af3236c28c0dd9930875d88ca4b2ab` |
| `linear.json` | `7a3324499429021d24740a6100fd6ef345fcaed1c88a5a5c7118893d3445d500` |
| `freeze.json` | `577294d2422ca0fc8e6aead9ec9075aca1bdcd3d45240b5a0f0f0c4be6914217` |
| `structure.json` | `ce650b5e990f6cc7d47674d381860fcfadbf69a42c1d335d3a533cdf6086c1b3` |
| `tests-run-v1.log` | `b7dc2e0f0894529f0dfcb5e2efcca976ab032f38a4a2d3bbc3be31f382d568a4` |
| `exhaustive/targets.jsonl` | `8e7385f8a5e7191a23afc35a45bc637e24418c3c45164d62e756acbfa39f2e30` |
| `exhaustive-summary.json` | `5fdd2e3f1e7c29ae38d66f9eb378e14fdd286cc260aa4741fefe4b7c295723a7` |
