# 独立清理开关与 checkpoint 对照

配置为 `DECISION_SPECULATION=none`，分别使用 `DECISION_CFG_CLEANUP=full/structural`。压力上限统一设为不构成约束，uniform guard 关闭，以隔离清理方式的影响。原始 checkpoint 使用35f9ccd代码与保存的原始融合可执行文件。

**四项 full 的最终二进制 SHA 和提交顺序均复现 checkpoint；四项 GPU 正确性全部通过。**

| Case | full / structural 提交数 | full 耗时 | structural 耗时 | structural 相对 checkpoint |
| --- | ---: | --- | --- | --- |
| vllm | 204 / 160 | 2.446 / 4.860 ms | 2.731 / 5.436 ms | +11.63% / +11.86% |
| mapairy | 25 / 16 | 24.960 μs | 24.960 μs | +0.00% |
| hypersonic | 2 / 1 | 1807.361 / 1807.681 μs | 1816.641 / 1810.081 μs | +0.51% / +0.13% |
| tigre | 5 / 2 | 3.043681 ms | 3.035683 ms | -0.26% |

full 与 checkpoint 二进制相同，明确共用一次采样，不作为两份独立测量。每组3批轮换顺序，预热3次、测量15次，2%为性能门槛。VLLM为64K/128K合成BF16输入，不是实际Qwen数据；Hypersonic为共同no-JT baseline、两个冻结输入，逐输入独立runner进程；TIGRE为六组配置中位数合计。

这轮相对的是35f9ccd checkpoint，不代表已经追平更早local-union冻结赢家。

## 两个不同的 VLLM 首对

| 候选 | structural | full | checkpoint |
| --- | ---: | ---: | ---: |
| greedy首先尝试的decoder pair | 5424 | 5412 | 5412 |
| 八叶量化树copysign L0+L1 | 5412 | 5412 | 5412 |

decoder的三条gap指令 fadd、add、amdgcn.ldexp 被full清理提前执行；权重1/1/4，LLVM12 SizeAndLatency成本1/1/1。量化树首对并不依赖这三条指令或隐式投机。

## CPU优化与压力因素

相同160次提交、876个trial的structural搜索：487.27 → 395.63秒，降低18.81%。提交顺序和最终二进制相同。该整轮对比的before已有反向liveness；after另加审计SlotTracker复用。反向liveness单独的代表trial对比降幅约35%–37%。

之前启用“pressure不许增长”时，Map-Airy为14次提交、54VGPR、31.36μs；这轮非约束压力下的structural为16次提交、37VGPR、24.96μs。关闭full隐式投机并非Map-Airy先前大幅退化的唯一原因，硬性的IR压力代理也阻止了关键融合。不同轮性能差只作为辅助证据；本轮full/structural比较为同轮控制。

## 诊断字段与安全检查

`implicit_speculation_cost_true/false` 为清理后减清理前的保守side可达块成本，负值表示净减少；它包含结构清理收益，不等同于纯投机的真实运行开销。每次full提交的具体被移动指令、opcode、weight、TTI与side增量均保留在对应commits.json及trial.json。诊断失败不拒绝full trial。

full保留全函数convergent拒绝；structural只拒绝trial区域内的convergent。两者均保留SESE边界检查、区域外审计和LLVM verifier；不支持的LLVM12 target明确拒绝，不回退通用TTI。便携单测和真实checkpoint字节对比均通过。

本轮未运行cost原型的2×2验收。代码与结果尚未commit/push。

远端完整证据：`/home/chh/kernel-benchmark-suite-review-speculation/build/decision-fuse/cleanup-comparison-v1`。
