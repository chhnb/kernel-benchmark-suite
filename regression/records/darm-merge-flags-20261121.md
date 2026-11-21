# DARM 合并属性审计与验证

## 起点

2026-11-21，EPYC／gfx906。远端 `feature/anchor-default` 从 `ed20a1f` 普通快进至发布标签指向的 `d8f1729`，标签与 HEAD 祖先检查通过，区间内没有后续提交。两者的源码、测试和发布归档逐字节一致，差异为两份发布文档。EPYC 的干净构建通过，测试 26 项通过，`condition`、`pair-trial`、`regions`、`similarity` 按 `tests/KNOWN_FAILURES.md` 返回 77。

默认 B2B 使用 Anchor V2+P，区域使用 DARM。TTI 环境变量缺省时使用 `TCK_RecipThroughput`，发布重建脚本显式设置 `FUSION_TTI_COST_KIND=throughput`。结构 cleanup 为目标感知 SimplifyCFG 至稳定，PHI 折叠阈值 7，关闭条件分支简化及公共指令提升和下沉，随后 EarlyCSE、DCE、InstCombine。候选 IR 最后统一 PHI 入边顺序。发布入口没有 `--merge-metadata`。

共享起点 `2a9b257` 从 `52a09af` 选取 SRAD 诊断计时与 A/A 工具，公式与 `065cfdb`、`47f429b` 的记录一致。发布树已有进程内角色轮换和独立进程的配对 bootstrap 入口。移植增加 200 ms 预热、A/A 检查和完整输出校验辅助代码。EPYC 上两个诊断 runner 构建成功，输出检查的正反例通过。

## 修改前审计

DARM 的匹配入口为 `tools/darm_pair_engine/InstructionMatch.cpp`。`RegionMelder::cloneInstructions` 对形成单条共享指令的配对克隆左侧，再修复操作数。未配对指令和两侧 PHI 各自克隆。出口无法共享时，分支也分别克隆。

| 指令或属性 | 当前匹配与发射 | 一侧属性可能继承 | 合并做法 |
| --- | --- | --- | --- |
| 整数 add、sub、mul、shl 的 nsw/nuw，除法或右移的 exact | nsw/nuw 检查已注释，exact 无单独检查。共享指令沿用左侧 flags | 是 | 在共享克隆上取 IR flags 交集 |
| 浮点二元及一元运算 | 按 opcode、类型和操作数个数匹配，左侧 fast-math flags 随克隆复制 | 是 | 取 fast-math flags 交集 |
| fcmp、icmp 与 select | 比较指令检查谓词，select 走通用匹配。共享指令保留左侧允许的 flags | 是 | 保持谓词约束，取 IR flags 交集 |
| GEP | 要求 inbounds 状态相同。附加 IR flags 随左侧克隆 | 已比较的 inbounds 两侧一致 | 继续使用现有匹配，交集合并器支持的 IR flags |
| Call 与 invoke | 白名单数学和采样 intrinsic 比较 FMF、metadata、call-site attributes。普通 call 比较 callee 与调用约定，invoke 比较调用约定及异常落点 | 白名单已比较的属性一致，普通路径可继承单侧 FMF 与 metadata | 取 IR flags 和 metadata 的共同保证。独立的 LLVM AttributeList 匹配超出本次 flags／metadata 范围 |
| Load、store | 比较 volatile、alignment、ordering，沿用左侧 tbaa、range、nonnull、noalias、alias.scope、invariant.load 等附件 | 是 | 由 LLVM 按 kind 合并两侧事实，丢弃无法安全保留的附件 |
| 原子 RMW、cmpxchg、fence | 比较各自的原子操作、ordering、同步域等结构属性，附件随左侧克隆 | metadata 可以单侧继承 | 结构约束照旧，合并 metadata |
| Alloca、cast、聚合与向量操作等 | Alloca 检查数组大小和对齐，聚合 insertvalue/extractvalue 检查索引，其余走相应 opcode 或通用匹配。左侧附件随克隆 | 是 | 对共享指令统一取 IR flags 和 metadata 的共同保证 |
| Br、switch、ret 及其他共享终结指令 | CFG、目标块和条件另行修复，克隆可带入左侧的 !prof、!llvm.loop 和调试位置 | 是 | 丢弃无法在变换后的共享指令上解释的附件 |
| PHI、未配对指令及重新分开的出口分支 | 各自保有原指令的克隆，合并过程不产生共同 SSA 定义 | 不适用 | 在各自发射路径保留原属性 |

B2B Anchor 的分段发射和 split 前共享发射都克隆左指令。算术与 intrinsic 配对要求原始 subclass optional data 相等，算术和 intrinsic 还要求无语义 metadata。普通 load/store 要求非调试附件完全相等。现有发射没有显式调用 `andIRFlags`，但匹配使既有 flags 和 load/store 语义 metadata 两侧一致。调试位置未比较，结果可能继承单侧位置。在发布起点没有 `--merge-metadata` 入口。实验提交 `974cbe1` 曾在该显式模式下允许不同的访存附件并对共享指令求共同信息，其实现没有进入发布起点。

## 实现与单元测试

DARM 在共享克隆发射时调用 `Instruction::andIRFlags` 与 `combineMetadataForCSE`。由于左右原指令分处两个分支，metadata 合并以移动指令的模式执行。不同的调试位置清除。B2B Anchor 的分段和 split 前发射使用同一处理。对齐和候选匹配条件沿用原实现。

`decision-greedy`、显式 `fusion-search` 和独立 `pair-trial` 均接受 `--darm-legacy-flags`，在 DARM 与 Anchor 共享发射时沿用左侧克隆行为。显式 `darm-artifact` 仍使用原论文对照实现。

`check-darm-merge-flags.py` 在 fixed 和 legacy 下分别重放双臂显式 DARM 并校验原始 IR。共享 `add`、`shl` 删除单侧的 `nsw`、保留共有的 `nuw`。`lshr` 移除单侧 `exact`，`fadd` 移除单侧 `fast`，访存夹具移除来源不同的 TBAA 和 load 的单侧 `range`。旧模式验证同一配对保留左侧属性。测试已纳入 `tests/run-v1`。

## 离线完整 Greedy

从发布 manifest 的冻结输入分别完整重跑 legacy 和 fixed，采用发布版 LLVM12／LLVM24 工具链、throughput 和默认 Anchor B2B。各用例的两次 Greedy 使用同一个临时输出路径，完成后分别归档。最终 IR 比较忽略路径相关的 ModuleID 首行。两条链的最终 IR 均通过 LLVM verifier。16 个 legacy 最终 IR 都匹配冻结版，机器码哈希全部匹配冻结版。

| 用例 | 提交数 legacy → fixed | 提交产物 IR 有差异的步次 | 最终 IR | 二进制 |
| --- | ---: | --- | --- | --- |
| vllm | 224 → 224 | — | 相同 | 相同 |
| MapAiry | 29 → 29 | — | 相同 | 相同 |
| tigre | 6 → 6 | — | 相同 | 相同 |
| HLLD | 5 → 5 | 3、4、5 | 改变 | 相同 |
| NQU64 | 1 → 1 | — | 相同 | 相同 |
| MS32 | 1 → 1 | — | 相同 | 相同 |
| PCM32 | 17 → 17 | — | 相同 | 相同 |
| SRAD16 | 4 → 4 | — | 相同 | 相同 |
| SRAD32 | 4 → 4 | — | 相同 | 相同 |
| Landau | 20 → 20 | — | 相同 | 相同 |
| SW2D | 0 → 0 | — | 相同 | 相同 |
| CED | 5 → 5 | — | 相同 | 相同 |
| TPACF | 12 → 12 | 1、2 | 相同 | 相同 |
| SRAD-stage2 | 2 → 2 | — | 相同 | 相同 |
| SasPoint5 | 8 → 8 | — | 相同 | 相同 |
| HiPIMS-George | 4 → 4 | — | 相同 | 相同 |

- **HLLD。** 第 3 步首次移除 `br i1 %569` 上的 `!fusion.logical.arm`，标记的内容为 `!{!"merged.bb88", !"merged.bb89"}`。第 4 步后对应分支为 `br i1 %531, label %merged.bb11, label %merged.bb9`。该附件是最终 IR 的唯一语义外差异，HSACO SHA-256 为 `3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3`。
- **TPACF。** 第 1 步的 `%106 = shl i32 %89, 3` 和 `%107 = shl i32 %merged.select, %106` 均移除左侧独有的 `nuw nsw`。第 2 步的临时 IR 仍有该表达式的 SSA 及指令位置差异。第 3 步收敛到相同的 IR，最终 HSACO SHA-256 为 `7b805ab747a196bae398d1df12d58ba34fb9f2f2dd4fbc29ec5b2c6daa408986`。

EPYC 明细目录为 `/data/home/chh/simplify-v2/build/darm-flags-fix.1WbCvz/build/release-new-old/`。每例保留双模式的运行日志、提交快照、最终 IR、机器码和 SHA-256。冻结归档按原哈希读取，重建产物写入新目录。

## GPU

14 个 HSACO 和 2 个 CUDA cubin 在 fixed 与 legacy 之间均逐字节一致。需走 A/A 和 12 轮正式 GPU 测量的变更集合为空。本轮报告二进制等价性，历史耗时只作背景。

TPACF 的 `ACFKernel` 新旧均报告 42 个 SGPR spill、0 个 VGPR spill。对应的不融合代码对象报告 36 个 SGPR spill、0 个 VGPR spill。发布存档的同批 Anchor／baseline 中位耗时比为 1.19971，该数据属于原发布测量。这次属性修复没有改变 TPACF 的机器码。

## 测试汇总

EPYC 上 `tools/build-v1`、`tools/build-decision-model` 以及独立 pair-trial 链接均通过。测试矩阵为 26 项通过和 4 项已知缺件跳过，与起点一致。26 项中的 `tests/run-v1` 包含新增的属性合并测试。独立 pair-trial 的纯计算和访存路径也通过 fixed／legacy 校验。
