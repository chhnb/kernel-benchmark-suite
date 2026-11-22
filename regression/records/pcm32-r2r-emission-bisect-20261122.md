# PCM32 R2R 发射二分诊断（第 7c 步）

## 结论

- 原始 TTI 的 **+104 全部在 `48fb41e` 进入默认路径**。`trial-139` 从 1446 到 1550，`trial-138` 从 1457 到 1561。前一提交 `474316d` 与 `3510dfb` 的原始 IR 逐字节一致。之后的 `d563956` 清理实验代码时未再涨，`3cf44a1` 与首个坏提交的两个原始报价一致。
- 这是 v1 统一默认配置时选择仅守护的区域发射，并退出原来的 cost gap planner 及候选重试。物理内存操作与路径保护仍有正确性要求，但两条固定 PCM32 试融多出的 104 点不必全部保留。草案只在非复制 R2R 中让可证明安全、独立且使用受同侧约束的纯标量整数 gap 原位执行。
- 草案恢复两份历史父 IR 上的全部 104 点，默认 cleanup 后两条均翻转为 +2。发布原生 `trial-33` 仍亏 78，PCM32 完整搜索仍为 17 次提交、最终 TTI 1138。此次固定父 IR 的改进没有改变当前 PCM32 的最终产物。

## 复现对象和二分

起点为 `study/pcm32-path-divergence` 的 `98925a282e658d1751946a91f621a4923a3913bc`。发布对照为 `3cf44a132f0b069577ad40ce2523bbb31aad46ff`。实验目录为 EPYC 上的 `/data/home/chh/simplify-v2/build/pcm32-emission-bisect.4Lhzs1`。两份父 IR 均使用第 7 步重建的原件：

| 试融 | 位置 | 历史父文件 | 父 IR SHA-256 |
| --- | --- | --- | --- |
| 139 | `B5:H6_8:H7_8` | `historical-run/trial-137/fused.ll` | `7e7d08a9d8067ea9d99d48492f573a5663796662a81fffeb449301e02ee94b41` |
| 138 | `B7:H8_10:H9_10` | `historical-run/trial-136/fused.ll` | `49ecad01ebc225ea7fe90ff0af667e48c5cc8407415bfae3e1da14fb972f31ee` |

只构建各版本的 `fusion-search-llvm24` 和链接所需对象。每次发射均检查候选 ID、R2R 类型、合法性，验证原始 IR，再用同一个固定 LLVM24 worker 报 throughput。worker 二进制 SHA-256 为 `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a`。早期版本按其 Greedy 实际默认的 `cost + gap-trials=4` 试融，v1 按当时发布默认试融。输出固定取 `structural/trial-0/after-raw.ll`。只读诊断脚本 [replay_pcm32_r2r_emission.py](../replay_pcm32_r2r_emission.py) 已用 `48fb41e` 独立重跑，原始哈希和报价均匹配。LLVM12 和 LLVM24 环境沿用 `/data/home/chh/v2-runtime/reproduce.json`，早期构建沿用第 7 步 OpenSSL 头文件和链接库环境。

```sh
python3 regression/replay_pcm32_r2r_emission.py 48fb41e \
  --historical-run "$HISTORICAL_RUN" --tti-worker "$FIXED_TTI_WORKER" \
  --out "$NEW_REPLAY_DIR"
```

在独立本地克隆运行 `git bisect start 3cf44a1 3510dfb` 与 `git bisect run …/step7c-bisect.sh`。两处都与旧端点相同判 good，两处都上涨判 bad。全部送测提交构建成功，最终无 skip。首轮手动探测 `48fb41e` 时按 CLI 支持项错误组合了 v1 cleanup 与历史 gap 模式；该版本正确拒绝参数。改用每版 driver 的实际默认重放后通过，并被正式二分纳入。完整记录为 `git-bisect.log`。

| 提交 | 139 raw / cleanup | 138 raw / cleanup | 说明 |
| --- | ---: | ---: | --- |
| `3510dfb` | 1446 / 1239 | 1457 / 1254 | 历史端点 |
| `ff1c2f8` | 1446 / 1239 | 1457 / 1254 | 二分 good |
| `474316d` | 1446 / 1239 | 1457 / 1254 | 首个 bad 的父提交 |
| **`48fb41e`** | **1550 / 1262** | **1561 / 1277** | **两处 raw 同时 +104** |
| `d563956` | 1550 / 1262 | 1561 / 1277 | 删除实验路径，无新增跳变 |
| `50a64fc`、`7cc5072`、`d0d911c`、`a5ae64b` | 1550 / 1262 | 1561 / 1277 | 二分 bad |
| `3cf44a1` | 1550 / 1262 | 1561 / 1277 | 发布端点 |

| 提交 | 139 raw SHA-256 | 138 raw SHA-256 |
| --- | --- | --- |
| `3510dfb`、`474316d` | `308650c357040b48084f35202d95120825e537282372d136eb4eca6e481634e6` | `6376428cb5aa73a3375bc17cd5d4920e7525cf914bca1ef95e9385961fa04ab5` |
| `48fb41e`、`d563956` | `7ce683319ac3544a2e042f667dd7ff5d07a43c2ffa2d41e0b07852672ef7bb4a` | `d5ea517a01c82c8d63cab5bd8879a669af9a0188b0182f77ab16023973688902` |
| `3cf44a1` | `ce7607f6fe10b79040ebf48791ace24eaf78bbcdda056f087425c08e09dc8664` | `6f89c1768c2c1ac7a46baf41036b9df75557bcc5f5fb856250217c7dcd8dd36a` |
| 草案 | `2be998e644a11a94c179122446670e25bf85db497b49ef62c2780f5b7342dbcf` | `482c8ac0ff89baa6912dfabeed226a3dac54fb84c20a4abbf2cac800bf7cb9ad` |

## 跳变的原因和正确性边界

`48fb41e`（Checkpoint reproducible Auto Greedy v1 defaults）固定了 Greedy 配置，driver 不再传 `--speculation cost --gap-trials 4`。pair CLI 原本默认 `SpeculationMode::None`，新增的 v1 cleanup 也显式要求守护发射、禁用 gap 搜索。旧规划器在这个提交仍可用历史 cleanup 调用。下面反事实保留同一 `48fb41e` 二进制、相同父 IR 和同一个 `darm-cfg-dce`，仅改变发射策略：

| 发射策略 | 139 raw / cleanup | 138 raw / cleanup |
| --- | ---: | ---: |
| 守护，无 gap 重试 | 1550 / 1297 | 1561 / 1312 |
| cost gap 规划，无重试 | 1460 / 1253 | 1471 / 1268 |
| cost gap 规划，旧的 4 次重试 | 1446 / 1239 | 1457 / 1254 |

两处各有 90 点来自基本 gap 规划，额外 14 点来自旧布局重试。固定旧 cleanup 后切到守护，raw 哈希与 `48fb41e` 的 v1 默认完全一致，所以 +104 在 cleanup 前已产生。旧模式带 4 次重试时 raw 哈希回到 `474316d`。后来的 flags/metadata 交集修复仍保留。

`llvm-diff` 比较 `474316d` 与 `48fb41e`，两处的操作码计数变化完全相同：

| 指令 | 139 旧 → 新 | 138 旧 → 新 | TTI 增量 |
| --- | ---: | ---: | ---: |
| 条件跳转 | 40 → 43 | 40 → 43 | 3 × 7 = 21 |
| 无条件跳转 | 31 → 47 | 33 → 49 | 16 × 4 = 64 |
| PHI | 65 → 84 | 66 → 85 | 19 × 1 = 19 |
| 合计 | | | **104** |

两处都仍有 115 个 load、89 个 store、118 个 select、205 个 GEP。以 `trial-139` 为例，`transition-139.diff` 指出旧 `%merged.bb` 中的 select、xor、zext、add 和 sub 被搬到两个互斥守护块，新汇合点再载入各边结果。以下为实际 diff 的摘录，中间省略数行：

```diff
  in block %merged.bb:
    <   %670 = select i1 %669, i32 %668, i32 %665
    <   %671 = xor i1 %669, true
    <   %672 = zext i1 %671 to i32
    <   %673 = add i32 %659, %672
    <   %676 = sub i32 255, %660
  in block %predication.tail / %predication.second:
    >   %676 = sub nuw nsw i32 255, %660
    >   br label %predication.join
```

新原始 IR 中 `%guard.value75` 为 `phi i32 [ undef, %predication.first ], [ %676, %predication.second ]`，随后由原选择条件引用。可以让这一类计算原位执行，前提是扩展执行后去除 poison-generating flags 和路径相关 metadata，且结果只在原侧或原条件下被观察。需要保留有副作用的运算和跨侧依赖的保护。缩紧这一局部规则仍能恢复两个固定对象的全部 104 点，因而无需恢复旧的全量 speculation 搜索。

## 默认路径修正草案

草案只在非复制 R2R 启用，无 CLI 开关。只省略整段独立、无副作用的纯标量整数 gap 的 guard。原有指令顺序保持不变，访存、调用、未证明安全的指令、跨侧使用或依赖守护结果的 gap 都继续守护。允许的跨 gap 用途仅包括同侧使用以及原分支选择器的对应操作数。复用 LLVM 的安全谓词，扩大执行范围前去除 poison flags 与未知非调试 metadata。单元用例检查 masked select、受守护 load、经依赖传播保持的 guard、跨侧使用以及 flags 的变化。Greedy 枚举、接受门槛和 cleanup 未修改。

| 固定父 IR | 发布 raw → 草案 raw | 同父对照 | 发布候选 → 草案候选 | 草案判定 |
| --- | ---: | ---: | ---: | --- |
| 历史 139 | 1550 → 1446 | 1137 | 1262 → 1135 | 接受，+2 |
| 历史 138 | 1561 → 1457 | 1152 | 1277 → 1150 | 接受，+2 |
| 发布 33 | 1558 → 1479 | 1138 | 1340 → 1216 | 拒绝，−78 |

用已核实形状和冻结输入重跑 17 例完整 Greedy，全部最终 IR 经 LLVM verifier。结果如下：

| Case | 发布 → 草案 TTI | 发布 → 草案提交数 | 最终 IR |
| --- | ---: | ---: | --- |
| vllm | 2619 → 2619 | 225 → 225 | 逐字节一致 |
| MapAiry | 3997 → 3997 | 30 → 30 | 逐字节一致 |
| tigre | 944 → 944 | 5 → 5 | 逐字节一致 |
| HLLD | 1696 → 1696 | 5 → 5 | 逐字节一致 |
| NQU64 | 274 → 274 | 2 → 2 | 逐字节一致 |
| MS32 | 198 → 198 | 2 → 2 | 逐字节一致 |
| PCM32 | 1138 → 1138 | 17 → 17 | 逐字节一致 |
| SRAD16 | 446 → 446 | 3 → 3 | 逐字节一致 |
| SRAD32 | 446 → 446 | 3 → 3 | 逐字节一致 |
| Landau | 1635 → 1635 | 22 → 22 | 逐字节一致 |
| SW2D | 1925 → 1925 | 1 → 1 | 逐字节一致 |
| CED | 281 → 281 | 3 → 3 | 仅 SSA 名变化 |
| TPACF | 325 → 325 | 23 → 23 | 逐字节一致 |
| SRAD-stage2 | 210 → 210 | 2 → 2 | 逐字节一致 |
| SasPoint5 | 487 → 487 | 8 → 8 | 逐字节一致 |
| HiPIMS-George | 5572 → 5572 | 5 → 5 | 逐字节一致 |
| LUD8 | 637 → 637 | 2 → 2 | 逐字节一致 |

全部 17 例最终 TTI 和提交数相同。CED 的第 1 次 R2R `B5:R3:R5` 的获选 TTI 为 309 → 307，后续两次提交仍为 294、281。逐字节核对最终 IR，唯一变化是 `%guard.result[.p]` 改名为 `%merged.select[.p]`，替换该名字后字节一致，函数级 `llvm-diff` 返回 0。最终实际哈希为 `d65f7e059e26c67da5aa64d39df79c4390ce40cba698fa6cacb5a012da84adbc`。其余 16 例最终 IR 逐字节一致。

草案提交 `87c7d8378ebe813bda4081212b8bf58da6a259c8` 的编译与集成测试通过。回归为 16 项通过、4 项按 `tests/KNOWN_FAILURES.md` 跳过。第一次套件运行时临时目录漏导出清单，补齐第 8 步冻结清单后复跑。GPU 未测，发布线和冻结清单均未修改。

## 回执

| 文件或工具 | SHA-256 |
| --- | --- |
| `git-bisect.log` | `2c636f7a2c004a93fd05faf80df6ed60f24b8cd0f871887b832eedb3c7d5fe2a` |
| `policy.json` | `82d408cce6f2fa883d3d4036a3b7cca4926ca9ba0e3c3ae8b4cba76174690a43` |
| `transition.json` | `2576b5f28c84eb4745e7fe6c742190170c250807bdb96929cdb89cf2b884bfd9` |
| `transition-139.diff` | `58d5c4b3f4f99d6bef0b9ef3881508dcc13d3ee310bf12507dce297e007c3297` |
| `transition-138.diff` | `52f00386184c007662ee26897d7f1dc1259dbd9ea330ba33068f4884b9db0a86` |
| `harness-smoke/result.json` | `94af98080b9214e6a2b2bd687c8d2708930fb84ec87fe56c3ae1aa74ef4268b1` |
| 草案 `fusion-search-llvm24` | `925a6ee70457a54119e3e31f28ef98f918ea770cfb4979ea46da31d5047a3679` |
| 草案 `decision-greedy` | `16a28c9e51a20b776b43786fc04b2dca8b103f3af69a2cf6227b8f513ede4a9a` |
| `draft-safe/result.json` | `0998e371f8f003b5bfb1af995ffc51cc43a2cc190c16266bc2813ad7c2a9b6bf` |
| `draft-safe/native-trial33/result.json` | `d3ec20bf775636f7d06a14c5fb22ff2b3398cfc7888d8004d76f333c35a942da` |
| `draft-safe/matrix.json` | `43acc85eee2555215fc0a17ee8f2974dde7b078211172d56f3e12c1730199083` |
| 草案 `final-anchor-r2r-draft-integrated/results.json` | `54700b3396da17fe3ee8e3820f32543ee1bf54ae2ec10aa7ca0629e949151a04` |

静态矩阵由实验目录中的 `step7c-matrix.py` 生成。它按发布 manifest 读取冻结 IR 和确切形状，逐例执行 `decision-greedy INPUT FUNCTION TOOL_ROOT active --anchor-wave-shape X,Y,Z`，再用 LLVM12 `opt -verify -disable-output` 验证最终 IR。固定候选的原始 IR 与全部日志均留在 EPYC。此前的轨迹与可达性证据见 [第 7b 步](pcm32-path-divergence-20261122.md)。
