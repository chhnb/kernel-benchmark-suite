# 第 10a″ 步 凸包保护与固定配对诊断

起点为 `9f1bb864ed457eb386595969eb057358c2bc8577`。在 epyc 的 `feature/dataflow-b2b` 上执行。设计见 [ALGORITHM.md](../../docs/dataflow-b2b/ALGORITHM.md)。逐区域 IR 诊断、五种组合和语义差分见 [step10a3.md](../../tests/dataflow-b2b/results/step10a3.md)。

## 修改前的只读诊断

读取第 10a 步 `build/dataflow-regression/run.fSczr6/scalable/small.json` 与第 10a′ 步 `build/dataflow-regression/run.Wgkitj/scalable/small.json`。比较 `generated_minimum`、`minimum`、`selected` 以及每个后备区域的控制项。两个方案的固定配对列各出现 433 点差额，由同一批 34 个线程模式区域组成。

对十二个指定区域逐一比较 `anchor/cleaned.ll` 和旧统一方案 `anchor-0.ll`。分别执行 LLVM 12 EarlyCSE 和 InstCombine，使用 LLVM 24 worker 重新报价。以 `338511bb` 一类为例，共用操作数从两臂的 add 提出到一个 add。四个 OR 区域缩减一个互补 select。两个向量区域由 EarlyCSE 消除重复的 insertelement，再折叠两个等臂 select。

```sh
diff -u "$solution/anchor-0.ll" "$solution/anchor/cleaned.ll"
"$LLVM12_BIN/opt" -enable-new-pm=0 -early-cse -S "$solution/anchor-0.ll" -o "$cse"
"$LLVM12_BIN/opt" -enable-new-pm=0 -instcombine -S "$solution/anchor-0.ll" -o "$ic"
build/llvm24-tti/evaluate_cost "$ic" docs/dataflow-b2b/COST_TABLE.json \
    --cost=real --after-cleanup --output-buffer
```

```text
anchor 34 Counter({('thread-pattern', 1, 2, 13): 30, ('thread-pattern', 1, 2, 14): 3, ('thread-pattern', 1, 1, 1): 1})
[('02248205bd', [17, 17, 7], [30, 30, 19], 1, 2), ('1df5acddcf', [17, 17, 7], [30, 30, 19], 1, 2)]
dataflow 34 Counter({('thread-pattern', 1, 2, 13): 30, ('thread-pattern', 1, 2, 14): 3, ('thread-pattern', 1, 1, 1): 1})
[('02248205bd', [17, 17, 7], [30, 30, 19], 1, 2), ('1df5acddcf', [17, 17, 7], [30, 30, 19], 1, 2)]
338511bb data baseline [28, 20, 20] orig [11, 11, 11] generated [12, 12, 12] best [12, 12, 12] layout linear pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'add': 1} {}
3dbb995f data baseline [28, 19, 19] orig [11, 11, 11] generated [12, 12, 12] best [12, 12, 12] layout linear pairs [{'left_index': 1, 'right_index': 1, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}, {'left_index': 4, 'right_index': 4, 'swapped_operands': False}] delta ops {'add': 1} {}
47a5aacc data baseline [26, 18, 18] orig [9, 9, 9] generated [10, 10, 10] best [10, 10, 10] layout linear pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'add': 1} {}
8d4c093c data baseline [26, 18, 18] orig [9, 9, 9] generated [10, 10, 10] best [10, 10, 10] layout linear pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'add': 1} {}
9fe145d5 data baseline [28, 20, 20] orig [11, 11, 11] generated [12, 12, 12] best [12, 12, 12] layout linear pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'add': 1} {}
d3272a2c data baseline [28, 19, 19] orig [11, 11, 11] generated [12, 12, 12] best [12, 12, 12] layout linear pairs [{'left_index': 1, 'right_index': 1, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}, {'left_index': 4, 'right_index': 4, 'swapped_operands': False}] delta ops {'add': 1} {}
45bc4cdf data baseline [28, 20, 20] orig [12, 12, 12] generated [13, 13, 13] best [13, 13, 13] layout segmented pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 1, 'right_index': 1, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'select': 1} {}
62757562 data baseline [28, 20, 20] orig [11, 11, 11] generated [12, 12, 12] best [12, 12, 12] layout segmented pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 1, 'right_index': 1, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'select': 1} {}
849d0a2a data baseline [28, 20, 20] orig [11, 11, 11] generated [12, 12, 12] best [12, 12, 12] layout segmented pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 1, 'right_index': 1, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'select': 1} {}
f90cffb7 data baseline [28, 20, 20] orig [11, 11, 11] generated [12, 12, 12] best [12, 12, 12] layout segmented pairs [{'left_index': 0, 'right_index': 0, 'swapped_operands': False}, {'left_index': 1, 'right_index': 1, 'swapped_operands': False}, {'left_index': 2, 'right_index': 2, 'swapped_operands': False}, {'left_index': 3, 'right_index': 3, 'swapped_operands': False}] delta ops {'select': 1} {}
1bae2080 data baseline [59, 55, 55] orig [42, 42, 42] generated [46, 46, 46] best [46, 46, 46] layout linear pairs [] delta ops {'insertelement': 4, 'select': 2} {}
6fb506a6 data baseline [59, 55, 55] orig [42, 42, 42] generated [46, 46, 46] best [46, 46, 46] layout linear pairs [] delta ops {'insertelement': 4, 'select': 2} {}
338511bb
early-cse [12, 12, 12] {'instruction': 4, 'memory': 1, 'select': 7}
instcombine [11, 11, 11] {'instruction': 3, 'memory': 1, 'select': 7}
3dbb995f
early-cse [12, 12, 12] {'instruction': 4, 'memory': 1, 'select': 7}
instcombine [11, 11, 11] {'instruction': 3, 'memory': 1, 'select': 7}
47a5aacc
early-cse [10, 10, 10] {'instruction': 4, 'memory': 1, 'select': 5}
instcombine [9, 9, 9] {'instruction': 3, 'memory': 1, 'select': 5}
8d4c093c
early-cse [10, 10, 10] {'instruction': 4, 'memory': 1, 'select': 5}
instcombine [9, 9, 9] {'instruction': 3, 'memory': 1, 'select': 5}
9fe145d5
early-cse [12, 12, 12] {'instruction': 4, 'memory': 1, 'select': 7}
instcombine [11, 11, 11] {'instruction': 3, 'memory': 1, 'select': 7}
d3272a2c
early-cse [12, 12, 12] {'instruction': 4, 'memory': 1, 'select': 7}
instcombine [11, 11, 11] {'instruction': 3, 'memory': 1, 'select': 7}
45bc4cdf
early-cse [13, 13, 13] {'instruction': 2, 'memory': 1, 'select': 10}
instcombine [12, 12, 12] {'instruction': 2, 'memory': 1, 'select': 9}
62757562
early-cse [12, 12, 12] {'instruction': 3, 'memory': 1, 'select': 8}
instcombine [11, 11, 11] {'instruction': 3, 'memory': 1, 'select': 7}
849d0a2a
early-cse [12, 12, 12] {'instruction': 3, 'memory': 1, 'select': 8}
instcombine [11, 11, 11] {'instruction': 3, 'memory': 1, 'select': 7}
f90cffb7
early-cse [12, 12, 12] {'instruction': 3, 'memory': 1, 'select': 8}
instcombine [11, 11, 11] {'instruction': 3, 'memory': 1, 'select': 7}
1bae2080
early-cse [42, 42, 42] {'instruction': 0, 'select': 42}
instcombine [46, 46, 46] {'instruction': 0, 'select': 46}
6fb506a6
early-cse [42, 42, 42] {'instruction': 0, 'select': 42}
instcombine [46, 46, 46] {'instruction': 0, 'select': 46}
```

## 生成与口径

- 生成对每侧构造独立的依赖边集合，作保护端点的正向和反向到达交集。全推测、必须保护凸包、全保护、每个最小割及其凸包分别交给同一拓扑阶段调度并报价。共同节点仍保留在公共阶段。
- 空配对的全保护候选克隆原 CFG 和指令顺序，实际验证并重新计价。回归比较固定空配对实际生成的最低 (T_D)。对无报价的三个区域记录原 worker 原因。
- 各档可以比较清理后的候选，输出缓冲 ABI 沿用上一步验证方式。独立 DP 对拍继续比较清理前的共同成本模型。交叉表用固定配对实际生成的最低报价，只有策略列可以使用保留原区域方案。
- 新增 14 个固定 anchor 配对的回归门槛，涵盖十二个已诊断的 small 区域和两个必过的 large 区域。

## 运行命令

```sh
set -o pipefail
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=32 tests/dataflow-b2b/run-regression.sh \
    2>&1 | tee build/dataflow-corpus/step10a3/regression.log
export LD_LIBRARY_PATH="$HOME/v2-runtime/toolchains/llvm12-jammy/usr/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
python3 -u tests/dataflow-b2b/measure_generation.py \
    build/dataflow-corpus/step10a3/quick.1g8fnssv/scalable/small.json \
    build/dataflow-corpus/step10a3/corpus-final tests/dataflow-b2b/results \
    --jobs 32 --stage step10a3 --diagnosis build/dataflow-corpus/step10a3/diagnosis.md
```

## 全语料初跑后的调整

初跑在 372 个可比区域中定位到唯一一处最小 (T_D) 退化。固定配对的 `43688e8d` 在相同的两个保护菱形下多产生三个流出 PHI。将每条源臂的指令顺序作为另一个可选调度，在无环且菱形数仍等于原依赖图下界时纳入报价。该区域的流出数由 7 降到 4，报价由 `(89,23,89)` 降到与 anchor 一致的 `(86,20,86)`。该例加入回归，最终共 15 项固定配对门槛。

## 最终验证命令

```sh
set -o pipefail
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=32 tests/dataflow-b2b/run-regression.sh \
    2>&1 | tee build/dataflow-corpus/step10a3/regression-final.log
export LD_LIBRARY_PATH="$HOME/v2-runtime/toolchains/llvm12-jammy/usr/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
python3 -u tests/dataflow-b2b/measure_generation.py \
    build/dataflow-regression/run.bWvz5w/scalable/small.json \
    build/dataflow-corpus/step10a3/corpus-verified tests/dataflow-b2b/results \
    --jobs 32 --stage step10a3 --diagnosis build/dataflow-corpus/step10a3/diagnosis.md \
    | tee build/dataflow-corpus/step10a3/corpus-verified.log
```

最终回归工作目录为 `build/dataflow-regression/run.kHu2lc`。全语料汇总复用较早的 small 文件并重跑 medium 和 large。源臂顺序的备选调度只在非 small 档启用。逐文件核对确认最终回归的 949 个逐区域 IR 和选择向量完全复现，结果保存在 `small-repro.log`。

373 个可报价区域的空配对最低 (T_D) 均不高于输入。固定 anchor 配对时，372 个可比区域的最低 (T_D) 均未上升，分别为 small 187、medium 124、large 61。包含 6,145 条操作的 `25146e46e0f2` 有统一生成结果，anchor 原生成在 120 秒时超时。其余三个区域没有可用的 LLVM 24 报价，原因见结果报告。两个指定的 large 区域各降低 27 点。语义差分 2,744 项通过，8 项不支持，0 项不一致。逐方案的解释器路径、样本和限制见 [step10a3-semantics.tsv](../../tests/dataflow-b2b/results/step10a3-semantics.tsv)。

DCT8 和 PCM32 上保留策略的最终 IR 与第 8 步一致，LLVM verifier 均通过。最终 TTI 如下。


```text
DCT8 anchor: 62, verifier OK, final IR matches Step 8
DCT8 darm: 44, verifier OK, final IR matches Step 8
DCT8 dataflow-exact: 44, verifier OK, final IR matches Step 8
PCM32 anchor: 1136, verifier OK, final IR matches Step 8
PCM32 darm: 1136, verifier OK, final IR matches Step 8
PCM32 dataflow-exact: 1130, verifier OK, final IR matches Step 8
```

## 最终回归完整输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.kHu2lc
Build and tool setup: 103 s

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

== Empty pairing ==
Unpriced 696f915b5378: unsupported: missing LLVM24 quote for call
Unpriced 989fc49dfa13: LLVM24 instruction quote order mismatch
Unpriced b670a987cbd0: unsupported: missing LLVM24 quote for call
Empty pairing generated T_D <= input T_D: small 187/187, medium 124/124, large 62/62

== Anchor parity goals ==
OK 1bae2080fbe9: generated [42, 42, 42]; anchor [42, 42, 42]
OK 338511bb95c6: generated [11, 11, 11]; anchor [11, 11, 11]
OK 3dbb995f4893: generated [11, 11, 11]; anchor [11, 11, 11]
OK 45bc4cdfb47b: generated [12, 12, 12]; anchor [12, 12, 12]
OK 47a5aaccc3c5: generated [9, 9, 9]; anchor [9, 9, 9]
OK 62757562d594: generated [11, 11, 11]; anchor [11, 11, 11]
OK 6fb506a6f70e: generated [42, 42, 42]; anchor [42, 42, 42]
OK 849d0a2aa129: generated [11, 11, 11]; anchor [11, 11, 11]
OK 8d4c093cff43: generated [9, 9, 9]; anchor [9, 9, 9]
OK 9fe145d5cce8: generated [11, 11, 11]; anchor [11, 11, 11]
OK d3272a2c8735: generated [11, 11, 11]; anchor [11, 11, 11]
OK f90cffb7d42b: generated [11, 11, 11]; anchor [11, 11, 11]
OK 43688e8df875: generated [86, 20, 86]; anchor [86, 20, 86]
OK 5e412ddb9d19: generated [866, 472, 470]; anchor [893, 485, 482]
OK 79ff52d933cd: generated [1698, 888, 886]; anchor [1725, 901, 898]

== Summary ==
Micro: 50/50 (2.27 s)
Fold oracle: 376/376 (0.37 s)
Small truth: 374/374 (2.03 s)
Context: 1/1 (0.21 s)
Dataflow context: 2/2 (0.46 s)
Scalable vs subset DP: 374/374 (1.10 s)
Pairing goals: 4/4 (0.04 s)
Empty pairing: 373/373 (2.03 s)
Anchor parity goals: 15/15 (7.71 s)
Total: 1569/1569 (16.23 s)
```
