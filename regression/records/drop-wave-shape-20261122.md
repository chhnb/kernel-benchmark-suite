# 第 13b 步：移除 Anchor workgroup 形状机制

起点 `7c76c56ef4e4e01b3bc7a3b7f8171e0f4f1a2d75`（13a 的普通合并提交）。分支 `refactor/drop-wave-shape`。对照为第 12 步无形状配置 B 和 13a 发布用法的独立干净构建。

## 改动

- `tools/anchor_wave_diagnostic.h` 移除。逐 wave 求值、形状解析、IR 的 `reqd_work_group_size` 读取和 wave 结果报告一并删除。条件的来源分析及分支查询保留于 `tools/anchor_condition.h`。
- `tools/anchor_uniform_gate.h` 的 `anchorUniformRejection` 根据来源分类决定。线程号条件使用普通吞吐 TTI，工作组一致条件禁用线性、守护和 R2R 推测，数据相关条件要求双侧一致收益有报价且都非负。B2B 布局与 R2R 推测继续复用此判断。候选 JSON 直接记录 `condition_source`。
- `decision_greedy_main.cpp`、`fusion_search_llvm24_main.cpp` 和 `compile_kernel.py` 删除形状选项、转发与相关警告。发布复验改用同一默认入口，撤掉 LUD8 形状开关专项重放。
- 来源分类、B2B 候选内部 gate、R2R gate 和 HLLD 确定性测试仍执行。原逐 wave 分类和形状精确化用例已删除。DP 观测测试仍核对布局回执。
- 发布清单和各 `case.json` 移除搜索形状字段。默认配置只更新 SRAD16、SRAD32、CED；CED 只更新 IR 哈希。历史归档、冻结输入、参考输出、旧 D 和 Auto DARM 的数据继续沿用。

| 范围 | 新增 | 删除 | 净变动 |
| --- | ---: | ---: | ---: |
| 工具（C++ 与命令行） | 115 | 338 | -223 |
| 回归测试 | 93 | 143 | -50 |
| 发布复验脚本 | 2 | 53 | -51 |
| manifest 与 case 元数据 | 16 | 451 | -435 |
| 文档 | 15 | 11 | +4 |
| 合计（统计不含本记录） | 241 | 996 | -755 |

## 构建和验证

EPYC 独立构建目录 `/data/home/chh/simplify-v2/build/drop-wave-shape.3t7Qah`。工具链来自 `/data/home/chh/v2-runtime/reproduce.json` 的冻结环境。实际执行的构建和回归入口如下。

```sh
tools/build-llvm24-tti --worker-only
tools/build-llvm24-tti --search-only
tools/build-decision-greedy
tools/build-decision-model
python3 regression/verify_anchor_release.py --tool-root . --out "/data/home/chh/simplify-v2/build/drop-wave-shape.3t7Qah/verified" --jobs 12
python3 ../check-regression.py drop-wave-shape
python3 ../step13b-parity.py "/data/home/chh/simplify-v2/build/drop-wave-shape.3t7Qah" "/data/home/chh/simplify-v2/build/cleanup-13a-release.ZSjzHj" "/data/home/chh/simplify-v2/build/thread-pattern.vLL3Qo"
```

`check-regression.py` 执行 `tests/run-v1`、decision model、单分支 B2B、区域控制流、队列、评分、报价缓存和 domain 组。结果为 **16 组通过，0 跳过**。测试外层入口首次启动时缺少临时输出的父目录，补建目录后完整运行。用于发布复验的二进制：

| 文件 | SHA-256 |
| --- | --- |
| `build/decision-fuse/decision-greedy` | `02ea92f65413967f28910ad05e4f76a0d619d1e5feb87f477f9ed73e8ef9244e` |
| `build/llvm24-tti/fusion-search-llvm24` | `2f26f6539bd60138ddd8a96825ad4f2566610f86b02b6385e4fa8220b885a712` |
| `build/llvm24-tti/llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |

17 个 case 在默认配置下完成 Greedy。每个 case 的选中提交顺序、候选和报价、所选提交的 IR、最终 IR 与第 12 步 B 对比，全部一致，共 360 次提交。标准脚本重建设备对象 16 份，LUD8 用冻结 ROCm 4.2 构建流程另行重建，17 个对象均与 B 原始字节相同。唯一发布报警为 CED 281 > 旧 D 的 280。

| Case | 提交数 | TTI | 最终 IR SHA-256 | 设备对象 SHA-256 |
| --- | ---: | ---: | --- | --- |
| vllm | 225 | 2619 | `186bc0f6e7fb590b52b30907d35809155695c40a6ee6b1ca7178a8b8fc4eb379` | `9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6` |
| MapAiry | 30 | 3997 | `109dae2f8e462357add07adbc0dcd17dae365372fdca464a9abe9469f40c90d1` | `030b9488c8bb5b7cf98479f218adaa85aeaec30e404f7efd4fc2ba4ad0167afc` |
| tigre | 5 | 942 | `5605316b9f7b3403cfdd81fcb96017f63592c94dad1c3ad888b3972c9adbc809` | `ffa327ddc018b3b910d11d56c9d9cca022509c39d5e099363465a44a574bc721` |
| HLLD | 5 | 1696 | `0ef79f2ea967b3a7b7ebab420c2667a64cb9099572d1fd97bd110a1cb0ed05de` | `3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3` |
| NQU64 | 2 | 274 | `383e6dfc7e111895537ba15f78c40824d8cac68a1b0843b08a5f6279c34331c4` | `83bec1d3bb5b164770921cd52763d70670efa5ea12ab5f04082391abbf74e97b` |
| MS32 | 2 | 198 | `f95ad2fe62d67c4a44eec0fc5a2c6ef387c9bed934f1410918cbcc27af599714` | `1be889a67dbd43dd8d63e0b6d5cee7fe26584fa22bb23da67878cd30b6722054` |
| PCM32 | 18 | 1136 | `debd9769998968174b631e18fd675916172800fd3eeeb179f026e725cf3b5fb0` | `5ba36c22102cb607d1db54684102c836b639e0acbd7ee03b76a109d5447c5816` |
| SRAD16 | 4 | 436 | `682d788ebaa36b26909d11560478599bfb22e3f9f59ae7181be2cbf84bd4d0f5` | `89191ed8c58d26ef8af05dee8c5ca06a1a17c026204fec6ffdecc9e0d948d2db` |
| SRAD32 | 4 | 436 | `1b8b91a062304dfbf3bccc8974feb7655387f9774275c1522c8270eb9460c008` | `be6cdbe3591098a69885adfabfa421f6a79c94cae37cece59f0f89648a74271a` |
| Landau | 22 | 1635 | `31aea7ae5a00106b1e4684c7f87cf6fa895cff29010f450c740f92396eb1943f` | `a74f636a78aa5c595ba9ea2675494d942064fe7f5cd499d7a7323c501cb1019f` |
| SW2D | 1 | 1925 | `2c231580ab79542a9998f2fd1ef0cdf765e05f46794ca5fd4af6cddfb159d6b1` | `cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518` |
| CED | 3 | 281 | `1798b84d27abb2b8d6f74d97249337ea562c97cf66e644ace637af319d7af3d4` | `c9f5da8a8caab4cc492af650f8663fae867cb65356aaa16a8c49ce48223dae38` |
| TPACF | 23 | 325 | `bc5b0ff9d9a58929c405bb97dd7af9e8c19b5239f2a2052282990be50633c781` | `3853cc72321f0c31102fbfe7b9b80a3258275103448e1437e0db0837dce6d65f` |
| SRAD-stage2 | 2 | 209 | `b1343cc5c72cc19d5a352cfa8080208fb503de8160190f1a0f638bc4cff42ad8` | `37ed260bde0e42fc816853f9ea712685dbda735b563bbddd3a5026044c7befc5` |
| SasPoint5 | 7 | 491 | `eefddfe2b88b52b4e348b8ac7ad6a324f0c7c881521d3a4f3c7696de9d616385` | `9b8f297905aca8ac726d64707a8432c07a90565b1828401251dbef473f230b2d` |
| HiPIMS-George | 5 | 5572 | `f22721c031b2847ee682e82637ff02cced9fc7e1b5ff99396fa5c68f56c74432` | `5775bc0c9c040ba7b55d84bd29d0719342a2f38043dff855fea723a9c5510b3b` |
| LUD8 | 2 | 628 | `387a564d46e1226112d51f2d9e7640dc1016dd72b2e41533a2a488aa330af915` | `15266ece5e8344423077a145cbf41eb24635ee6591884241f1e26e339d77edd8` |

## 与 13a 发布产物的差异

| Case | 提交数 | 最终 TTI | 变化 | 历史 GPU 时比（新／旧） |
| --- | --- | --- | --- | --- |
| SRAD16 | 3 → 4 | 445 → 436 | 第 4 次提交 `trial-12`（`B22:B23:B24`）选择 `b2b-anchor-5`。IR、HSACO 改变。 | 1.0074 [1.0000, 1.0078] |
| SRAD32 | 3 → 4 | 445 → 436 | 同上。保持既有 1024 线程上限的诊断构建口径。 | 1.00312 [1.00072, 1.00539] |
| CED | 3 → 3 | 281 → 281 | 第 1 次提交 `trial-1`（`B5:R3:R5`）选择 R2R 推测，同父报价 349 → 307，原先普通 R2R 为 309。IR 改变，HSACO 原始字节相同。 | 同一设备对象 |
| 其余 14 个 case | 一致 | 一致 | 完整提交链、最终 IR、设备对象一致。 | 同一设备对象 |

SRAD16/32 的 `tid.y == 0` 仅首个 wave 混合，两侧一致收益为 −1 / −14。当前按线程号条件的普通 TTI 收益接受线性布局。GPU 沿用第 12 步的冻结输入和实测结果，SRAD32 采用该步合并前 HIP Graph 补测。本步未重测。 [第 12 步记录](thread-pattern-optimism-20261122.md)
