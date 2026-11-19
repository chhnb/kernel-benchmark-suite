# 已知测试失败

基线为 `4a91a502928ca4fae06bef7651aaebee34ff3058`。在 EPYC 使用项目固定的
LLVM12 和 LLVM24 实时吞吐报价确认，原始记录保存在
`build/simplify-fingerprint/tests-baseline-v2/`。同一组测试在 V2 清理分支上复跑为 25 项通过、6 项失败。

| 测试 | 分类 | 基线失败 | 确认时间（UTC+08:00） | 当前状态 |
| --- | --- | --- | --- | --- |
| `single-b2b` | `stale-assertion` | `check-single-branch-b2b.py` 第 192 行期望 `pipeline_version == "v1"`，默认有序调度报告 `v2` | 2026-11-19 17:00:18 | 失败 |
| `suite` | `stale-assertion` | `tests/run-v1` 调用同一个 B2B 测试，止于相同断言 | 2026-11-19 17:00:17 | 失败 |
| `condition` | `missing-artifact` | `FileNotFoundError`，缺少 `build/decision-fuse/condition-check` | 2026-11-19 17:00:11 | 失败 |
| `regions` | `missing-artifact` | `FileNotFoundError`，缺少 `/home/chh/darm-artifacts-repro/build/bin/opt` | 2026-11-19 17:00:11 | 失败 |
| `similarity` | `missing-artifact` | `FileNotFoundError`，缺少同一个历史 `opt` | 2026-11-19 17:00:11 | 失败 |
| `pair-trial` | `missing-artifact` | 首个错误为 `FileExistsError`，脚本试图在已跟踪的 `tests/pair-trial/runs-v1` 创建新目录。另缺少旧 `clang`、`pair-trial` 和 `region-inventory` 可执行文件。 | 2026-11-19 17:00:11 | 失败 |

比较后续运行时，核对测试集合、状态和失败原因。删除测试或修复已知失败时，提交说明和本表同步记录。
