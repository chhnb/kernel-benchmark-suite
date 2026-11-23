# Dataflow B2B 第 3b 步

差距与 K 漏失只在不变式通过且标为完备的区域上统计。清理代价变化按方案逐条列出。

## diamond

区域 45 个，完备且通过不变式 44 个。

- 已验证方案中 D 收益 43 个，收益区域平均 5.023。
- §7.2 策略收益 24 个，收益区域平均 5.625。
- anchor 达到最优 D 的区域数为 34，差距分布为 `{0: 34, 1: 1, 2: 3, 3: 4, 5: 1, 11: 1}`，计费项差距合计为 `{'control': 18, 'escape': 10, 'select': -21, 'instruction': 28}`。
- darm 达到最优 D 的区域数为 15，差距分布为 `{0: 15, 1: 11, 2: 3, 3: 10, 4: 2, 6: 1, 7: 1, 11: 1}`，计费项差距合计为 `{'control': 48, 'escape': 139, 'select': -109, 'instruction': 1}`。
- 特征计数 `{'cmp_swap': 0, 'commute': 14, 'crossed': 1, 'guard_cluster': 0, 'multiple_guards': 0, 'paired_memory': 13, 'shared_select': 2, 'speculate_then_select': 15, 'speculated_operations': 25}`。
- K=1、3、10 漏失数依次为 18、6、4。
- 清理分类 `{'text_only': 66, 'unchanged': 7}`。

### 不变式

状态统计 `{'pass': 44, 'unpriced': 1}`。
- `b670a987cbd0b880da2265106c8e56fc5708a607`。无法计价。unsupported: missing abstract cost for call。

### 清理导致 T 改变

无。

## triangle

区域 143 个，完备且通过不变式 143 个。

- 已验证方案中 D 收益 35 个，收益区域平均 2.943。
- §7.2 策略收益 16 个，收益区域平均 2.875。
- anchor 达到最优 D 的区域数为 108，差距分布为 `{0: 108, 1: 1, 3: 34}`，计费项差距合计为 `{'control': 102, 'escape': 123, 'select': -122, 'instruction': 0}`。
- darm 达到最优 D 的区域数为 108，差距分布为 `{0: 108, 1: 1, 3: 34}`，计费项差距合计为 `{'control': 102, 'escape': 123, 'select': -122, 'instruction': 0}`。
- 特征计数 `{'cmp_swap': 0, 'commute': 0, 'crossed': 0, 'guard_cluster': 1, 'multiple_guards': 0, 'paired_memory': 0, 'shared_select': 0, 'speculate_then_select': 0, 'speculated_operations': 20}`。
- K=1、3、10 漏失数依次为 0、0、0。
- 清理分类 `{'cost_changed': 14, 'text_only': 104, 'unchanged': 45}`。

### 不变式

状态统计 `{'pass': 143}`。

### 清理导致 T 改变

- `17286707f6a1af5aa7eac5833a6af1084e7709a5/0.ll` [14, 14, 4] → [14, 14, 3]，CFG/guard、memory/address、instruction。
- `2b976b5426a5f36afd993842023f5f2097bc20e2/0.ll` [25, 4, 25] → [25, 3, 25]，CFG/guard、memory/address、instruction。
- `30e09200efbbedf868f9689e744696482ef8e1f3/0.ll` [14, 14, 4] → [14, 14, 3]，CFG/guard、memory/address、instruction。
- `30e459dd8ef55bf1e0717581cb43eee8b1f0f690/0.ll` [14, 14, 4] → [14, 14, 3]，CFG/guard、memory/address、instruction。
- `51a69063fa56a53c4985062271bdc5ab1395a72f/0.ll` [18, 18, 5] → [18, 18, 4]，CFG/guard、memory/address、instruction。
- `5ad75595a54055f22adb767581fe105ce675db2d/0.ll` [14, 14, 4] → [14, 14, 3]，CFG/guard、memory/address、instruction。
- `7641d63f4121df655843201de674e83fa10de46c/0.ll` [18, 18, 5] → [18, 18, 4]，CFG/guard、memory/address、instruction。
- `86b2ec3336e75e725c55ceba799ff6567751c53d/0.ll` [26, 4, 26] → [25, 3, 25]，CFG/guard、memory/address、instruction、GEP elimination。
- `8b7c06e2e980dc9d1b12e47efe594301649d8eb7/0.ll` [26, 4, 26] → [25, 3, 25]，CFG/guard、memory/address、instruction、GEP elimination。
- `952f6b0074a00f9711de394dac070d814eaaf973/0.ll` [25, 4, 25] → [25, 3, 25]，CFG/guard、memory/address、instruction。
- `d279fa254daa54bb8588deb249d9dce4b906e9b4/0.ll` [25, 4, 25] → [25, 3, 25]，CFG/guard、memory/address、instruction。
- `d81586fea853e6e4e2d6ca8924c28b1c6441ba84/0.ll` [18, 18, 5] → [18, 18, 4]，CFG/guard、memory/address、instruction。
- `e11e2989e6dfa2581abacc216755cd35bf361a16/0.ll` [18, 18, 5] → [18, 18, 4]，CFG/guard、memory/address、instruction。
- `eb37b9c1c50e49e1dc0539117b7a9437118a7c4a/0.ll` [26, 4, 26] → [25, 3, 25]，CFG/guard、memory/address、instruction、GEP elimination。

## 指定回归

| 区域 | 求解器 D | anchor D | darm D |
|---|---:|---:|---:|
| `d23a7c228c5b` | 16 | 27 | 16 |
| `2f29337da1ee` | 2 | 2 | 2 |
| `e37272cdb93e` | 4 | 4 | 4 |

逐方案完整 IR diff 和前后计价见原始 JSON。本次清理的具体计费原因及待确认闭包规则见[运行记录](../../../regression/records/dataflow-b2b-step3b-20261123.md#清理导致的代价变化)。
