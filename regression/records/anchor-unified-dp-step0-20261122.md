# Anchor B2B DP 第 0 步：基线复现与观测

- 日期：2026-11-22
- 分支：`feat/anchor-unified-dp`
- 起点：`c7dded07a2a0d528c4a2b7ece1c7493e22d2758e`
- 在 EPYC 上静态检查，使用固定的 LLVM 12 搜索引擎与 LLVM 24 throughput worker。GPU 历史耗时沿用此前记录，本步未测 GPU。
- 唯一新增入口是调试变量 `FUSION_OBSERVE_B2B_DP`。不设置时走原来的规划与发射，接受分数继续比较 cleanup 后的候选与只清理的对照。beam 容量、段尾截断、cutoff、cleanup 和 TTI 档位沿用起点提交。

## 构建与复现命令

EPYC 工作目录 `/data/home/chh/simplify-v2/build/anchor-dp-step0.nNbMYe`。`base` 由起点的 `git archive` 解出，运行 `tools/build-v1`。`observed` 用改动后源码重新编译 `b2b_anchor.o`、重连 `fusion-search-llvm24`，并运行 `tools/build-decision-greedy` 和 `tools/build-decision-model`。其余搜索对象和 TTI worker 来自同一次基线构建。构建与运行环境见 `/data/home/chh/v2-runtime/reproduce.json` 的 `environment`。

| 实际使用的二进制 | 基线 SHA-256 | 观测版 SHA-256 |
| --- | --- | --- |
| `decision-greedy` | `fa1795b80acec0a7afd72c435853455524a04aaef7fb992f7554368d9e61074d` | `b6678ff1bfdbd26c237688bd9698e693ca9e6833687e96ff67a8923955d182a1` |
| `fusion-search-llvm24` | `892bcad9b23338819f446dde95bf9fda0e3bc9ce90af4efe96e838fb8dfdf4a2` | `ce3a73e89038eb3bc704b8641e4db6ab49c205144d6c158f9c33e44fa7e55074` |
| `llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` | 同基线 |
| `auto-darm-opt` | `99fcb66d33562b1506a6a1bebaab8de9902f816a2aec9c04ef033c855f888324` | 同基线 |
| ROCm 4.2.0 `opt` | `688ce3667a5c4ce79c793b81f3d6cc52175c268e9a850002f14bfd6f514b0ec4` | 同基线 |

以下命令分别在 `base` 和 `observed` 执行。运行前载入上述环境，`LLVM_CONFIG` 与 `LD_LIBRARY_PATH` 指向固定工具链。命令中的输出路径可替换为新的工作目录。

```sh
study=/data/home/chh/simplify-v2/build/anchor-dp-step0.nNbMYe
runtime=/data/home/chh/v2-runtime
shared=/data/home/chh/simplify-v2/build/lud8-identical-input.6VjBaq/shared.ll
writeback=/data/home/chh/simplify-v2/build/lud8-fusion-analysis.pno7Uy/anchor-input-1.ll
rocm=/data/home/chh/simplify-v2/build/darm-paper-repro.AtXc3N/rocm-root
fn=_Z13lud_perimeterPfii
search=build/llvm24-tti/fusion-search-llvm24
verify_opt="$(dirname "$LLVM_CONFIG")/opt"
scratch="$(mktemp -d)"

cd "$study/base"
worker="$PWD/tools/run-llvm24-tti"
"$search" --ir "$shared" --function "$fn" --structural 1 \
  --cleanup darm-cfg-dce-instcombine --tti-worker "$worker" \
  --split B0 --left B1 --right B2 --b2b-strategy anchor \
  --ir-snapshots full --debug-dir "$scratch/anchor" --out "$scratch/anchor.ll"
LD_LIBRARY_PATH="$rocm/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH" \
  "$runtime/toolchains/auto-darm-opt" -cfmelder -cf-merging-similarity-threshold=0.2 \
  -run-cfmelding-on-function=lud_perimeter -run-cfmelding-once -S \
  "$shared" -o "$scratch/darm.ll"
"$search" --ir "$scratch/darm.ll" --function "$fn" --structural 1 \
  --cleanup darm-cfg-dce-instcombine --control-only 1 --out "$scratch/darm-clean.ll"
for variant in anchor darm; do
  sed 's/-A5-ni:7/-A5-G1-ni:7/' "$scratch/$variant.ll" > "$scratch/$variant-o3-input.ll"
  LD_LIBRARY_PATH="$rocm/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH" \
    "$rocm/opt/rocm-4.2.0/llvm/bin/opt" -O3 -verify-each -S \
    "$scratch/$variant-o3-input.ll" -o "$scratch/$variant-o3.ll"
done
for ir in "$shared" "$scratch/anchor.ll" "$scratch/anchor/round-0-control.ll" \
          "$scratch/darm.ll" "$scratch/darm-clean.ll" "$scratch/anchor-o3.ll" "$scratch/darm-o3.ll"; do
  "$worker" "$ir" "$fn" --summary-only
done

cd "$study/observed"
worker="$PWD/tools/run-llvm24-tti"
python3 tests/fusion-search/observe-b2b-anchor.py "$search" "$worker" "$verify_opt" \
  --ir "$shared" --function "$fn" --split B0 --left B1 --right B2 --output "$scratch/first.json"
python3 tests/fusion-search/observe-b2b-anchor.py "$search" "$worker" "$verify_opt" \
  --ir "$writeback" --function "$fn" --split B3 --left B4 --right B5 --output "$scratch/writeback.json"

# 在两个构建目录分别运行，使用同一输出路径，一次完成后移走再运行另一次。
unset FUSION_OBSERVE_B2B_DP
build/decision-fuse/decision-greedy "$shared" "$fn" "$PWD" "$scratch/lud"
build/decision-fuse/decision-greedy \
  /data/home/chh/simplify-v2/cases/boost-mapairy/start.ll evaluate "$PWD" "$scratch/mapairy"
tests/run-v1
```

统一 O3 分别以 Anchor 已选候选和 DARM 原始输出为输入。两边在 O3 前恢复同样的数据布局 `G1`，最终用同一个 worker 报价。DARM 同 cleanup 的 698 是独立对照分支。

## LUD8 基线

共同输入 `shared.ll` 的 SHA-256 为 `a52a8746779c561db1be7bc66026508f909e9eeba2223c966d7fe201435782b9`。原版 DARM 的日志也确认了 %7 / %102。

| 位置 | 父 IR | 只清理对照 | Anchor 最佳 cleanup 后 | 原版 DARM 输出 | DARM 同 Anchor cleanup 后 | 统一 O3 后 Anchor / DARM |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 第一次搬入 %7 / %102 | 819 | 763 | 735 | 814 | 698 | 636 / 590 |
| 写回 %491 / %551 | 814 | 698 | 698（空匹配，与对照持平） | — | — | — |

写回父 IR 是 DARM 第一步的 `anchor-input-1.ll`，SHA-256 为 `aac7fc51373f1f0bcc694974b246b35b9f82ede14f7a2d1e0475525176eba7f1`。写回候选分数均不低于对照，未通过现有严格收益条件。

## DP 观测

观测脚本指定输入、函数与块对，收集 strict/relaxed 两份 planner 对象以及现有 trial 报告，对输出 IR 执行 `opt -verify`。JSON 含两侧零基指令序列、操作码/类型/IR、操作数报价、提议与锚点链、反向及 forward cutoff、冲突、每次状态上的配对报价和结果、beam 淘汰及输出方案全量 `pairs`。

| 位置 / 模式 | 左 / 右指令数 | proposed / 锚点 / 反向 cutoff / forward cutoff / 冲突 | 各输出方案（配对数，score，chargedSegments，phiCharge） |
| --- | ---: | ---: | --- |
| 搬入 strict | 105 / 111 | 0 / 0 / 1 / 523 / 0 | (25, 7, 5, 2)，(24, 6, 5, 2)，(0, −2, 1, 0) |
| 搬入 relaxed | 105 / 111 | 1 / 1 / 0 / 0 / 0 | (39, 10, 2, 4)，(38, 10, 2, 4)，(1, −6, 1, 3) |
| 写回 strict | 65 / 73 | 0 / 0 / 1 / 189 / 0 | (0, −2, 1, 0)，(1, −3, 1, 0) |
| 写回 relaxed | 65 / 73 | 1 / 1 / 0 / 0 / 0 | (2, −9, 2, 3)，(1, −9, 2, 4) |

反向 cutoff 与 relaxed 的固定锚点分别落在搬入的 (104, 110) 和写回的 (62, 70)。表中 cutoff 是唯一指令对的数量。搬入布局逐个 cleanup 后的 TTI 为 785、786、763、735、735、763，写回为 698、700、702、700。

搬入的 7 组对应配对，每种指令对在 strict 和 relaxed 中各遇到 4 个 DP 状态。下表的价格与淘汰方式对 7 组均成立。

| 搬入指令 | instructionCost | inputCost | gain | strict | relaxed |
| --- | ---: | ---: | ---: | --- | --- |
| 全局源地址 GEP | 1 | 1 | 0 | 进 beam 后淘汰 | 进 beam 后淘汰 |
| 全局 load | 1 | 1 | 0 | 进 beam 后淘汰 | 进 beam 后淘汰 |
| LDS 目标地址 GEP | 1 | 2 | −1 | forward cutoff | 进 beam 后淘汰 |
| LDS store | 1 | 2 | −1 | 进 beam 后淘汰 | 进 beam 后淘汰 |

首组的零基索引依次是 (44, 47)、(46, 49)、(47, 50)、(49, 52)。LDS 地址 GEP 的两笔费用来自 `peri_row/peri_col` 和 `tid/tid-8`。store 的状态上仍有两组不同的操作数，没能从对应生产者配对抵扣。两侧 store 的目标指针不同，无法给这 7 组提供同地址 store 锚点。7 组的四类边均未触发静态 `cutPairs`。标记为进入 beam 的边随后在同一目标格被 `skip_left` 的状态挤出，输出方案没有保留这些配对。

写回的同索引组 1 至 6 也观察到相同模式。按指令顺序，LDS 源 GEP 的 gain 为 −1、LDS load 为 0、全局目标 GEP 为 0、全局 store 为 −1。strict 在 forward cutoff 拦下 LDS GEP，其余进 beam 后淘汰。relaxed 四类都进过 beam，均未保留。第 1 组对应 (8, 16)、(10, 18)、(13, 21)、(15, 23)。

两处有效 `anchorCost` 对 GEP/load/store 报 1，add i32 报 1、add i64 报 2、mul i32 报 4、sext 报 1、shl i64 报 2，观察到的 bitcast、zext 和可配对 workgroup intrinsic 报 0。i32、i64 及相关指针的 `anchorSelectCost` 和 `anchorPhiCost` 均为 1。这些是规划器的局部报价。表中候选的 TTI 是对实际发射及清理后的 IR 重新报价。

| 完整观测文件（EPYC 工作目录下） | SHA-256 |
| --- | --- |
| `reproduction/first.json` | `e478119836714947d0d5279691b0cfa1c862788626cf0d50d0be36ef5bce1ed7` |
| `reproduction/writeback.json` | `b05d67759399d65af55b9671e2e2720dbb63dc7412fda47a8a2eb8e28e635ab4` |

## 默认行为与回归

| case | 完整 Greedy 提交数 | 初始 → 最终 TTI | 逐字节相同的候选 / 对照与其余 IR | 最终 IR SHA-256 |
| --- | ---: | ---: | --- | --- |
| LUD8 | 1 | 819 → 735 | 9/9 份 IR，4 条评分记录一致 | `526ce2273ff4f2c93cb8ce2d20ac992cdfef6cf31ca24966601954911cb76442` |
| MapAiry | 31 | 6402 → 4065 | 300/300 份 trial IR 一致，523 条评分记录一致。745 份快照中 704 份一致 | `33ea26bce53af5d07ea4f771018a691dcf2ca7384a4ef023708ab5d303ca0c49` |

MapAiry 使用冻结输入，SHA-256 为 `130d89d31e175129c35386aa68f040556a3addb5c0615a26948b75ee7963dce2`。41 处差异全在 `prepared-*.ll` 的 LLVM `; preds =` 注释内，逐份去掉该注释后逐字节相同。用同一基线二进制复跑，745 份快照里有 46 份出现同类注释重排，评分记录无变化。候选、对照、归一化和最终 IR 均逐字节一致。完整运行位于 `defaults/LUD8/` 和 `defaults/MapAiry/`。

同一个观测版二进制分别启用和关闭观测，两处的父 IR、对照和候选指纹、评分、接受结论与所选布局均相同。

`tests/run-v1` 通过，覆盖 `check-b2b-anchor`、`check-b2b-anchor-segments`、`observe-b2b-anchor`、`check-normalize-commit`、`check-tti-quotes`、`check-trial-queue`、`check-commit-score-invalidation`。通过现有 `check-known-failures.py final-anchor-dp-step0` 执行的 20 项检查中，16 项通过，condition、pair-trial、regions、similarity 按 `tests/KNOWN_FAILURES.md` 记为退出 77。证据见 `tests.log` 和 `observed/build/simplify-fingerprint/final-anchor-dp-step0/results.json`。

下一步的 beam 宽度实验可以量化这些状态是否只是因每格最多保留 4 个状态而淘汰。对于 strict 里的 LDS GEP，调大 beam 没有解除已观察到的 forward cutoff。对搬入多次重复的 select 仍须单独验证扣费行为。
