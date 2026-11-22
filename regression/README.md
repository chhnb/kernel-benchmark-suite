# GPU 回归

当前收益回归：vLLM 随机 BF16 64K/128K、Map-Airy 混合输入、TIGRE Siddon。完整状态见 `case-status-20261110.json` 和 `../docs/project-status-and-darm-roadmap-20261110.md`。

## 发布复验

`golden/20261120-anchor-release/manifest.json` 固定发布 IR、设备产物、输入和参考输出，并记录各 kernel 的确切 workgroup 形状、出处、当前默认和 legacy 的静态参考。每个形状同时登记在对应 `case.json`。LUD8 使用另外登记的共同父 IR，参与两套搜索和发布性能比较。

```sh
python3 regression/verify_anchor_release.py --tool-root . --out build/anchor-release-new
```

复验逐 case 运行当前默认，校验最终 IR 哈希、提交数和 TTI，并按清单重建及核对 16 个冻结发布 case 的默认设备对象。脚本从 manifest 的 `anchor_profiles.legacy` 读取已冻结的旧默认 D 的 TTI 和 IR 哈希。当前默认 TTI 高于旧 D 时报告差值。复现旧默认 D 时请构建 `c7dded07`。可重复传 `--case` 选择子集。LUD8 额外重放写回候选，核实漏传形状时 gate 会拒绝守护布局。手动运行搜索时可传 `--anchor-wave-shape X,Y,Z`，或由 IR 提供确切的 `reqd_work_group_size`。

发布性能比较固定同一输入、参考、后端及 runner，按 case 协议在 12 轮中轮换新默认、legacy 和 Auto DARM。先做 A/A，超限允许重试一次。仍超限的输入转用 [v3 计时协议](records/anchor-unified-dp-step5-20261122.md)，每个角色每个窗口取 31 次完整校验的中位数，唯一重试使用 61 次，并保留原 A/A 门槛。CED 使用[第 7 步 HIP Graph 协议](records/pcm32-cleanup-strength-20261122.md)。所有区间使用同轮配对比值和 95% bootstrap。二进制逐字节一致时标记为别名，有同样输入和角色的既有配对测量时复用该测量。输出校验失败立即停止。

## 生成输入的回归

在 `/home/chh/kernel-benchmark-suite` 执行，`--candidate` 指向当前代码生成的二进制，`--out` 必须是新目录：

```sh
python3 tools/run_generated_regression.py vllm --candidate /absolute/current-vllm.hsaco --out /absolute/new-vllm-run
```

输入和 CPU 参考由 `regression/generators/generated_fixtures.cpp` 临时生成；GPU 验证和 event 计时使用 C++ runner，Python 只负责调度、设备准入与汇总。每个版本先验证完整输出，再进行3批、每批3次预热＋15次测量。各输入分别对冻结 reference 检查默认2%退化阈值；相同二进制记录为别名，不重复测量并声称独立对比。

- vLLM：固定种子2026111001/2026111002，65536/131072 tokens，8 heads、head_dim128，随机 BF16、跳过和打乱的 slots，并注入零值和阈值输入。不是历史 Qwen KV 数据。
- Map-Airy：65539个值、12个下尾区间锚点，种子2026110301打乱。新 C++ 打乱序列与旧 NumPy 字节不同；使用同批 reference 比较，不直接套旧绝对时间。连续分块输入曾变慢，不能把混合输入收益推广到全部输入。
- 运行成功即删除临时输入和参考输出，保留生成参数、种子、SHA、校验收据和计时 CSV。失败保留现场供诊断；`--keep-generated` 可显式保留。
- Git 只记录生成器、配置、清单、代码和小型结果摘要；不收录输入、参考输出、GPU 二进制。`golden/20261110-generated-gfx906-v1` 只在本机保留小型 runner/reference/baseline，Git 中仅保存 manifest；不是可独立下载的二进制发行包。
- 修改生成算法、冻结二进制或测试协议时，显式创建新版本，禁止自动更新 reference 来消除回归。

CPU 生成器一致性检查：

```sh
python3 tools/run_cpu.py UNIQUE_LABEL python3 /home/chh/kernel-benchmark-suite/regression/generators/check.py
```

当前 `check.py` 使用固定测试输出目录；已有结果时请先归档该目录再重新执行，避免覆盖证据。

当前融合代码重建候选（CPU 队列内运行）：

```sh
python3 tools/run_cpu.py UNIQUE_LABEL python3 /home/chh/kernel-benchmark-suite/regression/prepare_current_generated.py /absolute/new-current-build
```

## Map-Airy 共同父 IR 回归

`mapairy-v2.json` 固定输入、参考输出、父 IR 和原版 DARM 工具的 SHA-256。
三条路径从同一份父 IR 开始，随后统一执行 LLVM12 O3 和 gfx906 codegen。
Auto Greedy 使用当前构建的入口，发布复验按 manifest 提供 Map-Airy 的确切 workgroup 形状。
GPU 上轮换测三批，每批验证完整输出并记录 15 次计时。
输出目录保留工具命令、IR、二进制哈希和计时。首次结果见 `records/mapairy-v2-first.json`。
相对性能门槛使用同批 Greedy/DARM 中位耗时比，允许比首次记录相对退化 2%。

```sh
python3 tools/run_mapairy_regression.py --out /absolute/new-mapairy-run \
  --darm-opt /absolute/native-darm/bin/opt --greedy /absolute/current/decision-greedy \
  --llvm-bin /absolute/llvm12/bin --rocm /opt/rocm-6.3.3 \
  --runner /absolute/bench_hip
```

近期曾作为对照的 25 次融合产物属于历史融合版本，不用于共同父 IR 回归。

## TIGRE 和历史记录

TIGRE 沿用 `tools/run_golden_regression.py tigre --candidate /absolute/current-tigre.hsaco --out /absolute/new-tigre-run` 与现有冻结 head64/50 projections 基准。

旧 Qwen 真数据快照保留为历史归档，不作为 vLLM 日常回归输入，也未加入 Git。旧入口的 `vllm` 模式仅用于主动重放历史真数据。历史说明见 `HISTORY-20261109.md`。

## 完整叶子候选边界

搜索默认 `--cross-decision-leaves 0`。不同或无法识别的SSA判别值的完整叶子候选需要显式启用1；Hypersonic的指定多锚点入口已显式设置。Map-Airy默认搜索已恢复冻结二进制并通过混合输入回归。详见 `../docs/complete-leaf-decision-boundary.md`。

## Cholla HLLD 四组 GPU 回归

固定 `gfx906`、完整 FP64 HLLD kernel、共同父 IR 和 65,536 个
交错排列的合成界面。输入生成器和 CPU 解析通量参考由种子 20261115
复现。冻结清单在 `golden/20261115-hlld-gfx906-v1/manifest.json`，
父 IR、四个二进制及 runner 保存在 epyc 的本机构建目录
`build/hlld-golden-gfx906-v1`。

```sh
python3 tools/run_hlld_regression.py --out /absolute/new-hlld-run
```

可用 `--dp1 /absolute/current-dp1.hsaco --dp2 /absolute/current-dp2.hsaco`
对比新产物。回归按 12 轮交错运行，逐次校验七个通量分量。两组 Greedy
各自的逐轮耗时比中位数必须不超过同轮 Baseline 的 0.95。
Auto DARM 同轮测量并保留结果。两份冻结 Greedy 二进制相同；
分开计时用于观察波动。门槛适用于此冻结输入和设备。

规模扫描（65,536、262,144、1,048,576、4,194,304 个界面）见 `records/hlld-v1-scaling.json`。

### Anchor GPU 判定

本规则于 anchor v3 第 0 节固定，适用于后续所有 case。
`python3 regression/measure_anchor_gpu.py` 交错测量 baseline、A、N 共 12 轮，
每轮取中位时间并计算 N/A。所有完整轮次均 ≤ 1.02 则通过，均 > 1.02 则不通过。
若两者都有，使用固定种子和 10,000 次重采样计算配对比值中位数的 95% bootstrap
置信区间。区间上限 ≤ 1.02 时通过，下限 > 1.02 时不通过，其他情况判为不确定并汇报。

记录 A/baseline、N/baseline 和 N/A 各自的轮间跨度（最大比值除以最小比值再减 1）。
超过 5% 只在判定不确定时构成稳定性停止条件。明确判定保留全部轮次和跨度。
输出校验失败立即停止。DARM 可在独立批次测量供诊断。TIGRE runner 校验六个子批次
的完整输出及 guard，其他 event runner 逐次报告预热和计时样本的完整输出校验。
