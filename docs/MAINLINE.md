# Auto Greedy v1 主线

`release/greedy-v1` 从 `48fb41e` checkpoint 精简，唯一自动搜索入口是 `decision-greedy`。

## 执行链

1. 从固定 baseline IR 发现决策与 B/R 候选。条件规范化预算为 4；按条件等价规则整理入口。
2. 默认 16 路进程从连续队列领取候选；每个进程在一轮内复用 LLVM24 worker，同父输入复用解析与清理结果。完成一个候选即领取下一个，最终仍按原候选顺序打破平局。B2B 默认 DP1，可显式选择 DARM；B2R/R2B/R2R 固定 DARM。R2R 使用 DARM 的区域对齐，不枚举全部交叉区域对。
3. 克隆父模块并生成融合 IR。单侧未匹配指令保持分支保护；检查 SSA、访存、边界与 LLVM verifier。
4. 执行 DARM SimplifyCFG（PHI folding threshold 7；关闭条件分支简化、公共指令 sink/hoist）→ EarlyCSE → DCE → InstCombine。
5. LLVM24 常驻 worker 评价清理后的 IR。控制版本使用同样清理；选取满足正收益条件的候选。
6. 提交获胜 IR，重新发现候选。失败的 trial 不修改父 IR；DP1 失败不会隐式回退到 DARM B2B。

## 文件职责

| 文件 | 职责 |
|---|---|
| `tools/decision_greedy_main.cpp` | 自动搜索、并行 trial、比较与提交 |
| `tools/decision_model.cpp`、`condition_simplify.h` | 决策与条件规范化 |
| `tools/fusion_search.cpp/.h` | B/R 枚举、DP1 方案、DARM 调用、固定清理与合法性 |
| `tools/fusion_search_llvm24_main.cpp` | 显式 pair、catalog、控制版本、连续试跑队列 |
| `tools/darm_pair_engine/RegionAnalyzer.cpp` | 原生 DARM 区域对齐 |
| `RegionMelder.cpp`、`RegionReplicator.cpp` | DARM 融合与区域复制 |
| `GuardedRanges.h` | 未匹配指令的固定分支保护；不是 Gap Search |
| `InstructionPolicy.h` | 指令权重与移动安全检查；不是投机策略开关 |
| `tools/llvm24_scorer.h`、`tti_memory_io.h` | LLVM24 报价、常驻进程通信 |

## DP1 范围

保留共享前缀、共享后缀、公共计算与分段对齐等当前复现需要的 finalist 生成方式。分段 DP 使用有限标签搜索；相同游标下的值映射可能不同，不能声称它是无界全局最优算法。删除 SpecL/SpecR 和保护段投机变体；不删除 LLVM 的安全判断或 SimplifyCFG 自身的合法化简。

B2B 可配对普通访存及受支持的 intrinsic。未匹配副作用通过保护执行；不能证明改写合法的候选仍拒绝。B2R 保留 DARM 原生复制的 store 处理，不把它替换成旧 guarded B2R 实验策略。

删除 DP2/DP3、Gap Search/replay、完整 E-leaf、多锚点实验、旧 beam/backtrack 驱动、旧 decision-fuse、局部 if-conversion、profile/pressure 评分与可选 cleanup 策略。实验历史由 Git checkpoint 保存。

## 构建与验收

```sh
tools/build-v1 --search-only
tests/run-v1
python3 tools/run_v1_regression.py --out build/v1-check-new
```

完整工具链构建用 `tools/build-v1`；环境中的 `LLVM_CONFIG`、`LLVM24_CONFIG` 可覆盖默认位置。固定输入与参考摘要在 `regression/greedy-v1/manifest.json`。默认跑 38 个可完成配置；PCM128/256 是 checkpoint 的已知超时项，可用 `--include-slow` 测试，不计作通过。

复现检查包含输入 hash、提交次数、最终 TTI、verifier 和最终 IR hash（仅忽略 ModuleID 行）。合成测试还运行 CPU 输出、访存与 PHI/循环对比。GPU 性能是另一层验证；IR 一致并不等于本轮重新计时，也不证明静态 TTI 总能预测性能。
