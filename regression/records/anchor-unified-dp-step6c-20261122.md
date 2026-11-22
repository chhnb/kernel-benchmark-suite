# Anchor B2B 第 6c 步：逐布局一致代价 gate

## 结论

- **LUD8 保持 G0 水平。** dedup=0 的两个政策均复用 G0 设备对象（451.274 ms），dedup=1 均复用 G1（450.979 ms）。
- **NQU64 回到 D。** 四种 gate 配置均为 D 的同字节对象，2 次提交，TTI 274。**PCM32 不变**，17 次提交，TTI 1138，设备对象同 D。
- 已知输入收益与跨输入退化仍需要取舍。两种报价政策的实际差异见后面的逐输入表。
- HLLD 在关闭 ASLR 后，三个候选都从两种形态收敛到一种。

## 实现与计价口径

起点为 `15ba49b14bd911c1903e68e5dbf93b35f86720a1`。在 `fusion-search-llvm24` 内，对当前请求真正读取的父 IR（包括 ordered-arm 归一化后传入的 prepared IR）和该请求的 split 条件分类一次。形状沿用 [6a 的 17 项 launch 来源](anchor-unified-dp-step6a-20261122.md#确切形状与重点核对)，由实验驱动按 case 显式传递。未给出确切形状时沿用 6a 的精确 metadata 回退及 unknown 处理。

gate 只过滤 `linear` 和 `guarded-linear`，在候选内部选出最高分布局之前执行。must-diverge 豁免，must-uniform 只留 fork，mixed/unknown 检查 false/true 两侧；若任一实际报价为负则拒绝，只有缺失报价才看 allow/reject。被拒的布局不占用合格布局的 cleanup IR 去重记录。没有 surviving 布局时报告候选无可用布局。最终接受仍用原来的同父 cleanup throughput TTI。未改 DP 定价、两个独立 beam、cleanup 或默认开关。

6b 已在逐布局 `evaluateTrial` 中调用 LLVM24 scorer。原评分以候选父状态在该侧所执行的块为 before，以该布局自己的 cleanup 后状态为 after。只有双方块集合及其指令报价可用才输出两侧 gain。`uniform_gain_false/true` 不从同一候选的其他布局继承。本步 gate 开启时，连 cleanup IR 重复的 linear/guarded 布局也拿到自己的报价或明确缺失记录。对照规则保留原去重和计分路径。记录的 `tti_eligible` 表示应用 gate 前的原评分判断。

## 环境、命令、测试

- EPYC 工件目录为 `/data/home/chh/simplify-v2/build/anchor-dp-step6c.2u7qrZ`。工具链从 `/data/home/chh/v2-runtime/reproduce.json` 加载。构建命令为 `bash compile-anchor-step3.sh source` 和 `bash link-anchor-step2.sh source`。冻结父 IR、GPU 输入和 reference 均沿用发布 manifest，LUD8 用既有 16384 输入和共享前端 IR。
- `python3 -u anchor-step6c-static.py "$stage"` 运行 17×7 档。每档用 verifier，记录最终 IR 哈希、位置和布局类型。`anchor-step6c-default-parity.py` 用 6b 逐候选白名单比较 D 的请求、IR、评分和提交链。`anchor-step6c-profile.py` 从每个候选的 request profile 汇总 scorer 调用数和 inclusive 累计时长。
- `python3 -u anchor-step6c-gpu.py "$stage"` 使用 6b 已验证的历史角色及第 5 步的计时方法。新二进制与历史对象按 SHA-256 比对。LUD8 的相对工作路径只改变了 `ModuleID` 注释，仍按原 O3、llc -O2 及原 host 设备链接链重建并用 `anchor-step6c-lud8.py` 核对实际 device 对象。记录中的同字节别名沿用历史结果。
- GPU 新比较为进程内角色轮换，预热至少 200 ms，12 个窗口。每角色每窗口先做 31 次完整输出校验的计时，使用中位数，A/A 首次不过只允许一次 61 次版本。A/A 门槛仍为配对中位数距 1 不超过 1%、跨度不超过 3%。报告配对比值与 10,000 次 bootstrap 95% 区间。
- `bash test-anchor-step1.sh source final-anchor-dp-step6c`。新增 fixture 对同一候选验证 线性布局的 303 报价被拒后仍返回 324 的合格 fork，must-uniform 阻挡所有 linear，must-diverge 保留有负侧向报价的 linear，缺失报价在 allow/reject 下走不同分支。原回归 16 项通过，`condition`、`pair-trial`、`regions`、`similarity` 按已知失败清单跳过。

```sh
DECISION_GREEDY_JOBS=8 "$greedy" "$frozen_ir" "$function" "$tool_root" active \
  --anchor-gap auto --anchor-guarded-gap 1 --anchor-auto-assume classify \
  --anchor-wave-shape "$workgroup" --anchor-uniform-gate on \
  --anchor-uniform-missing "$policy" --anchor-select-dedup "$dedup"
"$opt" -verify -disable-output active/final.ll
```

## 静态矩阵与耗时

全部 119 档通过 LLVM verifier。默认 D 与 c7 比较 17 个 case，逐候选白名单用到 **1** 次，白名单外的候选 IR 和评分差异为 0，最终 IR 与提交链全部一致。中间注释重排按 6b 处理。

下表每行列出提交数及最终 TTI。F 包含 segmented、before-split、merged-exit 等 fork 方案，区域融合和仅归一化提交计入「其他」。拒绝数按实际提出的合法布局统计，重复布局也单独计数，计数受 gate 改变后的搜索路径影响。括号中的数指在原 TTI 判据下合格的子集。哈希为落盘最终 IR 的原始 SHA-256。

| Case | 档位 | 提交 | TTI | 线性 | 守护 | Fork | 其他 | must-uniform | 负侧报价 | 报价缺失 | 最终 IR SHA-256 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| CED | D | 5 | 280 | 0 | 0 | 4 | 1 | 0 (0) | 0 (0) | 0 (0) | `0db3898d2be02dd29bcae14c6522ea6ed86992e931fdf9861eea9b6caad8fe7a` |
| CED | L | 3 | 281 | 2 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `417664a60f8b61f295edc5ea6f6eebd9c17760d6f19cfedb6ff7540778dae78e` |
| CED | G0 | 3 | 281 | 2 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `417664a60f8b61f295edc5ea6f6eebd9c17760d6f19cfedb6ff7540778dae78e` |
| CED | allow0 | 3 | 281 | 2 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `417664a60f8b61f295edc5ea6f6eebd9c17760d6f19cfedb6ff7540778dae78e` |
| CED | allow1 | 3 | 281 | 2 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `417664a60f8b61f295edc5ea6f6eebd9c17760d6f19cfedb6ff7540778dae78e` |
| CED | reject0 | 3 | 281 | 2 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `417664a60f8b61f295edc5ea6f6eebd9c17760d6f19cfedb6ff7540778dae78e` |
| CED | reject1 | 3 | 281 | 2 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `417664a60f8b61f295edc5ea6f6eebd9c17760d6f19cfedb6ff7540778dae78e` |
| HiPIMS-George | D | 5 | 5572 | 0 | 0 | 4 | 1 | 0 (0) | 0 (0) | 0 (0) | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` |
| HiPIMS-George | L | 4 | 5572 | 1 | 0 | 2 | 1 | 0 (0) | 0 (0) | 0 (0) | `c924ec1b3e96163dcbbaa3c91461d859386d3401f36f0a1a405f35ef272ec8bb` |
| HiPIMS-George | G0 | 4 | 5572 | 1 | 0 | 2 | 1 | 0 (0) | 0 (0) | 0 (0) | `c924ec1b3e96163dcbbaa3c91461d859386d3401f36f0a1a405f35ef272ec8bb` |
| HiPIMS-George | allow0 | 5 | 5572 | 0 | 0 | 4 | 1 | 0 (0) | 18 (18) | 0 (0) | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` |
| HiPIMS-George | allow1 | 5 | 5572 | 0 | 0 | 4 | 1 | 0 (0) | 18 (18) | 0 (0) | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` |
| HiPIMS-George | reject0 | 5 | 5572 | 0 | 0 | 4 | 1 | 0 (0) | 18 (18) | 0 (0) | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` |
| HiPIMS-George | reject1 | 5 | 5572 | 0 | 0 | 4 | 1 | 0 (0) | 18 (18) | 0 (0) | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` |
| HLLD | D | 5 | 1696 | 0 | 0 | 1 | 4 | 0 (0) | 0 (0) | 0 (0) | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` |
| HLLD | L | 4 | 1700 | 2 | 0 | 0 | 2 | 0 (0) | 0 (0) | 0 (0) | `b6e2cc543a3c28b80bba7a19faf1f576c8ccc5c51ad54dea98b8e7242d945f2d` |
| HLLD | G0 | 4 | 1700 | 2 | 0 | 0 | 2 | 0 (0) | 0 (0) | 0 (0) | `b6e2cc543a3c28b80bba7a19faf1f576c8ccc5c51ad54dea98b8e7242d945f2d` |
| HLLD | allow0 | 4 | 1700 | 2 | 0 | 0 | 2 | 0 (0) | 0 (0) | 0 (0) | `b6e2cc543a3c28b80bba7a19faf1f576c8ccc5c51ad54dea98b8e7242d945f2d` |
| HLLD | allow1 | 4 | 1700 | 2 | 0 | 0 | 2 | 0 (0) | 0 (0) | 0 (0) | `b6e2cc543a3c28b80bba7a19faf1f576c8ccc5c51ad54dea98b8e7242d945f2d` |
| HLLD | reject0 | 5 | 1696 | 0 | 0 | 1 | 4 | 0 (0) | 0 (0) | 11 (10) | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` |
| HLLD | reject1 | 5 | 1696 | 0 | 0 | 1 | 4 | 0 (0) | 0 (0) | 11 (10) | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` |
| Landau | D | 20 | 1708 | 0 | 0 | 15 | 5 | 0 (0) | 0 (0) | 0 (0) | `fb7a3852ffc14afc4fea138e9f06db4d8b6f77432897398ab73f0cc72c8b4bf5` |
| Landau | L | 19 | 1066 | 17 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `a5a39475d2a88c6af7eb3257ab195d63aff28c74145db5eee3a69ef21b59a9d6` |
| Landau | G0 | 19 | 1066 | 17 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `a5a39475d2a88c6af7eb3257ab195d63aff28c74145db5eee3a69ef21b59a9d6` |
| Landau | allow0 | 21 | 1565 | 4 | 0 | 12 | 5 | 0 (0) | 204 (202) | 0 (0) | `0fbfeb1af525d1efe85e8f22dcfc6c7db50491948637fccc90ec2db803fe2737` |
| Landau | allow1 | 21 | 1565 | 4 | 0 | 12 | 5 | 0 (0) | 204 (202) | 0 (0) | `0fbfeb1af525d1efe85e8f22dcfc6c7db50491948637fccc90ec2db803fe2737` |
| Landau | reject0 | 22 | 1635 | 4 | 0 | 13 | 5 | 0 (0) | 216 (214) | 171 (171) | `0a776f8358682bca451208efdec2de8b7c23c985990debefa5b4eaa1f69ea944` |
| Landau | reject1 | 22 | 1635 | 4 | 0 | 13 | 5 | 0 (0) | 216 (214) | 171 (171) | `0a776f8358682bca451208efdec2de8b7c23c985990debefa5b4eaa1f69ea944` |
| LUD8 | D | 1 | 735 | 0 | 0 | 1 | 0 | 0 (0) | 0 (0) | 0 (0) | `526ce2273ff4f2c93cb8ce2d20ac992cdfef6cf31ca24966601954911cb76442` |
| LUD8 | L | 1 | 666 | 1 | 0 | 0 | 0 | 0 (0) | 0 (0) | 0 (0) | `b56665b58f88c96d3d19380978353433f60d7cdbf9edad0d63a9cad631f41cf3` |
| LUD8 | G0 | 2 | 637 | 1 | 1 | 0 | 0 | 0 (0) | 0 (0) | 0 (0) | `ef1fa6fd26c94734564b205d4c8b79bb69ec5cc8ace91c88d6163dbad45b4078` |
| LUD8 | allow0 | 2 | 637 | 1 | 1 | 0 | 0 | 0 (0) | 0 (0) | 0 (0) | `ef1fa6fd26c94734564b205d4c8b79bb69ec5cc8ace91c88d6163dbad45b4078` |
| LUD8 | allow1 | 3 | 638 | 1 | 2 | 0 | 0 | 0 (0) | 0 (0) | 0 (0) | `7000ad4fb43a5a41781dd571030e16b2e7eed81d619dbe47a820d1ef29d749c6` |
| LUD8 | reject0 | 2 | 637 | 1 | 1 | 0 | 0 | 0 (0) | 0 (0) | 0 (0) | `ef1fa6fd26c94734564b205d4c8b79bb69ec5cc8ace91c88d6163dbad45b4078` |
| LUD8 | reject1 | 3 | 638 | 1 | 2 | 0 | 0 | 0 (0) | 0 (0) | 0 (0) | `7000ad4fb43a5a41781dd571030e16b2e7eed81d619dbe47a820d1ef29d749c6` |
| MapAiry | D | 31 | 4065 | 0 | 0 | 17 | 14 | 0 (0) | 0 (0) | 0 (0) | `388930dd748222e1e2b4e4eccbd6d43156c7f3d6d0a7baa33e9dbc1b7d3dd252` |
| MapAiry | L | 30 | 3660 | 26 | 0 | 1 | 3 | 0 (0) | 0 (0) | 0 (0) | `6733bc5cbb91ccfefa4ad2d2d7d9e2ea28a60248128434d707537ad9cad83893` |
| MapAiry | G0 | 30 | 3660 | 26 | 0 | 1 | 3 | 0 (0) | 0 (0) | 0 (0) | `6733bc5cbb91ccfefa4ad2d2d7d9e2ea28a60248128434d707537ad9cad83893` |
| MapAiry | allow0 | 28 | 4108 | 4 | 0 | 12 | 12 | 0 (0) | 231 (229) | 0 (0) | `a80e01a2caf20b5cf8ad0e2da7466f4f327af557ef00c32eb1fe62da399ab819` |
| MapAiry | allow1 | 28 | 4108 | 4 | 0 | 12 | 12 | 0 (0) | 231 (229) | 0 (0) | `a80e01a2caf20b5cf8ad0e2da7466f4f327af557ef00c32eb1fe62da399ab819` |
| MapAiry | reject0 | 30 | 3997 | 3 | 0 | 14 | 13 | 0 (0) | 229 (227) | 101 (96) | `25a2d3b390209e09433d77547d88fc59cc4e121cad8470316142033ed81305b1` |
| MapAiry | reject1 | 30 | 3997 | 3 | 0 | 14 | 13 | 0 (0) | 229 (227) | 101 (96) | `25a2d3b390209e09433d77547d88fc59cc4e121cad8470316142033ed81305b1` |
| MS32 | D | 2 | 198 | 0 | 0 | 1 | 1 | 0 (0) | 0 (0) | 0 (0) | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| MS32 | L | 2 | 198 | 0 | 0 | 1 | 1 | 0 (0) | 0 (0) | 0 (0) | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| MS32 | G0 | 2 | 198 | 0 | 0 | 1 | 1 | 0 (0) | 0 (0) | 0 (0) | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| MS32 | allow0 | 2 | 198 | 0 | 0 | 1 | 1 | 0 (0) | 2 (0) | 0 (0) | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| MS32 | allow1 | 2 | 198 | 0 | 0 | 1 | 1 | 0 (0) | 2 (0) | 0 (0) | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| MS32 | reject0 | 2 | 198 | 0 | 0 | 1 | 1 | 0 (0) | 2 (0) | 0 (0) | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| MS32 | reject1 | 2 | 198 | 0 | 0 | 1 | 1 | 0 (0) | 2 (0) | 0 (0) | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| NQU64 | D | 2 | 274 | 0 | 0 | 0 | 2 | 0 (0) | 0 (0) | 0 (0) | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| NQU64 | L | 2 | 274 | 0 | 0 | 0 | 2 | 0 (0) | 0 (0) | 0 (0) | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| NQU64 | G0 | 3 | 270 | 0 | 1 | 0 | 2 | 0 (0) | 0 (0) | 0 (0) | `04e1c9a2606814b686b7a775a19691cfda77e266dbd9bc2e1c0d343b1dca8c7a` |
| NQU64 | allow0 | 2 | 274 | 0 | 0 | 0 | 2 | 0 (0) | 4 (2) | 0 (0) | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| NQU64 | allow1 | 2 | 274 | 0 | 0 | 0 | 2 | 0 (0) | 4 (2) | 0 (0) | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| NQU64 | reject0 | 2 | 274 | 0 | 0 | 0 | 2 | 0 (0) | 4 (2) | 0 (0) | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| NQU64 | reject1 | 2 | 274 | 0 | 0 | 0 | 2 | 0 (0) | 4 (2) | 0 (0) | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| PCM32 | D | 17 | 1138 | 0 | 0 | 17 | 0 | 0 (0) | 0 (0) | 0 (0) | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| PCM32 | L | 17 | 1138 | 0 | 0 | 17 | 0 | 0 (0) | 0 (0) | 0 (0) | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| PCM32 | G0 | 17 | 1138 | 0 | 0 | 17 | 0 | 0 (0) | 0 (0) | 0 (0) | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| PCM32 | allow0 | 17 | 1138 | 0 | 0 | 17 | 0 | 0 (0) | 63 (0) | 0 (0) | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| PCM32 | allow1 | 17 | 1138 | 0 | 0 | 17 | 0 | 0 (0) | 63 (0) | 0 (0) | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| PCM32 | reject0 | 17 | 1138 | 0 | 0 | 17 | 0 | 0 (0) | 63 (0) | 0 (0) | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| PCM32 | reject1 | 17 | 1138 | 0 | 0 | 17 | 0 | 0 (0) | 63 (0) | 0 (0) | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| SasPoint5 | D | 8 | 491 | 0 | 0 | 8 | 0 | 0 (0) | 0 (0) | 0 (0) | `107673959aa91db3f36aea8a1fee279d01c65b9b5fff34f5eda6da15fa356f2e` |
| SasPoint5 | L | 7 | 485 | 4 | 0 | 3 | 0 | 0 (0) | 0 (0) | 0 (0) | `635bcc33f218ac8c293e0a76ee2f3a0c9578a0770174171df3da798bfadae615` |
| SasPoint5 | G0 | 8 | 458 | 4 | 1 | 3 | 0 | 0 (0) | 0 (0) | 0 (0) | `19a6e61fb49700257e5d132f4bcd8e71cf550b439cccc753642ee83111fd9b35` |
| SasPoint5 | allow0 | 8 | 487 | 1 | 0 | 7 | 0 | 0 (0) | 86 (78) | 0 (0) | `cddeee0b711c71df961d6790a5d6501a1cab8070c4972dc17e1ee9d5292aab44` |
| SasPoint5 | allow1 | 8 | 487 | 1 | 0 | 7 | 0 | 0 (0) | 86 (78) | 0 (0) | `cddeee0b711c71df961d6790a5d6501a1cab8070c4972dc17e1ee9d5292aab44` |
| SasPoint5 | reject0 | 8 | 487 | 1 | 0 | 7 | 0 | 0 (0) | 86 (78) | 0 (0) | `cddeee0b711c71df961d6790a5d6501a1cab8070c4972dc17e1ee9d5292aab44` |
| SasPoint5 | reject1 | 8 | 487 | 1 | 0 | 7 | 0 | 0 (0) | 86 (78) | 0 (0) | `cddeee0b711c71df961d6790a5d6501a1cab8070c4972dc17e1ee9d5292aab44` |
| SRAD-stage2 | D | 2 | 210 | 0 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SRAD-stage2 | L | 2 | 210 | 0 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SRAD-stage2 | G0 | 2 | 210 | 0 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SRAD-stage2 | allow0 | 2 | 210 | 0 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SRAD-stage2 | allow1 | 2 | 210 | 0 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SRAD-stage2 | reject0 | 2 | 210 | 0 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SRAD-stage2 | reject1 | 2 | 210 | 0 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SRAD16 | D | 4 | 452 | 0 | 0 | 4 | 0 | 0 (0) | 0 (0) | 0 (0) | `a874ce3e6de7dc81c55d058eafed0599c131723fcd46141854100d0f934a60ec` |
| SRAD16 | L | 4 | 437 | 2 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `061d52a918b822ec1a7fa13e64e48c67a402f2cc54f7d1c71e9499eb31c8b1db` |
| SRAD16 | G0 | 4 | 437 | 2 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `061d52a918b822ec1a7fa13e64e48c67a402f2cc54f7d1c71e9499eb31c8b1db` |
| SRAD16 | allow0 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `84495226b219c7d3c405401e962a85122cd209101bc70ff2e7103a658ae8f55a` |
| SRAD16 | allow1 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `84495226b219c7d3c405401e962a85122cd209101bc70ff2e7103a658ae8f55a` |
| SRAD16 | reject0 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `84495226b219c7d3c405401e962a85122cd209101bc70ff2e7103a658ae8f55a` |
| SRAD16 | reject1 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `84495226b219c7d3c405401e962a85122cd209101bc70ff2e7103a658ae8f55a` |
| SRAD32 | D | 4 | 452 | 0 | 0 | 4 | 0 | 0 (0) | 0 (0) | 0 (0) | `775c85f9b192b53cc82078d603a99536da3918500fcdffdf6f51604a439a9fff` |
| SRAD32 | L | 4 | 437 | 2 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b2b36e6266ad77fcd6799054250b282d50a3ac8c279c6de9e03a1d17ed5db313` |
| SRAD32 | G0 | 4 | 437 | 2 | 0 | 2 | 0 | 0 (0) | 0 (0) | 0 (0) | `b2b36e6266ad77fcd6799054250b282d50a3ac8c279c6de9e03a1d17ed5db313` |
| SRAD32 | allow0 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `5f76db84cd3958b85edbe91394ef7aba54672e0d44e548e721a94b4c8eaef638` |
| SRAD32 | allow1 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `5f76db84cd3958b85edbe91394ef7aba54672e0d44e548e721a94b4c8eaef638` |
| SRAD32 | reject0 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `5f76db84cd3958b85edbe91394ef7aba54672e0d44e548e721a94b4c8eaef638` |
| SRAD32 | reject1 | 3 | 446 | 1 | 0 | 2 | 0 | 0 (0) | 23 (23) | 0 (0) | `5f76db84cd3958b85edbe91394ef7aba54672e0d44e548e721a94b4c8eaef638` |
| SW2D | D | 1 | 1925 | 0 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| SW2D | L | 1 | 1925 | 0 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| SW2D | G0 | 1 | 1925 | 0 | 0 | 0 | 1 | 0 (0) | 0 (0) | 0 (0) | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| SW2D | allow0 | 1 | 1925 | 0 | 0 | 0 | 1 | 0 (0) | 4 (0) | 0 (0) | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| SW2D | allow1 | 1 | 1925 | 0 | 0 | 0 | 1 | 0 (0) | 4 (0) | 0 (0) | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| SW2D | reject0 | 1 | 1925 | 0 | 0 | 0 | 1 | 0 (0) | 4 (0) | 0 (0) | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| SW2D | reject1 | 1 | 1925 | 0 | 0 | 0 | 1 | 0 (0) | 4 (0) | 0 (0) | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| tigre | D | 6 | 946 | 0 | 0 | 3 | 3 | 0 (0) | 0 (0) | 0 (0) | `ac3d39d3f979a4237b9dd5875e114da10a2e047647af3c2e4d02a7ef15b9f20a` |
| tigre | L | 5 | 944 | 1 | 0 | 1 | 3 | 0 (0) | 0 (0) | 0 (0) | `5aea08d6b2a5febf5eb480f283bde146e3a1c6b972dcf3fd51cdec94d28fdf61` |
| tigre | G0 | 5 | 944 | 1 | 0 | 1 | 3 | 0 (0) | 0 (0) | 0 (0) | `5aea08d6b2a5febf5eb480f283bde146e3a1c6b972dcf3fd51cdec94d28fdf61` |
| tigre | allow0 | 5 | 944 | 1 | 0 | 1 | 3 | 0 (0) | 1 (1) | 0 (0) | `5aea08d6b2a5febf5eb480f283bde146e3a1c6b972dcf3fd51cdec94d28fdf61` |
| tigre | allow1 | 5 | 944 | 1 | 0 | 1 | 3 | 0 (0) | 1 (1) | 0 (0) | `b08ec5d1c457bc8584201adb20d233c2cb32b14b525d0b490be105803c8486ba` |
| tigre | reject0 | 5 | 944 | 1 | 0 | 1 | 3 | 0 (0) | 1 (1) | 0 (0) | `5aea08d6b2a5febf5eb480f283bde146e3a1c6b972dcf3fd51cdec94d28fdf61` |
| tigre | reject1 | 5 | 944 | 1 | 0 | 1 | 3 | 0 (0) | 1 (1) | 0 (0) | `b08ec5d1c457bc8584201adb20d233c2cb32b14b525d0b490be105803c8486ba` |
| TPACF | D | 23 | 325 | 0 | 0 | 1 | 22 | 0 (0) | 0 (0) | 0 (0) | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| TPACF | L | 23 | 325 | 0 | 0 | 1 | 22 | 0 (0) | 0 (0) | 0 (0) | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| TPACF | G0 | 23 | 325 | 0 | 0 | 1 | 22 | 0 (0) | 0 (0) | 0 (0) | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| TPACF | allow0 | 23 | 325 | 0 | 0 | 1 | 22 | 0 (0) | 4 (4) | 0 (0) | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| TPACF | allow1 | 23 | 325 | 0 | 0 | 1 | 22 | 0 (0) | 4 (4) | 0 (0) | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| TPACF | reject0 | 23 | 325 | 0 | 0 | 1 | 22 | 0 (0) | 4 (4) | 0 (0) | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| TPACF | reject1 | 23 | 325 | 0 | 0 | 1 | 22 | 0 (0) | 4 (4) | 0 (0) | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| vllm | D | 225 | 2619 | 0 | 0 | 224 | 1 | 0 (0) | 0 (0) | 0 (0) | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` |
| vllm | L | 225 | 2619 | 64 | 0 | 160 | 1 | 0 (0) | 0 (0) | 0 (0) | `d41eca80caef11f83123f675a41b81b22cb7543376009ec69e97ca88a4ffcddb` |
| vllm | G0 | 225 | 2619 | 64 | 0 | 160 | 1 | 0 (0) | 0 (0) | 0 (0) | `d41eca80caef11f83123f675a41b81b22cb7543376009ec69e97ca88a4ffcddb` |
| vllm | allow0 | 225 | 2619 | 64 | 0 | 160 | 1 | 0 (0) | 0 (0) | 0 (0) | `d41eca80caef11f83123f675a41b81b22cb7543376009ec69e97ca88a4ffcddb` |
| vllm | allow1 | 225 | 2619 | 64 | 0 | 160 | 1 | 0 (0) | 0 (0) | 0 (0) | `d41eca80caef11f83123f675a41b81b22cb7543376009ec69e97ca88a4ffcddb` |
| vllm | reject0 | 225 | 2619 | 0 | 0 | 224 | 1 | 0 (0) | 0 (0) | 332 (332) | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` |
| vllm | reject1 | 225 | 2619 | 0 | 0 | 224 | 1 | 0 (0) | 0 (0) | 332 (332) | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` |

### 搜索开销与受影响候选

计时为 EPYC 同一批 CPU 作业，wall 时间会受并发影响。scorer inclusive 时间按候选日志汇总，表示各调用之和。分类时间没有包括已经在原规划和评分中发生的 IR cleanup。

| 档位 | 合计 wall 秒 | Anchor 请求数 | 布局计分调用数 | scorer 合计秒 | 分类合计秒 | 命中 fork 回退 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| G0 | 378.2 | 2037 | 5900 | 227.31 | 0.00 | 0 |
| allow0 | 405.2 | 2118 | 6286 | 250.07 | 0.09 | 161 |
| allow1 | 406.8 | 2117 | 6302 | 249.71 | 0.09 | 161 |
| reject0 | 421.7 | 2111 | 6720 | 256.84 | 0.08 | 515 |
| reject1 | 421.4 | 2110 | 6736 | 255.10 | 0.08 | 515 |

每档 allow 拒绝 663 个合法布局，其中 580 个原本通过 TTI。每档 reject 拒绝 1,288 个合法布局，其中负报价 673、缺报价 615，有 1,199 个原本通过 TTI。矩阵没有触发 must-uniform，禁止线性的规则已由单元用例覆盖。

以下为原正收益布局被拒后，仍有合格 fork、但 TTI 差距最大的三个同父实例。它们提供了下一步检查局部守护折中方案的具体父状态；该布局是否存在及其 GPU 效果尚未验证。

| Case | 档位 | 请求 | 块 ID | 分类 | 只清理 TTI | 被挡布局 TTI | 最优合格 fork TTI |
| --- | --- | --- | --- | --- | ---: | ---: | ---: |
| Landau | reject1 | trial-287 | `B14:B13:B15` | unknown | 2071 | 2007 | 2059 |
| Landau | reject1 | trial-281 | `B16:B15:B17` | unknown | 2098 | 2034 | 2086 |
| Landau | reject1 | trial-276 | `B6:B5:B7` | unknown | 2098 | 2034 | 2082 |

## GPU 对照与政策取舍

下表是相对 D 的配对耗时比与 95% 区间。重复的对象只测一个角色。历史别名沿用原数据。LUD8 行使用第 4 步的 5 次同批结果，按原顺序计算配对区间。

| 冻结输入 | G0 / D | allow0 / D | allow1 / D | reject0 / D | reject1 / D | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| LUD8/16384 | 0.89377 [0.88257, 0.90071] | 0.89377 [0.88257, 0.90071] | 0.89695 [0.88199, 0.90103] | 0.89377 [0.88257, 0.90071] | 0.89695 [0.88199, 0.90103] | 历史别名 |
| NQU64 | 1.04886 [1.04364, 1.05543] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 历史别名 |
| PCM32 | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 历史别名 |
| MapAiry/65539 | 0.92000 [0.92000, 0.92000] | 1.12000 [1.12000, 1.12000] | 1.12000 [1.12000, 1.12000] | 1.00000 [1.00000, 1.00500] | 1.00000 [1.00000, 1.00500] | 新批完整校验 |
| vllm/64K | 1.00746 [1.00475, 1.01568] | 1.00746 [1.00475, 1.01568] | 1.00746 [1.00475, 1.01568] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 历史别名 |
| vllm/128K | 1.01222 [1.00703, 1.01316] | 1.01222 [1.00703, 1.01316] | 1.01222 [1.00703, 1.01316] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 历史别名 |
| Landau/mixed | 0.80349 [0.80175, 0.80610] | 0.96522 [0.96508, 0.96943] | 0.96522 [0.96508, 0.96943] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 新批完整校验 |
| Landau/coherent | 1.30282 [1.30070, 1.30741] | 1.01056 [1.00350, 1.01408] | 1.01056 [1.00350, 1.01408] | 1.00000 [0.99650, 1.00000] | 1.00000 [0.99650, 1.00000] | 新批完整校验 |
| SasPoint5/interval-mixture | 0.93548 [0.93548, 0.93572] | 1.00000 [1.00000, 1.00025] | 1.00000 [1.00000, 1.00025] | 1.00000 [1.00000, 1.00025] | 1.00000 [1.00000, 1.00025] | 新批完整校验 |
| SasPoint5/coherent-blocks | 1.18064 [1.16667, 1.20351] | 1.00000 [0.99483, 1.00000] | 1.00000 [0.99483, 1.00000] | 1.00000 [0.99483, 1.00000] | 1.00000 [0.99483, 1.00000] | 新批完整校验 |
| SasPoint5/uniform-01 | 1.18880 [1.18748, 1.20833] | 0.99264 [0.98304, 1.00000] | 0.99264 [0.98304, 1.00000] | 0.99264 [0.98304, 1.00000] | 0.99264 [0.98304, 1.00000] | 新批完整校验 |
| SRAD16/256 | 1.00000 [0.99222, 1.00394] | 0.99612 [0.99216, 1.00000] | 0.99612 [0.99216, 1.00000] | 0.99612 [0.99216, 1.00000] | 0.99612 [0.99216, 1.00000] | 新批完整校验 |
| SRAD32/256 | 0.99247 [0.99242, 1.00000] | 0.99240 [0.98861, 0.99242] | 0.99240 [0.98861, 0.99242] | 0.99240 [0.98861, 0.99242] | 0.99240 [0.98861, 0.99242] | 新批完整校验 |
| CED/110 | — | — | — | — | — | 历史对象别名，A/A 无可靠计时 |
| tigre/head64 | 1.00582 [1.00425, 1.00846] | 1.00582 [1.00425, 1.00846] | 1.00679 [1.00301, 1.00826] | 1.00582 [1.00425, 1.00846] | 1.00679 [1.00301, 1.00826] | 历史别名 |

新批 A/A 各次为「窗口内次数 / 中位数 / 跨度」。

| 输入 | A/A |
| --- | --- |
| MapAiry/65539 | 31 / 1.00000 / 0.38% |
| Landau/mixed | 31 / 1.00000 / 0.19% |
| Landau/coherent | 31 / 1.00000 / 1.50% |
| SasPoint5/interval-mixture | 31 / 1.00000 / 0.75% |
| SasPoint5/coherent-blocks | 31 / 1.00000 / 0.63% |
| SasPoint5/uniform-01 | 31 / 1.00000 / 0.00% |
| SRAD16/256 | 31 / 1.00000 / 1.77% |
| SRAD32/256 | 31 / 0.99609 / 0.80% |

### 缺失报价政策的取舍

- **MapAiry。** 同批 G0/D 0.92000。allow 使这个冻结输入比 D 慢约 12%，reject 回到 D 附近，并放弃原线性布局在同一输入的收益。第 4 步的 3 批 G0/D 为 0.93269。
- **Landau。** G0 在 mixed 上收益约 20%，在 coherent 上慢约 30%。allow 把两端收至 0.96522 和 1.01056，保留一部分 mixed 收益，同时在 coherent 还有小幅退化。reject 为 1.00000 和 1.00000。
- **SasPoint5。** 两种政策在三个冻结输入上使用同一个设备对象。interval-mixture 上 G0 的约 6.5% 收益消失；coherent 和 uniform 原有约 17%–21% 的退化消失。当前实测见上表。
- **NQU64。** 两种政策均等于 D 的对象，移除了 G0/D 为 1.04886 的守护退化。
- **vLLM。** 64K 和 128K 上，G0/D 是 1.00746 和 1.01222。allow 是 1.00746 和 1.01222，reject 是 1.00000 和 1.00000。
- **LUD8、PCM32。** LUD8 的每种 dedup 都保留对应 G0/G1 产物，PCM32 是 D 的设备对象。SRAD16/32 改产物，幅度见同批表；tigre 仍是历史对象，CED 仍无可靠计时。

据此需要在不同输入方向相反的收益与回归之间选政策。已测数据支持 reject 在 Landau coherent 和 MapAiry 上更稳，也消除了 vLLM 两个输入的历史退化，同时放弃了 Landau mixed 在 allow 下仍保留的收益。此步继续保持发布默认。

## 附录 HLLD 地址随机化

使用 `c7dded07` 的发布二进制，固定 6b 中三项 D 候选各自的父 IR、split/两臂、cleanup 参数和输入序列化路径。每一轮是独立进程。`anchor-step6c-aslr.py` 只在第二组命令前加 `setarch x86_64 -R`。正常和关闭 ASLR 分别各做 20 次，合计 120 次。

| 候选 | 父 IR SHA-256 | 变体 SHA-256 | TTI | 正常环境 | 关闭 ASLR |
| --- | --- | --- | ---: | ---: | ---: |
| B9:B22:B12 | 1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91 | 3d088bc542be3afa7cea5ea719ab027ec04353596c45db55c45c75d64e2de864 | 1838 | 8 | 20 |
| B9:B22:B12 | 1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91 | 5a7d21cef13e427ed492cf02ac4c0fc9d7662ce1b76da627460a7171eb201d3a | 1839 | 12 | 0 |
| B9:B23:B12 | 1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91 | 0e5a464ec534233a07094584cbd49a3b325d4a404ba7339958d57f886fe462ef | 1843 | 11 | 20 |
| B9:B23:B12 | 1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91 | dd1b16cbc43fd52e21b74a270680d5885dc1465df59648db24254e19123ff2b4 | 1844 | 9 | 0 |
| B9:B21:B12 | 162a59fd16e55a76dfb488b5361549df3adfd3d3712657def52b6c3cd06b504f | 0e732f1488ffebc94e1cab72ce0daf9d19c9da29756f28e2837e1dccff9fee3e | 1804 | 14 | 0 |
| B9:B21:B12 | 162a59fd16e55a76dfb488b5361549df3adfd3d3712657def52b6c3cd06b504f | 4187ad0d4f4310521ae6fc5d893ff3bca1ba344cd9ebb38e74897313b509cf52 | 1805 | 6 | 20 |

关闭地址随机化后，每个候选的 20 次都给出相同的一种旧形态。这个对照支持地址相关排序或遍历的解释，仍不足以确定具体容器、比较器或代码行。已更新 [KNOWN_ISSUES](../../docs/KNOWN_ISSUES.md#darm-r2b-试融的非确定性)。

## SHA-256 收据

| 工件 | SHA-256 |
| --- | --- |
| `source/build/decision-fuse/decision-greedy` | `a228699b9418d3fd39a7e69a212c20a2bd256e4492148fbf5a610fa0460eb125` |
| `source/build/llvm24-tti/fusion-search-llvm24` | `5a2cecb3112d411a8954fbd6cb27f5d451769ec6ecfec70cbe56567558099295` |
| `source/build/llvm24-tti/llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| `../anchor-dp-step0.nNbMYe/base/build/llvm24-tti/fusion-search-llvm24` | `892bcad9b23338819f446dde95bf9fda0e3bc9ce90af4efe96e838fb8dfdf4a2` |
| `source/build/simplify-fingerprint/final-anchor-dp-step6c/results.json` | `54700b3396da17fe3ee8e3820f32543ee1bf54ae2ec10aa7ca0629e949151a04` |
| `static.json` | `46ccbe72a7a040f31697fdc45861e58eecf2ebee4afdeb828764b732e25cd404` |
| `default-parity.json` | `fda46126219b693078b0ef78e9b9df96ab0ae414fc9c65dc19147c544f38cf05` |
| `profile.json` | `859aa54f73f2428ce200469ce4388c7c1a90bbd8f5ff4a98302d333cf124f3fb` |
| `gpu/final-results.json` | `8964f0cd8494379fa3266cb7648dff19abb42bc431d79457303427f5a5995686` |
| `aslr.json` | `a9b233e58080189ff592bb6d6c64a44e4ff697b6b84ec8962a6a16fd0ceaacc4` |
| `lud8-gpu/results.json` | `23d68a067a7cb18586dd6df371456dbe31abff46e703180e33ab4ea04c1837a0` |
