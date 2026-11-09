# 仓库现状、case 收益与 DARM 路线整理

核对日期：2026-11-10。融合实现核对到 `09ad779`；实验记录分别注明版本，不能理解为该提交已对所有 case 完成 GPU 回归。

## 1. 仓库与远程

当前项目在 musa：`/home/chh/kernel-benchmark-suite`。已有本地 Git 提交，`git remote -v` 为空：**尚未配置远程，也没有推送**。

原始 DARM 对照是独立 checkout：`/home/chh/darm-artifacts-repro/upstream/code`，提交 `e9bc0540325ad9806313d34e84fc901496fd8be6`；本次检查工作区干净。我们的搜索程序编译的是 suite 内 `tools/darm_pair_engine/` 的修改副本，不是直接改动原始 artifacts 对照。

Git 目前主要覆盖工具、测试和部分文档/实验记录，不是整个目录的完整备份。许多既有 case 目录和构建产物仍未跟踪。新增远程前应区分源代码、生成规则、结果摘要与可再生数据；不能把整个工作目录直接全部加入 Git。本轮没有创建远程仓库或推送。

## 2. 哪些 case 跑过，收益如何

当前关注 8 个程序；SRAD 分成两个 kernel，合计 9 个 kernel 条目。Landau、CuDAFLOW、Saspoint5、SW2D 不再作为当前重点；HiPIMS–George 按用户要求跳过。以下数据均为单 kernel，不是完整应用端到端加速。

| Case | 新实现验证范围 | 相对共同 baseline | 原始 artifacts DARM 对照 | 回归定位 |
|---|---|---|---|---|
| vLLM Quant | HIP 软件 cache_eval；32 棵八叶树逐棵做相邻贪心，224 次融合 | 历史真实 Qwen64K 六层合计 18.083373→13.056489 ms，耗时减少 **27.80%** | 这组冻结记录不是与原始完整 DARM 的同批对照；不能用旧“DARM评分 greedy”冒充 native pass | **收益回归**；日常输入改为生成的随机 BF16 64K/128K |
| TIGRE Siddon | 完整 kernel，自动贪心 2 次，最终 1 处纹理采样 | 6.690241→3.088162 ms，减少 **53.84%** | 同批原始 DARM 3.905280 ms；新实现比它减少 **20.92%** | **收益回归**；已有冻结 head64/50 projections 基准 |
| Map-Airy | 完整 evaluate，16 次提交、1337 次 trial，停止于 no_positive_candidate | 混合输入 49.600→24.640 μs，减少 **50.32%**；连续分块 16.000→19.040 μs，**慢19%** | 混合输入 DARM 32.960 μs，新实现减少25.24%；分块输入 DARM18.400 μs，新实现慢3.48% | **混合输入收益回归**；分块输入保留为输入敏感的反例，不声称所有输入获益 |
| Hypersonic | 最新为共同 no-JumpThreading baseline 上指定 L1＋L2，试融合内部选择4对锚点；不是完整贪心收敛 | 独立进程协议下 1808.642/1808.962→1720.802/1721.921 μs，减少 **4.86%/4.81%**；比旧单锚点再快约1% | 较早普通 O2 baseline 上 native DARM 触发 dominance-order 断言；**最新 no-JT baseline 尚无同批 native 对照** | **实验性收益/结构回归**；原 runner 曾发生一次未定因 GPU 访问错误，暂不升为无条件性能门槛 |
| SRAD stage1 | 完整 srad_cuda_1；新贪心两种局部清理均0提交，与 baseline 二进制相同 | 无已确认新增收益；baseline 1024²/256² 为101.760/23.680 μs | DARM112.480/23.840 μs，1024²慢10.53% | **不退化/不误融合回归**；强制候选约1.1%的改善不稳定，不能标优胜 |
| SRAD stage2 | 完整 srad_cuda_2；新贪心0提交，与 baseline 二进制相同 | 没有确认稳定收益；1024²跨批波动大 | DARM融合2次；复测204.961→215.360 μs，256²21.280→21.760 μs | **正确性/不误融合回归**；不使用初测强制候选20.6%的单轮改善作收益声明 |
| HiPIMS–HLLC | 共同展开 pow 后，23个有效且已评分候选全负，0提交；与 prepared baseline 二进制相同 | **最新 GPU 验收未完成**，当时在执行前被准入拒绝 | 原始DARM生成6次融合的二进制，但本轮未完成GPU对照 | **静态/分派覆盖回归，性能待验收** |
| Cholla–HLLD | 已做 LLVM24 成本审计与候选试验；记录中的相邻候选被副作用范围检查拒绝 | **没有这条新融合路径的已确认 GPU 收益** | 不从其他旧路线移植性能结论 | **识别/合法性覆盖回归**，不是“实测差” |
| Reentry | LLVM24 已给46989条 baseline 指令定价；宽泛枚举10040个候选，早期相邻识别未覆盖复杂结构 | **没有当前路径的已确认 GPU 收益** | 不能把预算停止/无候选等同于 native DARM 的性能结果 | **大IR/结构覆盖回归**，不能说不存在合法合并 |

表中的绝对数值来自各自同批实验，不应跨不同 baseline、输入形状、编译流水线直接相除。vLLM 的原始 CUDA NVFP4 路线不等于当前 HIP 软件移植版。Hypersonic 较早普通 O2 IR 上完整贪心仅约0.04%～0.07%的差异，没有确认收益；不能把最新指定区域结果写成旧自动贪心结果。

## 3. 日常回归怎样标记

按本次用户要求：

- vLLM：固定种子随机生成 BF16，64K 与128K tokens、8 KV heads、head_dim128、page16；保留跳过/打乱的 slots、量化边界值和零值。C++生成输入及精确字节参考输出。真实 Qwen 数据仅作为历史证据，不是日常回归依赖。
- Map-Airy：混合输入列入收益回归。C++生成65539个值，使用原12个下尾区间锚点，固定种子打乱，long-double Boost oracle。新的打乱顺序不与旧 NumPy 输入字节相同，因此必须建立新的同批记录，不能直接套用24.640 μs作为硬阈值。
- TIGRE：沿用已有冻结数据基准。本次没有要求把 TIGRE 的 phantom 改成随机数据。
- 输入在运行目录临时生成，成功后删除；保留生成器版本、种子、参数、文件SHA、正确性收据和CSV。**不把生成的输入、输出参考或 GPU 二进制加入 Git。**小型 reference/baseline 二进制留在本机只读快照，通过 Git 中的 manifest 管理。
- 先检查完整输出，再同批测 reference/candidate。默认每个输入上比冻结 reference 慢超过2%即回归失败；这只是工程门槛，不是显著性检验。若二进制完全相同，明确记录别名，不伪造两组独立样本。
- SRAD的0融合、不支持区域的拒绝、intrinsic限制和父状态不可变等也需要回归；回归集合不应只留下“能加速”的案例。

已有真实 Qwen/TIGRE 大快照保留为历史归档，不自动覆盖或删除。新的 vLLM/Map-Airy 日常快照不包含输入文件。登记见 `regression/case-status-20261110.json`；入口见 `regression/README.md`。本轮实际回归结果附在本文末尾。

## 4. 我们相对原生 DARM 在做什么

最初目标基本正确，但更准确的说法是：**以 DARM 为融合引擎，枚举当前 IR 上受支持的区域对，通过试融合后的静态成本增量选择合并；同时补齐多路分支表示、操作匹配和融合代码生成的支持范围。**

这已经不只是“换分数、换顺序”，因为部分新候选和匹配能力原版没有，vLLM还使用专门的 local-computation/local-union 路径。

当前主要路径：

~~~text
当前父 IR S
  → 枚举候选 B2B / R2R / B2R（按具体模式和结构限制）
  → 对每个候选克隆 S
  → 使用选定引擎试融合，包含 DARM 必要内部处理
  → 运行同一配置的局部清理
  → LLVM24 TTI 查询 control 与候选的成本
  → 选合法、可评分且正分最高的候选提交
  → 在新 IR 上重新枚举；合并组可在支持范围内继续合并
~~~

这是**逐轮贪心**，不是把所有融合顺序、所有合法树都枚举完；默认不回溯，也不保证全局最优。旧 beam/backtracking 实验的存在不代表当前这条配置已经启用它们。vLLM 回归策略逐棵处理32个决策组，在每棵内部比较相邻候选；Map-Airy/TIGRE 使用 structural 通用枚举，不是严格相邻专用模式。最新 Hypersonic 的多锚点方案则打包在一次固定候选 trial 内。

### 当前 LLVM24 分数

~~~text
B = cleanup(S)                       // 同父状态，不融合的 control
A = cleanup(trial_fuse(S, pair))     // 同样的清理配置
C(F) = Σ TTI24.getInstructionCost(I, TCK_RecipThroughput)
score = [C(B) - C(A)] / max(C(B), 1)
~~~

成本统计范围是目标函数中入口可达的指令，不是动态执行路径。使用真实 LLVM24 worker，固定 revision `6be16f356d3e`，读取目标 triple、GPU target-cpu（例如gfx906/sm_70）、target-features；LLVM12仍负责变换与最终代码生成。不是把 LLVM24 的几项权重抄进 LLVM12。

未知成本拒绝评分，不按零处理；普通未知函数的 call TTI不能代表完整 callee。未校准寄存器压力、spill、依赖链、实际分歧比例、路径概率和GPU周期。Map-Airy 混合输入快、连续分块慢，正好说明静态总成本不能代替动态SIMT执行成本。

代码细节：`LLVM24Scorer` 当前把 `parentGain` 字段设为同一个 control gain，不能把该字段描述为另做一次独立的 S−A 查询。`--scorer legacy` 是旧指令权重下的总成本评分，也**不等于原生 DARM 的相似度策略**。内层 BB/指令对齐仍使用 DARM 的相似度/序列匹配，不是已经全部换成TTI最优匹配。

搜索中的局部清理与最终 codegen O3是两个阶段：vLLM冻结策略用none；TIGRE用scoped-local；Map-Airy用scoped-cfg；新Hypersonic用scoped-cfg-triangles。不能把这些结果都称为“每次融合后O3”。

## 5. 发现了哪些不足，分别属于谁

| 发现 | 归属和含义 | 已做的处理 |
|---|---|---|
| floor、copysign、amdgcn.rcp、image.sample 等操作不能按目标例子共享 | 原匹配器支持范围不够；不是这些操作在语义上天然不能融合 | 加入兼容性检查、immarg/属性/收敛性限制；不兼容调用仍保留各自条件。TIGRE由3处采样到1处，原始融合IR中已实现 |
| 顺序保持对齐遇到两侧独立计算顺序相反 | 对齐算法本身的限制，不是错误代码；同一算法在不同布局上可获得不同匹配 | Hypersonic必经load依赖链前移＋多锚点试融合；仍非通用偏序对齐 |
| native DARM Region列表要求 dominance chain，Hypersonic触发断言 | 原始 artifacts 的结构支持边界 | 保留失败对照，自己的路径做明确拒绝或受控转换；不能把失败当作baseline |
| complete-leaf 首版只选一对锚点 | **我们新增 wrapper 的限制**，不能说原生DARM所有情形都只能配一对 | 当前可在一次trial内融合多对受保护B2B锚点 |
| 相邻关系曾误判、融合后label追踪不完整、纯B2B误发给local引擎 | **我们的枚举、状态和分派问题** | 稳定逻辑标签、递归组合和支持范围分派修复；旧被撤回的相邻性记录不能当正确性证据 |
| 未匹配段产生多个条件保护区，互补段未形成紧凑if–else | 融合代码生成存在可改进的开销；不等于全部保护都能删 | gap归并、互补保护、局部短整数三角清理；有副作用或不可安全执行的段继续保护 |
| LLVM O2/O3使叶子从SESE变为多入口 | 编译流水线改变CFG，不是DARM相似度打分本身的问题 | 定位JumpThreading，提供不含该pass的共同baseline；必须让对照也使用相同准备 |
| 左右分支来源映射连续写入Left表 | 上游副本中的具体实现错误 | 修正Right表映射，并保持原始artifacts对照不变 |

因此可以说“发现并修复了 DARM 在这些 GPU case 上的若干匹配与代码生成不足”；但不能把我们的单锚点限制、邻接识别bug和LLVM优化造成的CFG变化都归罪于原生DARM。

## 6. 如何与原生 DARM 公平比较

每个case固定源码、输入、设备和**同一个准备后的 baseline IR**，至少比较：

1. 不融合 baseline。
2. 未修改的 artifacts 自动 DARM（固定提交、阈值、原生遍历和相似度规则）。
3. 当前新引擎＋当前搜索/TTI评分策略。

三者最终使用相同编译流程和参数，进行完整输出检查，再轮换顺序用GPU event计时。报告融合次数、停止原因、输入身份和版本。异常退出、无候选、全部静态负分、GPU未启动，必须分别记录。

如果要解释“究竟是匹配修复、搜索顺序还是TTI带来收益”，还需要消融：在固定引擎和候选集合时比较相似度策略与TTI策略；在固定计划和清理时比较原匹配器与补全匹配器；另外单独比较清理。**这套分离贡献的完整实验矩阵目前尚未全部完成**，不能把TIGRE/Map-Airy的所有提升都归因于评分器。

原生策略对照必须真正调用原策略，不能拿 `--scorer legacy` 或历史“DARM评分greedy”代替。当前已有可靠的同批 native 对照包括TIGRE和Map-Airy；vLLM新随机输入、Hypersonic新no-JT baseline等应补齐相同起点的native对照。

## 7. 主要证据位置

全部位于 `/home/chh/kernel-benchmark-suite/`：

- `regression/README.md`、`regression/golden/*/manifest.json`：回归配置、冻结身份与规则。
- `experiments/qwen64k-all32-greedy-20261108-v1/summary.json`：真实KV历史收益，不是新随机输入的计时。
- `docs/tigre-intrinsic-matching.md`、`experiments/tigre-intrinsic-match-20261109-v1/summary.json`。
- `experiments/mapairy-full-convergence-20261109-v1/report.md` 与 `summary.json`。
- `experiments/hypersonic-multi-anchor-20261109-v1/report.md`、`reviewed.json`，包含未解决的运行异常。
- `experiments/srad-greedy-20261109-v1/report.md`、`experiments/srad-stage2-greedy-20261109-v2/report.md`。
- `experiments/hipims-hllc-greedy-20261109-v3/report.md`。
- `docs/llvm24-focus-nine-status.md` 和带撤回说明的 `docs/llvm24-adjacent-v1-results.md`：仅用于确认对应历史审计范围，不将静态结果当GPU收益。
- `tools/fusion_search.cpp`、`tools/llvm24_scorer.h`、`tools/darm_pair_engine/InstructionMatch.cpp`、`RegionMelder.cpp`：实际实现。

## 8. 本轮生成输入回归（2026-11-10）

C++ 随机输入生成器两次相同种子生成结果逐字节一致；64-token 小样本的四份量化参考输出与既有独立 NumPy oracle 完全一致。日常生成器和 GPU runner 均为 C++，这项交叉检查不参与 GPU 计时。

本轮重新用当前融合实现生成候选。vLLM完成224次融合，与冻结 reference 的 GPU 二进制 SHA 相同；因此明确复用其测量作为 candidate，而非声称测出了两份独立版本之间的0%差异。Map-Airy完成16次融合，但二进制与旧 reference 不同，需要独立测量。

| 输入 | baseline | 当前候选 | 耗时降低 | 回归状态 |
|---|---:|---:|---:|---|
| vLLM 随机64K | 2.896800 ms | 2.144480 ms | 25.97% | 完整输出通过，二进制与冻结版本相同 |
| vLLM 随机128K | 5.748159 ms | 4.183999 ms | 27.21% | 完整输出通过，二进制与冻结版本相同 |

计时为3批、各3次预热＋15次测量的批中位数再取中位数。64K融合版本三批中位数为2.109440、2.144480、2.149120 ms，不能把单个绝对时间当作无噪声常数。随机输入的参考文件和输入在成功后删除。

首次启动因遗漏现有ROCm库路径而在设备初始化失败，尚未执行kernel；补齐与旧runner一致的环境后完成以上验收，失败运行记录保留用于解释。本轮证据位于 `regression/runs/20261110-vllm-generated-v2/summary.json` 与 `generation.json`。

### Map-Airy 捕获到性能回退

本次当前代码重新搜索仍提交16次，但 trial 数从历史1337变为1561，最终二进制也不同。混合输入完整正确性通过；三批候选中位数均为25.920 μs，冻结版本为24.640、24.799、24.640 μs。综合结果：

| baseline | 冻结 reference | 当前候选 | 候选相对 reference | 候选相对 baseline |
|---:|---:|---:|---:|---:|
| 49.440 μs | 24.640 μs | 25.920 μs | **慢5.19%，回归失败** | 耗时减少47.57% |

该结果说明仍有显著收益，但不能判为“没有退化”。2%门槛正常拦截了当前版本，**不更新冻结 reference**。本轮没有为了通过测试而调整融合算法或放宽门槛；尚未定位具体是哪项匹配/清理变更改变了最终代码，需要后续做固定融合计划和源码提交间的对比。不能仅凭16次融合数量相同就认为IR相同，也不能现在归因于TTI权重。

证据：`regression/runs/20261110-mapairy-generated/summary.json`，`regression/runs/20261110-current-generated/mapairy-search/result.json` 和 `code-regression.json`。冻结 reference 保存于新的无输入小快照，其SHA未改变。


后续定位已完成：新增完整SESE候选改变第9次选择；仅排除此类候选、保留当前其余实现，即恢复与冻结版本逐字节一致的二进制。详见 `mapairy-regression-cause-20261110.md`，替代前述“尚未定位”的当时状态。

后续修复已通过：默认完整叶子候选加入判别值边界，Map-Airy恢复冻结二进制并实测24.640 μs；vLLM二进制保持相同，Hypersonic显式开启后保持4对锚点/+92收益。详见 `complete-leaf-decision-boundary.md`。旧失败记录保留。
