# 第 10a 步 可扩展的统一生成

起点为 `b7deb4ebf4b95f43927761c2ff0ce888ab83aa36`。实验在 epyc 的 `feature/dataflow-b2b` 上执行。设计见 [ALGORITHM.md](../../docs/dataflow-b2b/ALGORITHM.md)。逐档比较、LUD8、逐区域报价和语义差分见 [step10a.md](../../tests/dataflow-b2b/results/step10a.md)。

## 实现和验证

- 保留第 9 步配对目标的独立指令收益与需求集合。原区域某侧的必须保护操作全部获得配对时，计算该侧省去的控制和流出代价。两侧共用的分支只计一次。对数据相关和工作组一致的条件，最多比较四个逐次去掉最低净收益链的子集。
- 依赖分组后，12 组以内枚举，超过时逐组比较当前选择和翻转决定。拓扑列表调度同时评估公共指令优先和保护优先。它保留原有数据和副作用依赖，并允许多个保护菱形。新路径共用原有 IR 生成和评估器，使用原 SimplifyCFG 规则实现强制推测。
- 旧子集 DP 仅用于 `--compare-dp` 的固定配对对照。开发时修复了 LLVM 12 位向量重载的误用，并让空操作的区域实际执行一次调度。最终回归的 1264 次固定配对比较直接对照两条独立路径，零差异。
- 对三个访存区域的真实模式及 `4f045e74e33a` 的两种模式，使用无安全网结果验收。DCT8 上的新策略与 dataflow-exact 的整核 TTI 均为 44。用 18 条操作的 PCM32 隔离窗口验证新策略直接进入生成器并产生经过 verifier 的 IR。
- 原策略对照使用当前 LLVM 24 worker 对每个抽取函数独立运行。旧策略的尝试沿用每次 120 秒上限。报告同时列出每列自身覆盖范围和五列交集，避免把缺项计入总和。用有界解释器对各统一生成方案与对应原始 IR 差分。

## 命令

```sh
set -o pipefail
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=24 tests/dataflow-b2b/run-regression.sh \
    2>&1 | tee build/dataflow-corpus/step10a/regression.log

export LD_LIBRARY_PATH="$HOME/v2-runtime/toolchains/llvm12-jammy/usr/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
python3 -u tests/dataflow-b2b/measure_generation.py \
    build/dataflow-regression/run.fSczr6/scalable/small.json \
    build/dataflow-corpus/step10a/corpus-final tests/dataflow-b2b/results --jobs 24
```

保留策略复跑沿用第 9 步的输入和命令，在 DCT8、PCM32 分别调用 `decision-greedy --b2b-strategy anchor|darm|dataflow-exact`，重新运行 verifier 和整核报价，逐行比较最终 IR（跳过 ModuleID）。

```text
DCT8 anchor: 62, verifier OK, final IR matches Step 8
DCT8 darm: 44, verifier OK, final IR matches Step 8
DCT8 dataflow-exact: 44, verifier OK, final IR matches Step 8
PCM32 anchor: 1136, verifier OK, final IR matches Step 8
PCM32 darm: 1136, verifier OK, final IR matches Step 8
PCM32 dataflow-exact: 1130, verifier OK, final IR matches Step 8
18-operation B2B: handler=dataflow_solver candidates=3 choice=fuse verifier=True
```

## 语料库结果

124/125 个 medium 和 62/63 个 large 区域完成生成和报价。两处错误分别核对了 LLVM 24 worker 的原始行。`989fc49dfa13` 的 lifetime 标记在读入时升级，逐指令报价顺序无法对齐，`quant_decide` 也没有整调用报价。`696f915b5378` 的内联汇编没有可接受的报价。

起跑后将语义差分改为按候选文件并行。保留已经完成的生成结果，用 32 个解释器并发读取同一批 IR。每个通过方案在条件真、假下各完成 1000 个输入。6 个不支持项属于 4 个区域，原因按方案保存在 TSV 中，没有观察到结果不一致。

最大区域 `25146e46e0f2` 有 6,145 条操作。新配对生成有结果，最高分配对的生成耗时约 145 秒。该区域的原 anchor 尝试触及 120 秒上限，统计交集时剔除此项，DARM 和新配对的有效报价仍计入各列自身总和。

```text
Generation complete: 374 small mode/region and 188 medium/large
Semantic statuses: {'pass': 1845, 'unsupported': 6}
Semantic trials: 1851
```

## 一键回归完整输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.fSczr6
Build and tool setup: 101 s

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

== Scalable vs subset DP ==
Scalable vs DP: 374/374 region/mode runs; 1264 fixed-plan comparisons, 0 raw differences

== Pairing goals ==
OK 00bc16cfd8ae/real: min=[6, 6, 6]; §7.2=[6, 6, 6]; truth min_D=6; truth §7.2=[6, 6, 6]
OK e3b15e5220a0/real: min=[6, 6, 6]; §7.2=[6, 6, 6]; truth min_D=6; truth §7.2=[6, 6, 6]
OK ed0b563f1288/real: min=[6, 6, 6]; §7.2=[6, 6, 6]; truth min_D=6; truth §7.2=[6, 6, 6]
OK 4f045e74e33a/abstract: min=[19, 19, 19]; §7.2=[23, 15, 15]; truth min_D=19; truth §7.2=[23, 15, 15]
OK 4f045e74e33a/real: min=[19, 19, 19]; §7.2=[23, 14, 14]; truth min_D=19; truth §7.2=[23, 14, 14]

== Summary ==
Micro: 50/50 (2.53 s)
Fold oracle: 376/376 (0.45 s)
Small truth: 374/374 (2.13 s)
Context: 1/1 (0.20 s)
Dataflow context: 2/2 (0.44 s)
Scalable vs subset DP: 374/374 (1.11 s)
Pairing goals: 4/4 (0.04 s)
Total: 1181/1181 (6.90 s)
```
