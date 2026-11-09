# Map-Airy intrinsic 匹配修复与复测

2026-11-09。基线是 suite 完整 evaluate（LLVM12 IR），评分使用 LLVM24 gfx906 reciprocal-throughput TTI。只修改 suite 内的 DARM pair engine；原始 artifacts 仓库保持未修改。

## 修复

`tools/darm_pair_engine/InstructionMatch.cpp` 补齐 `amdgcn.ldexp`、`amdgcn.frexp.mant`、`amdgcn.frexp.exp`、`llvm.fma`、`llvm.fabs` 的调用匹配。保留原有同 callee、类型、调用属性、metadata、fast-math、convergent、immarg 等检查。不开放任意未知调用，不改评分权重，不扩大 scoped-cfg 清理。

frexp.exp 返回整数，读取 fast-math flags 前新增 FPMathOperator 检查。新增测试覆盖三种 AMD intrinsic 匹配、原始融合中选择指数并共享调用链、FMA/fabs 匹配、FMA 属性不兼容、convergent 与未知 intrinsic 拒绝；原有纹理 immarg 与单边调用保护测试仍通过。

## 静态结果

固定三步计划，均通过正常 enumerate 和 tryPair；这是指定树复测，不是完整自动贪心结果。

| 步骤 | 原匹配器每步收益 | 修复后每步收益 | 修复后函数 TTI |
|---|---:|---:|---:|
| baseline | — | — | 6402 |
| L4+L5 | -239 | +272 | 6130 |
| L6+L7 | -239 | +272 | 5858 |
| (L4,L5)+(L6,L7) | -347 | +271 | 5587 |

收益定义是同父状态 control 成本减去融合后 scoped-cfg 成本。搜索没有新增 O3。第一步是相同父状态对比；之后两条路径的父 IR 已不同。

| 整个函数统计 | baseline | 旧匹配器第一步 | 新匹配器第一步 | 新匹配器第三步 |
|---|---:|---:|---:|---:|
| 条件 br | 70 | 96 | 69 | 67 |
| 无条件 br | 44 | 97 | 43 | 41 |
| PHI | 32 | 91 | 32 | 32 |
| select | 65 | 77 | 78 | 105 |
| call | 410 | 409 | 382 | 326 |

新匹配器第一步 raw IR（尚未 scoped-cfg）已有 382 次 call、32 个 PHI、70 个条件 br、46 个无条件 br，说明调用共享直接发生在融合阶段。局部清理再将 br 降到 69/43。

修复后实际 IR 开头如下：
```llvm
%merged.select = select i1 %cmp29.i.i.i.i, i32 4, i32 8
%735 = tail call double @llvm.amdgcn.ldexp.f64(double %arrayidx.val, i32 %merged.select)
%736 = tail call double @llvm.amdgcn.frexp.mant.f64(double %735)
%737 = fcmp olt double %736, 0x3FE5555555555555
%738 = zext i1 %737 to i32
%739 = tail call double @llvm.amdgcn.ldexp.f64(double %736, i32 %738)
%740 = tail call i32 @llvm.amdgcn.frexp.exp.i32.f64(double %735)
```

两叶融合后现在是单个计算块，两个组继续通过 adjacent B2B 合并。复测脚本已改为根据实际单块/多块形态定位，不再固定要求 G 编号。

另运行一轮自动选择：structural=1、adjacent-only=0、scoped-cfg、LLVM24，116 次 trial、提交 1 次，选中 L6+L7（evaluate:B100:B101:B103），收益 +272，因 round_budget=1 停止。尚未宣称完整搜索收敛；这是通用 CFG 枚举，不是严格相邻专用模式。

## GPU 同批测量

gfx906，完整 Map-Airy，65,539 个固定输入；interval-mixture 和 coherent-blocks。每版 3 次预热、15 次测量，3 批轮换顺序；C++ HIP event。所有版本完整输出检查通过。最终代码生成保持公共 LLVM12 O3 流程。

| 版本 | 混合输入 μs | 连续分块输入 μs |
|---|---:|---:|
| baseline | 49.441 | 16.000 |
| 新匹配器：L45 | 46.560 | 16.160 |
| 新匹配器：L45 与 L67 | 43.680 | 16.160 |
| 新匹配器：L4567 | 40.480 | 16.640 |
| 旧匹配器：同样 L4567 | 41.120 | 16.800 |

新 L4567 在混合输入比 baseline 耗时降低 18.12%，比同批旧匹配器降低 1.56%。连续分块仍比 baseline 慢约 4%，不能说所有输入都受益。静态评分大幅改善并不等于 GPU 时间按相同比例改善：旧路径最终 O3 也消除了许多临时结构。

## 回归与证据

- TIGRE 完整自动搜索：2 次提交、19 次 trial；最终 IR 除 ModuleID 外一致，GPU 二进制与冻结版本字节一致。
- vLLM：32 组、224 次融合，搜索 summary 一致，GPU 二进制与冻结版本字节一致；未重新测量二进制相同的 vLLM/TIGRE 性能。
- CPU 正式成功日志：region-fusion-lab/work/mapairy-intrinsic-match-20261109-v6；初版编译/脚本定位失败日志仍保留。
- 本目录 steps-final：各步 raw 与 cleaned IR；steps.tsv：成本；ir-comparison.json：统计和 hash；pair-*：最终 IR/binary 与构建清单；measure：正确性与计时收据、CSV；summary.json：汇总；auto-round：独立一轮贪心记录。
- v1 是只开放 ldexp/frexp 的中间实验，收益 -125/-125/-207，不是最终结果。
