# 线程号条件的无形状判定

分支 `feat/thread-pattern-optimism` 从发布线 `b66ae7e2161781792ab38f0c1710685a811960a2` 开出。A 使用发布线二进制和冻结形状。B 使用新二进制并省略形状参数，仍允许 IR 中确切的 `reqd_work_group_size`。C 使用新二进制和 A 的冻结形状。发布 manifest 和 case 的形状数值及冻结哈希保持原值。

## 实现

`anchor_wave_diagnostic.h` 沿条件操作数追溯来源。workitem ID 与常量、kernel 参数和已知 workgroup 一致的值组成的纯计算标为 `thread-pattern`。只有一致值的条件标为 `workgroup-uniform`。load、PHI、非纯调用和无法证明来源的值进入 `data`。分类支持纯的通用 LLVM intrinsic。目标专用 intrinsic 若可能隐式读取 lane 状态，需有明确的来源判定才会放行。

B2B 逐布局、R2R 逐次推测共用 gate。无确切形状的线程号条件仅使用原有 throughput TTI 接受条件，并在实际评估此类布局时提示可选形状参数。提供确切形状时按原逐 wave 分类。若仍无法静态求值（例如 `tid.x < n` 中参数值未知），继续使用一致代价 gate。workgroup 一致条件禁止线性、守护及 R2R 推测，保留 fork 和普通 R2R。数据条件的双侧一致代价和缺报价政策沿用原规则。

## 命令与工具

在 EPYC 上核对 manifest 中每份冻结输入的 SHA-256。各次运行使用同一个相对输出目录名 `active`。

```sh
DECISION_GREEDY_JOBS=8 "$TOOL_ROOT/build/decision-fuse/decision-greedy" \
  "$FROZEN_INPUT" "$FUNCTION" "$TOOL_ROOT" active --ir-snapshots full \
  --anchor-wave-shape "$SHAPE"
```

B 从命令末尾移除 `--anchor-wave-shape "$SHAPE"`。A 的设备对象从上一发布复验中取出，同一 IR 的 B/C 按字节复用对象。新 IR 按冻结的 LLVM12 和后端选项重建，SRAD32 保留 1024 线程的诊断构建口径。每项 GPU 比较使用冻结输入、完整输出校验及同批配对 12 轮，报告配对中位数和 bootstrap 95% 区间。原协议 A/A 失败及重试后依次尝试 31 和 61 次采样的窗口中位数协议。

| 配置 | `decision-greedy` SHA-256 | `fusion-search-llvm24` SHA-256 |
| --- | --- | --- |
| A | `cfdaec7c2f4597192511333be3573842ecc37ad15a7057dfdecf48767f1410e6` | `8fb695c9522497fec649eb033c7c1b6d09471c25d05af2184ccb300be0089f71` |
| B/C | `3d546763e879c6ddd0422badadaa54580a2e384d5ba421e42c818243abc51204` | `6cfec51c0077a0d18c8bec18f5e7b7c84db376bf58f8732b4ed694407ab35d5f` |

共用的 LLVM 24 报价器 SHA-256 为 `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a`。矩阵、报价回执、命令、计时窗口及完整输出校验保存在 EPYC 的 `/data/home/chh/simplify-v2/build/thread-pattern.vLL3Qo`。

## 关键路径

- LUD8 的无形状写回在同一父 IR 上使用乐观 TTI 并选中守护布局。形状 `16×1×1` 下为 must-diverge。直接重放的 cleanup 后 IR 逐字节相同。A/B/C 均为 2 次提交、TTI 628。
- PCM32 的第 18 次提交 `trial-33` 在 B 中判为 `thread-pattern`，报价从 1138 降到 1136，双侧一致收益为 −123 / −107。A/C 借助 `32×1×1` 将同一条件判为 must-diverge。三个配置的 18 次提交、最终 IR 和设备对象一致。
- NQU64 守护候选在固定父 IR 上判为 `data`，在有无形状时均因负的一致收益被拒。三个配置均为 2 次提交、TTI 274。
- CED 第 1 次提交 `trial-1`（`B5:R3:R5`）对 `tid.y == 0` 使用 R2R 推测，报价 349 → 307。A 的 `16×16×1` 下只有 1/4 的 wave 分流，双侧一致收益 +4 / −3，选择 TTI 309 的普通 R2R。B 在无形状时提交推测版。最终仍为 3 次提交、TTI 281。IR 改变，HSACO 逐字节相同。
- SRAD16 和 SRAD32 的第 4 次提交均为 `trial-12`（`B22:B23:B24`），条件为 `tid.y == 0`。B 选线性布局 `b2b-anchor-5`，TTI 445 → 436。A/C 的混合 wave 数分别为 1/4 和 1/16，双侧一致收益 −1 / −14。线性布局被拒，保留报价 445 的 fork 方案并停止在 3 次提交。

## 静态结果

- B 的 IR 变化：SRAD16、SRAD32、CED。
- B 的提交链变化：SRAD16、SRAD32、CED。
- C 的 IR 变化：0 个 case。
- C 的提交链变化：0 个 case。

选中类型的顺序为 fork／线性／守护／R2R 推测／其他。其他包括普通结构提交与仅归一化。

| Case | 配置 | 提交数 | TTI | 选中类型 | 最终 IR SHA-256 | 设备对象 SHA-256 |
| --- | --- | ---: | ---: | --- | --- | --- |
| vllm | A | 225 | 2619 | 224/0/0/0/1 | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` | `9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6` |
| vllm | B | 225 | 2619 | 224/0/0/0/1 | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` | `9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6` |
| vllm | C | 225 | 2619 | 224/0/0/0/1 | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` | `9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6` |
| MapAiry | A | 30 | 3997 | 14/3/0/0/13 | `109dae2f8e462357add07adbc0dcd17dae365372fdca464a9abe9469f40c90d1` | `030b9488c8bb5b7cf98479f218adaa85aeaec30e404f7efd4fc2ba4ad0167afc` |
| MapAiry | B | 30 | 3997 | 14/3/0/0/13 | `109dae2f8e462357add07adbc0dcd17dae365372fdca464a9abe9469f40c90d1` | `030b9488c8bb5b7cf98479f218adaa85aeaec30e404f7efd4fc2ba4ad0167afc` |
| MapAiry | C | 30 | 3997 | 14/3/0/0/13 | `109dae2f8e462357add07adbc0dcd17dae365372fdca464a9abe9469f40c90d1` | `030b9488c8bb5b7cf98479f218adaa85aeaec30e404f7efd4fc2ba4ad0167afc` |
| tigre | A | 5 | 942 | 1/1/0/0/3 | `5605316b9f7b3403cfdd81fcb96017f63592c94dad1c3ad888b3972c9adbc809` | `ffa327ddc018b3b910d11d56c9d9cca022509c39d5e099363465a44a574bc721` |
| tigre | B | 5 | 942 | 1/1/0/0/3 | `5605316b9f7b3403cfdd81fcb96017f63592c94dad1c3ad888b3972c9adbc809` | `ffa327ddc018b3b910d11d56c9d9cca022509c39d5e099363465a44a574bc721` |
| tigre | C | 5 | 942 | 1/1/0/0/3 | `5605316b9f7b3403cfdd81fcb96017f63592c94dad1c3ad888b3972c9adbc809` | `ffa327ddc018b3b910d11d56c9d9cca022509c39d5e099363465a44a574bc721` |
| HLLD | A | 5 | 1696 | 1/0/0/0/4 | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` | `3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3` |
| HLLD | B | 5 | 1696 | 1/0/0/0/4 | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` | `3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3` |
| HLLD | C | 5 | 1696 | 1/0/0/0/4 | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` | `3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3` |
| NQU64 | A | 2 | 274 | 0/0/0/0/2 | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` | `83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b` |
| NQU64 | B | 2 | 274 | 0/0/0/0/2 | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` | `83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b` |
| NQU64 | C | 2 | 274 | 0/0/0/0/2 | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` | `83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b` |
| MS32 | A | 2 | 198 | 1/0/0/0/1 | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` | `1be889a67dbd43dd8d63e0b6d5cee7fe26584fa22bb23da67878cd30b6722054` |
| MS32 | B | 2 | 198 | 1/0/0/0/1 | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` | `1be889a67dbd43dd8d63e0b6d5cee7fe26584fa22bb23da67878cd30b6722054` |
| MS32 | C | 2 | 198 | 1/0/0/0/1 | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` | `1be889a67dbd43dd8d63e0b6d5cee7fe26584fa22bb23da67878cd30b6722054` |
| PCM32 | A | 18 | 1136 | 17/0/0/1/0 | `debd9769998968174b631e18fd675916172800fd3eeeb179f026e725cf3b5fb0` | `5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816` |
| PCM32 | B | 18 | 1136 | 17/0/0/1/0 | `debd9769998968174b631e18fd675916172800fd3eeeb179f026e725cf3b5fb0` | `5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816` |
| PCM32 | C | 18 | 1136 | 17/0/0/1/0 | `debd9769998968174b631e18fd675916172800fd3eeeb179f026e725cf3b5fb0` | `5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816` |
| SRAD16 | A | 3 | 445 | 2/1/0/0/0 | `29c33f08d3663cfa068b563f88939300fe16ae24ca5f748bef8f6eec11b59b71` | `ac992d49e04656c3b8789a6825ca51c0895b2c656bf7387e61785b5d8e3703d9` |
| SRAD16 | B | 4 | 436 | 2/2/0/0/0 | `682d788ebaa36b26909d11560478599bfb22e3f9f59ae7181be2cbf84bd4d0f5` | `89191ed8c58d26ef8af05dee8c5ca06a1a17c026204fec6ffdecc9e0d948d2db` |
| SRAD16 | C | 3 | 445 | 2/1/0/0/0 | `29c33f08d3663cfa068b563f88939300fe16ae24ca5f748bef8f6eec11b59b71` | `ac992d49e04656c3b8789a6825ca51c0895b2c656bf7387e61785b5d8e3703d9` |
| SRAD32 | A | 3 | 445 | 2/1/0/0/0 | `675b5641e45673d18e51066e4cfa8a5ec70c5c0d4afbc2409dd5766f45eae5a2` | `fe59dbc7dc4d2955b0f3953a688ee8fcf58e6d28a8404cde068cfc610404948a` |
| SRAD32 | B | 4 | 436 | 2/2/0/0/0 | `1b8b91a062304dfbf3bccc8974feb7655387f9774275c1522c8270eb9460c008` | `be6cdbe3591098a69885adfabfa421f6a79c94cae37cece59f0f89648a74271a` |
| SRAD32 | C | 3 | 445 | 2/1/0/0/0 | `675b5641e45673d18e51066e4cfa8a5ec70c5c0d4afbc2409dd5766f45eae5a2` | `fe59dbc7dc4d2955b0f3953a688ee8fcf58e6d28a8404cde068cfc610404948a` |
| Landau | A | 22 | 1635 | 13/4/0/0/5 | `31aea7ae5a00106b1e4684c7f87cf6fa895cff29010f450c740f92396eb1943f` | `a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f` |
| Landau | B | 22 | 1635 | 13/4/0/0/5 | `31aea7ae5a00106b1e4684c7f87cf6fa895cff29010f450c740f92396eb1943f` | `a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f` |
| Landau | C | 22 | 1635 | 13/4/0/0/5 | `31aea7ae5a00106b1e4684c7f87cf6fa895cff29010f450c740f92396eb1943f` | `a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f` |
| SW2D | A | 1 | 1925 | 0/0/0/0/1 | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` | `cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518` |
| SW2D | B | 1 | 1925 | 0/0/0/0/1 | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` | `cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518` |
| SW2D | C | 1 | 1925 | 0/0/0/0/1 | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` | `cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518` |
| CED | A | 3 | 281 | 0/2/0/0/1 | `f068294bdff0eea4be42fe2036db147d3efd5cbc31ab44d1b006c2fc9fd4fb11` | `c9f5da8a8caab4cc492af650f8663fae867cb65356aaa16a8c49ce48223dae38` |
| CED | B | 3 | 281 | 0/2/0/1/0 | `1798b84d27abb2b8d6f74d97249337ea562c97cf66e644ace637af319d7af3d4` | `c9f5da8a8caab4cc492af650f8663fae867cb65356aaa16a8c49ce48223dae38` |
| CED | C | 3 | 281 | 0/2/0/0/1 | `f068294bdff0eea4be42fe2036db147d3efd5cbc31ab44d1b006c2fc9fd4fb11` | `c9f5da8a8caab4cc492af650f8663fae867cb65356aaa16a8c49ce48223dae38` |
| TPACF | A | 23 | 325 | 1/0/0/0/22 | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` | `3853cc72321f0c31102fbfe7b9b80a3258275103448e1437e0db0837dce6d65f` |
| TPACF | B | 23 | 325 | 1/0/0/0/22 | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` | `3853cc72321f0c31102fbfe7b9b80a3258275103448e1437e0db0837dce6d65f` |
| TPACF | C | 23 | 325 | 1/0/0/0/22 | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` | `3853cc72321f0c31102fbfe7b9b80a3258275103448e1437e0db0837dce6d65f` |
| SRAD-stage2 | A | 2 | 209 | 1/1/0/0/0 | `b1343cc5c72cc19d5a352cfa8080208fb503de8160190f1a0f638bc4cff42ad8` | `37ed260bde0e42fc816853f9ea712685dbda735b563bbddd3a5026044c7befc5` |
| SRAD-stage2 | B | 2 | 209 | 1/1/0/0/0 | `b1343cc5c72cc19d5a352cfa8080208fb503de8160190f1a0f638bc4cff42ad8` | `37ed260bde0e42fc816853f9ea712685dbda735b563bbddd3a5026044c7befc5` |
| SRAD-stage2 | C | 2 | 209 | 1/1/0/0/0 | `b1343cc5c72cc19d5a352cfa8080208fb503de8160190f1a0f638bc4cff42ad8` | `37ed260bde0e42fc816853f9ea712685dbda735b563bbddd3a5026044c7befc5` |
| SasPoint5 | A | 7 | 491 | 7/0/0/0/0 | `eefddfe2b88b52b4e348b8ac7ad6a324f0c7c881521d3a4f3c7696de9d616385` | `9b8f297905aca8ac726d64707a8432c07a90565b1828401251dbef473f230b2d` |
| SasPoint5 | B | 7 | 491 | 7/0/0/0/0 | `eefddfe2b88b52b4e348b8ac7ad6a324f0c7c881521d3a4f3c7696de9d616385` | `9b8f297905aca8ac726d64707a8432c07a90565b1828401251dbef473f230b2d` |
| SasPoint5 | C | 7 | 491 | 7/0/0/0/0 | `eefddfe2b88b52b4e348b8ac7ad6a324f0c7c881521d3a4f3c7696de9d616385` | `9b8f297905aca8ac726d64707a8432c07a90565b1828401251dbef473f230b2d` |
| HiPIMS-George | A | 5 | 5572 | 4/0/0/0/1 | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` | `5775bc0c9c040ba7b55d84bd29d0719342a2f38043dff855fea723a9c5510b3b` |
| HiPIMS-George | B | 5 | 5572 | 4/0/0/0/1 | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` | `5775bc0c9c040ba7b55d84bd29d0719342a2f38043dff855fea723a9c5510b3b` |
| HiPIMS-George | C | 5 | 5572 | 4/0/0/0/1 | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` | `5775bc0c9c040ba7b55d84bd29d0719342a2f38043dff855fea723a9c5510b3b` |
| LUD8 | A | 2 | 628 | 0/1/1/0/0 | `387a564d46e1226112d51f2d9e7640dc1016dd72b2e41533a2a488aa330af915` | `15266ece5e8344423077a145cbf41eb24635ee6591884241f1e26e339d77edd8` |
| LUD8 | B | 2 | 628 | 0/1/1/0/0 | `387a564d46e1226112d51f2d9e7640dc1016dd72b2e41533a2a488aa330af915` | `15266ece5e8344423077a145cbf41eb24635ee6591884241f1e26e339d77edd8` |
| LUD8 | C | 2 | 628 | 0/1/1/0/0 | `387a564d46e1226112d51f2d9e7640dc1016dd72b2e41533a2a488aa330af915` | `15266ece5e8344423077a145cbf41eb24635ee6591884241f1e26e339d77edd8` |

## 候选判定

以下按单个布局或一次 R2R 推测计数。可接受指通过 gate 及 TTI 条件，实际获选数见上一表。gate 拒绝含负收益及缺报价。逐 wave 禁止是精确形状下的 must-uniform，工作组禁止来自 workgroup-uniform 规则。

| 配置 | 来源 | 布局 | 可接受 | gate 拒绝 | 逐 wave 禁止 | 工作组禁止 | TTI 未通过 | 无效 |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | data | guarded-linear | 0 | 129 | 0 | 0 | 1 | 0 |
| A | data | linear | 1369 | 1108 | 0 | 0 | 342 | 0 |
| A | thread-pattern | guarded-linear | 6 | 0 | 0 | 0 | 11 | 0 |
| A | thread-pattern | linear | 52 | 52 | 0 | 0 | 0 | 0 |
| A | thread-pattern | r2r-speculation | 1 | 1 | 0 | 0 | 0 | 0 |
| B | data | guarded-linear | 0 | 129 | 0 | 0 | 1 | 0 |
| B | data | linear | 1369 | 1108 | 0 | 0 | 342 | 0 |
| B | thread-pattern | guarded-linear | 6 | 0 | 0 | 0 | 11 | 0 |
| B | thread-pattern | linear | 104 | 0 | 0 | 0 | 0 | 0 |
| B | thread-pattern | r2r-speculation | 2 | 0 | 0 | 0 | 0 | 0 |
| C | data | guarded-linear | 0 | 129 | 0 | 0 | 1 | 0 |
| C | data | linear | 1369 | 1108 | 0 | 0 | 342 | 0 |
| C | thread-pattern | guarded-linear | 6 | 0 | 0 | 0 | 11 | 0 |
| C | thread-pattern | linear | 52 | 52 | 0 | 0 | 0 | 0 |
| C | thread-pattern | r2r-speculation | 1 | 1 | 0 | 0 | 0 | 0 |

- B 的工作组禁止数为 0。
- C 的工作组禁止数为 0。

## GPU

| 输入 | B/A | B/Auto DARM | A（同 C）/Auto DARM |
| --- | ---: | ---: | ---: |
| SRAD16/256 | 1.0074 [1.0000, 1.0078] | 0.9847 [0.9735, 0.9855] | 0.9810 [0.9428, 0.9847] |
| SRAD32/256 | 无可靠计时 | 无可靠计时 | 无可靠计时 |

| 输入 | A/A 协议 | 中位比值 | 极差比 |
| --- | --- | ---: | ---: |
| SRAD16/256 | 原协议 | 0.9961 | 50.55% |
| SRAD16/256 | 原协议 | 1.0000 | 52.45% |
| SRAD16/256 | 31 | 1.0000 | 2.37% |
| SRAD32/256 | 原协议 | 1.0000 | 51.43% |
| SRAD32/256 | 原协议 | 0.9887 | 64.44% |
| SRAD32/256 | 31 | 1.0000 | 16.54% |
| SRAD32/256 | 61 | 1.0000 | 17.29% |

20 个输入的 B/C 对象与 A 相同，作为别名。SRAD16 使用每窗口 31 次的协议通过完整输出校验。SRAD32 的 A/A 在 61 次窗口重试后仍超限，未进行正式比较。

SRAD32 另用同一 runner 和冻结输入做 A、B、Auto DARM 各一次完整输出校验，三者通过。此次调用只用于正确性校验，未纳入时比。首次调用同时传了 `--mode validate` 和扩展测量角色参数，runner 在启动 GPU 前报参数不兼容，随后用对象列表方式完成校验。SRAD32 没有已验证的时比，无法据此排除超过 2% 的退化。

## 回归测试

回归测试 16 项通过，4 项按 `tests/KNOWN_FAILURES.md` 跳过。新增或更新的用例覆盖线程号、线程号和参数、纯通用 intrinsic、工作组一致参数与 ID、load、PHI、线程号与 load 混合、形状上界、B2B fork 回退和 R2R 的共享 gate。固定 NQU64 父 IR 的有形状和无形状两次重放均拒绝守护候选，LUD8 的无形状守护布局重放与有形状产物逐字节一致。

用新二进制运行 `regression/verify_anchor_release.py` 的 17 个 case 全部通过，LUD8 重放检查通过。唯一既有报警为 CED 281 > 280。C 与 A 的 358 步提交链及全部设备对象一致。

## 合并前 SRAD32 HIP Graph 补测

沿用第 7 步 CED 的 HIP Graph 窗口协议。SRAD32 每个样本用 110 个独立的常驻缓冲区副本，按冻结输入的 8×8 grid、32×32 block 捕获 110 次 kernel 启动。重置、回传及完整输出检查在 event 区间外。每个样本检查五个输出、只读输入和每个缓冲区两侧的 guard。A/A 和正式比较均按批次预热至少 200 ms、12 个交替窗口，取每角色每窗口的中位数。角色起点按窗口轮换，每组窗口交换顺序，平衡先后位置。A/A 门槛为中位比值偏离不超过 1%、比值极差不超过 3%。首次 31 次失败后只重试 61 次。

运行记录和 CSV 保存在 EPYC 的 `/data/home/chh/simplify-v2/build/thread-pattern.vLL3Qo/srad32-graph`。使用 ROCm 6.3.3 构建，runner SHA-256 为 `e9c82e90cc8322b8980feb4f883ad71114d67e945001fc2b28936779300646ec`，源码 SHA-256 为 `61def1cf34f1f133caaca4ade95ed2a3ca0ddf6a89b50723059013f891938170`。

```sh
/opt/rocm-6.3.3/bin/hipcc -O3 -std=c++17 --offload-arch=gfx906 step12-srad-graph.hip -o srad-graph
python3 step12-srad-graph.py /data/home/chh/simplify-v2/build/thread-pattern.vLL3Qo
```

| A/A 每窗口次数 | 中位时比 | 95% 区间 | 比值极差 |
| ---: | ---: | --- | ---: |
| 31 | 0.99957 | [0.99141, 1.00671] | 1.90% |

正式比较使用每角色每窗口 31 次，三个角色均通过完整输出校验。

| 比较 | 中位时比 | bootstrap 95% 区间 |
| --- | ---: | --- |
| B / A | 1.00312 | [1.00072, 1.00539] |
| B / Auto DARM | 0.95482 | [0.95169, 0.95721] |
| A / Auto DARM | 0.95090 | [0.94887, 0.95268] |
