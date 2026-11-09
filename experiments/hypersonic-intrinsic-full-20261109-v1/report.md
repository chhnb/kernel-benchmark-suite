# Hypersonic 新匹配器复测与 O0 结构对照

2026-11-09，融合实现 5d82263（随后 8d342e3 仅保存 Map-Airy 实验）。完整 face_kernel，不抽取 face_decide，不改源程序。

## O2 完整 IR 的新实现复测

使用同一份 results/hypersonic-hip-llvm12-ir-v1/start.ll；LLVM24 TTI、structural=1、adjacent-only=0、maxRounds=256、maxTrials=100000。

- scoped-local：提交 1 次、46 次 trial，收益 +4。
- scoped-cfg：提交 1 次、44 次 trial，收益 +23。
- 两者都是 face_kernel:B51:B53:B52（if.end169.i.i 与 if.then140.i.i），随后 no_positive_candidate。
- 两者最终 GPU binary 均与上一轮同模式字节一致，新增 Map-Airy intrinsic 匹配没有改变此 case。
- 原始 artifacts DARM 的失败记录来自上一轮，没有重复运行或伪造新的失败证据。

同批 gfx906 完整输出检查通过；两个快照，每版 3 预热、15 测量，3 批轮换，C++ HIP event：

| 版本 | 快照1 μs | 快照24 μs |
|---|---:|---:|
| 共同 LLVM12 baseline | 1807.682 | 1808.002 |
| 新实现（两清理模式二进制相同） | 1805.442 | 1804.162 |

差异约 0.12%/0.21%，且二进制与旧实现一致，不把它解释成这次修复的新收益。相同二进制仅测一次。一次启动前拒绝后入口有界重试成功，保留收据。

## 为什么四叶无法直接对应

源程序本来就有：两边无效时写四个零通量并 return；不是 O3 创造了提前退出。现有 baseline 的确由 LLVM12 clang -O2 编译，另有 amdgpu-early-inline-all=true、amdgpu-function-calls=false。neighbor_or_wall 内联后含边界分支；O2 又整理短路条件与 CFG。没有逐 pass 消融，不能把每个改变归给某个确定 pass。

当前 O2：叶0是 B6 单块；叶1涉及边界专用 B8、内部 B9～B11 与共享尾 B12，不能把 R3（B9～B11，出口 B12）当作完整叶1；叶2是 B14～B18 的 R4；叶3是 B19 的四个 store 并跳到函数 cleanup。有效状态进入 B20 继续 HLLC，inactive 不经过 B20。因此外层共同后支配点变成 B55，默认作用域会扩展到通量计算和最终写回。

显式测试（邻近可表示单元，不冒充已经恢复完整语义叶）：

| 候选 | 结果 |
|---|---|
| B5:B6:R3 | mixed_granularity_not_supported |
| B13:R4:B19 | mixed_granularity_not_supported |
| B5:B6:B12 | side_effect_in_trial_scope_not_supported |
| B7:R3:R4 | side_effect_in_trial_scope_not_supported |

注意原生 DARM B2R 的“从两块扩展上下文”与 API 直接选择 Block+Region 并不是一回事：当前直接混合粒度检查仍会拒绝。

## 实际生成 O0 对照

复用原始 command.json、同源文件与 LLVM12、gfx906、同 bitcode 库和早期内联配置；将 -O2 改为 -O0，去掉显式 vectorize 开关，保留 disable-O0-optnone。额外生成 always-inline + mem2reg，以及 always-inline + sroa + mem2reg 两份 IR。没有 SimplifyCFG、完整 O2/O3。所有 IR 经过读取/验证；未将 O0 版本用于 GPU 性能比较，也未声称 O0 搜索已经跑通。

| face_kernel 统计 | 原 O2 | O0 | O0+mem2reg | O0+SROA+mem2reg |
|---|---:|---:|---:|---:|
| 基本块 | 56 | 467 | 467 | 467 |
| 条件 br | 31 | 170 | 170 | 170 |
| alloca | 0 | 1392 | 1216 | 0 |
| load | 47 | 3068 | 3068 | 96 |
| store | 8 | 2372 | 2372 | 8 |

O0 已按原有 AMD 配置进行早期内联，所以不是保留全部源码调用的原始前端 IR。裸 mem2reg 不足以去掉聚合结构与指针转换造成的栈对象；SROA 后全部消失，并保持上述 CFG 统计不变。

低优化 IR 的四路 if 顺序更接近源码。按照每个叶子的自然出口识别：

| 叶 | 入口 | 自然出口 | 块数 |
|---|---|---|---:|
| 0 | B8 if.then21 | B74 if.end52 | 1 |
| 1 | B10 if.then29 | B73 if.end51 | 30 |
| 2 | B41 if.then39 | B72 if.end50 | 30 |
| 3 | B71 if.else47 | B466 return | 1 |

这些自然叶子体各自是单入口；但出口仍不一致。叶1和叶2在 B73 共享 PHI，再与叶0在 B74 汇合；叶3直接退出。不能把叶1/2机械延长到 B74 并声称仍是独立单入口 Region，因为会包含共享汇合块。相应诊断保存在 logical-leaf-boundaries.json（延长至公共有效路径 join）和 natural-leaf-boundaries.json（自然边界）。

结论：O0+SROA+mem2reg 可以作为保留结构的搜索输入候选，明显比裸 O0 干净；但仅改编译等级不能解决异构叶子、共享 PHI/出口、inactive 提前写回的表示问题。旧 helper 路线通过 active 标志把分类输出统一，在内联前完成融合；这与直接完整 IR 的形态确实不同。未修改当前生产 baseline 或放宽内存副作用保护。

## 文件

本目录保存 prepare.py、probe.py、build_o0.py、命令、inventory.json、显式拒绝记录、搜索 raw/cleaned IR、scoped-*-pair GPU binary、measure 计时/验证收据、summary.json、o0/ 全部对照 IR 和 commands.json、o0-comparison.json。CPU 入口日志分别在 region-fusion-lab/work/hypersonic-intrinsic-full-20261109-v1、hypersonic-intrinsic-probes-20261109-v1、hypersonic-o0-shape-20261109-v1。
