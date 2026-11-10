# Decision/Arm：关键分支核对与仅规范化 GPU 验收

2026-11-10，musa，AMD gfx906。独立实验路径；没有接入默认搜索，没有调用 RegionMelder，没有更新冻结 reference。

结论：本次指定范围的规范化通过 GPU 正确性验证。Map-Airy 基本持平；vLLM 全部 32 处量化树各规范化 L0/L1 后，在同批随机 64K/128K 输入上耗时下降约 4.6%。这不是新融合引擎或新评分器的收益。

## 实际变换范围

- Map-Airy：下尾 L4/L5 一对，仅建立短路 gate、dispatch、pair join 和所需 PHI。
- vLLM：32 处八路量化树，每处只规范化 L0/L1，共 32 次。其余叶子保留。
- 不试融合、不清理 trial；生成最终二进制时，两边使用相同 LLVM 12 AMD 后端 `opt -O3`、`llc -O3 -mcpu=gfx906` 和链接命令。

父 IR：

```text
/home/chh/kernel-benchmark-suite/experiments/mapairy-full-convergence-20261109-v1/steps-final/state-0.ll
/home/chh/kernel-benchmark-suite/experiments/recursive-all32-greedy-20261108-v1/state-0.ll
```

两边都从上述父 IR 重新编译。本次不是和历史 greedy winner 比较，也不能将本次绝对耗时与历史结果直接相减。
Map-Airy 编译出的 baseline 与冻结 baseline SHA 相同；vLLM 本次重编译 baseline 的 SHA 是 `5a11c36b…`，与冻结档案中的 `ecef393b…` 不同，结论仅针对本次同父 IR、同编译流程的配对。

## 结构核对

Map-Airy 的下尾决策识别出 12 个 Linear 计算叶子，L4～L11 均为完整单块；fallback L12 是直接去 join 的空路径，保守标记 Unsupported。测试 L4/L5 分别对应 `%if.then30.i.i.i.i` 和 `%if.then41.i.i.i.i`。

vLLM 与旧 `logical-state-0.json` 逐个核对：32 个八路决策的叶子集合、共同 join 全部一致，计算 Arm 均是单块 Linear。

但新发现器的末尾顺序为旧标签的 `L7,L6`：末级谓词发生反转，新列表此处使用 CFG true/false 顺序。不能把数组下标直接称为原 L 编号。当前只测试没有歧义的 L0/L1；自动贪心前需要明确采用结构邻接还是区间邻接，并将原逻辑顺序作为独立元信息保留。不能在没有说明的情况下把 L5/L7 当成数值区间相邻。

逐树映射和 Map-Airy 完整 Arm 边界在 `evidence/decision-normalization-gpu-20261110/arm-audit.json`。

## 测量结果

| 输入 | Baseline | 仅规范化 | 耗时变化 |
|---|---:|---:|---:|
| Map-Airy，混合输入，65,539 个值 | 49.440 μs | 49.600 μs | +0.32% |
| Map-Airy，连续分块，65,539 个值 | 16.000 μs | 16.000 μs | 0.00% |
| vLLM，随机 BF16，65,536 tokens | 2.896482 ms | 2.763522 ms | −4.59% |
| vLLM，随机 BF16，131,072 tokens | 5.748485 ms | 5.486565 ms | −4.56% |

所有输入均通过完整输出验证。Map-Airy 使用 long-double Boost 参考、既有 f64 容差；vLLM 的量化和缓存输出按字节精确比较。

同批运行两个版本，每个版本三批；每批 3 次预热、15 次测量，交替版本顺序；先取每批中位数，再取三批中位数。计时为既有 C++ HIP event runner 的 kernel 时间，不包含输入生成、传输和 CPU 校验。

Map-Airy 的微小差异没有统计显著性证明。本次仅验证上述配对与输入，不证明其他配对、完整搜索或其他设备均无退化。

输入全部由 C++ 临时生成：

- vLLM 沿用固定随机协议，8 heads × head_dim 128，种子 2026111001/2026111002，含打乱/跳过的 slots 和阈值样本。不是 Qwen 真 KV。
- Map-Airy 混合输入沿用冻结生成协议，12 个下尾锚点、固定种子 2026110301。
- 连续分块输入使用同一组锚点，按 `anchors[min(11, i*12/n)]` 排列并重新计算 oracle。与混合输入不是严格相同直方图的排列：非整除的尾数分配可能相差一个样本。

## O3 之后发生了什么

| 指标 | Map-Airy 前 → 后 | vLLM 前 → 后 |
|---|---:|---:|
| 条件 br | 70 → 70 | 351 → 319 |
| 无条件 br | 44 → 44 | 315 → 283 |
| PHI | 32 → 32 | 88 → 88 |
| select | 65 → 65 | 52 → 84 |
| VGPR | 37 → 37 | 62 → 62 |
| SGPR | 44 → 44 | 82 → 82 |
| SGPR / VGPR spill | 0 / 0 → 0 / 0 | 0 / 0 → 0 / 0 |

vLLM 还新增了 32 条 `or` 和 32 条 `xor`；调用指令类别统计没有变化，包括 copysign。没有证据表明本次收益来自共享 copysign。

这说明规范化改变了最终 O3 可以处理的 CFG：新增短路结构没有按原样全部留到最后，控制流与选择计算发生了转换。性能变化与该代码形态变化同时出现，但本次没有进一步隔离每种指令的具体耗时贡献。

“规范化不提前计算条件”描述的是新变换自身，不表示最终 LLVM O3 禁止合法的 if-conversion 或安全投机。两边的后端优化规则相同。

## 实验完整性与保存内容

第一次测量被哈希检查中止：诊断用 `llvm-objcopy --dump-section` 未指定独立输出文件，重写了测量中的 HSACO。第一次运行不作为最终验收证据。

随后从保存的 IR 重新编译到 `compiled-immutable-v2`，所有 GPU 验证和三批计时在 `measurement-v2` 完整重跑，过程中不再运行会重写测量二进制的诊断工具。最终 plan 为 completed；前后哈希检查通过。

运行目录：

```text
/home/chh/kernel-benchmark-suite-review-speculation/build/decision-model/gpu-normalization/compiled-immutable-v2
/home/chh/kernel-benchmark-suite-review-speculation/build/decision-model/gpu-normalization/measurement-v2
```

本地小型证据保存在 `docs/evidence/decision-normalization-gpu-20261110/`：summary、批次中位数、二进制 SHA、最终计划、输入生成参数与 SHA、Arm 映射、源文件 SHA。
完整计时 CSV 和验收收据保留在 musa。临时输入、oracle 和输出 blob 已删除；失效的第一次运行也仅保留诊断记录。没有把输入张量或 GPU 输出放进 Git。

## 复现入口

在 CPU 准入队列内调用：

```bash
python3 tools/run_cpu.py UNIQUE_LABEL python3 tests/decision-model/prepare_gpu_variants.py \
  --suite /home/chh/kernel-benchmark-suite \
  --tool /absolute/build/decision-model/decision-model \
  --out /absolute/new-compiled-directory
```

然后运行独立验收脚本；它自行调用 CPU 生成准入与现有 `bench` GPU 准入：

```bash
python3 tests/decision-model/gpu_validate.py \
  --suite /home/chh/kernel-benchmark-suite \
  --compiled /absolute/new-compiled-directory \
  --out /absolute/new-measurement-directory
```

固定 case 的块名只出现在验收脚本的输入选择中，不在通用发现器或规范化实现里。

## 下一步

可以接一次指定配对的 RegionMelder 调用，先比较 Map-Airy L4/L5 的四个阶段：父 IR、仅规范化、融合后、局部清理后。保持现有 LLVM24 TTI 评分不变。

自动贪心尚不应启用：还需明确稳定的邻接顺序、支持已有二路菱形的直接路径，并验证融合后的 Arm 重新绑定。此次没有替换旧入口或旧引擎。
