# Anchor 简化 10c：线性与守护布局共享一个 beam

发布线以普通 merge `f7ac69378d8c06fb417f142f3ff732d5ebe0c8f2` 合入 10a 和 10b。合并后的干净构建与发布复验通过。17 个 case 的提交链、最终 IR、TTI 和设备对象与 `6a0e4a6` 一致，发布复验只报 CED 281 > 280。测试 16 项通过、4 项按已知缺件跳过。复验使用 `step9-verify.sh` 和 `step10a-check.py`，结果 SHA-256 为 `44cb6962e6465e35b547d4a085fbc3e8849da5dab0469ef7337d8589f8ee880c`。

10c 从该合并提交快进 `refactor/anchor-simplify` 后开始。第 10b 步覆盖当前轨迹上的 2,103 个 Anchor B2B 请求与 7,698 个布局，raw、cleanup 后 IR 和评分均与迁移前一致。这组回执用来定位本步的候选与提交差异。 [10b 记录](anchor-simplify-step10b-20261122.md)

## 实现

- `tools/b2b_anchor.cpp`／`planB2BAnchors` 删除按是否允许守护分别保存的两个线性投影。单个线性 beam 沿用原可守护投影的跳过合法性、分数、宽度 4、段尾裁剪、anchors-only 路径和退出报价。无守护布局仍可从这个 beam 中胜出。
- `tools/b2b_anchor.h` 删除 `AnchorScoring` 和 `guardedProjection`。
- `tools/fusion_search.cpp`／`planSingleBranchB2B` 保留独立的 fork 搜索，线性搜索直接读取单一 beam 的方案，按实际是否存在守护 gap 标记布局。strict 和 relaxed 仍分别运行。发射器、cleanup、逐 wave 分类及一致代价 gate 沿用合并后的实现。
- `tests/fusion-search/check-b2b-anchor-segments.cpp` 改用单一 beam，继续检查已有的报价、cutoff、guard placement 与守护代价。双投影等价断言已删除。

不含本记录，净减少 **62 行**。

## 构建与回归

实验目录为 EPYC 的 `/data/home/chh/simplify-v2/build/anchor-simplify-step10c.4XnUzI`。LLVM12 重新构建，使用与合并起点一致的固定 LLVM24 throughput worker。

```sh
bash step9-build.sh "$STAGE"
bash test-anchor-step1.sh "$STAGE/source" step10c
python3 step10c-matrix.py "$STAGE" "$BASELINE"
python3 step10c-audit.py "$STAGE" current "$BASELINE"
python3 step10c-audit.py "$STAGE" historical "$BASELINE"
python3 step10c-rebuild.py "$STAGE" "$BASELINE"
python3 step10c-trace.py "$STAGE" "$BASELINE"
python3 step10c-gpu.py "$STAGE"
```

逐 case 使用发布 manifest 里的冻结输入和确切形状，运行完整 Greedy 与 LLVM verifier。比较 10b 合入后的静态回执和设备对象。IR 字节相同的对象沿用原编译产物，变化的 IR 用同一后端重建。IR 有变化时比较两套完整提交链，并在共同父 IR 上重新发射旧、新选中候选的全部布局，按 cleanup 后 IR 字节识别布局，避免把编号变化当成布局消失。

17 个 case 的 358 次提交、最终 IR、TTI 及重建设备对象均与合并起点一致。没有产物改变的 case。回归测试 16 项通过，4 项按 `tests/KNOWN_FAILURES.md` 跳过。沿用冻结旧 D 对照，仍只有 CED 281 > 280。

| 同父重放矩阵 | 请求数 | 布局数 | 新增／消失布局 | 评分差异 | 所选 IR 差异 | 所选编号差异 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 当前 17 个 case | 2,103 | 7,698 | 0／0 | 0 | 0 | 1 |
| 第 10b 步的历史父态 | 6,253 | 22,243 | 0／0 | 0 | 0 | 3 |

在同父重放中按布局类型与 cleanup IR 哈希的多重集合查找对应方案，再核对完整评分。两组共 8,356 个请求和 29,941 个布局。历史父态按其在 D、G0、G1 轨迹上的出现次数计数。

当前轨迹唯一可见的所选编号变化是 LUD8 第 1 次提交，`trial-0`，块对 `B0:B1:B2`。旧 `b2b-anchor-9`、新 `b2b-anchor-10` 都是 relaxed linear，cleanup 后 TTI 都为 666，IR 哈希均为 `91a2688ca2e29323ccb9ad41492a001982614e5d4c0ef2702e9fc58c295733ef`。旧布局按无守护、可守护投影分组，新线性方案按 strict、relaxed 发出。原本在两条 relaxed linear 之后的 strict guarded-linear 移到它们之前，净效果是编号变化。重放中没有发现剪枝导致的布局丢失。

## GPU 复验

22 个冻结计时场景的设备对象都匹配合并起点，全部作为已测对象的别名。本步无新增 GPU 测量。

## 回执

| 工件 | SHA-256 |
| --- | --- |
| `matrix.json` | `8c8917e8d7d7e6ea5d7f4395a8b50e32e4449c0c1e494724ac53573512234ee6` |
| `rebuilt.json` | `8dbbbc9e9817c7c52180f7dbcb63bf15d5b4e907f7c1b4a7435d2453b6084f51` |
| `tests.log` | `518e22f00321dd03c0932c0a9d01d817f71943e4ee8ab17cb1d444aaea61f388` |
| `audit-current/summary.json` | `c094fa8c191500395d3e137f864854ebe76bec7fb3abbc4c4ee8fcd417a91a6b` |
| `audit-current/rows.jsonl` | `faebb96f1a5f3c8f888d3e836259da9ec5d5577826e1000cf1287cf005087e72` |
| `audit-historical/summary.json` | `765be4f1dc338c294de4d7ed1db8dcfe69dd3d9de07c9fb2ca0dd91ee38d1f85` |
| `audit-historical/rows.jsonl` | `0583390078cd6a35bd641e7db81dcd58f0d39e57f3cd3a5be2f98e82baabf423` |
| `gpu/results.json` | `1ea64e081205b2e8d4fb553a1ce41cd009661acd5b85fe6fee8fabf984f182e5` |
| `changed-layout-number/result.json` | `07ba45a35a6d17dd25ffad0b8ebc2ffd2a7bd008d5d4f3cc36fd32229d001734` |
| `build/decision-fuse/decision-greedy` | `5bba10ee9fcfa4781fd3c4af120172df8fc602728edd99567bd553703ac1c97e` |
| `build/llvm24-tti/fusion-search-llvm24` | `bdaee160498a13ff735f2b50124737e133870cc7f74cba231d2180bea5f8a0fc` |
| `build/llvm24-tti/llvm24-tti` | `6115d44b163ad87f564fcf6fca0e9b5b983c2139e56dd22a74bc289f5604658a` |
