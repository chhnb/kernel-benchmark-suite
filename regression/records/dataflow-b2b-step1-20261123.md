# Dataflow B2B 第 1 步

起点为 `d4ad2e89f4704c408165e002c4082e90e7f949dc`。向量顺序为 D、L、R。

## 01-crossed

整数 f 链和浮点 g 链互不依赖，右侧顺序为 g 再 f，PHI 按 f 对 f、g 对 g 交叉对应。 Fold 不成立。两侧各为 7，合计 14。

- `original`。左侧 mul 2 + sub 1 + fmul 2 + fsub 2 + bitcast 0 (7, 7, 0) + 右侧 mul 2 + sub 1 + fmul 2 + fsub 2 + bitcast 0 (7, 0, 7) + 分支控制 (3, 3, 3) + 2 个合流 (2, 2, 2) = (19, 12, 12)，Δ = (0, 0, 0)。
- `pair-both-chains`。mul (2, 2, 2) + sub (1, 1, 1) + fmul (2, 2, 2) + fsub (2, 2, 2) + bitcast (0, 0, 0) + 两条输入 select (2, 2, 2) = (9, 9, 9)，Δ = (10, 3, 3)。

两条链都能配对，每条链使用一条 V3 输入选择，链中间结果经 V2 复用。 Pareto 前沿为 pair-both-chains。保守选择为 `pair-both-chains`。

## 02-commute

相同的 mul 和 sub 尾链直接使用共享的 add 结果。 Fold 不成立。每侧 add 1 + mul 2 + sub 1，合计 8。

- `original`。左侧 add 1 + mul 2 + sub 1 (4, 4, 0) + 右侧 add 1 + mul 2 + sub 1 (4, 0, 4) + 分支控制 (3, 3, 3) + 1 个合流 (1, 1, 1) = (12, 8, 8)，Δ = (0, 0, 0)。
- `positional`。add (1, 1, 1) + mul (2, 2, 2) + sub (1, 1, 1) + 两条输入 select (2, 2, 2) = (6, 6, 6)，Δ = (6, 2, 2)。
- `commuted`。add (1, 1, 1) + mul (2, 2, 2) + sub (1, 1, 1) + 一条输入 select (1, 1, 1) = (5, 5, 5)，Δ = (7, 3, 3)。

R2 复用 %y，比 R1 少一条 select。 Pareto 前沿为 commuted。保守选择为 `commuted`。

## 03-cmp-swap

右侧 slt 交换输入后成为 sgt，共同尾链消费比较结果。 Fold 不成立。每侧 icmp 1 + zext 1 + mul 2 + xor 1，合计 10。

- `original`。左侧 icmp 1 + zext 1 + mul 2 + xor 1 (5, 5, 0) + 右侧 icmp 1 + zext 1 + mul 2 + xor 1 (5, 0, 5) + 分支控制 (3, 3, 3) + 1 个合流 (1, 1, 1) = (14, 9, 9)，Δ = (0, 0, 0)。
- `swap-predicate`。icmp (1, 1, 1) + zext (1, 1, 1) + mul (2, 2, 2) + xor (1, 1, 1) + 两条比较输入 select (2, 2, 2) = (7, 7, 7)，Δ = (7, 2, 2)。
- `speculate-comparisons`。两条 icmp (2, 2, 2) + 比较结果 select (1, 1, 1) + zext (1, 1, 1) + mul (2, 2, 2) + xor (1, 1, 1) = (7, 7, 7)，Δ = (7, 2, 2)。

交换谓词的方案合法。保守条件下两种方案并列，选择能展示 R3 的方案。 Pareto 前沿为 swap-predicate, speculate-comparisons。保守选择为 `swap-predicate`。

## 04-select-select-diff

两个 select 的条件、真值和假值都不同。准备操作的 opcode 在两侧互异。 Fold 不成立。左侧 5、右侧 3，合计 8。

- `original`。左侧 mul 2 + mul 2 + select 1 (5, 5, 0) + 右侧 sub 1 + xor 1 + select 1 (3, 0, 3) + 分支控制 (3, 3, 3) + 1 个合流 (1, 1, 1) = (12, 9, 7)，Δ = (0, 0, 0)。
- `speculate-selects`。左侧两条 mul (4, 4, 4) + 右侧 sub 与 xor (2, 2, 2) + 原有两条 select (2, 2, 2) + 一条输出 select (1, 1, 1) = (9, 9, 9)，Δ = (3, 0, -2)。
- `merge-selects`。左侧两条 mul (4, 4, 4) + 右侧 sub 与 xor (2, 2, 2) + 三条输入 select (3, 3, 3) + 一条共享 select (1, 1, 1) = (10, 10, 10)，Δ = (2, -1, -3)。

两条 select 各自推测执行比合并便宜，但右侧一致场景有开销，保守策略保留原始控制流。 Pareto 前沿为 original, speculate-selects。保守选择为 `original`。

## 05-select-select-shared

两条 select 共用条件和真值，只有假值不同。 Fold 不成立。每侧 select 1 + mul 2 + mul 2，合计 10。

- `original`。左侧 select 1 + mul 2 + mul 2 (5, 5, 0) + 右侧 select 1 + mul 2 + mul 2 (5, 0, 5) + 分支控制 (3, 3, 3) + 1 个合流 (1, 1, 1) = (14, 9, 9)，Δ = (0, 0, 0)。
- `merge-selects`。输入 select (1, 1, 1) + 共享 select (1, 1, 1) + 共享两条 mul (4, 4, 4) = (6, 6, 6)，Δ = (8, 3, 3)。
- `speculate-selects`。两条原 select (2, 2, 2) + 中间结果 select (1, 1, 1) + 共享两条 mul (4, 4, 4) = (7, 7, 7)，Δ = (7, 2, 2)。

合并 select 优于分别推测，尾链在两个方案里均配对。 Pareto 前沿为 merge-selects。保守选择为 `merge-selects`。

## 06-shared-select

mul 和 sub 都要求有序值对 (%p, %q)，add 汇总两条计算。 Fold 不成立。每侧 mul 2 + sub 1 + add 1，合计 8。

- `original`。左侧 mul 2 + sub 1 + add 1 (4, 4, 0) + 右侧 mul 2 + sub 1 + add 1 (4, 0, 4) + 分支控制 (3, 3, 3) + 1 个合流 (1, 1, 1) = (12, 8, 8)，Δ = (0, 0, 0)。
- `reuse-input-select`。共享 mul (2, 2, 2) + 共享 sub (1, 1, 1) + 共享 add (1, 1, 1) + 共用的输入 select (1, 1, 1) = (5, 5, 5)，Δ = (7, 3, 3)。

两个使用者引用同一条 select。生成两条相同 select 违反 V3 的复用要求。 Pareto 前沿为 reuse-input-select。保守选择为 `reuse-input-select`。

## 07-guard-cluster

两条左 sdiv 独立，中间的 mul 可与右侧配对。各 sdiv 的结果都流向 join。 Fold 不成立。参数除数的两条 sdiv 不可推测，且合计代价为 20。

- `original`。左侧 sdiv 8 + mul 2 + sdiv 8 (18, 18, 0) + 右侧 mul (2, 0, 2) + 分支控制 (3, 3, 3) + 3 个合流 (3, 3, 3) = (26, 24, 8)，Δ = (0, 0, 0)。
- `cluster-divides`。共享 mul (2, 2, 2) + 两条左 sdiv (16, 16, 0) + 分支控制 (3, 3, 3) + 两个流出值 (2, 2, 2) = (23, 23, 7)，Δ = (3, 1, 1)。
- `split-divides`。共享 mul (2, 2, 2) + 两条左 sdiv (16, 16, 0) + 两个保护段控制 (6, 6, 6) + 两个流出值 (2, 2, 2) = (26, 26, 10)，Δ = (0, -2, -2)。

将共享 mul 移出两条 sdiv 之间，两条 sdiv 只支付一次控制开销。 Pareto 前沿为 cluster-divides。保守选择为 `cluster-divides`。

## 08-fold-threshold-7

单位代价的 add/xor 链在三角形的左侧，右边直接返回参数。 Fold 成立。全部操作可推测，只有一个 i32 PHI，两侧合计 7 个单位。

- `original`。7 条 add/xor (7, 7, 7) + 输出 select (1, 1, 1) = (8, 8, 8)，Δ = (0, 0, 0)。

局部化简恰好消去保护。 Pareto 前沿为 original。保守选择为 `original`。

## 08-fold-threshold-8

单位代价的 add/xor 链在三角形的左侧，右边直接返回参数。 Fold 不成立。全部操作可推测，只有一个 i32 PHI，两侧合计 8 个单位。

- `original`。八条 add/xor (8, 8, 0) + 分支控制 (3, 3, 3) + 一个合流 (1, 1, 1) = (12, 12, 4)，Δ = (0, 0, 0)。
- `speculate-chain`。8 条 add/xor (8, 8, 8) + 输出 select (1, 1, 1) = (9, 9, 9)，Δ = (3, 3, -5)。

原始区域保留保护，显式推测会增加 R 场景代价。 Pareto 前沿为 original, speculate-chain。保守选择为 `original`。

## 09-phi-count-3

两侧各三条独立计算，所有 PHI 写入 %out。 Fold 成立。两侧操作均可推测，c_SL 合计 6，join 含 3 个 i32 PHI。

- `original`。两侧 add/sub/xor (6, 6, 6) + 三条输出 select (3, 3, 3) = (9, 9, 9)，Δ = (0, 0, 0)。
- `pair-operations`。共享 add (1, 1, 1) + 共享 sub (1, 1, 1) + 共享 xor (1, 1, 1) + 新建 select (1, 1, 1) = (4, 4, 4)，Δ = (5, 5, 5)。

三条运算配对可共用一条输入 select。 Pareto 前沿为 pair-operations。保守选择为 `pair-operations`。

## 09-phi-count-4

两侧各三条独立计算，所有 PHI 写入 %out。第 4 个 PHI 直接选择参数 %u、%v。 Fold 不成立。两侧操作均可推测，c_SL 合计 6，join 含 4 个 i32 PHI。

- `original`。左侧 add 1 + sub 1 + xor 1 (3, 3, 0) + 右侧 add 1 + sub 1 + xor 1 (3, 0, 3) + 分支控制 (3, 3, 3) + 4 个合流 (4, 4, 4) = (13, 10, 10)，Δ = (0, 0, 0)。
- `pair-operations`。共享 add (1, 1, 1) + 共享 sub (1, 1, 1) + 共享 xor (1, 1, 1) + 新建 select (2, 2, 2) = (5, 5, 5)，Δ = (8, 5, 5)。

三条运算配对可共用一条输入 select。 Pareto 前沿为 pair-operations。保守选择为 `pair-operations`。

## 10-unsafe

两条危险操作的值分别通过 PHI 写到输出数组。 Fold 不成立。除数可能为零，%p 无解引用保证，两条操作都不能推测。

- `original`。sdiv (8, 8, 0) + load (4, 4, 0) + 分支控制 (3, 3, 3) + 两个合流 (2, 2, 2) = (17, 17, 5)，Δ = (0, 0, 0)。

两条操作只能用 R6。对任一操作使用 R5 都不合法。 Pareto 前沿为 original。保守选择为 `original`。

## 11-mem-order

左侧先写 %p 再读 %q，参数没有 noalias 保证。 Fold 不成立。store 有副作用，load 可访问无效指针，也依赖可能别名的 store。

- `original`。store (4, 4, 0) + load (4, 4, 0) + 分支控制 (3, 3, 3) + 一个合流 (1, 1, 1) = (12, 12, 4)，Δ = (0, 0, 0)。

先 load 再 store 的调度不合法；将 load 提出保护段、移到 store 之前也不合法。%p = %q 时必须读到新写入的 %x。 Pareto 前沿为 original。保守选择为 `original`。

## 12-convergent

左侧调用 AMDGPU swizzle，第二个操作数是 intrinsic 必需的 immarg。代价表未覆盖调用，手算暂以 1 为占位。 Fold 不成立。convergent 调用不可推测。

- `original`。swizzle（占位） (1, 1, 0) + 分支控制 (3, 3, 3) + 一个合流 (1, 1, 1) = (5, 5, 4)，Δ = (0, 0, 0)。

convergent 调用只能使用 R6。若调用代价记为 k，则原始代价为 (k + 4, k + 4, 4)，结论与 k 无关。 Pareto 前沿为 original。保守选择为 `original`。

## 13-fallback

左侧只有 sdiv，右侧只有 load。两条操作无法配对，也都必须留在各自的保护段。 Fold 不成立。参数除数的 sdiv 和无解引用保证的 load 都不可推测，合计代价为 12。

- `original`。左侧 sdiv (8, 8, 0) + 右侧 load (4, 0, 4) + 分支控制 (3, 3, 3) + 1 个合流 (1, 1, 1) = (16, 12, 8)，Δ = (0, 0, 0)。

R1–R3 均无可用配对，R5 也不可用。保留共用分支的菱形和一个输出合流即可达到所需的最少控制与合流开销。 Pareto 前沿为 original。保守选择为 `original`。

## 14-user-example

保留用户给定的两条 add 和一个 PHI。 Fold 成立。两条 add 都可推测，合计 2，且只有一个 i32 PHI。

- `original`。左 add (1, 1, 1) + 右 add (1, 1, 1) + 输出 select (1, 1, 1) = (3, 3, 3)，Δ = (0, 0, 0)。
- `positional`。共享 add (1, 1, 1) + 两条输入 select (2, 2, 2) = (3, 3, 3)，Δ = (0, 0, 0)。
- `commuted`。共享 add (1, 1, 1) + 一条输入 select (1, 1, 1) = (2, 2, 2)，Δ = (1, 1, 1)。
- `speculate-both`。左 add (1, 1, 1) + 右 add (1, 1, 1) + 输出 select (1, 1, 1) = (3, 3, 3)，Δ = (0, 0, 0)。

原始区域经过 Fold，基线为 (3, 3, 3)。因此 R1 和双侧推测的收益均为零，只有 R2 在三个场景各节省 1。 Pareto 前沿为 commuted。保守选择为 `commuted`。

## 计费约定待明确

- 代价表没有 convergent call 条目。12 暂按 1 计费，并保留关于 k 的通式。
- 三角形将空侧视为同一条件分支的直通边，未折叠时计一次控制开销。多输出的 join 写回与 GEP 是观测代码，不计入两侧或输出需求的代价。
- 08 每条操作都为 1，覆盖累计阈值，未覆盖首条操作允许单独超预算的特例。09 使用 i32 PHI，仅改变 PHI 个数。
- 等价代价向量不互相支配。03 的两个方案同属 Pareto 前沿，保守策略未指定平局规则，本例选取交换比较谓词的方案。
- 运行哈希只覆盖定义良好的主机输入，随机整数非零且绝对值不超过 32，避免除零和有符号除法溢出。11 的两个输入指针交替使用相同和不同数组。12 仅跑 verifier。

## 检查命令和完整输出

```sh
llvm_root="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
export KBS_LLVM12_BIN="$llvm_root/lib/llvm-12/bin"
export LD_LIBRARY_PATH="$llvm_root/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
python3 tests/dataflow-b2b/check-micro.py --clang "$KBS_LLVM12_BIN/clang"
```

```text
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
```

在同一工具链下重跑，完整输出逐字一致。

---

# Dataflow B2B 第 1 步（输入区域语料库）

这次从已发布的 `cfc3d2e0a875a51f81cd658f9c940833eea4b6b3` 追加提交，沿用原来的 `feature/dataflow-b2b` 分支和 epyc 工作目录。前面的微型测试记录保留。该起点已经包含 `PROBLEM.md` 第 7 节的两处表格修正。

## 来源与覆盖

- **darm**。逐条校验 `regression/greedy-v1/manifest-ordered-20261119.json` 中解压后的输入哈希，同一个程序和 block size 的多个函数条目共用模块。25 个 block size 直接复用。LUD128 使用历史 LUD64 的 LLVM 12 ROCm 4.2 前端命令，仅调整 block size、源文件和输出路径。 `gpu_example` 用相同工具链按上游的 `-O3 -fno-unroll-loops` 生成 gfx906 设备 IR。两个生成件随语料库保存，LLVM 12 verifier 均通过。上游固定在 `7f253257c619ad6b8d6529653dbbe0a0d3007195`，完整 argv、工作目录和环境见 `sources.json` 的 `generation`。SB1–SB4 缺公开源码。
- **project**。先按基线提交枚举 `cases/` 内的 IR，再用 `artifact/run` 提交 `7d2e45b77e5502eeab42bea43f696ccb89172e58` 的发布清单定位全部 14 个 IR blob。发布名称与目录名不同时，保留两种 case 对应关系。用有路径和运行记录的历史输入补入 Hypersonic、CUDAflow、HiPIMS HLLC/George 和 SasPoint5。三个 vLLM 数据集变体的 `runtime.default_kernel` 与 vLLM 主 case 相同，复用其已提交的内核 IR。Reentry 的历史 LLVM 12 HIP 构建缺少内建函数，已知 ROCm 6 构建的 IR 使用 opaque pointer。在 epyc 的实验目录和历史目录中没有找到可用的实际输入。无法由记录确定的 block size 写为 `null`。
- **snapshot**。以 `domain-reactivation/build/frozen-parity/*/summary.json` 为主，另外收录 PCM256 固定回归和 CED、HiPIMS-George、SasPoint5、SRAD-stage2、TPACF 留出运行的已接受步骤。以每个 summary 的 `selected`、`selected_cost` 和 `commits` 核对，保存被选中的 `fused.ll` 作为该步输出及下一步父 IR。跳过未被选中的试验文件和零提交的运行。LUD8 共 2 步（均为 perimeter，diagonal 和 internal 为零）、PCM32 17 步、NQU64 1 步、SRAD16 3 步、MS32 1 步、MapAiry 31 步。清单保留每步的源目录、运行记录和上一步父 IR 路径。来源清单引用历史文件，语料库提交保存抽出的 IR。

所有来源共 936 条（darm 27、project 39、snapshot 870），对应 912 个不同的源文件哈希。各类别和 case 的出现次数允许同一个模块以不同 provenance 出现。

## 抽取与计数口径

- 扫描源模块中的每个已定义函数。直接菱形或三角形优先识别为 B2B，汇合块的额外前驱在 occurrence 上标记。多块区域按最近共同后支配点及两侧单入口、单出口检查分类，含额外汇合前驱的非 B2B 形状归入 `other`。`structure` 中的整数是区域内的块编号，`edges` 顺序保留条件分支的真边和假边。各 occurrence 的 `source_index` 是 `sources.json` 中从零开始的索引。
- B2B 只使用所选路径的两条 PHI 入边。SRAD16 原始输入的 `srad_cuda_1` 在 `%175 → %191` 的汇合处有四个 21 入边 PHI，`srad_cuda_2` 在 `%109 → %119` 的汇合处有两个 8 入边 PHI。输出 IR 中每个 PHI 都只有两条入边。生成函数沿用原 triple、datalayout 和适用的函数属性。修改签名后无法复用 `allocsize` 的参数索引，新增输出写回时移除了与写回矛盾的内存和推测属性。同类型多输出写到数组，混合类型写到单个输出缓冲的对应结构字段。区域内地址计算、访存地址空间和 load/store 保留。
- 结构 ID 使用 SHA-1，对输入源文件仍按解压后的原始字节使用 SHA-256。B2B 以规范化后的独立模块和区域类型散列。其余类型从 CFG、操作和操作数依赖生成结构编码。忽略 SSA 名、块名和模块中的数字槽位，按首次引用编号编码匿名结构体类型，避免 LLVM 在无模块的类型打印中写入进程地址。结构编码保留有语义的直接被调函数名称、常量、类型和指令属性。目标、属性或源条件分类不同的影响见 inventory。条件来源逐处复用 `tools/anchor_condition.h`。
- 有 8 个 B2B 结构的 Fold 结果因抽象代价表缺少 `call` 项而为 `null`。可由安全性、PHI 条件或已知代价确定的结果仍记为布尔值。B2B 汇合 i1 PHI 的判断仅使用两条所选入边。最大抽取 IR 文件约 529 KB，未触发对单个 IR 文件的 gzip 阈值。
- 完整统计和缺项见 [SUMMARY.md](../../tests/dataflow-b2b/corpus/SUMMARY.md)。

## 生成和验证命令

```sh
cd /data/home/chh/kernel-benchmark-suite-dataflow-b2b
work=build/dataflow-corpus
corpus=tests/dataflow-b2b/corpus
mkdir -p "$work"
git fetch origin refs/heads/artifact/run
git clone https://github.com/charitha22/cgo22ae-darm-benchmarks "$work/upstream"
git -C "$work/upstream" rev-parse HEAD
python3 tools/dataflow_b2b/compile_upstream.py --work "$work" >"$work/upstream-compile.log" 2>&1
python3 tools/dataflow_b2b/collect_sources.py --work "$work" --output "$corpus"

llvm_root="$HOME/v2-runtime/toolchains/llvm12-jammy/usr"
export LD_LIBRARY_PATH="$llvm_root/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PYTHONDONTWRITEBYTECODE=1
cfg="$llvm_root/lib/llvm-12/bin/llvm-config"
opt="$llvm_root/lib/llvm-12/bin/opt"
g++ $("$cfg" --cxxflags) -std=c++17 -O2 -Wall -Wextra -Wno-unused-parameter -Wno-deprecated-declarations -Wno-template-id-cdtor \
    tools/dataflow_b2b/extract_regions.cpp \
    $("$cfg" --ldflags --libs core irreader analysis transformutils support --system-libs) \
    -o "$work/extract_regions"

python3 tools/dataflow_b2b/build_inventory.py --sources "$corpus/sources.json" \
    --extractor "$work/extract_regions" --opt "$opt" --work "$work" \
    --output "$work/validated" --jobs 4
python3 tools/dataflow_b2b/build_inventory.py --sources "$corpus/sources.json" \
    --extractor "$work/extract_regions" --opt "$opt" --work "$work" \
    --output "$work/reproduced" --jobs 4
diff -qr "$work/validated" "$work/reproduced"
cp -a "$work/validated"/. "$corpus"/
git diff --check
python3 tests/dataflow-b2b/check-micro.py --clang "$llvm_root/lib/llvm-12/bin/clang"
```

可单独运行 `build/dataflow-corpus/extract_regions INPUT.ll docs/dataflow-b2b/COST_TABLE.json OUTPUT_DIR`。工具将每个分支的 JSON 记录打印为一行，并将抽出的 IR 写入 `OUTPUT_DIR`。`build_inventory.py` 负责验证源文件的 SHA-256、聚合 occurrence 并对每个输出调用 `opt -verify -disable-output`。

两次全量运行结果一致。额外用 LLVM IR 验证了块名和值名重命名不改变 ID、立即数变更会改变 ID、重复的线程号内建量共用一个参数、AS1 指针和混合类型输出保留。所有 376 个独立文件都通过了 LLVM 12 verifier，912 个不同 SHA-256 的来源均可解析并验证。

```text
912 distinct source hashes; 0 source entries failed LLVM 12
4378 unique regions; 376 extracted files passed opt -verify
```

独立按源 IR 文本计数，共核对 112393 条条件分支；每处位置的来源索引、源文件哈希及抽取件结构哈希均匹配。原微型测试也重新通过。
