# DARM 区域融合的确定性修复

起点为发布线 `feature/anchor-default` 的 `f58687f49006391a2a1a079c1c50494b2a955fe8`，工作分支为 `fix/darm-determinism`，修复提交为 `b2008bd`。使用 EPYC 上冻结的 17 个 case、各 case 的发布 workgroup 形状、LLVM 12 结构工具与固定 LLVM 24 throughput 报价器。

## 普查方法

每个 case 的五个正常 ASLR 进程和一个 `setarch x86_64 -R` 进程使用同一发布二进制、输入和配置。每次使用不同的工作目录，命令中的输出目录始终为相对路径 `active`，避免 LLVM 将路径差异写入 ModuleID。候选按 case 和 Greedy 回执中的候选目录对齐，并校验父 IR SHA-256。结构试融比较 `after-raw.ll`、`after.ll`、候选输出、`score_result`、各布局评分和拒绝信息。仅归一化比较准备后的 IR、cleanup 后 IR 及 TTI 回执。计时字段不参与确定性比较；IR 按原始字节比较，包含 `; preds =` 注释。

```sh
DECISION_GREEDY_JOBS=8 "$TOOL_ROOT/build/decision-fuse/decision-greedy" \
  "$FROZEN_INPUT" "$FUNCTION" "$TOOL_ROOT" active \
  --anchor-wave-shape "$SHAPE" --ir-snapshots full
setarch x86_64 -R env DECISION_GREEDY_JOBS=8 \
  "$TOOL_ROOT/build/decision-fuse/decision-greedy" \
  "$FROZEN_INPUT" "$FUNCTION" "$TOOL_ROOT" active \
  --anchor-wave-shape "$SHAPE" --ir-snapshots full
```

| 构建 | `decision-greedy` SHA-256 | `fusion-search-llvm24` SHA-256 |
| --- | --- | --- |
| `f58687f` | `a8510256193e4af5d1a1701a19cc76f9691709f998b439aa041ef092fe9a71b1` | `15b81849e13d502b52bf4deab50e6c7ecf672b0d7df01e36eeeaec2b646b067e` |
| 修复 | `865672bdea97b4209984a79e78144b1cdad1e4306635171469f9d81b1116b755` | `2c94eebdae4b2a648e193a208ea028b7f5fd6566b1b9b91315688c5dee8b6001` |

固定的 `llvm24-tti` SHA-256 为 `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a`。冻结输入先核对 manifest 中的 SHA-256。

## 根因

### 区域复制

`tools/darm_pair_engine/RegionReplicator.cpp` 的 `replicateCFG` 建块时已经使用发现顺序，接边却遍历以 `BasicBlock *` 为键的 `DenseMap`。接边插入到目标块的 use-list，改变了 `concretizeBranchConditions` 读取前驱的顺序。后者从匹配块反向走所有路径，遇到同一分支的两条边时两次写入条件，最后写入的值决定了复制臂选用的路径。稳定接边顺序即可稳定选路。匹配块、原区域实际执行臂的条件及合并判据保持原语义。

HLLD `trial-11` 在临时日志中首次于 `replicateCFG` 的接边顺序分歧。接到 `replicated.bb1` 上游的路径顺序改变后，`concretizeBranchConditions` 最后经 `replicated.bb3` 写入 `true`，或最后经 `replicated.bb4` 写入 `false`。同一父 IR 的原始差异如下：

```diff
-  %433 = select i1 %361, i1 %432, i1 true
+  %433 = select i1 %361, i1 %432, i1 false
```

cleanup 把常量臂约简进布尔条件，选择 `fcmp uge` 加反向跳转，或 `fcmp olt` 加正向跳转。在后续块上，复制路径经过哪一条边还决定 `and i1` 是否可消去，造成 1 点 TTI 差异。Landau 的 `trial-304` 同样在复制臂的 `select` 中出现 `true/false` 差异，但该试融在 cleanup 前即被拒绝。

修复将复制映射改为 `MapVector`，让接边保持 CFG 发现顺序。临时日志未提交。

### 仅归一化与区域预检

- `tools/decision_model.cpp` 的 `decision::normalize` 用 `std::sort` 比较出口块指针，再调用 `SplitBlockPredecessors`。接边顺序改变了 raw IR 的前驱注释。改为沿两臂各自的 CFG 发现顺序去重。
- `tools/fusion_search.cpp` 的区域预检从 `std::set<BasicBlock *>` 遍历 scope，并在第一个不支持的访存处返回。tigre 的 `trial-9` 和 `trial-10` 会先记录 `%if.then499` 或 `%if.then485` 中的纹理采样。沿父函数块顺序检查 scope 后，拒绝详情稳定。两种旧详情均属 `unsupported_replicated_memory_access`。

### 其余静态排查

| 路径 | 会影响顺序的写法及处理 |
| --- | --- |
| `darm_pair_engine/RegionMelder.cpp` | `computeRegionSeqAlignment` 的旧分支遍历块指针映射，发布构建的 `FUSION_DETERMINISTIC_REGION_ORDER` 已按函数顺序对齐；`updateMapping` 只查找唯一出口；`SeenBlocks`、`visited` 和 `Selects` 作成员检查，删除和分支遍历按单独序列进行。 |
| `darm_pair_engine/RegionAnalyzer.cpp`、`CFMelderUtils.cpp` | CFG 标签映射作索引，匹配排序比较相似度和支配关系。相似度遍历指针映射时只累加整数。 |
| `darm_pair_engine/RegionReplicator.cpp` | `addPhiNodes` 的 `SmallSet<Instruction *, 32>` 在超过内联容量时有地址排序风险，LLVM 的 dominance frontier 也维护块集合。现有回放的首个分歧已经发生于接边，修复后保留这些代码。 |
| `darm_artifact/` | 原版 `RegionReplicator` 存在同样的 `DenseMap` 接边和前驱遍历，旧 `RegionMelder` 还直接遍历块映射；此处只做静态排查，原论文对照实现未修改。 |
| `fusion_search.cpp` | 区域的块集合、内存检查和前驱集合以指针为键；实际影响首条拒绝详情的 scope 已稳定。候选排序使用候选键，预留集合或映射只作成员检查、按块查找或先转成稳定索引。 |
| `b2b_anchor.cpp` | `latestRoot`、`indices` 和 `charged` 对指针哈希，只查询或检查插入结果；cutoff 集合使用指令序号，beam 以布局配对和分数排序。 |

## 修复后固定父 IR 回放

三个候选各自在对应的固定父 IR 上，用 20 个独立进程执行原 `request.json` 中的命令。候选相对路径与原 Greedy 保持相同。临时日志构建仍能复现两形，`trial-11` 为 14 / 6，`trial-12` 为 7 / 13，`trial-23` 为 9 / 11，顺序见普查表。

| 候选 | Raw SHA-256 | Cleanup SHA-256 | TTI | 次数 |
| --- | --- | --- | ---: | ---: |
| `trial-11` / `B9:B22:B12` | `266c0ec9bdfc8ee905a47b31d9dddfd833b60689bf996d7d333d1f44890ccd86` | `5a7d21cef13e427ed492cf02ac4c0fc9d7662ce1b76da627460a7171eb201d3a` | 1839 | 20 |
| `trial-12` / `B9:B23:B12` | `a4dcb2d3efa28f503324f9ec5ec15eb39c0251a98c368cc65b4e25625fcf88f1` | `dd1b16cbc43fd52e21b74a270680d5885dc1465df59648db24254e19123ff2b4` | 1844 | 20 |
| `trial-23` / `B9:B21:B12` | `690b6ca600bee249bbc2802e13cc5bff633972be4058bfc5b48a735dbc2c447b` | `4187ad0d4f4310521ae6fc5d893ff3bca1ba344cd9ebb38e74897313b509cf52` | 1805 | 20 |

用 `tests/fusion-search/check-darm-determinism.py` 在固定 HLLD 父 IR 上运行五个独立进程，比较 raw IR、cleanup IR 和完整评分；测试已进入 `tests/run-v1`。同一回归在发布线二进制的第 2 次重放即检出差异。

## 全部 17 个 case 的普查和复验

修复前比较了 102 次完整 Greedy，共 28,986 条候选观察。修复后比较了 85 次，共 24,155 条候选观察。每组 17 个 case 均产生 4,831 个试融目录。下表列出曾出现多个观察结果的候选。完整候选号、各形态的出现次数及 ASLR 对照见[普查明细](darm-determinism-census-20261122.tsv)。

| 路径 | 变异字段 | 候选数 |
| --- | --- | ---: |
| normalize-only | raw preds | 1317 |
| darm-R2B | raw | 6 |
| darm-R2B | raw / cleanup / fused / receipt / attempt / cost | 3 |
| B2R（预检） | receipt | 2 |

- CED：normalize-only（raw preds）2 个。
- HLLD：darm-R2B（raw / cleanup / fused / receipt / attempt / cost）3 个；normalize-only（raw preds）4 个。
- HiPIMS-George：normalize-only（raw preds）21 个。
- Landau：darm-R2B（raw）6 个；normalize-only（raw preds）160 个。
- MapAiry：normalize-only（raw preds）75 个。
- SW2D：normalize-only（raw preds）2 个。
- SasPoint5：normalize-only（raw preds）43 个。
- TPACF：normalize-only（raw preds）397 个。
- tigre：B2R（预检）（receipt）2 个；normalize-only（raw preds）3 个。
- vllm：normalize-only（raw preds）610 个。

### 结构试融的观察分布

| Case | 候选 | 融合路径 | 各形态正常次数 | 关闭 ASLR 的形态 |
| --- | --- | --- | --- | --- |
| HLLD | `trial-11` / `B9:B22:B12` | darm-R2B | 4 / 1 | 2 |
| HLLD | `trial-12` / `B9:B23:B12` | darm-R2B | 2 / 3 | 1 |
| HLLD | `trial-23` / `B9:B21:B12` | darm-R2B | 3 / 2 | 1 |
| Landau | `trial-304` / `B14:B42:B28` | darm-R2B | 1 / 2 / 2 / 0 | 4 |
| Landau | `trial-305` / `B14:B43:B28` | darm-R2B | 2 / 1 / 1 / 1 | 1 |
| Landau | `trial-314` / `B14:B28:B36` | darm-R2B | 1 / 3 / 1 / 0 | 4 |
| Landau | `trial-319` / `B14:B36:B28` | darm-R2B | 2 / 2 / 1 / 0 | 4 |
| Landau | `trial-327` / `B14:B26:B30` | darm-R2B | 3 / 2 | 2 |
| Landau | `trial-328` / `B14:B30:B26` | darm-R2B | 4 / 1 | 2 |
| tigre | `trial-10` / `B22:B23:B27` | B2R（预检） | 2 / 3 | 2 |
| tigre | `trial-9` / `B22:B23:B25` | B2R（预检） | 3 / 2 | 2 |

### 修复后

每个 case 的 5 次复验中，候选集合、父 IR、raw IR、cleanup 后 IR、候选输出及评分均逐字节一致。各 case 的提交链（含每次提交的 IR）、最终 IR、最终 TTI 和设备对象与发布线逐字节一致。HLLD 的三个候选仍未获选。全部设备对象相同，沿用发布测量，本步无需 GPU 重测。

| Case | 候选目录数／轮 | 提交数 | 最终 TTI | 最终 IR SHA-256 |
| --- | ---: | ---: | ---: | --- |
| vllm | 1971 | 225 | 2619 | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` |
| MapAiry | 462 | 30 | 3997 | `109dae2f8e462357add07adbc0dcd17dae365372fdca464a9abe9469f40c90d1` |
| tigre | 22 | 5 | 942 | `5605316b9f7b3403cfdd81fcb96017f63592c94dad1c3ad888b3972c9adbc809` |
| HLLD | 42 | 5 | 1696 | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` |
| NQU64 | 17 | 2 | 274 | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| MS32 | 6 | 2 | 198 | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| PCM32 | 50 | 18 | 1136 | `debd9769998968174b631e18fd675916172800fd3eeeb179f026e725cf3b5fb0` |
| SRAD16 | 14 | 3 | 445 | `29c33f08d3663cfa068b563f88939300fe16ae24ca5f748bef8f6eec11b59b71` |
| SRAD32 | 14 | 3 | 445 | `675b5641e45673d18e51066e4cfa8a5ec70c5c0d4afbc2409dd5766f45eae5a2` |
| Landau | 555 | 22 | 1635 | `31aea7ae5a00106b1e4684c7f87cf6fa895cff29010f450c740f92396eb1943f` |
| SW2D | 22 | 1 | 1925 | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| CED | 7 | 3 | 281 | `f068294bdff0eea4be42fe2036db147d3efd5cbc31ab44d1b006c2fc9fd4fb11` |
| TPACF | 1381 | 23 | 325 | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| SRAD-stage2 | 4 | 2 | 209 | `b1343cc5c72cc19d5a352cfa8080208fb503de8160190f1a0f638bc4cff42ad8` |
| SasPoint5 | 109 | 7 | 491 | `eefddfe2b88b52b4e348b8ac7ad6a324f0c7c881521d3a4f3c7696de9d616385` |
| HiPIMS-George | 151 | 5 | 5572 | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` |
| LUD8 | 4 | 2 | 628 | `387a564d46e1226112d51f2d9e7640dc1016dd72b2e41533a2a488aa330af915` |

发布复验只报告 CED 281 > 280。LUD8 按发布比较的 ROCm 4.2 口径重新生成设备对象，SHA-256 为 `15266ece5e8344423077a145cbf41eb24635ee6591884241f1e26e339d77edd8`。原回归套件 16 项通过、4 项按缺件跳过；新增的 HLLD 重放也在套件中通过。

## 发布复验与白名单

```sh
tools/build-llvm24-tti --search-only
tools/build-decision-greedy
tools/build-decision-model
python3 regression/verify_anchor_release.py --tool-root . --out "$STAGE/verified" --jobs 12
tests/run-v1
```

`regression/verify_anchor_release.py` 已按冻结哈希逐字节验收，仓库中的验证脚本和现行模板没有 DARM 白名单代码。先前按候选号和哈希放行的规则只存在于旧步骤的一次性审计脚本和历史记录。本次审计对所有候选严格比较，移除了 `docs/KNOWN_ISSUES.md` 中的现行豁免说明，保留历史记录原貌。

原始回执、LLVM 12 的 `llvm-diff`、临时插桩日志和复现脚本保存在 EPYC 的 `/data/home/chh/simplify-v2/build/darm-determinism.Nq2mte`。实际环境变量来自主机的 `v2-runtime/reproduce.json`。首次固定父 IR 批量调用在临时目录误用了相对符号链接，尚未完成任何重放即退出，改成绝对路径后从头重放。回归套件包装器首次调用缺少测试输出父目录，创建目录后完整重跑。
