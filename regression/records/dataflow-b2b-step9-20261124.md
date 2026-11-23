# 第 9 步 Dataflow 配对阶段

起点为 `130066a23864b693409ab155af2d2f4f42e5b9b1`，实验在 epyc 的 `feature/dataflow-b2b` 上执行。设计见 [ALGORITHM.md](../../docs/dataflow-b2b/ALGORITHM.md)，分布、逐区域诊断、交叉报价和分量测量见 [step9.md](../../tests/dataflow-b2b/results/step9.md)。

## 实现及实验口径

- 新策略有三组配对输入。新算法用参考求解器的兼容条件建图，小分量做分支定界，大分量运行三个起点的双向扩展和局部改进。配对阶段按指令、需求和输出选择计费。合并分量时执行全局一对一和无环检查。
- anchor 的配对由选中布局的源操作索引和交换位给出。DARM 的左右源指令映射到同一条产物且映射完整时，记录其位置对应。这两项是对现有生成的只读观测。两种安全网及原生成报价都在同一个抽取函数上取样。上下文中取得的条件来源用于 §7.2 选择。三角形上的原策略列为保持原样，统一生成列用空配对运行参考生成器。
- 三组配对使用同一个参考生成器、Fold oracle、子集 DP 和评估器。统一生成的交叉报价取该配对自身生成的最小 $T_D$；真值对比和新策略选择另允许保留原始区域。16 条指令是现有生成器上限，超限的 B2B 候选记录原因并回退到 anchor。
- 首轮发现 void 配对的“无产出”哨兵被用作 LLVM DenseSet 的查询键，已在上界计算中跳过。长区域还触及持久 TTI 连接的回复上限，改为按操作数形态去重、分批报价，需求集合仍按原始值对去重。复跑覆盖全部 125 个 medium 和 63 个 large。唯一未能完成统一生成报价的 medium 是 `989fc49dfa13`，包含 LLVM 读入时升级的 lifetime intrinsic 以及无整调用报价的普通调用 `quant_decide`。
- 真实模式下安全网修复了 3 个纯配对目标看不到控制收益的区域。剩余一个 §7.2 差距同时出现在两种计价模式中，`4f045e74e33a` 的最小 $T_D$ 不受影响，满足两侧约束的真值需要只配后一对 `fmul`。比较阶段保留该差距作为结果。

## 运行命令

```sh
set -o pipefail
KBS_DATAFLOW_JOBS=24 DECISION_GREEDY_JOBS=8 tests/dataflow-b2b/run-regression.sh \
    2>&1 | tee build/dataflow-corpus/step9/regression-verified.log

export LD_LIBRARY_PATH="$HOME/v2-runtime/toolchains/llvm12-jammy/usr/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
python3 -u tests/dataflow-b2b/measure_pairing.py \
    build/dataflow-regression/run.WjqM7g/dataflow/small.json \
    build/dataflow-corpus/step9/research-final tests/dataflow-b2b/results --jobs 24

build/llvm24-tti/dataflow_solver tests/dataflow-b2b/corpus/regions/d23a7c228c5b39f95910f0b1d4eb8b9318e5c775.ll \
    docs/dataflow-b2b/COST_TABLE.json "$out" --cost=real --condition-source=data
```

基线复核以第 8 步相同输入调用 `build/decision-fuse/decision-greedy INPUT FUNCTION "$PWD" OUT --b2b-strategy STRATEGY --ir-snapshots compact`，用 LLVM 12 verifier 检查最终 IR，独立运行 `tools/run-llvm24-tti`，并逐行比较最终 IR（跳过 ModuleID）。规模回退用第 4b 步检查的 18 指令版本，比较 anchor 与 dataflow 的布局、裁决和清理后 IR。

```text
DCT8 anchor: 62, verifier OK, final IR matches Step 8
DCT8 darm: 44, verifier OK, final IR matches Step 8
DCT8 dataflow-exact: 44, verifier OK, final IR matches Step 8
PCM32 anchor: 1136, verifier OK, final IR matches Step 8
PCM32 darm: 1136, verifier OK, final IR matches Step 8
PCM32 dataflow-exact: 1130, verifier OK, final IR matches Step 8
pair trial verified; static_score=1.217765e-02; eligible=1; semantic validation not run
pair trial verified; static_score=1.217765e-02; eligible=1; semantic validation not run
{'cleaned_kernel_cost': 1379, 'condition_source': 'data', 'extracted_operations': 18, 'handler': 'anchor_fallback', 'kind': 'b2b-diamond', 'operations': 18, 'raw_kernel_cost': 1399, 'region_id': '74e896b3cf18ac78f0d51f3aaf97cae525e8aa12', 'solver_reason': 'generation size limit', 'strategy': 'dataflow'}
Step 9: 374 small runs, 188 medium/large pairing-only runs, 25 medium generator runs
```

## 一键回归完整输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.WjqM7g
Build and tool setup: 99 s

== Micro ==
opt: /data/home/chh/v2-runtime/toolchains/llvm12-jammy/usr/lib/llvm-12/bin/opt (Ubuntu LLVM version 12.0.1)
clang: /data/home/chh/v2-runtime/toolchains/llvm12-jammy/usr/lib/llvm-12/bin/clang (host x86_64-pc-linux-gnu)
01-crossed: verifier OK; C=1 6b1c3922df6a7ab6; C=0 87e3ac6d58d77c83
02-commute: verifier OK; C=1 edb6504df871c973; C=0 85bbe769795159f8
03-cmp-swap: verifier OK; C=1 fff31be52166112b; C=0 b1302703081ef135
04-select-select-diff: verifier OK; C=1 10a2416e48451a87; C=0 0dffb72c07067aee
05-select-select-shared: verifier OK; C=1 54e8ec84a9700d4e; C=0 18a2eb0795494d02
06-shared-select: verifier OK; C=1 383ba327cda15bee; C=0 b62260356afa19ff
07-guard-cluster: verifier OK; C=1 5b20989f77639f1a; C=0 aa19897a2e9ad6b0
08-fold-threshold-7: verifier OK; C=1 c74be684101036de; C=0 adda3eea769e0ba7
08-fold-threshold-8: verifier OK; C=1 d1bc9398ca026227; C=0 adda3eea769e0ba7
09-phi-count-3: verifier OK; C=1 10f251d99cbbe980; C=0 5ca82495f17ae8ec
09-phi-count-4: verifier OK; C=1 0a7b9d10456557ce; C=0 84194d59d26ef8f6
10-unsafe: verifier OK; C=1 92d53cf868868696; C=0 3893f48e5e105c0d
11-mem-order: verifier OK; C=1 3d671316131fac2e; C=0 3ac8e9c84f6fa218
12-convergent: verifier OK; host skipped (convergent)
13-fallback: verifier OK; C=1 1defdf3390a93d0d; C=0 3b25314ffeb61478
14-user-example: verifier OK; C=1 d561bf55b449bb51; C=0 f3f8341e7d7a083d
OK: 16 verifiers and expectations; 15 native runs (1000 samples per condition); 1 host skip
fixtures: 16/16
01-crossed/original: [19, 12, 12]
01-crossed/pair-both-chains: [9, 9, 9]
02-commute/original: [12, 8, 8]
02-commute/positional: [6, 6, 6]
02-commute/commuted: [5, 5, 5]
03-cmp-swap/original: [14, 9, 9]
03-cmp-swap/swap-predicate: [7, 7, 7]
03-cmp-swap/speculate-comparisons: [7, 7, 7]
04-select-select-diff/original: [12, 9, 7]
04-select-select-diff/speculate-selects: [9, 9, 9]
04-select-select-diff/merge-selects: [10, 10, 10]
05-select-select-shared/original: [14, 9, 9]
05-select-select-shared/merge-selects: [6, 6, 6]
05-select-select-shared/speculate-selects: [7, 7, 7]
06-shared-select/original: [12, 8, 8]
06-shared-select/reuse-input-select: [5, 5, 5]
07-guard-cluster/original: [26, 24, 8]
07-guard-cluster/cluster-divides: [23, 23, 7]
07-guard-cluster/split-divides: [26, 26, 10]
08-fold-threshold-7/original: [8, 8, 8]
08-fold-threshold-8/original: [12, 12, 4]
08-fold-threshold-8/speculate-chain: [9, 9, 9]
09-phi-count-3/original: [9, 9, 9]
09-phi-count-3/pair-operations: [4, 4, 4]
09-phi-count-4/original: [13, 10, 10]
09-phi-count-4/pair-operations: [5, 5, 5]
10-unsafe/original: [17, 17, 5]
11-mem-order/original: [12, 12, 4]
12-convergent/original: [5, 5, 4]
13-fallback/original: [16, 12, 8]
14-user-example/original: [3, 3, 3]
14-user-example/positional: [3, 3, 3]
14-user-example/commuted: [2, 2, 2]
14-user-example/speculate-both: [3, 3, 3]
34 schemes verified and priced
schemes: 34/34

== Fold oracle ==

== Small truth ==
Excluded b670a987cbd0: ordinary call has no accepted quote in either mode
abstract: 187/187
real: 187/187

== Context ==
DCT8 dataflow-exact kernel TTI: 44

== Dataflow context ==
DCT8 d23a7c228c5b: sext and sdiv paired; T=[9, 9, 9]
DCT8 dataflow kernel TTI: 44

== Dataflow vs truth (report only) ==
abstract without safety net: min T_D optimum 187/187 [0=187]; §7.2 optimum 186/187 [0=186, 2=1]; §7.2 T match 186/187 [(0, 0, 0)=186, (2, 0, 0)=1]
abstract with safety net: min T_D optimum 187/187 [0=187]; §7.2 optimum 186/187 [0=186, 2=1]; §7.2 T match 186/187 [(0, 0, 0)=186, (2, 0, 0)=1]
abstract minimum_winner: dataflow=78, original=109
abstract winner: dataflow=39, original=148
real without safety net: min T_D optimum 184/187 [0=184, 15=3]; §7.2 optimum 183/187 [0=183, 2=1, 15=3]; §7.2 T match 183/187 [(0, 0, 0)=183, (2, 0, 0)=1, (15, 9, 9)=3]
real with safety net: min T_D optimum 187/187 [0=187]; §7.2 optimum 186/187 [0=186, 2=1]; §7.2 T match 186/187 [(0, 0, 0)=186, (2, 0, 0)=1]
real minimum_winner: anchor=3, dataflow=87, original=97
real winner: anchor=3, dataflow=50, original=134
REPORT abstract/4f045e74e33a6f957716f7dc10142278050a1d6f (0, (2, 0, 0)): §7.2 配对为 [(0, 0, 'R1'), (1, 3, 'R1'), (2, 2, 'R1')]，历史前沿达到目标的配对为 [[(2, 2, 'R1')]]；共用生成器已枚举当前配对。
REPORT real/00bc16cfd8ae8b9fd56b51b66aeeb3eeb49c6052 (15, (15, 9, 9)): D 配对为 []，历史前沿达到目标的配对为 [[(0, 0, 'R1')]]；共用生成器已枚举当前配对，各分量配对收益为 0，生成后本可获得的控制收益未进入配对目标。§7.2 配对为 []，历史前沿达到目标的配对为 [[(0, 0, 'R1')]]；共用生成器已枚举当前配对，各分量配对收益为 0，生成后本可获得的控制收益未进入配对目标。
REPORT real/4f045e74e33a6f957716f7dc10142278050a1d6f (0, (2, 0, 0)): §7.2 配对为 [(0, 0, 'R1'), (1, 3, 'R1'), (2, 2, 'R1')]，历史前沿达到目标的配对为 [[(2, 2, 'R1')]]；共用生成器已枚举当前配对。
REPORT real/e3b15e5220a0d47675fb5ee8d7a3ee4f4a995ef5 (15, (15, 9, 9)): D 配对为 []，历史前沿达到目标的配对为 [[(0, 0, 'R1')]]；共用生成器已枚举当前配对，各分量配对收益为 0，生成后本可获得的控制收益未进入配对目标。§7.2 配对为 []，历史前沿达到目标的配对为 [[(0, 0, 'R1')]]；共用生成器已枚举当前配对，各分量配对收益为 0，生成后本可获得的控制收益未进入配对目标。
REPORT real/ed0b563f12883adfc22df149315b6f16661424f1 (15, (15, 9, 9)): D 配对为 []，历史前沿达到目标的配对为 [[(0, 0, 'R1')]]；共用生成器已枚举当前配对，各分量配对收益为 0，生成后本可获得的控制收益未进入配对目标。§7.2 配对为 []，历史前沿达到目标的配对为 [[(0, 0, 'R1')]]；共用生成器已枚举当前配对，各分量配对收益为 0，生成后本可获得的控制收益未进入配对目标。
Dataflow vs truth: report only (0.98 s)

== Summary ==
Micro: 50/50 (2.31 s)
Fold oracle: 376/376 (0.42 s)
Small truth: 374/374 (2.08 s)
Context: 1/1 (0.21 s)
Dataflow context: 2/2 (0.50 s)
Total: 803/803 (6.51 s)
```
