# DP1 删除后的重建核验

2026-11-20，EPYC。恢复 tag 为 pre-dp1-removal（97227b3）。两套干净目录分别用该 tag
和删除提交 8d380af 的 git archive 新建，分别执行 tools/build-v1 和 tools/build-decision-model，
构建 LLVM24 TTI worker、离线 layout 工具、显式融合器、decision-greedy 和决策工具。
使用固定 LLVM12、LLVM24、ROCm gfx906 与 CUDA 11 ptxas 重新编译最终产物。

## 默认行为与显式 DARM

对照为 97227b3 的完整 Greedy。下表的“相同”同时表示最终 IR 和 HSACO／cubin 完整字节一致。
LLVM verifier 逐例通过。clean candidate 的默认产物先与删除前归档逐字节核对，随后用发布脚本
直接读取并校验冻结归档，再重跑并用字节比较核对所有用例。DARM 的对照不使用 DP1 的产物。

| case | 删除前 tag 干净重建 anchor | 删除后干净重建 anchor | 删除后干净重建显式 DARM | 默认提交数／TTI |
| --- | --- | --- | --- | ---: |
| vllm | 相同 | 相同 | 相同 | 224／2619 |
| MapAiry | 相同 | 相同 | 相同 | 29／4099 |
| tigre | 相同 | 相同 | 相同 | 6／946 |
| HLLD | 相同 | 相同 | 相同 | 5／1696 |
| NQU64 | 相同 | 相同 | 相同 | 1／282 |
| MS32 | 相同 | 相同 | 相同 | 1／212 |
| PCM32 | 相同 | 相同 | 相同 | 17／1138 |
| SRAD16 | 相同 | 相同 | 相同 | 4／452 |
| SRAD32 | 相同 | 相同 | 相同 | 4／452 |
| Landau | 相同 | 相同 | 相同 | 20／1708 |
| SW2D | 相同 | 相同 | 相同 | 0／1926 |
| CED | 相同 | 相同 | 相同 | 5／280 |
| TPACF | 相同 | 相同 | 相同 | 12／483 |
| SRAD-stage2 | 相同 | 相同 | 相同 | 2／210 |
| SasPoint5 | 相同 | 相同 | 相同 | 8／491 |
| HiPIMS-George | 相同 | 相同 | 相同 | 4／5572 |

冻结的 DP1 reference 保留在归档。darm-artifact 引擎、来源记录和补丁未变。用独立两套工具运行
显式 darm-artifact 的无 PHI 菱形，输出逐字节一致。

## 正确性与性能证据

测试 26 项通过，condition、pair-trial、regions、similarity 四项按 KNOWN_FAILURES 返回 77。
少一项来自删除 DP1 专用的 recipe 测试。干净候选构建的 tests/run-v1 完整通过。
发布 GPU 表的 15 个场景中 14 个通过，Landau coherent 为有记录的唯一 DP1 性能例外。

独立输出校验覆盖所有可运行的冻结场景，含因 A/A 不稳定排除计时的 SasPoint5 与 SRAD stage2 1024。
PCM32 独立拿到 baseline、A、N 各两次完整回读后结束附加重复测量。性能采用归档的完整 12 轮。
NQU64 追加 12 轮 GPU kernel 事件计时和一次全字节的分块输出比较。SRAD16 stage1 五路完整输出通过。
SRAD32 冻结件需要 1,024 线程，代码对象上限为 256。原版 baseline 即启动失败，未记录性能。
仅提高工作组上限的独立诊断构建通过 baseline 和 anchor 的五路输出核对。冻结产物未采用该修改。

## 行数与归档

以 tools/fusion_search.cpp 中 using B2BMatch 到 makeRound 前一行为同一计数口径。
4a91a50 为 1,136 行，删除前为 1,246 行，删除后为 603 行。删除提交共移除 1,077 行、加入 302 行，净减 775 行。
共享权重仍供条件规范化、区域边界和 anchor 缺报价回退使用。

构建日志、字节核对、校验 CSV 和样本在 EPYC 的 /data/home/chh/simplify-v2/build/dp1-removal/。
可从 Git 读取[冻结 manifest](../golden/20261120-anchor-release/manifest.json)及随附参考归档。
性能结果见[发布清单](../../docs/RELEASE.md)。只有恢复 tag 已创建，发布 tag 待确认。
