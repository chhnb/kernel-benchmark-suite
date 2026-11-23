# 第 10a′ 步 最小割布置与大区域诊断

起点为 `1041678695cb94ade8246d957301f025aef879a1`。在 epyc 的 `feature/dataflow-b2b` 上执行。设计见 [ALGORITHM.md](../../docs/dataflow-b2b/ALGORITHM.md)。逐区域诊断、五种组合和语义差分见 [step10a2.md](../../tests/dataflow-b2b/results/step10a2.md)。

## 修改前的只读诊断

从第 10a 步在 `build/dataflow-corpus/step10a/corpus-final/other.json` 保存的结果读取 anchor 的左右操作索引和操作数对应关系。对三个区域重放选中的 anchor 布局，保存完整快照。分别用原 LLVM 24 worker 对源 IR、清理前后的 anchor IR 和统一生成 IR 计价。LLVM 12 单独运行 EarlyCSE 复现了优化，单独运行 DCE 没有复现。EarlyCSE 后再运行 DCE 和 InstCombine 未进一步改变 T。

```sh
build/llvm24-tti/fusion-search-llvm24 --ir "$region" --function region \
    --split B0 --left B1 --right B2 --b2b-strategy anchor --observe-source-pairs 1 \
    --tti-worker tools/run-llvm24-tti --debug-dir "$trace" --out "$clean"
build/llvm24-tti/evaluate_cost "$clean" docs/dataflow-b2b/COST_TABLE.json --cost=real --after-cleanup
"$LLVM12_BIN/opt" -enable-new-pm=0 -early-cse -S "$trace/trial-0/after-raw.ll" -o "$cse"
"$LLVM12_BIN/opt" -enable-new-pm=0 -dce -S "$trace/trial-0/after-raw.ll" -o "$dce"
"$LLVM12_BIN/opt" -enable-new-pm=0 -early-cse -dce -instcombine -S "$trace/trial-0/after-raw.ll" -o "$ic"
```

```text
8d98e860d1157316db59563aaa9c6a784bda6dc1 750 787 thread-pattern pairs equality True 0 ()
layout b2b-anchor-1 before-split rewrite False
source [1520, 641, 886] 1 2 0 0 {'DLR': 256, 'DL': 750, 'DR': 787} {'control': 15, 'instruction': 737, 'memory': 768}
raw [1520, 641, 886] 1 2 0 0 {'DLR': 256, 'DL': 750, 'DR': 787} {'control': 15, 'instruction': 737, 'memory': 768}
clean [1280, 522, 765] 1 2 0 0 {'DL': 751, 'DR': 802} {'control': 15, 'instruction': 497, 'memory': 768}
opcode removed {('DLR', 'getelementptr'): 256} added {('DL', 'getelementptr'): 1, ('DR', 'getelementptr'): 15}
unified [1520, 641, 886] 1 2 0 0 {'DLR': 256, 'DL': 750, 'DR': 787} {'control': 15, 'instruction': 737, 'memory': 768}
e3583227939bff785a2993f7056817b0abcfd8b0 182 203 thread-pattern pairs equality True 0 ()
layout b2b-anchor-1 before-split rewrite False
source [448, 165, 290] 1 2 0 0 {'DLR': 64, 'DL': 182, 'DR': 203} {'control': 15, 'instruction': 241, 'memory': 192}
raw [448, 165, 290] 1 2 0 0 {'DLR': 64, 'DL': 182, 'DR': 203} {'control': 15, 'instruction': 241, 'memory': 192}
clean [392, 138, 261] 1 2 0 0 {'DL': 183, 'DR': 210} {'control': 15, 'instruction': 185, 'memory': 192}
opcode removed {('DLR', 'getelementptr'): 64} added {('DL', 'getelementptr'): 1, ('DR', 'getelementptr'): 7}
unified [448, 165, 290] 1 2 0 0 {'DLR': 64, 'DL': 182, 'DR': 203} {'control': 15, 'instruction': 241, 'memory': 192}
e7ea914e85463dbe44174a64f87c64f5d3b2f062 182 203 thread-pattern pairs equality True 0 ()
layout b2b-anchor-1 before-split rewrite False
source [448, 165, 290] 1 2 0 0 {'DLR': 64, 'DL': 182, 'DR': 203} {'control': 15, 'instruction': 241, 'memory': 192}
raw [448, 165, 290] 1 2 0 0 {'DLR': 64, 'DL': 182, 'DR': 203} {'control': 15, 'instruction': 241, 'memory': 192}
clean [392, 138, 261] 1 2 0 0 {'DL': 183, 'DR': 210} {'control': 15, 'instruction': 185, 'memory': 192}
opcode removed {('DLR', 'getelementptr'): 64} added {('DL', 'getelementptr'): 1, ('DR', 'getelementptr'): 7}
unified [448, 165, 290] 1 2 0 0 {'DLR': 64, 'DL': 182, 'DR': 203} {'control': 15, 'instruction': 241, 'memory': 192}
```

## 实现与验证

- 收缩固定配对后，沿拓扑序计算保护阶段的最长路径下界。每个阶段在同一个菱形内执行左右保护，再执行该阶段的公共操作。
- 对数据相关和工作组一致的条件，用有理数扫描按侧分解的最小割下包络。流出辅助节点使同一值最多付一次。再用评估器选择真实权重约束下的结果。出现多个菱形时，试着把保护与公共边界上的安全操作改为推测。
- 对非 small 区域同时比较经项目清理的 IR。空配对可比较原保护布局经同等清理后的结果。流程入口仍用带原输出缓冲 ABI 的替换 IR，交给原有整核清理。语义差分覆盖留存的计价 IR 和替换 IR。
- 随机小图的独立校验比较割模型与穷举，以及阶段菱形数与原 DP。DCT8 与 PCM32 对 anchor、DARM 和 dataflow-exact 逐一复跑 verifier、最终 TTI 和 IR 对比。DCT8 的两种 dataflow 路径整核 TTI 都是 44。

```text
Cut vs exhaustive objective: 16384 weights matched
Phase schedule vs DP: 1024 diamond counts matched
DCT8 anchor: 62, verifier OK, final IR matches Step 8
DCT8 darm: 44, verifier OK, final IR matches Step 8
DCT8 dataflow-exact: 44, verifier OK, final IR matches Step 8
PCM32 anchor: 1136, verifier OK, final IR matches Step 8
PCM32 darm: 1136, verifier OK, final IR matches Step 8
PCM32 dataflow-exact: 1130, verifier OK, final IR matches Step 8
```

## 回归与语料库命令

```sh
set -o pipefail
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=24 tests/dataflow-b2b/run-regression.sh \
    2>&1 | tee build/dataflow-corpus/step10a2/regression.log

export LD_LIBRARY_PATH="$HOME/v2-runtime/toolchains/llvm12-jammy/usr/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
python3 -u tests/dataflow-b2b/measure_generation.py \
    build/dataflow-regression/run.FkAczW/scalable/small.json \
    build/dataflow-corpus/step10a2/corpus-final tests/dataflow-b2b/results \
    --jobs 32 --diagnosis build/dataflow-corpus/step10a2/diagnosis.md
```

以上命令用于全语料初跑。随后收紧清理后报价的输出缓冲识别，只沿已由源 IR 验证的输出 ABI 排除传输指令。

初跑出现一处语义差分。区域 `977cab5e0b3b` 的 `raw-darm-2.ll` 通过。对同一 IR 只跑 SimplifyCFG，以及继续跑 EarlyCSE 和 DCE 均通过。加入 InstCombine 后，清理将嵌套选择改写为 `or i1`，从跨段 `i1` 值的非活动路径传播了 poison。修正后的新生成器给该类非活动路径填 false。旧生成器保持其原来的规则。重跑后同一区域的清理前后方案均通过。

```text
simplify-only: {"false_samples":1000,"method":"bounded-scalar-interpreter","status":"pass","true_samples":1000}
pre-instcombine: {"false_samples":1000,"method":"bounded-scalar-interpreter","status":"pass","true_samples":1000}
after-instcombine: {"condition":true,"method":"bounded-scalar-interpreter","reason":"result or memory differs","seed":"5055490765315214239","status":"mismatch","true_samples":0}
```

使用同一条一键回归命令重新构建并运行。随后对 187 个 medium/large 区域重跑生成。6,145 条操作的 `25146e46e0f2` 保留前一次结果，检查其替换 IR 没有受修正影响的 poison 型 i1 PHI，并对每个留存方案重报价。对全部留存的报价和替换 IR 重新运行语义差分。

```text
Regenerated 187 medium/large regions. Repriced unchanged 6,145-op region.
Semantic statuses: {'pass': 2285, 'unsupported': 7}
Semantic trials: 2292
```

Large 档在五种组合共同覆盖的 61 个区域上，固定 anchor 配对改用统一生成的 §7.2 净收益为 `(12, -161, -102)`。没有区域的已选 $T_D$ 上升。5 个线程模式区域的 $T_D$ 各低 1，两个一致场景代价仍然上升。逐项重新报价显示来自安全指令的推测，分歧中的收益来自省去一个流出。两处 LLVM 24 无有效报价和最大区域 anchor 超时的细节见结果文件。

## 一键回归完整输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.Wgkitj
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
Micro: 50/50 (2.31 s)
Fold oracle: 376/376 (0.42 s)
Small truth: 374/374 (2.12 s)
Context: 1/1 (0.19 s)
Dataflow context: 2/2 (0.44 s)
Scalable vs subset DP: 374/374 (1.14 s)
Pairing goals: 4/4 (0.04 s)
Total: 1181/1181 (6.66 s)
```
