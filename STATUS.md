# 当前状态导航

更新于 2026-11-20。Auto Greedy V2 使用 ordered 调度，默认 B2B 为 anchor。

| 范围 | 当前状态 |
|---|---|
| vLLM随机64K/128K | 默认 anchor 与 DP1/A 逐字节一致，冻结 v2 reference 保持原版本。 |
| Map-Airy混合输入 | 采用 anchor 的新参考。同 HSACO 的 12 轮连续性 N/A 0.84810，N/baseline 0.37605。旧参考保留。 |
| TIGRE Siddon | 默认 anchor 与 A 逐字节一致，旧 reference 保留。 |
| Hypersonic | 指定L1+L2多锚点实验；IR回归通过；原runner异常未定因 |
| SRAD两个阶段 | stage2 256×256 对 A 达标。1024×1024 的两种 A/A 均未通过，无法判定。 |
| HiPIMS–HLLC | 最新prepared baseline GPU比较待验收 |
| Cholla–HLLD | pending-regression。历史 A 比未融合慢约 7%，主要退化出现在第 3 次 R2B。 |
| Reentry | 成本/结构覆盖，当前新路径收益未确认 |
| Landau | 设计集。mixed 通过，coherent 的 anchor 对未融合慢约 6%。 |
| TPACF | anchor / DP1 对未融合分别慢约 20% / 27%。 |
| CED / SW2D / HiPIMS–George | 冻结 anchor 对 A 通过。 |
| SasPoint5 | 两种测量方式均未通过整例 A/A。 |

- [主线与架构](docs/MAINLINE.md)
- [Benchmark构建与运行](docs/BENCHMARK_GUIDE.md)
- [已知问题](docs/KNOWN_ISSUES.md)
- [精简方案](docs/REPOSITORY_PLAN.md)
- [回归入口](regression/README.md)
- [详细证据与历史对照](docs/project-status-and-darm-roadmap-20261110.md)

原2026-11-05运行时迁移报告及后续附记保留在 [历史状态](docs/history/runtime-migration-20261105.md)，不再作为当前active case/融合状态的依据。
