# Anchor B2B 第 8 步 · 默认 R 与发布复验

## 起点与实现

分支 `feat/anchor-unified-dp` 从 `926222f1d9cb5e607dc55901450a150875dde57f` 开始。新默认与 6c 的 `84e30a76` reject0 比较，legacy 与 `c7dded07a2a0d528c4a2b7ece1c7493e22d2758e` 比较。EPYC 实验目录为 `/data/home/chh/simplify-v2/build/anchor-dp-step8.HwSOtW`，下文路径相对此目录。

- 默认同时生成 fork、线性和守护布局，沿用两个独立投影的 unified DP。根据父 IR 的条件与确切 launch 形状逐 wave 分类，再按布局过滤；拒绝缺报价，保留 fork 参与比较。移除 dedup、线性发散过滤以及实验开关。legacy 走原有 fork 规划与 `emitB2BSegments`。区域 DARM、cleanup 与 throughput 报价保持原口径。
- 两个入口接受统一的 `--anchor-wave-shape X,Y,Z`。缺失时尝试确切的 `reqd_work_group_size`；仅有上界时分类为 unknown，主入口日志提示缺形状。`compile_kernel.py` 可把形状传给 Greedy。manifest 与各 `case.json` 登记同一组 6a 核实的形状及出处。历史归档的输入、参考和设备对象未重新冻结。
- 发布复验逐例跑两种模式，校验最终哈希、TTI 和提交数，重建并校验 16 个冻结发布 case 的设备对象，并报告新默认 TTI 高于 legacy 的差值。唯一报警为 CED **281 对 280（+1）**。LUD8 重放了已提交写回的同一父 IR：16×1×1 为 must-diverge，选择守护布局；去掉形状后警告、分类 unknown，守护布局被 gate 拒绝。完整搜索不传形状时只提交第一步（TTI 666），提供形状后提交第一步与写回（TTI 637）。

## 构建、测试与静态核验

环境由 `/data/home/chh/v2-runtime/reproduce.json` 提供，使用 LLVM12 与固定 LLVM24。下列 SHA-256 对应本次实际运行的可执行文件。

| 二进制 | SHA-256 |
| --- | --- |
| `source/build/decision-fuse/decision-greedy` | `cd0077ce173f8c165360070f3e2f2127aa2956b2f8d056633be49cb20991080b` |
| `source/build/llvm24-tti/fusion-search-llvm24` | `1e7eb3d975edbcfbc74954798ec29380b5f6c8ce209fc5398b1bd1ef210cdf54` |
| `source/build/llvm24-tti/llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| `ced-graph` | `ea4d053641530997196b3a0e94e996c35269dfdea68f5f9623d761662c0f2c36` |
| `lud-window` | `c2ab4a5086d3bdab9992fdbedbe7807f293fcd788a07b03cdcf4799ffe56c2dd` |

```sh
bash compile-anchor-step3.sh source
bash link-anchor-step2.sh source
bash test-anchor-step1.sh source final-anchor-dp-step8-r2
python3 step8-static.py "$PWD"
python3 step8-compare.py "$PWD"
python3 step8-rebuild-objects.py "$PWD"
python3 step8-rebuild-lud.py "$PWD"
python3 source/regression/verify_anchor_release.py --tool-root source --out verified-final --jobs 10
```

两套搜索使用各自新目录下的相同相对输出路径 `active`，并逐个核对冻结输入 SHA-256。全部最终 IR 通过 LLVM verifier。回归 16 项通过；`condition`、`pair-trial`、`regions`、`similarity` 按 `tests/KNOWN_FAILURES.md` 跳过。套件包含 Anchor 规划和统一发射、优化后 verifier 与 CPU 两分支核对、normalize-only、TTI 报价、trial queue 和提交评分失效检查。新增精确 metadata 测试覆盖无显式形状时的 fallback。首次测试的 AMDGPU fixture 缺少对应 flat-workgroup 属性，补齐后用新的输出目录完整重跑。另用 `compile_kernel.py --anchor-wave-shape 16,16,1` 编译 CED，得到相同的默认 HSACO SHA-256 `c9f5da8a8caab4cc492af650f8663fae867cb65356aaa16a8c49ce48223dae38`。

34 次完整搜索的提交链、最终 TTI、最终 IR 及 Anchor B2B 候选 IR/评分全部一致。逐文件比较 14,998 个 IR 路径、4,291 条 Anchor trial、10,471 条布局评分、719 次提交。1,374 处差异仅是非候选的 prepared/structural 快照中 `; preds =` 注释顺序。HLLD 有 5 个白名单 trial 差异，父 IR、候选编号、成对 IR 哈希和评分匹配既有基线重放，均未获选。验收使用的基线重放见 [6b](anchor-unified-dp-step6b-20261122.md) 和 [6c](anchor-unified-dp-step6c-20261122.md)。

| HLLD 候选 | 固定父 IR SHA-256 | 两种候选 IR SHA-256 | 本次出现 |
| --- | --- | --- | --- |
| `B9:B21:B12` | `162a59fd16e55a76dfb488b5361549df3adfd3d3712657def52b6c3cd06b504f` | `0e732f1488ffebc94e1cab72ce0daf9d19c9da29756f28e2837e1dccff9fee3e` / `4187ad0d4f4310521ae6fc5d893ff3bca1ba344cd9ebb38e74897313b509cf52` | default trial-23, legacy trial-23 |
| `B9:B22:B12` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `3d088bc542be3afa7cea5ea719ab027ec04353596c45db55c45c75d64e2de864` / `5a7d21cef13e427ed492cf02ac4c0fc9d7662ce1b76da627460a7171eb201d3a` | default trial-11 |
| `B9:B23:B12` | `1dc0d0dfaaae77778828b89df59a85afc7099ce03c439a1fd23fda3b3068ed91` | `0e5a464ec534233a07094584cbd49a3b325d4a404ba7339958d57f886fe462ef` / `dd1b16cbc43fd52e21b74a270680d5885dc1465df59648db24254e19123ff2b4` | default trial-12, legacy trial-12 |

下表哈希为最终 IR 的完整 SHA-256。各模式的后端重建还逐字节匹配下面 GPU 比较所用的 34 个 HSACO/cubin，保留了 Map-Airy 原后端特性参数、SRAD32 的历史 1024 线程诊断修正，以及 LUD8 原版工具链的 O3/llc O2 和链接步骤。

| Case | 确切形状 | 默认 提交/TTI | 默认 IR SHA-256 | legacy 提交/TTI | legacy IR SHA-256 |
| --- | --- | ---: | --- | ---: | --- |
| vllm | 64×1×1 | 225/2619 | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` | 225/2619 | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` |
| MapAiry | 256×1×1 | 30/3997 | `25a2d3b390209e09433d77547d88fc59cc4e121cad8470316142033ed81305b1` | 31/4065 | `388930dd748222e1e2b4e4eccbd6d43156c7f3d6d0a7baa33e9dbc1b7d3dd252` |
| tigre | 9×9×9 | 5/944 | `5aea08d6b2a5febf5eb480f283bde146e3a1c6b972dcf3fd51cdec94d28fdf61` | 6/946 | `ac3d39d3f979a4237b9dd5875e114da10a2e047647af3c2e4d02a7ef15b9f20a` |
| HLLD | 128×1×1 | 5/1696 | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` | 5/1696 | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` |
| NQU64 | 64×1×1 | 2/274 | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` | 2/274 | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` |
| MS32 | 32×1×1 | 2/198 | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` | 2/198 | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` |
| PCM32 | 32×1×1 | 17/1138 | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` | 17/1138 | `09305dd6ce16fd9dd197ddd3fa7a12ee97de69086bc3f7087e738fc1eea1c7f2` |
| SRAD16 | 16×16×1 | 3/446 | `84495226b219c7d3c405401e962a85122cd209101bc70ff2e7103a658ae8f55a` | 4/452 | `a874ce3e6de7dc81c55d058eafed0599c131723fcd46141854100d0f934a60ec` |
| SRAD32 | 32×32×1 | 3/446 | `5f76db84cd3958b85edbe91394ef7aba54672e0d44e548e721a94b4c8eaef638` | 4/452 | `775c85f9b192b53cc82078d603a99536da3918500fcdffdf6f51604a439a9fff` |
| Landau | 256×1×1 | 22/1635 | `0a776f8358682bca451208efdec2de8b7c23c985990debefa5b4eaa1f69ea944` | 20/1708 | `fb7a3852ffc14afc4fea138e9f06db4d8b6f77432897398ab73f0cc72c8b4bf5` |
| SW2D | 1024×1×1 | 1/1925 | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` | 1/1925 | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` |
| CED | 16×16×1 | 3/281 | `417664a60f8b61f295edc5ea6f6eebd9c17760d6f19cfedb6ff7540778dae78e` | 5/280 | `0db3898d2be02dd29bcae14c6522ea6ed86992e931fdf9861eea9b6caad8fe7a` |
| TPACF | 128×1×1 | 23/325 | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` | 23/325 | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` |
| SRAD-stage2 | 16×16×1 | 2/210 | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` | 2/210 | `b80a9581d7c8cb5e652c0b80b6658ffa98000051115380f910fc4e6c69272de8` |
| SasPoint5 | 256×1×1 | 8/487 | `cddeee0b711c71df961d6790a5d6501a1cab8070c4972dc17e1ee9d5292aab44` | 8/491 | `107673959aa91db3f36aea8a1fee279d01c65b9b5fff34f5eda6da15fa356f2e` |
| HiPIMS-George | 128×1×1 | 5/5572 | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` | 5/5572 | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` |
| LUD8 | 16×1×1 | 2/637 | `ef1fa6fd26c94734564b205d4c8b79bb69ec5cc8ace91c88d6163dbad45b4078` | 1/735 | `526ce2273ff4f2c93cb8ce2d20ac992cdfef6cf31ca24966601954911cb76442` |

主回执为 `matrix.json`、`comparison.json`、`verified-final/results.json`、`rebuilt.json`、`rebuilt-lud8/results.json`。

| 回执 | SHA-256 |
| --- | --- |
| `comparison.json` | `664b062dd8a02aaab3c1306bd0bba54ac625b0f7638ff6abd1f67d7134fe19d0` |
| `verified-final/results.json` | `86af94f508a93303e74cd8bb69332df1e9f1b9436344616a5c75cf256899e748` |
| `gpu/results.json` | `5eaad7f270106c6e08810e5a47eca72fea2d2028617e0278ceb3d99bb1af15e8` |
| `gpu-ced-step7/results.json` | `6c9c1b74b723e8bd4dcefa1e671c02b98ce09196b0d347cdee45f5ae2f2efa79` |
| `gpu-lud-retry/results.json` | `5a5e19bb49153533d9748ce9b8240d48b63e1026118b45eea78d3939066f6ed8` |

## 发布 GPU 回归

逐输入核对冻结 fixture 与参考哈希，完整验证每次计时输出。在 gfx906 和 RTX 3090 上，按发布协议单进程载入、至少 200 ms 批次预热、按轮换顺序测量 12 个窗口。同一设备字节相同的角色合并。发布 A/A 用同一 baseline 的两个角色，超过 1±1% 或跨度超过 3% 时重试一次；继续超限时走 v3（每窗口 31 次并取中位数，唯一重试增至 61）。CED 用第 7 步 HIP Graph。LUD8 用冻结的 16,384 确定性生成矩阵和完整输出指纹 `99f686c239322d34`，A/A 使用 legacy 代码对象，沿用 v3。

每列为同轮配对比值的中位数与 95% bootstrap 区间（10,000 次，固定种子 20261121）。区间完全高于 1.02 列为相对旧默认退化。设备角色路径与 SHA-256 在 `gpu-roles.json`，逐轮数据及 A/A 判定在 `gpu/results.json`。GPU 实际命令保存在对应目录的 `*.command.json`。Auto DARM 延用发布对照（vLLM 无区域复制、LUD8 原版完整三步）。实际执行 `python3 step8-gpu.py "$PWD"`，CED 的第 7 步 A/A 对照复跑执行 `python3 step8-ced-replay.py "$PWD"`。

| 冻结输入 | 默认/legacy | 默认/Auto DARM | legacy/Auto DARM | 协议与状态 |
| --- | ---: | ---: | ---: | --- |
| vllm/64K | 1.00000 [1.00000, 1.00000] | 0.82609 [0.82479, 0.82707] | 0.82609 [0.82479, 0.82707] | 默认/legacy 别名，沿用冻结发布配对 |
| vllm/128K | 1.00000 [1.00000, 1.00000] | 0.83199 [0.82665, 0.83790] | 0.83199 [0.82665, 0.83790] | 默认/legacy 别名，沿用冻结发布配对 |
| MapAiry/65539 | 1.00500 [1.00500, 1.00500] | 0.68836 [0.68836, 0.68896] | 0.68495 [0.68493, 0.68696] | 发布协议 |
| tigre/head64 | 1.00779 [1.00196, 1.01005] | 0.74800 [0.74707, 0.75471] | 0.74319 [0.74135, 0.74704] | 发布协议 |
| HLLD/65536 | 1.00000 [1.00000, 1.00000] | 0.72333 [0.72287, 0.72416] | 0.72333 [0.72287, 0.72416] | v3，61 次/窗口，默认/legacy 别名 |
| Landau/mixed | 1.00000 [1.00000, 1.00429] | 0.79145 [0.78983, 0.79322] | 0.78983 [0.78974, 0.79252] | v3，31 次/窗口 |
| Landau/coherent | 0.99301 [0.99296, 1.00000] | 0.88162 [0.87852, 0.88441] | 0.88237 [0.88199, 0.89342] | v3，61 次/窗口 |
| SW2D/258x259 | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 1.00000 [1.00000, 1.00000] | 三角色逐字节别名 |
| CED/110 | — | — | — | A/A 超限；第 7 步同对象历史 R/D 1.00032 [0.99638, 1.00968] |
| TPACF/16384 | 1.00000 [1.00000, 1.00000] | 0.35005 [0.34858, 0.35034] | 0.35005 [0.34858, 0.35034] | v3，31 次/窗口，默认/legacy 别名 |
| SRAD-stage2/256 | 1.00000 [1.00000, 1.00000] | 1.00000 [0.99145, 1.00862] | 1.00000 [0.99145, 1.00862] | v3，31 次/窗口，默认/legacy 别名 |
| SRAD-stage2/1024 | 1.00000 [1.00000, 1.00000] | 1.00351 [0.99826, 1.00699] | 1.00351 [0.99826, 1.00699] | v3，61 次/窗口，默认/legacy 别名 |
| SasPoint5/interval-mixture | 0.99255 [0.98400, 1.00781] | 0.47692 [0.47287, 0.48250] | 0.48062 [0.47674, 0.48062] | 发布协议 |
| SasPoint5/coherent-blocks | 1.00000 [0.99929, 1.02000] | 0.99503 [0.95952, 0.99716] | 0.97514 [0.95455, 0.99716] | v3，31 次/窗口 |
| SasPoint5/uniform-01 | 1.00000 [1.00000, 1.00000] | 0.85714 [0.85714, 0.85714] | 0.85714 [0.85714, 0.85714] | v3，31 次/窗口 |
| HiPIMS-George/128x128 | 1.00000 [1.00000, 1.00000] | 0.99863 [0.99777, 0.99995] | 0.99863 [0.99777, 0.99995] | 发布协议，默认/legacy 别名 |
| SRAD16/256 | — | — | — | A/A 超限 |
| SRAD32/256 | — | — | — | A/A 超限 |
| MS32 | 1.00000 [1.00000, 1.00000] | 0.99261 [0.98931, 0.99730] | 0.99261 [0.98931, 0.99730] | 发布协议，默认/legacy 别名 |
| PCM32 | 1.00000 [1.00000, 1.00000] | 1.07326 [1.07324, 1.07330] | 1.07326 [1.07324, 1.07330] | 默认/legacy 别名，沿用第 7 步配对 |
| NQU64 | 1.00000 [1.00000, 1.00000] | 0.98542 [0.98075, 0.99109] | 0.98542 [0.98075, 0.99109] | 发布协议，默认/legacy 别名 |
| LUD8/16384 | 0.89381 [0.89253, 0.89448] | 0.99282 [0.99125, 0.99407] | 1.11098 [1.10805, 1.11209] | v3，31 次/窗口 |

下表给出当轮全部 A/A 尝试。每格依序列出「每窗口次数或发布协议／中位数／跨度」。

| 冻结输入 | A/A 回执 |
| --- | --- |
| MapAiry/65539 | 发布/1.00000/0.19% |
| tigre/head64 | 发布/0.99646/2.75% |
| HLLD/65536 | 发布/0.99748/22.82%；发布/0.99001/20.43%；31/0.98995/0.76%；61/1.00504/0.76% |
| Landau/mixed | 发布/1.00094/13.30%；发布/1.00187/13.94%；31/1.00000/0.38% |
| Landau/coherent | 发布/0.99632/37.55%；发布/1.00368/61.25%；31/0.99998/3.75%；61/1.00000/1.50% |
| CED/110 | 31/0.99799/5.39%；61/0.99847/6.47%；按第 7 步使用 legacy 做 A/A：31/1.00799/6.75%；61/1.00275/5.85% |
| TPACF/16384 | 发布/0.99891/14.42%；发布/1.00118/13.98%；31/1.00050/1.62% |
| SRAD-stage2/256 | 发布/1.00424/46.82%；发布/0.99145/43.92%；31/1.00000/2.61% |
| SRAD-stage2/1024 | 发布/0.98441/45.88%；发布/1.01506/21.35%；31/0.99577/7.29%；61/1.00044/2.75% |
| SasPoint5/interval-mixture | 发布/1.00000/2.34% |
| SasPoint5/coherent-blocks | 发布/1.04545/40.91%；发布/1.00000/98.66%；31/1.00000/0.00% |
| SasPoint5/uniform-01 | 发布/1.00028/5.45%；发布/1.00000/17.52%；31/1.00000/0.17% |
| HiPIMS-George/128x128 | 发布/1.00000/0.44% |
| SRAD16/256 | 发布/0.99650/55.84%；发布/1.00000/44.12%；31/1.00355/12.70%；61/0.99293/18.62% |
| SRAD32/256 | 发布/1.00000/61.64%；发布/1.01089/64.03%；31/0.98606/20.75%；61/1.00000/8.27% |
| MS32 | 发布/1.00022/1.46% |
| NQU64 | 发布/1.00053/3.53%；发布/1.00362/2.82% |
| LUD8/16384 | 31/0.99941/0.56% |

LUD8 首次正式测量在第二窗口停滞超过 5 分钟。抓取的线程栈在 ROCm/HSA ioctl 内，已写出的 93 个样本全部通过完整输出校验。终止该进程并保留现场及其已通过的 A/A，再用同 runner、设备对象及 31 次/窗口独立重跑完整 12 窗口；正式区间只使用重跑批次。命令为 `python3 step8-lud-retry.py "$PWD"`，回执在 `gpu-lud-retry/results.json`。

SRAD16/32 的本轮比较在 A/A 停止。逐字节核对了 6c 的同输入 R/D 对象，历史比值分别为 0.99612 [0.99216, 1.00000] 与 0.99240 [0.98861, 0.99242]，无本轮对 Auto DARM 的结论。 [6c 计时](anchor-unified-dp-step6c-20261122.md)

22 个冻结输入中，本轮有效配对 15 个、字节别名或复用完全相同配对 4 个、A/A 超限 3 个。通过 A/A 或可按字节确认别名的输入中，没有相对旧默认超过 2% 的退化。

## 合并准备

`origin/feature/anchor-default` 的预检基准为 `86cd7d8234e02c1642b032162bb50ef47aaa1cd5`，是本分支的祖先。`git merge-tree --write-tree origin/feature/anchor-default HEAD` 无冲突。若目标保持该提交，批准后可快进，或按发布线惯例创建普通 merge 提交。

需同步两入口、Anchor 规划/发射/gate、case 形状、发布 manifest 和复验脚本、相关测试以及 README、STATUS、KNOWN_ISSUES 与本记录。冻结归档、输入、参考和历史测量均继续按原哈希引用。发布线和标签未动，等待合入批准。
