# 区域 Anchor 的单侧指令排列

起点 `225972b`。同父 PCM32 第 10 次 R2R 显式回放 `_Z3pcmPi:B5:H6_8:H7_8`，使用 LLVM24 latency 计价。E1、E3 和原 Latency Anchor 都显式启用 `--merge-metadata intersect`。

## 1. 逐项序列比对

DARM 和 E3 的 14 对 LDS load 与 7 对 store 完全一致。全部发射序列的配对数分别为 71 和 60，含块头、PHI 和终结指令。DARM 独有的 11 项是 3 对 PHI、7 对写地址 GEP、1 对取值 select。E3 没有独有配对。共有端点且中间没有额外配对的 gap 有 51 个，其中 6 个的单侧顺序不同。

例如首个错位 store 之前，DARM 在左臂游标更新后先列出右侧第 11 项 `sub 255`，稍后才发射左侧第 18 项 store 和下一阶段两条读；E3 native 在这一 gap 收完全部左项后才列右项。E3 会把读结果选择留在左右各自的块里，用 PHI 汇合。SW 投影恢复了右侧提前出现的独立地址计算。E3 sw 的 O3 IR 仍把首个错位 store 的两个源 select 保留在两臂（%679 / %680），再用 %guard.result 汇合。这里缺失的配对也影响发射，不能把分支臂内的 select 都归因给 gap 顺序。

[完整三份发射序列](anchor-gap-order-20261121/sequences.json)、[原始差异](anchor-gap-order-20261121/sequence-M-E3-native.diff)、[修正后剩余差异](anchor-gap-order-20261121/sequence-M-E3-sw.diff)。

## 2. 排列开关

`fusion-search-llvm24 --anchor-gap-order native|sw|latency` 默认为 native，两个命令行入口均支持，非默认值要求 `--region-align anchor`。SW 从 DARM 的 Smith–Waterman 结果取得条目次序，在每个 Anchor gap 内按该次序保序交织。DARM 的配对若被 Anchor 拆开，原配对位置按左、右发射。Latency 模式在保持每侧顺序、SSA 依赖和访存及其它副作用相对顺序的前提下，优先安排不依赖 gap 内或紧邻前个匹配项中读取结果的就绪指令。

两个模式都只重排 gap；配对搜索、报价、发射器和最终接受条件沿用原实现。改变发射后的 TTI 可以改变既有严格/宽松候选之间的选择。此次 E1 即发生这种切换。

## 3. PCM32 静态核对与 GPU

E3 sw 的序列恰好等于 DARM 序列把 11 个 DARM 独有配对拆成左、右各一项。其余 gap 差异全部清除。Cleanup IR、O3 IR 及 HSACO 仍有差异。目标循环的 VALU 回到 DARM 的 142；SALU 由 DARM 的 69 变成 70，掩码操作 42→44。E3 sw 恢复了 DARM 的 7 组“末条共享读后先执行 4 条指令再等”的节奏，也恢复了单侧段的 `lgkmcnt(1)`。E3 latency 的这 7 组仍是读完立刻等。该排列只在匹配点之间移动单侧项，不能把某个 gap 的指令搬到前一个共享比较之前。

| 版本 | 共享 load / store | 目标循环 LDS / VALU / SALU / wait / 掩码 | 每次等待前潜在未清除的 LDS 读 |
|---|---|---|---|
| M | 14 / 7 | 27 / 142 / 69 / 9 / 42 | 9 次均为 2 |
| e3-native | 14 / 7 | 27 / 137 / 61 / 9 / 37 | 9 次均为 2 |
| e3-sw | 14 / 7 | 27 / 142 / 70 / 9 / 44 | 9 次均为 2 |
| e3-latency | 14 / 7 | 27 / 136 / 62 / 9 / 39 | 9 次均为 2 |
| original-native | 16 / 0 | 32 / 121 / 56 / 8 / 40 | 8 次均为 2 |
| original-sw | 16 / 0 | 32 / 124 / 59 / 8 / 42 | 8 次均为 2 |
| original-latency | 16 / 0 | 32 / 121 / 56 / 8 / 40 | 8 次均为 2 |
| e1-native | 2 / 0 | 34 / 145 / 8 / 15 / 5 | 15 次均为 2 |
| e1-sw | 16 / 0 | 32 / 124 / 59 / 8 / 42 | 8 次均为 2 |
| e1-latency | 16 / 0 | 32 / 121 / 56 / 8 / 40 | 8 次均为 2 |

计数通过目标循环 CFG 推导，按前一条 wait 的计数器阈值保留可能仍在途的 LDS 操作。这是指令发射给出的上限；硬件可能已完成部分读取。每个 wait 的 PC、阈值及路径计数见 [机器码明细](anchor-gap-order-20261121/pcm-static.json)。

所有 E3 的共享访存配对仍与 DARM 相同，含 2 对同一步 load、12 对错位 load 和 7 对错位 store。原 Latency Anchor 各模式为 16 对同一步 load 和零共享 store。E1 native 只有 2 对同一步读；E1 sw 与 latency 因清理后 TTI 的排序切到宽松方案，各有 16 对同一步读取，分别与对应的原 Latency Anchor 产物字节相同。原 Latency Anchor 开 latency 排列的 HSACO 与其 native 相同。

同进程共享输入交错 12 轮，字节别名只测一份。A/A 按发布规则。所有正式启动都走 pinned-host 完整排序校验。

A/A 1。各复制槽中位数 1.00004, 0.99999, 1.00001, 1.00003, 0.99994，最大跨度 63.75%。
A/A 2。各复制槽中位数 0.99998, 1.00001, 1.00003, 1.00000, 1.00004，最大跨度 140.21%。

GPU 状态为 unmeasurable。
A/A 1 次的最慢 DARM 槽是第 5 轮 slot2，耗时 1211.936 ms。该次输出校验通过。
A/A 2 次的最慢 DARM 槽是第 2 轮 slot5，耗时 1777.243 ms。该次输出校验通过。
两次 A/A 的轮间跨度均超出 3%，依规则停止 GPU 部分。未启动正式测量，因此无法用本批数据判定任何排列相对 DARM 或父的速度。

[GPU 逐轮数据与二进制哈希](anchor-gap-order-20261121/gpu-paired.json)。

## 4. 影响面

- sw 相对 native 的 HSACO 变化为 6/26。分别为 MapAiry/trial-228, MapAiry/trial-281, MapAiry/trial-348, tigre/trial-6, HLLD/trial-28, Landau/trial-322。
- latency 相对 native 的 HSACO 变化为 0/26。

审计使用原 latency Anchor 的 strict metadata 路径。native 的 26 个 HSACO 全部与历史原 latency Anchor 逐字节一致。相对 native，sw 改变 22 次发射序列、13 次 cleanup IR；latency 改变 4 次发射序列，cleanup IR 均相同。B2B Anchor 使用独立的布局发射器，开关未进入该路径，已在一例有实际共享 load 的 B2B 上用三个值逐字节核对。现有 `tests/run-v1` 通过。

[26 次回放的 HSACO 哈希](anchor-gap-order-20261121/audit-hsaco.json)。
