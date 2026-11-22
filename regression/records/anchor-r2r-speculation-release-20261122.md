# Anchor R2R 受限推测发布候选（第 9 步）

## 分支与范围

候选分支为 `release/anchor-r2r-speculation`，从发布线 `feature/anchor-default` 的 `3cf44a132f0b069577ad40ce2523bbb31aad46ff` 新建。纳入 `87c7d83` 的整数 gap 受限推测和 `7d9e705` 的 R2R 逐 wave gate、普通 R2R 回退以及修法 A。整数 gap 白名单继续排除 `freeze`，未带入修法 B 的用例。单元测试覆盖默认 Anchor 的 poison／undef 条件、未选侧 poison、legacy 访存前缀的 `freeze`、R2R 的 must-diverge 豁免，以及无确切形状时守护布局仍可参与普通 TTI 比较。

7b–7f 五份记录逐字节拷入，另在 README、STATUS 和已知问题中说明新行为、PCM32 已解决的差距及 SasPoint5 的路径依赖。7c 原记录内的试融二分脚本留在 study 分支。 [原诊断脚本](https://github.com/chhnb/kernel-benchmark-suite/blob/70a8466/regression/replay_pcm32_r2r_emission.py)

发布 manifest 只刷新变更 case 的 `anchor_profiles.default` 字段。旧归档、输入、GPU reference、legacy profile 和既有 `anchor_reference` 保留原记录。

## 构建与静态复验

实验目录为 EPYC 的 `/data/home/chh/simplify-v2/build/anchor-r2r-speculation-release.qCwPok`。使用固定 LLVM12 与 LLVM24 throughput 报价。新建目录编译搜索工具和驱动，复用固定的 LLVM24 worker。首次并行构建的 driver 在结构对象就绪前退出，等搜索对象完成后重新链接。首次套件缺少临时输出父目录，创建目录后完整重跑。

| 工具 | SHA-256 |
| --- | --- |
| `decision-greedy` | `e662c40a06809fc957ee43683f838b7065e04f5fb4ef067aecf0b569e330ac71` |
| `fusion-search-llvm24` | `e08dfe3d8ab876f30bb7042c35e8007337d0c61c9a4b534d571350385992ddb2` |
| LLVM24 TTI worker | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |

```sh
bash step9-build.sh "$PWD"
bash test-anchor-step1.sh "$PWD/source" step9
bash step9-verify.sh "$PWD"
python3 step9-compare.py "$PWD"
python3 step9-gate-replay.py "$PWD"
```

`step9-verify.sh` 用 `python3 regression/verify_anchor_release.py --tool-root . --out "$STAGE/verified" --jobs 12` 重放 17 个冻结输入和两个模式，按 manifest 校验精确形状、提交数、最终 TTI、最终 IR 以及 16 个冻结发布 case 的 HSACO／cubin。LUD8 的两套设备对象使用第 8 步专用 ROCm 4.2 后端独立重建。

LLVM verifier、17 个新默认完整提交链及最终 IR 均通过。新默认的全部 17 个最终设备对象逐字节匹配第 7f 步仅 A 的构建。Legacy 的 17 条完整提交链、最终 TTI 和最终 IR 逐字节匹配 `c7dded07` 的 D 回执。冻结发布集合的 16 个 legacy 设备对象匹配 manifest，LUD8 的 legacy 设备对象匹配第 8 步旧 D 对照。

完整发布复验只有 **CED 281 > 280（+1）** 报警。SasPoint5 **491 = 491**。

| Case | 新默认提交／TTI | Legacy 提交／TTI | 新默认最终 IR SHA-256 前缀 | 新默认设备对象 SHA-256 前缀 |
| --- | ---: | ---: | --- | --- |
| vllm | 225／2619 | 225／2619 | `186bc0f6e7fb` | `9aa97bca3906` |
| MapAiry | 30／3997 | 31／4065 | `109dae2f8e46` | `030b9488c8bb` |
| tigre | 5／942 | 6／946 | `5605316b9f7b` | `ffa327ddc018` |
| HLLD | 5／1696 | 5／1696 | `0ef79f2ea967` | `3aa2cad42001` |
| NQU64 | 2／274 | 2／274 | `383e6dfc7e11` | `83bec1d3bb5b` |
| MS32 | 2／198 | 2／198 | `f95ad2fe62d6` | `1be889a67dbd` |
| PCM32 | 18／1136 | 17／1138 | `debd97699989` | `5ba36c22102c` |
| SRAD16 | 3／445 | 4／452 | `29c33f08d366` | `ac992d49e046` |
| SRAD32 | 3／445 | 4／452 | `675b5641e456` | `fe59dbc7dc4d` |
| Landau | 22／1635 | 20／1708 | `31aea7ae5a00` | `a74f636a78aa` |
| SW2D | 1／1925 | 1／1925 | `2c231580ab79` | `cd0e00d27683` |
| CED | 3／281 | 5／280 | `f068294bdff0` | `c9f5da8a8caa` |
| TPACF | 23／325 | 23／325 | `bc5b0ff9d9a5` | `3853cc72321f` |
| SRAD-stage2 | 2／209 | 2／210 | `b1343cc5c72c` | `37ed260bde0e` |
| SasPoint5 | 7／491 | 8／491 | `eefddfe2b88b` | `9b8f297905ac` |
| HiPIMS-George | 5／5572 | 5／5572 | `f22721c031b2` | `5775bc0c9c04` |
| LUD8 | 2／628 | 1／735 | `387a564d46e1` | `15266ece5e83` |

LUD8 不提供形状的完整重跑仍提交两次，最终 TTI 655；提供 `16,1,1` 时为 628。复验脚本还在同父 IR 上确认缺形状时不得通过 guarded-linear gate。PCM32 用 `32,1,1` 时以 must-diverge 豁免接受 `trial-33`（1138 → 1136）；省略形状后同一推测布局因 `negative_uniform_gain` 被拒绝，退回普通 R2R 的 1263。

Legacy 逐个核对了 3,131 个落盘试融的候选身份、合法性、接受状态、IR 与有效报价。已有白名单获用 1 次。
- HLLD `trial-23` 在父 IR `162a59fd16e55a76dfb488b5361549df3adfd3d3712657def52b6c3cd06b504f` 上从 `0e732f1488ffebc94e1cab72ce0daf9d19c9da29756f28e2837e1dccff9fee3e`（TTI 1804）变为 `4187ad0d4f4310521ae6fc5d893ff3bca1ba344cd9ebb38e74897313b509cf52`（TTI 1805）。

回归套件 16 项通过，`condition`、`pair-trial`、`regions`、`similarity` 按 `tests/KNOWN_FAILURES.md` 跳过。

## SasPoint5 / uniform-01 补测

按 manifest 核对原 `input.txt`、输入、输出初始化及 reference 哈希。此 case 的发布对象为 CUDA cubin。首次 HIP 尝试在加载对象时退出，尚未启动 kernel。正式协议采用同样的 Graph 计时思路，在 EPYC 的 RTX 3090 上使用 CUDA Graph。每个 Graph 含 128 次相同冻结输入的 kernel launch，grid 为 257，block 为 256，独立输出。每个样本在计时区间外恢复输出初始化，GPU event 包围 Graph。每个节点的 65,539 个 double 输出均按冻结协议的 `atol=1e-14`、`rtol=5e-13` 校验；同时检查输入逐字节一致及前后 256 字节 guard。

每批预热至少 200 ms，同进程交替，12 窗口，每角色每窗口 31 个样本取中位数。A/A 使用两份原发布对象，中位时比须在 1±1%，跨度须不超过 3%。正式数据用每窗配对比值，固定种子 20261121 作 10,000 次 bootstrap 得到 95% 区间。备选 A/A 为 256 节点，只有第一档超限才运行。GPU 定时使用的候选对象来自第 7f 步 A；与本分支重建对象作字节对照。

```sh
g++ -std=c++17 -O2 -I/usr/local/cuda/include step9-sas-cuda-graph.cpp -lcuda -o sas-cuda-graph
python3 step9-sas.py "$PWD"
```

128 节点的 A/A 通过，中位时比 **1.00000**，跨度 **0.03508%**。正式测量中，发布与候选的窗口耗时中位数分别为 5.86240 和 5.86342 ms／Graph，新默认／发布的配对时比为 **1.00033 [1.00017, 1.00035]**，约慢 0.033%。A/A 和正式各有 744 个 Graph 样本，合计 190,464 个 kernel 输出全部通过校验。无需第二档。

## 合并预检

远端 `feature/anchor-default` 仍为 `3cf44a1`。最近的发布线集成 `cd7ee11`、`e3bb5fd`、`b54c3c0` 均为普通 merge 提交。用 `git merge-tree --write-tree origin/feature/anchor-default HEAD` 预检，结果树与候选 HEAD 的树相同，无冲突。待批准后可按惯例用 `git merge --no-ff release/anchor-r2r-speculation` 创建合并提交。

## 回执

| 回执 | SHA-256 |
| --- | --- |
| `verified/results.json` | `f3c292dfaca3c65e73670607000c1a9098e2ab95e008a9ff5090d8d79b2bf613` |
| `rebuilt-lud8/results.json` | `710510d74a0e7a6f9f61d12167f54645885f9b46f4049ce8ff30170d9d0b510f` |
| `legacy-trials.json` | `17c196d0c1a151bb8f72d133f6887b9e0dd16715801cc1660735b9bee4d26f2b` |
| `pcm32-missing-shape/structural/trial-0/trial.json` | `e9b6ea9b3a2f5e5e0843eb4c98089aad70e4eca810b4a477ec190c83761f8a36` |
| `tests.log` | `518e22f00321dd03c0932c0a9d01d817f71943e4ee8ab17cb1d444aaea61f388` |
| `compare.log` | `76ee9e28cc047fe982b95f932f61819a2fd7d9695f67da7d0699321b29a29c74` |
| `verify.log` | `c234c8cc68be2929b54d33d404e6033f88a76d4e0f1756d1969fd52e7cc89af4` |
| `sas-results.json` | `ee206882d0dbc26fc290ca6170bd3bfda39277ee90d83d538cbe1058454efcd6` |
| `sas-cuda-graph` | `6e453f22b0f62e2e84fc5597a384d0a328db059cb5bc476ab0191cf7613744af` |
| `step9-sas-cuda-graph.cpp` | `56b8f308eb7c22b9b198a8c996f90179a117150fa26c258be02cb27411115a6e` |
| `sas-aa1.csv` | `205fe476fa80524f51232ce1182d17031d8ba7d5c1049fa325d9d940a1acfd29` |
| `sas-comparison.csv` | `09c6ddae00dc108ba0505cf04faeab215b23f7ce4b9c5f93b83fa33864af9ac6` |
