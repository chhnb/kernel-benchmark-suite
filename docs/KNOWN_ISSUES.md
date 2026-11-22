# 已知问题与优先级

本文先保留 2026-11-10 的问题快照，再列出本次发布的有效问题。

## 2026-11-10 问题快照

| 优先级 | 问题 | 当前证据/影响 | 下一步与完成标准 |
|---|---|---|---|
| P0 | 仓库无法仅靠Git重建 | 无remote；cases仅8个跟踪文件；工具链、源码、数据和路径依赖本机其他项目 | 先列必需文件和依赖清单，纳入源码/补丁/生成器，写fetch/verify；在隔离目录完成重建后再称可复现 |
| P0 | Hypersonic有未定因GPU访问异常 | 旧runner一次fault；隔离输入进程协议通过；当前是指定L1+L2多锚点结果 | 定位原runner生命周期/内存问题，重复执行原协议并验证；不能把selector修正当作已经修复fault |
| P1 | 静态总成本会选错候选 | Map-Airy全函数成本4419比4428低，却慢5.19%；新边界已恢复旧二进制 | 候选边界和评分分开研究；补单边额外工作、共享收益与实际输入的对照，先做小批校准，不直接加任意罚分 |
| P1 | 判别值边界是保守近似 | 默认仅支持同SSA常量比较；复合条件需opt-in；未恢复任意源码树 | 建立可审计的决策/叶子身份与归属；明确未知状态，覆盖合并后重绑定；保留当前安全默认 |
| P1 | case间搜索/cleanup不统一 | vLLM逐组相邻、Map/TIGRE structural、Hyp指定区域；cleanup配置各异 | 统一策略manifest，显式记录枚举/cleanup/预算/对照；不要硬把不同语义的策略合成一个隐藏默认 |
| P1 | 原生DARM同批对照未覆盖全套 | TIGRE/Map可靠；vLLM随机、Hyp no-JT等缺统一新起点对照 | 同baseline、同最终后端、同输入、同批计时；异常退出与不融合分开 |
| P1 | 算法贡献尚未分离 | 匹配修复、候选扩展、评分、清理同时变化 | 固定候选/引擎比较评分；固定计划比较匹配器；单独清理消融 |
| P1 | 基线身份不够统一 | vLLM HIP依赖保留IR和历史软件移植；Fluid native runtime与LLVM12 IR不应混用 | 每case提供可重建源→IR链及hash；无法从原始源码独立重建的明确标移植/遗留输入 |
| P1 | 源码模块与历史试验混放 | fusion_search.cpp包含枚举、清理、分派、特殊路径、循环；tools有多个旧入口 | 先建立稳定接口和测试，再分文件迁移，逐步保证二进制或行为等价 |
| P1 | 文档/manifest状态会漂移 | 旧README宣称10个active含Landau、STATUS宣称尚无融合；case.enabled仍是历史 | 新导航已整理；下一步统一case registry，区分研究重点/基线验收/搜索/性能回归状态 |
| P2 | 工具链与设备路径硬编码 | CMake及脚本依赖/home/chh、/opt/rocm、多个外部项目；公共CPU包装器已移到tools，旧路径兼容保留 | 配置化路径并统一构建/准入入口；配额锁逻辑不复制多份 |
| P2 | 通用paired codegen仅AMD | postopt_compile_pair.py明确拒绝非AMD；Cholla/HLLC有CUDA路径 | 增加明确CUDA后端实现与测试，不能仅复用AMD参数 |
| P2 | IR/trial数据膨胀 | experiments约8.2GB、work约2.5GB、build约2.3GB；很多拒绝trial保留全IR | 支持摘要默认、选中/失败诊断按需保留；先确认再生链和依赖后清理 |
| P2 | 统计与回归范围有限 | 2%是工程门槛非显著性检验；Map连续分块慢；SRAD部分批次波动 | 保留输入敏感反例、原始样本、漂移信息，不只发布成功case |

### 2026-11-10 各 case 的待补项

- vLLM：随机数据日常回归已完成；仍是HIP软件移植，补原始DARM同批对照与完整source→baseline复现。
- Map-Airy：本次默认边界修复后混合回归24.64 μs通过；连续分块退化仍存在，跨层级收益评分尚未解决。
- TIGRE：已有收益回归与原始DARM对照；仍需分离匹配增强与评分贡献，不是“融合次数越多越好”。
- Hypersonic：多锚点指定区域+92静态收益、既有约4.8%实测；原runner异常、完整自动搜索和no-JT native对照待补。
- SRAD两阶段：当前0融合是有效结果；没有稳定新融合收益，不人为强制提交凑成功case。
- HLLC：23个有效候选均负的最新prepared baseline，对应GPU比较尚未完成。
- Cholla/Reentry：当前复杂结构/副作用支持范围有限，尚无新路径已确认GPU收益。

## 历史 NQU64 uniform-wave 回归

- NQU64 的 DP2 第 3 次融合属于同一类问题。该次 B2B 的总 TTI 从 275 降至 270，GPU 耗时却增加 4.46%，原本单侧的两条运算扩展到整个到达分支的活动 lane。历史分析可用 `git show 5959ee1:regression/records/nqu-dp2-analysis-20261115.md` 查阅。

## 已解决但仍保留证据

Map-Airy新增完整叶子候选改变第9步造成5.19%回退；`4ac5a90`加入默认判别值边界后恢复冻结二进制并实测通过。没有改TTI权重，也没有覆盖reference。该修复不代表TTI已能可靠评价所有跨层级融合。

vLLM/Map-Airy输入已改为运行时生成；随机输入不纳入Git。旧Qwen归档保留历史。原生DARM匹配器不足与我们新增wrapper/逻辑追踪bug的归属，见项目状态文档。


## Anchor 默认版本的性能与测量状态

| 问题 | 现象 | 定位 | 原因 | 后续计划 |
| --- | --- | --- | --- | --- |
| HLLD · `pending-regression` | 相对不融合慢约 7%–15%。历史 DP1 约 7%，anchor 独立进程约 9%，进程内逐状态批次约 15% | 第 3 次带复制的 R2B 是主要台阶，第 4 次 R2B 再增加约 3.5% | 第 3 次提交的两侧 uniform gain 为 −133／−29，受影响的单侧波前增加工作量 | 用稳健接受规则限制单侧波前损失 |
| Landau coherent | anchor 比 DP1 慢 4.4%，比不融合慢约 2%–6%。这是发布第二层门槛的唯一例外 | 第 17 次 R2R | 两侧 uniform gain 为 −63／−59，逐状态计时在同一步出现退化 | 用稳健接受规则约束单侧退化 |
| TPACF | anchor 比不融合慢约 20%，DP1 慢约 27% | 第 2、3 次 B2B | 条件合并后，SGPR spill 槽从 34 增至 52，`v_readlane` 从 34 条增至 276 条 | 用编译期 spill 信息做静态提交检查 |
| SRAD32 stage1 冻结件 | baseline 也无法启动 | 冻结 code object 的工作组上限为 256，kernel 需要 1,024 线程 | 冻结时的构建参数设置有误，与融合策略无关。仅调整 launch 上限的诊断构建已通过 baseline 和 anchor 的五路 CPU 参考校验 | 用正确的 launch 上限另建冻结版本，保留旧版本 |
| SasPoint5、SRAD stage2 1024 | 完整输出通过，性能不可判定 | 两种候选计时方式的 A/A 对照均未达到 case 的稳定性要求 | 同一二进制也会出现轮间波动，硬件层原因尚未确认 | 保留 A/A 原始数据，后续用通过稳定性门槛的方式复测 |
| SRAD16 stage1 | 完整输出通过，计时不稳定 | 报告批次的 anchor/baseline 跨度为 54.84% | 批次轮间波动较大，根因尚未确认 | 发布只报告正确性，后续用通过稳定性门槛的方式复测 |

实测和输入对应关系见 [anchor 留出记录](../regression/records/b2b-anchor-heldout-20261120.md)。

逐状态计时、提交及机器码证据见[区域融合审计](../regression/records/region-fusion-audit-20261120.md)。

SRAD32 的冻结件和诊断构建见[重建核验记录](../regression/records/anchor-release-rebuild-20261120.md)。

## Anchor B2B 一致代价 gate 的性能取舍

- TIGRE 的 6c R 配置比旧默认 D 慢约 0.6%。分支依赖运行时数据，线性布局的两侧 uniform gain 为 +1 和 +9，满足当前 gate。 [6c 记录](../regression/records/anchor-unified-dp-step6c-20261122.md)
- 对无法证明必然发散的分支，发布候选要求两侧 uniform gain 均有报价且非负。按 6c 冻结输入，这放弃了 Map-Airy mixed 约 6.7%、Landau mixed 约 19.6% 和 SasPoint5 interval-mixture 约 6.5% 的线性布局收益，同时避免了 Landau coherent 约 30% 和 SasPoint5 coherent/uniform 约 17%–21% 的退化。这个取舍针对跨输入稳定性。 [6c 的逐输入比较](../regression/records/anchor-unified-dp-step6c-20261122.md)

## SasPoint5：B2B 路径依赖

默认 Anchor 去掉多余的条件 `freeze` 后，冻结 IR 上的 B2B 轨迹从第二次提交开始重排，末次线性提交消失。提交数由 8 变为 7，最终 TTI 由 487 升至 491，与冻结的旧默认 D 持平。复现旧 D 时请构建 `c7dded07`。interval-mixture 和 coherent-blocks 的第 7f 步同批计时持平，uniform-01 的 CUDA Graph 补测时比为 1.00033 [1.00017, 1.00035]。 [第 7f 步](../regression/records/pcm32-freeze-removal-20261122.md) · [第 9 步](../regression/records/anchor-r2r-speculation-release-20261122.md)

## PCM32：完整搜索相对 Auto DARM 的差距已解决

`48fb41e` 固定 v1 默认时关闭了 R2R 的 gap 推测和布局重试。恢复受限推测后，Anchor B2B 多出的条件 `freeze` 仍使下游 R2R 保留额外的守护。第 7f 步恢复受限推测并加入当时的逐 wave gate，同时从默认 Anchor 发射移除多余的条件 `freeze`。PCM32 的 `trial-33` 以同父 1138 → 1136 被接受。新 HSACO 与第 7d 步实测对象逐字节相同，较上一发布默认快 6.83%，相对 Auto DARM 的时比为 0.99999 [0.99997, 1.00001]。 [发射二分](../regression/records/pcm32-r2r-emission-bisect-20261122.md) · [第 7f 步](../regression/records/pcm32-freeze-removal-20261122.md)

### 历史 TTI 漏判记录

第 10 步的同父 R2R 在 LLVM12 O3 后的 throughput TTI 增加 124，实测耗时下降 **5.74%**。发布 Greedy 的 `trial-33` 增加 202，实测耗时下降 **5.71%**。两者使用各自的父状态作对照。 [第 10 步计时（`617b52a`）](https://github.com/chhnb/kernel-benchmark-suite/blob/617b52a/regression/records/cleanup-extended-20261120.md) · [O3 报价和运行时计数（`90c819b`）](https://github.com/chhnb/kernel-benchmark-suite/blob/90c819b/regression/records/pcm32-r2r-runtime-20261120.md) · [trial-33（`81bbd4a`）](https://github.com/chhnb/kernel-benchmark-suite/blob/81bbd4a/regression/records/accept-rule-eval-20261121.md)

第 10 步两侧均需 64 KiB LDS，每 CU 只能驻留一个 workgroup。融合减少内层循环中的 LDS 工作量，运行时采样记录了 LDS 指令和 bank-conflict 总计数下降。该例的 throughput 报价把 LDS load/store 与普通 VALU 操作同样按单位报价，按静态指令累加时也没有给热循环更高权重。 [LDS 驻留与离线布局（`c89b380`）](https://github.com/chhnb/kernel-benchmark-suite/blob/c89b380/regression/records/region-anchor-20261120.md) · [运行时计数（`90c819b`）](https://github.com/chhnb/kernel-benchmark-suite/blob/90c819b/regression/records/pcm32-r2r-runtime-20261120.md)

| 已尝试的修正 | 结果 | 记录与提交 |
| --- | --- | --- |
| 全局 load 和 LDS load 分别按 4、2 报价 | 第 10 步重新报价仍判亏 | [实验实现 `f1dfd7f`](https://github.com/chhnb/kernel-benchmark-suite/commit/f1dfd7f)，[运行时记录 `90c819b`](https://github.com/chhnb/kernel-benchmark-suite/blob/90c819b/regression/records/pcm32-r2r-runtime-20261120.md) |
| gfx906 微基准访存权重 | 缩小 PCM32 的预测差距，方向仍判错，历史集方向一致率未提高 | [成本模型记录 `09778be`](https://github.com/chhnb/kernel-benchmark-suite/blob/09778be/regression/records/cost-model-eval-20261120.md) |
| latency／throughput 切换 | latency 缩小了第 10 步的亏损报价，结论仍是拒绝 | [occupancy-aware-cost `c43d1b7`](https://github.com/chhnb/kernel-benchmark-suite/blob/c43d1b7/regression/records/occupancy-aware-cost-20261120.md)，[区域融合 latency 回放 `c89b380`](https://github.com/chhnb/kernel-benchmark-suite/blob/c89b380/regression/records/region-anchor-20261120.md) |
| Occupancy 感知选择 | 低驻留时统一改用 latency 的启发式未提高历史转移的方向一致率。RIRv2 在该 PCM32 实例上接受，完整前瞻评估停于 NQU64 的 A/A 门槛 | [occupancy-aware-cost `c43d1b7`](https://github.com/chhnb/kernel-benchmark-suite/blob/c43d1b7/regression/records/occupancy-aware-cost-20261120.md)，[逐规则评估 `81bbd4a`](https://github.com/chhnb/kernel-benchmark-suite/blob/81bbd4a/regression/records/accept-rule-eval-20261121.md) |
| 区域 anchor | 同父对照未达到推广门槛，区域融合保留 DARM | [区域对齐结论 `2c112f0`](https://github.com/chhnb/kernel-benchmark-suite/blob/2c112f0/regression/records/region-anchor-parity-20261121.md) |

第 7 步的旧 D 与旧 R 在五档同父 cleanup 下都拒绝了 `trial-33`。全局加强 cleanup 使 NQU64 慢 9.4%。发布候选沿用原 cleanup 和 throughput TTI。 [第 7 步记录](../regression/records/pcm32-cleanup-strength-20261122.md)

## Auto DARM 对照口径

- MS32 的发布版／原版 Auto DARM 耗时比为 1.020，配对 bootstrap 95% 区间为 [1.010, 1.027]。区间跨过 1.02。 [最终复验记录](../regression/records/final-rerun-20261121.md#gpu-复验)
- vLLM 的 Auto DARM 对照使用无区域复制版本。上游固定阈值 0.2 的原版命令在首个区域复制处超时，360 秒内未产出完整 IR。 [最终复验记录](../regression/records/final-rerun-20261121.md#gpu-复验)

## 上游 DARM 的非确定性

上游 CFMelder 排查出五处依赖地址的遍历。实测的首个分歧来自块对齐的 `DenseMap` 顺序和复制 CFG 的接边顺序。其余三处是建块工作列表、PHI 工作列表和支配边界，在本批中未触发。artifact 的补丁按插入顺序或函数内块次序遍历，保持上游源码原样。

100 次正常 ASLR 重放中，补丁对象在 TPACF 出现 9 次、LUD8 出现 100 次，在 MapAiry、HLLD、Landau 各出现 0 次。11 个通过 A/A 的冻结输入完成同批全输出校验，10 个输入的补丁版位于已测原版耗时范围内。HLLD 补丁版中位数 95.360 μs，快于最快已测原版的 95.680 μs，对 DARM 有利。SRAD-stage2/1024 的 HIP Graph A/A 比值为 1.00134，跨度 3.45%，未可靠计时。该输入已从 artifact 计时清单移除，SRAD-stage2/256 与历史回执继续保留。

artifact 用补丁版对象做确定性重建。对外 Anchor / DARM 一律使用相对最快已测原版的时比，记录同时列出相对补丁版的时比。冻结发布历史继续保留。 [14a 扩样、时比与 manifest](../regression/records/artifact-14a-20261122.md)

## 上游 branch fusion 在 vLLM 上生成非法 IR

原版 BF 在 vLLM 的 `cache_eval` 生成 verifier 拒绝的 IR，涉及 PHI 前驱数及操作数支配性。原版静态工具、pristine 插件及仅改变遍历顺序的插件均复现。artifact 清单登记为不可用，`kbs build --variant bf --case vllm` 输出原因并退出 3，全量验收列为带脚注的例外。

## 已修复：DARM R2B 试融的非确定性

HLLD 的 `B9:B22:B12`、`B9:B21:B12` 和 `B9:B23:B12` 在同一父 IR 上曾出现两种 cleanup 后 IR，throughput TTI 相差 1。三个候选均未获选。提交 `b2008bd` 修复了普查发现的三处地址相关顺序。

- `RegionReplicator::replicateCFG` 按块指针 `DenseMap` 的桶顺序接边，使 `concretizeBranchConditions` 的最终分支选择随地址变化。现在按 CFG 发现顺序接边。HLLD 的三个候选各重放 20 次，raw IR、cleanup 后 IR 和评分均只有一种形态。
- `decision::normalize` 按地址排序出口块，使 raw IR 的前驱注释顺序不稳定。现在按两臂的 CFG 发现顺序去重。
- 区域融合预检按 `std::set<BasicBlock *>` 的指针顺序扫描，导致首条拒绝详情随地址变化。现在按父函数的块顺序检查。

历史分布见 [6c 重放记录](../regression/records/anchor-unified-dp-step6c-20261122.md#附录-hlld-地址随机化)。全量普查和修复后的严格比较见 [第 11 步记录](../regression/records/darm-determinism-fix-20261122.md)。

## 数据相关分支的保守政策

依赖运行时数据的条件缺少静态证据来判断 wave 内是否一致。线性布局、守护布局和 R2R 推测目前要求两侧一致代价的收益都非负，缺少报价时拒绝。这一政策放弃了 MapAiry、Landau mixed 和 SasPoint5 interval-mixture 等冻结输入上的部分收益，此类分支上可能慢于采用激进合并的 Auto DARM。计划在在线 PGO 提供运行时的一致性频率后再评估放宽。 [一致代价政策评估](../regression/records/anchor-unified-dp-step6c-20261122.md)

## SRAD16/32 的线程号合并

分支条件 `tid.y == 0` 只有首个 wave 混合。当前线程号规则按普通吞吐 TTI 接受额外的线性合并，两案的 TTI 都从 445 降到 436。冻结输入上的耗时分别增加 0.74%（SRAD16）和 0.31%（SRAD32）。 [第 12 步 GPU 实测](../regression/records/thread-pattern-optimism-20261122.md)
