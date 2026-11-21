# c7dded0 全量 GPU 性能与跑法

实测代码为 `fix/normalize-commit` 的 `c7dded07a2a0d528c4a2b7ece1c7493e22d2758e`。B2B 使用默认 Anchor，归一化提交默认开启，TTI 使用 reciprocal throughput。显式关闭档仅追加 `--no-commit-normalize-only`。这份记录的 Git 提交用于归档，测量的代码提交以各收据中的 `source_commit` 或 `anchor_commit` 为准。

## 发布套件的 3+15 复测

覆盖 16 个发布 case、21 个冻结输入，AMD 使用 EPYC 上的 Radeon VII（gfx906），CUDA 使用 RTX 3090。14 个输入完成四档正式测量，其余 7 个输入两次 A/A 超限。已执行的完整输出校验全部通过。独立重试 CED/110 两次仍超限，数据单独保留。

- [全部输入、四档绝对耗时、六组配对时比及 95% 区间](benchmark-c7dded0-20261122/release-3plus15-20261121.md)
- [逐轮计时、A/A、四档二进制哈希和实际 runner](benchmark-c7dded0-20261122/release-3plus15-20261121.json)
- [CED 单独复测](benchmark-c7dded0-20261122/ced-3plus15-retest-20261121.json)

### 输入、构建与计时

1. 从 [2026-11-20 冻结发布清单](../golden/20261120-anchor-release/manifest.json) 取得设备 IR、数据、完整输出参考和各输入的 runner，按 SHA-256 核对。
2. 在每个冻结 IR 上，以 `c7dded0` 的 driver 分别跑默认完整 Greedy 和显式关闭的完整 Greedy，再按同一发布后端生成对象。开关两档的逐字节核对见 [默认值复验](normalize-commit-20261121.md#分支默认开启)。Baseline 和 Auto DARM 沿用上次发布复验的归档对象。vLLM 的 Auto DARM 使用无区域复制版本。SRAD32 沿用发布复验的 1024 线程启动兼容对象。
3. 对每个输入先用两份相同的关档对象做 12 轮 A/A。每轮每档预热 3 次、计时 15 次，轮内取 15 次计时的中位数。A/A 的中位数距 1 不超过 1%，跨度 `max(ratio)/min(ratio) - 1` 不超过 3%。超限重试一次，两次超限记录为无法可靠计时。
4. 通过后，baseline、默认开启、显式关闭、Auto DARM 按轮换顺序计时 12 轮。常规输入使用归档 runner 的独立进程入口。MS32、PCM32、NQU64 通过各自完整回放逻辑在进程内按 3+15 轮换。排序回放直接读取冻结输入与参考输出。TIGRE 每轮合计六组投影的计时中位数。每次完整输出校验失败立即停止。
5. 对每个比较计算 12 个逐轮耗时比，以 10,000 次配对 bootstrap 给出中位数和 95% 区间。区间的采样单位为轮。原始计时与命令日志保存在 EPYC 的 `/data/home/chh/simplify-v2/build/retest-release-315.BRiNaz/`。

在原 EPYC 归档已就绪的情况下，可将经过核对的 runner、冻结输入及对象交给原编排器。在新目录启动能保留已有结果。

```sh
campaign=/data/home/chh/simplify-v2/build/retest-release-315.BRiNaz
trial=$(mktemp -d /data/home/chh/simplify-v2/build/replay-315.XXXXXX)
cp "$campaign/nqu-315" "$campaign/sort-315" "$trial/"
python3 "$campaign/retest-release-315.py" "$trial"
```

## 原版 DARM artifact 对照

官方 CGO 2022 Figure 7 包含 7 组 benchmark、25 个配置。原版复现有 22 个配置通过 baseline、branch fusion、DARM 的完整校验。对 22 个入选配置重测 Anchor 后，21 个有 baseline、原版 DARM、Anchor 三档完整计时。DCT8 的 Anchor 与 baseline 逐字节相同，独立计时两次超时。LUD16、LUD32 的原版融合档输出未通过逐位校验。NQU256 的原版 baseline 解数错误。三者仍在全表中标记。 [官方测量脚本](https://github.com/charitha22/cgo22ae-darm-benchmarks/blob/7f253257c619ad6b8d6529653dbbe0a0d3007195/scripts/run_speedups.sh)

- [25 个配置的完整结果表，含绝对耗时、时比和未测原因](benchmark-c7dded0-20261122/anchor-vs-darm-full-20261122.md)
- [合并后的逐次数据与同 IR 核对](benchmark-c7dded0-20261122/anchor-vs-darm-full-20261122.json)
- [原版 artifact 的完整复现和论文对照](benchmark-c7dded0-20261122/darm-artifact-figure7-complete.md) · [原版逐次数据](benchmark-c7dded0-20261122/darm-artifact-figure7-complete.json)
- [Anchor 对照的初始测量记录](benchmark-c7dded0-20261122/anchor-on-darm-artifact-20261121.json) · [MS 四档使用同一 IR 的正式替换数据](benchmark-c7dded0-20261122/ms-common-inline-20261122.json)
- [LUD8 第一步使用同一个输入文件与统一 O3 的单独对照](benchmark-c7dded0-20261122/lud8-shared-o3-20261122.json)

### 输入、构建与计时

1. 使用上游 benchmarks 提交 `7f253257c619ad6b8d6529653dbbe0a0d3007195` 的配置和参数。在 EPYC 的 Radeon VII（gfx906）上用 ROCm 4.2.0 的 Clang、LLVM 后端和设备库构建，链接 ROCm 6.3.3 HIP 运行库。原生 DARM 使用 `auto-darm-opt -cfmelder -cf-merging-similarity-threshold=0.2`。其 SHA-256 记录在原版复现收据中。
2. Anchor 从 artifact baseline 的设备 IR 跑完整 Greedy。SRAD 分别处理两个启动的 kernel，LUD 处理 `lud_perimeter`。除 MS 外，18 个比较配置的入口 IR 已核对。去掉打印注释、对齐旧 DARM parser 的 `G1` 兼容处理后，IR 文本逐字节相同。
3. MS32、64、128、256 用共同的 `-O0 → GVN → mem2reg → 定向内联` 生成公共 IR，再分出 baseline、Anchor、原版 DARM。内联限于 `getIdx` 及其 HIP 坐标访问链，另处理旧 IR 的 `icmp` 常量表达式。每个配置的三档入口 SHA-256 相同，统一做 `simplifycfg` 和 `llc -O3`。全表使用这组 MS 数据。
4. 按 artifact 的计时范围每档运行 5 次，逐次对照完整输出的指纹。耗时取中位数，时比以各档中位数相除。排除未通过完整校验或计时超时的档位。原版、Anchor 和同 IR MS 的命令、逐次日志分别在 EPYC 的 `darm-paper-repro.AtXc3N`、`anchor-on-darm-artifact.MGDggq` 与 `anchor-paper-resume.nYv2Vt`、`ms-common-inline-ir.u2GBOI` 运行目录下，均位于 `/data/home/chh/simplify-v2/build/`。

在原 EPYC 的 artifact 构建与输入归档已经就绪的情况下，可使用原编排器重跑。Anchor 命令会保留未修改的原版对象。MS 同 IR 复测需单独执行并替换全表中的 MS 四行。

```sh
base=/data/home/chh/simplify-v2/build
artifact=$base/darm-paper-repro.AtXc3N
anchor_out=$(mktemp -d "$base/replay-anchor-artifact.XXXXXX")
python3 "$base/anchor-on-darm-artifact.MGDggq/anchor-on-darm-artifact.py" "$artifact" "$anchor_out"
ms_out=$(mktemp -d "$base/replay-ms-common.XXXXXX")
cp "$base/ms-common-inline-ir.u2GBOI/inline-ms-getidx.py" "$ms_out/"
python3 "$base/ms-common-inline-ir.u2GBOI/ms-common-inline-ir.py" "$artifact" "$ms_out"
```
