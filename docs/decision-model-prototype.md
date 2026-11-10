# 统一 Decision/Arm：只读发现与短路规范化原型

状态：实验入口，默认搜索不使用。LLVM 12；生产搜索、TTI 和生产回归命令未改。

最新进展：已增加独立 decision-fuse，支持组与叶子、组与组递归融合；完整树结果见[融合实验](decision-fusion-full-trees-20261110.md)，单次 IR 见[对比](vllm-first-pair-ir-comparison-20261110.md)。下面只读与规范化部分描述的是第一阶段。

## 主线目标与本次边界

统一的是“决策、分支边界、候选来源和递归身份”，不是按 case 选择新引擎。
本次完成独立的发现器、旧候选结构对照、相邻 else-if 短路规范化及测试。
后续仍需把实验规范化接到生产 tryPair；独立 driver 已复用 RegionMelder 验证 B2B 和受限制的 SESE 锚点融合。

新增文件：

- `tools/decision_model.h/.cpp`：数据模型、只读发现、规范化。
- `tools/decision_compare.h/.cpp`：与现有 B/R/E/G catalog 的结构对照。
- `tools/decision_model_main.cpp`：独立 C++ CLI。
- `tools/build-decision-model`：LLVM 12 构建入口。
- `tests/decision-model/`：LLVM IR fixture 和执行等价测试。

没有修改原搜索代码，也没有合入审查中的 0001–0004 补丁。
只读工具不链接那四个补丁。新增融合工具仅在临时 engine 副本应用随提交提供的 speculation API 子集，不修改生产引擎与 CLI 默认值。

## 使用

在项目根目录：

```bash
bash tools/build-decision-model
build/decision-model/decision-model input.ll function > decisions.json

# 第 0 个决策中，第 0 和第 1 个 Arm：只规范化，不融合、不清理。
# 输出文件必须不存在。失败只丢弃克隆，不写出候选 IR。
build/decision-model/decision-model input.ll function 0 0 normalized.ll > after.json

# 与旧枚举器同一份输入、cleanup none 的 catalog 对照。
build/decision-model/decision-model input.ll function --compare catalog.json > comparison.json

python3 tests/decision-model/run.py
```

可用 `LLVM_CONFIG`、`CXX` 覆盖构建工具；执行测试用 `CLANG` 指定 LLVM 12 clang。
测试 Python 只负责调用编译器与比较输出；发现和变换全部是 C++。

## 数据定义与发现规则

Arm 保存 entry、完整块集合、到决策 join 的出口来源列表、路径边约束、分类、拒绝原因和原始叶子来源。
不假定一个 Arm 只有一个末尾块。共同 join 不计入 Arm 的工作量。

分类为 Linear / SESE / Unsupported。直线块链属于 Linear；内部有分支但满足边界条件属于 SESE。
当前保守拒绝带副作用、提前返回、循环回边、跨循环作用域、非普通终结指令、地址被取用、重叠块等结构。
规范化还保守拒绝含 convergent 调用的整个函数，避免改变汇合结构影响跨 lane 操作。

从每个条件 br 或 switch 建立一个决策视图，依据后支配关系确定 join。
仅展开由条件计算组成的判断块；识别不代表允许提前执行条件。
条件切片可以包含 load，但规范化保持它原来的短路执行位置。
同一个 switch 的多个标签指向同一目标时归为一个 Arm，记录多条谓词边选择。

JSON 里的 successor 是原始终结指令的后继编号。单侧判断链把终止叶子排在继续判断之前，不受谓词取反影响；
两侧都是子判断的树使用 true 边优先顺序，switch 使用 IR 后继顺序；不声称恢复 C++ 源码顺序或数值区间顺序。
工具保留嵌套决策视图，所以跨决策统计的 Arm 数不是唯一源码叶子总数。

只读发现不写元数据。未标记 IR 的 ID 只对该快照有效。
规范化在克隆中给原块写入 `decision.origin`，新分支写入 `decision.merged_from`；
再次规范化时来源列表展开为原始叶子列表，而不是丢失上一步历史。
尚未实现任意 O3 之后的可靠身份重绑定，也未替代旧 LogicalRegionState。

## 实际生成的短路结构

原结构：

```llvm
x:
  br i1 %c0, label %a, label %y
y:
  ; 第二个条件的计算，包括必须受短路保护的 load / division
  br i1 %c1, label %b, label %rest
```

规范化：

```llvm
x:
  br i1 %c0, label %gate, label %y
y:
  ; 原位置保留条件计算
  br label %gate
gate:
  %was_left = phi i1 [true, %x], [false, %y]
  %take = phi i1 [true, %x], [%c1, %y]
  ; y 中跨块使用的值另建 phi [undef, x], [原值, y]
  br i1 %take, label %dispatch, label %rest
dispatch:
  br i1 %was_left, label %a, label %b
```

两个 Arm 到原 join 的边经 `SplitBlockPredecessors` 改到独立的 pair join，
原 join 的相关 PHI 值在新 join 汇总。

这里用 `%was_left` 记录实际走过的边，不重复读取 `%c0`。
如果 `%c0` 是 undef，重复读取不能保证和第一次分支选择一致。
桥接 PHI 的 undef 只能出现在原来不会访问对应值的路径上；执行测试专门覆盖了这一点。

在普通可终止 CFG 中 gate 是两个入口路径的结构汇合点。
这不是 GPU 硬件调度或同步保证；尚未用它证明跨 lane 操作安全。

重识别不仅看原 root 的直接后支配点：该点可能已经变成 gate。
工具沿有标记且结构校验通过的短路 gate 链找到真正的决策 join，
把 tagged dispatch 到 join 的范围作为一个 SESE Arm。
它不会仅凭元数据把任意 CFG 当成合法 gate。

## 对照表的含义

旧 B/R/E/G 单元先还原成块集合，再与新 Arm 范围比较：

| 分类 | 含义 |
|---|---|
| exact_adjacent | 两侧完整对应新决策的一对相邻 Arm |
| nonadjacent | 完整对应，但不是该视图中的相邻 Arm |
| partial_arm_units | 旧单元只是两个 Arm 各自的一部分 |
| unsupported_arm | 范围对应，但新发现器标记为暂不支持 |
| no_same_decision | 未在当前发现结果中找到同一决策内的对应范围，需要进一步分析 |
| unresolved_old_unit | 无法还原旧 ID，不能据此声称覆盖 |

对照不证明合法性或收益。`no_same_decision` 也不等同于旧候选错误。
新候选表还会标记是否在旧 catalog 中有完整范围匹配。
当前 G 映射按旧协议解析范围，没有导入旧融合历史。

## 验证及尚未完成的验收

CPU 执行测试对每个输入逐一比较，不只比较总和：

- 普通四路链；第一和第二个判断分别反向。
- 条件保护的整数除法：跳过时不执行可能除零的指令。
- 条件保护的 load：跳过时不解引用空指针。
- 五种 fixture 连续两轮规范化、重新发现和来源列表校验。
- switch 别名标签归并。
- 提前返回、volatile store、convergent 调用拒绝，且不写出输出文件。

每种执行 fixture 覆盖整数输入 -100 到 100，共 201 个值；不能当作形式化证明。

Map-Airy、vLLM、TIGRE、Hypersonic 的真实 IR 已做只读扫描与旧 catalog 对照，
各选择一对完成规范化和 verifier。原始输入 SHA256 不变。
初次扫描只做 IR 检查。随后 Map-Airy 和 vLLM 的规范化专项 GPU 验收见
[GPU 验收记录](decision-normalization-gpu-20261110.md)；TIGRE 和 Hypersonic 尚未做这项 GPU 验收。

下一阶段必须继续完成：

1. 对关键源码叶子核对发现边界，逐项解释 no_same_decision 和 partial_arm_units。
2. Map-Airy 和 vLLM 已进行“仅规范化”的专项 GPU 对比；继续覆盖其他配对和 case。
3. 覆盖带入口 PHI 的规范化、switch 的变换，以及更一般的短路图。
4. 独立 driver 已完成 RegionMelder 完整树实验；仍需接入默认关闭的生产 tryPair 路径。
5. 引入每 Arm 静态成本诊断；当前原型不做成本评估、接受判断或贪心提交。

入口 PHI、switch 改写和非相邻配对目前返回拒绝，不进行不完整的变换。
现有生产冻结二进制和性能回归命令没有变动。专项 GPU 验收只覆盖记录中的配对，不能当作全搜索回归。

## 本次留存的证据

`docs/evidence/decision-model-20261110/summary.json` 保存真实 case 的输入路径、SHA256、
发现统计、旧候选分类统计和规范化尝试记录。各 case 的 `*-comparison.json` 保存逐候选对照，
`tests.log` 保存 CPU 测试结果。未把真实输入张量或 GPU 输出加入仓库。

musa 实验目录：`/home/chh/kernel-benchmark-suite-review-speculation/`。
原始生产目录：`/home/chh/kernel-benchmark-suite/`，本次未修改其搜索实现。
