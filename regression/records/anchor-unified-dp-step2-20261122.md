# Anchor B2B DP 第 2 步：GPU 验证与状态计费

- 日期：2026-11-22
- 分支：`feat/anchor-unified-dp`
- 起点：`6727417fd6c9e8519213ec45df1468ff446686f5`。默认行为对照为 `c7dded07a2a0d528c4a2b7ece1c7493e22d2758e`。
- EPYC 工作目录：`/data/home/chh/simplify-v2/build/anchor-dp-step2.L023nO`，以下相对路径均指这个目录。进入代码改动前完成 MapAiry GPU 测量和 LUD8 ISA 对比。

## A. MapAiry 第 1 步产物的 GPU 验证

按 [Map-Airy 共同父 IR 协议](../README.md#map-airy-共同父-ir-回归) 使用 `mapairy-v2.json` 的 65,539 元素冻结混合输入。共同父 IR 的 SHA-256 为 `130d89d31e175129c35386aa68f040556a3addb5c0615a26948b75ee7963dce2`，输入 `input.bin` 为 `0018705f2b9c28db1fcc20f4fd6356db8e2ae19972c910029e8978b4baa51125`，`reference.bin` 为 `584c3a9a5e9d1b20cfb3552b021eb528d8dab34ebc4a091a5599bc09a1c0ec26`。另校验了 spec 和输出初始化文件。

从第 1 步工作目录 `anchor-dp-step1.EMLp5L/evaluation/MapAiry/{fork,both}/final.ll` 取已验证的两份最终 IR。它们由第 1 步 `decision-greedy`（SHA-256 `8148e0240d7d7fa10625e164e7ac8e2d038810fefbcbed9c22e5acf6c3b894e6`）和 `fusion-search-llvm24`（`e19f9fd485b329dc6aade08241118a4a7b7365d1e55016510e42d9e7142c6ff6`）从同一父 IR 生成。按原协议的 LLVM12 `opt -O3 -verify-each`、`llc -O3` 和 ROCm 6.3.3 `ld.lld` 重新编译。单 GPU，锁内三批，顺序为 fork/both、both/fork、fork/both。每档每批 3 次预热、15 次计时，108 行样本都通过完整输出校验。

| MapAiry | 第 1 批中位数 (µs) | 第 2 批 | 第 3 批 | 三批中位数 | HSACO SHA-256 |
| --- | ---: | ---: | ---: | ---: | --- |
| fork | 33.120 | 33.120 | 32.960 | 33.120 | `5cc3f528f4f1f08e51c56f04a73e0593d2ebb703076e2950f275eb5058ccbc21` |
| both | 30.880 | 30.880 | 30.720 | 30.880 | `03605b898901db2dd090a4b6ff5fbaf9265cef41359fef56f7c25ee0c7742664` |
| 同批时比 both/fork | 0.9324 | 0.9324 | 0.9320 | 0.9324 | — |

both 耗时下降 **6.76%**，未触发超过 2% 退化时的逐提交回退。数据和命令在 `mapairy-gpu/`，`results.json` SHA-256 为 `c9a07fb6c342ce2850b8c99fe166ae4307d397efa521d638bf791e6bf10fe7e1`。runner SHA-256 为 `aa92386ea2a19f0111b8168f12bc21966cf32ab78cdb8d57b277c7f248f423ef`。

```sh
"$llvm12/opt" -O3 -verify-each -S "$final" -o "$post"
"$llvm12/llc" -O3 -mtriple=amdgcn-amd-amdhsa -mcpu=gfx906 -mattr=+sramecc \
  -amdhsa-code-object-version=4 -filetype=obj "$post" -o "$obj"
/opt/rocm-6.3.3/llvm/bin/ld.lld -shared "$obj" -o "$hsaco"
"$runner" --kernel "$hsaco" --input /data/home/chh/v2-runtime/cases/mapairy/inputs/65539/input.txt \
  --mode benchmark --warmup 3 --repeat 15 --output "$batch"
```

## B. LUD8 第 1 步 ISA 对比

使用第 1 步同批 GPU 测量的 `gpu/{linear_both,darm_step1}/o3.ll`，校验其哈希后以同一 ROCm 4.2.0 `llc -O2 -mtriple amdgcn-amd-amdhsa -mcpu=gfx906 --amdhsa-code-object-version=4 -filetype=asm` 发射。只统计 `_Z13lud_perimeterPfii` 的实际汇编指令。寄存器数、LDS 和 scratch 从该 kernel 的 code object metadata 读取。

| 静态指标 | 第 1 步 Anchor both | 原版 DARM 第一步 |
| --- | ---: | ---: |
| `global_load*` | 12 | 12 |
| `ds_write*` | 18 | 14 |
| `ds_read*` | 36 | 36 |
| `v_cndmask*` | 22 | 22 |
| `s_cbranch*` | 4 | 4 |
| `s_waitcnt` | 44 | 39 |
| VGPR / SGPR | 36 / 20 | 32 / 18 |
| 静态 LDS / scratch 字节 | 768 / 0 | 768 / 0 |
| 指令总数 | 566 | 552 |

差异集中在 LDS 写指令的合并程度。Anchor 有 13 条 `ds_write_b32` 和 3 条 `ds_write2_b32`，DARM 是 5 条和 7 条，双方另各有 2 条 `ds_write_b128`。按指令宽度展开，两边都对应 27 个 dword 写入。Anchor 的静态写指令多 4 条，等待多 5 条，寄存器用量也更高。这些差异与 GPU 中位数高 1.37% 的方向一致。第 1 步的计时范围有重叠，静态计数无法单独确定各项的耗时贡献。完整 opcode 分布、汇编和命令在 `lud8-isa/`，`results.json` SHA-256 为 `3330141c617768e55233fe8ec43ebe5eb3c8a4b4cd7f9251b114785e87c5801f`。

## C. 计费和排序开关

| 开关 | 默认 | 启用行为 |
| --- | --- | --- |
| `--anchor-select-dedup 0\|1` | `0` | DP 状态累计实际收费的操作数对，重用不收费。等值和已配对生产者不计入集合。线性 join 与配对转移共享集合。默认计费下，join 只从真正会插入 select 的输入对恢复集合。 |
| `--anchor-cutoff static\|live` | `static` | 反向传播仍记录 cutoff，DP 不再用它禁止转移。strict forward cutoff 继续使用当前状态的 gain，包含启用去重时省下的报价。 |
| `--anchor-gap-rank lazy\|eager` | `lazy` | 只在 fork 生效。第一步跳过立即扣 2 分，结算时只补本次尚未扣除的费用和 PHI。最终得分的定义不变。 |

显式搜索和 Greedy 使用同一组开关。启用项进入 trial 请求与复放参数。接受、cleanup 和 throughput TTI 档位沿用起点设置。未增加混合 gap。

构建使用 `reproduce.json` 固定环境，从基线对象重编 `b2b_anchor.o`、`fusion_search.o` 和搜索前端，再链接 Greedy 和 model。初始并行构建让 driver 在对象生成前开始，报缺少 `fusion_search.o`。构建对象完成后重新链接，见 `final-build.log` 与 `final-link.log`。

```sh
# 在 EPYC 工作目录执行，先载入 /data/home/chh/v2-runtime/reproduce.json 的 environment。
p=/data/home/chh/simplify-v2/build
shared="$p/lud8-identical-input.6VjBaq/shared.ll"
fn=_Z13lud_perimeterPfii
search="$PWD/build/llvm24-tti/fusion-search-llvm24"
worker="$PWD/tools/run-llvm24-tti"
out="$(mktemp -d)"
FUSION_OBSERVE_B2B_DP="$out/dp.jsonl" "$search" --ir "$shared" --function "$fn" \
  --split B0 --left B1 --right B2 --structural 1 --b2b-strategy anchor --anchor-gap both \
  --anchor-select-dedup 1 --anchor-cutoff live --anchor-gap-rank eager \
  --tti-worker "$worker" --debug-dir "$out/debug" --out "$out/fused.ll"
build/decision-fuse/decision-greedy "$shared" "$fn" "$PWD" "$out/lud" \
  --anchor-gap both --anchor-select-dedup 1 --anchor-cutoff live --anchor-gap-rank eager
build/decision-fuse/decision-greedy /data/home/chh/simplify-v2/cases/boost-mapairy/start.ll \
  evaluate "$PWD" "$out/mapairy" \
  --anchor-gap both --anchor-select-dedup 1 --anchor-cutoff live --anchor-gap-rank eager
tests/run-v1
```

单项测试只传一个实验开关。写回改用 `lud8-fusion-analysis.pno7Uy/anchor-input-1.ll`、`B3/B4/B5`。每个 raw 与 cleaned 布局在相同 worker 上报价，再用 ROCm 4.2.0 `opt -O3 -verify-each` 和统一的 `G1` 布局得到 O3 TTI。完整命令与工件见 `eval-anchor-step2.py`、`evaluation/`。

| 实际构建或执行的二进制 | SHA-256 |
| --- | --- |
| `fusion-search-llvm24` | `e48d6e676ee43b85d7c43e18298befde622263f817caa5f8345422a915e20e41` |
| `decision-greedy` | `1b9caf5a1dbd796ed8347015fef3b1f1500dd3deca6c4a67b6badce4273549b6` |
| `llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| MapAiry LLVM12 `opt` / `llc` | `bf209ade6854e03637414290a3242aeed86b7269fd025c6b73a2ada6dca588a7` / `83242fe5b2e14402bae46dce47f8a7ae287da787e5387c06375f13bd5c44f891` |
| LUD8 ROCm 4.2.0 `opt` / `llc` | `688ce3667a5c4ce79c793b81f3d6cc52175c268e9a850002f14bfd6f514b0ec4` / `268f3404625b6f3742a542ecc5a38376783d41ed2b7adb4e5ad54085518b4f56` |

### LUD8 搬入块 %7 / %102

共同父 IR 仍为 `a52a8746779c561db1be7bc66026508f909e9eeba2223c966d7fe201435782b9`，对照 TTI 为 763。

| `gap=both` 的计费开关 | 所选布局 | 所选方案的中间 LDS GEP 配对 | DP 分数 | raw / cleanup / O3 TTI |
| --- | --- | ---: | ---: | --- |
| 第 1 步设置 | linear 9 | 0/7 | 27 | 773 / 666 / 558 |
| 仅 dedup | linear 7 | 7/7 | 47 | 761 / 672 / 563 |
| 仅 live | linear 9 | 0/7 | 27 | 773 / 666 / 558 |
| 仅 eager | linear 9 | 0/7 | 27 | 773 / 666 / 558 |
| 三项全开 | linear 7 | 7/7 | 49 | 759 / 673 / 564 |

dedup 让第一个 LDS GEP 的 gain 从 −1 到 0，其余六个从 −1 到 +1。tid 与 tid−8 的 select 先由 `dia` 搬运付费，第一组 `peri` 只付 row/col 基地址，后六组重用两项。开启 dedup 后四个线性规划结果全部保留这 7 对。fork 即使开 dedup，最终方案仍未保留这 7 对。

只开 live 时 strict forward cutoff 仍拦下这 7 对，线性布局不变。全开时，live 在 strict 又放开了尾部 `(104,110)`，这个配对使两条 strict 方案从 47 分升到 49 分，与 relaxed 的两条方案相同，布局层去重后只剩两条线性布局。只开 dedup 时的 strict 布局取得 672，尾部并入后留下的是 673。相对第 1 步，选中的全开布局 raw 少 14，cleanup 后多 7，O3 后多 6。去重改善了当前规划器的局部计费，布局选出的实际收益仍取决于 cleanup。

以下是全开所选布局中间行的 raw IR。索引 `%13` 和 LDS 基地址 `%67` 在这 7 行共用，摘自 `evaluation/first/all/debug/b2b-anchor-7-raw.ll`：

```llvm
  %13 = select i1 %7, i32 %4, i32 %8
  ; ...
  %67 = select i1 %7, [8 x [8 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, [8 x [8 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col
  ; ...
  %100 = load i32, i32 addrspace(1)* %99, align 4, !tbaa !5
  %101 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %67, i32 0, i32 3, i32 %13
  %102 = bitcast float addrspace(3)* %101 to i32 addrspace(3)*
  store i32 %100, i32 addrspace(3)* %102, align 4, !tbaa !5
```

### 逐布局校准

每行按试验报告中的布局编号，含调试报告捕获的 cleanup 后重复布局。同一个 IR 仍只参与一次接受判断。

**搬入**

| 设置 | 布局 | 发射 / 模式 | DP 分数 | raw | cleanup | 763 − cleanup | O3 |
| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 第 1 步设置、仅 live、仅 eager | 1 | segmented / strict | 7 | 855 | 785 | -22 | 641 |
| 第 1 步设置、仅 live、仅 eager | 2 | segmented / strict | 6 | 856 | 786 | -23 | 641 |
| 第 1 步设置、仅 live、仅 eager | 3 | before-split / strict | -2 | 819 | 763 | 0 | 664 |
| 第 1 步设置、仅 live、仅 eager | 4 | segmented / relaxed | 10 | 813 | 735 | +28 | 636 |
| 第 1 步设置、仅 live、仅 eager | 5 | segmented / relaxed | 10 | 813 | 735 | +28 | 636 |
| 第 1 步设置、仅 live、仅 eager | 6 | segmented / relaxed | -6 | 828 | 763 | 0 | 664 |
| 第 1 步设置、仅 live、仅 eager | 7 | linear / strict | 27 | 778 | 668 | +95 | 560 |
| 第 1 步设置、仅 live、仅 eager | 8 | linear / strict | 27 | 778 | 668 | +95 | 563 |
| 第 1 步设置、仅 live、仅 eager | 9 | linear / relaxed | 27 | 773 | 666 | +97 | 558 |
| 第 1 步设置、仅 live、仅 eager | 10 | linear / relaxed | 27 | 773 | 666 | +97 | 558 |
| 仅 dedup | 1 | segmented / strict | 20 | 806 | 736 | +27 | 637 |
| 仅 dedup | 2 | segmented / strict | 20 | 806 | 736 | +27 | 637 |
| 仅 dedup | 3 | before-split / strict | -2 | 819 | 763 | 0 | 664 |
| 仅 dedup | 4 | segmented / relaxed | 18 | 813 | 735 | +28 | 636 |
| 仅 dedup | 5 | segmented / relaxed | 18 | 813 | 735 | +28 | 636 |
| 仅 dedup | 6 | segmented / relaxed | -6 | 828 | 763 | 0 | 664 |
| 仅 dedup | 7 | linear / strict | 47 | 761 | 672 | +91 | 563 |
| 仅 dedup | 8 | linear / strict | 47 | 761 | 672 | +91 | 566 |
| 仅 dedup | 9 | linear / relaxed | 49 | 759 | 673 | +90 | 564 |
| 仅 dedup | 10 | linear / relaxed | 49 | 759 | 673 | +90 | 564 |
| 全开 | 1 | segmented / strict | 20 | 806 | 736 | +27 | 637 |
| 全开 | 2 | segmented / strict | 20 | 806 | 736 | +27 | 637 |
| 全开 | 3 | before-split / strict | -2 | 819 | 763 | 0 | 664 |
| 全开 | 4 | segmented / relaxed | 18 | 813 | 735 | +28 | 636 |
| 全开 | 5 | segmented / relaxed | 18 | 813 | 735 | +28 | 636 |
| 全开 | 6 | segmented / relaxed | -6 | 828 | 763 | 0 | 664 |
| 全开 | 7 | linear / strict | 49 | 759 | 673 | +90 | 564 |
| 全开 | 8 | linear / strict | 49 | 759 | 673 | +90 | 564 |

**写回**

| 设置 | 布局 | 发射 / 模式 | DP 分数 | raw | cleanup | 698 − cleanup | O3 |
| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 第 1 步设置、仅 dedup、仅 live | 1 | before-split / strict | -2 | 814 | 698 | 0 | 590 |
| 第 1 步设置、仅 dedup、仅 live | 2 | before-split / strict | -3 | 815 | 700 | -2 | 593 |
| 第 1 步设置、仅 dedup、仅 live | 3 | segmented / relaxed | -9 | 834 | 702 | -4 | 596 |
| 第 1 步设置、仅 dedup、仅 live | 4 | segmented / relaxed | -9 | 834 | 700 | -2 | 593 |
| 仅 eager、全开 | 1 | before-split / strict | -2 | 814 | 698 | 0 | 590 |
| 仅 eager、全开 | 2 | before-split / strict | -3 | 815 | 700 | -2 | 593 |
| 仅 eager、全开 | 3 | segmented / relaxed | -9 | 834 | 700 | -2 | 593 |
| 仅 eager、全开 | 4 | segmented / relaxed | -9 | 834 | 702 | -4 | 596 |
| 仅 eager、全开 | 5 | segmented / relaxed | -9 | 834 | 700 | -2 | 593 |

写回使用 DARM 第一步共同父状态。eager 改变了 fork 中保留的布局，但各配置的最佳 TTI 都等于对照 698。两侧仍为 6 对 7 组访存，所有配置都没有线性布局。第 1 步记录中的 DARM 写回 O3 TTI 为 574。

### LUD8 GPU 补测

因为完整 Greedy 的 TTI 从 666 变为 673，在同一 gfx906 上补测。沿用第 1 步的 `-s 16384`、统一 `G1`、ROCm 4.2.0 `opt -O3 -verify-each` / `llc -O2`、同一 HIP 主机程序与五轮轮换顺序。每次验证完整输出指纹 `99f686c239322d34`，20 次全部通过。命令见 `gpu-anchor-step2.py` 和 `gpu/*/build.log`。收据 `gpu/results.json` SHA-256 为 `bab74ead744b1f04c5f88330c51f338472308de363e725fcedc70e57f0171204`。

| LUD8 版本 | 各轮耗时 (ms) | 中位数 (ms) | 中位数 / Baseline |
| --- | --- | ---: | ---: |
| Baseline | 517.428，519.496，519.013，521.624，528.658 | 519.496 | 1.0000 |
| 第 1 步 both | 465.125，468.768，469.527，467.428，473.675 | 468.768 | 0.9024 |
| 三项全开 | 464.422，460.294，464.664，464.100，465.548 | 464.422 | 0.8940 |
| DARM 第一步 | 461.073，468.876，464.148，464.233，469.154 | 464.233 | 0.8936 |

全开中位数比本批第 1 步 both 低 0.93%，比 DARM 第一步高 0.04%。五次样本范围有重叠，汇报描述性时比。

### 测试与默认行为

`tests/run-v1` 包含 B2B、normalize-commit、TTI quotes、trial-queue、commit-score 检查。新增规划器用例验证四次使用同一对输入值和两个同样的出口只收费一次，等值及已配对生产者不收费。另一用例保留反向 cutoff 计数，live 允许已具正收益的配对。还验证 eager 对同一 fork 路径的结算分数、段数和 PHI 费用不变，并对线性模式不起作用。已有回归驱动得到 16 项通过，4 项依据 `tests/KNOWN_FAILURES.md` 退出 77（condition、pair-trial、regions、similarity）。详见 `tests.log` 和 `build/simplify-fingerprint/final-anchor-dp-step2/results.json`。

| 默认 Greedy 校验 | 与 `c7dded07` 逐字节一致的候选 | 评分记录 | 最终 IR SHA-256 |
| --- | --- | ---: | --- |
| LUD8 | 4/4 份候选，全部 9 份 IR 相同 | 4/4 | `526ce2273ff4f2c93cb8ce2d20ac992cdfef6cf31ca24966601954911cb76442` |
| MapAiry | 300/300 份候选，745 份 IR 中 704 份相同 | 523/523 | `843de4617527746b7e169a4e159424426f6d830ba3bded16ec7fa9bb706f0df9` |

MapAiry 的 41 份准备快照仅 LLVM `; preds =` 注释顺序不同。第 0 步的基线自重复出现过同类重排。本步默认配置的候选、对照与最终产物逐字节一致。

### 完整 Greedy 静态对比

| case | 初始 TTI | fork 默认（提交 / 最终 TTI / 线性提交） | 第 1 步 both | 本步全开 |
| --- | ---: | --- | --- | --- |
| LUD8 | 819 | 1 / 735 / 0 | 1 / 666 / 1 | 1 / 673 / 1 |
| MapAiry | 6402 | 31 / 4065 / 0 | 30 / 3660 / 26 | 30 / 3661 / 26 |

全开的 LUD8 最终 IR SHA-256 为 `6d4ac63063346df387e469de43266a33c8cfe6046ad46381d7c717faaf5364d8`，MapAiry 为 `617d63aeca44d6ebec00957a1f0d68d69afbca8a4fc52e0e20cc3f4ec825697e`。两案最终静态结果见 `evaluation/results.json`。MapAiry 的 GPU 数字只覆盖第 1 步产物，本步全开仅做静态对比。

下一步的混合 gap 要验证能否在共享写回的同时保留右臂第 0 组访存，并用完整输出确认执行次数和原始顺序。线性布局配对数增加时，继续把 DP 分数与 cleanup 及 GPU 实际结果并列记录。
