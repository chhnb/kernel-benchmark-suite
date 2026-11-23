# 第 10b 步运行记录

在 epyc 的 `/data/home/chh/kernel-benchmark-suite-dataflow-b2b` 上从 `ab71a8d1aa9a654e50c210562b903bcd799ede1b` 开始。正式运行目录为 `build/dataflow-corpus/step10b`。结果和明细见 [step10b.md](../../tests/dataflow-b2b/results/step10b.md)。

## 策略接入

- 两个新路径通过现有的独立区域提取、求解和内联回填入口处理 B2B。直接菱形和三角形使用统一生成，无尺寸门槛和按大小回退。仅 `dataflow-exact` 保留原来的 10 条限制和回退。间接 B2B（不属于独立抽取的菱形或三角形）、B2R、R2R 和 normalize-only 仍走原路径。
- `anchor-unified` 通过独立求解器的 `--anchor-only` 入口，从抽取后函数上的 anchor 试验读取实际配对及对应关系。它跳过新的配对搜索和 DARM。无法提取或兼容性检查不通过的候选保留诊断，由既有贪心流程继续尝试其他候选。相比之下 `dataflow` 会比较三个配对来源及新配对的子集。
- 统一生成的报告写入放置来源。多个放置产生相同的位图时保留首次生成的来源。最小割再做凸包时和沿公共边界修复时分别附记。原始区域胜出时没有放置。输出区域的报价用于 §7.2，回填后的清理、接受以及提交继续用原整核 TTI。
- 首轮回归发现修复放置标签暂存为 LLVM JSON 的非拥有字符串，导致两项报告解析失败。改为拥有字符串后重构建、重跑两种策略和完整回归。正式实验使用 `final/` 下复跑结果。

## 输入与验证

- 六个继承用例复制第 7 步冻结输入。LUD8 只改写第 7 步有实际 B2B 搜索的 `lud_perimeter`，模块中的 diagonal 和 internal 函数保持原样。运行窗口为 16,384 矩阵上的 2,047 个 perimeter offset。
- HiPIMS-George 和 tigre-siddon 分别取第 5 步 top-15 的 `cd507219fcce` 和 `5380fef61ac9` 所在项目输入。前者是 NVPTX，在 RTX 3090 上运行 cubin。LLVM 24 TTI 使用原 `sm_70` 函数目标，区域生成的 Fold 判断仍用项目既有 LLVM 12 gfx906 SizeAndLatency 模型。后者及其余用例在 Radeon VII gfx906 上运行 HSACO。各 case 的输入路径及函数记录在实验目录的 `cases.tsv`，完整 SHA-256 在结果报告。
- DCT8 和 PCM32 使用项目的 CPU 量化或排序和完整结果对比。NQU64 重新生成三批 CPU 输出并与冻结文件逐字节核对，重放用第 6 步二进制接口 `kbs-nqu`。第一次误用了同目录里的命令行应用，切换到支持固定输入和 CSV 的回放驱动后通过。
- SRAD16 重算 256×256 的 CPU stencil 指标和五个输出。MapAiry 重跑 long-double oracle 的 65,539 个输出。HiPIMS-George 重编笛卡尔 128×128 湿干边界 CPU oracle 并比较 `dh`、`dhu` 的冻结参考。tigre-siddon 使用原六批 head64 驱动的位级 CPU 递推校验。
- LUD8 使用项目回放程序将每个变体的结果与冻结参考逐字节比较。另按原两臂的 perimeter 递推独立重算 268,435,456 个元素，归一化最大误差 (4.81618701\times10^{-7})，阈值 (10^{-5}) 内的失败数为零。
- 单独确认了保留策略。DCT8 的 darm-artifact 单候选生成 IR 与基线工具逐字节一致，PCM32 的 dataflow-exact 最终 TTI 为 1130，除 ModuleID 的目录路径外，最终 IR 与第 4b 步一致。
- 计时重用第 4a 步统计代码。只测试相比 anchor 静态差异严格超过 1% 的变体，并把 anchor 纳入同轮。三角色按轮换和反序平衡。四角色沿用第 4a 步的顺序。GPU 访问使用项目 `gpu.lock`。计时用 HIP event，校验、拷贝和复位不计入。LUD8 的 event 包含整组 perimeter launches。NQU64 和 tigre 分别沿用三批和六批窗口口径。LUD8 的首次宿主机暂存计时在正式窗口完成前停止。正式版本每次从 GPU 上的完整只读输入复位，事件之后在 GPU 上逐字比较完整结果，校验和复位仍在事件外。五个角色在同进程中轮换，继续使用 12 轮、每轮 3 次预热和 15 次测量。

## 运行命令

以下命令从仓库根目录运行。实验脚本保存在 epyc 实验目录。

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
w="$PWD/build/dataflow-corpus/step10b"
llvm="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
export LLVM_CONFIG="$llvm/lib/llvm-12/bin/llvm-config"
export LD_LIBRARY_PATH="$llvm/lib/x86_64-linux-gnu:$HOME/v2-runtime/toolchains/llvm24-pinned/lib"
DECISION_GREEDY_JOBS=8 KBS_DATAFLOW_JOBS=32 tests/dataflow-b2b/run-regression.sh \
  > "$w/regression-final.log" 2>&1

# 六个既有 case 的路径对应第 7 步目录，通过 cases.tsv 记录实际输入和函数。
# 两个新增用例从 sources.json 的 source_index 919 和 899 复制。
while IFS="$(printf '\t')" read -r case_name function source; do
  tools/run-llvm24-tti "$w/$case_name/input.ll" "$function" > "$w/$case_name/original-tti.json"
done < "$w/cases.tsv"
bash "$w/static.sh" "$w" anchor darm
bash "$w/static.sh" "$w/final" anchor-unified dataflow
bash "$w/build-gpu.sh" "$w" original anchor darm
bash "$w/build-gpu.sh" "$w/final" anchor-unified dataflow
python3 -u "$w/gpu.py" "$w" validate all original anchor darm
python3 -u "$w/gpu.py" "$w/final" validate all anchor-unified dataflow
# lud-resident.hip 由发布 lud-window.hip 保留发射、窗口和事件逻辑，
# 将复位改为 GPU 到 GPU copy，校验改为对完整参考矩阵的 GPU 逐字比较。
lud_runners="$HOME/simplify-v2/build/artifact-14b.5ZY6U4/source/artifact/runners"
/opt/rocm-6.3.3/bin/hipcc -O2 --offload-arch=gfx906 -I"$lud_runners" \
  "$w/lud-resident.hip" -o "$w/lud-resident"
KBS_LUD_REPLAY="$w/lud-resident" python3 -u "$w/gpu.py" "$w/final" timing all
python3 -u "$w/gpu.py" "$w/final" profile LUD8,MapAiry
python3 "$w/collect.py" "$w/final" "$w/evidence.json"
python3 "$w/verify-static.py" "$w/final"
python3 "$w/check-evidence.py" "$w/evidence.json"
python3 "$w/render.py" "$w" tests/dataflow-b2b/results
gzip -nc "$w/evidence.json" >tests/dataflow-b2b/results/step10b-evidence.json.gz
```

`static.sh` 对非原始角色调用 `build/decision-fuse/decision-greedy INPUT FUNCTION "$PWD" OUTPUT --b2b-strategy ROLE --ir-snapshots compact`。AMD code object 用 LLVM 12 `opt -verify`、`llc -O3 -march=amdgcn -mcpu=gfx906 -mattr=+sramecc -amdhsa-code-object-version=4 -filetype=obj` 和 ROCm `ld.lld -shared` 构建。反汇编先用 ROCm `llvm-readelf -Ws` 取目标函数 ELF 符号的地址和大小，再用 `llvm-objdump -d --mcpu=gfx906 --start-address=BEGIN --stop-address=END`。初版采用 `--disassemble-symbols`，在 TIGRE 的首个局部 BB 符号处截断，已重取所有 AMD 变体的完整范围。NVIDIA 用 LLVM 12 `llc -O3 -march=nvptx64 -mcpu=sm_70 -mattr=+ptx70`、`ptxas -arch=sm_86` 和 `cuobjdump -sass -fun FUNCTION`。最终呈现的 ISA 计数只含测试的 kernel。

按两种新策略相对 anchor 的最大绝对 TTI 点数选 MapAiry 和 LUD8。ROCProfiler 使用第 4b 步同一 ROCm 6.3.3 用户态和 `Wavefronts VALUInsts SALUInsts VALUBusy MemUnitBusy MemUnitStalled`。每次 profiler 单独回放，时间由目标 dispatch 的 `EndNs-BeginNs` 得到。gfx906 的动态 wave 驻留率仍不可用，另用 `query-gfx906-occupancy.cpp` 查询资源上限。详细命令及原始样本存在各用例的 `gpu/{timing,profile}` 下。

## 路径补充诊断

用保存的 `request.json.replay_args` 重放五个同父 IR 的 anchor 候选，添加 `--observe-source-pairs 1`。PCM32、SRAD16、MapAiry 和 tigre-siddon 的选中配对与在抽取区域中重放的 anchor 一致。LUD8 首候选的原 anchor 有 64 对，按 `!dataflow.builtin.operations` 删除一对提到入口的工作组 ID 并重编号后有 63 对。抽取区域里的 anchor 选择其中 30 对。用相同生成器固定重放了 63 对，真实 §7.2 结果为 `(154,154,154)`，全推测。没有把上下文和抽取时配对的差异归为单纯生成代价。

MapAiry 首步通过 `extract_regions` 从 `trial-5/request.json` 指向的准备后父 IR 提取；再用 `dataflow_solver --cost=real --condition-source=data` 单独重放，确认一致场景的约束使两种策略都跳过其原 anchor 的第一步。配对、原报价和方案保存于 `map-first-solver.json`。

## 完整回归输出

```text
Work directory: /data/home/chh/kernel-benchmark-suite-dataflow-b2b/build/dataflow-regression/run.w4UjAk
Build and tool setup: 108 s

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
Micro: 50/50 (2.51 s)
Fold oracle: 376/376 (0.37 s)
Small truth: 374/374 (2.12 s)
Context: 1/1 (0.23 s)
Dataflow context: 2/2 (0.48 s)
Scalable vs subset DP: 374/374 (1.79 s)
Pairing goals: 4/4 (0.04 s)
Empty pairing: 373/373 (2.40 s)
Anchor parity goals: 15/15 (8.21 s)
Total: 1569/1569 (18.16 s)
```

## 实验结果核对

```text
{'validated': 40, 'commits': 248, 'tracked_b2b': 843}
profile cases ['LUD8', 'MapAiry']
DCT8 original 62 OK
DCT8 anchor 62 OK
DCT8 darm 44 OK
DCT8 anchor-unified 62 OK
DCT8 dataflow 44 OK
PCM32 original 1392 OK
PCM32 anchor 1136 OK
PCM32 darm 1136 OK
PCM32 anchor-unified 1136 OK
PCM32 dataflow 1130 OK
NQU64 original 289 OK
NQU64 anchor 274 OK
NQU64 darm 274 OK
NQU64 anchor-unified 274 OK
NQU64 dataflow 274 OK
SRAD16 original 484 OK
SRAD16 anchor 436 OK
SRAD16 darm 455 OK
SRAD16 anchor-unified 411 OK
SRAD16 dataflow 408 OK
MapAiry original 6402 OK
MapAiry anchor 3997 OK
MapAiry darm 3999 OK
MapAiry anchor-unified 5052 OK
MapAiry dataflow 5051 OK
LUD8 original 819 OK
LUD8 anchor 628 OK
LUD8 darm 681 OK
LUD8 anchor-unified 730 OK
LUD8 dataflow 640 OK
HiPIMS-George original 5588 OK
HiPIMS-George anchor 5572 OK
HiPIMS-George darm 5577 OK
HiPIMS-George anchor-unified 5583 OK
HiPIMS-George dataflow 5581 OK
tigre-siddon original 1182 OK
tigre-siddon anchor 942 OK
tigre-siddon darm 948 OK
tigre-siddon anchor-unified 1003 OK
tigre-siddon dataflow 1003 OK
```
