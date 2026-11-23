# 第 6 步 ILP 与 NQU64、MapAiry 端到端验证

## 求解器回归

| 复跑集合 | 已证明且与旧结果一致 | 总运行数 |
|---|---:|---:|
| small 抽象 | 187 | 187 |
| small 真实 | 187 | 187 |
| medium 第 5b 步已证明 | 67 | 67 |

共 91 次有效 anchor 提示。新增 81 条长环约束。
两种目标都核对了完整三场景向量，441 次重跑同时通过语义验证。无报价区域沿用第 5 和 5b 步的排除。

## Medium 超时复跑

| 类型 | 全部区域 | 第 5b 步双目标已证明 | 第 6 步双目标已证明 | 复跑仍未证明 | 无报价 |
|---|---:|---:|---:|---:|---:|
| diamond | 53 | 15 | 16 | 37 | 0 |
| triangle | 72 | 52 | 56 | 15 | 1 |

下界取第一次 CP-SAT 松弛的 `best_objective_bound`。松弛计入确定存活且报价不随配对变化的操作，以及必保留保护段的分支。后续长环、强制推测和多保护段裁剪只删除方案，所以下界仍有效。实际求得 0 时保留该值。完成穷举时上、下界相等。

- 最小 D 仍未证明 52 个，其中 42 个下界大于 0。52 个有间隙，范围 28.6%–100.0%，中位数 78.4%。
- §7.2 仍未证明 52 个，其中 42 个下界大于 0。52 个有间隙，范围 28.6%–100.0%，中位数 80.0%。

| 区域 ID | 类型 | 旧 D 下界 / 间隙 | 新 D 上界 | 新 D 下界 / 间隙 | 旧 §7.2 下界 / 间隙 | 新 §7.2 上界 | 新 §7.2 下界 / 间隙 | 双目标证明 |
|---|---|---:|---:|---:|---:|---:|---:|---|
| `05cbccd64deafbe08d17207494e43e3d8156cf85` | diamond | 0 / 100.0% | 103 | 17 / 83.5% | 0 / 100.0% | 103 | 17 / 83.5% | 否 |
| `090f2cd17446af3debba11b04464340a454b0ec3` | diamond | 0 / 100.0% | 62 | 24 / 61.3% | 0 / 100.0% | 62 | 24 / 61.3% | 否 |
| `0e2991b2265ed5e419c80863c10f6d3dbb68b11e` | diamond | 0 / 100.0% | 103 | 18 / 82.5% | 0 / 100.0% | 103 | 18 / 82.5% | 否 |
| `11c070dd78ba01030ee1512bbaad4b6993935dc1` | diamond | 0 / 100.0% | 87 | 14 / 83.9% | 0 / 100.0% | 87 | 14 / 83.9% | 否 |
| `215d902a84870a9674648c5603d5b85d204db314` | diamond | 0 / 100.0% | 95 | 24 / 74.7% | 0 / 100.0% | 117 | 24 / 79.5% | 否 |
| `2a0ac8514f96ba2f393d76a0986f38d471325e14` | diamond | 0 / 100.0% | 58 | 12 / 79.3% | 0 / 100.0% | 78 | 12 / 84.6% | 否 |
| `2bf53c6e0704ae9f5f5e8a2f8dd1dc237df24e61` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `32bf8966046d0dd11ac9d5adccc1f92635c61ff7` | diamond | 0 / 100.0% | 90 | 24 / 73.3% | 0 / 100.0% | 90 | 24 / 73.3% | 否 |
| `43688e8df875a05f5a5b898f8b69cbacee0b6612` | diamond | 0 / 100.0% | 79 | 32 / 59.5% | 0 / 100.0% | 79 | 32 / 59.5% | 否 |
| `4916ee879b339603058f83083198d712f50413db` | diamond | 0 / 100.0% | 42 | 30 / 28.6% | 0 / 100.0% | 42 | 30 / 28.6% | 否 |
| `5191b72e69588e2145718b41b97b8adb76cfb96b` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `565deba7de2fe96622f16e3784a784b00fe1ac4e` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `65b6b1a7fd1b68140792d4c4ff4bc8ba06b0d2a1` | diamond | 0 / 100.0% | 34 | 2 / 94.1% | 0 / 100.0% | 34 | 2 / 94.1% | 否 |
| `672125a6633e425cc617e57c94e591ea7fd0a89f` | diamond | 0 / 100.0% | 62 | 14 / 77.4% | 0 / 100.0% | 82 | 14 / 82.9% | 否 |
| `6a1c89d960b027ae8d89e33aeea2ca149ee257a3` | diamond | 0 / 100.0% | 76 | 24 / 68.4% | 0 / 100.0% | 76 | 24 / 68.4% | 否 |
| `6c38894262ee7115078b0effb98708b54ef48ea1` | diamond | 0 / 100.0% | 43 | 14 / 67.4% | 0 / 100.0% | 61 | 14 / 77.0% | 否 |
| `6ecd5daad8155ea3c5a93f86140db47fc9e48638` | diamond | 0 / 100.0% | 81 | 16 / 80.2% | 0 / 100.0% | 96 | 16 / 83.3% | 否 |
| `70e11c5e7ef5e688b4089719cbacbc00d194edba` | diamond | 0 / 100.0% | 90 | 24 / 73.3% | 0 / 100.0% | 90 | 24 / 73.3% | 否 |
| `731e6cce7e1f19849050a6967e3abc2faeca08e8` | diamond | 0 / 100.0% | 15 | 3 / 80.0% | 0 / 100.0% | 15 | 3 / 80.0% | 否 |
| `73cb7f8dee1a26336ab5bdf72c3d13ad7dc60218` | diamond | 0 / 100.0% | 103 | 17 / 83.5% | 0 / 100.0% | 103 | 17 / 83.5% | 否 |
| `8a15a93c7183b43087bef82c08aea00bac86ccf5` | diamond | 0 / 100.0% | 76 | 24 / 68.4% | 0 / 100.0% | 76 | 24 / 68.4% | 否 |
| `90e4b3785dac861d4d2b9b5f0acf7d9fdb668a8b` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `a2e2007cd816d8b111f48ec8749f94b5b66d07d6` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `b5049a6c7989410a4fdf59cec222988a4c4821cc` | diamond | 0 / 100.0% | 15 | 3 / 80.0% | 0 / 100.0% | 15 | 3 / 80.0% | 否 |
| `bc523a01f48319d8d39ede01e1621a51a99ed209` | diamond | 0 / 100.0% | 62 | 24 / 61.3% | 0 / 100.0% | 62 | 24 / 61.3% | 否 |
| `c2ac2dceab1ee4e2aae50609c9e09831dc0dcdf6` | diamond | 0 / 100.0% | 34 | 2 / 94.1% | 0 / 100.0% | 34 | 2 / 94.1% | 否 |
| `c51a7e4eaacc4bc6780d9a0a9a1d54218d95fd2b` | diamond | 0 / 100.0% | 60 | 0 / 100.0% | 0 / 100.0% | 63 | 0 / 100.0% | 否 |
| `c6e1de82fa5a4fb699896e5a710f7ceb1a47a11c` | diamond | 0 / 100.0% | 106 | 19 / 82.1% | 0 / 100.0% | 117 | 19 / 83.8% | 否 |
| `ca4ce2e08f2905009133ae4705ad1b0f96b3249e` | diamond | 0 / 100.0% | 54 | 0 / 100.0% | 0 / 100.0% | 69 | 0 / 100.0% | 否 |
| `cb9c26f323030209c4e0e7e3606572d28abce282` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `cb9fefec11e0dd03bf30f6641ae8bb080e24c7fc` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `cc04713e8ddcfb2bd15cf88385ee35e2bafb29ec` | diamond | 0 / 100.0% | 52 | 14 / 73.1% | 0 / 100.0% | 69 | 14 / 79.7% | 否 |
| `ccbbd3f701995dba26516f03c8e00816667ee129` | diamond | 0 / 100.0% | 71 | 0 / 100.0% | 0 / 100.0% | 76 | 0 / 100.0% | 否 |
| `d099be01e17e46d5c3b1f60a4bb42b729055fe3b` | diamond | 0 / 100.0% | 36 | 16 / 55.6% | 0 / 100.0% | 36 | 16 / 55.6% | 否 |
| `d10023bab4c9c2d96452b347e6252b00f43b30c1` | diamond | 0 / 100.0% | 47 | 0 / 100.0% | 0 / 100.0% | 50 | 0 / 100.0% | 否 |
| `d3a3d4e5e861a2c2cb1cf309b0568edd8db40c3a` | diamond | 0 / 100.0% | 51 | 24 / 52.9% | 0 / 100.0% | 51 | 24 / 52.9% | 否 |
| `da90a2b4ba54d65ca6518eff6838176df76a39cb` | diamond | 0 / 100.0% | 48 | 24 / 50.0% | 0 / 100.0% | 48 | 24 / 50.0% | 否 |
| `de3e276c7858c3cd1cb7a5260f67b7d79052605d` | diamond | 0 / 100.0% | 22 | 22 / 0.0% | 0 / 100.0% | 25 | 25 / 0.0% | 是 |
| `2f09de5a3ed07e245e3b056bb43a9e1cf77ae8c5` | triangle | 0 / 100.0% | 70 | 32 / 54.3% | 0 / 100.0% | 70 | 32 / 54.3% | 否 |
| `3447d1c152af204422036437c4d544ab97cd2b90` | triangle | 0 / 100.0% | 58 | 0 / 100.0% | 0 / 100.0% | 58 | 0 / 100.0% | 否 |
| `43cacdef5fdba1b3cc99843f00c85cf773984e36` | triangle | 94 / 0.0% | 94 | 94 / 0.0% | 0 / 100.0% | 94 | 94 / 0.0% | 是 |
| `4e8211443ded96050e9d95384092989ee594365a` | triangle | 0 / 100.0% | 37 | 0 / 100.0% | 0 / 100.0% | 48 | 0 / 100.0% | 否 |
| `51944e700512e2414c9c91129fd5190fdb453f27` | triangle | 0 / 100.0% | 22 | 0 / 100.0% | 0 / 100.0% | 33 | 0 / 100.0% | 否 |
| `5520dacef7e707a233419116bca08159e175c984` | triangle | 0 / 100.0% | 37 | 0 / 100.0% | 0 / 100.0% | 48 | 0 / 100.0% | 否 |
| `57e5a1d9874606f26274f5fe2aa59cdaf03539c4` | triangle | 0 / 100.0% | 71 | 4 / 94.4% | 0 / 100.0% | 82 | 4 / 95.1% | 否 |
| `5be73e6cde7e79d6fde7947e450f534de81b5037` | triangle | 60 / 0.0% | 60 | 60 / 0.0% | 0 / 100.0% | 60 | 60 / 0.0% | 是 |
| `63afd293d84f1fa4fdab08ed207e71997503dfd3` | triangle | 0 / 100.0% | 91 | 11 / 87.9% | 0 / 100.0% | 91 | 11 / 87.9% | 否 |
| `8b237daf658c7a1039da0c9ab8efc9be20dfd450` | triangle | 0 / 100.0% | 55 | 6 / 89.1% | 0 / 100.0% | 66 | 6 / 90.9% | 否 |
| `99d55434337685264381fdaeeacee0a667c8a065` | triangle | 0 / 100.0% | 69 | 32 / 53.6% | 0 / 100.0% | 69 | 32 / 53.6% | 否 |
| `b09f0d407b042362e18f74c2be1e80910c4290c4` | triangle | 0 / 100.0% | 92 | 15 / 83.7% | 0 / 100.0% | 92 | 15 / 83.7% | 否 |
| `b725dcb2bd9d20e3d77f2bb928cae965fab9d4fa` | triangle | 47 / 0.0% | 47 | 47 / 0.0% | 0 / 100.0% | 47 | 47 / 0.0% | 是 |
| `cb568be75c28263f65bd975bd0947008b9fdf776` | triangle | 0 / 100.0% | 65 | 19 / 70.8% | 0 / 100.0% | 65 | 19 / 70.8% | 否 |
| `cf330aa862731c739160ae7cc26cec7fd7d02077` | triangle | — | 42 | 42 / 0.0% | — | 53 | 53 / 0.0% | 是 |
| `e6437d0696729675d168c1a2cb8f252b2ef17532` | triangle | 0 / 100.0% | 22 | 0 / 100.0% | 0 / 100.0% | 33 | 0 / 100.0% | 否 |
| `efb48f96297d602a644a601f6e53f91bcbfb2eae` | triangle | 0 / 100.0% | 52 | 19 / 63.5% | 0 / 100.0% | 52 | 19 / 63.5% | 否 |
| `f55c0886648a1d83d595b503454807ab1792a1e7` | triangle | 0 / 100.0% | 123 | 12 / 90.2% | 0 / 100.0% | 123 | 12 / 90.2% | 否 |
| `faa47a3aa4481cba32746ef81c7815c5c18e7d59` | triangle | 0 / 100.0% | 87 | 0 / 100.0% | 0 / 100.0% | 87 | 0 / 100.0% | 否 |

## NQU64

| 变体 | LLVM 24 TTI | 贪心提交 | CPU / GPU 验证 | GPU 中位数 (µs) | IR 条件分支 / 无条件分支 / 控制 TTI | ISA 条件分支 / 全部分支 / exec 指令 |
|---|---:|---:|---|---:|---:|---:|
| original | 289 | 0 | 通过 | 10365.997 | 12 / 13 / 136 | 13 / 15 / 36 |
| anchor | 274 | 2 | 通过 | 8730.465 | 10 / 11 / 114 | 11 / 13 / 27 |
| darm | 274 | 2 | 通过 | 8741.987 | 10 / 11 / 114 | 11 / 13 / 27 |
| dataflow-ilp | 274 | 2 | 通过 | 8725.979 | 10 / 11 / 114 | 11 / 13 / 27 |

Dataflow-ILP / anchor 的配对时间比为 **1.00028**（95% bootstrap 区间 0.99643–1.00330）。
两版最终 HSACO 的 SHA-256 相同。

Dataflow-ILP 结构试验处理方式计数为 `{'existing_anchor': 2, 'existing_pipeline': 6, 'ilp_solver': 4, 'reference_solver': 8}`，提交处理方式计数为 `{'existing_pipeline': 1, '既有流程': 1}`。候选的求解状态、区域 T 以及回填清理前后的 kernel 报价在逐项证据中。

### 贪心提交

#### anchor

| 步 | 区域 ID 或流程 | 处理方式 | Kernel TTI |
|---:|---|---|---:|
| 1 | `0ee2ac3a0c79a3eb54e5a8f8cdbc70372840bb29` / b2r 根 | darm-B2R | 289 → 282 |
| 2 | normalize-only | normalize-only | 282 → 274 |

#### darm

| 步 | 区域 ID 或流程 | 处理方式 | Kernel TTI |
|---:|---|---|---:|
| 1 | `0ee2ac3a0c79a3eb54e5a8f8cdbc70372840bb29` / b2r 根 | darm-B2R | 289 → 282 |
| 2 | normalize-only | normalize-only | 282 → 274 |

#### dataflow-ilp

| 步 | 区域 ID 或流程 | 处理方式 | Kernel TTI |
|---:|---|---|---:|
| 1 | `0ee2ac3a0c79a3eb54e5a8f8cdbc70372840bb29` / b2r 根 | existing_pipeline | 289 → 282 |
| 2 | normalize-only | normalize-only | 282 → 274 |

### 最终 ISA 分支检查

全 kernel 的 LLVM IR 条件分支净减 0 条，控制报价净降 0 点。最终 HSACO 的条件分支净减 0 条，全部分支净减 0 条，exec 相关指令净减 0 条。负数表示增加。

Dataflow 求解器提交中未发现从有保护段改为无保护段的区域。

### ROCProfiler

| 变体 | VALUInsts | SALUInsts | VALUBusy % | MemUnitBusy % | MemUnitStalled % | Wavefronts | kernel µs / 完整重放 µs |
|---|---:|---:|---:|---:|---:|---:|---:|
| anchor | 168307.27 | 102673.31 | 19.332 | 0.012 | 0.015 | 384 | 2956.748 / 8764.903 |
| dataflow-ilp | 168307.27 | 102673.31 | 19.326 | 0.011 | 0.013 | 384 | 2943.928 / 8759.813 |

静态 wave 驻留上限（anchor、dataflow-ilp）为 `6 WG/CU 6 waves/CU 40 max waves/CU`、`6 WG/CU 6 waves/CU 40 max waves/CU`。当前 gfx906 计数器不提供动态 wave 占用率。VALU/SALU 指令按 profiler 的每 wave 指标报告。

## MapAiry

| 变体 | LLVM 24 TTI | 贪心提交 | CPU / GPU 验证 | GPU 中位数 (µs) | IR 条件分支 / 无条件分支 / 控制 TTI | ISA 条件分支 / 全部分支 / exec 指令 |
|---|---:|---:|---|---:|---:|---:|
| original | 6402 | 0 | 通过 | 84.719 | 70 / 44 / 666 | 99 / 101 / 263 |
| anchor | 3997 | 30 | 通过 | 31.520 | 57 / 35 / 539 | 68 / 74 / 184 |
| darm | 3999 | 27 | 通过 | 30.560 | 59 / 42 / 581 | 69 / 75 / 198 |
| dataflow-ilp | 4100 | 26 | 通过 | 31.520 | 57 / 38 / 551 | 74 / 80 / 189 |

Dataflow-ILP / anchor 的配对时间比为 **1.00000**（95% bootstrap 区间 0.99495–1.00000）。

Dataflow-ILP 结构试验处理方式计数为 `{'anchor_fallback': 58, 'existing_anchor': 59, 'existing_pipeline': 117, 'ilp_solver': 85, 'reference_solver': 43}`，提交处理方式计数为 `{'anchor_fallback': 8, 'existing_anchor': 1, 'existing_pipeline': 6, 'ilp_solver': 2, '既有流程': 9}`。候选的求解状态、区域 T 以及回填清理前后的 kernel 报价在逐项证据中。

### 贪心提交

#### anchor

| 步 | 区域 ID 或流程 | 处理方式 | Kernel TTI |
|---:|---|---|---:|
| 1 | `0293233d29ce8113b6ad8a563044789112e73391`（动态） / b2b-diamond 根 | b2b-anchor-1 | 6402 → 6150 |
| 2 | `ff1168a5e9e9bf0314f209533bddea1f7cb208a5`（动态） / b2b-diamond 根 | b2b-anchor-1 | 6150 → 5898 |
| 3 | `0c18c540bf3ba19a7b823d58942699560d9f78af`（动态） / b2b-diamond 根 | b2b-anchor-1 | 5898 → 5646 |
| 4 | `648c95be256ed1a7cfe57a604e41cc0fc29aee19`（动态） / b2b-diamond 根 | b2b-anchor-1 | 5646 → 5394 |
| 5 | `a5cfe0d60dd446e9a939783527b8f56362ac75df`（动态） / r2r 根 | darm-R2R | 5394 → 5205 |
| 6 | `5f3baf654110bfe426720105678155423ecf63e3`（动态） / r2r 根 | darm-R2R | 5205 → 5016 |
| 7 | `ff1604326a42b69463f8580361a386407935b413`（动态） / r2r 根 | darm-R2R | 5016 → 4763 |
| 8 | `9d54fbd14628e50633271d6a71f7ed6872d98c65`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4763 → 4692 |
| 9 | `22be0fbece1dd00604ae7c697dfada8d4b40a572`（动态） / b2b-diamond 根 | b2b-anchor-2 | 4692 → 4636 |
| 10 | `471b9e214c269f2523154b22e25de1a46f96f09f`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4636 → 4602 |
| 11 | normalize-only | normalize-only | 4602 → 4591 |
| 12 | normalize-only | normalize-only | 4591 → 4582 |
| 13 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4582 → 4573 |
| 14 | normalize-only | normalize-only | 4573 → 4564 |
| 15 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4564 → 4555 |
| 16 | normalize-only | normalize-only | 4555 → 4546 |
| 17 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4546 → 4537 |
| 18 | normalize-only | normalize-only | 4537 → 4528 |
| 19 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4528 → 4519 |
| 20 | normalize-only | normalize-only | 4519 → 4510 |
| 21 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4510 → 4501 |
| 22 | normalize-only | normalize-only | 4501 → 4492 |
| 23 | `9696f4c5696faba7e38032fa3a1f0779a79575d6`（动态） / b2b-diamond 根 | b2b-anchor-7 | 4492 → 4430 |
| 24 | `a89f0dc46f0172efdfa1b9614f7d0dd99dee7133` / other 根 | darm-R2R | 4430 → 4417 |
| 25 | `a89f0dc46f0172efdfa1b9614f7d0dd99dee7133` / other 根 | darm-R2R | 4417 → 4412 |
| 26 | `03d55c7d3db732b4299d4e8f4adc06b3a881e0e5`（动态） / b2b-diamond 根 | b2b-anchor-3 | 4412 → 4394 |
| 27 | `3508515f5f4dca54386a614b9815be3b9c57bab0`（动态） / r2r 根 | darm-R2R | 4394 → 4264 |
| 28 | `76ba4e0e8a89ac33cf9459815596227cb048d52d`（动态） / other 根 | b2b-anchor-1 | 4264 → 4123 |
| 29 | `872d77ef5109138d3950acc123db3f98392430a1`（动态） / b2b-diamond 根 | b2b-anchor-3 | 4123 → 4102 |
| 30 | `f94e0989bb185c57008efce5cad25215324e0a09`（动态） / b2b-diamond 根 | b2b-anchor-1 | 4102 → 3997 |

#### darm

| 步 | 区域 ID 或流程 | 处理方式 | Kernel TTI |
|---:|---|---|---:|
| 1 | `0293233d29ce8113b6ad8a563044789112e73391`（动态） / b2b-diamond 根 | darm-B2B | 6402 → 6129 |
| 2 | `ff1168a5e9e9bf0314f209533bddea1f7cb208a5`（动态） / b2b-diamond 根 | darm-B2B | 6129 → 5856 |
| 3 | `a54b179ecc9e36fe0fff9d9b40c3bc4f30d2c8d1`（动态） / b2b-diamond 根 | darm-B2B | 5856 → 5583 |
| 4 | `0c18c540bf3ba19a7b823d58942699560d9f78af`（动态） / b2b-diamond 根 | darm-B2B | 5583 → 5310 |
| 5 | `648c95be256ed1a7cfe57a604e41cc0fc29aee19`（动态） / b2b-diamond 根 | darm-B2B | 5310 → 5037 |
| 6 | `e02ca96ad8887779fbc5e68ef131733cc93cdc4d`（动态） / b2b-diamond 根 | darm-B2B | 5037 → 4764 |
| 7 | `c15b3420c0ffadfec07e0963e3eb237f24dba34b`（动态） / b2b-diamond 根 | darm-B2B | 4764 → 4491 |
| 8 | `eca051b49cfa59c7ee564c56fa9b997ac061d52e`（动态） / b2b-diamond 根 | darm-B2B | 4491 → 4306 |
| 9 | `9d54fbd14628e50633271d6a71f7ed6872d98c65`（动态） / b2b-diamond 根 | darm-B2B | 4306 → 4246 |
| 10 | `22be0fbece1dd00604ae7c697dfada8d4b40a572`（动态） / b2b-diamond 根 | darm-B2B | 4246 → 4190 |
| 11 | `e185fac0fe0eafd7a5b0fcece81ad31a953eccdf`（动态） / b2b-diamond 根 | darm-B2B | 4190 → 4150 |
| 12 | normalize-only | normalize-only | 4150 → 4139 |
| 13 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | darm-B2B | 4139 → 4130 |
| 14 | normalize-only | normalize-only | 4130 → 4121 |
| 15 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | darm-B2B | 4121 → 4112 |
| 16 | normalize-only | normalize-only | 4112 → 4103 |
| 17 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | darm-B2B | 4103 → 4094 |
| 18 | normalize-only | normalize-only | 4094 → 4085 |
| 19 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | darm-B2B | 4085 → 4076 |
| 20 | normalize-only | normalize-only | 4076 → 4067 |
| 21 | `b9d27685035d79937b18e4cbdae32f585c60eec7`（动态） / b2b-diamond 根 | darm-B2B | 4067 → 4058 |
| 22 | normalize-only | normalize-only | 4058 → 4049 |
| 23 | `9696f4c5696faba7e38032fa3a1f0779a79575d6`（动态） / b2b-diamond 根 | darm-B2B | 4049 → 4040 |
| 24 | normalize-only | normalize-only | 4040 → 4031 |
| 25 | `9696f4c5696faba7e38032fa3a1f0779a79575d6`（动态） / b2b-diamond 根 | darm-B2B | 4031 → 4009 |
| 26 | `b32b9061ae07e3a8d9513c12dc68dc505e57fdf7` / other 根 | darm-R2R | 4009 → 4004 |
| 27 | `b32b9061ae07e3a8d9513c12dc68dc505e57fdf7` / other 根 | darm-R2R | 4004 → 3999 |

#### dataflow-ilp

| 步 | 区域 ID 或流程 | 处理方式 | Kernel TTI |
|---:|---|---|---:|
| 1 | `0293233d29ce8113b6ad8a563044789112e73391`（动态） / b2b-diamond 根 | anchor_fallback | 6402 → 6150 |
| 2 | `ff1168a5e9e9bf0314f209533bddea1f7cb208a5`（动态） / b2b-diamond 根 | anchor_fallback | 6150 → 5898 |
| 3 | `0c18c540bf3ba19a7b823d58942699560d9f78af`（动态） / b2b-diamond 根 | anchor_fallback | 5898 → 5646 |
| 4 | `648c95be256ed1a7cfe57a604e41cc0fc29aee19`（动态） / b2b-diamond 根 | anchor_fallback | 5646 → 5394 |
| 5 | `a5cfe0d60dd446e9a939783527b8f56362ac75df`（动态） / r2r 根 | existing_pipeline | 5394 → 5205 |
| 6 | `5f3baf654110bfe426720105678155423ecf63e3`（动态） / r2r 根 | existing_pipeline | 5205 → 5016 |
| 7 | `ff1604326a42b69463f8580361a386407935b413`（动态） / r2r 根 | existing_pipeline | 5016 → 4763 |
| 8 | `9d54fbd14628e50633271d6a71f7ed6872d98c65`（动态） / b2b-diamond 根 | anchor_fallback | 4763 → 4692 |
| 9 | `22be0fbece1dd00604ae7c697dfada8d4b40a572`（动态） / b2b-diamond 根 | anchor_fallback | 4692 → 4636 |
| 10 | `471b9e214c269f2523154b22e25de1a46f96f09f`（动态） / b2b-diamond 根 | anchor_fallback | 4636 → 4602 |
| 11 | normalize-only | normalize-only | 4602 → 4591 |
| 12 | normalize-only | normalize-only | 4591 → 4582 |
| 13 | normalize-only | normalize-only | 4582 → 4573 |
| 14 | normalize-only | normalize-only | 4573 → 4564 |
| 15 | normalize-only | normalize-only | 4564 → 4555 |
| 16 | normalize-only | normalize-only | 4555 → 4546 |
| 17 | normalize-only | normalize-only | 4546 → 4537 |
| 18 | normalize-only | normalize-only | 4537 → 4528 |
| 19 | normalize-only | normalize-only | 4528 → 4526 |
| 20 | `a89f0dc46f0172efdfa1b9614f7d0dd99dee7133` / other 根 | existing_pipeline | 4526 → 4521 |
| 21 | `a89f0dc46f0172efdfa1b9614f7d0dd99dee7133` / other 根 | existing_pipeline | 4521 → 4516 |
| 22 | `03d55c7d3db732b4299d4e8f4adc06b3a881e0e5`（动态） | ilp_solver（可行解） | 4516 → 4497 |
| 23 | `3508515f5f4dca54386a614b9815be3b9c57bab0`（动态） / r2r 根 | existing_pipeline | 4497 → 4367 |
| 24 | `76ba4e0e8a89ac33cf9459815596227cb048d52d`（动态） / other 根 | existing_anchor | 4367 → 4226 |
| 25 | `872d77ef5109138d3950acc123db3f98392430a1`（动态） | ilp_solver（可行解） | 4226 → 4205 |
| 26 | `f94e0989bb185c57008efce5cad25215324e0a09`（动态） / b2b-diamond 根 | anchor_fallback | 4205 → 4100 |

### 最终 ISA 分支检查

全 kernel 的 LLVM IR 条件分支净减 0 条，控制报价净降 -12 点。最终 HSACO 的条件分支净减 -6 条，全部分支净减 -6 条，exec 相关指令净减 -5 条。负数表示增加。

有 2 个 anchor 分支谓词在最终 dataflow-ilp IR 中未找到相同分支谓词。证据记录其位置，计数包含可能被改写的谓词。
求解器提交中有 2 个区域由有保护段变成无保护段。下列每项另行核对最终 anchor 版本。
- `03d55c7d3db732b4299d4e8f4adc06b3a881e0e5`。本步父 IR 到求解方案的控制 TTI 为 15 → 0。anchor 最终 IR 已对同一谓词用 select。anchor 块 `%decision.dispatch5`，dataflow-ilp 块 `%decision.dispatch5`。条件分支 / exec / cndmask 为 0/0/54 → 0/0/56，控制 TTI 为 0 → 0。逐条 ISA 和地址见证据。
- `872d77ef5109138d3950acc123db3f98392430a1`。本步父 IR 到求解方案的控制 TTI 为 15 → 0。anchor 最终 IR 已对同一谓词用 select。anchor 块 `%decision.dispatch1, %fusion.side, %merged.branch.split83`，dataflow-ilp 块 `%decision.dispatch1, %fusion.side, %merged.branch.split83`。条件分支 / exec / cndmask 为 1/5/123 → 1/5/123，控制 TTI 为 0 → 0。逐条 ISA 和地址见证据。

### ROCProfiler

| 变体 | VALUInsts | SALUInsts | VALUBusy % | MemUnitBusy % | MemUnitStalled % | Wavefronts | kernel µs / 完整重放 µs |
|---|---:|---:|---:|---:|---:|---:|---:|
| anchor | 802.60 | 110.66 | 46.325 | 3.757 | 0.234 | 1028 | 27.840 / 27.840 |
| dataflow-ilp | 803.60 | 110.66 | 45.420 | 4.129 | 0.229 | 1028 | 27.840 / 27.840 |

静态 wave 驻留上限（anchor、dataflow-ilp）为 `3 WG/CU 12 waves/CU 40 max waves/CU`、`3 WG/CU 12 waves/CU 40 max waves/CU`。当前 gfx906 计数器不提供动态 wave 占用率。VALU/SALU 指令按 profiler 的每 wave 指标报告。

[逐区域求解证据](step6-solver.json.gz) · [逐候选和设备证据](step6-evidence.json.gz)

## 分支的 TTI 收益是否落到 ISA 和运行时间

- **NQU64。** Original 到 anchor 的控制报价下降 22 点，最终 ISA 少 2 条条件分支和 9 条显式 exec 指令。Dataflow-ILP 和 anchor 生成同一个 HSACO，进一步减少的分支和 exec 指令均为 0。配对计时比为 1.00028，95% 区间包含 1。
- **MapAiry。** 两次被接受的 ILP 改写分别基于当前父 IR 消除一个菱形，每处控制报价 15 → 0。最终 anchor 对两个谓词均已使用 select。因此这两处相对 anchor 的 TTI 控制差、目标条件分支差和 exec 差均为 0。第一处的基本块从 188 条指令增至 189 条，`v_cndmask` 从 54 条增至 56 条。两版均可在 `0x18f8`–`0x1900` 看到构造 0.25 并执行 `v_cmp_nle_f64_e32`，随后用 `v_cndmask` 选择值。第二处关联块两版均为 369 条指令。其 `0x2aa4` 的 `s_and_saveexec_b64` 和 `0x2aa8` 的 `s_cbranch_execz` 在两版相同，属于仍留在 `%decision.dispatch1` 的邻接分支。两处完整的地址与指令序列均在压缩证据里。
- **MapAiry 的另一次分支变化来自第 19 步 normalize-only。** Anchor 的 `%merged.bb5` 和 `%if.then12.i.i.i32.i.i.i.i` 各有一个 IR 条件分支。Dataflow-ILP 路径先把两个测试合为 `and i1`，最终两个分支变为一个，条件分支报价 14 → 7。最终序列的原位置中，anchor 在 `0x3d44` 保存 exec，在 `0x3d4c` 发射 `s_cbranch_execz`，又在 `0x3d50` 保存 exec。另一版在 `0x3d40`–`0x3d48` 使用 `s_or_b64`、`s_and_saveexec_b64` 和 `s_xor_b64`。这两个块合计少 1 条实际分支和 1 条显式 exec 指令。这个局部变化计入整核净值，来源为既有规范化流程。
- **MapAiry 整核。** Dataflow-ILP 相对 anchor 的 LLVM IR 条件分支数相同，额外的 3 条无条件分支使控制报价高 12 点。最终 ISA 多 6 条条件分支和 5 条显式 exec 指令。GPU 中位数均为 31.520 µs，配对比中位数为 1.00000。两例均未观察到 dataflow-ilp 相对 anchor 的分支减少带来可辨别的运行时间收益。两处 ILP 局部的 30 点控制收益以各自父 IR 为基线。
