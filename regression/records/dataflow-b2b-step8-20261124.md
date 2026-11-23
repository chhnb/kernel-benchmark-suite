# 第 8 步 移除 ILP，整理测试用例和回归测试

## 存档和代码

在 `e591438cf86e757d381012921abdda94396ed819` 上建立并推送 tag `dataflow-b2b-ilp-archive`。归档后删除求解器、专用桥接接口、`dataflow-ilp` 策略以及第 5 至 7 步只为 ILP 实验服务的脚本。搜索入口恢复到第 6 步引入 ILP 前的实现，保留 `dataflow-exact` 的 10 条指令上限和 anchor 回退。参考求解器保留抽象与真实计价选项。归档前提交的全部结果和记录均保留，微型用例与语料库逐文件未变。

```sh
git tag dataflow-b2b-ilp-archive e591438cf86e757d381012921abdda94396ed819
git push origin refs/tags/dataflow-b2b-ilp-archive
git ls-remote origin refs/tags/dataflow-b2b-ilp-archive
```

推送通过本机的临时 Git 仓库转发 epyc 上的对象。首次构造推送 refspec 时，zsh 将变量后的冒号解析为修饰符。改用带花括号的变量展开后推送成功，并用 `ls-remote` 核对了远端的完整提交哈希。

## 基准数据

- `truth/small.json` 包含 188 个 small 区域。抽象前沿取自第 3b 步枚举，真实前沿取自第 5 步保存的参考枚举结果。两个模式的目标值与第 5 步已对拍的结果核对，187 个区域可计价。六个真实计价用例保留当时恢复的目标属性。含普通调用的 `b670a987cbd0` 标为 unpriced。
- `context/candidates.json` 收录第 7 步的 114 条正遗憾候选和两条 LUD8 同窗口比较记录，共 89 份去重父 IR。89 份解压内容都与第 7 步 SHA-256 一致。历史上只对选中的候选实际运行了单步替换，其他记录的最终整核 TTI 为 null；LUD8 所用的是同窗口 anchor/DARM 对照流程。

## 保留策略的整核报价复核

在 epyc 上使用 LLVM 12.0.1 和仓库固定的 LLVM 24 worker。输入由 `regression/greedy-v1/manifest-ordered-20261119.json` 指定并校验 SHA-256。每次运行使用独立输出目录。预期来自第 4a 步 DCT8 和第 4b 步 PCM32；第 6 步的端到端用例为 NQU64 和 MapAiry。

```sh
gzip -dc "regression/greedy-v1/$input" > "$parent"
build/decision-fuse/decision-greedy "$parent" "$function" "$PWD" "$out" \
    --b2b-strategy "$strategy" --ir-snapshots compact
"$LLVM12_BIN/opt" -verify -disable-output "$out/final.ll"
tools/run-llvm24-tti "$out/final.ll" "$function"
python3 tests/dataflow-b2b/check-step4b-fallback.py \
    build/dataflow-corpus/step8/parity.ttn2u02h/PCM32
```

```text
DCT8 21a5ddb82636744c691db57d4e78ffcfcaf0143b495f3129d14700d09ca9ae0d _Z27CUDAkernelQuantizationShortPsi
PCM32 db3b35287f1ef284e3c8dac514b05fc952a6892345b5ff0077b2840927aaab47 _Z3pcmPi
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-corpus/step8/parity.ttn2u02h
DCT8 anchor: 62 (expected 62; verifier OK)
DCT8 darm: 44 (expected 44; verifier OK)
DCT8 dataflow-exact: 44 (expected 44; verifier OK)
PCM32 anchor: 1136 (expected 1136; verifier OK)
PCM32 darm: 1136 (expected 1136; verifier OK)
PCM32 dataflow-exact: 1130 (expected 1130; verifier OK)
TTI parity: 6/6
pair trial verified; static_score=1.217765e-02; eligible=1; semantic validation not run
pair trial verified; static_score=1.217765e-02; eligible=1; semantic validation not run
{'cleaned_kernel_cost': 1379, 'condition_source': 'data', 'handler': 'anchor_fallback', 'kind': 'b2b-diamond', 'operations': 12, 'raw_kernel_cost': 1396, 'region_id': '45b92df9fd9488e134d373d58742c42313765a1d'}
```

规模回退检查用两侧共 12 条指令的 PCM32 隔离用例。搜索报告标为 `anchor_fallback`，与 anchor 的布局、裁决和清理后 IR 相同，清理后 TTI 为 1379。本次整核复核执行静态报价与 IR verifier。

## 一键回归

```sh
set -o pipefail
KBS_DATAFLOW_JOBS=24 DECISION_GREEDY_JOBS=8 tests/dataflow-b2b/run-regression.sh \
    2>&1 | tee build/dataflow-corpus/step8/regression.log
```

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.C6vFnh
Build and tool setup: 85 s

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

== Summary ==
Micro: 50/50 (2.32 s)
Fold oracle: 376/376 (0.42 s)
Small truth: 374/374 (2.08 s)
Context: 1/1 (0.20 s)
Total: 801/801 (5.02 s)
```
