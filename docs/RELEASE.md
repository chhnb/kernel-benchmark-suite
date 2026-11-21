# Anchor 发布

Auto Greedy 默认 B2B 为冻结的 anchor V2+P。DP1 已删除，`darm` 仍可显式选用。
`darm-artifact` 是论文中“原版 DARM”的对照基线，仅在显式选择时运行。
`pre-dp1-removal` 固定在 `97227b3`，可构建完整 DP1 和原版 DARM 对照，也可用
`git checkout pre-dp1-removal -- <path>` 恢复相应源码。发布 tag 为 `anchor-release-20261120`。

## 三层验收

1. **正确性，必须通过。** 完整校验所有可运行的冻结 GPU 输出及 guard。核对 LLVM verifier、已知测试状态和从源码重建的最终 IR／代码对象。SasPoint5 和 SRAD stage2 1024 的输出校验通过，性能计时见排除表。
2. **相对上一版 DP1，必须通过或有记录的例外。** 使用存档的 DP1（A，`4a91a50`）与冻结 anchor 性能数据。Landau coherent 是唯一例外。GPU case 有逐字节相同的最终 HSACO 时可登记为字节别名。
3. **相对不融合，仅报告。** 下表的 baseline 是同输入的未融合版本。比值小于 1 表示 anchor 更快。计时不稳定的用例在排除表中保留正确性结果。

GPU 使用已固定的规则。每批计划 12 轮，轮内交错 baseline、A、N。所有完整轮次的 N/A 都 ≤1.02 时通过，都 >1.02 时不通过。混合结果使用 10,000 次配对中位数 bootstrap。95% 区间上限 ≤1.02 为通过，下限 >1.02 为不通过，其余为不确定。角色相对 baseline 与 N/A 的跨度都记录，判定明确时跨度不改变结论。输出校验失败立即停止。选择计时方式时，同二进制 A/A 的中位数须在 1±1% 内、跨度 ≤3%，按已冻结的方式选择顺序执行。独立进程入口见 [GPU 判定脚本](../regression/measure_anchor_gpu.py)，逐轮中位数和归档来源见 [GPU 样本](../regression/golden/20261120-anchor-release/gpu-paired.json)。

## 结果

DARM 合并默认对共享指令的 IR 标志和 metadata 取交集。16 个发布用例的 HSACO／CUDA cubin 与旧版逐字节一致。HLLD 的最终 IR 少一条内部逻辑臂附件。 [修复记录](../regression/records/darm-merge-flags-20261121.md)

16 个 IR case（九个设计 case 和七个可运行留出 case）的完整 Greedy 均获 LLVM verifier 通过。与 `97227b3` 对应策略相比，默认 anchor 和显式 `darm` 各 16/16 的最终 IR、HSACO 或 CUDA cubin 逐字节一致。测试 26 项通过，四个已知缺件测试按 KNOWN_FAILURES 跳过，专用 recipe 测试随 DP1 删除。

### 最终复验（2026-11-21）

合入清理后的发布代码为 `e3bb5fd`。16 例均通过 LLVM verifier，最终 IR 和 HSACO／cubin 与清理前 `b54c3c0` 基准逐字节一致。16 项测试通过，4 项按 `KNOWN_FAILURES` 跳过。21 个输入完成 A/A 输出校验，其中 8 个通过计时门槛并完成三角色对照。13 个输入两次 A/A 超限，表中保留其两次中位数／跨度。比值小于 1 表示发布版本更快。 [完整复验、历史参考与逐例核对](../regression/records/final-rerun-20261121.md)

| 场景 | 发布／baseline [95% 区间] | 发布／Auto DARM [95% 区间] | 状态 |
| --- | --- | --- | --- |
| vLLM 64K | 0.72786 [0.72573, 0.73099] | 0.82609 [0.82479, 0.82707] | 12 轮完整输出通过，Auto DARM 使用 no-region-replication |
| vLLM 128K | 0.73688 [0.72894, 0.74079] | 0.83199 [0.82665, 0.83790] | 12 轮完整输出通过，Auto DARM 使用 no-region-replication |
| MapAiry | 0.38290 [0.38255, 0.38290] | 0.69595 [0.69595, 0.69595] | 12 轮完整输出通过 |
| TIGRE | 0.51339 [0.51083, 0.51923] | 0.74469 [0.74339, 0.74499] | 12 轮完整输出通过 |
| HLLD | — | — | 无法可靠计时，A/A 0.99372／19.45%、0.99495／19.02% |
| Landau/mixed | — | — | 无法可靠计时，A/A 0.99907／14.56%、0.99629／13.98% |
| Landau/coherent | — | — | 无法可靠计时，A/A 0.98982／30.04%、1.01025／36.33% |
| SW2D | — | — | 无法可靠计时，A/A 0.99755／12.09%、1.00617／12.13% |
| CED | — | — | 无法可靠计时，A/A 1.00118／22.39%、0.98155／32.93% |
| TPACF | — | — | 无法可靠计时，A/A 0.99856／13.88%、1.00025／14.68% |
| SRAD stage2 256 | — | — | 无法可靠计时，A/A 1.00855／51.66%、0.98728／45.43% |
| SRAD stage2 1024 | — | — | 无法可靠计时，A/A 1.00711／46.56%、1.00310／21.57% |
| SasPoint5/interval-mixture | 0.47298 [0.47287, 0.47847] | 0.47656 [0.47287, 0.47835] | 12 轮完整输出通过 |
| SasPoint5/coherent-blocks | — | — | 无法可靠计时，A/A 1.00000／655.34%、1.00000／49.66% |
| SasPoint5/uniform-01 | — | — | 无法可靠计时，A/A 1.00795／5.29%、1.00000／7.00% |
| HiPIMS-George | — | — | 无法可靠计时，A/A 1.00066／8.40%、1.00075／15.86% |
| SRAD16/256 | — | — | 无法可靠计时，A/A 1.00357／49.39%、1.00004／56.69% |
| SRAD32/256 | — | — | 无法可靠计时，A/A 0.99998／58.18%、0.99303／47.68% |
| MS32 | 0.91715 [0.91164, 0.92200] | 1.02017 [1.01041, 1.02690] | 12 轮完整输出通过 |
| PCM32 | 0.80848 [0.80836, 0.80857] | 1.07327 [1.07319, 1.07332] | 12 轮完整输出通过 |
| NQU64 | 0.96571 [0.95534, 0.97253] | 1.12407 [1.11958, 1.12622] | 12 轮完整输出通过 |

NQU64 在唯一一次重试中通过。RTX 3090 上，SasPoint5 和 HiPIMS-George 的发布 cubin 均与冻结档逐字节一致。vLLM 的 Auto DARM 使用无区域复制版本，原版命令在 360 秒内未产出完整 IR。

### 2026-11-20 冻结发布参考

| GPU case | 完整输出 | anchor/DP1 | 95% 区间 | 第二层结果 | anchor/baseline |
| --- | --- | ---: | --- | --- | ---: |
| vLLM 64K | 通过 | 1.00000 | — | 字节别名，通过 | 0.74020 |
| vLLM 128K | 通过 | 1.00000 | — | 字节别名，通过 | 0.73461 |
| TIGRE | 通过 | 1.00000 | — | 字节别名，通过 | 0.52471 |
| Map-Airy | 通过 | 0.84810 | [0.84526, 0.84810] | 通过 | 0.37605 |
| HLLD | 通过 | 1.00821 | [1.00235, 1.00940] | 通过 | 1.09276 |
| NQU64 | 通过 | 1.00000 | — | 字节别名，通过 | 0.97148 |
| MS32 | 通过 | 0.99993 | [0.99980, 0.99998] | 通过 | 0.91744 |
| PCM32 | 通过 | 1.00000 | — | 字节别名，通过 | 0.80832 |
| Landau mixed | 通过 | 0.92322 | [0.91938, 0.92526] | 通过 | 0.43045 |
| Landau coherent | 通过 | 1.04426 | [1.03652, 1.08132] | 超过 1.02，记录例外 | 1.05970 |
| SW2D | 通过 | 1.00744 | [1.00619, 1.00808] | 通过 | 1.00000 |
| CED | 通过 | 0.98490 | [0.97836, 0.99901] | 通过 | 0.88775 |
| TPACF | 通过 | 0.94792 | [0.94701, 0.94908] | 通过 | 1.19971 |
| SRAD stage2 256 | 通过 | 0.99528 | [0.98122, 1.00943] | 通过 | 1.00435 |
| HiPIMS-George | 通过 | 1.00002 | [1.00000, 1.00072] | 通过 | 1.00000 |
| SRAD32 stage1 | 兼容构建通过，冻结件仅核对字节 | — | — | 仅在报告层 | — |

TIGRE 的相对 baseline 比值来自与当前 N 字节相同的存档 A 及同轮 baseline。NQU64 同样是 A 的字节别名，新补的 12 轮只用于相对 baseline 报告，15 皇后的解数为 2,279,184，存档含全部 GPU 分块输出。PCM32 的比例来自采用分块 pinned-host 回读的存档 12 轮，本轮独立核对了新版本的完整输出。HLLD 使用旧同批 N/A 判定。进程内逐状态复测相对不融合为 1.152，记录在区域审计中。Landau coherent 的逐状态批次相对不融合为 1.021–1.027。
SRAD32 stage1 的冻结件启动限制和诊断结果见[已知问题](KNOWN_ISSUES.md#anchor-默认版本的性能与测量状态)。

## 性能排除

| 场景 | 排除原因 | 进程内 A/A 中位数／跨度 | 独立进程 A/A 中位数／跨度 |
| --- | --- | --- | --- |
| SasPoint5 interval-mixture | 该 case 的三个输入须共用一种全部通过 A/A 的方式 | 1.00000／2.80% | 0.99251／15.92% |
| SasPoint5 coherent-blocks | 轮间波动 | 1.00000／4.40% | 0.98077／4.82% |
| SasPoint5 uniform-01 | 轮间波动 | 1.00000／5.48% | 1.00000／4.99% |
| SRAD stage2 1024 | 两种方式均不通过 A/A | 0.99282／11.32% | 0.92221／179.14% |
| SRAD16 stage1 | 计时不稳定（报告批次跨度 54.84%），只报告正确性 | — | — |
| CUDAflow | 无法报价设备调用及 inline asm | — | — |
| HiPIMS-HLLC | 未报价的 opaque `__internal_accurate_pow` 调用 | — | — |
| Reentry | 归档 IR 使用 LLVM12 不接受的 opaque pointer，LLVM12 设备构建也未通过 | — | — |

SasPoint5、SRAD stage2 1024 和 SRAD16 stage1 均通过完整输出校验，只报告正确性。CUDAflow、HiPIMS-HLLC、Reentry 没有可纳入本清单的 Greedy 产物。

## 冻结材料与重建

[冻结 manifest](../regression/golden/20261120-anchor-release/manifest.json) 包含 16 个 IR 用例的输入、anchor／DP1／DARM 参考及 SHA-256。随清单提交的压缩归档含这些 IR 和机器码。GPU 部分固定输入和参考输出的版本、路径和 SHA-256。大体积 GPU 数据保留在 manifest 指向的 EPYC 归档上。SRAD16／32 报告使用新增 256×256 的固定输入和五输出 CPU 参考，种子为 20261120。原 vLLM 和 TIGRE 冻结版本继续保留，[Map-Airy 的 anchor 参考](../regression/golden/20261120-mapairy-anchor-gfx906-v1/manifest.json)继续使用。

在 EPYC 上从干净源码运行下列命令。外部工具及路径由 manifest 固定。发布重建用 `anchor-release-20261120`。历史对照用 `pre-dp1-removal`。

```sh
source_ref=anchor-release-20261120
release_repo="$PWD"
mkdir -p /path/to/clean-anchor-source
git archive "$source_ref" | tar -xf - -C /path/to/clean-anchor-source
cd /path/to/clean-anchor-source
# 设置 manifest 所列 LLVM_CONFIG、LLVM24_CONFIG、LLVM24_LIBDIR，
# 将 LLVM12 的共享库目录加入 LD_LIBRARY_PATH。
tools/build-v1
tools/build-decision-model
tests/run-v1
python3 "$release_repo/regression/verify_anchor_release.py" \
  --tool-root "$PWD" --out /path/to/anchor-rebuild-receipt
```

重建脚本在比较前校验归档哈希和各个对象哈希，再运行 LLVM verifier 并比较完整字节。LLVM IR 包含输入路径或选中 trial 的绝对 ModuleID。使用 manifest 固定的路径可以逐字节比较，迁移到其他主机时可把同样的路径绑定到工作目录。脚本会拒绝覆盖现有输入或 Greedy 输出目录。

## 记录索引

- [历史布局审计](../regression/records/b2b-layout-usage-20261119.md)
- [unified 实验及结论](../regression/records/b2b-unified-dp-20261119.md)
- [DARM 与 DP1 对照](../regression/records/b2b-darm-vs-dp1-20261119.md)
- [DARM select 代价实验](../regression/records/darm-select-cost-20261119.md)
- [anchor 初版和离线回放](../regression/records/b2b-anchor-20261119.md)
- [GPU 固定规则](../regression/records/b2b-anchor-v3-20261119.md)
- [V2+P 配置消融](../regression/records/b2b-anchor-ablation-20261120.md)
- [留出数据与冻结核对](../regression/records/b2b-anchor-heldout-20261120.md)
- [相对 baseline 的逐提交审计](../regression/records/region-fusion-audit-20261120.md)
- [当前已知问题](KNOWN_ISSUES.md)和[已知测试结果](../tests/KNOWN_FAILURES.md)
- [删除 DP1 后的重建核验](../regression/records/anchor-release-rebuild-20261120.md)
