# vLLM：新 Decision/Arm 路径的完整树实验

2026-11-10。实验入口默认关闭，生产搜索和冻结回归未改。本次完成了完整递归融合，但**尚未把该入口接入贪心＋TTI 接受逻辑**；下面是手动强制树的结果，不能称为新评分器选出的方案。

## 实现和复现入口

```bash
bash tools/build-decision-model
bash tools/build-decision-fuse
python3 tests/decision-model/run.py
python3 tests/decision-model/fuse_check.py
python3 tests/decision-model/full_tree_check.py

# 明确选择一个 Decision 里的相邻 Arm；输出目录必须不存在。
build/decision-fuse/decision-fuse input.ll cache_eval 0 0 output-dir leaf-order.json
```

LLVM12 用于 IR 和 RegionMelder。构建脚本在临时副本中应用随仓库提供的 engine-only speculation 补丁，新 driver 明确选 none；没有更改生产 engine。LLVM_CONFIG/CXX 可覆盖工具链，ENGINE_ROOT 可选已有审查引擎。

每次 trial 克隆父 IR，短路规范化入口、独立 pair join、调用 RegionMelder、内部及有限局部清理、verifier、外部范围审计，然后重绑定来源和原始叶序。输出 parent.ll、normalized.ll、meld-raw.ll、fused.ll、trial.json、decisions.json。

Linear×Linear 局部串联后走 B2B；含 SESE 的当前实现选择两侧必经且有实际指令匹配的锚点，未宣称实现完整通用 R2R/区域复制。新支持同前驱叶子、反向末端条件、组＋叶子、组＋组，以及整个决策完成后的绑定。

本次原始 L0～L7 顺序来自旧 logical-state-0.json 的显式映射，以 decision.order 元数据维护，不能仅凭 CFG 的 true/false 顺序恢复源码编号。任意 O3 后的稳定重绑定仍未保证。

GPU 准备与执行脚本位于 tests/decision-model：prepare_full_vllm.py 使用 musa 已归档实验父 IR 和逻辑映射；gpu_validate.py 使用 C++ 生成随机输入、验证输出并计时。这些脚本的 --help 给出实验目录参数。源码级 CPU fixture 不依赖历史实验目录。

## 两种完整树

- 递归：`(((((((L0,L1),L2),L3),L4),L5),L6),L7)`。
- 平衡：`(((L0,L1),(L2,L3)),((L4,L5),(L6,L7)))`。

32 棵量化树每棵 7 次，两种方案各 224 次实际融合。每一步检查 copysign 少一次；全函数 256→32；每棵树最终 8 个 Arm→1 个。每步 verifier、外部审计及绑定检查通过。CPU fixture 两种树各 7 步，每步比较 201 个输入的输出。

逐次融合不跑 O3；最终 GPU 编译使用相同后端流水线，包括最终 O3。GPU 输入是固定 seed 的随机 BF16 64K/128K，**不是历史真实 Qwen KV**。三个版本在两种规模的完整输出比较通过。每批预热 3 次、测量 15 次，共 3 批轮换版本顺序，以批次中位数的中位数汇总。

## 性能结果：完整树发生回退

| 版本 | 64K μs | 128K μs | 相对 baseline |
|---|---:|---:|---|
| 本批 baseline | 2897.602 | 5749.285 | 1.000× |
| 新递归完整树 | 3344.802 | 6656.326 | 慢 15.43% / 15.78% |
| 新平衡完整树 | 4082.723 | 8087.046 | 慢 40.90% / 40.66% |

之前只进行每棵前三次融合的独立批次，64K 为 2895.042→2692.962 μs，128K 为 5746.404→5353.124 μs，分别快 6.98%/6.84%。不同批次不能直接混用 baseline。

## 后端资源与旧冻结结果

| 版本 | VGPR | SGPR | SGPR spill | VGPR spill |
|---|---:|---:|---:|---:|
| 旧冻结 greedy | 50 | 76 | 0 | 0 |
| 本批 baseline | 62 | 82 | 0 | 0 |
| 新前三次融合 | 78 | 78 | 0 | 0 |
| 新递归完整树 | 93 | 104 | 14 | 0 |
| 新平衡完整树 | 125 | 104 | 37 | 0 |

旧冻结版本确实没有 spill。完整树的反汇编出现 v_writelane/v_readlane，private segment 为 0，无 scratch 指令，支持 SGPR 溢出到 VGPR lane 的解释，不能说已经证实溢出到显存。这些资源变化与回退相关，但尚未隔离各项耗时贡献。

最终 O3 后，递归版本有 88 个 PHI、244 个 select；平衡版本有 408 个 PHI、308 个 select，后者保留了更多选择状态。ir-comparison.json 中旧 final 是旧 raw 阶段，不能拿它与新 post-O3 直接作同阶段结论。

## TTI 诊断和局限

LLVM24 gfx906 TCK_RecipThroughput：parent 5423，第一次新融合 5438，递归 raw 12815，平衡 raw 6703；最终 O3 后分别 3375、3983。unknown 都是 0。**这些数值没有用于选择或拒绝本次强制树**，也不能证明静态低成本对应更快 GPU 时间。

第一次 L0+L1 的同父状态对照见[完整比较文档](vllm-first-pair-ir-comparison-20261110.md)。目前还存在死 PHI、可折叠直线连接块，以及新路径没有复用旧阈值并集简化的问题。先保留这些实际证据，再决定怎样修复，不能用本次结果替换更快的冻结回归参考。

## 证据

[记录目录](evidence/decision-full-trees-20261110/) 包含：

- recursive-search.json、balanced-search.json：两种树全部 448 步的验证和绑定记录。
- leaf-order.json：原始叶子顺序。
- gpu-summary.json、gpu-plan.json、generation.json：输入参数、二进制哈希、正确性和计时摘要。
- resource-comparison.json、ir-comparison.json、tti-diagnostic.json：资源、IR 和成本诊断。
- cpu-full-trees.log、clean-build-tests.log：CPU 验证记录。
- three-levels-comparison.json、three-levels-backend.json：前三次融合的独立实验。

GPU 二进制、生成输入及输出张量不进 git。完整 trial 仍留在 musa 的 `/home/chh/kernel-benchmark-suite-review-speculation/build/decision-fuse/full-all32-v1/`。单次前后完整 IR 随提交保存，见上述比较文档。
