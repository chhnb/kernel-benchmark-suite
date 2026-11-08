# 局部 copysign 融合：路径并集入口

2026-11-08，musa `/home/chh/kernel-benchmark-suite`。

## 使用方式

```text
--adjacent-only 1 --local-copysign 1 --local-union 1 --cleanup none
```

新增 `--local-union` 默认为 0。原 PHI 接收参数的模式保留，并通过回归测试；一般 DARM 自动融合路线和上游 Git checkout 不变。本次仍是 copysign 简单叶子的专用原型，不是任意多指令区域的通用融合器。

## 入口语义

对直接链式的两个相邻叶子，设 A 为进入第一个叶子的条件，B 为进入第二个叶子的局部条件。第二个叶子的完整条件为 `!A && B`，二者并集为 `A || (!A && B)`，等价于 `A || B`。共同的外层路径条件由原来的入口位置保留。

只有当两个条件都是相同 SSA 浮点输入与常量的普通 FCmp、第二个判断块仅含比较和分支、仅由第一个判断块进入、且比较无额外使用者时，才允许把第二个比较移到入口。否则明确拒绝，不调用通用 SimplifyCFG，不复制外围区域。

若证明 `A => B`，入口进一步简化为 B。证明覆盖两阈值本身、各自上下相邻可表示值、正负无穷和 NaN；对同一浮点输入的两个常量比较，这些点覆盖所有比较真值组合。支持 float32/64，比较符号和真假边按原 IR 处理，严格/非严格边界和 unordered 行为都保留。不能证明时保留显式 OR。

参数选择使用原始第一个比较：原叶子位于 false 边时交换 select 的两个幅值，避免额外生成 NOT。简化后的 B 若对应 false 边，交换入口跳转的目的块，避免额外的布尔取反。

对于两个叶子来自同一前驱的标准 diamond，直接在共同前驱生成常量 select 和共享调用，并跳到原共同出口；不创建无必要的中转块。

这显式改变了第二个比较的求值范围，但仅允许普通、可安全执行的 FCmp；不会把两条 copysign 一并提前计算。原始比较指令和 NaN 路由保持语义一致。

## 真实 vLLM 的 L1+L2 输出

```llvm
if.else.i667:
  %cmp2.i666 = fcmp olt float %128, 7.500000e-01
  %cmp6.i669 = fcmp ugt float %128, 1.250000e+00
  br i1 %cmp6.i669, label %if.else8.i673, label %local.copysign

local.copysign:
  %local.magnitude = select i1 %cmp2.i666,
      float 5.000000e-01, float 1.000000e+00
  %local.result = tail call float @llvm.copysign.f32(
      float %local.magnitude, float %mul126.1) #3
  br label %quant_decide.exit685
```

原 L1/L2 计算块及第二个判断块被删除，原来的 L3～L7 判断链继续使用。共同出口 PHI 只更新被选中叶子的输入边。

原本 `p || !q` 的入口通过 `p => !q` 简化为 `!q`，并以 q 为真走剩余尾部、为假进共享块实现；p 仍用于选择幅值，未被错误删除。

## 同父状态七对实测静态成本

输入：`experiments/logical-state-vllm-20261108-v1/state-0.ll`，实例 D16，LLVM24/gfx906 TTI，无外部清理。

| 候选 | 前 | 后 | 收益：前−后 |
|---|---:|---:|---:|
| L0+L1 | 5423 | 5412 | +11 |
| L1+L2 | 5423 | 5412 | +11 |
| L2+L3 | 5423 | 5412 | +11 |
| L3+L4 | 5423 | 5412 | +11 |
| L4+L5 | 5423 | 5412 | +11 |
| L5+L6 | 5423 | 5412 | +11 |
| L6+L7 | 5423 | 5412 | +11 |

每对减少一条条件 br（7）、一条无条件 br（4）、一条 copysign（1），增加一条 float select（1），净收益 11。按“后−前”定义的增量为 −11，归一化收益为 11/5423 ≈ 0.0020284。如果把所有 br 成本归零，收益仍为零。没有 GPU 性能实测，不将此数值解释为加速。

## 验证

- `check_union_implication.cpp`：float32/64、反向阈值反例、严格边界、NaN 反例、正负零；断言启用。
- `check_local_union.py`：7 对均通过 LLVM verifier；每对在主机 O0/O3 下比较 10,050 个输入位模式，共 140,700 次前后输出逐位比较。包含边界及邻值、正负零、无穷、quiet/signaling NaN 和固定种子随机值。
- 额外计算指令的叶子仍明确拒绝。
- 原 `check_local_copysign.py` PHI 模式回归通过。
- 七对真实 vLLM trial 均成功，新增 shared copysign 没有触发 region replication。

实验目录：`experiments/local-union-unit-20261108-v1`、`experiments/local-union-seven-pairs-20261108-v1`、`experiments/local-union-phi-regression-20261108-v1`。

这次没有重跑多轮贪心、自动 DARM 或全 benchmark suite。带 PHI/select 的已融合组继续扩大仍未支持，后续需单独设计。
