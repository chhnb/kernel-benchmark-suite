# NQU 的第三次 B2B 融合与 GPU 性能退化

2026-11-15 · AMD Radeon VII / gfx906 · DP1 与 DP2 均使用默认 DARM B2R

## 1. 受控比较

NQU64 的两种策略从同一个设备 IR 出发，前两次均提交相同的 DARM B2R，第二次之后的 IR 内容一致。DP1 停在该版本，DP2 再提交一次 B2B，候选为 `B2:B19:B20`，布局为 `single-branch-dp2-9-direct`。以下把第三次融合之前记为 `P_0`，之后记为 `P_1`。

| NQU 尺寸 | DP1 最终 TTI | DP2 最终 TTI | DP1 GPU 中位耗时 | DP2 GPU 中位耗时 | 耗时变化 |
|---|---:|---:|---:|---:|---:|
| 64 | 275 | 270 | 631.502 ms | 659.670 ms | +4.46% |
| 96 | 292 | 287 | 438.272 ms | 457.459 ms | +4.38% |
| 128 | 293 | 288 | 340.339 ms | 355.362 ms | +4.41% |
| 256 | 293 | 288 | 183.554 ms | 190.840 ms | +3.97% |

表中使用 baseline、Auto DARM、DP1、DP2 四组轮换的同场中位数。每个尺寸的四组运行报告相同的解数。

## 2. 逐 lane 的语义

在 NQU64 循环头 `unify.bb`，定义以下变量。

- `c` 为累计解数（`%35`），`d` 为当前搜索深度（`%36`），`M` 为本 lane 对应的 LDS 搜索状态。
- `a=%38` 表示当前层已耗尽可尝试的位置。
- `b = %46 = ¬a ∧ %45` 表示当前掩码下没有可用候选。
- `z=%48` 表示 `d+1` 已达到目标深度。
- `p = %50 = a ∨ b ∨ z` 为回退侧条件。DP2 在替换分支中使用 `freeze i1 %50`，以下按进入该分支时条件已定义且相关算术有定义的执行描述。

令 `M_0` 为两个版本在分支前都已更新过的 LDS 状态。令 `U(M_0,d,d+1)` 表示下降到下一层时，按原顺序执行的 `mask`、`l_mask`、`r_mask` 和 `m` 更新。两版的局部状态转移如下。

| 原路径条件 | `c'` | `d'` | 分支后的 LDS |
|---|---:|---:|---|
| `a ∨ b` | `c` | `d-1` | `M_0` |
| `¬a ∧ ¬b ∧ z` | `c+1` | `d-1` | `M_0` |
| `¬a ∧ ¬b ∧ ¬z` | `c` | `d+1` | `U(M_0,d,d+1)` |

随后，若 `d'>-1`，从 LDS 读取下一轮的 `m[d']` 并回到循环头，否则退出搜索循环。状态方程由 `merged.bb19` 的 PHI 和后续 `select` 按路径化简得到，适用范围为上述有定义的执行。

## 3. 执行域与循环携带值

设一个 wave 到达分支前的活动 lane 集合为 `E`，定义 `E_T = {ℓ ∈ E : p(ℓ) = true}`、`E_F = E ∖ E_T`。

```text
P0
  if p:  compute c+1 and d-1
  else:  update LDS for descent
  join:  obtain next count and depth

P1
  compute c+1 and d-1
  if !p: update LDS for descent
  join:  obtain next count and depth
```

两条算术从 `E_T` 扩展到 `E`，LDS 下降更新仍在 `E_F`。因此每轮新增的算术 lane 执行量为 `2 × |E_F|`。实际 wave 指令发射和周期成本取决于掩码、后端调度及数据依赖。

gfx906 反汇编显示，DP2 在 `s_and_saveexec_b64` 收窄 EXEC 前发射两条 `v_add_u32`。循环尾部的深度选择也发生变化如下。

```asm
; P0
v_cndmask_b32_e32 v2, v3, v3, vcc
; P1
v_cndmask_b32_e32 v2, v8, v3, vcc
```

P0 的两个数据操作数由各自路径写入同一物理寄存器。P1 的两个数据操作数来自不同寄存器，使选择对两条深度值链都有依赖。NQU64 双方静态 LDS 指令数及 `s_cbranch_execz` 数量一致。两版均为 22 SGPR、10 VGPR、10,496 B LDS 和 0 字节 scratch。

## 4. 静态评分与实测方向相反

第三次融合的 LLVM24 TTI 变化可精确写成下面的等式。

```text
TTI(P1) - TTI(P0) = (-1 × 4) + (-1 × 1) = -5
                     无条件 br       PHI
```

评分统计中的 load、store、条件分支和算术条数都未变化。GPU 计时对应的是不同活动掩码下重复执行的机器码，循环携带值依赖和 LDS 周围的调度也随改写变化。静态评分给这次变换正收益，实测给出相反方向。

### NQU64 消融

三轮交错计时，所有版本均通过 LLVM verifier，GPU 均报告 2,279,184 个解。

| 版本 | GPU 中位耗时 |
|---|---:|
| `P_0` | 631.668 ms |
| `P_1` | 659.871 ms |
| `P_1`，仅把提前的 LDS 地址 GEP 移回保护块 | 659.888 ms |
| `P_0`，额外执行 IR `-O3` | 619.365 ms |
| `P_1`，额外执行 IR `-O3` | 630.595 ms |

单独移回 GEP 后的 HSACO 与 `P_1` 逐字节相同。额外执行 IR `-O3` 后，两版的差距从约 4.47% 缩到 1.81%。现有证据把退化定位到第三次 B2B 及其热循环代码生成。提前执行算术、循环尾的值选择、LDS 附近的调度各自贡献多少，仍缺独立消融或动态计数。

## 5. 证据位置

以下证据均位于 `epyc` 的同一个回测目录。

```text
/data/home/chh/kernel-benchmark-suite/build/nqu-guard.WKPsAN/tail-arith.xLPf/memory-match.YIwp9c/dp2-backtest.azgs01_s/
```

| 相对路径 | 内容 |
|---|---|
| `four-results.json` | 四组 GPU 样本和中位数 |
| `dp1/NQU64/final.ll` | `P_0` |
| `dp2/NQU64/final.ll` | `P_1` |
| `dp2/NQU64/trial-8/structural/trial-0/trial.json` | 第三次融合候选及 TTI 指令分类 |
| `dp1/NQU64/gpu/disassembly.txt` | `P_0` 汇编 |
| `dp2/NQU64/gpu/disassembly.txt` | `P_1` 汇编 |
| `nqu64-attribution/` | 消融 IR、运行脚本、二进制和逐轮日志 |
