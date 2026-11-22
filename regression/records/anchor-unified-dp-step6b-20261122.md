# Anchor B2B 第 6b 步：统一 gap 定价与发射

## 范围

从 `ceb06e89c997004152c8f3ac0b06f9e19208a50c`（6a）开始。旧草稿 stash `d78e90ff` 保留。复用了草稿中整段守护发射的思路。CLI 新增 `--anchor-gap auto` 和 `--anchor-auto-assume diverge`，目前只支持 diverge。默认继续使用 fork；本步没有接入逐 wave 分类、接受 gate 或保守定价。

每个 strict/relaxed 档只进行一次线性 DP 遍历，共享锚点、反向 cutoff、报价和网格。网格内保留无守护与允许守护两个独立 beam，分别裁剪，避免原本只准配对的内存路径被可跳过内存的新状态淘汰。原先 G0 的 strict/relaxed 顺序及 linear → guarded 方案顺序保留。旧 fork DP 仍独立运行，并先进入候选列表。dedup 的状态和出口报价沿用原定义。

方案显式记录每个非空 gap 的放置方式。可推测计算无额外代价，简单单侧访存及依赖仍落在原配对界线之间。守护按每侧 2 分及跨块值 PHI 报价。发射器按计划提前或只守护必要指令；同时支持整段守护，两边都有内容时在同一个条件分支发射 if-else。当前 diverge 规划不生成整段守护。旧 segmented fork 发射保持原路径。

## 环境、命令和测试

- EPYC 目录为 `/data/home/chh/simplify-v2/build/anchor-dp-step6b.xhGhHM`。构建脚本为 `compile-anchor-step3.sh source`、`link-anchor-step2.sh source`，固定工具链见 `/data/home/chh/v2-runtime/reproduce.json`。首次构建使用了 LLVM12 没有的 `llvm::seq`，换为区间循环后重建成功。最终源码重建的 Greedy 与 search 哈希和主矩阵所用二进制相同。
- `anchor-step6b-run.py` 对发布 manifest 的固定 IR（另加 LUD8 的 shared.ll）逐项复核 SHA-256 并执行三档完整 Greedy。核对档 D 用 `c7dded07`。Auto0 对 6a 的 G0，Auto1 对 6a 的 G1，这两份对照均已在 6a 逐字节验证与第 4 步一致。
- `anchor-step6b-compare.py` 检查落盘的候选 IR、每个 Anchor 布局评分、完整获选链及最终 IR。非候选的中间快照只允许已知的 `; preds =` 注释重排。DARM 变体只有固定父 IR SHA-256 和本记录列出的候选号、变体 SHA-256、对应评分均相符时才允许。
- `anchor-step6b-build-audit.sh`、`anchor-step6b-build-audit-c7.sh` 从各原版本构建临时审计入口。唯一插桩是读取全部布局的 raw/cleanup IR 序列化摘要，包括重复后没有计分的布局。用 `anchor-step6b-audit.py` 在每个历史 Anchor 请求的同一父 IR 上重放，对比布局顺序和各摘要。临时插桩不在提交中。
- `bash test-anchor-step1.sh final final-anchor-dp-step6b-r2` 使用已知失败口径。16 项通过，`condition`、`pair-trial`、`regions`、`similarity` 共 4 项跳过。新增规划用例逐项对比 strict/relaxed 的两组 beam、guard 记录与旧方案。新增发射用例调用实际线性发射器，核对双侧整段 if-else、单侧整段、提前与守护在同一计划混合、访存次序、guard PHI 的 poison 边以及 join 的结果。生成 IR 经 `opt -O2 -verify-each`，CPU 上两种分支各 65 组输入比较完整返回值和写后内存。
- 本步无 GPU 新测量。逐字节相同的产物沿用第 4 步及第 5 步的结果。

```sh
DECISION_GREEDY_JOBS=8 "$greedy" "$frozen_ir" "$function" "$tool_root" "$output" \
  --anchor-gap auto --anchor-guarded-gap 1 --anchor-auto-assume diverge
# Auto1 同上，另加 --anchor-select-dedup 1。
"$opt" -verify -disable-output "$output/final.ll"
```

## HLLD 发布基线补证据与白名单

用 `c7dded07` 的原发布二进制对 6a 的两个固定父 IR 各重放 20 次。同份输入路径和 cleanup 命令，独立进程。主矩阵另外发现 `B9:B23:B12` 的相同类型波动，以及 auto 对照用不同父状态或序列化路径生成的变体。也分别用原发布二进制在对应固定父 IR 上各重放 20 次。对新重放去掉发布二进制还不支持的 Anchor 实验参数，保留显式 R2B 请求及相同的父 IR 和路径拼法。首次补跑因这些参数被旧二进制拒绝；去掉后重跑。

下表缩写 `11`、`12` 和 `23` 分别对应 `B9:B22:B12`、`B9:B23:B12`、`B9:B21:B12`。函数均为 HLLD 的 `_ZN3mhd26Calculate_HLLD_Fluxes_CUDAEPKdS1_S1_Pdidii`，merge path 为 `darm-R2B`。每一行都限定父 IR 及两种 SHA-256，任何其他候选或变体均不豁免。

| 对照 / 候选 | 父 IR SHA-256 | 变体 SHA-256 | 重放次数 | TTI |
| --- | --- | --- | ---: | ---: |
| D / `trial-11` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `5a7d21cef13e427ed492cf02ac4c0fc9d7662ce1b76da627460a7171eb201d3a` | 17 | 1839 |
| D / `trial-11` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `3d088bc542be3afa7cea5ea719ab027ec04353596c45db55c45c75d64e2de864` | 3 | 1838 |
| D / `trial-12` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `dd1b16cbc43fd52e21b74a270680d5885dc1465df59648db24254e19123ff2b4` | 11 | 1844 |
| D / `trial-12` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `0e5a464ec534233a07094584cbd49a3b325d4a404ba7339958d57f886fe462ef` | 9 | 1843 |
| D / `trial-23` | `162a59fd16e55a76dfb488b5361549df3adfd3d3712657def52b6c3cd06b504f` | `4187ad0d4f4310521ae6fc5d893ff3bca1ba344cd9ebb38e74897313b509cf52` | 17 | 1805 |
| D / `trial-23` | `162a59fd16e55a76dfb488b5361549df3adfd3d3712657def52b6c3cd06b504f` | `0e732f1488ffebc94e1cab72ce0daf9d19c9da29756f28e2837e1dccff9fee3e` | 3 | 1804 |
| auto0 / `trial-23` | `82cb18624e1db2397673a8da64d61eb9f7b4e1a18179f9184e6efff82ed6ff6b` | `9802709d86720dc471f36fe26d3457bbf594551fec105eb2f9c9dfda93a02e8d` | 13 | 1803 |
| auto0 / `trial-23` | `82cb18624e1db2397673a8da64d61eb9f7b4e1a18179f9184e6efff82ed6ff6b` | `3e13d08d55440a3fcbe68c16c813cdc64a5b9b9bd0d3a3939811373a758966cc` | 7 | 1804 |
| auto1 / `trial-11` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `4bdbb5a5342e077c232c6461bad17d724d2f5d89ee481c53d29ea42d194ff3fb` | 15 | 1839 |
| auto1 / `trial-11` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `9236d6f13b9f6276800cf5f0fff6340fe0af3ee77f1bddc19010efb6c9aa7837` | 5 | 1838 |
| auto1 / `trial-12` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `abc8004745742c59b5ebd1714ff5120e68d2447db9c81dc98b50e9e82aae483d` | 15 | 1844 |
| auto1 / `trial-12` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `2e77f0a09bc4d8dce8920f5cc06b1f1cc14dc8b1738ad91d36065d2c2e87a47b` | 5 | 1843 |

这些候选都未获选。分支谓词与一条 `and i1` 发生变化。根因未定位，怀疑以指针为键的容器遍历或按地址排序。本步没有修改区域融合路径，已登记到 [KNOWN_ISSUES](../../docs/KNOWN_ISSUES.md#darm-r2b-试融的非确定性)。

## 等价矩阵

以下各格为提交数 / 最终 throughput TTI。每档都通过 LLVM verifier、完整提交链对照及最终 IR 逐字节核对。右栏为对三档同父重放的 Anchor 布局总数，包含去重前的布局。

| Case | D 对 c7 | Auto0 对 G0 | Auto1 对 G1 | 同父布局数 |
| --- | ---: | ---: | ---: | ---: |
| CED | 5 / 280 | 3 / 281 | 3 / 281 | 60 |
| HiPIMS-George | 5 / 5572 | 4 / 5572 | 4 / 5572 | 105 |
| HLLD | 5 / 1696 | 4 / 1700 | 4 / 1700 | 81 |
| Landau | 20 / 1708 | 19 / 1066 | 19 / 1061 | 2589 |
| LUD8 | 1 / 735 | 2 / 637 | 3 / 638 | 71 |
| MapAiry | 31 / 4065 | 30 / 3660 | 30 / 3661 | 1746 |
| MS32 | 2 / 198 | 2 / 198 | 2 / 198 | 46 |
| NQU64 | 2 / 274 | 3 / 270 | 3 / 270 | 31 |
| PCM32 | 17 / 1138 | 17 / 1138 | 17 / 1138 | 742 |
| SasPoint5 | 8 / 491 | 8 / 458 | 8 / 458 | 472 |
| SRAD-stage2 | 2 / 210 | 2 / 210 | 2 / 210 | 54 |
| SRAD16 | 4 / 452 | 4 / 437 | 4 / 437 | 175 |
| SRAD32 | 4 / 452 | 4 / 437 | 4 / 437 | 175 |
| SW2D | 1 / 1925 | 1 / 1925 | 1 / 1925 | 44 |
| tigre | 6 / 946 | 5 / 944 | 5 / 944 | 86 |
| TPACF | 23 / 325 | 23 / 325 | 23 / 325 | 4267 |
| vllm | 225 / 2619 | 225 / 2619 | 225 / 2619 | 8352 |

- **51/51 最终 IR 逐字节一致，完整提交链及最终 TTI 一致。**
- 对比了 21589 份落盘 IR 和 6253 个 Anchor B2B 请求的候选输出。15567 条逐布局评分完全一致。非候选快照 2033 处只有已知的 preds 注释顺序差异。
- 固定同一父 IR 重放全部 19096 个 Anchor 布局，raw 与 cleanup 的文本序列化 SHA-1 逐布局一致，包含去重前未参与计分的方案。
- HLLD 在实际矩阵中使用白名单 6 次。白名单之外的 IR 或评分差异为 0。

## 二进制 SHA-256

| 工件 | SHA-256 |
| --- | --- |
| 6b `decision-greedy` | `4210324d6956f4c6fd4aa890b3b2eeb3d3bc049050c8841f0960e368c5db437a` |
| 6b `fusion-search-llvm24` | `d71c98a7a768a22654a1c3a0199eb9edb0633311dbda8a3f677ece65aee1c0e7` |
| 固定 TTI worker `llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| 6a G0/G1 的 `decision-greedy` | `2ff4bcaf53154de0e544be55a14ea24875d35b26f0c5755bf54a65dfecdebf8b` |
| 6a G0/G1 的 `fusion-search-llvm24` | `e558a7ed21538d28ea6028ad394fd676b59b091b0c1bfd13e68856a747f19b44` |
| 发布 `c7dded07` 的 `decision-greedy` | `fa1795b80acec0a7afd72c435853455524a04aaef7fb992f7554368d9e61074d` |
| 发布 `c7dded07` 的 `fusion-search-llvm24` | `892bcad9b23338819f446dde95bf9fda0e3bc9ce90af4efe96e838fb8dfdf4a2` |
| `audit/c7/search` | `bd437a3ed893dd0a321121f0d2cc128903fc4f49ba2a7c480b48c9da496200e1` |
| `audit/step6a/search` | `c35a8f6f35697dbb97dbd1ff1d3b74a7e24ec91d7317f1d40f911a7b2e9fa738` |
| `audit/current/search` | `598519c35a4f2104c85c97643839b96b0e992e872dbd8ba5e996b50285111add` |
| `comparison.json` | `c018e5335d71e86d8d232a0d9b43bf9b5ab00531dfe908f78a4b3746a444da9e` |
| `audit-results.json` | `81f74e74adbcd1204b7a665e5ec1f187588cf7b3b8a2e70f761492276ecfdf45` |
| `final/build/simplify-fingerprint/final-anchor-dp-step6b-r2/results.json` | `54700b3396da17fe3ee8e3820f32543ee1bf54ae2ec10aa7ca0629e949151a04` |
