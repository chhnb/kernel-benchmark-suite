# 已知测试失败

基线为 `4a91a502928ca4fae06bef7651aaebee34ff3058`。在 EPYC 使用项目固定的
LLVM12 和 LLVM24 实时吞吐报价确认，原始记录保存在
`build/simplify-fingerprint/tests-baseline-v2/`。同一组测试在 V2 清理分支上复跑为 25 项通过、6 项失败。

| 测试 | 分类 | 基线失败 | 确认时间（UTC+08:00） | 当前状态 |
| --- | --- | --- | --- | --- |
| `single-b2b` | `stale-assertion` | `check-single-branch-b2b.py` 第 192 行期望 `pipeline_version == "v1"`，默认有序调度报告 `v2` | 2026-11-19 17:00:18 | 已修复，验证 V2 ordered |
| `suite` | `stale-assertion` | `tests/run-v1` 调用同一个 B2B 测试，止于相同断言 | 2026-11-19 17:00:17 | 已修复，执行更新后的 B2B 检查 |
| `condition` | `missing-artifact` | `FileNotFoundError`，缺少 `build/decision-fuse/condition-check` | 2026-11-19 17:00:11 | 缺件时明确跳过（77） |
| `regions` | `missing-artifact` | `FileNotFoundError`，缺少 `/home/chh/darm-artifacts-repro/build/bin/opt` | 2026-11-19 17:00:11 | 缺件时明确跳过（77） |
| `similarity` | `missing-artifact` | `FileNotFoundError`，缺少同一个历史 `opt` | 2026-11-19 17:00:11 | 缺件时明确跳过（77） |
| `pair-trial` | `missing-artifact` | 首个错误为 `FileExistsError`，脚本试图在已跟踪的 `tests/pair-trial/runs-v1` 创建新目录。另缺少旧 `clang`、`pair-trial` 和 `region-inventory` 可执行文件。 | 2026-11-19 17:00:11 | 缺件时明确跳过（77） |

比较后续运行时，核对测试集合、状态和失败原因。删除测试或修复已知失败时，提交说明和本表同步记录。

测试维护提交更新 V2 ordered 断言。旧分支 `4a91a50` 的 `guarded` 专用测试依赖当时的离线报价。DP2／DP3 和其他已移除选项的拒绝检查保留。
四个缺件测试列出缺失路径和恢复方式。Pair trial 使用新临时目录，保留已跟踪的历史证据目录。

## 历史入口清理

- 移除 `tests/fusion-search/compare-scoped-driver.py`。原用于比较 scoped-full 和 scoped-reuse 的提交链及复用情况。该脚本未列入当前 27 项通过、4 项缺件跳过的测试集合。
- 移除 `tests/fusion-search/check-preparation-reactivation.py`。原用于验证 trees 调度下准备臂的再激活。该脚本未列入当前 27 项通过、4 项缺件跳过的测试集合。

- 移除仅适用于 DP1 的 recipe 测试。共享发射、TTI 报价、连续 worker、逐提交重新评分和局部／区域回退测试改用 anchor。缺件跳过清单保持不变。

- 移除 `check-offline-tti.py`，其覆盖的 SQLite 记录、重放及实验报价档已删除。四个缺件跳过保持不变。

- 移除依赖 SQLite 离线报价的 `check-guarded-b2r.py` 和 `guarded-load.ll`。默认 DARM 的测试保持运行。

- 移除隔离 B2B 原型专用测试 `check-hybrid-priority.py`、`check-region-fallback.py`、`check-incremental-ir.py`，以及它们的四个元数据/活跃性单元测试、probe 和 fixtures。当前 whole-function Greedy 继续由完整发布 case 与 domain driver 测试验证。
