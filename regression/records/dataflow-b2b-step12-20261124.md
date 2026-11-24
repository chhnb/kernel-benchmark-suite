# dataflow-b2b 第 12 步：DARM artifact、发布线补测和噪声标定

起点为 `3c994de1de85a5cb643f807a0b886c6d88d8d615`（`dataflow-b2b-v1`），分支 `feature/dataflow-b2b`，工作目录 `epyc:/data/home/chh/kernel-benchmark-suite-dataflow-b2b`。原始日志、每个样本、最终 IR 和设备对象存于 `build/dataflow-corpus/step12`。所有贪心策略继续使用该起点的实现、选项和默认规则。

## 静态评估

用 `tests/dataflow-b2b/corpus/sources.json` 中 `category == "darm"` 的 BIT、DCT、LUD、MS、NQU、PCM、SRAD 项。解压后逐一复核清单 SHA-256，排除另列的 `gpu_example`。SRAD 依次处理并报价两个 kernel，LUD 测原 artifact 主程序调用的 perimeter kernel。对其他程序选择其唯一被测 kernel。

`darm-artifact` 使用归档原版 CFMelder 完整构建 `$HOME/v2-runtime/toolchains/auto-darm-opt`，SHA-256 为 `99fcb66d33562b1506a6a1bebaab8de9902f816a2aec9c04ef033c855f888324`。正常输入命令为 `auto-darm-opt -cfmelder -cf-merging-similarity-threshold=0.2 -stats -S INPUT -o RESULT`。MS 沿用 artifact 的 `-run-cfmelding-on-function=mergesort` 与 pass 后 `opt -simplifycfg`。原版提交数按目标函数的 `Melding entry blocks` 日志计数。项目内四个融合策略用 `build/decision-fuse/decision-greedy INPUT FUNCTION "$PWD" OUT --b2b-strategy ROLE --ir-snapshots compact`，提交数取贪心日志。原始及全部最终 IR 用 LLVM 12 verifier 复核，TTI 用 `tools/run-llvm24-tti IR FUNCTION` 逐 kernel 重新报价。

LUD128 的冻结输入使用较新的 AMDGPU DataLayout，原版 12.0.0git parser 拒绝 `G1`。仅对原版 pass 的输入副本暂时去掉这一标记，pass 后恢复原 DataLayout，再做 verifier 和报价。原冻结 IR 和其余五个变体入口字节保持相同。LUD128 的 perimeter 使用三个 128×128 float LDS 数组，总计 196608 字节。gfx906 仅支持 65536 字节，设备编译明确拒绝该 kernel。六个变体保留静态结果，GPU 对照和 ISA 无设备对象可用。

PCM128 的项目 darm 首次并行运行在第 38 个提交后报告 normalize-only control 导出失败。单独重放该控制输入能导出并通过 verifier，随后用一个候选 worker 从冻结输入全量重跑。单候选 worker 重跑完成 308 次提交，最终 TTI 为 6879。原始失败的进程日志没有进一步诊断。

## 设备验证与计时

同一 case 的六种设备代码使用统一的 LLVM 12 AMDGPU 后端、ROCm 6.3.3 链接器，Radeon VII（gfx906）。LUD 采用原 artifact 的 `-O2`，其他用 `-O3`。特性为 `+sramecc,-xnack`，code object v4。SRAD32 的设备构建沿用第 11 步 1024 线程 launch bound 兼容，静态报价使用冻结 IR。ISA 从每个目标 kernel 的 ELF 符号范围中统计，VGPR/SGPR 从代码对象 metadata 读取。

用 `tests/dataflow-b2b/replay-darm-artifact.cpp` 的 HIP module API 在同一进程加载各变体。每个可运行变体在计时前先将完整输出与独立 CPU 参考比较。每轮按交替方向轮转角色，每角色预热 3 次，计时 15 次，用窗口内中位数。12 组配对中位数的比值，复用 `regression/measure_anchor_gpu.py` 的 10000 次 bootstrap 计算 95% 区间。计时窗口为 HIP 事件包围的 kernel 或 kernel 序列。重置、主机传输和 CPU 验证在区间外。

设备工作负载如下。

- BIT 使用 artifact 的 2^26 个整数，按 block 排序，对比解析得到的全数组。
- DCT 使用第 4a 步相同的 4096×4096 输入、随机种子和 CPU 量化规则，三个 block size 用同一图像。原论文主程序的 32768×32768 工作负载更大。
- MS 和 PCM 使用 artifact 的 2^20 个 long 和 2^28 个 int。CPU 使用完整排序结果。MS 计时覆盖整个合并序列，PCM 使用每 block 原有的已排序子序列布局。
- NQU 使用 15 皇后，CPU 枚举所有前缀子树，逐组核对并验证加权总数 2279184。NQU256 原归约只汇总 threadIdx.x < 128 的数据，六个变体常规打包都复现少算。保留原诊断日志，另将所有有效条件打包到每个 256 线程块的前 128 lane 并给后半块补零贡献输入，计时覆盖该正确打包下的全部问题。该点的打包量与更小 block size 不同。
- LUD 使用 16384 阶 Toeplitz 输入与原 perimeter sweep，各 off-diagonal tile 有独立 CPU 浮点参考，按绝对及相对 4e-5 容差比对。计时覆盖全部 offset。LUD64 的 perimeter-only sweep 在冻结 Toeplitz 输入上会溢出。CPU 参考与 GPU 均出现 NaN，首轮的比较器拒绝了 CPU 和 GPU 同位置产生的 NaN。重跑逐元素核对有限值、NaN 位置和有符号无穷值，设备对象和工作负载保持原样。
- SRAD 使用 4096×4096 图像、128×128 ROI 与两次迭代。基准先计算两次所需 ROI 系数，固定给各设备变体。CPU 参考按被冻结 GPU 算式执行，扩散系数不裁剪。首次校验沿用了 CPU 示例中已在 GPU kernel 注释掉的裁剪操作，导致原始和全部策略的输出校验都不匹配，修正参考后重测。使用绝对及相对 2e-5 容差。

## 发布线补测与噪声

补测按最终 IR 去掉 ModuleID 后逐行比较，筛选和第 11 步相同的整个 kernel TTI 门槛。命中 SW2D、HiPIMS-George、LUD8。使用留存的第 11 步设备对象、验证入口和工作负载。六个输入同轨的 case 已复核 anchor 与 dataflow 设备对象逐字节相同。

vllm 64K、MapAiry、SRAD16、PCM32 和 LUD8 噪声标定均用第 11 步设备对象。每批运行重新加载二进制，先执行的角色交替。相邻批次在上一批结束后至少等待 600 秒，且与其他计时共享 `$HOME/v2-runtime/gpu.lock`，所以实际间隔可能更长。显著性门槛取五个场景中配对差值范围最宽的一项，把宽度向上取整到整数百分点且下限为 1%。快或慢的判定还要求 95% 区间完全位于零的一侧。

## 命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
w=build/dataflow-corpus/step12
python3 -u "$w/static.py" "$w" original darm-artifact anchor darm anchor-unified dataflow
g++ -std=c++17 -O3 -march=native -fopenmp -D__HIP_PLATFORM_AMD__ \
    -I/opt/rocm-6.3.3/include "tests/dataflow-b2b/replay-darm-artifact.cpp" -L/opt/rocm-6.3.3/lib \
    -Wl,-rpath,/opt/rocm-6.3.3/lib -lamdhip64 -o "$w/runner"
python3 -u "$w/gpu.py" "$w"
python3 -u "$w/gpu.py" "$w" SRAD16 SRAD32
python3 -u "$w/gpu.py" "$w" LUD64
KBS_NOISE_INTERVAL=600 python3 -u "$w/release.py" "$w" noise
python3 -u "$w/release.py" "$w" supplement
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=32 tests/dataflow-b2b/run-regression.sh
python3 "$w/report.py" "$w" tests/dataflow-b2b/results
```

## 回归输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.MVFqUU
Build and tool setup: 126 s

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
Micro: 50/50 (2.50 s)
Fold oracle: 376/376 (0.37 s)
Small truth: 374/374 (2.32 s)
Context: 1/1 (0.20 s)
Dataflow context: 2/2 (0.51 s)
Scalable vs subset DP: 374/374 (1.16 s)
Pairing goals: 4/4 (0.05 s)
Empty pairing: 373/373 (2.22 s)
Anchor parity goals: 15/15 (9.04 s)
Native layout bounds: 4/4 (4.05 s)
Total: 1573/1573 (22.41 s)
```
