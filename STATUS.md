# 当前状态导航

更新于 2026-11-19。当前默认调度为 Auto Greedy V2 ordered。

| 范围 | 当前状态 |
|---|---|
| vLLM随机64K/128K | 收益回归通过；最新重建二进制保持一致 |
| Map-Airy混合输入 | 默认边界修复后恢复冻结二进制，实测24.64 μs通过；连续分块退化仍保留 |
| TIGRE Siddon | 已有收益回归和原始DARM同批对照 |
| Hypersonic | 指定L1+L2多锚点实验；IR回归通过；原runner异常未定因 |
| SRAD两个阶段 | 默认0融合/不误融合回归；无稳定新融合收益 |
| HiPIMS–HLLC | 最新prepared baseline GPU比较待验收 |
| Cholla–HLLD | 冻结规模扫描中 DP1 较 baseline 快 6.2%–8.3%。原版 DARM 在前两个规模慢 49.5%–60.7%，四个规模的范围为 49.5%–67.3%。见[同场记录](regression/records/hlld-v1-scaling.json)。 |
| Reentry | 成本/结构覆盖，当前新路径收益未确认 |

- [主线与架构](docs/MAINLINE.md)
- [Benchmark构建与运行](docs/BENCHMARK_GUIDE.md)
- [已知问题](docs/KNOWN_ISSUES.md)
- [精简方案](docs/REPOSITORY_PLAN.md)
- [回归入口](regression/README.md)
- [详细证据与历史对照](docs/project-status-and-darm-roadmap-20261110.md)

原2026-11-05运行时迁移报告及后续附记保留在 [历史状态](docs/history/runtime-migration-20261105.md)，不再作为当前active case/融合状态的依据。
