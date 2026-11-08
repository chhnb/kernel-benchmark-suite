# 递归局部融合：实现与结果

2026-11-08，musa `/home/chh/kernel-benchmark-suite`。

## 输入抽象

新核心 `tools/darm_pair_engine/LocalComputationFusion.h` 使用统一的 `LocalComputation`：一个可共享的输出计算节点，以及为其操作数提供值的封闭表达式 DAG。原始叶子和已经融合过的选择树都用这个结构描述，不再依赖“幅值必须是常量”“块内必须恰好两条指令”。

支持的输出节点包括二元/一元运算、类型转换，以及专门允许的 copysign intrinsic。两个节点必须是同一种操作，类型、指令标记、非调试元数据及相关调用属性兼容。对不同的操作数创建 select，对相同的操作数直接复用，再克隆一次共享计算。不是只修改 copysign 的幅值参数。

内部表达式允许已有 select、比较及其他经 LLVM 判定可安全提前求值的纯指令。必须闭合在被选中块内，不能有外部使用者，不能包含 PHI、调用、内存读写或不安全操作。它们只在两个区域的并集路径内组合，不执行两份输出根计算。

例如 `fmul` 的两个输入可以分别选择；对于“先乘再加”，乘法可以作为操作数表达式保留，合并共享的加法根。这里未实现任意指令序列的完整 DARM 对齐或任意多块 Region 合并；未匹配的纯操作数计算可能增加某些路径的动态工作量，因此仍需要成本评估与性能验证。

## 入口与递归

原来的路径并集与阈值蕴含检查继续使用。第二个组的入口允许含有多个普通 FCmp，但必须比较同一个输入与常量，其使用者限于该入口分支和所选组的计算。检查通过后，才把这些比较移到新入口；其他外围区域不复制。

已有组里的 select、比较和参数计算会被收集为操作数 DAG，参与下一次共享。因此支持：

- 叶子 + 叶子
- 组 + 叶子
- 叶子 + 组
- 组 + 组

逻辑组的叶子区间、孩子 ID、active 顺序和当前 IR 绑定沿用现有状态。每次试融合使用克隆；提交后在当前 IR 上重新枚举和评分。拒绝发生在变换前，不修改候选的克隆 IR。

## 开关

```text
--adjacent-only 1 --local-compute 1 --local-union 1 --cleanup none
```

`--local-compute` 是已有 `--local-copysign` 的兼容别名；旧开关仍可使用。未启用时原 DARM 路线不变。旧 PHI 参数模式保留并通过回归；本次递归支持针对 union/select 路线，不宣称能接收任意旧 DARM 或 PHI 模式产生的区域。

上游 `/home/chh/darm-artifacts-repro/upstream/code` 未修改，改动位于 suite 当前编译的引擎副本。

## vLLM D16：同分优先靠左的贪心

初始父状态与此前实验相同，LLVM24/gfx906 TTI，无外部清理，仅选择 D16 的候选。

| 轮次 | 提交 | 静态成本 |
|---|---|---|
| 1 | G0=(L0,L1) | 5423→5412 |
| 2 | G1=(G0,L2) | 5412→5401 |
| 3 | G2=(G1,L3) | 5401→5390 |
| 4 | G3=(G2,L4) | 5390→5379 |
| 5 | G4=(G3,L5) | 5379→5368 |
| 6 | G5=(G4,L6) | 5368→5357 |
| 7 | G6=(G5,L7) | 5357→5346 |

最终树：

```text
(((((((L0,L1),L2),L3),L4),L5),L6),L7)
```

该实例最终覆盖全部 8 个叶子，不再停在四对。每次静态收益 11，合计 77；这不是 GPU 实测收益。

另外按指定顺序验证了：

```text
右深： (L0,(L1,(L2,(L3,(L4,(L5,(L6,L7)))))))
平衡： (((L0,L1),(L2,L3)),((L4,L5),(L6,L7)))
```

两者同样完成 7 次融合，最终成本都是 5346。当前指令加权模型无法区分这三棵树的选择依赖深度与硬件表现。

## 验证

- 独立的 8 叶子 copysign、fmul、fmul 后接 fadd 用例，各按左深、右深、平衡三种顺序递归融合，共 9 次完整构造、63 次提交；每次 trial 通过 verifier。
- 每个结果在主机 O0/O3 下分别对 10,050 个输入位模式做逐位对照，共 180,900 次比较。覆盖阈值及相邻值、正负零、无穷、quiet/signaling NaN 和固定种子随机输入。
- 原单次 PHI 融合、单次路径并集融合回归通过。
- 内存加载、不安全整数除法、内部值逃逸、输出操作不匹配等明确拒绝，并验证拒绝后克隆 IR 与原输入相同。
- 元数据不兼容也明确拒绝，不将其中一侧的优化假设直接复制给另一侧。
- 真实 vLLM 的贪心、指定左深、右深、平衡四次运行均完成 7 次融合。

以上不包括 GPU 性能或完整 kernel 数值验收，也不意味着其他 8 个主要 case 均已支持。通用多块结构、多个输出计算、循环、内存与副作用区域仍需额外实现。

## 文件与复现

- 核心：`tools/darm_pair_engine/LocalComputationFusion.h`
- 兼容头：`tools/darm_pair_engine/LocalCopysignFusion.h`
- 驱动：`tests/postopt/recursive_local_union.cpp`
- 构建驱动：`tests/postopt/build_recursive_local_union.sh`
- 数值测试：`tests/postopt/check_recursive_local.py`
- 拒绝测试：`tests/postopt/check_recursive_rejections.py`

先运行 `tools/build-llvm24-tti` 重建引擎，再构建驱动；驱动链接该构建目录中的对象文件。

```text
build/llvm24-tti/recursive-local-union \
  experiments/logical-state-vllm-20261108-v1/state-0.ll \
  cache_eval D16 experiments/NEW_OUTPUT_DIRECTORY greedy
```

策略可选 `greedy`、`left`、`right`、`balanced`。greedy 只接受正收益；后三者是指定树形的合法性试验，不要求每次正收益。可选最后一个参数 `legacy` 用于主机数值测试中的旧静态评分；真实 vLLM 默认使用 LLVM24 TTI。

主要实验：`experiments/recursive-local-unit-20261108-v2` 与 `experiments/recursive-local-vllm-{greedy,left,right,balanced}-20261108-v1`。目录内保存每次提交后的完整 IR、逻辑状态和所有试融合记录。
