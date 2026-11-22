# Anchor B2B DP 第 1 步：线性规划与发射

- 日期：2026-11-22
- 分支：`feat/anchor-unified-dp`
- 起点：`cffa7b9ed9989b60b9612ee742516c8be89b2b89`，默认行为比较基线为 `c7dded07a2a0d528c4a2b7ece1c7493e22d2758e`。
- 按修订后的计划跳过 beam 宽度实验。`--anchor-gap fork|linear|both` 同时接到显式试验和完整 Greedy。默认 `fork`。`both` 先保留原有布局顺序，再加入线性布局，按原有的 cleanup 后吞吐 TTI 评估。
- 线性 DP 仅跳过可安全投机且不读写内存的指令。需要配对的指令无法覆盖时，丢弃整段不配和仅锚点的兜底。线性 gap 不扣分叉或 PHI 代价，出口按实际新增的不同 select 收费。配对指令的 select 仍按原方式逐次计费，static 和 forward cutoff 均沿用原规则。
- 线性发射复用之前的前缀发射，按两侧原顺序共享配对指令并搬入未配对的纯计算。冻结条件，复用 selector，替换两个 arm 的 PHI 入边，删除这两个 arm。出口还有其他入边时，保留这些入边的 PHI。DP 分数仅用于规划和观测。

## 环境与复现

EPYC 工作目录为 `/data/home/chh/simplify-v2/build/anchor-dp-step1.EMLp5L`。使用 `/data/home/chh/v2-runtime/reproduce.json` 中的固定 LLVM 12/24 环境。基线为第 0 步的 `anchor-dp-step0.nNbMYe/base`。重新编译 `b2b_anchor.o`、`fusion_search.o`、前端和 Greedy，链接到同一基线的其他对象，并构建 model。详细命令见工作目录 `build-anchor-step1.sh`、`observe-anchor-step1.sh`、`eval-anchor-step1.py` 和 `gpu-anchor-step1.py`。

| 二进制 | 实际 SHA-256 |
| --- | --- |
| 发射前的 `fusion-search-llvm24` | `cbefe73a6f2cf79f56df425c77d2996c6e281bbe8f327eefe7d5c61c15174e0b` |
| 最终 `fusion-search-llvm24` | `e19f9fd485b329dc6aade08241118a4a7b7365d1e55016510e42d9e7142c6ff6` |
| 最终 `decision-greedy` | `8148e0240d7d7fa10625e164e7ac8e2d038810fefbcbed9c22e5acf6c3b894e6` |
| 基线 `fusion-search-llvm24` | `892bcad9b23338819f446dde95bf9fda0e3bc9ce90af4efe96e838fb8dfdf4a2` |
| 基线 `decision-greedy` | `fa1795b80acec0a7afd72c435853455524a04aaef7fb992f7554368d9e61074d` |
| `llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
| ROCm 4.2.0 `opt` | `688ce3667a5c4ce79c793b81f3d6cc52175c268e9a850002f14bfd6f514b0ec4` |
| ROCm 4.2.0 `llc` | `268f3404625b6f3742a542ecc5a38376783d41ed2b7adb4e5ad54085518b4f56` |

共同输入 `lud8-identical-input.6VjBaq/shared.ll` SHA-256 为 `a52a8746779c561db1be7bc66026508f909e9eeba2223c966d7fe201435782b9`。写回父 IR 为 DARM 第一步的 `lud8-fusion-analysis.pno7Uy/anchor-input-1.ll`，SHA-256 为 `aac7fc51373f1f0bcc694974b246b35b9f82ede14f7a2d1e0475525176eba7f1`。MapAiry 使用发布 manifest 中的冻结输入，SHA-256 为 `130d89d31e175129c35386aa68f040556a3addb5c0615a26948b75ee7963dce2`。

```sh
# 从 EPYC 工作目录运行，先载入 reproduce.json 中的环境。
p=/data/home/chh/simplify-v2/build
shared="$p/lud8-identical-input.6VjBaq/shared.ll"
writeback="$p/lud8-fusion-analysis.pno7Uy/anchor-input-1.ll"
fn=_Z13lud_perimeterPfii
search="$PWD/build/llvm24-tti/fusion-search-llvm24"
worker="$PWD/tools/run-llvm24-tti"
verify_opt="$(dirname "$LLVM_CONFIG")/opt"
out="$(mktemp -d)"

python3 tests/fusion-search/observe-b2b-anchor.py "$search" "$worker" "$verify_opt" \
  --ir "$shared" --function "$fn" --split B0 --left B1 --right B2 \
  --anchor-gap linear --output "$out/first.json"
python3 tests/fusion-search/observe-b2b-anchor.py "$search" "$worker" "$verify_opt" \
  --ir "$writeback" --function "$fn" --split B3 --left B4 --right B5 \
  --anchor-gap linear --output "$out/writeback.json"
FUSION_OBSERVE_B2B_DP="$out/dp.jsonl" "$search" \
  --ir "$shared" --function "$fn" --split B0 --left B1 --right B2 \
  --structural 1 --b2b-strategy anchor --anchor-gap both --tti-worker "$worker" \
  --debug-dir "$out/debug" --out "$out/candidate.ll"

build/decision-fuse/decision-greedy "$shared" "$fn" "$PWD" "$out/lud" --anchor-gap both
build/decision-fuse/decision-greedy /data/home/chh/simplify-v2/cases/boost-mapairy/start.ll \
  evaluate "$PWD" "$out/mapairy" --anchor-gap both
tests/run-v1
```

写回的显式搜索改用 `"$writeback"` 和 `B3/B4/B5`，分别执行 `fork`、`linear` 和 `both`。打开 DP 观测时，`--debug-dir` 下会落每个布局的 raw 和 cleaned IR，cleanup 后去重的布局也会保留报告。正式 Greedy 的评分与去重顺序不变。

## 发射前的规划验证

先只构建线性规划器、CLI 和观测，线性计划在进入发射前被截断。结果见 `planner-only/first.json` 和 `planner-only/writeback.json`，SHA-256 分别为 `84cff4aea564ed5a415e4ea939363fddc3ce6595a6c12603276a09d4661358d5` 和 `02be9afa0bf81d0a493b1e5d92e45e8eaf0c4ca2a76d101c485a8772bce21515`。

| 块对 | 线性模式 | 转移 | 最终方案（配对数 / 分数） | load / store 覆盖 |
| --- | --- | --- | --- | --- |
| 搬入 %7 / %102 | strict | 291 插入、123 forward cutoff、4 静态 cutoff | 70 / 27，69 / 27 | 每个方案 11 / 11 对 |
| 搬入 %7 / %102 | relaxed | 414 插入、2 次追加固定锚点 | 79 / 27，78 / 27 | 每个方案 11 / 11 对 |
| 写回 %491 / %551 | strict | 152 插入、49 forward cutoff | 无 | 左 6 组，右 7 组 |
| 写回 %491 / %551 | relaxed | 197 插入 | 无 | 左 6 组，右 7 组 |

搬入 7 行都采用相同的排法。沿最终路径，全局 GEP、其 bitcast、load、store 的净收益依次为 0、0、+1、0。load 的前驱已经配对，LDS store 只为地址付一次报价。第 1 行的 strict 还观察到一个没有匹配地址生产者的前置状态，此时 load 的 gain 为 0。两种模式的最终方案内，每行净赚 +1。

| 搬入行 | 全局 GEP / load / LDS GEP / store 的零基配对下标 | strict 中 LDS GEP | relaxed 中 LDS GEP |
| --- | --- | --- | --- |
| 1 | (44,47) (46,49) (47,50) (49,52) | −1，forward cutoff | −1，插入后淘汰 |
| 2 | (52,56) (54,58) (55,59) (57,61) | −1，forward cutoff | −1，插入后淘汰 |
| 3 | (60,65) (62,67) (63,68) (65,70) | −1，forward cutoff | −1，插入后淘汰 |
| 4 | (68,74) (70,76) (71,77) (73,79) | −1，forward cutoff | −1，插入后淘汰 |
| 5 | (77,83) (79,85) (80,86) (82,88) | −1，forward cutoff | −1，插入后淘汰 |
| 6 | (86,92) (88,94) (89,95) (91,97) | −1，forward cutoff | −1，插入后淘汰 |
| 7 | (95,101) (97,103) (98,104) (100,106) | −1，forward cutoff | −1，插入后淘汰 |

relaxed 中配对 LDS GEP 的状态会先落后 1 分。第 1 行的四个此类状态都在继续匹配 store 前被 `skip_left` 路径排出。线性模式没有 fork gap 扣分，这个差异来自当前的局部 select 价格。最终方案保留两侧各自的 LDS GEP 和 bitcast，然后 select 指针并共用 store。

写回右侧首先执行第 0 组 load/store，随后执行第 1 至 6 组。左侧只有第 1 至 6 组。同索引的 6 组均未到达配对转移。DP 必须先尝试把左侧第 1 组与右侧第 0 组对齐，最后剩下右侧成对的 load/store。线性模式不允许跳过它们。两侧末尾的第 7 组在 join 后继续执行，不计入 arm 内的 6/7 组。此形状需要能保留单侧访存的布局。

## 发射后的 TTI 校准

`both` 的布局编号如下。第一处的 4 个线性方案在 `linear` 单独运行时编号为 1–4，TTI 相同。最后一列在 cleanup 后的 Anchor IR 上统一运行 ROCm 4.2.0 `opt -O3 -verify-each`。和第 0 步一样，O3 前统一恢复数据布局的 `G1`，再用同一 worker 报价。

| 搬入方案 | DP 分数 | raw TTI | cleanup 后 TTI | 763 − cleanup 后 TTI | O3 后 TTI |
| --- | ---: | ---: | ---: | ---: | ---: |
| fork 1 | 7 | 855 | 785 | −22 | 641 |
| fork 2 | 6 | 856 | 786 | −23 | 641 |
| fork 3 | −2 | 819 | 763 | 0 | 664 |
| fork 4（旧 Anchor） | 10 | 813 | 735 | +28 | 636 |
| fork 5 | 10 | 813 | 735 | +28 | 636 |
| fork 6 | −6 | 828 | 763 | 0 | 664 |
| linear 7 | 27 | 778 | 668 | +95 | 560 |
| linear 8 | 27 | 778 | 668 | +95 | 563 |
| linear 9（所选） | 27 | 773 | 666 | +97 | 558 |
| linear 10 | 27 | 773 | 666 | +97 | 558 |
| 原版 DARM 第一步 | — | 814 | 698 | +65 | 590 |

DARM 第一步的 698 是独立运行同套 Anchor cleanup 的结果，590 来自原始 DARM 输出直接做同一 O3。线性方案的 DP 同报 27，仍由实际 cleanup 后的 666/668 决定取舍。

所选布局在 barrier 前最后一组的原始 IR，摘自 `evaluation/first/both/debug/b2b-anchor-9-raw.ll`。中间指令省略：

```llvm
  %151 = load i32, i32 addrspace(1)* %150, align 4, !tbaa !5
  %152 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_row, i32 0, i32 6, i32 %4
  %153 = bitcast float addrspace(3)* %152 to i32 addrspace(3)*
  %154 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* @_ZZ13lud_perimeterPfiiE8peri_col, i32 0, i32 6, i32 %8
  %155 = bitcast float addrspace(3)* %154 to i32 addrspace(3)*
  %156 = select i1 %7, i32 addrspace(3)* %153, i32 addrspace(3)* %155
  store i32 %151, i32 addrspace(3)* %156, align 4, !tbaa !5
  ; ...
  store i32 %170, i32 addrspace(3)* %171, align 4, !tbaa !5
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier() #3
  fence syncscope("workgroup") acquire
```

| 写回方案（DARM 第一步为父状态） | DP 分数 | raw TTI | cleanup 后 TTI | 698 − cleanup 后 TTI | O3 后 TTI |
| --- | ---: | ---: | ---: | ---: | ---: |
| fork 1 | −2 | 814 | 698 | 0 | 590 |
| fork 2 | −3 | 815 | 700 | −2 | 593 |
| fork 3 | −9 | 834 | 702 | −4 | 596 |
| fork 4 | −9 | 834 | 700 | −2 | 593 |
| linear | — | — | — | — | — |
| 原版 DARM 第一步 + 写回 | — | 850 | — | — | 574 |

DARM 的 574 是跳过原第二步后，在同一个第一步父状态上做写回并统一 O3 得到的归档对照，出处是 `/data/home/chh/simplify-v2/build/lud8-first-writeback.vy0RyY/results.json` 的 `costs.darm_1_3`。698 是 Anchor 本轮的只清理对照，写回在两种 Anchor 模式下都未提交。

## 完整 Greedy 与 GPU

| case | 初始 TTI | 默认提交数 / 最终 TTI | both 提交数 / 最终 TTI |
| --- | ---: | ---: | ---: |
| LUD8 | 819 | 1 / 735 | 1 / 666 |
| MapAiry | 6402 | 31 / 4065 | 30 / 3660 |

LUD8 的 both 配置在共同输入上选择同一处 %7 / %102 的线性方案。最终 IR SHA-256 为 `b56665b58f88c96d3d19380978353433f60d7cdbf9edad0d63a9cad631f41cf3`。

MapAiry 的 both 有 26 次提交选择线性 B2B。首步成本由默认的 6150 降到 6129，最终比默认低 405（9.96%）。both 最终 IR SHA-256 为 `e7266c410b7835adc5941305aaec1106ab11ee0865e9490d2165284e8abb8afd`。MapAiry 仅做静态比较。

四档使用同一个 LUD8 主机程序与输入 `-s 16384`，分别以共同基线、基线 Anchor Greedy、both Greedy 和 DARM 第一步 IR 生成设备对象。均先恢复 `G1` 并运行 `opt -O3 -verify-each`，再以 `llc -O2 -mtriple amdgcn-amd-amdhsa -mcpu=gfx906 --amdhsa-code-object-version=4 -filetype=obj` 编译。用同一 HIP 运行时链接，在同一张 gfx906 上做 5 轮，逐轮轮换四档的执行顺序。每次校验完整输出指纹 `99f686c239322d34`。20 次全通过。原始输出、工具命令、二进制哈希在 `gpu/`，`gpu/results.json` SHA-256 为 `3827b759cf3a119cad8f0fc175badfda26a87c4d9ae7b6700564524ce95cf192`。

| 版本 | 5 次耗时（ms，按轮次） | 中位数（ms） | 中位数 / Baseline |
| --- | --- | ---: | ---: |
| Baseline | 514.295，513.694，523.759，523.468，512.581 | 514.295 | 1.0000 |
| 旧 Anchor | 501.734，504.354，509.036，504.598，508.785 | 504.598 | 0.9811 |
| Anchor both | 473.824，466.191，472.995，469.076，473.516 | 472.995 | 0.9197 |
| DARM 第一步 | 464.564，470.548，466.618，464.751，471.853 | 466.618 | 0.9073 |

both 的中位数比旧 Anchor 低 6.26%，比 DARM 第一步高 1.37%。

## 默认逐字节验证与异常

LUD8 的 9 份 IR 和 4 条评分记录均与 `c7dded07` 一致，最终 IR SHA-256 为 `526ce2273ff4f2c93cb8ce2d20ac992cdfef6cf31ca24966601954911cb76442`。MapAiry 默认候选和最终 IR 与基线逐字节相同，准备快照的注释差异见 第 0 步的基线复跑。本步两次默认运行的 745 份快照中，44 份 `prepared-*.ll` 仅 LLVM `; preds =` 注释次序不同。其余 701 份（含 300 份 trial IR 和最终 IR）及 523 条评分逐项一致。默认最终 IR SHA-256 为 `33869cc437e3928fcb05f1ce6663c7c85c5ad5438c610018cca7b35bd699ddc5`。

`tests/run-v1` 覆盖 B2B、normalize-commit、TTI 报价、trial-queue 和 commit-score。新增用例检查未配对的 load、可除零的整数除法和 convergent 调用会被拒绝，原访存保持 load → store → load，两条 arm 的出口值合成 select，同时保留外部入边。通用 LLVM `opt -O3 -verify-each` 和 CPU 双分支全结果及内存值对比均通过。一个用例在未选分支上构造 poison shift，raw IR 检查它经由未选中操作数进入 store 的输入 select。初次运行时测试把 convergent 的拒绝原因错误限定成「缺少 B2B 布局」，该例实际在更早的合法性检查拒绝，修正断言后全套复跑。

已有回归驱动 `check-known-failures.py final-anchor-dp-step1-r2` 的结果为 16 项通过，condition、pair-trial、regions、similarity 按 `tests/KNOWN_FAILURES.md` 退出 77。记录见 `tests-r2.log` 与 `build/simplify-fingerprint/final-anchor-dp-step1-r2/results.json`。

下一步分别观察 select 去重、实时 cutoff、eager 排序的影响。对搬入重点看 LDS GEP 是否进入最终配对。写回左右访存数不同，只改分数和 cutoff 无法形成完整线性方案。
