# Auto Greedy V2 主线

`decision-greedy INPUT FUNCTION [TOOL_ROOT] NEW_OUTPUT` 是自动搜索入口。`release/greedy-v1` 和原冻结清单保留历史版本。

## 执行链

1. 从固定 baseline IR 发现决策与 B/R 候选。条件规范化预算为 4；按条件等价规则整理入口。
2. 默认 16 路进程从连续队列领取候选；每个进程在一轮内复用 LLVM24 worker，同父输入复用解析与清理结果。完成一个候选即领取下一个，最终仍按原候选顺序打破平局。B2B 默认 anchor。B2R/R2B 使用 DARM。R2R 通过 DARM 对齐区域，枚举范围由区域对齐结果决定。
3. 克隆父模块并生成融合 IR。单侧未匹配指令保持分支保护；检查 SSA、访存、边界与 LLVM verifier。
4. 执行 DARM SimplifyCFG（PHI folding threshold 7；关闭条件分支简化、公共指令 sink/hoist）→ EarlyCSE → DCE → InstCombine。
5. 通过 LLVM24 报价或离线 TTI 记录评价清理后的 IR。控制版本使用同样清理；选取满足正收益条件的候选。
6. 提交获胜 IR，重新发现候选。失败的 trial 不修改父 IR；不同 B2B 策略各自生成候选。

## 文件职责

| 文件 | 职责 |
|---|---|
| `tools/decision_greedy_main.cpp` | 自动搜索、并行 trial、比较与提交 |
| `tools/decision_model.cpp`、`condition_simplify.h` | 决策与条件规范化 |
| `tools/fusion_search.cpp/.h` | B/R 枚举、anchor 布局发射、DARM 调用、固定清理与合法性 |
| `tools/fusion_search_llvm24_main.cpp` | 显式 pair、catalog、控制版本、连续试跑队列 |
| `tools/darm_pair_engine/RegionAnalyzer.cpp` | 原生 DARM 区域对齐 |
| `RegionMelder.cpp`、`RegionReplicator.cpp` | DARM 融合与区域复制 |
| `GuardedRanges.h` | 未匹配指令的固定分支保护；不是 Gap Search |
| `InstructionPolicy.h` | 指令权重与移动安全检查；不是投机策略开关 |
| `tools/llvm24_scorer.h`、`tti_memory_io.h` | LLVM24 报价、常驻进程通信 |

## B2B 策略

默认 anchor 从出口 PHI 的两侧入值和共同地址的 store 建立锚点，沿操作数反向传播。
局部 TTI 用严格和宽松两种截断规则选择锚点。按两臂顺序取带权递增子序列，
再对相邻锚点间的指令做前向分段对齐，计入跨段 PHI 并保留空对齐方案。
布局共用 B2B 发射和清理，最终由 LLVM24 TTI 裁决。

当前 B2B 发射共享前缀、保留单侧代码的分段布局和 merged-exit。
分段对齐按有界候选搜索，评分相同时沿用生成顺序。

`darm` 使用仓库内的 DARM 引擎，`darm-artifact` 保留用于原版 DARM 对照。
DP1 规划器及 recipe 缓存已移除，完整历史实现保存在 `pre-dp1-removal`。

B2B 可配对普通访存及受支持的 intrinsic。单侧副作用保持分支保护。

删除 DP2/DP3、Gap Search/replay、完整 E-leaf、多锚点实验、旧 beam/backtrack 驱动、旧 decision-fuse、局部 if-conversion、profile/pressure 评分与可选 cleanup 策略。实验历史由 Git checkpoint 保存。

## 参数

- `--b2b-strategy anchor|darm|darm-artifact`，默认 `anchor`。
- B2R、R2B 和 R2R 使用 DARM。
- `--domain-schedule ordered`，可省略。
- `--ir-snapshots full|compact`，默认 `compact`。
- `--tti-quote-cache off|audit|on`，默认 `on`。

## 构建与验收

```sh
tools/build-v1 --search-only
tests/run-v1
python3 regression/verify_anchor_release.py --tool-root "$PWD" --out build/anchor-release-check
```

完整工具链从 `tools/build-v1` 开始，指定固定的 `LLVM_CONFIG`、`LLVM24_CONFIG` 和链接库。已有 LLVM24 worker 时可用 `--search-only`。
发布参考、可测 case 及逐字节验证命令见 [RELEASE](RELEASE.md)。
[ordered DP1 清单](../regression/greedy-v1/manifest-ordered-20261119.json)可配合旧 checkout 重放。
用 `python3 tools/run_v1_regression.py --tool-root /path/to/pre-dp1-removal --out build/ordered-dp1-check` 调用在历史 tag 上构建的工具。Map-Airy 的 anchor 参考仍位于[原冻结目录](../regression/golden/20261120-mapairy-anchor-gfx906-v1/manifest.json)。
