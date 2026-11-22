# PCM32 搜索路径分叉诊断（第 7b 步）

## 结论

- **IR 从第 1 次融合就分叉，提交位置从第 2 次才分叉。** 首次两版都选 `B9:B10:B11`，同为 1392 → 1377。当前 Anchor 和历史 DARM 的发射 IR 不同。第 2 次两处候选在当前同一父 IR 都报价 1362，历史选 `B15:B16:B17`，当前活动域只试 `B9:B25:B24` 的直接版和归一化版。差异来自活动域筛选。同样的全局枚举顺序下，严格低价才换胜者，因此历史全局平手取先出现的候选。
- **当前工具可以强制到达两条历史 R2R 的结构位置，但两条报价仍为负。** 原样接着跑 A 或 B，当前发布 Greedy 最终收敛到同一个 1138 的 IR。强制改变 B2B 顺序也没有重现历史 R2R 的收益。第二条的当前试融与发布 `trial-33` 通过了函数级 LLVM IR diff 对照，逐类指令报价一样。
- **当前没有证据支持为 PCM32 增加有限前瞻，也没有证据支持全局追加 3-pass。** 要复现历史收益，先定位旧 R2R 原始产物与当前原始产物的差异，重建能生成有利形态的候选，再单独验证打分。单独换路径或增加 cleanup 都没有在本次当前重放上复现翻转。

## 输入和方法

起点 `3cf44a132f0b069577ad40ce2523bbb31aad46ff`，分支 `study/pcm32-path-divergence`。当前二进制来自发布合并复验目录 `/data/home/chh/simplify-v2/build/anchor-release-merge.t6fjhP/source`。历史二进制及原轨迹取自第 7 步重建的 `3510dfb74de85e02dd6f8f4e8d3a2dfcdf2fe267`，不是已遗失的原始 `trial-70` 归档。实验目录为 `/data/home/chh/simplify-v2/build/pcm32-path-divergence.2j3BS7`。

| 二进制 | SHA-256 |
| --- | --- |
| 当前 `decision-greedy` | `cd0077ce173f8c165360070f3e2f2127aa2956b2f8d056633be49cb20991080b` |
| 当前 `fusion-search-llvm24` | `1e7eb3d975edbcfbc74954798ec29380b5f6c8ce209fc5398b1bd1ef210cdf54` |
| 双方 LLVM24 TTI worker | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| 历史 `historical-greedy` | `b52dc0a87ba00c81bf61dffe8dfbd2b5f0b0dde5783bf3e0b29ec61a0efb7e3e` |
| 历史 `fusion-search-llvm24` | `8bdf2dedf7a34854ff078504a8b1d0fefb084f970deb1f5f7a89e097e3b09591` |

两条 PCM32 完整轨迹读取相同冻结 IR，SHA-256 为 `db3b35287f1ef284e3c8dac514b05fc952a6892345b5ff0077b2840927aaab47`。当前分别以 PCM32 32×1×1、NQU64 64×1×1、LUD8 16×1×1 运行。LLVM12 验证通过的候选使用 LLVM24 throughput 报价，附加 pass 对同父对照、候选与未准备轮父状态完全对称。在重放内部布局时固定发布 gate 的侧向判定，只重新算 throughput。每个强制选择都先检查目录，再用原二进制显式试融，把通过 verifier 的 `fused.ll` 送入下一步。强制过程绕开自然活动域选择，重启 Greedy 的对照从种子重新发现决策域。

```sh
decision-greedy INPUT FUNCTION TOOL_ROOT active --anchor-wave-shape X,Y,Z
fusion-search-llvm24 --ir PARENT --function FUNCTION --catalog-only 1 --debug-dir CATALOG --out COPY.ll
fusion-search-llvm24 --ir PARENT --function FUNCTION --structural 1 --cleanup darm-cfg-dce-instcombine \
  --split SPLIT --left LEFT --right RIGHT --b2b-strategy anchor --anchor-wave-shape X,Y,Z \
  --tti-worker TOOL_ROOT/tools/run-llvm24-tti --debug-dir TRIAL --out FUSED.ll
opt -enable-new-pm=0 -instcombine -speculative-execution -simplifycfg -verify-each -S IR -o THREE.ll
opt -enable-new-pm=0 -instcombine -speculative-execution -correlated-propagation -simplifycfg -verify-each -S IR -o FOUR.ll
TOOL_ROOT/tools/run-llvm24-tti IR FUNCTION --summary-only
```

扫描、强制与副作用脚本依次为 `step7b-alignment.py`、`step7b-first.py`、`step7b-probe.py`、`step7b-force.py`、`step7b-controls.py`、`step7b-rollouts.py`、`step7b-homology.py`、`step7b-overhead.py`、`step7b-side.py` 和 `step7b-extra.py`。命令、候选表、IR 和日志留在实验目录。此提交只有诊断记录，未新增 GPU 测量。作为起点的发布复验已通过 17 个 case 和 32 个设备对象对比，回归 16 项通过、4 项按已知失败清单跳过。

## 逐轮轨迹及分叉

对齐使用提交序号，因为历史轨迹切换搜索阶段时 iteration 归零，当前也会在活动域退出后重新计数。下表保留每次提交前后的 TTI、所选位置与该轮实际尝试数。`aligned.json` 保存所有轮次与尝试，包括未提交轮、完整父 IR 路径及 SHA-256、准备态哈希、选中状态、候选控制报价、候选报价、侧向收益、资格和 fused IR 哈希。历史共 18 轮、140 条尝试，当前 20 轮、50 条尝试（含 16 条仅归一化）。

| 提交 | 历史 trial／位置 | 历史 TTI | 尝试 | 当前 trial／位置 | 当前 TTI | 尝试 |
| ---: | --- | ---: | ---: | --- | ---: | ---: |
| 1 | `trial-0` `B9:B10:B11` | 1392 → 1377 | 2 | `trial-0` `B9:B10:B11` | 1392 → 1377 | 3 |
| 2 | `trial-3` `B15:B16:B17` | 1377 → 1362 | 16 | `trial-2` `B9:B25:B24` | 1377 → 1362 | 3 |
| 3 | `trial-19` `B15:B43:B42` | 1362 → 1347 | 15 | `trial-4` `B9:B25:B24` | 1362 → 1347 | 3 |
| 4 | `trial-34` `B15:B43:B42` | 1347 → 1332 | 14 | `trial-6` `B9:B25:B24` | 1347 → 1332 | 3 |
| 5 | `trial-48` `B15:B43:B42` | 1332 → 1317 | 13 | `trial-8` `B9:B25:B24` | 1332 → 1317 | 3 |
| 6 | `trial-61` `B15:B43:B42` | 1317 → 1302 | 12 | `trial-10` `B9:B25:B24` | 1317 → 1302 | 3 |
| 7 | `trial-73` `B15:B43:B42` | 1302 → 1287 | 11 | `trial-12` `B9:B25:B24` | 1302 → 1287 | 3 |
| 8 | `trial-84` `B15:B43:B42` | 1287 → 1272 | 10 | `trial-14` `B9:B25:B24` | 1287 → 1272 | 3 |
| 9 | `trial-94` `B15:B43:B42` | 1272 → 1257 | 9 | `trial-16` `B0:B2:B1` | 1272 → 1262 | 1 |
| 10 | `trial-103` `B23:B25:B24` | 1257 → 1242 | 8 | `trial-17` `B13:B14:B15` | 1262 → 1243 | 3 |
| 11 | `trial-111` `B23:B25:B24` | 1242 → 1227 | 7 | `trial-19` `B12:B19:B18` | 1243 → 1228 | 3 |
| 12 | `trial-118` `B23:B25:B24` | 1227 → 1212 | 6 | `trial-21` `B12:B19:B18` | 1228 → 1213 | 3 |
| 13 | `trial-124` `B23:B25:B24` | 1212 → 1197 | 5 | `trial-23` `B12:B19:B18` | 1213 → 1198 | 3 |
| 14 | `trial-129` `B23:B25:B24` | 1197 → 1182 | 4 | `trial-25` `B12:B19:B18` | 1198 → 1183 | 3 |
| 15 | `trial-133` `B23:B25:B24` | 1182 → 1167 | 3 | `trial-27` `B12:B19:B18` | 1183 → 1168 | 3 |
| 16 | `trial-136` `B9:B22:B21` | 1167 → 1152 | 2 | `trial-29` `B12:B19:B18` | 1168 → 1153 | 3 |
| 17 | `trial-137` `B0:B2:B1` | 1152 → 1141 | 2 | `trial-31` `B12:B19:B18` | 1153 → 1138 | 3 |

未提交轮单独对齐。历史末轮 1141 试 `trial-139` 后结束。当前在第 8 次提交后退出 `%275` 域（1272，无候选）；末轮 1138 试 `trial-33`，随后空轮结束。

第 1 次提交在相同父 IR 上直接重放。历史 DARM 和当前显式 DARM 的 raw、cleanup 产物分别逐字节一致。当前 Anchor raw TTI 为 1392，DARM 为 1400；两者 cleanup 后均为 1377。Anchor 生成 `freeze i1` 后的 select，原始 DARM 发射结构不同。第 2 次提交的父哈希在此已分开：

| 父状态 | SHA-256 |
| --- | --- |
| 历史第 1 次产物 | `4779f947017649a607080591b056cf2df29f50d28fbdaf2fa56cfdd9605d0fdb` |
| 当前第 1 次产物 | `9a4726aeef3d74123348dd526ac64119dd3c8bd8b7f936fc057d721db0d9e475` |

历史第 2 轮开放 16 个对，`B0:B2:B1` 为 1366，另外 15 个都是 1362，第一条最低价 `B15:B16:B17` 获选。当前在自己的第 2 轮也有 16 个目录项；逐个离线重放，`B0:B2:B1` 是 1367，其余 15 个仍为 1362，包含 A `B9:B25:B24` 和 B `B15:B16:B17`。但是运行中的 `roundCandidates` 先用 `decisionSplit` 和活动域缩小结构候选集，当轮实际只试 A 的直接版和准备版（各 1362），外加 1377 的未融合归一化。即使把 B 作为额外试融，**即时 TTI 代价差为 0**。两版都以严格低价更新胜者，平手使用枚举先后。

## 强制历史选择与 R2R 报价

从发布第一次产物接 B 后，按历史位置逐一重放，15 个后续 B2B 都能在当前目录找到并合法生成。第 16 次提交后目录包含 `B7:H8_10:H9_10`，第 17 次提交后目录包含 `B5:H6_8:H7_8`。对每个点取对应的同父 cleanup 对照。以下是控制 TTI → 候选 TTI，粗体表示按该档位报价合格。R2R 默认还要严格低于轮父 TTI；这里没有因该条件改变表中方向。

| 路径与 R2R | 默认 | 追加 3-pass | 追加 4-pass |
| --- | ---: | ---: | ---: |
| 历史二进制及历史父 IR，138 | 1152 → 1254 | **1152 → 1150** | **1152 → 1147** |
| 历史二进制及历史父 IR，139 | 1137 → 1239 | **1137 → 1135** | **1137 → 1132** |
| 当前 Anchor，发布第一次产物后强制历史顺序，138 | 1152 → 1354 | 1152 → 1288 | 1152 → 1282 |
| 当前 Anchor，发布第一次产物后强制历史顺序，139 | 1138 → 1340 | 1138 → 1274 | 1138 → 1268 |
| 当前 Anchor，历史第一次产物后强制历史顺序，138 | 1152 → 1349 | 1152 → 1283 | 1152 → 1276 |
| 当前 Anchor，历史第一次产物后强制历史顺序，139 | 1138 → 1335 | 1138 → 1269 | 1138 → 1262 |
| 当前 B2B 设为 DARM，发布第一次产物后强制历史顺序，138 | 1152 → 1282 | 1152 → 1282 | 1152 → 1282 |
| 当前 B2B 设为 DARM，发布第一次产物后强制历史顺序，139 | 1138 → 1268 | 1138 → 1268 | 1138 → 1268 |
| 当前 R2R 发射器直接用历史 138 的固定父 IR | 1152 → 1277 | 1152 → 1277 | 1152 → 1276 |
| 当前 R2R 发射器直接用历史 139 的固定父 IR | 1137 → 1262 | 1137 → 1262 | 1137 → 1261 |

当前的强制 139 父 IR 和发布末态父 IR 字节不同，编号也不同。将其 fusion 产物 `B5:H6_8:H7_8` 和发布 `trial-33` 的 `B4:H5_7:H6_7` 用 LLVM12 `llvm-diff … _Z3pcmPi` 比较，退出码为 0，整个函数的父／候选逐类指令报价统计也一致。最终文本哈希仍不同。按当前工具能观测到的计算结构和 TTI，发布 `trial-33` 已覆盖这里的 139 类试融。用强制 138 的父 IR 启动原 driver 时，该轮只试 B2B，随后试 139，未试显式目录中的 138。**目录可见性、driver 实际送评和试融合格是三个独立条件。**

交叉清理固定历史父 IR，把两版 R2R 各自发出的 raw IR 分别交给两版 `--control-only`。历史 raw 的 TTI 为 1457／1446，当前 raw 均高 104，分别为 1561／1550。历史 raw 用当前默认 cleanup 已可降到 1150／1135；当前 raw 即使用历史 cleanup 再追加 3-pass 也只到 1279／1264。故最早的差异已在清理前出现。本次交叉试验没有把这 104 点进一步归因到某条 DARM 发射规则。

## 前瞻深度和开销

分别拿发布候选 A、显式试融的 B 作为种子，在当前 driver 下完整续跑。这里 `k` 表示在选择 A 或 B 以后继续提交的次数。

| k | A 续跑 TTI | B 续跑 TTI |
| ---: | ---: | ---: |
| 0 | 1362 | 1362 |
| 1 | 1347 | 1347 |
| 2 | 1332 | 1332 |
| 3 | 1317 | 1317 |
| 4 | 1302 | 1302 |
| 5 | 1287 | 1287 |
| 6 | 1272 | 1272 |
| 7 | 1262 | 1257 |
| 8 | 1243 | 1247 |
| 9 | 1228 | 1228 |
| 10 | 1213 | 1213 |
| 11 | 1198 | 1198 |
| 12 | 1183 | 1183 |
| 13 | 1168 | 1168 |
| 14 | 1153 | 1153 |
| 15 | 1138 | 1138 |

从当前搜索的活动域做 top-2，在分叉处只有 A 的两个试融版本，无法纳入另一域的 B。把 B 显式加入以后，`k=1` 是 1347 对 1347，`k=7` 暂时偏向 B 5 点，下一步又偏向 A 4 点。两条自然续跑最终 IR 逐字节一致，SHA-256 `52a258bf879109e710292a134b44cee0e59c360adb1dfd82b7906e3796cbb91a`。两条自然续跑都未得到可接受的这类 R2R。

强制历史顺序下，选择 B 后至少 14 次后续提交才能到 138 的父态、15 次才能到 139 的父态；若把 R2R 转移本身也计作一层，则分别是 **15／16**。这是这条实测路径的暴露深度。两次试融在当前报价及 3-pass、4-pass 下仍亏，增加深度本身没有使选择翻转。

发布二进制顺序重跑三次，其完整 Greedy 的最终 IR 与发布哈希逐字节一致。下表以总墙钟中位数除以记录轮数，估计在普通轮额外扩展一个状态的增量。含无尝试的轮，且实际开销受缓存、并发和候选数影响；不代表实现了一个新的搜索器。

| Case | 完整 Greedy 中位数 | 轮／尝试 | 每新增一路一层的量级 | 候选集观察 |
| --- | ---: | ---: | ---: | --- |
| PCM32 | 5.277 s | 20／50 | 约 0.264 s | 分叉当轮仅一个不同结构候选。纳入全目录后有 16 对，首层会多试 15 对。实跑 A、B 各自续完约 4.62 s。 |
| NQU64 | 0.515 s | 4／17 | 约 0.129 s | 首轮 5 个请求，两条融合平手为 282。两条续跑第一步均为 274，`trial-2` 再走一步到 269，`trial-0` 停在 274。各自完整续跑约 0.365 s。 |
| LUD8 | 2.021 s | 5／4 | 约 0.404 s | 原搜索每轮最多一个结构候选，想增加分支需保留内部布局或扩大结构目录。 |

用同样的均轮成本粗估，PCM32 只额外跟踪一条路径 15–16 层已约 **4.0–4.2 s**，还未计入扩大首层和多条平手分支。NQU64 的 269 是静态续跑值，不能用来推断 GPU 收益；第 7 步另一个 GVN 路径虽降到 268，GPU 反而慢 9.4%。

## 3-pass 对 NQU64 / LUD8 的副作用

| Case | Greedy 层请求（含归一化） | Greedy 请求资格翻转 | Anchor 内部布局 | 内部布局资格翻转 |
| --- | ---: | ---: | ---: | ---: |
| NQU64 | 17（13 次融合、4 次归一化） | 0 | 12 | 0 |
| LUD8 | 4 | 0 | 32 | 2 次拒绝 → 接受 |

NQU64 首轮两条报价仍为 282，所选顺序不变，未获选的 289 → 288 归一化仍合格。LUD8 若只复算原来各对块返回的布局，会漏掉两条翻转。两条均为无 gate 拒绝项的 `b2b-anchor-5`：

| 候选／布局 | 默认父／对照／候选 | 3-pass 父／对照／候选 | 重排后 |
| --- | ---: | ---: | --- |
| `trial-1 / b2b-anchor-5` | 666／656／661 | 666／656／654 | 合格，仍输给同轮 637 的写回 |
| `trial-3 / b2b-anchor-5` | 637／634／639 | 637／634／632 | 末轮新增提交；从这份 IR 启动发布 Greedy，0 次后续提交，最终 632 |

这两次内部布局翻转补齐了第 7 步的 3-pass 覆盖。第 7 步已测过 3-pass 对各对块原返回布局的影响，完整布局表此前仅含 EarlyCSE/GVN/DSE/O3。

## 回执

| 文件 | SHA-256 |
| --- | --- |
| `aligned.json` | `8c67f26db7389dd39543905c380341fe44bfd1e43116d02f24a62455f9ef9270` |
| `first-trial/results.json` | `f50ba2aa07e0bb2911e31c3f2184b6a070f273c64a9f4fd647e1390ad7990be1` |
| `fork-scores.json` | `8b64de2228f083d0172213e872a154e4a82761817d186626fcfd6182e1ab8062` |
| `force/from-release-first/chain.json` | `f6989ecd7e7c766fa51e7844ba0386d4edca85ea902d418e221762fbd0735219` |
| `force/from-historical-first/chain.json` | `a03a6d0c9f0e2a13e639ad0855a1d578548169c8d1df9752d47c2823c5cf03f9` |
| `force/from-release-first-darm/chain.json` | `08262b2d02840acea1dbe91464c8d1404ce55c1aa7f03977b4b52a9768fa00dd` |
| `cross-cleanup.json` | `0f0f2ab93dba799a78b31037dd84f0a5e6e87d916ef2c8a30d29ad4fd573b28c` |
| `rollouts.json` | `54edf32c4af312bc2b3269e59fcfc045082ee2cd88b5310fd4ee68f59dc8d6d6` |
| `overhead.json` | `f9c054792b3aa56c5bbf15831d6a5342f1ae15541c84e13bc34d634057d39d18` |
| `nqu-alternatives.json` | `57cb352f57b2f6c06df84fcf5eead507a9376757ee0c4d24d92ce0b360ca5bd7` |
| `side.json` | `7fb7986379a48f358f2267d8538ec8b9b38eb55f70afe0df2b81daba6083b402` |

历史 cleanup、GPU 基线与已测历史变体参见 [第 7 步](pcm32-cleanup-strength-20261122.md)。
