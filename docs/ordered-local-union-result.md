# 局部并集融合的顺序贪心

2026-11-08，musa kernel-benchmark-suite，vLLM cache_eval 的 D16 实例。

从 `experiments/logical-state-vllm-20261108-v1/state-0.ll` 开始；只搜索 D16，其余 31 个量化实例不参与候选选择。使用已有的稳定逻辑状态、候选枚举、trial、LLVM24 scorer 和接受准则。每轮评估全部可枚举邻居，选正分最高者，同分优先原始叶子区间最靠左者，再按物理候选键确定顺序。局部 copysign、路径并集入口开启，无外部清理。不是强制接受最左候选。

| 轮次 | 提交 | 函数静态成本 |
|---|---|---|
| 1 | G0=(L0,L1) | 5423→5412 |
| 2 | G1=(L2,L3) | 5412→5401 |
| 3 | G2=(L4,L5) | 5401→5390 |
| 4 | G3=(L6,L7) | 5390→5379 |

最终：`(L0,L1) | (L2,L3) | (L4,L5) | (L6,L7)`，累计静态收益 44，最终 IR 通过 verifier。没有 GPU 性能测量或最终整 kernel 数值验收。

第 2 轮曾尝试 G0+L2；随后尝试过 G0+G1、G1+L4 等组合。最后一轮三个邻居 G0+G1、G1+G2、G2+G3 都明确拒绝，原因 `local_requires_copysign_only_leaves`。当前变换只接受“一条 copysign + 一条跳转”的叶子，已有组包含 select/比较等指令，尚不能作为输入。它们不是负分或零分，而是未生成合法 trial、没有评分。

这次结果只验证了第一层融合和稳定相邻组维护，不能推断更大融合树不划算，也不能推断四对是最终最优划分。

可复现驱动：`tests/postopt/ordered_local_union.cpp`。

```text
build/llvm24-tti/ordered-local-union \
  experiments/logical-state-vllm-20261108-v1/state-0.ll \
  cache_eval D16 experiments/NEW_OUTPUT_DIRECTORY
```

输出目录必须不存在。实际记录位于 `experiments/ordered-local-union-20261108-v1`，含每轮 IR、稳定标签状态和完整尝试/拒绝记录。
