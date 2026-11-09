# Hypersonic L1＋L2：必经 load 前移与多锚点试融合

本次新增可选的 C++ 实现 `--complete-leaf-plan 1`，默认关闭；LLVM12 负责融合，LLVM24 TTI 权重和最终 LLVM12 O3 代码生成保持不变。这是固定 L1＋L2 候选的验证，没有运行完整贪心搜索收敛。

## 实现范围

1. 将无环、只读叶子中**必定执行**的普通 load 及其独立地址计算提取到叶子前缀。依赖必须已在入口可用，或者同属可前移依赖链。非必经 load 不前移；volatile、atomic、写内存、不可安全跨越的调用禁止这项移动。
2. 从两侧的无条件出口基本块生成匹配对，以原 DARM BB 相似度乘较短侧指令数排序；每个原块最多使用一次。不跨越已有先后关系配对，防止引入循环。这不是按最终 TTI 收益穷举所有锚点方案。
3. 为互斥锚点建立共同入口与返回路径，保留原来的可达性条件。直接复用原始叶子选择条件，使用 SSAUpdater 修复跨路径的值传递，然后调用**原生 RegionMelder** 做指令对齐和融合。没有投机执行原本不应执行的 optional load。
4. 四对锚点都在同一次 trial 中完成，中途不做独立收益门槛。最后运行 `scoped-cfg-triangles`，统一 verifier、局部清理审计和 LLVM24 TTI 评分。

这是“必经 load 依赖链前移＋多个受保护 B2B 锚点”的保守实现，尚不是任意 SESE 单元重排或任意 CFG 拓扑匹配。convergent/noduplicate 调用、循环、写内存等受限情形不会通过这条路径。

## L1＋L2 实际匹配

提取/前移 22 条指令，完成四对锚点：

- `if.then7.i198` ＋ `if.then7.i`：第一组边界计算；
- `if.then17.i270` ＋ `if.then17.i`：含 fdiv/fmul 的边界计算；
- 两个 `leaf.load.prefix`：独立取值和地址计算；
- `if.end27.i280` ＋ `if.end27.i`：普通取值。

原方案只共享一对锚点中的四次 load；新方案共享了更多计算，但原叶子的其余判断仍存在，且为返回各自后续路径增加了控制流和 PHI。

| 清理后指标 | 旧单锚点 | 新多锚点 |
|---|---:|---:|
| 基本块 | 59 | 67 |
| 指令数 | 796 | 764 |
| 条件 br | 32 | 36 |
| PHI | 18 | 44 |
| select | 42 | 39 |
| LLVM24 TTI 成本 | 1913 | 1823 |
| 相对 control=1915 的收益 | +2 | +92 |

评分权重没有修改。静态收益变大，不代表新增控制流没有成本；它们已经计入总成本。

相对旧单锚点，当前函数中 `fdiv` 从 21 降到 18、`fmul` 从 212 降到 196、load 从 44 降到 33、call 从 42 降到 35。这证实新增共享已经覆盖计算，而不只是那四次 load。

## 正式计时结果：每个输入独立进程

GPU 为 AMD gfx906。两组原有冻结输入，完整 Hypersonic kernel，GPU event 计时；每批 3 次预热＋15 次测量，共 3 批，轮换版本顺序。下表是三批中位数的中位数，单位 μs。

| 版本 | 输入 step1 | 输入 step24 | 相对 baseline 耗时下降 |
|---|---:|---:|---:|
| baseline | 1808.642 | 1808.962 | 0.00% / 0.00% |
| 旧单锚点＋短分支清理 | 1738.402 | 1738.722 | 3.88% / 3.88% |
| 新多锚点＋短分支清理 | 1720.802 | 1721.921 | 4.86% / 4.81% |

新版本相对旧单锚点进一步减少耗时 1.01% / 0.97%。这轮观察到小幅额外收益，不能把全部约 4.8% 归因于本次新增能力。

三个版本都使用同一个独立进程 runner；只改变输入生命周期，不改变 kernel 输入、launch、计时区间或完整输出比较。每个输入先独立验证，再进行上述计时；所有正式批次的完整输出、保护区和只读输入检查均通过。

## 必须保留的异常记录

首版在原 suite runner 中完成两组输入的验证；随后计时在 step1 完成 18 次完整检查后、step24 开始前，出现一次 GPU memory access fault，整轮结果作废，未把成功片段混入正式结果。

之后增加分配、释放、launch 和模块卸载日志的独立诊断 runner，以相同二进制完成两组各 18 次检查，未复现。将原始 IR 转成 CPU 诊断版本（用主机函数模拟 AMD intrinsic）后，带保护页的 30,000 个边界及随机位置比较也通过。

首版用新 PHI 表示锚点来源；当前版直接复用原始叶子选择条件，减少了 3 个 PHI，静态收益从 +89 到 +92。但二者最终 GPU 二进制完全相同，**不能把条件改写说成访问错误的修复**。

首次错误根因仍未确认。正式计时因此采用每个输入独立进程的协议，不再在同一进程中卸载模块后继续下一组输入；原 suite runner 保持原样。新能力仍为显式实验选项，不能声称原协议中的错误已解决。

## 验证与使用

- 新 CPU fixture：644 组比较，包含未选路径空指针、未选路径零除数；另验证 convergent 调用被拒绝、父模块不变、其他函数不变。
- 已有 complete-leaf：12,006 组输入比较通过。
- 已有短分支清理、gap 分组回归通过。
- LLVM verifier、无新增循环检查、局部清理审计通过。

在 musa 的 `/home/chh/kernel-benchmark-suite` 中使用：

~~~bash
build/llvm24-tti/fusion-search-llvm24   --ir experiments/hypersonic-complete-leaf-20261109-v1/input.ll   --function face_kernel   --structural 1 --complete-leaf-plan 1 --coalesce-gaps 1   --cleanup scoped-cfg-triangles --scorer llvm24   --split B7 --left E8_23 --right E15_23   --debug-dir /tmp/hypersonic-multi-trial   --out /tmp/hypersonic-multi.ll
~~~

输出位置应使用尚不存在的路径。主实现为 `tools/fusion_search.cpp`，接口在 `tools/fusion_search.h`，参数和调试输出在 `tools/fusion_search_llvm24_main.cpp`；回归为 `tests/postopt/complete-leaf-plan/`。

实验材料保存在 `experiments/hypersonic-multi-anchor-20261109-v1/`。其中 `measure/` 保留首次失败，`gpu-diagnostic/trace/` 为带日志诊断，`outer-selector/` 为当前变换，`isolated-fixture/` 为正式独立进程结果。报告本身包含分析所需的主要数据，不需要打开这些文件才能理解结论。
