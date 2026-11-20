# PCM32 第 10 步 R2R 的同父 IR

Auto DARM 第 10 步进入 RegionMelder 时捕获父 IR。目标函数为 `_Z3pcmPi`，split 为 `%143`，两臂入口为 `%145` 与 `%unify.bb2`，共同出口为 `%371`。这里的子版本由 Greedy 对同一父 IR 只试融一次 `darm-R2R` 得到。

| 阶段 | R2R 前 | R2R 后 |
| --- | --- | --- |
| 捕获的父 IR／原始发射结果 | [before-r2r.ll](before-r2r.ll) | [after-r2r.ll](after-r2r.ll) |
| 当前 cleanup 后的对照与候选 | [before-r2r-cleanup.ll](before-r2r-cleanup.ll) | [after-r2r-cleanup.ll](after-r2r-cleanup.ll) |
| LLVM 12 O3 后的对照与候选 | [before-r2r-o3.ll](before-r2r-o3.ll) | [after-r2r-o3.ll](after-r2r-o3.ll) |

六份 IR 按原始文件逐字节保存并通过 LLVM 12 verifier。两份 O3 IR 使用发布设置编译到 gfx906（`llc -O3`、`+sramecc,-xnack`、code object v4 和 ROCm 6.3.3 `ld.lld -shared`），所得 HSACO 与运行时采样的两个对象逐字节一致。使用原始父 IR 和原始发射结果各自走一遍完整 O3 编译，也得到相同的两个 HSACO。

| 代码对象 | SHA-256 |
| --- | --- |
| R2R 前 | `35a2c062b54b056a4b3c8e6e513e75abfce5a59edba2e7b1330a21d693a952c1` |
| R2R 后 | `6a0f71b49a5856d08e1d2af6f085b5b0f4865c362c11cd1aee7f2008a747c66e` |

[运行时采样](../pcm32-r2r-runtime-20261120.md) · [IR SHA-256](SHA256SUMS)
