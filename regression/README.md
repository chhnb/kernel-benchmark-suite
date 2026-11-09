# GPU 回归

当前收益回归：vLLM 随机 BF16 64K/128K、Map-Airy 混合输入、TIGRE Siddon。完整状态见 `case-status-20261110.json` 和 `../docs/project-status-and-darm-roadmap-20261110.md`。

## 生成输入的回归

在 `/home/chh/kernel-benchmark-suite` 执行，`--candidate` 指向当前代码生成的二进制，`--out` 必须是新目录：

```sh
python3 tools/run_generated_regression.py vllm --candidate /absolute/current-vllm.hsaco --out /absolute/new-vllm-run
python3 tools/run_generated_regression.py mapairy --candidate /absolute/current-mapairy.hsaco --out /absolute/new-mapairy-run
```

输入和 CPU 参考由 `regression/generators/generated_fixtures.cpp` 临时生成；GPU 验证和 event 计时使用 C++ runner，Python 只负责调度、设备准入与汇总。每个版本先验证完整输出，再进行3批、每批3次预热＋15次测量。各输入分别对冻结 reference 检查默认2%退化阈值；相同二进制记录为别名，不重复测量并声称独立对比。

- vLLM：固定种子2026111001/2026111002，65536/131072 tokens，8 heads、head_dim128，随机 BF16、跳过和打乱的 slots，并注入零值和阈值输入。不是历史 Qwen KV 数据。
- Map-Airy：65539个值、12个下尾区间锚点，种子2026110301打乱。新 C++ 打乱序列与旧 NumPy 字节不同；使用同批 reference 比较，不直接套旧绝对时间。连续分块输入曾变慢，不能把混合输入收益推广到全部输入。
- 运行成功即删除临时输入和参考输出，保留生成参数、种子、SHA、校验收据和计时 CSV。失败保留现场供诊断；`--keep-generated` 可显式保留。
- Git 只记录生成器、配置、清单、代码和小型结果摘要；不收录输入、参考输出、GPU 二进制。`golden/20261110-generated-gfx906-v1` 只在本机保留小型 runner/reference/baseline，Git 中仅保存 manifest；不是可独立下载的二进制发行包。
- 修改生成算法、冻结二进制或测试协议时，显式创建新版本，禁止自动更新 reference 来消除回归。

CPU 生成器一致性检查：

```sh
python3 experiments/saspoint5-cuda-v1/run_cpu.py UNIQUE_LABEL python3 /home/chh/kernel-benchmark-suite/regression/generators/check.py
```

当前 `check.py` 使用固定测试输出目录；已有结果时请先归档该目录再重新执行，避免覆盖证据。

当前融合代码重建候选（CPU 队列内运行）：

```sh
python3 experiments/saspoint5-cuda-v1/run_cpu.py UNIQUE_LABEL python3 /home/chh/kernel-benchmark-suite/regression/prepare_current_generated.py /absolute/new-current-build
```

## TIGRE 和历史记录

TIGRE 沿用 `tools/run_golden_regression.py tigre --candidate /absolute/current-tigre.hsaco --out /absolute/new-tigre-run` 与现有冻结 head64/50 projections 基准。

旧 Qwen 真数据快照保留为历史归档，不作为 vLLM 日常回归输入，也未加入 Git。旧入口的 `vllm` 模式仅用于主动重放历史真数据。历史说明见 `HISTORY-20261109.md`。

## 完整叶子候选边界

搜索默认 `--cross-decision-leaves 0`。不同或无法识别的SSA判别值的完整叶子候选需要显式启用1；Hypersonic的指定多锚点入口已显式设置。Map-Airy默认搜索已恢复冻结二进制并通过混合输入回归。详见 `../docs/complete-leaf-decision-boundary.md`。
