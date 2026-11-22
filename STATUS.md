# 当前状态导航

更新于 2026-11-22。发布候选对 Anchor B2B 和 DARM R2R 受限推测使用逐 wave 分类和双侧 uniform gain gate。发布清单提供确切 launch 形状，手工运行请用 `--anchor-wave-shape X,Y,Z` 或提供确切的 `reqd_work_group_size`。旧默认可用 `--anchor-mode legacy` 重放。

默认 Anchor 发射可直接使用原 split 条件，因为新用途位于原条件分支的执行范围内。LLVM 规定以 poison 或 undef 为条件执行 `br` 是未定义行为。 [LLVM LangRef](https://llvm.org/docs/LangRef.html#br-instruction)

PCM32 复现第 7d 步已测的设备对象，较上一发布默认快 6.83%，与 Auto DARM 持平。静态等价和补测见 [第 9 步发布候选复验](regression/records/anchor-r2r-speculation-release-20261122.md)。

下表保留 2026-11-20 冻结版本的背景。上一发布默认的逐输入计时和等价审计见 [第 8 步发布复验](regression/records/anchor-unified-dp-step8-20261122.md)。

| 范围 | 当前状态 |
|---|---|
| vLLM随机64K/128K | 默认 anchor 与 DP1/A 逐字节一致，冻结 v2 reference 保持原版本。 |
| Map-Airy混合输入 | 采用 anchor 的新参考。同 HSACO 的 12 轮连续性 N/A 0.84810，N/baseline 0.37605。旧参考保留。 |
| TIGRE Siddon | 默认 anchor 与 A 逐字节一致，旧 reference 保留。 |
| Hypersonic | 指定L1+L2多锚点实验；IR回归通过；原runner异常未定因 |
| SRAD两个阶段 | stage2 256×256 对 A 达标。1024×1024 的两种 A/A 均未通过，无法判定。 |
| HiPIMS–HLLC | 能构建 LLVM12 IR，pow 缺少 TTI 报价，排除出发布性能集。 |
| Cholla–HLLD | pending-regression。通过 DP1 相对门槛，较不融合慢约 7%–15%。第 3 次 R2B 是主要退化。 |
| Reentry | 成本/结构覆盖，当前新路径收益未确认 |
| Landau | mixed 通过。coherent 慢于 DP1 4.4%，是发布的已记录性能例外，第 17 次 R2R 为退化台阶。 |
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

DP1 的实现保存在 `pre-dp1-removal`，现有分支默认 anchor，保留 DARM 和 darm-artifact。测试、排除项和发布结果见 [RELEASE](docs/RELEASE.md)。
