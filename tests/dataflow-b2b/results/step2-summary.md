# Dataflow B2B 第 2 步 Small 档

共尝试 188 个区域，178 个原始区域可以按抽象代价表计费。完备证明数为 0。

在已找到且未出现语义不一致的方案中，54 个区域改善了 D 场景，12 个满足保守策略。表内 best_found_T 是当前候选中的最小 D。语义尚未验证的候选仍保留在原始结果中，所有搜索都保留未完成状态。

## 现有策略

- anchor 的可计费比较为 35，其中 15 个达到当前最佳 D。运行状态为 `{'fusion_rejected': 1, 'no_single_pair': 143, 'ok': 35, 'unsupported': 9}`。
- darm 的可计费比较为 35，其中 6 个达到当前最佳 D。运行状态为 `{'fusion_rejected': 1, 'no_single_pair': 143, 'ok': 35, 'unsupported': 9}`。

## 候选方案特征

- crossed 出现在 0 个已选候选中。
- commute 出现在 10 个已选候选中。
- cmp_swap 出现在 0 个已选候选中。
- shared_select 出现在 2 个已选候选中。
- guard_cluster 出现在 1 个已选候选中。
- speculate_then_select 出现在 14 个已选候选中。

## 最大已观测差距

按计费项分解差值。候选特征的单独贡献尚未做消融验证。

### anchor

- `4f045e74e33a6f957716f7dc10142278050a1d6f` 的 D 差距为 5，候选特征为 speculate_then_select, speculated_operations。代价差构成为 分支 +3、合流 +2、select -2、其余操作 +2。
- `23591531d258bfc66fd4591054cc5128d87e5c3d` 的 D 差距为 3，候选特征为 speculate_then_select, speculated_operations。代价差构成为 分支 +3、合流 +3、select -3。
- `c817e748e8c4c8aa576eb08bb0ca96949c8ae3f2` 的 D 差距为 3，候选特征为 speculate_then_select, speculated_operations。代价差构成为 分支 +3、合流 +2、select -2。
- `e75fbe80b4ef0386c37356e341ab80b0bb8e92a6` 的 D 差距为 3，候选特征为 speculate_then_select, speculated_operations。代价差构成为 分支 +3、合流 +1、select -1。
- `c9ab53d356c757d5f2639ba5cf5ce0dc163ea40e` 的 D 差距为 2，候选特征为 commute, speculated_operations。代价差构成为 select +2。
- `0027035588d14dbe339285c5647c3aada796cf2d` 的 D 差距为 0，候选特征为 speculate_then_select, speculated_operations。
- `05887769be2ea38a215001ebc697799b8c221dae` 的 D 差距为 0，候选特征为 speculate_then_select, speculated_operations。
- `2b64bc2662b89f444fc97b7a1ec87cf682a3ee5c` 的 D 差距为 0，候选特征为 speculate_then_select, speculated_operations。
- `4e627469ecf0bc8214231b010af572680425ffaa` 的 D 差距为 0，候选特征为 speculated_operations。
- `8ab29a70a7e891cbbbaf991ffdcd928f2df81896` 的 D 差距为 0，候选特征为 speculate_then_select, speculated_operations。

### darm

- `ccbf194f80fcbdf6a76a868a15b8fd7a86ac890c` 的 D 差距为 11，候选特征为 shared_select, speculated_operations。代价差构成为 分支 +6、合流 +11、select -6。
- `4e627469ecf0bc8214231b010af572680425ffaa` 的 D 差距为 7，候选特征为 speculated_operations。代价差构成为 分支 +3、合流 +4。
- `b232720fc69b09f3419058ef3b001cbfcaa20508` 的 D 差距为 6，候选特征为 无。代价差构成为 分支 +3、合流 +3。
- `23591531d258bfc66fd4591054cc5128d87e5c3d` 的 D 差距为 3，候选特征为 speculate_then_select, speculated_operations。代价差构成为 分支 +3、合流 +3、select -3。
- `c817e748e8c4c8aa576eb08bb0ca96949c8ae3f2` 的 D 差距为 3，候选特征为 speculate_then_select, speculated_operations。代价差构成为 分支 +3、合流 +2、select -2。
- `e75fbe80b4ef0386c37356e341ab80b0bb8e92a6` 的 D 差距为 3，候选特征为 speculate_then_select, speculated_operations。代价差构成为 分支 +3、合流 +1、select -1。
- `c9ab53d356c757d5f2639ba5cf5ce0dc163ea40e` 的 D 差距为 2，候选特征为 commute, speculated_operations。代价差构成为 select +2。
- `0027035588d14dbe339285c5647c3aada796cf2d` 的 D 差距为 1，候选特征为 speculate_then_select, speculated_operations。代价差构成为 select +3、其余操作 -2。
- `05887769be2ea38a215001ebc697799b8c221dae` 的 D 差距为 1，候选特征为 speculate_then_select, speculated_operations。代价差构成为 select +3、其余操作 -2。
- `2b64bc2662b89f444fc97b7a1ec87cf682a3ee5c` 的 D 差距为 1，候选特征为 speculate_then_select, speculated_operations。代价差构成为 select +3、其余操作 -2。

前沿代表方案的主机验证（含微型测试）为 `{'pass': 41, 'unsupported': 202}`。
