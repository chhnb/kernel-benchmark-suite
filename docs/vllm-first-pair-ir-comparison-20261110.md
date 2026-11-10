# vLLM：同一父 IR 的第一次 L0+L1 融合对比

日期：2026-11-10。对象为 `cache_eval` 的 D13 量化树，原始叶子 L0、L1。这里只做一次融合，未将后续完整树的变化混进来。

## 对照条件

父状态是旧实验 `recursive-all32-greedy-20261108-v1/state-0.ll`，SHA256 为 `7e1e57ebb0adeb1beef9382eab38a3ff5dfb37e2449ccfc79396ddcf89cd9962`。新 trial 保存的 parent 与它仅有 ModuleID 注释差异。

旧结果取冻结 greedy 的 state-1；其逻辑记录明确为 D13.L0+D13.L1。旧路径启用 local-copysign、local-union，cleanup none。新结果取本次 recursive/0-0 的 fused.ll：短路规范化、RegionMelder B2B、内部及有限局部清理，speculation none；没有逐步 O3。

新实验是手动指定融合，不是贪心＋TTI。这里 TTI 只读评估 LLVM24 gfx906 的 TCK_RecipThroughput，总成本为整个函数的指令成本和，unknown 为 0。

## 融合前的受影响块

```llvm
if.else.7:                                        ; preds = %cond.end75
  %mul116 = fmul float %div73, %12
  %101 = tail call float @llvm.fabs.f32(float %mul116) #3
  %cmp.i43 = fcmp ugt float %101, 2.500000e-01
  br i1 %cmp.i43, label %if.else.i, label %if.then.i

if.then.i:                                        ; preds = %if.else.7
  %102 = tail call float @llvm.copysign.f32(float 0.000000e+00, float %mul116) #3
  br label %quant_decide.exit

if.else.i:                                        ; preds = %if.else.7
  %cmp2.i44 = fcmp olt float %101, 7.500000e-01
  br i1 %cmp2.i44, label %if.then3.i, label %if.else4.i

if.then3.i:                                       ; preds = %if.else.i
  %103 = tail call float @llvm.copysign.f32(float 5.000000e-01, float %mul116) #3
  br label %quant_decide.exit
```

## 旧冻结 greedy 第一次融合后

```llvm
if.else.7:                                        ; preds = %cond.end75
  %mul116 = fmul float %div73, %12
  %101 = tail call float @llvm.fabs.f32(float %mul116) #3
  %cmp.i43 = fcmp ugt float %101, 2.500000e-01
  %cmp2.i44 = fcmp olt float %101, 7.500000e-01
  br i1 %cmp2.i44, label %local.copysign, label %if.else4.i

local.copysign:                                   ; preds = %if.else.7
  %local.magnitude = select i1 %cmp.i43, float 5.000000e-01, float 0.000000e+00
  %local.result = tail call float @llvm.copysign.f32(float %local.magnitude, float %mul116) #3
  br label %quant_decide.exit
```

旧 local-union 使用同一 SSA 值上的阈值关系，提前计算安全的第二次比较，并简化两个叶子的入口并集；用原比较选择幅值，直接生成共享调用块。

## 新实现第一次融合后

```llvm
if.else.7:                                        ; preds = %cond.end75
  %mul116 = fmul float %div73, %12
  %101 = tail call float @llvm.fabs.f32(float %mul116) #3
  %cmp.i43 = fcmp ugt float %101, 2.500000e-01
  br i1 %cmp.i43, label %if.else.i, label %decision.gate, !decision.origin !66

unify.bb:                                         ; preds = %decision.dispatch
  br label %merged.bb

if.else.i:                                        ; preds = %if.else.7
  %cmp2.i44 = fcmp olt float %101, 7.500000e-01
  br label %decision.gate

decision.gate:                                    ; preds = %if.else.i, %if.else.7
  %decision.value = phi i1 [ undef, %if.else.7 ], [ %cmp2.i44, %if.else.i ]
  %decision.was_left = phi i1 [ true, %if.else.7 ], [ false, %if.else.i ]
  %decision.take = phi i1 [ true, %if.else.7 ], [ %cmp2.i44, %if.else.i ]
  br i1 %decision.take, label %decision.dispatch, label %if.else4.i, !decision.short_gate !67

decision.dispatch:                                ; preds = %decision.gate
  br label %unify.bb, !decision.origin !68, !decision.order !69, !decision.merged_from !70

quant_decide.exit.pair.join:                      ; preds = %merged.bb
  br label %quant_decide.exit

merged.bb:                                        ; preds = %unify.bb
  %merged.select = select i1 %decision.was_left, float 0.000000e+00, float 5.000000e-01
  %439 = tail call float @llvm.copysign.f32(float %merged.select, float %mul116) #3
  br label %quant_decide.exit.pair.join
```

原 quant_decide.exit 的两个叶子 incoming 被一个共享结果 incoming 替代；新路径经 pair.join 返回。下文完整 IR 保留了该 PHI 和所有未变化块。

两者都共享了 copysign。新路径仍保留短路条件求值、实际路径选择 PHI，以及 dispatch → unify → merged → pair.join 的连接块。decision.value 只出现定义，没有使用，是尚未删除的死 PHI。直线空块也有局部折叠空间；这与允许提前执行条件、证明阈值蕴含是两件事。本提交记录现状，没有把这些后续清理修复混进实验。

## 原始融合结果的成本差

| 指令类别 | 单条权重 | 融合前 | 旧融合后 | 新融合后 |
|---|---:|---:|---:|---:|
| 条件 br | 7 | 351 | 350 | 351 |
| 无条件 br | 4 | 315 | 314 | 318 |
| copysign | 1 | 256 | 255 | 255 |
| i1 PHI | 1 | 1 | 1 | 4 |
| float select | 1 | 3 | 4 | 4 |
| 全函数指令数 | — | 2248 | 2246 | 2254 |
| 全函数 TTI 成本 | — | 5423 | 5412 | 5438 |

其余指令统计不变。收益统一定义为 C(before)−C(after)：旧为 +11，新为 −15。
新相对旧多 26 = 1×7 + 4×4 + 3×1。不能把静态成本单位解释为 GPU 周期。

## 同样跑 O3 后的对照

三个版本分别使用相同 LLVM12 AMD opt 的 `-O3 -verify-each`：

| 版本 | 指令数 | LLVM24 TTI 成本 |
|---|---:|---:|
| before + O3 | 2248 | 5423 |
| old_after + O3 | 2235 | 5380 |
| new_after + O3 | 2237 | 5382 |

新旧成本差从 26 缩到 2；统计上新版本多一个 i1 or 和一个 i1 xor。O3 是全函数优化，也会触发第一次融合之外的后续整理，因此不能把这张表解读为只优化两个叶子。

这说明原始单次融合确实有冗余，但不足以单独解释完整树的 spill。完整树还改变条件选择依赖和活跃范围，需要单独比较后端结果，见[完整树记录](decision-fusion-full-trees-20261110.md)。本次未对这个单次候选单独做 GPU 计时。

## 完整 IR 与机器可读证据

六份 IR 均随提交保存，无需访问 musa 即可查看：

- [before.ll](evidence/vllm-first-pair-20261110/before.ll)
- [old_after.ll](evidence/vllm-first-pair-20261110/old_after.ll)
- [new_after.ll](evidence/vllm-first-pair-20261110/new_after.ll)
- [before-o3.ll](evidence/vllm-first-pair-20261110/before-o3.ll)
- [old_after-o3.ll](evidence/vllm-first-pair-20261110/old_after-o3.ll)
- [new_after-o3.ll](evidence/vllm-first-pair-20261110/new_after-o3.ll)
- [summary.json](evidence/vllm-first-pair-20261110/summary.json)
- [cost-deltas.json](evidence/vllm-first-pair-20261110/cost-deltas.json)
- [o3-summary.json](evidence/vllm-first-pair-20261110/o3-summary.json)
