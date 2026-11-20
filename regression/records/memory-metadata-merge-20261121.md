# 访存配对的 metadata 合并

基线为 `experiment/region-anchor` 的 `c89b380`。默认模式为 `strict`。

## 1. DARM 只读审计

共享指令在 `RegionMelder::cloneInstructions` 中克隆左指令，随后用两臂的输入修复操作数。DARM 这条路径未合并 metadata 或 IR flags。左独有的性质可能留在共享指令上，右独有的性质在克隆时丢失。

| 最小输入 | DARM 生成指令 |
|---|---|
| 左 store 无 TBAA，右有 | 共享 store 无 TBAA |
| 左 load 有 range，右无 | 共享 load 仍有 range |
| 左 add 有 nsw/nuw，右无 | 共享 add 仍有 nsw/nuw |
| 左 lshr 有 exact，右无 | 共享 lshr 仍有 exact |
| 左 fadd 有 nnan，右无 | 共享 fadd 仍有 nnan |

从发布清单默认 Greedy 的 16 个重建目录收集实际选中的 DARM 区域提交，使用只读插桩重放 27 次。26 次去掉 ModuleID 后与各自发布归档相同。CED 第 1 次只差 Greedy 提交时剥离的 `decision.ordered_trial_boundary` 元数据和打印的前驱顺序，核对这两点后相同。
在 1305 次共享指令克隆中，4 条保留了右侧不具有的性质。TPACF 第 1 次的 2 条 `shl` 各保留一对 `nsw/nuw`，HLLD 的 2 条分支各保留一个内部逻辑臂标记 `fusion.logical.arm`，没有发现单侧访存 metadata 被继承的实例。两条 TPACF 指令在第 1 次提交的 cleanup 后仍带这对 flag。后续提交改写了表达式，因此计数以发布链上可追溯到左右原指令的克隆位置为准。

逐提交计数见 [DARM 审计](memory-metadata-merge-20261121/darm-audit.json)。

## 2–3. 开关和测试

`--merge-metadata intersect` 同时作用于 Anchor B2B 的前缀和分段发射，以及 `--region-align anchor` 的共享访存克隆。普通 DARM 模式沿用原有克隆行为。访存的地址对齐属性、volatile 和内存序检查沿用 strict 模式。TBAA、alias.scope、noalias 和 access.group 使用 LLVM12 的合并规则，其余 metadata 仅保留双方完全相同的条目。

最小测试验证单侧 TBAA、单侧 range、相同 TBAA 和不同 TBAA 的公共类型。R2R 用例另外验证共享 load 的 `!range` 被剥离。所有测试输出通过 LLVM verifier，现有 `tests/run-v1` 通过。

## 4. PCM32 第 10 步

| 版本 | 共享 store / 单侧 store | 改写区 LDS load / store（原始 IR） | 全函数 LDS load / store（cleanup） | 热循环 LDS / VALU / s_waitcnt（gfx906） |
|---|---:|---:|---:|---:|
| DARM | 7 / 2 | 18 / 9 | 98 / 81 | 105 / 316 / 53 |
| Anchor intersect throughput | 0 / 16 | 30 / 16 | 110 / 88 | 112 / 316 / 59 |
| Anchor intersect latency | 0 / 16 | 16 / 16 | 96 / 88 | 110 / 295 / 52 |

两种 intersect Anchor 的 HSACO 均与同计价 strict Anchor 逐字节一致。DARM 的错位 store 配对在过滤 metadata 后可参与搜索，但它会与 latency Anchor 已选的同阶段 load 链发生顺序冲突。探针在两种 LLVM24 计价下，对 LDS store、AS3 指针 select 与 i32 select 均报价 1。在需要选择新地址及新数据的情况下，配对一个 store 的局部账面收益为 1−1−1。这里保留原代价与搜索规则。

| 版本 | 中位数 ms | 相对 DARM [95% 区间] | 相对父 [95% 区间] |
|---|---:|---|---|
| 父 | 785.097 | — | — |
| DARM | 740.057 | 1.0000 [1.0000, 1.0000] | 0.9426 [0.9425, 0.9427] |
| Anchor throughput | 787.496 | 1.0641 [1.0640, 1.0642] | 1.0031 [1.0030, 1.0031] |
| Anchor latency | 753.573 | 1.0183 [1.0182, 1.0184] | 0.9598 [0.9598, 0.9599] |

同一进程 12 轮、每次完整排序校验通过。A/A 重测与逐轮样本见 [PCM32 GPU 数据](memory-metadata-merge-20261121/pcm-gpu.json)。

## 5. 发布清单

| Case | Strict IR 与二进制 | Intersect final IR | 首处分歧 |
|---|---|---|---|
| CED | 与冻结版逐字节一致 | 字节别名 | — |
| HLLD | 与冻结版逐字节一致 | 字节别名 | — |
| HiPIMS-George | 与冻结版逐字节一致 | 字节别名 | — |
| Landau | 与冻结版逐字节一致 | 字节别名 | — |
| MS32 | 与冻结版逐字节一致 | 字节别名 | — |
| MapAiry | 与冻结版逐字节一致 | 字节别名 | — |
| NQU64 | 与冻结版逐字节一致 | 字节别名 | — |
| PCM32 | 与冻结版逐字节一致 | 字节别名 | — |
| SRAD-stage2 | 与冻结版逐字节一致 | 字节别名 | — |
| SRAD16 | 与冻结版逐字节一致 | 字节别名 | — |
| SRAD32 | 与冻结版逐字节一致 | 字节别名 | — |
| SW2D | 与冻结版逐字节一致 | 字节别名 | — |
| SasPoint5 | 与冻结版逐字节一致 | 字节别名 | — |
| TPACF | 与冻结版逐字节一致 | 字节别名 | — |
| tigre | 与冻结版逐字节一致 | 字节别名 | — |
| vllm | 与冻结版逐字节一致 | 字节别名 | — |

16 个 intersect 产物都是发布版的逐字节 IR 别名，二进制也一致，因此发布 GPU 判定沿用冻结结果。

[发布逐用例数据](memory-metadata-merge-20261121/release-results.json)。
