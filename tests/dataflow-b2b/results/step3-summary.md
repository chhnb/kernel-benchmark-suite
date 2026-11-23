# Dataflow B2B 第 3 步

Small 档共 188 个区域。完备枚举 0 个。

仅统计通过语义差分的前沿代表，D 场景改善 75 个，按 §7.2 策略改善 38 个。

已验证的当前最佳代表特征计数为 `{'cmp_swap': 0, 'commute': 14, 'crossed': 1, 'guard_cluster': 1, 'multiple_guards': 0, 'paired_memory': 13, 'shared_select': 2, 'speculate_then_select': 14, 'speculated_operations': 43}`。

K=1、3、10 相对当前搜索已观测的最低 D 漏掉的区域数依次为 18、6、4。全局最优漏失率仍待完备搜索。

语义验证（含微型测试）为 `{'pass': 253}`。

清理一致性（含微型测试）为 `{'changed': 199, 'unchanged': 54}`。
可观测差异类别为 `{'PHI 或 select 变化': 21, '分支或块折叠': 81, '块布局、操作数或标志变化': 92, '访存或地址计算变化': 5}`。

## 与现有工具的比较

- anchor `{'ok': 44, 'rejected': 144}`。33 个与通过语义验证的当前最佳 D 相等。
  - `4f045e74e33a6f957716f7dc10142278050a1d6f` 的 D 差为 5。计费项差值为 control +3、escape +2、instruction +4、select -4，候选特征为 crossed、speculate_then_select、speculated_operations。
  - `23591531d258bfc66fd4591054cc5128d87e5c3d` 的 D 差为 3。计费项差值为 control +3、escape +3、select -3，候选特征为 speculate_then_select、speculated_operations。
  - `4691ec0c105801022e72f775009d892015e9257c` 的 D 差为 3。计费项差值为 control +3、escape +1、select -1，候选特征为 speculate_then_select、speculated_operations。
  - `c817e748e8c4c8aa576eb08bb0ca96949c8ae3f2` 的 D 差为 3。计费项差值为 control +3、escape +2、select -2，候选特征为 speculate_then_select、speculated_operations。
  - `e75fbe80b4ef0386c37356e341ab80b0bb8e92a6` 的 D 差为 3。计费项差值为 control +3、escape +1、select -1，候选特征为 speculate_then_select、speculated_operations。
  - `c9ab53d356c757d5f2639ba5cf5ce0dc163ea40e` 的 D 差为 2。计费项差值为 select +2，候选特征为 commute、speculated_operations。
  - `cdd7f2ba84a3d0dd73db35b0acafcee20442d513` 的 D 差为 2。计费项差值为 select +2，候选特征为 commute、speculated_operations。
  - `daa252c4257499441151e25b02ea63f077d199de` 的 D 差为 2。计费项差值为 select +2，候选特征为 commute、speculated_operations。
  - `74fc20b5ec4ff611c3d438a6e45703c11b787a62` 的 D 差为 1。计费项差值为 select +1，候选特征为 commute、speculated_operations。
  - `0027035588d14dbe339285c5647c3aada796cf2d` 的 D 差为 0。计费项差值为 instruction +2、select -2，候选特征为 speculate_then_select、speculated_operations。
- darm `{'ok': 44, 'rejected': 144}`。12 个与通过语义验证的当前最佳 D 相等。
  - `ccbf194f80fcbdf6a76a868a15b8fd7a86ac890c` 的 D 差为 11。计费项差值为 control +6、escape +11、select -6，候选特征为 shared_select、speculated_operations。
  - `4e627469ecf0bc8214231b010af572680425ffaa` 的 D 差为 7。计费项差值为 control +3、escape +4，候选特征为 speculated_operations。
  - `b232720fc69b09f3419058ef3b001cbfcaa20508` 的 D 差为 6。计费项差值为 control +3、escape +3，候选特征为 无。
  - `338511bb95c6d7311ca350674fe52dd48589309d` 的 D 差为 4。计费项差值为 control +3、escape +5、select -4，候选特征为 commute、paired_memory。
  - `9fe145d5cce8de6688df7d0a78164b828ff938fe` 的 D 差为 4。计费项差值为 control +3、escape +5、select -4，候选特征为 commute、paired_memory。
  - `1bae2080fbe9064b81804403e6d26813359c003f` 的 D 差为 3。计费项差值为 control +3、escape +42、select -42，候选特征为 无。
  - `23591531d258bfc66fd4591054cc5128d87e5c3d` 的 D 差为 3。计费项差值为 control +3、escape +3、select -3，候选特征为 speculate_then_select、speculated_operations。
  - `45bc4cdfb47bf94438198a9120620367a6703b14` 的 D 差为 3。计费项差值为 control +3、escape +5、select -5，候选特征为 commute、paired_memory。
  - `4691ec0c105801022e72f775009d892015e9257c` 的 D 差为 3。计费项差值为 control +3、escape +1、select -1，候选特征为 speculate_then_select、speculated_operations。
  - `62757562d59442359ede2d9c8c87398c6b28391a` 的 D 差为 3。计费项差值为 control +3、escape +5、select -5，候选特征为 commute、paired_memory。

逐区间的拒绝原因、oracle 和语义状态见原始 JSON。
