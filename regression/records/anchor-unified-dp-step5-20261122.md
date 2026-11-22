# Anchor B2B DP 第 5 步：一致性诊断与计时覆盖

## 一致性能否区分收益和退化

**不能用本轮的静态分类或一致代价门槛把两组分开。** L/G0 在 17 案中的全部 247 条线性或守护提交，都被目标相关的 LLVM 分析标为 divergent，且逐次比同父最优 fork 的 cleanup TTI 严格更低。LLVM 的 divergent 表示某些执行中可能发散，无法说明这组输入上有多少 wave 实际走了两侧。

如果要求 `uniform_gain_false` 和 `uniform_gain_true` 均非负，NQU64 的慢提交会被挡住（−5、+4），但 LUD8 的写回收益提交也会被挡住（−27、−5），SasPoint5 的守护收益提交同样会被挡住（−90、−25）。MapAiry 的 26 条中有 23 条至少一侧为负，却在冻结输入上有稳定的最终收益。反过来，tigre 的 +1、+9 会通过该条件，尽管 GPU 小幅变慢。vLLM 有报价的 32 条也都是 +1、+9，另 32 条缺侧向报价。拒绝所有缺失项仍会留下前 32 条。以上反例均用同父实测静态报价，不能由最终 TTI 相等推断逐步收益持平。

运行时一致性的假设仍有价值。Landau 的 mixed 与 coherent 输入执行同一套产物，静态标签一致，补测呈现相反的 GPU 结果。要区分运行时一致性对收益的贡献，需要测量实际 wave 两侧参与情况及其动态权重。

## 环境与命令

- 起点为记录提交 `c3d4d6d21198aa0fc3f5edbd03a650f6c60caf5e`，分支 `feat/anchor-unified-dp`。第 4 步归档的分析基线为 `300e6f5` 的二进制。
- EPYC 工作目录 `/data/home/chh/simplify-v2/build/anchor-dp-step5.e9JDHh`。下文工件路径以它为根。
- AMDGPU 与 NVPTX 都用固定 LLVM12 的 GPU divergence 分析（`GPUDivergenceAnalysis`，使用目标机 TTI、dominator/post-dominator/loop 信息），查询分支的条件 use。无目标模型或无可分析条件记 unknown。使用的是获选请求实际读入的 IR；有 ordered-arm 条件归一化时，这份 IR 是准备后的候选父 IR。另在机器收据中保留 Greedy 提交父状态及两份哈希。
- 从第 4 步选中请求恢复原 block IDs、报价和实际试验父 IR。固定旧的二进制从同父仅跑 fork，比较合法且获报价的最低 cleanup TTI。保留无合并的 fork 对照。缺侧向报价的项不填 0，且一致代价仍为诊断项。
- 新参数 `--anchor-linear-require any|divergent|divergent-or-unknown` 默认 `any`。两种过滤实验只限制线性布局（含守护），其余候选保留 fork。默认执行路径不调用发散分析。
- 试验命令和收据见 `anchor-step5-profile.py`、`anchor-step5-static.py`、`anchor-step5-coverage.py` 和 `anchor-step5-coverage-compare.py`。输入和参考用第 4 步的同一发布 manifest 验证。

```sh
# 在第 5 步工作目录加载 /data/home/chh/v2-runtime/reproduce.json 的 environment。
search="$PWD/build/llvm24-tti/fusion-search-llvm24"
"$search" --ir "$trial_parent" --function "$function" --split "$split" \
  --anchor-condition-only 1 --out "$diagnostic_json"
"$step4_search" --ir "$trial_parent" --function "$function" \
  --split "$split" --left "$left" --right "$right" --anchor-gap fork \
  --tti-worker "$worker" --debug-dir "$fork_reports" --out "$fork_ir"
build/decision-fuse/decision-greedy "$frozen_ir" "$function" "$PWD" "$new_output" \
  --anchor-gap both --anchor-linear-require divergent
```

在 G0-div 加 `--anchor-guarded-gap 1`，允许 unknown 版本改为 `--anchor-linear-require divergent-or-unknown`。

## vLLM 的 64 次线性提交

L 与 G0 的 64 条提交逐一相同。条件 64 条均为 divergent，根节点包含 workitem/workgroup ID、全局输入 load（addrspace(1)）、dispatch load（addrspace(4)）、kernel 参数和控制汇合 PHI。普通 gain 分布是 **32 条 +11，32 条 +16**。相对同父最优 fork 的优势是 **32 条 +11，32 条 +15，0 条持平**。一致代价的 **32 条 +1/+9 和 32 条缺失**分别对应 +16 和 +11 两组。D/L 的完整搜索最终均为 2619，GPU L/D 为 **1.00746（64K）** 和 **1.01222（128K）**。

另在未准备的 Greedy 父状态核对了原决策块。104 条直接使用该父状态，143 条使用了准备 IR。后 143 条按原决策块位置重新查询，原条件与准备后的实际融合条件均为 divergent。逐条原条件记录在 `original-conditions.json`，SHA-256 为 `d13bd707faa07cd4594cfa3080168430cd34da4db3555cc25399f96caef76899`。

## 过滤实验

| case | L-div | L-div-unknown | G0-div | G0-div-unknown |
| --- | --- | --- | --- | --- |
| vllm | 225 / 2619 / 64 / 0 / L=G0 | 225 / 2619 / 64 / 0 / L=G0 | 225 / 2619 / 64 / 0 / L=G0 | 225 / 2619 / 64 / 0 / L=G0 |
| NQU64 | 2 / 274 / 0 / 0 / D=L | 2 / 274 / 0 / 0 / D=L | 3 / 270 / 0 / 1 / G0 | 3 / 270 / 0 / 1 / G0 |
| tigre | 5 / 944 / 1 / 0 / L=G0 | 5 / 944 / 1 / 0 / L=G0 | 5 / 944 / 1 / 0 / L=G0 | 5 / 944 / 1 / 0 / L=G0 |
| MapAiry | 30 / 3660 / 26 / 0 / L=G0 | 30 / 3660 / 26 / 0 / L=G0 | 30 / 3660 / 26 / 0 / L=G0 | 30 / 3660 / 26 / 0 / L=G0 |
| LUD8 | 1 / 666 / 1 / 0 / L | 1 / 666 / 1 / 0 / L | 2 / 637 / 1 / 1 / G0 | 2 / 637 / 1 / 1 / G0 |
| SasPoint5 | 7 / 485 / 4 / 0 / L | 7 / 485 / 4 / 0 / L | 8 / 458 / 4 / 1 / G0 | 8 / 458 / 4 / 1 / G0 |

每格为提交数 / 最终 TTI / 线性数 / 守护数 / 与第 4 步逐字节相同的配置。

24 次过滤版搜索均通过 verifier，没有产生与 D、L、G0 都不同的 IR。vLLM 两个冻结输入、NQU64、tigre、MapAiry、LUD8 和 SasPoint5 的 GPU 对照可以直接复用第 4 步的同字节产物。两种 unknown 政策产物相同，过滤没有消除 NQU64 的守护回归或 vLLM 的 64 条线性提交。

## 补齐计时覆盖

### 新协议 v3-window-median

保留发布 runner、冻结输入和全输出校验，使用同一个 EPYC GPU 锁串行运行。每个输入在新进程内按发布规则预热至少 200 ms，之后以 12 个交替窗口采样。每个窗口每个角色独立 reset、launch、event 计时和全输出校验 31 次，用其中位数作为窗口样本。A/A 的成对中位数须在 1±1%，跨度不超过 3%。初次不通过时，按预先规定的唯一重试将每窗口次数提高到 61；重试仍然失败则记录为无法可靠计时，不给正式时比。正式比较沿用通过 A/A 时的重复数，计算成对中位数及固定种子的 10,000 次 bootstrap 95% 区间。GPU 时钟保留机器现有设置，不改输入、参考或校验阈值。

CED 的旧 runner 忽略 --repeat，每个原生窗口只给 110 子输入的单次整批 kernel 时间。CED 使用同一 runner 扩为 12×31 个原生交替窗口，依序把每 31 个原生窗口的同角色完整校验时间取中位数，得到 12 个逻辑窗口；唯一重试扩为 12×61。先前收到的 12 个原生窗口只用来确认 runner 接口，不纳入 A/A 判定。


表中时比以同批 D 为基准，括号内为 95% 区间。「同」表示设备对象别名。

| 输入 | A/A（重复数，中位数，跨度） | L / D | G0 / D | 状态 |
| --- | --- | --- | --- | --- |
| HLLD/65536 | 31× 0.99498，1.78% | 0.98636 [0.98635, 0.98860] | 同 L | 完整校验后计时 |
| Landau/mixed | 31× 1.00000，0.56% | 0.80435 [0.80392, 0.80786] | 同 L | 完整校验后计时 |
| Landau/coherent | 31× 1.00000，2.25% | 1.30068 [1.29371, 1.30282] | 同 L | 完整校验后计时 |
| SRAD-stage2/256 | 31× 0.99153，1.75% | 同 D | 同 D | 完整校验后计时 |
| SRAD-stage2/1024 | 31× 1.00419，2.06% | 同 D | 同 D | 完整校验后计时 |
| SRAD16/256 | 31× 1.00000，2.69% | 1.00000 [0.99650, 1.04908] | 同 L | 完整校验后计时 |
| SRAD32/256 | 31× 1.00000，2.31% | 0.99315 [0.96482, 1.00002] | 同 L | 完整校验后计时 |
| CED/110 | 31× 0.99997，5.66% / 61× 0.99996，3.95% | — | — | A/A 两次超限 |
| SasPoint5/coherent-blocks | 31× 1.00000，0.13% | 1.03870 [1.00065, 1.04076] | 1.17391 [1.17391, 1.17391] | 完整校验后计时 |
| SasPoint5/uniform-01 | 31× 1.00000，0.28% | 1.00098 [1.00000, 1.02128] | 1.20833 [1.19816, 1.21277] | 完整校验后计时 |

## 默认关闭路径核对

固定父 IR，逐案重跑 D、L、G0、G1，68 份最终 IR、提交数和最终 TTI 均与第 4 步相同。源码中四个配置均保持 static cutoff 和 lazy 排序，live 与 eager 的分支未启用。后续清理若保留 static/lazy 实现，本轮没有任何产物依赖要删除的开启路径。未删除实验开关。

### 收据

- profiles-final.json SHA-256 1bdf5e98ca38029aca822b1d500d06fc891b20c9b676a2c7c22b1fa73ef91b3e
- static.json SHA-256 babcf78c9ac3118a61eda4f65c5cc0239b67f3676d965f98cd97648fa9042f98
- aa.json SHA-256 22dade2ab51ae9e0379741834929b0cdce0c884485a39bf6286a29f66976f590
- comparison.json SHA-256 e1a8c0e07de2e03963d63f9581ccddc5a9cca38fee0f758e5ba1e47500ed0ef9

- 分析/试验 `fusion-search-llvm24` SHA-256 为 `6d4fd2cc7c899c9512cc629e98f3962bd34e0fb5f565060046df7e9c9e5717e5`，`decision-greedy` 为 `7b79b205f14e74f35ede7c9edffba96abbf1059b94b9feb530055ccb1c7852af`。同父 fork 对照和 GPU 代码对象沿用第 4 步固定二进制，详见第 4 步收据。
- 计时覆盖为 9/10。SRAD stage2 的两个输入只有 D/L/G0 的同字节别名，验证已通过。CED 的两个尝试均通过完整输出校验，离散度仍超过预定 3% 门槛，因此不进入正式比较。
- Landau 在 mixed 上 L/D 为 0.80435，在 coherent 上为 1.30068。SasPoint5 的同一守护产物在 interval-mixture 上第 4 步有收益，coherent-blocks 和 uniform-01 补测中相对 D 分别为 1.17391 和 1.20833。相同静态判定对应不同输入的时比方向与幅度。
- 第一次同父核查遇到同时运行的 Greedy 占用临时 `active` 路径，已丢弃该次读数。完成的 247 项均强制解析归档路径，逐项核对 fork 与已选布局的 cleanup 基线 TTI 一致。原决策核对与归档分析没有改写冻结文件。
- 16 项测试通过，condition、pair-trial、regions、similarity 按 `tests/KNOWN_FAILURES.md` 跳过。新增测试覆盖两个目标的 wave 一致 kernel 参数与 workitem ID、非 GPU 模型的 unknown、uniform 分支在两种过滤模式下均走 fork。首次接入该回归样例时缺少 worker 所需的 target-cpu，补齐后整套复跑通过，见 `tests-r3.log`。

发散性作为审计信息保留。基于本轮成对证据，发布默认继续用 D，下一步若需要验证一致性机制，应在固定输入上记录动态 wave 的方向覆盖和热度。


### A. 逐案画像

L / G0 的一致代价栏按「两侧都非负 / 至少一侧负 / 未报价」列数。所有纳入的提交均标为 divergent，且 cleanup TTI 严格优于同父最优 fork。

| case | L 次数 | L 一致代价 | L gain | G0 次数 | G0 一致代价 | G0 gain |
| --- | --- | --- | --- | --- | --- | --- |
| vllm | 64 | 32 / 0 / 32 | 11…16 | 64 | 32 / 0 / 32 | 11…16 |
| MapAiry | 26 | 1 / 23 / 2 | 15…273 | 26 | 1 / 23 / 2 | 15…273 |
| tigre | 1 | 1 / 0 / 0 | 74…74 | 1 | 1 / 0 / 0 | 74…74 |
| HLLD | 2 | 0 / 0 / 2 | 4…102 | 2 | 0 / 0 / 2 | 4…102 |
| NQU64 | 0 | 0 / 0 / 0 | — | 1 | 0 / 1 / 0 | 4…4 |
| MS32 | 0 | 0 / 0 / 0 | — | 0 | 0 / 0 / 0 | — |
| PCM32 | 0 | 0 / 0 / 0 | — | 0 | 0 / 0 / 0 | — |
| SRAD16 | 2 | 0 / 2 / 0 | 9…11 | 2 | 0 / 2 / 0 | 9…11 |
| SRAD32 | 2 | 0 / 2 / 0 | 9…11 | 2 | 0 / 2 / 0 | 9…11 |
| Landau | 17 | 0 / 13 / 4 | 33…284 | 17 | 0 / 13 / 4 | 33…284 |
| SW2D | 0 | 0 / 0 / 0 | — | 0 | 0 / 0 / 0 | — |
| CED | 2 | 2 / 0 / 0 | 13…13 | 2 | 2 / 0 / 0 | 13…13 |
| TPACF | 0 | 0 / 0 / 0 | — | 0 | 0 / 0 / 0 | — |
| SRAD-stage2 | 0 | 0 / 0 / 0 | — | 0 | 0 / 0 / 0 | — |
| SasPoint5 | 4 | 0 / 4 / 0 | 55…55 | 5 | 0 / 5 / 0 | 27…55 |
| HiPIMS-George | 1 | 0 / 1 / 0 | 3…3 | 1 | 0 / 1 / 0 | 3…3 |
| LUD8 | 1 | 1 / 0 / 0 | 97…97 | 2 | 1 / 1 / 0 | 19…97 |

### 附录 A. 每次提交的条件与同父报价

同一行同时标 L 和 G0，表示两个配置中相同序号的提交具有同样条件、来源、块对与报价。条件完整 IR、根节点名称与父 IR SHA-256 见 profiles-final.json。缺失的一致代价保持为空值。

| case | 配置 | 步 | 块对 | 布局 | 条件分类 | 条件 | 来源 | 对照 | 候选 | gain | 一致 false | 一致 true | fork 最优 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| vllm | L/G0 | 6 | `%decision.dispatch1 / %if.then19.i` | linear | divergent | `%decision.left = xor i1 %decision.interval2, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 5199 | 5188 | 11 | — | — | 5199 |
| vllm | L/G0 | 8 | `%decision.dispatch / %if.else20.i` | linear | divergent | `%cmp18.i = fcmp olt float %101, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 5177 | 5161 | 16 | 1 | 9 | 5176 |
| vllm | L/G0 | 13 | `%decision.dispatch1 / %if.then19.i724` | linear | divergent | `%decision.left = xor i1 %decision.interval3, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 5117 | 5106 | 11 | — | — | 5117 |
| vllm | L/G0 | 15 | `%decision.dispatch / %if.else20.i726` | linear | divergent | `%cmp18.i722 = fcmp olt float %116, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 5095 | 5079 | 16 | 1 | 9 | 5094 |
| vllm | L/G0 | 20 | `%decision.dispatch1 / %if.then19.i702` | linear | divergent | `%decision.left = xor i1 %decision.interval4, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 5035 | 5024 | 11 | — | — | 5035 |
| vllm | L/G0 | 22 | `%decision.dispatch / %if.else20.i704` | linear | divergent | `%cmp18.i700 = fcmp olt float %131, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 5013 | 4997 | 16 | 1 | 9 | 5012 |
| vllm | L/G0 | 27 | `%decision.dispatch1 / %if.then19.i680` | linear | divergent | `%decision.left = xor i1 %decision.interval5, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4953 | 4942 | 11 | — | — | 4953 |
| vllm | L/G0 | 29 | `%decision.dispatch / %if.else20.i682` | linear | divergent | `%cmp18.i678 = fcmp olt float %146, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4931 | 4915 | 16 | 1 | 9 | 4930 |
| vllm | L/G0 | 34 | `%decision.dispatch1 / %if.then19.i658` | linear | divergent | `%decision.left = xor i1 %decision.interval6, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4871 | 4860 | 11 | — | — | 4871 |
| vllm | L/G0 | 36 | `%decision.dispatch / %if.else20.i660` | linear | divergent | `%cmp18.i656 = fcmp olt float %161, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4849 | 4833 | 16 | 1 | 9 | 4848 |
| vllm | L/G0 | 41 | `%decision.dispatch1 / %if.then19.i636` | linear | divergent | `%decision.left = xor i1 %decision.interval7, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4789 | 4778 | 11 | — | — | 4789 |
| vllm | L/G0 | 43 | `%decision.dispatch / %if.else20.i638` | linear | divergent | `%cmp18.i634 = fcmp olt float %176, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4767 | 4751 | 16 | 1 | 9 | 4766 |
| vllm | L/G0 | 48 | `%decision.dispatch1 / %if.then19.i614` | linear | divergent | `%decision.left = xor i1 %decision.interval8, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4707 | 4696 | 11 | — | — | 4707 |
| vllm | L/G0 | 50 | `%decision.dispatch / %if.else20.i616` | linear | divergent | `%cmp18.i612 = fcmp olt float %191, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4685 | 4669 | 16 | 1 | 9 | 4684 |
| vllm | L/G0 | 55 | `%decision.dispatch1 / %if.then19.i592` | linear | divergent | `%decision.left = xor i1 %decision.interval9, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4625 | 4614 | 11 | — | — | 4625 |
| vllm | L/G0 | 57 | `%decision.dispatch / %if.else20.i594` | linear | divergent | `%cmp18.i590 = fcmp olt float %206, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4603 | 4587 | 16 | 1 | 9 | 4602 |
| vllm | L/G0 | 62 | `%decision.dispatch1 / %if.then19.i570` | linear | divergent | `%decision.left = xor i1 %decision.interval10, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4543 | 4532 | 11 | — | — | 4543 |
| vllm | L/G0 | 64 | `%decision.dispatch / %if.else20.i572` | linear | divergent | `%cmp18.i568 = fcmp olt float %221, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4521 | 4505 | 16 | 1 | 9 | 4520 |
| vllm | L/G0 | 69 | `%decision.dispatch1 / %if.then19.i548` | linear | divergent | `%decision.left = xor i1 %decision.interval11, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4461 | 4450 | 11 | — | — | 4461 |
| vllm | L/G0 | 71 | `%decision.dispatch / %if.else20.i550` | linear | divergent | `%cmp18.i546 = fcmp olt float %236, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4439 | 4423 | 16 | 1 | 9 | 4438 |
| vllm | L/G0 | 76 | `%decision.dispatch1 / %if.then19.i526` | linear | divergent | `%decision.left = xor i1 %decision.interval12, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4379 | 4368 | 11 | — | — | 4379 |
| vllm | L/G0 | 78 | `%decision.dispatch / %if.else20.i528` | linear | divergent | `%cmp18.i524 = fcmp olt float %251, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4357 | 4341 | 16 | 1 | 9 | 4356 |
| vllm | L/G0 | 83 | `%decision.dispatch1 / %if.then19.i504` | linear | divergent | `%decision.left = xor i1 %decision.interval13, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4297 | 4286 | 11 | — | — | 4297 |
| vllm | L/G0 | 85 | `%decision.dispatch / %if.else20.i506` | linear | divergent | `%cmp18.i502 = fcmp olt float %266, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4275 | 4259 | 16 | 1 | 9 | 4274 |
| vllm | L/G0 | 90 | `%decision.dispatch1 / %if.then19.i482` | linear | divergent | `%decision.left = xor i1 %decision.interval14, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4215 | 4204 | 11 | — | — | 4215 |
| vllm | L/G0 | 92 | `%decision.dispatch / %if.else20.i484` | linear | divergent | `%cmp18.i480 = fcmp olt float %281, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4193 | 4177 | 16 | 1 | 9 | 4192 |
| vllm | L/G0 | 97 | `%decision.dispatch1 / %if.then19.i460` | linear | divergent | `%decision.left = xor i1 %decision.interval15, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4133 | 4122 | 11 | — | — | 4133 |
| vllm | L/G0 | 99 | `%decision.dispatch / %if.else20.i462` | linear | divergent | `%cmp18.i458 = fcmp olt float %296, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4111 | 4095 | 16 | 1 | 9 | 4110 |
| vllm | L/G0 | 104 | `%decision.dispatch1 / %if.then19.i438` | linear | divergent | `%decision.left = xor i1 %decision.interval16, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4051 | 4040 | 11 | — | — | 4051 |
| vllm | L/G0 | 106 | `%decision.dispatch / %if.else20.i440` | linear | divergent | `%cmp18.i436 = fcmp olt float %311, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 4029 | 4013 | 16 | 1 | 9 | 4028 |
| vllm | L/G0 | 111 | `%decision.dispatch1 / %if.then19.i416` | linear | divergent | `%decision.left = xor i1 %decision.interval17, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3969 | 3958 | 11 | — | — | 3969 |
| vllm | L/G0 | 113 | `%decision.dispatch / %if.else20.i418` | linear | divergent | `%cmp18.i414 = fcmp olt float %326, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3947 | 3931 | 16 | 1 | 9 | 3946 |
| vllm | L/G0 | 118 | `%decision.dispatch1 / %if.then19.i394` | linear | divergent | `%decision.left = xor i1 %decision.interval18, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3887 | 3876 | 11 | — | — | 3887 |
| vllm | L/G0 | 120 | `%decision.dispatch / %if.else20.i396` | linear | divergent | `%cmp18.i392 = fcmp olt float %356, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3865 | 3849 | 16 | 1 | 9 | 3864 |
| vllm | L/G0 | 125 | `%decision.dispatch1 / %if.then19.i372` | linear | divergent | `%decision.left = xor i1 %decision.interval19, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3805 | 3794 | 11 | — | — | 3805 |
| vllm | L/G0 | 127 | `%decision.dispatch / %if.else20.i374` | linear | divergent | `%cmp18.i370 = fcmp olt float %371, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3783 | 3767 | 16 | 1 | 9 | 3782 |
| vllm | L/G0 | 132 | `%decision.dispatch1 / %if.then19.i350` | linear | divergent | `%decision.left = xor i1 %decision.interval20, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3723 | 3712 | 11 | — | — | 3723 |
| vllm | L/G0 | 134 | `%decision.dispatch / %if.else20.i352` | linear | divergent | `%cmp18.i348 = fcmp olt float %386, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3701 | 3685 | 16 | 1 | 9 | 3700 |
| vllm | L/G0 | 139 | `%decision.dispatch1 / %if.then19.i328` | linear | divergent | `%decision.left = xor i1 %decision.interval21, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3641 | 3630 | 11 | — | — | 3641 |
| vllm | L/G0 | 141 | `%decision.dispatch / %if.else20.i330` | linear | divergent | `%cmp18.i326 = fcmp olt float %401, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3619 | 3603 | 16 | 1 | 9 | 3618 |
| vllm | L/G0 | 146 | `%decision.dispatch1 / %if.then19.i306` | linear | divergent | `%decision.left = xor i1 %decision.interval22, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3559 | 3548 | 11 | — | — | 3559 |
| vllm | L/G0 | 148 | `%decision.dispatch / %if.else20.i308` | linear | divergent | `%cmp18.i304 = fcmp olt float %416, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3537 | 3521 | 16 | 1 | 9 | 3536 |
| vllm | L/G0 | 153 | `%decision.dispatch1 / %if.then19.i284` | linear | divergent | `%decision.left = xor i1 %decision.interval23, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3477 | 3466 | 11 | — | — | 3477 |
| vllm | L/G0 | 155 | `%decision.dispatch / %if.else20.i286` | linear | divergent | `%cmp18.i282 = fcmp olt float %431, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3455 | 3439 | 16 | 1 | 9 | 3454 |
| vllm | L/G0 | 160 | `%decision.dispatch1 / %if.then19.i262` | linear | divergent | `%decision.left = xor i1 %decision.interval24, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3395 | 3384 | 11 | — | — | 3395 |
| vllm | L/G0 | 162 | `%decision.dispatch / %if.else20.i264` | linear | divergent | `%cmp18.i260 = fcmp olt float %446, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3373 | 3357 | 16 | 1 | 9 | 3372 |
| vllm | L/G0 | 167 | `%decision.dispatch1 / %if.then19.i240` | linear | divergent | `%decision.left = xor i1 %decision.interval25, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3313 | 3302 | 11 | — | — | 3313 |
| vllm | L/G0 | 169 | `%decision.dispatch / %if.else20.i242` | linear | divergent | `%cmp18.i238 = fcmp olt float %461, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3291 | 3275 | 16 | 1 | 9 | 3290 |
| vllm | L/G0 | 174 | `%decision.dispatch1 / %if.then19.i218` | linear | divergent | `%decision.left = xor i1 %decision.interval26, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3231 | 3220 | 11 | — | — | 3231 |
| vllm | L/G0 | 176 | `%decision.dispatch / %if.else20.i220` | linear | divergent | `%cmp18.i216 = fcmp olt float %476, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3209 | 3193 | 16 | 1 | 9 | 3208 |
| vllm | L/G0 | 181 | `%decision.dispatch1 / %if.then19.i196` | linear | divergent | `%decision.left = xor i1 %decision.interval27, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3149 | 3138 | 11 | — | — | 3149 |
| vllm | L/G0 | 183 | `%decision.dispatch / %if.else20.i198` | linear | divergent | `%cmp18.i194 = fcmp olt float %491, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3127 | 3111 | 16 | 1 | 9 | 3126 |
| vllm | L/G0 | 188 | `%decision.dispatch1 / %if.then19.i174` | linear | divergent | `%decision.left = xor i1 %decision.interval28, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3067 | 3056 | 11 | — | — | 3067 |
| vllm | L/G0 | 190 | `%decision.dispatch / %if.else20.i176` | linear | divergent | `%cmp18.i172 = fcmp olt float %506, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 3045 | 3029 | 16 | 1 | 9 | 3044 |
| vllm | L/G0 | 195 | `%decision.dispatch1 / %if.then19.i152` | linear | divergent | `%decision.left = xor i1 %decision.interval29, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2985 | 2974 | 11 | — | — | 2985 |
| vllm | L/G0 | 197 | `%decision.dispatch / %if.else20.i154` | linear | divergent | `%cmp18.i150 = fcmp olt float %521, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2963 | 2947 | 16 | 1 | 9 | 2962 |
| vllm | L/G0 | 202 | `%decision.dispatch1 / %if.then19.i130` | linear | divergent | `%decision.left = xor i1 %decision.interval30, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2903 | 2892 | 11 | — | — | 2903 |
| vllm | L/G0 | 204 | `%decision.dispatch / %if.else20.i132` | linear | divergent | `%cmp18.i128 = fcmp olt float %536, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2881 | 2865 | 16 | 1 | 9 | 2880 |
| vllm | L/G0 | 209 | `%decision.dispatch1 / %if.then19.i108` | linear | divergent | `%decision.left = xor i1 %decision.interval31, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2821 | 2810 | 11 | — | — | 2821 |
| vllm | L/G0 | 211 | `%decision.dispatch / %if.else20.i110` | linear | divergent | `%cmp18.i106 = fcmp olt float %551, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2799 | 2783 | 16 | 1 | 9 | 2798 |
| vllm | L/G0 | 216 | `%decision.dispatch1 / %if.then19.i86` | linear | divergent | `%decision.left = xor i1 %decision.interval32, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2739 | 2728 | 11 | — | — | 2739 |
| vllm | L/G0 | 218 | `%decision.dispatch / %if.else20.i88` | linear | divergent | `%cmp18.i84 = fcmp olt float %566, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2717 | 2701 | 16 | 1 | 9 | 2716 |
| vllm | L/G0 | 223 | `%decision.dispatch1 / %if.then19.i64` | linear | divergent | `%decision.left = xor i1 %decision.interval33, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2657 | 2646 | 11 | — | — | 2657 |
| vllm | L/G0 | 225 | `%decision.dispatch / %if.else20.i66` | linear | divergent | `%cmp18.i62 = fcmp olt float %581, 3.500000e+00` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 2635 | 2619 | 16 | 1 | 9 | 2634 |
| MapAiry | L/G0 | 1 | `%if.then30.i.i.i.i / %if.then41.i.i.i.i` | linear | divergent | `%cmp29.i.i.i.i = icmp sgt i32 %610, -9` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 6402 | 6129 | 273 | -3 | -3 | 6150 |
| MapAiry | L/G0 | 2 | `%decision.dispatch / %if.then52.i35.i.i.i` | linear | divergent | `%cmp40.i.i.i.i = icmp sgt i32 %610, -17` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 6129 | 5856 | 273 | -19 | -3 | 5877 |
| MapAiry | L/G0 | 3 | `%decision.dispatch1 / %if.then63.i.i.i.i` | linear | divergent | `%cmp51.i31.i.i.i = icmp sgt i32 %610, -33` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 5856 | 5583 | 273 | -35 | -3 | 5604 |
| MapAiry | L/G0 | 4 | `%decision.dispatch / %if.then74.i.i.i.i` | linear | divergent | `%cmp62.i.i.i.i = icmp sgt i32 %610, -65` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 5583 | 5310 | 273 | -51 | -3 | 5345 |
| MapAiry | L/G0 | 5 | `%decision.dispatch1 / %if.then85.i.i.i.i` | linear | divergent | `%cmp73.i.i.i.i = icmp sgt i32 %610, -129` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 5310 | 5037 | 273 | -67 | -3 | 5073 |
| MapAiry | L/G0 | 6 | `%decision.dispatch / %if.then96.i.i.i.i` | linear | divergent | `%cmp84.i.i.i.i = icmp sgt i32 %610, -257` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 5037 | 4764 | 273 | -83 | -3 | 4801 |
| MapAiry | L/G0 | 7 | `%decision.dispatch1 / %if.then107.i.i.i.i` | linear | divergent | `%cmp95.i.i.i.i = icmp sgt i32 %610, -513` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 4764 | 4491 | 273 | -99 | -3 | 4529 |
| MapAiry | L/G0 | 8 | `%if.then20.i.i.i.i / %decision.dispatch` | linear | divergent | `%cmp19.i.i.i.i = icmp sgt i32 %610, -5` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 4491 | 4229 | 262 | -2 | -126 | 4328 |
| MapAiry | L/G0 | 9 | `%if.then.i.i.i.i / %if.then3.i.i.i.i` | linear | divergent | `%decision.left = xor i1 %cmp.i.i.i.i, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID | 4229 | 4162 | 67 | — | — | 4173 |
| MapAiry | L/G0 | 11 | `%decision.dispatch2 / %if.then11.i.i.i.i` | linear | divergent | `%decision.left = xor i1 %decision.interval3, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID | 4096 | 4030 | 66 | — | — | 4062 |
| MapAiry | L/G0 | 12 | `%decision.dispatch3 / %decision.dispatch1` | linear | divergent | `%decision.left = xor i1 %decision.interval4, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID | 4032 | 3977 | 55 | -56 | -336 | 4014 |
| MapAiry | L/G0 | 13 | `%if.then14.i.i.i627.i.i.i.i / %if.else.i.i.i633.i.i.i.i` | linear | divergent | `%cmp13.i.i.i621.i.i.i.i = icmp sgt i32 %185, 2` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3977 | 3958 | 19 | 8 | -14 | 3968 |
| MapAiry | L/G0 | 14 | `%if.then12.i.i.i622.i.i.i.i / %if.else21.i.i.i634.i.i.i.i` | linear | divergent | `%cmp11.i.i.i619.i.i.i.i = icmp ult i32 %188, 64` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3958 | 3943 | 15 | -29 | 10 | 3958 |
| MapAiry | L/G0 | 15 | `%if.then14.i.i.i506.i.i.i.i / %if.else.i.i.i512.i.i.i.i` | linear | divergent | `%cmp13.i.i.i500.i.i.i.i = icmp sgt i32 %327, 2` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3943 | 3924 | 19 | 8 | -14 | 3934 |
| MapAiry | L/G0 | 16 | `%if.then12.i.i.i501.i.i.i.i / %if.else21.i.i.i513.i.i.i.i` | linear | divergent | `%cmp11.i.i.i498.i.i.i.i = icmp ult i32 %330, 64` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3924 | 3909 | 15 | -29 | 10 | 3924 |
| MapAiry | L/G0 | 17 | `%if.then14.i.i.i393.i.i.i.i / %if.else.i.i.i399.i.i.i.i` | linear | divergent | `%cmp13.i.i.i387.i.i.i.i = icmp sgt i32 %469, 2` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3909 | 3890 | 19 | 8 | -14 | 3900 |
| MapAiry | L/G0 | 18 | `%if.then12.i.i.i388.i.i.i.i / %if.else21.i.i.i400.i.i.i.i` | linear | divergent | `%cmp11.i.i.i385.i.i.i.i = icmp ult i32 %472, 64` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3890 | 3875 | 15 | -29 | 10 | 3890 |
| MapAiry | L/G0 | 19 | `%if.then14.i.i.i280.i.i.i.i / %if.else.i.i.i286.i.i.i.i` | linear | divergent | `%cmp13.i.i.i274.i.i.i.i = icmp sgt i32 %611, 2` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3875 | 3856 | 19 | 8 | -14 | 3866 |
| MapAiry | L/G0 | 20 | `%if.then12.i.i.i275.i.i.i.i / %if.else21.i.i.i287.i.i.i.i` | linear | divergent | `%cmp11.i.i.i272.i.i.i.i = icmp ult i32 %614, 64` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3856 | 3841 | 15 | -29 | 10 | 3856 |
| MapAiry | L/G0 | 21 | `%if.then14.i.i.i199.i.i.i.i / %if.else.i.i.i205.i.i.i.i` | linear | divergent | `%cmp13.i.i.i193.i.i.i.i = icmp sgt i32 %632, 2` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3841 | 3822 | 19 | 8 | -14 | 3832 |
| MapAiry | L/G0 | 22 | `%if.then12.i.i.i194.i.i.i.i / %if.else21.i.i.i206.i.i.i.i` | linear | divergent | `%cmp11.i.i.i191.i.i.i.i = icmp ult i32 %635, 64` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3822 | 3807 | 15 | -29 | 10 | 3822 |
| MapAiry | L/G0 | 23 | `%if.then14.i.i.i118.i.i.i.i / %if.else.i.i.i124.i.i.i.i` | linear | divergent | `%cmp13.i.i.i112.i.i.i.i = icmp sgt i32 %653, 2` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3807 | 3788 | 19 | 8 | -14 | 3798 |
| MapAiry | L/G0 | 24 | `%if.then12.i.i.i113.i.i.i.i / %if.else21.i.i.i125.i.i.i.i` | linear | divergent | `%cmp11.i.i.i110.i.i.i.i = icmp ult i32 %657, 64` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3788 | 3771 | 17 | -27 | 11 | 3788 |
| MapAiry | L/G0 | 26 | `%if.then14.i.i.i37.i.i.i.i / %if.else.i.i.i43.i.i.i.i` | linear | divergent | `%cmp13.i.i.i112.i.i.i.i = icmp sgt i32 %653, 2` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3762 | 3705 | 57 | 41 | 19 | 3753 |
| MapAiry | L/G0 | 28 | `%predication.first / %predication.second` | linear | divergent | `%cmp26.i.i.i130.i.i.i.i = icmp slt i32 %653, 1021` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3695 | 3680 | 15 | 5 | -13 | 3695 |
| MapAiry | L/G0 | 30 | `%predication.first / %predication.second` | linear | divergent | `%cmp26.i.i.i130.i.i.i.i = icmp slt i32 %653, 1021` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3675 | 3660 | 15 | 5 | -13 | 3675 |
| tigre | L/G0 | 5 | `%decision.dispatch / %if.then513` | linear | divergent | `%decision.take = or i1 %cmp484, %cmp498` | constant、dispatch ptr、kernel 参数、load addrspace(4)、workgroup ID、workitem ID、全局对象、控制汇合 PHI、标量 intrinsic | 1018 | 944 | 74 | 1 | 9 | 950 |
| HLLD | L/G0 | 2 | `%merged.bb88 / %merged.bb89` | linear | divergent | `%601 = or i1 %599, %600` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 1847 | 1745 | 102 | — | — | 1747 |
| HLLD | L/G0 | 4 | `%merged.bb31 / %merged.bb32` | linear | divergent | `%432 = fcmp olt double %431, %322` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 1704 | 1700 | 4 | — | — | 1701 |
| NQU64 | G0 | 3 | `%decision.dispatch / %merged.bb16` | guarded-linear | divergent | `%decision.take = or i1 %49, %decision.left` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(3)、load addrspace(4)、workgroup ID、workitem ID、全局对象、控制汇合 PHI | 274 | 270 | 4 | -5 | 4 | 274 |
| SRAD16 | L/G0 | 3 | `%160 / %fusion.common1` | linear | divergent | `%144 = icmp eq i32 %12, 15` | constant、workitem ID | 457 | 446 | 11 | 1 | -7 | 453 |
| SRAD16 | L/G0 | 4 | `%152 / %159` | linear | divergent | `%134 = icmp eq i32 %13, 0` | constant、workitem ID | 446 | 437 | 9 | -1 | -15 | 446 |
| SRAD32 | L/G0 | 3 | `%160 / %fusion.common1` | linear | divergent | `%144 = icmp eq i32 %12, 31` | constant、workitem ID | 457 | 446 | 11 | 1 | -7 | 453 |
| SRAD32 | L/G0 | 4 | `%152 / %159` | linear | divergent | `%134 = icmp eq i32 %13, 0` | constant、workitem ID | 446 | 437 | 9 | -1 | -15 | 446 |
| Landau | L/G0 | 1 | `%if.then30.i.i.i.i / %if.then42.i.i.i.i` | linear | divergent | `%cmp29.i.i.i.i = icmp sgt i32 %21, -9` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 4737 | 4453 | 284 | -6 | -6 | 4474 |
| Landau | L/G0 | 2 | `%if.then54.i.i.i.i / %if.then66.i.i.i.i` | linear | divergent | `%cmp53.i.i.i.i = icmp sgt i32 %21, -33` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 4453 | 4177 | 276 | -18 | -14 | 4198 |
| Landau | L/G0 | 3 | `%decision.dispatch / %decision.dispatch1` | linear | divergent | `%cmp41.i.i.i.i = icmp sgt i32 %21, -17` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 4177 | 3897 | 280 | -29 | -41 | 3988 |
| Landau | L/G0 | 4 | `%if.then30.i44.i.i.i / %if.then41.i.i.i.i` | linear | divergent | `%cmp29.i40.i.i.i = icmp sgt i32 %374, -9` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3897 | 3624 | 273 | -3 | -3 | 3645 |
| Landau | L/G0 | 5 | `%decision.dispatch / %if.then52.i.i.i.i` | linear | divergent | `%cmp40.i.i.i.i = icmp sgt i32 %374, -17` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3624 | 3351 | 273 | -19 | -3 | 3372 |
| Landau | L/G0 | 6 | `%decision.dispatch1 / %if.then63.i.i.i.i` | linear | divergent | `%cmp51.i.i.i.i = icmp sgt i32 %374, -33` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3351 | 3078 | 273 | -35 | -3 | 3099 |
| Landau | L/G0 | 7 | `%decision.dispatch / %if.then74.i.i.i.i` | linear | divergent | `%cmp62.i.i.i.i = icmp sgt i32 %374, -65` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 3078 | 2805 | 273 | -51 | -3 | 2840 |
| Landau | L/G0 | 8 | `%decision.dispatch1 / %if.then85.i.i.i.i` | linear | divergent | `%cmp73.i.i.i.i = icmp sgt i32 %374, -129` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 2805 | 2532 | 273 | -67 | -3 | 2568 |
| Landau | L/G0 | 9 | `%decision.dispatch / %if.then96.i.i.i.i` | linear | divergent | `%cmp84.i.i.i.i = icmp sgt i32 %374, -257` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 2532 | 2259 | 273 | -83 | -3 | 2296 |
| Landau | L/G0 | 10 | `%decision.dispatch1 / %if.then107.i.i.i.i` | linear | divergent | `%cmp95.i.i.i.i = icmp sgt i32 %374, -513` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 2259 | 1986 | 273 | -99 | -3 | 2024 |
| Landau | L/G0 | 11 | `%if.then20.i.i.i.i / %decision.dispatch2` | linear | divergent | `%cmp19.i.i.i.i = icmp sgt i32 %21, -5` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 1986 | 1719 | 267 | -3 | -96 | 1785 |
| Landau | L/G0 | 12 | `%if.then20.i39.i.i.i / %decision.dispatch` | linear | divergent | `%cmp19.i34.i.i.i = icmp sgt i32 %266, -5` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、标量 intrinsic | 1719 | 1457 | 262 | -2 | -126 | 1556 |
| Landau | L/G0 | 15 | `%decision.dispatch / %if.then11.i.i.i.i` | linear | divergent | `%decision.left = xor i1 %decision.interval, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID | 1323 | 1259 | 64 | — | — | 1307 |
| Landau | L/G0 | 16 | `%if.then.i21.i.i.i / %decision.dispatch3` | linear | divergent | `%decision.left = xor i1 %cmp.i6.i.i.i, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID | 1259 | 1195 | 64 | — | — | 1247 |
| Landau | L/G0 | 17 | `%decision.dispatch / %decision.dispatch2` | linear | divergent | `%decision.left = xor i1 %decision.interval1, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID | 1196 | 1146 | 50 | -54 | -340 | 1178 |
| Landau | L/G0 | 18 | `%decision.dispatch4 / %decision.dispatch1` | linear | divergent | `%decision.left1 = xor i1 %decision.interval5, true` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID | 1159 | 1099 | 60 | — | — | 1141 |
| Landau | L/G0 | 19 | `%decision.dispatch / %if.else75.i.i.i.i` | linear | divergent | `%decision.take = phi i1 [ true, %if.then.i.i.i ], [ %cmp65.i.i.i.i, %if.else17.i.i.i.i ]` | constant、dispatch ptr、kernel 参数、load addrspace(1)、load addrspace(4)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 1099 | 1066 | 33 | — | — | 1080 |
| CED | L/G0 | 2 | `%merged.bb2 / %merged.bb4` | linear | divergent | `%133 = icmp eq i32 %17, 0` | constant、workitem ID | 307 | 294 | 13 | 7 | 1 | 305 |
| CED | L/G0 | 3 | `%39 / %46` | linear | divergent | `%37 = icmp eq i32 %17, 0` | constant、workitem ID | 294 | 281 | 13 | 5 | 1 | 292 |
| SasPoint5 | L/G0 | 3 | `%decision.dispatch1 / %270` | linear | divergent | `%269 = fcmp olt double %20, 4.000000e+00` | constant、kernel 参数、load addrspace(0)、workgroup ID、workitem ID、标量 intrinsic | 744 | 689 | 55 | -44 | -12 | 690 |
| SasPoint5 | L/G0 | 4 | `%decision.dispatch / %287` | linear | divergent | `%286 = fcmp olt double %20, 8.000000e+00` | constant、kernel 参数、load addrspace(0)、workgroup ID、workitem ID、标量 intrinsic | 689 | 634 | 55 | -60 | -12 | 639 |
| SasPoint5 | L/G0 | 5 | `%decision.dispatch1 / %304` | linear | divergent | `%303 = fcmp olt double %20, 1.600000e+01` | constant、kernel 参数、load addrspace(0)、workgroup ID、workitem ID、标量 intrinsic | 634 | 579 | 55 | -76 | -12 | 585 |
| SasPoint5 | L/G0 | 6 | `%decision.dispatch / %321` | linear | divergent | `%320 = fcmp olt double %20, 3.200000e+01` | constant、kernel 参数、load addrspace(0)、workgroup ID、workitem ID、标量 intrinsic | 579 | 524 | 55 | -92 | -12 | 531 |
| SasPoint5 | G0 | 8 | `%decision.dispatch1 / %255` | guarded-linear | divergent | `%112 = fcmp olt double %20, 6.400000e+01` | constant、kernel 参数、load addrspace(0)、workgroup ID、workitem ID、标量 intrinsic | 485 | 458 | 27 | -90 | -25 | 486 |
| HiPIMS-George | L/G0 | 3 | `%3873 / %3879` | linear | divergent | `%3872 = fcmp ogt double %2594, %2595` | constant、kernel 参数、load addrspace(0)、workgroup ID、workitem ID、控制汇合 PHI、标量 intrinsic | 5578 | 5575 | 3 | -8 | -8 | 5577 |
| LUD8 | L/G0 | 1 | `%7 / %102` | linear | divergent | `%6 = icmp ult i32 %4, 8` | constant、workitem ID | 763 | 666 | 97 | 7 | 2 | 735 |
| LUD8 | G0 | 2 | `%427 / %470` | guarded-linear | divergent | `%5 = icmp ult i32 %4, 8` | constant、workitem ID | 656 | 637 | 19 | -27 | -5 | 656 |
