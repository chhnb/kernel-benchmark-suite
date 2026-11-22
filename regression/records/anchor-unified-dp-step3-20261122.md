# Anchor B2B DP 第 3 步：守护单侧访存

- 日期：2026-11-22
- 分支：`feat/anchor-unified-dp`
- 起点：`71b71ac70ad707d99a207f6e9b160f3d918c3b62`。默认行为校验与 `c7dded07a2a0d528c4a2b7ece1c7493e22d2758e` 同父 IR、同输出路径比较。
- EPYC 工作目录：`/data/home/chh/simplify-v2/build/anchor-dp-step3.8d6gX5`。下文相对工件路径均指该目录。

## 实现

`--anchor-guarded-gap 0|1` 默认为 `0`，仅在 `--anchor-gap linear|both` 中扩展规划。开启后先保留原布局，再附加守护布局，现有接受判据继续使用 cleanup 后的 throughput TTI。下文两种守护配置都使用 `--anchor-cutoff live --anchor-gap-rank eager`，只改变 dedup。

- Planner 允许跳过简单的 load/store。两侧各自在遇到第一条需守护访存时扣 2 分。依赖本 gap 访存的计算也留在守护块，跨 gap 或出口 PHI 使用的值在结算时各扣一次 PHI 报价。整段不配及仅锚点兜底用同一方式计费。
- Planner 与 emitter 共用依赖根的分析。每个 gap 先发射可投机的独立指令，再按各臂原顺序生成守护块。两臂都需要守护时依次生成左右块，使用同一个 freeze 条件。需要跨块的值通过 PHI 在跳过边取 poison。配对指令在汇合后用正确一侧的值。
- 循环、convergent、alloca、volatile/atomic 等原有合法性约束继续生效。`guarded-linear` 标记实际发射了守护块的布局，`charged_segments` 计单侧块的数量。
- LLVM throughput TTI 在这里仍不会直接为「基址复用加立即数偏移」以及后端的 `ds_write2` 合并报价。第 2 步的 dedup 增加 LDS GEP 配对后，实际 GPU 性能与 TTI 的变化方向可不同。本步继续保留三个开关，接受规则和 cleanup 不变。

## 构建与命令

载入 `/data/home/chh/v2-runtime/reproduce.json` 的工具环境，使用固定 LLVM12 和 LLVM24 worker。编译两个改动的对象后，链接搜索工具、Greedy 和 model。构建命令和日志在 `compile-anchor-step3.sh`、`link-anchor-step2.sh` 与 `final-build.log`。

```sh
p=/data/home/chh/simplify-v2/build
shared="$p/lud8-identical-input.6VjBaq/shared.ll"
writeback="$p/lud8-fusion-analysis.pno7Uy/anchor-input-1.ll"
fn=_Z13lud_perimeterPfii
search="$PWD/build/llvm24-tti/fusion-search-llvm24"
worker="$PWD/tools/run-llvm24-tti"
out="$(mktemp -d)"
for d in 0 1; do
  FUSION_OBSERVE_B2B_DP="$out/writeback-$d.jsonl" "$search" --ir "$writeback" \
    --function "$fn" --split B3 --left B4 --right B5 --structural 1 --b2b-strategy anchor \
    --anchor-gap both --anchor-guarded-gap 1 --anchor-select-dedup "$d" \
    --anchor-cutoff live --anchor-gap-rank eager --tti-worker "$worker" \
    --debug-dir "$out/writeback-$d" --out "$out/writeback-$d.ll"
  build/decision-fuse/decision-greedy "$shared" "$fn" "$PWD" "$out/lud-$d" \
    --anchor-gap both --anchor-guarded-gap 1 --anchor-select-dedup "$d" \
    --anchor-cutoff live --anchor-gap-rank eager
  build/decision-fuse/decision-greedy /data/home/chh/simplify-v2/cases/boost-mapairy/start.ll \
    evaluate "$PWD" "$out/mapairy-$d" --anchor-gap both --anchor-guarded-gap 1 \
    --anchor-select-dedup "$d" --anchor-cutoff live --anchor-gap-rank eager
done
tests/run-v1
```

搬入改用 `shared.ll` 和 `B0/B1/B2`。第 2 步配置省略 `--anchor-guarded-gap` 并开 dedup，默认跑省略实验开关。全量命令在 `eval-anchor-step3.py` 和 `evaluation/`。raw、cleanup 和 O3 由同一 worker 报价。LUD8 的 O3 用 ROCm 4.2.0 `opt -O3 -verify-each`，先统一数据布局为 `G1`。

## LUD8 写回共同父状态

父状态为原版 DARM 第一步 `anchor-input-1.ll`，SHA-256 `aac7fc51373f1f0bcc694974b246b35b9f82ede14f7a2d1e0475525176eba7f1`。块对为 `%491 / %551`（B3/B4/B5），只清理 TTI 为 **698**。DARM 在该父状态上跳过第 2 步后做写回，raw TTI **850**，统一 O3 后 **574**。其归档见 `/data/home/chh/simplify-v2/build/lud8-darm-skip-step2.tuZy8T/step1-plus3-restored.ll`。

守护打开后，dedup=0 的最佳布局为 **805 / 677 / 564**（raw / cleanup / O3），dedup=1 为 **793 / 664 / 551**。后者使用一个右臂守护块保存 `peri_col[0]` 的原始 load/store，其后按索引配对六组写回。以下为 raw IR（`evaluation/writeback/guard-dedup1/debug/b2b-anchor-9-raw.ll`），两个地址在分支前计算。load 的结果只用在该守护块的 store，无需 live-out PHI。

```llvm
  %491 = freeze i1 %5
  ; ...
  %506 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 0, i32 %495
  %507 = bitcast float addrspace(3)* %506 to i32 addrspace(3)*
  ; ...
  br i1 %491, label %anchor.cont, label %anchor.guard

anchor.guard:
  %513 = load i32, i32 addrspace(3)* %507, align 4, !tbaa !5
  store i32 %513, i32 addrspace(1)* %511, align 4, !tbaa !5
  br label %anchor.cont

anchor.cont:
  %514 = select i1 %491, [8 x [8 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, [8 x [8 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col
  %515 = select i1 %491, i32 %3, i32 %495
  %516 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %514, i32 0, i32 1, i32 %515
  %517 = bitcast float addrspace(3)* %516 to i32 addrspace(3)*
  %518 = load i32, i32 addrspace(3)* %517, align 4, !tbaa !5
  ; ...
  store i32 %518, i32 addrspace(1)* %525, align 4, !tbaa !5
```

| 写回配置 | 布局 | 发射 / 模式 | 守护块 | DP 分数 | raw | cleanup | 698 − cleanup | O3 |
| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 共同 fork | 1 | before-split / strict | 0 | -2 | 814 | 698 | 0 | 590 |
| 共同 fork | 2 | before-split / strict | 0 | -3 | 815 | 700 | -2 | 593 |
| 共同 fork | 3 | segmented / relaxed | 0 | -9 | 834 | 700 | -2 | 593 |
| 共同 fork | 4 | segmented / relaxed | 0 | -9 | 834 | 702 | -4 | 596 |
| 共同 fork | 5 | segmented / relaxed | 0 | -9 | 834 | 700 | -2 | 593 |
| guard-dedup0 | 6 | guarded-linear / strict | 1 | 7 | 805 | 677 | 21 | 564 |
| guard-dedup0 | 7 | guarded-linear / strict | 1 | 7 | 805 | 678 | 20 | 565 |
| guard-dedup0 | 8 | guarded-linear / strict | 2 | -6 | 827 | 705 | -7 | 592 |
| guard-dedup0 | 9 | guarded-linear / relaxed | 1 | 7 | 805 | 682 | 16 | 571 |
| guard-dedup0 | 10 | guarded-linear / relaxed | 1 | 7 | 805 | 682 | 16 | 571 |
| guard-dedup0 | 11 | guarded-linear / relaxed | 2 | -6 | 827 | 704 | -6 | 591 |
| guard-dedup1 | 6 | guarded-linear / strict | 1 | 7 | 805 | 677 | 21 | 564 |
| guard-dedup1 | 7 | guarded-linear / strict | 1 | 7 | 805 | 678 | 20 | 565 |
| guard-dedup1 | 8 | guarded-linear / strict | 2 | -6 | 827 | 705 | -7 | 592 |
| guard-dedup1 | 9 | guarded-linear / relaxed | 1 | 19 | 793 | 664 | 34 | 551 |
| guard-dedup1 | 10 | guarded-linear / relaxed | 1 | 19 | 793 | 665 | 33 | 552 |
| guard-dedup1 | 11 | guarded-linear / relaxed | 2 | -6 | 827 | 704 | -6 | 591 |

## LUD8 搬入和完整 Greedy

搬入仍用共同输入 `shared.ll`，SHA-256 `a52a8746779c561db1be7bc66026508f909e9eeba2223c966d7fe201435782b9`，对照 **763**。开启守护后均选择原有纯线性布局，dedup=0 为 **773 / 666 / 558**，dedup=1 为 **759 / 673 / 564**（raw / cleanup / O3）。后者与第 2 步全开一致。新增的守护搬入布局 cleanup 后为 699 或 702，均未胜出。逐布局在 `evaluation/first/summary.json`。

| Greedy 配置 | 步 | 实际块对 | 发射 / 布局 | 父 TTI | 只清理对照 | 候选 TTI |
| --- | ---: | --- | --- | ---: | ---: | ---: |
| 默认 | 1 | %7 / %102 搬入 | segmented / 4 | 819 | 763 | 735 |
| 第 2 步全开 | 1 | %7 / %102 搬入 | linear / 7 | 819 | 763 | 673 |
| 守护，dedup=0 | 1 | %7 / %102 搬入 | linear / 9 | 819 | 763 | 666 |
| 守护，dedup=0 | 2 | %427 / %470 写回 | guarded-linear / 5 | 666 | 656 | 637 |
| 守护，dedup=1 | 1 | %7 / %102 搬入 | linear / 7 | 819 | 763 | 673 |
| 守护，dedup=1 | 2 | %147 / %275 行列更新 | guarded-linear / 5 | 673 | 663 | 661 |
| 守护，dedup=1 | 3 | %399 / %447 写回 | guarded-linear / 3 | 661 | 661 | 639 |

块号取每一步父 IR。dedup=1 的行列更新包含两个单侧守护块，实际只清理对照为 663，候选为 661，正收益 **2**。它针对原 DARM 第 2 步的行列更新区，使用自己的第 1 步父 IR；历史的 **+456** 是原 DARM 路径的 raw 差值。dedup=0 的行列更新未提交。LUD8 GPU 的本步候选按最终 TTI 最低选择 dedup=0，完整 Greedy 为 2 次提交，最终 TTI 637。dedup=1 为 3 次提交，最终 TTI 639。

## 工具哈希和正确性

| 二进制 | SHA-256 |
| --- | --- |
| 本步 `fusion-search-llvm24` | `ce7ecc94a2b1c64aaf9e057ab4eaf9c01733bba9534c175e644e11303aae9f85` |
| 本步 `decision-greedy` | `fd58611658cb49d6f4c6c7c59d17c007a28e61f150efe91ebdb8a93de9025d75` |
| `llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| LUD8 ROCm 4.2.0 `opt` / `llc` | `688ce3667a5c4ce79c793b81f3d6cc52175c268e9a850002f14bfd6f514b0ec4` / `268f3404625b6f3742a542ecc5a38376783d41ed2b7adb4e5ad54085518b4f56` |
| 默认对照 `decision-greedy` | `fa1795b80acec0a7afd72c435853455524a04aaef7fb992f7554368d9e61074d` |

`tests/run-v1` 通过，含 B2B、normalize-commit、TTI quotes、trial-queue、commit-score。新增的守护用例验证单侧 load 及其依赖活跃值的 poison PHI、单侧 store 保持在前后两个共享 load 之间、左右同时守护、仅流向 join PHI 的值，以及拒绝 convergent。对原始发射与源程序执行 `opt -O3 -verify-each`，用 CPU 对两侧和外部路径的返回值及全部测试内存做对比。首次结构断言误认为中间的 xor 直接跨块，真实布局中 xor 与依赖它的 add 一起守护，仅 add 结果跨块；按实际活跃值修正断言后通过。完整回归 16 项通过，condition、pair-trial、regions、similarity 按 `tests/KNOWN_FAILURES.md` 跳过。详见 `tests-r2.log` 与对应的 `suite.log`。

## LUD8 GPU 五档

沿用冻结输入 `-s 16384`、同一 HIP 主机 runner 和 gfx906。所有 IR 统一布局，执行同一 `opt -O3 -verify-each` 和 `llc -O2 -mtriple amdgcn-amd-amdhsa -mcpu=gfx906 --amdhsa-code-object-version=4 -filetype=obj`。顺序轮换五轮，共 25 次，每次完整输出哈希为 `99f686c239322d34`。收据、编译及执行命令在 `gpu/`，`gpu/results.json` SHA-256 为 `a11d27fad7f5ebd79fabd5e59274615e0c431c33853241da556d7c2e79816bd8`。

| 版本 | O3 TTI | 5 次耗时 (ms) | 中位数 (ms) | 相对 Baseline |
| --- | ---: | --- | ---: | ---: |
| Baseline | 664 | 524.115，518.229，515.627，514.326，518.282 | 518.229 | 1.0000 |
| 第 2 步全开 | 564 | 461.198，466.472，466.048，465.483，469.579 | 466.048 | 0.8993 |
| 守护，dedup=0 | 536 | 448.745，450.807，450.037，451.971，451.459 | 450.807 | 0.8699 |
| DARM 第一步 | 590 | 469.590，472.283，467.264，472.182，464.973 | 469.590 | 0.9061 |
| DARM 第 1+3 步 | 574 | 453.024，458.283，455.926，452.755，459.446 | 455.926 | 0.8798 |

本步守护布局耗时比第 2 步全开低 **3.27%**，比 DARM 第一步低 **4.00%**，比 DARM 第 1+3 步低 **1.12%**。本步设备对象 SHA-256 为 `e44e2051a062c2f88482a60a2f79fc0abc13bc11e40d79b575c426ade47e7a9b`。DARM 写回对照设备对象为 `0205f723d22172d025c78640d40fa68867f135c7322a955592e61e017d4b466c`。

## 定点搜索耗时

关闭 DP trace，在相同 LUD8 搬入块对交错运行守护模式的 dedup=0、1 各 6 次，其他参数不变。以 `request-profile.json` 的 `b2b_plan_generate_clean_total` 为规划与发射清理耗时。命令及逐次收据在 `time-anchor-step3.py`、`timing-dedup/`。

| dedup | 规划、发射和 cleanup 中位数 (ms) | 完整显式试验中位数 (ms) | 每个试验 cleanup 调用数 |
| --- | ---: | ---: | ---: |
| 0 | 259.861 | 499.532 | 12 |
| 1 | 266.743 | 476.895 | 10 |

打开 dedup 后，合计规划阶段约多 2.65%，完整试验约少 4.53%。布局数和计费路径也变了，测量没有把 `charged` 复制成本独立出来。这个对照未显示显著的整段搜索开销。

## MapAiry 与完整搜索耗时

MapAiry 使用 SHA-256 `130d89d31e175129c35386aa68f040556a3addb5c0615a26948b75ee7963dce2` 的共同父 IR。表中的纯线性和守护提交分开计数。耗时取同一构建的 Greedy `summary.json.elapsed_ms`，包含重新枚举、评分和输出写入。

| case | 配置 | 提交数 | 纯线性 | 守护 | 最终 TTI | 整体搜索 (s) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| LUD8 | 默认 fork | 1 | 0 | 0 | 735 | 1.121 |
| LUD8 | 第 2 步全开 | 1 | 1 | 0 | 673 | 1.011 |
| LUD8 | 守护，dedup=0 | 2 | 1 | 1 | 637 | 2.159 |
| LUD8 | 守护，dedup=1 | 3 | 1 | 2 | 639 | 1.584 |
| MapAiry | 默认 fork | 31 | 0 | 0 | 4065 | 44.953 |
| MapAiry | 第 2 步全开 | 30 | 26 | 0 | 3661 | 28.342 |
| MapAiry | 守护，dedup=0 | 30 | 26 | 0 | 3660 | 28.160 |
| MapAiry | 守护，dedup=1 | 30 | 26 | 0 | 3661 | 28.718 |

LUD8 守护配置进入更多提交轮次，搜索总耗时增加。两个守护配置之间，启用 dedup 后耗时下降。MapAiry 在相同提交结构下 dedup=1 比 dedup=0 多约 2%，比第 2 步配置多约 1.3%。这两种端到端对照与定点计时都未显示 `charged` 复制带来明显的搜索开销。单次完整 Greedy 耗时不能单独量化复制开销。

MapAiry 的 dedup=1 与本步第 2 步配置重放的最终 IR 逐字节相同，并与第 2 步归档的 HSACO 逐字节相同。dedup=0 的最终 IR 和设备代码均改变，因此按共同父 IR 协议补测。固定 65,539 元素混合输入，统一 LLVM12 `opt -O3 -verify-each`、`llc -O3` 和 ROCm 6.3.3 `ld.lld`，两份不同的 HSACO 做三批交替，每批每档 3 次预热、15 次计时，全部 108 个样本通过完整输出校验。dedup=1 记录为同二进制别名。

| MapAiry GPU | 第 1 批中位数 (µs) | 第 2 批 | 第 3 批 | 三批中位数 |
| --- | ---: | ---: | ---: | ---: |
| 第 2 步全开 | 30.880 | 31.040 | 31.199 | 31.040 |
| 守护，dedup=0 | 30.880 | 30.880 | 31.040 | 30.880 |
| dedup=0 / 第 2 步 | 1.0000 | 0.9948 | 0.9949 | 0.9948 |

MapAiry 的 HSACO 为 `b169b29ff118611b8028a9d31c622c1004f00b4cf3a7579336c5d678a4e5b53d`（第 2 步 / dedup=1）和 `03605b898901db2dd090a4b6ff5fbaf9265cef41359fef56f7c25ee0c7742664`（dedup=0）。runner `aa92386ea2a19f0111b8168f12bc21966cf32ab78cdb8d57b277c7f248f423ef`，`opt` `bf209ade6854e03637414290a3242aeed86b7269fd025c6b73a2ada6dca588a7`，`llc` `83242fe5b2e14402bae46dce47f8a7ae287da787e5387c06375f13bd5c44f891`。保留原始 samples、命令和 receipt。原脚本轮换时覆盖了一行配对比的角色标签，以上从批次中位数重算，原样本和各自中位数保持原值。更正后的 `mapairy-gpu/verified-summary.json` SHA-256 为 `a769bafd714047fd0d939d3ef07858bb43988281393bb9133519840b5ef68773`。

## 默认逐字节一致性

LUD8 的默认 9 份 IR 和 4 条评分记录全部与 `c7dded07` 一致，最终 IR SHA-256 为 `526ce2273ff4f2c93cb8ce2d20ac992cdfef6cf31ca24966601954911cb76442`。MapAiry 的 300 份 trial IR、最终 IR 和 523 条评分均一致。745 份快照中有 45 份准备快照仅 LLVM 前驱注释顺序不同，基线自重复现过同类差异。最终 IR SHA-256 为 `02201de85ba578fdfaea61facaf8e1ff1d34b01c93cd4c8b907d186683e66d5c`。

后续全量回归可以重点看守护 gap 带来多少额外提交和搜索时间，以及有小幅静态收益的行列更新是否带来 GPU 收益。本步保留默认配置，未进入下一步。
