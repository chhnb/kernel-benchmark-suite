# 第 10c 步运行记录

在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 以 `ac1134ff64b7a2c3994cea444ed6bbdc1aff89ee` 为起点。实验目录为 `build/dataflow-corpus/step10c`，正式两条新路径在 `final/`。逐用例结果见 [step10c.md](../../tests/dataflow-b2b/results/step10c.md)。

## 修改与核查

- 复用 anchor 的评分和布局选择路径，在父 IR 上开启原 `--observe-source-pairs` 对应的记录。将指令索引映射到抽取区域，提升为参数的同名 lane/workgroup 内建量作为共享输入记录。LUD8 首步从父 IR 的 64 对映射到 63 对。未取得映射时留下原因。
- 参考生成器对每个已验证、不同的候选布局输出未清理的区域 IR。父 IR 中的回填、LLVM verifier、DARM 清理、整核 LLVM 24 报价、同一条件的真假场景报价均复用原逻辑。独立生成器还用局部费用构造与扩展候选。局部 Pareto 或策略的结果不筛去任何已经输出的布局。
- 只对含 R5 的布局调用原 `anchorUniformRejection`。线程模式直接放行，工作组一致拒绝推测，数据相关条件要求真假一致收益都可计算且非负。保护所有剩余未配对操作时按整核 TTI 下降裁决。先记录所有整核报价，按报价检查 gate，并继续尝试下一个符合 gate 的候选，最后沿用贪心对父 IR 的整核收益检查。
- 首轮试跑先选最小报价并只检查该布局的 gate，导致 MapAiry 首步的 6129 推测布局拒绝后跳过了 6150 全保护布局。正式实现与 anchor 一样继续检查其余布局。首轮 CPU 和 GPU 产物未进入正式汇总。
- 选择数据保留 `lowest_layout`、最终选择、每个布局的整核报价和 gate 原因，使用 `audit-context.py` 核对。MapAiry 的部分候选各输出 10,531 个布局，重跑时用每个候选最多 12 个独立 LLVM context 并行验证和报价。TIGRE 同父 IR 的 1,871 个布局在串行和并行路径上逐项核对了报价、gate、配对和最终选择。分析区域以第 10b 步同一提取器从每个父 IR 重建，包括准备后 IR 中的区域。

## 正式运行命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
d="$PWD/build/dataflow-corpus/step10c"
w="$d/final"
a="$PWD/build/dataflow-corpus/step10b"
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=32 tests/dataflow-b2b/run-regression.sh \
    > "$d/regression-parallel.log" 2>&1

# 从 $a/cases.tsv 指定同一八份输入。静态原始、anchor、darm 重跑一次。
while IFS="$(printf '\t')" read -r c fn source; do
  tools/run-llvm24-tti "$d/$c/input.ll" "$fn" > "$d/$c/original-tti.json"
  for strategy in anchor darm; do
    jobs=4
    if [[ $c == MapAiry ]]; then jobs=16; fi
    DECISION_GREEDY_JOBS="$jobs" build/decision-fuse/decision-greedy "$d/$c/input.ll" "$fn" "$PWD" \
      "$d/$c/$strategy" --b2b-strategy "$strategy" --ir-snapshots compact
  done
done < "$d/cases.tsv"

# final/ 的输入、原始 TTI 和重跑的 anchor/darm 目录链接到 $d 对应目录。
bash "$d/run-static-final.sh" "$d"
# MapAiry dataflow 重跑。输出目录必须为空。
DECISION_GREEDY_JOBS=16 KBS_DATAFLOW_LAYOUT_JOBS=12 \
  build/decision-fuse/decision-greedy "$w/MapAiry/input.ll" evaluate "$PWD" "$w/MapAiry/dataflow" \
  --b2b-strategy dataflow --ir-snapshots compact
bash "$d/run-gpu-final.sh" "$d" build
bash "$d/run-gpu-final.sh" "$d" validate
bash "$d/run-gpu-final.sh" "$d" timing
bash "$d/run-profiles-final.sh" "$d"
python3 "$d/verify-static.py" "$w"
python3 "$d/audit-context.py" "$w" > "$d/context-audit.json"
python3 "$d/collect.py" "$w" "$d/evidence.json"
python3 "$d/render.py" "$d" tests/dataflow-b2b/results
```

`build` 对每一个变体运行 LLVM 12 verifier，使用 gfx906 或 sm_70 LLVM 12 codegen。gfx906 链接 HSACO 后依 ELF 函数符号地址和大小反汇编。HiPIMS 生成 RTX 3090 的 cubin，再用 `cuobjdump -sass` 取得 SASS。输入、发射、CPU 校验和完整 GPU 输出检查使用第 10b 步同一套 fixture 和驱动。LUD8 只对 perimeter 做贪心，CPU reference 为第 10b 步已经与独立标量递推比较的矩阵。LUD8 event 驱动执行 2,047 个 offset，GPU 上逐字比较输出，复位和校验均在事件间隔外。其余用例保留上一版的 launch 及批次。所有旧 CPU reference 与冻结输入关联的 SHA 可在第 10b 步记录查到。

绝对静态差异超过 anchor 的 1% 时，与 anchor 同轮测时。12 轮顺序轮换，每个角色每轮 3 个预热和 15 个样本，每轮取中位数，再用 10,000 次 bootstrap 给出配对比值区间。用 `gpu.lock` 保持单个测试独占设备。按两条新策略相对 anchor 的最大绝对 TTI 点数选择两个 rocprof 用例。复用第 4b 步的计数器和 HIP occupancy 查询。所有 GPU 命令、逐轮 CSV 和 profiler 数据保存在各用例的 `gpu/` 下。HiPIMS-George 的 NVIDIA 反汇编和正确性均已完成。它进入静态差异前两名，rocprof 不支持该设备，Nsight Compute 的计数器试跑返回 `ERR_NVGPUCTRPERM`。未改动设备权限，第二组 AMD 计数器改测下一名 SRAD16。

## HiPIMS-George 计数器探测

```sh
h="$HOME/simplify-v2/build/b2b-layouts"
flock "$HOME/v2-runtime/gpu.lock" timeout 120 /usr/local/cuda/bin/ncu \
  --set basic --kernel-name regex:cuAdvectionSWEsGeorgeCartesianKernel --launch-skip 3 --launch-count 1 \
  "$h/anchor-heldout/cuda-runner" --kernel "$w/HiPIMS-George/gpu/anchor.cubin" \
  --input "$h/anchor-ablation/heldout/HiPIMS-George/anchor-holdout-synthetic-v1/input.txt" \
  --mode benchmark --warmup 3 --repeat 15 --output "$w/HiPIMS-George/gpu/ncu-check"
python3 -u "$d/gpu.py" "$w" profile SRAD16
```

## 第 10b 步 LUD8 诊断命令

```sh
mkdir -p "$d/lud8-diagnosis"
for role in anchor dataflow; do
  bash "$d/disasm.sh" "$a/LUD8/gpu/$role.hsaco" _Z13lud_perimeterPfii \
    "$d/lud8-diagnosis/$role.s"
  input="$a/LUD8/$role/final.ll"
  [[ $role != dataflow ]] || input="$a/final/LUD8/$role/final.ll"
  "$llvm/lib/llvm-12/bin/llc" -O3 -march=amdgcn -mcpu=gfx906 -mattr=+sramecc \
    -amdhsa-code-object-version=4 -filetype=asm "$input" \
    -o "$d/lud8-diagnosis/$role.annotated.s"
done
```

按 `s_barrier` 和 `s_cbranch_execz` 划分地址范围，再计 VALU、访存和 `v_cndmask`。第 10b 步计时和计数器来自已提交的 `step10b-evidence.json.gz`。

## 完整回归输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.YdEg8p
Build and tool setup: 123 s

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
Micro: 50/50 (2.68 s)
Fold oracle: 376/376 (0.39 s)
Small truth: 374/374 (2.25 s)
Context: 1/1 (0.23 s)
Dataflow context: 2/2 (0.51 s)
Scalable vs subset DP: 374/374 (1.18 s)
Pairing goals: 4/4 (0.04 s)
Empty pairing: 373/373 (2.38 s)
Anchor parity goals: 15/15 (9.04 s)
Total: 1569/1569 (18.69 s)
```

## 对照核验

40 个最终 kernel 重新使用固定 LLVM 24 worker 报价并核对 verifier。八个用例重跑的 16 个 anchor/darm 终值、提交数和去除输出目录 ModuleID 后的 IR 均与第 10b 步相同。PCM32 的 dataflow-exact 仍为 1130，DCT8 的 darm-artifact 单候选输出也与第 10b 步相同。并行路径的 TIGRE 对拍采用 `trial-14/request.json` 的 `replay_args`，附加 `KBS_DATAFLOW_LAYOUT_JOBS=8`，逐项比较布局原序、TTI、gate 和整核选中输出。

HiPIMS-George 的 168 个布局尝试回填后报 `solution_argument_type_mismatch`。这 168 项未参与整核比较。另有 6 次 `dataflow_exact_solver_failed` 没有输出布局清单，也没有 stderr 诊断。原始 trial 路径与区域 ID 记录在正式实验目录，逐候选计数保存在结果明细。

```text
{'validated': 40, 'commits': 332, 'tracked_b2b': 3157}
profile static ranking ['HiPIMS-George', 'MapAiry'] measured ['MapAiry', 'SRAD16'] unavailable ['HiPIMS-George']
DCT8 anchor 62 identical
DCT8 darm 44 identical
PCM32 anchor 1136 identical
PCM32 darm 1136 identical
NQU64 anchor 274 identical
NQU64 darm 274 identical
SRAD16 anchor 436 identical
SRAD16 darm 455 identical
MapAiry anchor 3997 identical
MapAiry darm 3999 identical
LUD8 anchor 628 identical
LUD8 darm 681 identical
HiPIMS-George anchor 5572 identical
HiPIMS-George darm 5577 identical
tigre-siddon anchor 942 identical
tigre-siddon darm 948 identical
Parallel/serial TIGRE parity 1871 layouts, labels, gate, TTI and chosen IR matched
Stopped slow serial MapAiry run 18 processes
```
