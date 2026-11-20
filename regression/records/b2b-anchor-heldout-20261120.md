# Anchor V2+P 冻结、GPU 测量和 Landau 诊断

A 为 4a91a50 的 DP1 默认产物，N 为严格／宽松截断加段内 PHI 计价和空对齐的 anchor。
默认 B2B 为 DP1。

## 冻结前的通用核对与标签

97e54bc、a0bb841、da5593c 已在 origin。检查时 origin 已有指向 da5593c 的
`anchor-v2p-frozen`。在不强制移动该标签的前提下，标签仍指向报价修正之前的提交。
本轮的两个核对仅来自设计用例，发生于第一批留出结果已知以后。后续不使用留出结果
修改 anchor 的规则或参数。

- 根节点原来已计输出 **select** 代价。改为查与段内相同的 PHI 报价，store 起点仍为零。
  完整回放仍为 7 更好／262 相同／5 更差，570 次评分。274 次的胜出布局、TTI 和
  cleanup 哈希逐例相同。vLLM 第 1、7 次的 cleanup IR 均与 A 逐字节一致。
- SRAD16、SRAD32 第 3 次的三个 GEP 均为 c=1、PHI 报价 1。输入成本依次为 3、2、3，
  两变体的净值都是 −1、0、−1。严格全部截断，宽松只保留中间对。最终由严格布局胜出，
  TTI 458（A 为 451）。宽松候选的两个评分为 477 和 458，严格候选先发射。
- HLLD 第 2 次同父回放的 N/A TTI 分别为 1747／1745。anchor 的分段、前缀和
  merged-exit 操作数及出口 select 已经统一使用 `emitB2BSelect`。cleanup 后 N 的
  select 用 `%601 = or %599, %600` 并交换两个值，说明谓词极性处理已生效。
  外围 `leaf.enter` 还使用 `leaf.choose`，其 De Morgan 形式在 N 的无 freeze
  路径上留下另一条 or 和一条 xor。A 的 select 使用冻结后的 `leaf.choose`。
  因此未另改发射器。
- 断言放在 merged-exit 删除原分支前，检查两个臂只余终结指令。七个默认产物和九个
  anchor 最终 IR 分别与 A 以及既有 V2+P 冻结产物一致。三个回归用例只验证合法性并记录下表。

| 用例 | 实际行为 | cleanup TTI |
| --- | --- | ---: |
| 共享产生者 | 三对锚点，前缀发射，无冲突或丢弃 | 33 → 18 |
| 两条链顺序交叉 | LIS 保留两对，丢弃两对，分段发射 | 35 → 20 |
| LIS 丢父节点 | 保留两对、丢弃一对，候选仍可分段合法发射 | 36 → 19 |

## GPU 分布与地址诊断

每角色 20 个新进程，或者在一个进程中重新分配 20 次。每窗口预热 3 次、计时
50 次，报告窗口中位数。TIGRE 继续汇总六个子批次；V2+P 的 TIGRE 与 A 字节相同。
下表给出各观察带的中位数（µs）和出现比例。TIGRE 分界 3100 µs，SRAD 用
170、207、245 µs 分带，SRAD 的分布具有四个观察带。

| Case | 方法 | baseline | A | N |
| --- | --- | --- | --- | --- |
| TIGRE | 独立进程 | 6274.76（100%） | 2848.71（65%），3282.47（35%） | 2854.71（80%），3258.95（20%） |
| TIGRE | 重新分配 | 6264.24（100%） | 2843.84（100%） | 2842.96（100%） |
| SRAD1024 | 独立进程 | 157.32（10%），185.76（45%），225.68（25%），264.48（20%） | 160.00（10%），188.32（35%），225.08（20%），263.84（35%） | 160.96（5%），187.68（30%），225.20（50%），272.40（15%） |
| SRAD1024 | 重新分配 | 263.52（100%） | 228.32（100%） | 224.16（100%） |

记录设备分配基址，TIGRE 另记录纹理 backing。每个角色在新进程有 20 个不同的
完整地址向量，但对 4 KiB、64 KiB、2 MiB 取模后均只剩一组，跨快慢带仍相同。
同进程 20 次释放再申请时，分配器每次返回同一完整地址。进程内分布集中，可观测的
地址低位无法区分峰，完整地址与进程身份也没有解耦，因而无法确定地址是否有因果影响。
EPYC 频率 sysfs 仅 root 可写，当前用户无非交互 sudo，固定频率未测。
rocprof 能列出指标，进入 TIGRE A 和 SRAD 三个角色时均在建立计数器上下文时报
`Error: Context Create failed`（退出码 134），无可用的分峰计数器。

## 进程内方式的零假设检验

保留单代码对象模式。实验方式在同一进程加载三个代码对象，按轮内固定顺序交错，
每次发射恢复同一初值并做完整输出校验。

| 用例 | 轮数 | A/A 中位数 | 轮间跨度 | 零假设 |
| --- | ---: | ---: | ---: | --- |
| TIGRE | 12 | 0.99994 | 0.90% | 通过 |
| SRAD stage2 1024 | 12 | 0.99282 | 11.32% | 不通过 |

两个对照的输出均通过。SRAD 的 A/A 最小 0.91140，最大 1.01453，
超出 3% 的跨度上限。本轮在此停止 GPU，进程内方式没有用于性能判定。
冻结后的留出重测也没有启动，SasPoint5、HiPIMS-George 仍待测。原方式下 V2+P
的 TIGRE 是 A 的字节别名，SRAD 1024 的原方式结果为下表的不确定。两者均未
取得进程内性能判定。

## 已有留出结果（第一批，原有独立进程方式）

| 用例／输入 | N/A | bootstrap 95% | N/baseline | A/baseline | 判定 | 输入版本／种子 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Landau／mixed | 0.92322 | [0.91938, 0.92526] | 0.43045 | 0.46616 | 通过 | 归档 65539／2026110301 |
| Landau／coherent | 1.04426 | [1.03652, 1.08132] | 1.05970 | 1.01119 | 不通过 | 归档 65539／2026110301 |
| SW2D／258x259-synthetic | 1.00744 | [1.00619, 1.00808] | 1.00000 | 0.99200 | 通过 | synthetic-v1／2026111901 |
| CED／110-synthetic | 0.98490 | [0.97836, 0.99901] | 0.88775 | 0.91179 | 通过 | synthetic-v1／2026111901 |
| TPACF／16384-synthetic | 0.94792 | [0.94701, 0.94908] | 1.19971 | 1.26598 | 通过 | synthetic-v1／2026111901 |
| SRAD-stage2／256 | 0.99528 | [0.98122, 1.00943] | 1.00435 | 1.00435 | 通过 | synthetic-v1／2026111901 |
| SRAD-stage2／1024 | 1.13435 | [0.77853, 1.14370] | 1.16163 | 1.00817 | 不确定 | synthetic-v1／2026111901 |
| SasPoint5 | — | — | — | — | 未测 | synthetic-v1／20261106 |
| HiPIMS-George | — | — | — | — | 未测 | synthetic-v1／2026111901 |

## Landau coherent 诊断

第 1 次已分歧，A 和 N 的父 IR 及候选都是 `evaluate:B14:B13:B15`。
两臂是上尾近似的两个指数区间，位于原始输入 `p > 0.5` 的路径上。归一化分派
在 `icmp sgt i32 %21, -9` 处区分 `ilogb(1-p) >= -8` 及其后备臂。A 选 prefix-suffix，N 选有 144 对锚点的
严格分段布局。N 在这步的总 TTI 收益 263，A 为 239，差值全来自非 CFG 收益；
两方向 uniform gain 同为 −19。cleanup 后两边都有 49 块、21 个 PHI 和 44 个
select，N 少 13 条指令。首处分歧确实是布局选择。

两套冻结输入均小于 0.5，首处分歧的上尾两臂不会直接执行。
mixed 将相同的 12 个概率值重复，再用 Python `random.Random(2026110301)` 打乱，
已重建并核对二进制输入。coherent 将每个值连续排成
一段。按实际样本每 64 lane 切分（block256），coherent 的 1025 个 wave 中
1014 个只包含同一个概率，另 11 个含两个概率；mixed 没有单一概率的 wave，
975 个包含全部 12 个概率。概率均由原输入下尾分档决定，阈值包括 0.375、
0.25、0.125 和 `ilogb(p)` 的多个指数区间。因此 coherent 的绝大多数 wave
在同一个输入分档中；不同概率也可能落在相同分档。

N 的第 17 次 R2R（−63／−59）和第 2 次 B2B（−31／−27）有明显 uniform
损失。N 第 2 次也只改变上尾。N 第 3 次 B2B（−16／−16）和第 8 次 R2R
（−12／−12）改动了实际可达的下尾路径。A 也做了负 uniform 收益的下尾 R2R，
例如第 4 次（−12／−12）、第 8 次（−50／−13）。首个 B2B 的两方向损失完全相同。分歧后的块编号不可直接当作相同子树，
这些数据没有逐提交 GPU 消融，无法将 coherent 慢 4.4% 单独归因给某次提交、
某种配对或发射。Landau 的这些结果将用于后续设计，因此从现在起归入设计集，
不再作为留出用例。

### 两边分歧后的全部提交

以下为工作归档中实际保留的提交，破折号表示该布局未报告该项。

**A**

| 提交／轮次 | 候选 | 类型 | 布局 | total_tti_gain | non_cfg_work_gain | cfg_phi_gain | uniform_gain_false | uniform_gain_true |
| ---: | --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1／1 | evaluate:B14:B13:B15 | B2B | single-branch-prefix-suffix | 239 | 262 | -23 | -19 | -19 |
| 2／2 | evaluate:B31:B30:B32 | B2B | single-branch-prefix-suffix | 228 | 248 | -20 | -16 | -16 |
| 3／3 | evaluate:B35:B34:B36 | B2B | single-branch-prefix-suffix | 228 | 248 | -20 | -16 | -16 |
| 4／4 | evaluate:B33:R19:R20 | R2R | darm-R2R | 237 | 220 | 17 | -12 | -12 |
| 5／5 | evaluate:B33:B32:B34 | B2B | single-branch-prefix-suffix | 228 | 248 | -20 | -16 | -16 |
| 6／6 | evaluate:B31:R19:R21 | R2R | darm-R2R | 236 | 219 | 17 | -31 | -13 |
| 7／7 | evaluate:B33:B32:B34 | B2B | single-branch-prefix-suffix | 228 | 248 | -20 | -16 | -16 |
| 8／8 | evaluate:B31:R19:R22 | R2R | darm-R2R | 236 | 219 | 17 | -50 | -13 |
| 9／9 | evaluate:B18:B17:B19 | B2B | single-branch-prefix-suffix | 211 | 228 | -17 | -13 | -13 |
| 10／10 | evaluate:B16:R11:R12 | R2R | darm-R2R | 221 | 220 | 1 | -31 | -17 |
| 11／11 | evaluate:B6:B5:B7 | B2B | single-branch-segment-dp-2 | 67 | 56 | 11 | — | — |
| 12／12 | evaluate:B17:B16:B18 | B2B | single-branch-common-join-dp-3 | 48 | 56 | -8 | — | — |
| 13／13 | evaluate:B6:B5:B7 | B2B | single-branch-join-dp-3 | 20 | 28 | -8 | — | — |
| 14／15 | evaluate:B11:R9:R10 | R2R | darm-R2R | 57 | 50 | 7 | -20 | -12 |
| 15／16 | evaluate:B17:B18:B16 | B2B | single-branch-prefix | 5 | 1 | 4 | 3 | -1 |
| 16／17 | evaluate:B21:B31:B32 | B2B | single-branch-segment-dp-4 | 28 | 14 | 14 | 0 | 0 |
| 17／19 | evaluate:B29:B27:B28 | B2B | single-branch-prefix | 81 | 70 | 11 | -7 | -7 |
| 18／21 | evaluate:B32:B27:B28 | B2B | single-branch-join-dp | 70 | 84 | -14 | -14 | -18 |
| 19／24 | evaluate:B34:B35:B36 | B2B | single-branch-join-dp | 44 | 60 | -16 | -16 | -16 |
| 20／25 | evaluate:B8:B9:B12 | B2B | single-branch-suffix | 23 | 25 | -2 | 264 | -443 |
| 21／29 | evaluate:B6:B7:B5 | B2B | single-branch-segment-dp | 2 | 2 | 0 | -2 | -4 |
| 22／33 | evaluate:B5:B20:B21 | B2B | single-branch-segment-dp-10 | 1 | 1 | 0 | -1 | -2 |
| 23／37 | evaluate:B5:B20:B21 | B2B | single-branch-segment-dp-10 | 2 | 2 | 0 | -2 | -9 |
| 24／41 | evaluate:B5:B20:B21 | B2B | single-branch-segment-dp-2 | 3 | 3 | 0 | -1 | -2 |
| 25／45 | evaluate:B5:B20:B21 | B2B | single-branch-segment-dp-8 | 3 | 3 | 0 | -1 | -2 |
| 26／49 | evaluate:B5:B20:B21 | B2B | single-branch-segment-dp-8 | 2 | 2 | 0 | -2 | -3 |
| 27／53 | evaluate:B5:B20:B21 | B2B | single-branch-segment-dp-6 | 1 | 1 | 0 | -1 | -2 |
| 28／57 | evaluate:B5:B20:B21 | B2B | single-branch-common-dp | 1 | 1 | 0 | -1 | -1 |

**N**

| 提交／轮次 | 候选 | 类型 | 布局 | total_tti_gain | non_cfg_work_gain | cfg_phi_gain | uniform_gain_false | uniform_gain_true |
| ---: | --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1／1 | evaluate:B14:B13:B15 | B2B | b2b-anchor-1 | 263 | 286 | -23 | -19 | -19 |
| 2／2 | evaluate:B16:B15:B17 | B2B | b2b-anchor-1 | 255 | 274 | -19 | -31 | -27 |
| 3／3 | evaluate:B27:B26:B28 | B2B | b2b-anchor-1 | 252 | 272 | -20 | -16 | -16 |
| 4／4 | evaluate:B29:B28:B30 | B2B | b2b-anchor-1 | 252 | 272 | -20 | -16 | -16 |
| 5／5 | evaluate:B31:B30:B32 | B2B | b2b-anchor-1 | 252 | 272 | -20 | -16 | -16 |
| 6／6 | evaluate:B33:B32:B34 | B2B | b2b-anchor-1 | 252 | 272 | -20 | -16 | -16 |
| 7／7 | evaluate:B14:R11:R12 | R2R | darm-R2R | 189 | 172 | 17 | -15 | -11 |
| 8／8 | evaluate:B25:R18:R19 | R2R | darm-R2R | 189 | 172 | 17 | -12 | -12 |
| 9／9 | evaluate:B27:R21:R22 | R2R | darm-R2R | 189 | 172 | 17 | -12 | -12 |
| 10／10 | evaluate:B25:R19:R21 | R2R | darm-R2R | 253 | 217 | 36 | -4 | -4 |
| 11／11 | evaluate:B12:B11:B13 | B2B | b2b-anchor-1 | 154 | 162 | -8 | -1 | -7 |
| 12／12 | evaluate:B6:B5:B7 | B2B | b2b-anchor-1 | 68 | 57 | 11 | — | — |
| 13／13 | evaluate:B18:B17:B19 | B2B | b2b-anchor-1 | 66 | 55 | 11 | — | — |
| 14／14 | evaluate:B6:B5:B7 | B2B | b2b-anchor-1 | 16 | 57 | -41 | — | — |
| 15／15 | evaluate:B18:B15:B19 | B2B | b2b-anchor-1 | 18 | 24 | -6 | — | — |
| 16／17 | evaluate:B41:B42:B43 | B2B | b2b-anchor-1 | 105 | 94 | 11 | -7 | -7 |
| 17／21 | evaluate:B18:R17:R18 | R2R | darm-R2R | 130 | 171 | -41 | -63 | -59 |
| 18／25 | evaluate:B20:B22:B21 | B2B | b2b-anchor-2 | 1 | 1 | 0 | -1 | -2 |
| 19／30 | evaluate:B32:B33:B34 | B2B | b2b-anchor-1 | 110 | 99 | 11 | -16 | -32 |
| 20／35 | evaluate:B5:B19:B18 | B2B | b2b-anchor-2 | 1 | 1 | 0 | -1 | -2 |

EPYC 原始文件位于 `build/b2b-layouts/anchor-heldout/`，第一批留出计时位于
`build/b2b-layouts/anchor-ablation/heldout/`。

## 核验范围

PHI 报价和 merged-exit 断言各自通过七个默认用例和九个 anchor 用例的
完整产物核对。PHI 报价后九个设计用例的最终 IR 沿用先前二进制，没有触发
设计用例 GPU 重测。完整测试各 27 项通过，4 项按 KNOWN_FAILURES 跳过。
合并两个变更后，274 例回放的逐例结果仍然一致。TIGRE HIP runner 和通用 HIP／CUDA
runner 均已编译。新增方式只用于上文的诊断和零假设验证。

## 第二次冻结和留出测量收尾

`anchor-v2p-frozen-2` 已推送，指向 `905b308c5ee6d20fd613a62c9c12b70f77eb3a01`。
旧标签 `anchor-v2p-frozen` 仍指向 `da5593c`。相对旧标签，anchor 相关的
三项变化为根节点改用出口 PHI 报价、merged-exit 全配断言、三个行为观察用例。
区间内另有实验 runner 与记录提交。274 次同父回放和九个设计用例的最终 IR 均一致，
仍为 7／262／5，评分 570 次。默认 B2B 为 DP1。

以下五处 TTI 差距已接受，后续不为这些实例调整规则。

| 例 | 原因 |
| --- | --- |
| HLLD 第 2 次，1745 → 1747 | 无 freeze 的 merged-exit 让外围条件保留额外的布尔运算。 |
| Map-Airy 第 27 次，4301 → 4305 | 分段配对产生标量 PHI 和 extractelement，留下额外的双宽 fma。 |
| Map-Airy 第 30 次，4271 → 4281 | 分段布局比 A 的后缀下沉多保留分支和 select。 |
| SRAD16 第 3 次，451 → 458 | 严格布局截断三对 GEP，保留了分支和重复的地址计算。 |
| SRAD32 第 3 次，451 → 458 | 与 SRAD16 相同，GEP 截断后保留了分支和重复的地址计算。 |

### 第一批产物的 CPU 核验

在冻结提交上重跑完整 Greedy，A、N 复用原构建路径，再用原 LLVM 12 gfx906
管线编译 HSACO。Landau 两份输入共用一个搜索结果。下面按角色列出字节比较，
并把产物与第一批测量记录的角色哈希交叉核对。

| Case | A final.ll／HSACO | N final.ll／HSACO | baseline HSACO |
| --- | --- | --- | --- |
| Landau | 相同／相同 | 相同／相同 | 相同 |
| SW2D | 相同／相同 | 相同／相同 | 相同 |
| CED | 相同／相同 | 相同／相同 | 相同 |
| TPACF | 相同／相同 | 相同／相同 | 相同 |
| SRAD-stage2 | 相同／相同 | 相同／相同 | 相同 |

SasPoint5 和 HiPIMS-George 另以新标签完整重跑 N。最终 IR 和 sm_86 cubin 均与
原先准备的 N 逐字节一致，HiPIMS-George 正式测量使用的 N 哈希已交叉核对。

### 方式选择与 A/A

每个对照 12 轮，每轮预热 3 次、计时 15 次。中位数距 1 ≤1% 且
跨度 ≤3% 时才通过。SasPoint5 的三个输入共用一种方式，三个对照都达到门槛
才选用该方式。已核对字节的归档结果直接复用。TIGRE 沿用既有进程内 A/A 对照
0.99994、跨度 0.90%，N 与 A 为字节别名。

| Case／输入 | 方式 | A/A 中位数 | 跨度 | 通过 |
| --- | --- | ---: | ---: | --- |
| SRAD1024／1024 | 进程内 | 0.99282 | 11.32% | 否 |
| SRAD1024／1024 | 独立进程 | 0.92221 | 179.14% | 否 |
| SasPoint5／interval-mixture | 进程内 | 1.00000 | 2.80% | 是 |
| SasPoint5／coherent-blocks | 进程内 | 1.00000 | 4.40% | 否 |
| SasPoint5／uniform-01 | 进程内 | 1.00000 | 5.48% | 否 |
| SasPoint5／interval-mixture | 独立进程 | 0.99251 | 15.92% | 否 |
| SasPoint5／coherent-blocks | 独立进程 | 0.98077 | 4.82% | 否 |
| SasPoint5／uniform-01 | 独立进程 | 1.00000 | 4.99% | 否 |
| HiPIMS-George／128x128 | 进程内 | 0.99993 | 0.15% | 是 |

### 更新后的留出判定

归档 N/A 与基准比均为逐轮配对中位数。95% bootstrap 区间沿用 v3 固定规则。
Landau 仍列出历史对照，已划入设计集。SRAD 1024 的第一批不确定数据保留在
前表，下面仅显示本轮方式选择后的判定。

| Case／输入 | N/A | 95% 区间 | N/baseline | A/baseline | 方式 | 判定 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Landau／mixed | 0.92322 | [0.91938, 0.92526] | 0.43045 | 0.46616 | 独立进程，已用冻结版本核对 | 通过 |
| Landau／coherent | 1.04426 | [1.03652, 1.08132] | 1.05970 | 1.01119 | 独立进程，已用冻结版本核对 | 不通过 |
| SW2D／258x259-synthetic | 1.00744 | [1.00619, 1.00808] | 1.00000 | 0.99200 | 独立进程，已用冻结版本核对 | 通过 |
| CED／110-synthetic | 0.98490 | [0.97836, 0.99901] | 0.88775 | 0.91179 | 独立进程，已用冻结版本核对 | 通过 |
| TPACF／16384-synthetic | 0.94792 | [0.94701, 0.94908] | 1.19971 | 1.26598 | 独立进程，已用冻结版本核对 | 通过 |
| SRAD-stage2／256 | 0.99528 | [0.98122, 1.00943] | 1.00435 | 1.00435 | 独立进程，已用冻结版本核对 | 通过 |
| SRAD stage2／1024 | — | — | — | — | — | 无法测量，两种方式的 A/A 未通过 |
| SasPoint5／interval-mixture | — | — | — | — | — | 无法测量，两种方式的 A/A 未通过 |
| SasPoint5／coherent-blocks | — | — | — | — | — | 无法测量，两种方式的 A/A 未通过 |
| SasPoint5／uniform-01 | — | — | — | — | — | 无法测量，两种方式的 A/A 未通过 |
| HiPIMS-George／128x128 | 1.00002 | [1.00000, 1.00072] | 1.00000 | 0.99993 | 进程内 | 通过 |

原始数据与构建产物位于 EPYC 的 `build/b2b-layouts/anchor-heldout/frozen-2/`，
第一批的数据仍位于 `build/b2b-layouts/anchor-ablation/heldout/`。
