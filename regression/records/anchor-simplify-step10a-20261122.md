# Anchor 简化 10a：移除 legacy 运行模式

起点为 `feature/anchor-default` 的 `6a0e4a6f14df26d355176d43f922726e57e9b75a`。本步在 `refactor/anchor-simplify` 上完成。

## 改动与行数

| 文件／函数 | 改动 | 净行数 |
| --- | --- | ---: |
| `tools/decision_greedy_main.cpp`，命令行入口、trial 参数构造 | 删除 `--anchor-mode` 的帮助、解析、形状提示特例和 worker 参数转发 | −5 |
| `tools/fusion_search_llvm24_main.cpp`，`runSearch` | 删除 legacy 解析和不启用 gate 的分支。按新默认原顺序计算逐布局报价、gate、cleanup IR 去重及最优布局。R2R 先尝试受限推测，gate 拒绝时仍走普通 R2R | −17 |
| `tools/b2b_anchor.h`、`tools/fusion_search.h`、`tools/llvm24_scorer.h`、`tools/fusion_search.cpp`，`planAnchorB2B`、`planSingleBranchB2B`、`emitB2BLinear` | 删除 `AnchorGap` 模式传递和 legacy 专用的 `preserveLegacyFreeze` 分支。默认候选仍包含 fork、线性和守护布局，fork 继续使用原先的分段发射器 | −12 |
| `regression/verify_anchor_release.py`，`verify_profiles` | 只运行当前默认。报警由默认 TTI 与 manifest 中旧 D 的 TTI 比较。JSON 报告旧 D 的冻结 profile 及两者的 IR 哈希是否相同 | −5 |
| `tests/fusion-search/check-b2b-linear-emitter.cpp` | 删除专门要求 legacy 前缀插入 freeze 的断言。默认的 poison／undef、守护、PHI 和访存顺序测试保留 | −9 |
| `tests/fusion-search/check-b2b-anchor.py`、`check-single-branch-b2b.py`、`observe-b2b-anchor.py` | 改为走当前默认。布局上限单独核对 fork 组。用现有 trace 观察被 cleanup 去重的 merged-exit 布局，保留原顺序断言 | +4 |
| 发布 manifest、README、回归 README、STATUS、KNOWN_ISSUES | 去掉已删除模式的调用说明，旧默认 D 改用构建 `c7dded07` 复现 | −3 |
| 合计，不含本记录 | 工具源码 −34，测试 −5，复验脚本 −5，manifest 与文档 −3 | **−47** |

`compile_kernel.py` 在起点未解析或传递该选项，无需改动。7f 记录中的旧开关只属于历史复现命令，保留原文。

manifest 的 `anchor_profiles.legacy` 已覆盖全部 17 个 case。逐项核对了旧 D 的提交数、最终 TTI 和 IR 哈希，均与第 8 步的旧 D 回执一致，所有已有设备对象哈希也一致。第 4 步的 D 是旧结果的最初记录，第 8 步已用 `c7dded07` 重放并登记这些冻结值。本次仅将模式说明替换为参考提交字段，原始输入、参考归档及各 profile 数值均保留。 [第 4 步](anchor-unified-dp-step4-20261122.md) · [第 8 步](anchor-unified-dp-step8-20261122.md)

## 构建与验证

复验目录为 EPYC 的 `/data/home/chh/simplify-v2/build/anchor-simplify-step10a.EYKDom`。

| 工件 | SHA-256 |
| --- | --- |
| `build/decision-fuse/decision-greedy` | `d5399420e19d718a4d9487ab0b089891a11c62c0a2d1e48a37b7547734d93ef4` |
| `build/llvm24-tti/fusion-search-llvm24` | `97e425db5abae8dfb4dcef5516c09ab43fff5a94a4de5862b541ec141dabcb49` |
| `build/llvm24-tti/llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |

从起点拆出当前工作树，在 EPYC 新目录编译 LLVM12 结构搜索与 Greedy driver，使用固定 LLVM24 worker。初次 driver 编译发现删除旧分支后形状转发处留有孤立的 `else if`。转为独立的 `if` 后重新构建。原发布构建与当前构建使用相同的冻结输入、确切 workgroup 形状和设备后端。

```sh
bash step9-build.sh "$STAGE"
bash test-anchor-step1.sh "$STAGE/source" step10a
bash step9-verify.sh "$STAGE"
python3 step10a-check.py "$STAGE"
```

`step9-verify.sh` 调用 `python3 regression/verify_anchor_release.py --tool-root . --out "$STAGE/verified" --jobs 12`。LUD8 另用第 8 步的专用 ROCm 4.2 后端重建设备对象。首次将旧测试直接切到当前默认时，旧断言把当前所有布局都限制在 fork 的 9 个布局内，而且常规回执已经去重了与 before-split 相同的 merged-exit。改用逐布局 trace 并对 fork 单独计数后，继续检查原有断言。

17 个 case 的完整提交链（358 次提交）、最终 IR、最终 TTI 和设备对象哈希均与 `6a0e4a6` 一致。逐项比较了 3,011 个实际试融回执，其中 2,103 个 Anchor B2B 请求共记录 6,681 个布局评分。所有候选 cleanup 后 IR 与评分一致，本次未用到 DARM 非确定性白名单。

发布复验只报警 **CED 281 > 280（+1）**，SasPoint5 为 **491 = 491**。LUD8 专用设备对象哈希匹配起点，缺形状的同父 guarded-linear gate 检查也通过。回归 **16 项通过、4 项按 `tests/KNOWN_FAILURES.md` 跳过**，四项为 `condition`、`pair-trial`、`regions`、`similarity`。

| 工件 | SHA-256 |
| --- | --- |
| `verified/results.json` | `44cb6962e6465e35b547d4a085fbc3e8849da5dab0469ef7337d8589f8ee880c` |
| `rebuilt-lud8/results.json` | `eb9d5c283fd9f79cba9a47634e6b8b1d5fb9d8bdec25eb7f9a314e9a83b2ebb1` |
| `comparison.json` | `5529e31d60e95d05ba4c83a635abce2d1bfcf237288983d61f1979a5c4650a9c` |
| `tests.log` | `518e22f00321dd03c0932c0a9d01d817f71943e4ee8ab17cb1d444aaea61f388` |
| `verify.log` | `ec10a01126e1857313c905f9904b43b1e7a27a58473435af4eb46d9ae97f0031` |
| `compare.log` | `12444ddbe45ee032703622bab89f4804f168edacbbbb8bd980e9bf66c955d2f5` |

## 下一步判断

10b 的验收应从同父 IR 的所有 fork 布局逐个比较 cleanup 后字节与评分。保留本步建立的提交链和设备对象对照，遇到白名单外差异定位到具体布局后再决定是否能替换旧发射路径。
