# PCM32 的 DARM B2B 可达性（第 7d 步）

## 结论

四种组合都未复现第 7 步的 `5b7adc29…` HSACO。草案 + DARM B2B 仍未走过历史路径，但在当前路径上多提交一次 R2R，最终 18 次、TTI 1136。两个历史 R2R 和新的 DARM 父 `trial-33` 都满足 must-diverge 豁免。新 HSACO 相对发布默认快 6.83%，与 Auto DARM 持平。

## 起点与复现口径

本步从 `study/pcm32-path-divergence` 的 `70a84665f120e401a8bf5ad8cbf6f5bb76db8218` 开始。对照使用 `3cf44a132f0b069577ad40ce2523bbb31aad46ff` 的发布二进制，草案使用 `87c7d8378ebe813bda4081212b8bf58da6a259c8` 当时验证的二进制。实验目录为 EPYC 的 `/data/home/chh/simplify-v2/build/pcm32-darm-b2b-reachability.cMrURt`。

| 二进制 | 发布 SHA-256 | 草案 SHA-256 |
| --- | --- | --- |
| `decision-greedy` | `cd0077ce173f8c165360070f3e2f2127aa2956b2f8d056633be49cb20991080b` | `16a28c9e51a20b776b43786fc04b2dca8b103f3af69a2cf6227b8f513ede4a9a` |
| `fusion-search-llvm24` | `1e7eb3d975edbcfbc74954798ec29380b5f6c8ce209fc5398b1bd1ef210cdf54` | `925a6ee70457a54119e3e31f28ef98f918ea770cfb4979ea46da31d5047a3679` |

PCM32 读取发布 manifest 的冻结 IR，输入 SHA-256 为 `db3b35287f1ef284e3c8dac514b05fc952a6892345b5ff0077b2840927aaab47`。形状固定为 32×1×1。各版本搜索完都执行 LLVM12 verifier。设备对象沿用第 7 步的 LLVM12 `opt -O3 -verify-each`、`llc -O3 -mcpu=gfx906 -mattr=+sramecc,-xnack -amdhsa-code-object-version=4` 和 ROCm 6.3.3 `ld.lld -shared`。

```sh
decision-greedy PCM32.ll _Z3pcmPi TOOL_ROOT active --anchor-wave-shape 32,1,1
decision-greedy PCM32.ll _Z3pcmPi TOOL_ROOT active --anchor-wave-shape 32,1,1 --b2b-strategy darm
fusion-search-llvm24 --ir ACTUAL_PARENT.ll --function _Z3pcmPi --split SPLIT \
  --anchor-condition-only 1 --anchor-wave-shape 32,1,1 --out condition.json
```

脚本 `step7d-matrix.py`、`step7d-gate.py`、`step7d-trajectory.py`、`step7d-catalog.py`、`step7d-gpu.py` 保存在实验目录。此步只提交诊断记录。

## 完整 PCM32 搜索与设备对象

| 配置 | 提交数 | 最终 throughput TTI | 最终 IR SHA-256 | HSACO SHA-256 |
| --- | ---: | ---: | --- | --- |
| 发布 + Anchor | 17 | 1138 | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` | `a0a8df33ee604bc77519a3887af2c8663afa6c7f0cd609dd392d136a815ec116` |
| 草案 + Anchor | 17 | 1138 | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` | `a0a8df33ee604bc77519a3887af2c8663afa6c7f0cd609dd392d136a815ec116` |
| 发布 + DARM B2B | 17 | 1138 | `fc980493dfda4f3952d58009c2e7d17019572bf8c494befbcdf85f3d2b5a6cdb` | `01658668f4436b31d43f14423abff5a3954215e510a7692c9198f43009be2050` |
| 草案 + DARM B2B | 18 | 1136 | `81021a900e7eb11a581f6e18bb6f312640a1c64e07cc3921e0207f755c5278cb` | `5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816` |

四份 HSACO 均不同于第 7 步历史续跑的 `5b7adc29cd6f0938d17bbc3b226ce04f96805003eeb05987f960ae41303e9c6e`。草案 + DARM B2B 与该历史对象的 `.text` 都是 3904 字节，但段哈希分别为 `7fbbdfc63e2cb39ca8034040a79c8d3cada9068c3a2c211e351ca5cee02fdfd7` 与 `59318c3a970386ad3244259fe24670f749fcb8e20a27ab3edce548b7030623a3`。发布 + DARM B2B 匹配冻结 manifest 的 `darm_reference` 对象。它和原版 Auto DARM 是不同的对照角色。

## 草案 + DARM B2B 的轨迹

两套 DARM B2B 的前 17 次提交逐项一致，包括各次生成 IR 的 SHA-256。两者第一次都选 `B9:B10:B11`（1392 → 1377），第二次都选 `B0:B2:B1`（1377 → 1367，域 `%1`）。历史路径的第二次是 `B15:B16:B17`（1377 → 1362）。现有 ordered driver 的活动域调度照常生效。逐轮重扫草案 + DARM 的 19 个父态，目录和实际送评记录都没有出现两条历史 ID `B7:H8_10:H9_10`、`B5:H6_8:H7_8`。

草案 + DARM 在第 18 次提交接受同类的 `trial-33`（`B4:H5_7:H6_7`）。其父 IR 是该 DARM B2B 链的第 17 次产物，SHA-256 为 `fc980493dfda4f3952d58009c2e7d17019572bf8c494befbcdf85f3d2b5a6cdb`。发布同父对照 → 候选为 1138 → 1263，草案为 1138 → **1136**。最后一个空轮结束。首次到达可提交的 R2R 由这套 B2B 父状态和有限推测共同形成。四条完整链及逐次哈希在 `trajectories.json`，19 个目录及送评名单在 `catalogs.json`。

## 分类与逐布局一致代价

对草案两条完整搜索中所有合法 R2R，以及两个固定历史 R2R 和发布 `trial-33` 的原父，按 6a 的只读分类器检查实际 split。每个请求只有一个区域发射布局 `darm-R2R`，侧向报价取该布局 cleanup 后的 `score_result.metrics`。同父发布重放检查了 raw 差异。当前草案并未执行 R2R gate，下面是用 B2B 规则推算的结果。

| 父 IR／R2R | 草案同父对照 → 候选 | uniform false／true | wave 分类 | 只看 gate | 普通 TTI |
| --- | ---: | ---: | --- | --- | --- |
| 固定历史 `trial-138`，`B7:H8_10:H9_10` | 1152 → 1150 | −123／−107 | must-diverge | 豁免 | 接受 |
| 固定历史 `trial-139`，`B5:H6_8:H7_8` | 1137 → 1135 | −119／−103 | must-diverge | 豁免 | 接受 |
| Anchor 父 `trial-33`，`B4:H5_7:H6_7` | 1138 → 1216 | −203／−153 | must-diverge | 豁免 | 拒绝 |
| DARM 父 `trial-33`，`B4:H5_7:H6_7` | 1138 → 1136 | −123／−107 | must-diverge | 豁免 | 接受 |

固定发布父 `trial-33` 与草案 + Anchor 搜索中的父及输出完全相同，表中合并一行。四处条件均为 `tid.x < 31 && (tid.x & 1) == 0`，只依赖 workitem ID 和常量。gfx906 的唯一一个部分占用 wave 含 32 个活动 lane，16 个走 true、16 个走 false，分类器回执为混合 1／总数 1。草案生成的 raw 相对同父发布分别减少 3／16／19 条条件跳转／无条件跳转／PHI（两条历史和 DARM 父 `trial-33`），Anchor 父则减少 1／14／16。完整的实际父哈希、分类 JSON 和两套报价见 `gate.json`。对没有确切形状、也没有 side gain 的候选仍会拒绝；本表没有依赖缺失项放行。

## 其他 case 的静态副作用

| Case | 确切形状 | 发布 + DARM B2B 提交／TTI | 草案 + DARM B2B 提交／TTI | 发布默认 Anchor 提交／TTI |
| --- | --- | ---: | ---: | ---: |
| NQU64 | 64×1×1 | 2／274 | 2／274 | 2／274 |
| LUD8 | 16×1×1 | 2／681 | 2／681 | 2／637 |

同 case 的两份 DARM B2B 最终 IR 逐字节一致。NQU64 也与默认 Anchor 字节一致。LUD8 显式 DARM 的最终 TTI 比默认 Anchor 高 44，四条命令分别传参，DARM 仅用于该次调用。这里的 TTI 比较不代表 GPU 性能结论。

## PCM32 GPU 对比

原第 7 步 runner 启动后超过 5 分钟未产出第一个 A/A 窗口。线程栈停在 `hipMemcpy` 的 HSA ioctl，日志没有输出不匹配。保留日志并结束该进程。重跑使用相同的设备、冻结输入与 reference、launch、预热和轮换顺序。把不可计时的复制路径改为显存内从冻结输入恢复，使用 4 MiB pinned-host buffer 分块回读并校验全部元素。原有 kernel event 的开始、结束位置保持一致。重跑从 A/A 重新开始。

冻结输入与参考输出均为 1 GiB，按发布 manifest 验证 SHA-256。使用 gfx906、预热累计至少 200 ms、12 个轮换窗口、每角色每窗口取完整校验样本的耗时中位数。A/A 用发布默认对象的两份副本。中位时比须在 1±1%，跨度不超过 3%。正式测量沿用通过 A/A 的窗口大小，同轮比值用固定种子 20261121 做 10,000 次 bootstrap，给出 95% 区间。复测命令为 `python3 step7d-gpu-pinned.py "$PWD"`。

A/A 每角色每窗口 31 次，中位时比 **0.99998**，跨度 **0.0075%**。

正式批次三种不同对象各完成 12×31 次完整校验。草案 + Anchor 与发布默认的 HSACO 完全相同，在同批使用同一角色。

| 同批角色 | 中位耗时（ms） | 相对发布默认 | 相对 Auto DARM |
| --- | ---: | ---: | ---: |
| 发布／草案 + Anchor（别名） | 707.056 | 1.00000 [1.00000, 1.00000] | 1.07334 [1.07332, 1.07335] |
| 原版 Auto DARM | 658.751 | 0.93168 [0.93166, 0.93169] | 1.00000 [1.00000, 1.00000] |
| 草案 + DARM B2B | 658.741 | 0.93167 [0.93165, 0.93168] | 0.99999 [0.99997, 1.00001] |

草案 + DARM B2B 的同轮耗时比发布默认低 **6.83%**。相对原版 Auto DARM 的 95% 区间包含 1。第 7 步历史对象的 6.83% 是另一份 HSACO 的配对结果。

发布 + DARM B2B 匹配此前实测对象。同批旧对照 A 的 HSACO 为 `a0a8df33…`，即当前发布默认；旧 D 为 `01658668…`。复算旧分块回读 12 个完整窗口，D/A 为 **0.99999 [0.99996, 1.00006]**，沿用该已测别名。该批没有原版 Auto DARM 同轮读数。 [旧测量记录](b2b-darm-vs-dp1-20261119.md#ms32-和-pcm32)

## 回执

| 文件或工具 | SHA-256 |
| --- | --- |
| `matrix.json` | `cfd650ce8bd4cf42ffdb3d443c6693853b6e545a22e125a29a4fc59b14bb7028` |
| `gate.json` | `e3b9eef0690215db4bf28134bf727c6cba7060868da70d80a9c1112fcbfa1a4a` |
| `trajectories.json` | `2cacaf9e70372f6894a8b73fa5ec283405f8f36d121dc0bf787f53295eb54056` |
| `catalogs.json` | `ab1538e3b252f2a212fbcfaf8d680fb013196d4e4180ceb11d3cc5d33dc18157` |
| `object-text.json` | `25e56ceba49fd79d7a9ca8b66e1ca6523f4deb91385db9cab887339b6185bca9` |
| `pcm-aa-31-stall.stack` | `5b8e83fc6573d16870482f06bdb37ac93bcc10f96ef7541b85595839f2bace83` |
| `pcm-runner-pinned` | `e7ff093abc1b687127177bd8c249245cc2765675d0301be3419a445fa32034fa` |
| 旧 `PCM32-pinned-window/timing.csv` | `d534565dbdf16d7e399c4a7d2e342a907cdcc3bf650b9c2b8db40d983f1f6f25` |
| `gpu-pinned/pcm-gpu-results.json` | `d3dad1db0a1029ae42147e1d6255e3a8b023fcd26a01e79daa756043ee8e54ac` |
| `gpu-pinned/pcm-aa-31.csv` | `cdb23b3430bd30d05ed029f2918a67902581245cf4c205f1985e73ce89c6965d` |
| `gpu-pinned/pcm-formal.csv` | `fd6731548dd1705fcab61d53f7a89920f8c37bd33812f3893d1507b7fc09b6e7` |

逐轮回执及完整产物留在 EPYC。冻结清单及发布分支保持原状。
