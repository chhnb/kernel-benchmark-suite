# PCM32 的分支条件 freeze 与 R2R 推测（第 7f 步）

## 分支条件语义核对

LLVM 12 的 `br` 语义和LLVM 24.0.0git 开发版 LangRef 均规定：条件为 poison 或 undef 时，执行条件跳转为未定义行为。两版的 `br` 条文均为 “If ‘`cond`’ is `poison` or `undef`, this instruction has undefined behavior.” 以下只讨论原程序有定义的动态执行。在原 split 块内新用途插入在旧 terminator 之前，因此这里的证明是原程序到达插入点后会执行同一个 terminator；该 terminator 并未在该点前执行。进入原后继块的对应路径已执行原 br。 [LLVM 12 LangRef](https://releases.llvm.org/12.0.0/docs/LangRef.html#br-instruction) · [LLVM 24 LangRef](https://llvm.org/docs/LangRef.html#br-instruction)

| 位置 | 原条件在该位置的用途 | 执行范围与结论 |
| --- | --- | --- |
| `emitB2BLinear` 提前与共享指令 | `moveGap` 提前移动的无副作用指令不新增条件使用；`select` 选择配对操作数 | 插在原 split terminator 处，或在前一个守护汇合后的 continuation |
| 部分守护 | `emitGuards` 在每侧插入条件跳转，未执行的一侧给 carrier PHI 的 incoming 为 poison | 首个跳转在原 split，后续跳转与 carrier PHI 都只从该 split 可达；值仍只由正确一侧的 select 观察 |
| 整段守护 | `emitGuards` 用单个 if/else，或单侧有内容时用 if/then | 同上，守护块与 continuation 无额外前驱 |
| before-split 前缀 | 共享操作数 select 和保留下来的分支 | 插在原 terminator 前，残余分支仍使用原条件 |
| merged-exit、线性退出 | 用 select 替换两个匹配臂对 join PHI 的 incoming | 选择发生在 split 或只由 split 可达的 continuation，再给 join 增加该前驱；join 中其他前驱不会执行它 |
| 相邻叶入口 | `AdjacentLeafEntry::apply` 的 `leaf.enter = select(Choose, true, Other)` 与 `leaf.union` 的 `br Choose` | `Choose` 为第一条原分支条件或其取反；`leaf.union` 只从第一分支改写后的入口到达。第二条原分支只在原相应边观测，`select` 保留此遮蔽，未将 `Other` 改成无条件选择器 |
| R2R 共享指令与内部 terminator | `RegionMelder::setOperends` 的操作数选择，以及内部 br/switch 条件选择 | 匹配区域只能从原 split 的两条对应边进入；新选择在合并区域内。未选侧的内部条件仍被 select 遮蔽 |
| R2R 区域退出与 gap | `setOperendsForBr` 的退出分派、`runUnpredicationPass` 的单侧／互补 guard、用 carrier PHI 消解的 select | 在原区域的合并块、它拆出的 guard 与继续块内；没有来自 split 外的新入口 |
| R2R 入口合并 | `mergeOutsideDefsAtEntry` 在 `unify.bb` 建条件跳转 | 只接收原匹配区域外部进入边；候选检查保证这些边位于原 split 的对应臂内。相邻叶用上述 `Choose` |
| R2R 草案取消部分整数 gap 的守护 | `planGaps` 的原位执行不会新增条件使用；现有侧局部用途及退出 select 约束仍有效 | 原有 `freeze` 指令保留为一次 SSA 定义，只允许和其他安全整数指令一样原位执行；无跨侧替换、复制、删除或放宽访存约束 |

在新默认的 Anchor 条件用途中，未找到必须保留发射器额外插入的 `freeze` 的位置。Legacy 对照照原逻辑插入。B 只放宽 R2R 的整数 gap 白名单，原有 `freeze` 指令和其确定性语义照常保留。

## 构建与复现

起点为 `study/pcm32-path-divergence` 的 `b4d1dcf181badeb3e1760e16fbfb20977ea5e8f6`，包含 R2R 草案 `87c7d8378ebe813bda4081212b8bf58da6a259c8`。发布对照为 `3cf44a132f0b069577ad40ce2523bbb31aad46ff`。静态复验用发布 manifest 的全部 16 个冻结 case 和 LUD8 的共同输入，均校验输入哈希，传入实际 workgroup 形状，逐个运行 LLVM12 verifier。评分仍用固定 LLVM24 throughput 和发布 cleanup。

A 只在默认 Anchor 发射关闭额外的条件 freeze。B 只把整数 `Freeze` 纳入 `isCheapIntegerGapInstruction` 白名单，仍调用 `safeToExecuteUnconditionally`，保留原有的侧内使用、跨侧依赖及内存约束。组合 A+B 包含两项改动。三种草案配置都在同一套代码中按布局给 R2R 试融应用与 B2B 相同的一致代价 gate。只有实际移除整数 gap 守护时才检查 gate，使用原父 IR 上产生该选择器的条件。相邻叶若选择器来自更内层的第一条分支，侧向报价和分类一起改用该条件。gate 拒绝后重发射同候选的普通 R2R，仍按完整 TTI 比较，失败和成功的报价分别落盘。Legacy 关闭草案 R2R 推测并沿用原先的 freeze 发射。

在 A 和 B 两个对照构建中分别用局部补丁关闭另一项。首次构建在嵌套 Git 目录里跳过了补丁，验收发现三份搜索二进制哈希相同。该批结果作废。第二次用 `patch -p1` 在新目录应用补丁，核对了各版本搜索二进制。构建用相同的 Greedy driver 和报价 worker。

```sh
bash step7f-build.sh "$PWD" A
bash step7f-build.sh "$PWD" B
bash step7f-build.sh "$PWD" AB
python3 step7f-matrix.py "$PWD"
python3 step7f-pcm.py "$PWD"
python3 step7f-lud.py "$PWD"
python3 step7f-finalize.py "$PWD"
python3 step7f-gpu.py "$PWD"
bash test-anchor-step1.sh "$PWD/AB" step7f
```

`step7f-matrix.py` 调用 `decision-greedy INPUT FUNCTION TOOL_ROOT active --anchor-wave-shape X,Y,Z`，legacy 另加 `--anchor-mode legacy`。发布结果沿用合并后已验证的静态回执并重编译设备对象。LUD8 的最终设备对象用第 8 步专用编译流程，统一 LLVM `opt -O3 -verify-each` 与 `llc -O2`。其他 case 按发布设备对象编译配置。所有脚本和 IR 均保存在 EPYC 的实验目录 `/data/home/chh/simplify-v2/build/pcm32-freeze-removal.wxfN4n`。

| 工具 | SHA-256 |
| --- | --- |
| 发布搜索二进制 | `1e7eb3d975edbcfbc74954798ec29380b5f6c8ce209fc5398b1bd1ef210cdf54` |
| A 搜索二进制 | `04041d48dc59e2c32acded09bdb75b71d5730e7dc645aaf7d9d6d491cc03041c` |
| B 搜索二进制 | `1fb91cbd17b9bb92cb4bd1ae7e687d46d0bc7475d3c5c43f1cf5f8e8521dc0a8` |
| A+B 搜索二进制 | `a1c5635eeac95f37a8e3f9c15d3fa52ab33d00ef6b5224c6ca4ec1f3d3096e86` |
| 发布 Greedy | `cd0077ce173f8c165360070f3e2f2127aa2956b2f8d056633be49cb20991080b` |
| 草案 Greedy | `16a28c9e51a20b776b43786fc04b2dca8b103f3af69a2cf6227b8f513ede4a9a` |
| LLVM24 TTI worker | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |

## PCM32

冻结输入 IR SHA-256 为 `db3b35287f1ef284e3c8dac514b05fc952a6892345b5ff0077b2840927aaab47`，实际形状 32×1×1。对每种配置取各自原生轨迹中第 1–7 次提交的父 IR，在完全相同的块对上另发射 DARM B2B，并用 LLVM12 `llvm-diff` 对比 cleanup 后的 `_Z3pcmPi`。再在第 7e 步的固定父态独立重做一遍。两个比较口径的结论相同。

| 配置 | 第 1–7 次与同父 DARM 结构一致 | `trial-33` 同父对照 → 候选 | 侧向报价 false／true | gate／TTI | 完整 Greedy 提交数／TTI |
| --- | --- | ---: | ---: | --- | ---: |
| 发布 | 0/7 | 1138 → 1340 | −252／−242 | 普通 R2R，拒绝 | 17／1138 |
| A | 7/7 | 1138 → 1136 | −123／−107 | must-diverge 豁免，接受 | 18／1136 |
| B | 0/7 | 1138 → 1208 | −195／−149 | must-diverge 豁免，拒绝 | 17／1138 |
| A+B | 7/7 | 1138 → 1136 | −123／−107 | must-diverge 豁免，接受 | 18／1136 |

`trial-33` 的条件为 `tid.x < 31 && (tid.x & 1) == 0`，唯一活动 wave 内 16 lane 走每侧。省略形状的负对照在 A 的同一父 IR 上重放。分类变为 `unknown`，原本 TTI 1136 的推测候选因 `negative_uniform_gain` 被拒绝，退回普通 R2R 的 1263，仍不提交。CED 的一次真实请求也验证了 fallback 能保留收益。其推测布局分类为 `mixed`（1/4 wave 混合），同父对照 349 → 307，两侧收益 +4／−3。经 gate 拒绝后，普通 R2R 仍以 349 → 309 被接受。

固定历史父 IR 的 `trial-138`、`trial-139` 仍分类为 `must-diverge`，三个草案配置均获豁免，报价分别为 1152 → 1150、1137 → 1135，两侧收益分别为 −123／−107、−119／−103。当前完整搜索接受的是 `trial-33`。第 7e 步的草案对照在带 freeze 的原 Anchor 父 IR 上为 1138 → 1216。B 在同样的父上把报价改善 8 点，仍不足以通过 TTI。

A 与 A+B 的 HSACO 都匹配第 7d 步已测量的 `5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816`，发布与 B 匹配 `a0a8df33ee604bc77519a3887af2c8663afa6c7f0cd609dd392d136a815ec116`。沿用第 7d 步同批完整校验数据，A／发布为 **0.93167 [0.93165, 0.93168]**，快 6.83%，相对 Auto DARM 为 **0.99999 [0.99997, 1.00001]**。 [第 7d 步 GPU 回执](pcm32-darm-b2b-reachability-20261122.md#pcm32-gpu-对比)

## 全量静态矩阵

| Case | 发布 提交／TTI·IR | A 提交／TTI·IR | B 提交／TTI·IR | A+B 提交／TTI·IR | A 的设备对象 SHA-256 对比 |
| --- | --- | --- | --- | --- | --- |
| PCM32 | 17／1138 · `09305dd6ce16` | 18／1136 · `debd97699989` | 17／1138 · `09305dd6ce16` | 18／1136 · `debd97699989` | `a0a8df33ee60` → `5ba36c22102c` |
| LUD8 | 2／637 · `ef1fa6fd26c9` | 2／628 · `387a564d46e1` | 2／637 · `ef1fa6fd26c9` | 2／628 · `387a564d46e1` | `e44e2051a062` → `15266ece5e83` |
| NQU64 | 2／274 · `383e6dfc7e11` | 2／274 · `383e6dfc7e11` | 2／274 · `383e6dfc7e11` | 2／274 · `383e6dfc7e11` | 同发布 |
| CED | 3／281 · `417664a60f8b` | 3／281 · `f068294bdff0` | 3／281 · `417664a60f8b` | 3／281 · `f068294bdff0` | 同发布 |
| HiPIMS-George | 5／5572 · `f22721c031b2` | 5／5572 · `f22721c031b2` | 5／5572 · `f22721c031b2` | 5／5572 · `f22721c031b2` | 同发布 |
| HLLD | 5／1696 · `0ef79f2ea967` | 5／1696 · `0ef79f2ea967` | 5／1696 · `0ef79f2ea967` | 5／1696 · `0ef79f2ea967` | 同发布 |
| Landau | 22／1635 · `0a776f835868` | 22／1635 · `31aea7ae5a00` | 22／1635 · `0a776f835868` | 22／1635 · `31aea7ae5a00` | 同发布 |
| MapAiry | 30／3997 · `25a2d3b39020` | 30／3997 · `109dae2f8e46` | 30／3997 · `25a2d3b39020` | 30／3997 · `109dae2f8e46` | 同发布 |
| MS32 | 2／198 · `f95ad2fe62d6` | 2／198 · `f95ad2fe62d6` | 2／198 · `f95ad2fe62d6` | 2／198 · `f95ad2fe62d6` | 同发布 |
| SasPoint5 | 8／487 · `cddeee0b711c` | 7／491 · `eefddfe2b88b` | 8／487 · `cddeee0b711c` | 7／491 · `eefddfe2b88b` | `c1e34623ec1e` → `9b8f297905ac` |
| SRAD-stage2 | 2／210 · `b80a9581d7c8` | 2／209 · `b1343cc5c72c` | 2／210 · `b80a9581d7c8` | 2／209 · `b1343cc5c72c` | `67e86ccd1567` → `37ed260bde0e` |
| SRAD16 | 3／446 · `84495226b219` | 3／445 · `29c33f08d366` | 3／446 · `84495226b219` | 3／445 · `29c33f08d366` | `4f105a815f93` → `ac992d49e046` |
| SRAD32 | 3／446 · `5f76db84cd39` | 3／445 · `675b5641e456` | 3／446 · `5f76db84cd39` | 3／445 · `675b5641e456` | `9dde8dbb0600` → `fe59dbc7dc4d` |
| SW2D | 1／1925 · `2c231580ab79` | 1／1925 · `2c231580ab79` | 1／1925 · `2c231580ab79` | 1／1925 · `2c231580ab79` | 同发布 |
| tigre | 5／944 · `5aea08d6b2a5` | 5／942 · `5605316b9f7b` | 5／944 · `5aea08d6b2a5` | 5／942 · `5605316b9f7b` | `687d2a0b1088` → `ffa327ddc018` |
| TPACF | 23／325 · `bc5b0ff9d9a5` | 23／325 · `bc5b0ff9d9a5` | 23／325 · `bc5b0ff9d9a5` | 23／325 · `bc5b0ff9d9a5` | 同发布 |
| vllm | 225／2619 · `186bc0f6e7fb` | 225／2619 · `186bc0f6e7fb` | 225／2619 · `186bc0f6e7fb` | 225／2619 · `186bc0f6e7fb` | 同发布 |

17 个 case 的 B 与发布最终 IR 和设备对象全部逐字节一致。A 与 A+B 的全部最终 IR、提交数、最终 TTI 和设备对象逐项相同。A 改变了 10 个 case 的 IR，其中 CED、Landau、MapAiry 的设备对象仍匹配发布，7 个 case 的设备对象改变。NQU64 的 2 次提交、TTI 274 与 HSACO 均匹配发布。`--anchor-mode legacy` 在全部 17 个 case 上与 `c7dded07` 的 D 回执逐字节一致，包括每次选中候选的编号、提交 IR 和 TTI。另逐个比对了 legacy 的 2,180 个 Anchor B2B 试融，候选发射与 TTI 报价一致。表中的哈希为前缀，完整值在 `matrix-final.json`。

LUD8 第一处仍是 linear，TTI 666；写回处仍为 guarded-linear，布局从 #5 换到 #8，最终 TTI 637 → 628，统一后端 O3 TTI 536 → 527。gfx906 ISA 指令数 520 → 513，VGPR 53 → 50，SGPR 16，`v_cndmask` 26 → 24，global load、LDS read/write 与条件跳转数不变。tigre 的末次线性提交位置相同，944 → 942。SRAD16/32 的末次线性提交位置相同，446 → 445。SRAD-stage2 的第二次提交由 segmented 变为 linear，210 → 209。SasPoint5 的 B2B 轨迹从第二次开始重排，发布末尾的线性提交没有出现在 A 轨迹，提交数由 8 变为 7，最终 TTI 487 → 491。

通用设备对象编译器读不到 LUD8 在 manifest 中的 `anchor_reference`，已完成的 17 个 case 的静态回执用于下一步汇总。LUD8 使用其专用构建，发布对照对象哈希与第 8 步相同。所有设备对象用 `step7f-finalize.py` 汇总。


## GPU 回归

设备对象逐字节相同的配置作为别名。A+B 与 A 共用测量，B 与发布同对象。每个输入用其第 8 步的冻结 fixture 和 runner，先验证 A/A 中位比在 1±1%，跨度 ≤3%。正式测量采用 12 个同批轮换窗口、完整输出校验和固定种子 20261121 的 10,000 次配对 bootstrap 95% 区间。表中的窗口次数为每角色取中位数前的独立样本数，“发布”表示沿用该输入的发布 runner 重复数。

LUD8 的第一个 A/A 使用原第 8 步 runner，写出的 279 个样本都通过输出校验。随后线程停在 1 GiB 的设备到 host 拷贝，调用栈和反汇编定位到 `hipMemcpy` 进入 ROCm/HSA ioctl。保留现场后结束该进程。重跑采用与 PCM32 第 7d 步相同的拷贝做法，计时区间外用显存原件恢复输入，再用 4 MiB pinned-host buffer 分块读回并逐字节比对 1 GiB 输出。设备、输入生成、冻结输出 checksum、kernel event 边界、窗口样本数与角色轮换一致。重跑重新执行 A/A，停滞批次未纳入统计。

| 冻结输入 | A（同 A+B）／发布时比与 95% 区间 | 每窗口样本数 |
| --- | ---: | ---: |
| PCM32 | 0.93167 [0.93165, 0.93168] | 31（第 7d 步） |
| LUD8/16384 | 1.00033 [0.99992, 1.00059] | 31 |
| tigre/head64 | 1.00075 [0.99791, 1.00163] | 发布 |
| SRAD-stage2/256 | 1.00000 [0.99580, 1.00421] | 31 |
| SRAD-stage2/1024 | 1.00181 [0.99186, 1.00720] | 31 |
| SRAD16/256 | 1.00000 [0.99293, 1.00000] | 31 |
| SRAD32/256 | 1.00000 [0.99301, 1.00704] | 31 |
| SasPoint5/interval-mixture | 1.00000 [1.00000, 1.00000] | 31 |
| SasPoint5/coherent-blocks | 1.00000 [1.00000, 1.00000] | 31 |
| SasPoint5/uniform-01 | A/A 超限，无法可靠计时 | — |

| 冻结输入 | A/A 每次读数（样本数／配对中位比／跨度） |
| --- | --- |
| LUD8/16384 | 31／1.00000／0.144% |
| tigre/head64 | 发布／0.99921／2.999% |
| SRAD-stage2/256 | 31／1.00000／2.571% |
| SRAD-stage2/1024 | 31／1.00153／1.955% |
| SRAD16/256 | 发布／1.01434／53.743%；发布／1.00352／58.950%；31／1.00000／2.153% |
| SRAD32/256 | 发布／1.00699／53.943%；发布／0.99306／49.495%；31／1.00000／1.408% |
| SasPoint5/interval-mixture | 发布／1.00000／4.972%；发布／0.99849／257.060%；31／1.00000／0.000% |
| SasPoint5/coherent-blocks | 31／1.00000／0.000% |
| SasPoint5/uniform-01 | 31／1.00000／3.961%；61／1.00000／3.959% |

所有通过 A/A 的新对象未观察到 95% 区间完全高于 1 的计时退化。
SasPoint5 的 uniform-01 没有正式 GPU 时比。

## 验证与回执

回归套件 16 项通过，`condition`、`pair-trial`、`regions`、`similarity` 按 `tests/KNOWN_FAILURES.md` 跳过。新增断言检查默认 guarded/linear 发射用原条件、原分支条件为 poison 或 undef 时发射仍使用原分支值、legacy 前缀保留 freeze、R2R gap 中 freeze 仍只有原 SSA 定义且其侧内使用遮蔽不变。现有 PHI 的未选边 poison、访存顺序、`opt -verify-each`、CPU 两侧全结果和内存比较继续通过。

| 回执 | SHA-256 |
| --- | --- |
| `matrix-final.json` | `621fd736cf89060434b321b130d69e28f0f1c8ca48aa1a1e6185199528507653` |
| `pcm.json` | `79802af0ce5d4c57c23632327cbbbae24f920cd856d1d01a01fea8db5d461903` |
| `tests.log` | `518e22f00321dd03c0932c0a9d01d817f71943e4ee8ab17cb1d444aaea61f388` |
| `legacy-chain.json` | `31eca2326ecc7b27ade5bfb017f7dbfac4640177f917bd7ed36a6db0b094440c` |
| `legacy-b2b.json` | `c911968fc46c5fc5ec331d650d345d11e6a62e5842c1ad152e1f92a43e1dc511` |
| `lud8-isa/results.json` | `a489566efe896c10988a513cb7efa2d7cf9f88e3c98ff8e0799b65b8525d4937` |
| `pcm/missing-shape/structural/trial-0/trial.json` | `2ee54cf62f0d510737cd1de85458b442013b1b8415276efef0b894a4165ab4d5` |
| `lud-aa-stack-final.log` | `9038f9b84fae79731a83bc9720f894fe19da520e2b304cda2524f196ede3cf23` |
| `gpu/LUD8-pageable-stall/aa-1.csv` | `4de71fde4d964e94d01447282a20e7ec3cb2dcd0d122f23f077c2a373c517ea5` |
| `lud-window-pinned` | `9b5a55442081524d9bc92b67bbb21dc2a56b1ee864653aa7c3fa30745f405e91` |
| `gpu/results.json` | `7bce4fe75baa2ec0bf4a685c97c1476b9eb728332f310ac4ca554e0ced2e9880` |
| `gpu/LUD8-16384/aa-1.csv` | `3ff1a6205d19dd6b7c99a64e1024af2353fcb6e374ba3ee17492133f74ed87ab` |
| `gpu/LUD8-16384/comparison.csv` | `a0179f66460654fa9c914695c61f44d1991ea5ed28a0b6a9f5ee1b26396afa1c` |
