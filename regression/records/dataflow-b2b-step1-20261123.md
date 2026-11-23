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
