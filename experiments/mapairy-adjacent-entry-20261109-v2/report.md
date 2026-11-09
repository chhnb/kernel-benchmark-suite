# 多分支相邻叶子入口重构与递归融合修复

2026-11-09。修复位于 /home/chh/kernel-benchmark-suite/tools/fusion_search.cpp，LLVM12变换、LLVM24 TTI评分。未改原始artifacts DARM仓库，也未修改评分权重。

## 修复前后
原来选择L4/L5时，以共同split整侧路径判断类型，L5不是右侧必经块，于是把后续L5～L11扩大为B2R复制范围。
现在在structural模式下，对符合条件的相邻单入口叶子先把入口链改成局部diamond，再调用原有RegionMelder：
- 共同入口先判断是否进入两叶的并集。
- diamond内仍保留原始叶子选择条件。
- 未选中的后续分支链保留。
- 第二入口只移动经过投机安全检查的无内存、无调用纯指令；所有操作数必须已可用。
- 并集条件用select(choose_left, true, hit_right)，而不是无条件or，避免原本未执行的右侧条件poison污染左侧路径。
- 更新后续PHI的前驱，重建DT/PDT/RegionInfo后才调用DARM，不复用失效分析。

融合组通过fusion.logical.arm元数据保存原始成员。多块结果以G编号作为完整逻辑区域参与下一轮枚举，范围包括canonical RegionInfo可能漏掉的内部汇合后计算。G编号依赖当轮IR，成员标签负责跨轮说明，不能把G编号当永久ID。

两个同构多块组继续融合前，各自建立局部出口及对应PHI，再交给R2R。直接把两个组共同的全局出口当成两个Region出口会触发DARM空PHI问题，此次已在调用侧规避。

## 实测三步
基于与前次相同的suite原始post.ll，未额外预先O3。每次trial使用scoped-cfg，最终各版本统一LLVM12 O3/llc gfx906/link。

| 步骤 | 变换路径 | 区域复制 | TTI前→后 | 本步静态收益 |
|---|---|---|---:|---:|
| L4+L5 | darm-adjacent-B2B | 否 | 6402→6641 | −239 |
| L6+L7（在上一步之后） | darm-adjacent-B2B | 否 | 6641→6880 | −239 |
| L45+L67 | darm-adjacent-R2R | 否 | 6880→7227 | −347 |

第三步由正常enumerate产生的evaluate:B96:G96:G98候选执行，不是绕开候选枚举手工改IR。三步均验证模块合法，最终输出正确。这是指定三步的强制诊断，负分候选未被伪装成自动贪心提交。

| 累计版本 | 混合输入 μs | 连续分块 μs |
|---|---:|---:|
| baseline | 49.440 | 16.000 |
| L45 | 46.720 | 16.160 |
| L45、L67 | 44.000 | 16.160 |
| L4567 | 41.120 | 16.800 |

三步混合输入累计耗时降低16.83%，连续分块增加5.00%。每批各版本轮换，3批×每批3预热+15测量，C++ HIP event，每个输入取三批中位数的中位数。全部四版本、两组65539个固定下尾输入的完整输出检查通过。表格不是全树优胜方案，也不包括完整应用速度。

混合输入逐批中位数：
baseline 49.600/49.440/49.440；
L45 46.720/46.720/46.880；
L45+L67 44.000/44.160/44.000；
L4567 40.960/41.120/41.120 μs。
本轮支持“这些强制融合在混合输入上有收益”，不能据此证明当前负分评分合理。当前正分准则仍会拒绝这些步骤，未宣称完整自动贪心重现历史最优树。

## 回归与检查
- 新adjacent_entry测试：60组可执行输出比较，含整型阈值边界、后续分支、第二条件overflow poison在第一路径被屏蔽；拒绝不安全sdiv入口投机；父模块不变；LLVM verifier。
- 既有hybrid、guard-pairs、scoped-cfg回归通过。
- vLLM完整32组、224次融合重跑：搜索摘要相同、GPU二进制字节相同；IR文件路径/ModuleID造成文本差异。没有声称改动后再次测量vLLM GPU性能。
- TIGRE重跑：2次融合，IR除ModuleID外相同、GPU二进制字节相同。
- Map-Airy三个阶段分别通过真实GPU全输出校验和计时。
- Python仅用于编排/汇总；变换、评分入口、回归驱动为C++，GPU计时沿用C++ runner。

## 支持边界
本次已验证非循环、直接相邻、同一出口的Block+Block，以及入口可安全重构、拓扑同构的多块Group+Group。循环入口、不可安全提前计算的条件、非相邻路径、异构多块图仍受现有约束；没有宣称任意Block+Region、任意清理后状态都已通用支持。G区域在每轮重新核对CFG支配关系，不单凭标签信任范围。未做全suite其它case的GPU回归。

## 复现与证据
musa正式目录 /home/chh/kernel-benchmark-suite/experiments/mapairy-adjacent-entry-20261109-v2/：
replay.cpp/run.sh 为三步C++指定回放；steps-final/ 保存各步raw/state IR与steps.tsv；compile.py及pair-*/manifest.json保存统一编译；measure.py、measure/、summary.json保存完整校验、哈希、CSV、三批计时。
调用沿用 --structural 1 --adjacent-only 0；这次没有新增手动开关。
tests/postopt/build_adjacent_entry.sh 是新可执行回归入口，依赖先构建tools/build-llvm24-tti。

先前v1目录使用历史手动驱动额外预先O3，保留用于调试，不参与这里的6402起点和性能表；其中一次计时因准入收集器在扫描时遇到新进程而提前停止，未拿不完整结果作结论。正式v2完整运行成功。

冻结回归证据分别位于experiments/vllm-adjacent-entry-regression-20261109-v1/和tigre-adjacent-entry-regression-20261109-v1/。源代码改动及摘要提交到suite；原始逐候选IR和大型二进制保留在musa实验目录。
