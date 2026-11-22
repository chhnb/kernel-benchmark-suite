# Anchor 简化 10b：统一 fork 布局的发射

改动起点为 `refactor/anchor-simplify` 的 `6df9412e89b466d789c202ad86ab316f9e7bf61a`，整体验收对照为 `feature/anchor-default` 的 `6a0e4a6f14df26d355176d43f922726e57e9b75a`。

## 改动

| 文件／函数 | 改动 |
| --- | --- |
| `tools/fusion_search.cpp`，`planSingleBranchB2B` | 保留原规划、候选顺序、编号及评分。将 segmented 的配对间空段和尾段标为整段守护，按原 CFG 区分共同出口与独立出口。before-split 指定保留后缀，merged-exit 指定合并两臂出口。三类均调用 `emitB2BLinear` |
| 同文件，`emitB2BLinear` | 共用配对指令、条件选择、gap 扫描和守护块发射。原 segmented 的克隆值映射、互补 poison PHI 配对、尾段直达 join 及独立出口前驱保留在同一发射器。守护块名、基本块顺序和 PHI incoming 顺序沿用各布局原表示 |
| 同文件，`emitB2BSegments` | 删除整个函数及其局部 `preserve`、`consume` 实现。无配对的已有方案仍按原入口保留父 IR |
| `tools/fusion_search.h` | 用 `B2BExit` 标明保留后缀、合并出口、守护尾段后汇合及保留独立出口四种出口方式 |
| `tests/fusion-search/check-b2b-linear-emitter.cpp` | 测试调用改用同一套出口表示。保留原 PHI、poison／undef、访存顺序、IR verifier 和 CPU 结果核对 |

不含本记录，总计新增 140 行、删除 209 行，净减少 **69 行**。

## 逐布局重放

实验目录为 EPYC 的 `/data/home/chh/simplify-v2/build/anchor-simplify-step10b.XlTs8M`。同一请求的两个版本用同一个 `parent.ll` 路径读取相同父 IR，传入相同候选块 ID、确切 workgroup 形状、固定 LLVM24 throughput worker 及默认 cleanup。用现有 `FUSION_OBSERVE_B2B_DP` trace 导出 raw IR、cleanup IR 和所有布局评分，包括常规搜索会去重的布局。对比原字节及完整逐布局评分和回执；两个版本均使用同一种 trace 配置。

先覆盖每个 case 的前十个请求或其全部请求（不足十个时），共 137 个，三类 fork 均通过。随后覆盖当前 17 个 case 的全部 Anchor B2B 请求，再用第 6b 步的旧 D、G0、G1 父态请求补充覆盖。历史矩阵只用于提供冻结父 IR 与候选位置，两个构建均使用当前默认进行重放；按请求出现次数计数，不把相同请求在不同轨迹中的重复出现标为新的唯一请求。

```sh
bash step9-build.sh "$STAGE"
python3 step10b-audit.py "$STAGE" probe
python3 step10b-audit.py "$STAGE" current
python3 step10b-audit.py "$STAGE" historical
bash step9-verify.sh "$STAGE"
bash test-anchor-step1.sh "$STAGE/source" step10b
python3 step10a-check.py "$STAGE"
```

| fork 布局 | 当前 17 个 case 出现数 | raw IR 差异 | cleanup 后 IR 差异 | 评分差异 |
| --- | ---: | ---: | ---: | ---: |
| segmented | 1,852 | 0 | 0 | 0 |
| before-split | 1,741 | 0 | 0 | 0 |
| merged-exit | 1,035 | 0 | 0 | 0 |

当前矩阵覆盖 **2,103** 个请求、**7,698** 个布局。未观察到块名、块顺序、PHI 顺序、前驱注释或其他 raw 字节差异。三类布局均通过并进入统一发射路径。

扩展历史矩阵覆盖 **6,253** 个请求、**22,243** 个布局。其中 segmented、before-split、merged-exit 分别出现 5,073、4,986、3,162 次。raw、cleanup 后 IR、评分与所选布局均一致。当前和历史两组共重放 8,356 个请求。

| Case | segmented | before-split | merged-exit |
| --- | ---: | ---: | ---: |
| CED | 8 | 4 | 0 |
| HiPIMS-George | 5 | 20 | 0 |
| HLLD | 2 | 20 | 1 |
| Landau | 449 | 113 | 2 |
| LUD8 | 10 | 4 | 0 |
| MapAiry | 259 | 181 | 2 |
| MS32 | 0 | 8 | 2 |
| NQU64 | 1 | 6 | 0 |
| PCM32 | 33 | 97 | 32 |
| SasPoint5 | 68 | 17 | 15 |
| SRAD-stage2 | 7 | 3 | 0 |
| SRAD16 | 26 | 7 | 0 |
| SRAD32 | 26 | 7 | 0 |
| SW2D | 8 | 4 | 0 |
| tigre | 15 | 5 | 0 |
| TPACF | 359 | 309 | 309 |
| vllm | 576 | 936 | 672 |

## 发布复验

与 `6a0e4a6` 对照，17 个 case 的完整提交链（358 次提交）、最终 IR、最终 TTI 和设备对象哈希均一致。逐项比较了完整 Greedy 记录的 3,011 个候选和输出。DARM 已登记白名单使用 1 次，白名单外差异为 0。

- HLLD `trial-23`，父 IR `162a59fd16e55a76dfb488b5361549df3adfd3d3712657def52b6c3cd06b504f`。候选从 `4187ad0d4f4310521ae6fc5d893ff3bca1ba344cd9ebb38e74897313b509cf52`（TTI 1805）变为 `0e732f1488ffebc94e1cab72ce0daf9d19c9da29756f28e2837e1dccff9fee3e`（TTI 1804）。

发布复验只报警 **CED 281 > 280（+1）**。LUD8 另用第 8 步的专用后端重建设备对象，哈希与起点一致。回归测试 **16 项通过、4 项按 `tests/KNOWN_FAILURES.md` 跳过**。

## 回执

| 工件 | SHA-256 |
| --- | --- |
| `verified/results.json` | `44cb6962e6465e35b547d4a085fbc3e8849da5dab0469ef7337d8589f8ee880c` |
| `rebuilt-lud8/results.json` | `bebc4ea3d3442d38c8a37de598c271157b06fb8d83ae4944813c0d22f5c137bc` |
| `comparison.json` | `3710825fb09a1f817120eb329d0eaf742ab3dbc979fcc82e1eea162d554f26d4` |
| `audit-current/summary.json` | `b84c350e0446f466121de0dcdf8cf32d738745b3ee15d5070620d0b3ce2fb238` |
| `audit-current/rows.jsonl` | `d7cf950a6bc53a1833c93118b67b0e4d4c933134207c4eb2f230855447c2db2e` |
| `audit-historical/summary.json` | `b5da9bbb1a273b78cc0a8fa96416397ee762633c4e889d4dd3a5203386c3cf86` |
| `audit-historical/rows.jsonl` | `acddaca66f2b0615f727d7f4d14c36c42d65383770c2163d59c9cfd17c6b3379` |
| `tests.log` | `518e22f00321dd03c0932c0a9d01d817f71943e4ee8ab17cb1d444aaea61f388` |
| `build/decision-fuse/decision-greedy` | `655b9d6d577267bd4fefc564aca08834db8a55268bedb7b0b27d3373fac73ad8` |
| `build/llvm24-tti/fusion-search-llvm24` | `9dd02fccb8a3e7b383457b771668323822248f558a8c2c69d739a430f965176f` |
| `build/llvm24-tti/llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |

## 下一步判断

本步将 fork、线性和守护方案交给同一发射器，保留规划器的原有投影和排序。下一步若改变规划器，应独立评估候选集合、提交轨迹和产物变化，以本步逐布局字节及评分回执为参照。
