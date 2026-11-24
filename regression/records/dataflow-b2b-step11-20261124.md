# dataflow-b2b 第 11 步：原生布局与发布线复验

工作树为 `epyc:/data/home/chh/kernel-benchmark-suite-dataflow-b2b`，起点 `c28a3f03469cea271b49bb2f669d6147c7b24e1b`。所有搜索目录和 GPU 样本在 `build/dataflow-corpus/step11`。

## 发布复验清单和编译

使用 14a 记录开头的发布复验清单。将 `regression/golden/20261120-anchor-release/manifest.json` 的 `cases`（16）与 `anchor_additional_cases`（LUD8）按顺序连接，并与 14a 指定的 `/data/home/chh/simplify-v2/build/drop-wave-release.4o8DPF/verified/results.json` 逐个核对。包括 15 个 AMD case 和 2 个 NVIDIA case。LUD8 使用发布复验中 SHA-256 以 `a52a8746` 开头的输入。DCT8 只参加新增回归。每个输入的 SHA-256 与冻结清单核对，历史路径不能提供相同内容时从清单指定归档取原件。

对每个 case 的同一冻结输入运行原始、anchor、darm、anchor-unified、dataflow 五种静态路径。原始直接用 LLVM 24 worker 报价。每个策略独立贪心，并从最终 IR 再报价。搜索同时保留最终成本、提交记录和候选报价。

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
w=build/dataflow-corpus/step11
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=32 tests/dataflow-b2b/run-regression.sh >"$w/regression-final.log" 2>&1
KBS_RELEASE_JOBS=22 python3 "$w/run-static.py" "$w" dataflow anchor-unified anchor darm original >"$w/static.log" 2>&1
python3 "$w/replay-hipims.py" "$w" >"$w/hipims-replay.log" 2>&1
LLVM24_LIBDIR="$HOME/v2-runtime/toolchains/llvm24-pinned/lib" python3 "$w/collect.py" "$w" --verify >"$w/collect.log" 2>&1
python3 "$w/render.py" "$w/evidence.json" tests/dataflow-b2b/results
```

`run-static.py` 对每个融合变体调用 `build/decision-fuse/decision-greedy INPUT FUNCTION "$PWD" OUT --b2b-strategy ROLE --ir-snapshots compact`。MapAiry 和 vllm 用 16 个候选 worker，其余用 4 个。MapAiry 每个候选最多用 12 个统一布局 worker，其余用 4 个。原始与最终 TTI 用 `tools/run-llvm24-tti IR FUNCTION`。17 个 anchor 的最终 TTI、提交数与冻结发布报告一致。最终 IR 忽略记录文件路径的 ModuleID 后逐行一致。

## GPU 和 ISA

所有参与设备对照的 IR 先经 LLVM 12 verifier，再调用 `regression/verify_anchor_release.py` 的设备对象构建入口。AMDGPU 用 LLVM 12/ROCm 6.3.3 和 gfx906，MapAiry 使用 `+sramecc`，其余使用 `+sramecc,-xnack`。SRAD32 沿用发布验证的 1024 线程 launch-bound 修正。NVIDIA 采用清单锁定的 CUDA 11 ptxas，以 sm_86 构建，在 RTX 3090 上验证。ISA 从设备对象的 kernel 符号范围提取。AMD VGPR/SGPR 从 ELF 内核 metadata 读取，CUDA 使用 cuobjdump 的每线程寄存器数。原始和三个融合策略逐个与冻结的 CPU 参考全量比较。anchor-unified 只跑静态。GPU 用 `$HOME/v2-runtime/gpu.lock` 保持串行计时。

GPU 证据来自 `/data/home/chh/simplify-v2/build/artifact-14b.5ZY6U4` 的 `run-manifest-v2.json`、`results/full/*/fixtures` 和 NVIDIA held-out fixtures。通用输入与 SRAD32 使用原 HIP event runner，tigre 使用六批次 event runner。CED 使用发布复验中独立的 110 样本 event runner。sort、NQU64、TPACF 使用发布 runner，LUD8 使用第 10c 步的 GPU 常驻输入 event replay。运行记录包括设备输出验证、配对窗口和 ISA 数据。

GPU 测量的变体由 `abs(TTI_variant - TTI_anchor) * 100 > TTI_anchor` 决定。每个配对 12 轮，每轮先热身 3 次，再取 15 个 HIP/CUDA event 样本的中位数。使用 `regression/measure_anchor_gpu.py` 的 10,000 次配对 bootstrap 算 95% 区间。合并排序按完整排序的 kernel 序列计时，LUD8 按完整 perimeter sweep，tigre 按六批次 kernel 计时。按角色与相同场景相同轮次的 anchor 比较。

## 回填和上界

`pickAnchor` 同时报出通过原规则的最佳原生报价和布局清单。通过各自 gate 的两个来源竞争最低整核 TTI。同价时复用 anchor 原生模块。审计以实际提交报价对同一候选在同一父 IR 上的可接受原生报价。步骤 8、9 的 MapAiry 精确父 IR 固化到 `tests/dataflow-b2b/context/native-layouts.json` 与其内容寻址归档。

HiPIMS-George 的两臂使用 typed pointer 指向命名结构体。从独立模块重新解析时 LLVM 为该布局分配新的结构体身份，旧代码只比较类型指针，导致 168 个布局在回填入口被拒。新入口沿参数、输出、调用声明构建类型映射，按原 ABI 回填。90 个历史请求重放核对，完整恢复 168 个布局。6 次旧运行无布局的请求在旧、新二进制均返回布局，旧日志没有足够信息区分超时或其他子进程异常。修正后的日志记录退出码及 LLVM 进程运行错误。

## 评估中遇到的问题

- 标有批量计时模式的 14b runner 需要附加对象列表，普通单变体调用会拒绝。通用、SRAD32 和 tigre 改走已有独立 event runner。TPACF 继续用 14b 的批量 runner，显式提供 anchor 和待测对象，保留 216 个事件窗口并按每 18 个窗口重组。AMD 基准清单的 469 个文件均通过 SHA-256 和大小核对。
- SasPoint5 的 RTX 3090 有外部 CUDA 进程。按原计时流程测量后，在主场景用同一个 anchor 设备对象追加 A/A 对照，并记录 GPU 进程活动。A/A 的相对中位数为 +0.00%，95% 区间为 −1.53% 至 +2.87%。
- Landau 首次使用 4 个候选 worker 和每候选 4 个布局 worker。为缩短多布局批次的墙钟时间，用 12×12 复跑，前两次提交分别复现 4453 和 4173 后停止 4×4 副本。归档和设备构建使用完整的 12×12 轨迹。

```sh
DECISION_GREEDY_JOBS=12 KBS_DATAFLOW_LAYOUT_JOBS=12 build/decision-fuse/decision-greedy \
    "$PWD/$w/Landau/input.ll" evaluate "$PWD" "$PWD/$w/Landau/dataflow-fast" \
    --b2b-strategy dataflow --ir-snapshots compact
python3 -u "$w/release-gpu-final.py" "$w"
```

计时和校验日志保存在 `gpu*.log` 下及各 case 的 `gpu/` 子目录。命令使用冻结清单的 LLVM 12/24 库路径。结果中的散点图由本机 Matplotlib 根据 `step11-plot.json` 生成。

## 完整回归输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.C8ByiH
Build and tool setup: 133 s

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

== Native layout bounds ==
dataflow: 1 committed B2B trials audited
MapAiry step 8: chosen 4700 <= native 4700
MapAiry step 9: chosen 4639 <= native 4639
dataflow: 5 committed B2B trials audited

== Summary ==
Micro: 50/50 (2.53 s)
Fold oracle: 376/376 (0.45 s)
Small truth: 374/374 (2.35 s)
Context: 1/1 (0.20 s)
Dataflow context: 2/2 (0.49 s)
Scalable vs subset DP: 374/374 (1.29 s)
Pairing goals: 4/4 (0.04 s)
Empty pairing: 373/373 (2.74 s)
Anchor parity goals: 15/15 (9.32 s)
Native layout bounds: 4/4 (3.96 s)
Total: 1573/1573 (23.38 s)
```
