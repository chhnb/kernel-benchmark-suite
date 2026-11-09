# Hypersonic 完整相邻叶子融合入口

已实现并验证；没有更改原始 artifacts checkout，也没有抽取或重写 case helper。
修改位于 suite 的 tools/fusion_search.cpp，复用 suite 内现有 DARM RegionMelder。

## 输入与边界

输入是 LLVM12 显式 pass、无 Jump Threading 的 IR。为让 LLVM24 TTI 可以解析，先 internalize + globaldce 去除未使用的 ROCm 设备库函数（其中有 LLVM24 不接受的旧式常量表达式）；kernel CFG 保持不变。

- E6_23：L0，B6，出口 B23。
- E8_23：完整 L1，B8～B13，出口 B23；包括 canonical R20 之外的尾部 B13。
- E15_23：L2，B15～B21，出口 B23。
- L3 写零并提前返回，排除在两个候选的范围之外。

Eentry_exit 是当前 IR 快照的编号，不能跨轮次直接复用。
自动枚举已包含 E 候选；转换入口要求 --structural 1。
只处理可验证的相邻、无环 SESE 叶子，读取可以保留，但写入、有副作用的调用、异常入口等仍不支持。

## 转换如何执行

1. 根据两个叶子的共同后支配出口建立完整范围，不用整个 classifier 的出口。
2. 将相邻判断链规范成局部选择入口，保留未选的后缀。
   条件使用 select 来屏蔽原本不会求值的 poison；不投机执行加载或可能陷阱的判断计算。
3. 在这两个完整上下文内选择一个 DARM 块对齐锚点，按已有 BB 相似度排序、同分按函数顺序。
   至少一侧锚点必须必经；需要复制时，扩展块必须有唯一后继且不含 PHI。
4. 使用原有 RegionMelder 的指令匹配、保护和必要的区域复制。
5. 局部 scoped-cfg 清理、verifier，然后按原始父状态/control 计算 LLVM24 TTI 收益。

这不是任意异构 CFG 的整体一一映射，也不是每个叶子中的所有块都共享。
L1+L2 当前共享的是选定锚点，其余不匹配的分支仍保留。
带 PHI 的块作为复制扩展块仍被排除；未删除相关合法性检查。
这两个试验使用单次显式候选，不是完整搜索收敛结果。

## 结果

| 候选 | 原生对齐方式 | LLVM24 TTI 收益 | 接受情况 |
|---|---|---:|---|
| L0 + L1 | B2R，需要区域复制 | -201 | 合法，但贪心拒绝 |
| L1 + L2 | 两个必经计算块对齐，保留两侧其它 CFG | -11 | 合法，但贪心拒绝 |

L0+L1 的实际锚点：if.then21 与 if.then17.i270。
L1+L2 的实际锚点：neighbor_or_wall 的 exit289 尾块与 if.then39。
收益为 control 成本减候选成本，负数表示静态成本增加；不是 GPU 耗时标签。

## 验证

- LLVM12 raw/清理后 verifier 均通过。
- CPU 合成用例：12,006 组输入，每组对照两个融合版本。覆盖嵌套分支、PHI、受保护的空指针输入和提前退出写入。
- 不可安全投机的第二判断：拒绝且原始模块保持不变。
- 已有相邻入口融合、scoped CFG 运行回归通过（含 signed zero、infinity、NaN）。
- Hypersonic GPU 完整输出验证：baseline、L0+L1、L1+L2 全部通过，使用相同冻结输入。
- GPU 代码生成使用共同的最终 O3；这与搜索中的局部清理是两个阶段。
- L3 指令形态保持不变，仅无名 SSA 和元数据打印编号可能改变。
- 没有做性能计时，不宣称加速。

## 复现位置

项目：/home/chh/kernel-benchmark-suite
实验：experiments/hypersonic-complete-leaf-20261109-v1
输入：input.ll
显式试验：probe-v2.py
融合前/后：L0-L1-v2/state-0.ll、L0-L1-v2/trial-0/after-raw.ll、after.ll；L1-L2-v2 同理。
验证记录：validation.json、validation/、summary.json。
测试：tests/postopt/complete-leaf/{check.cpp,runtime.cpp,run.sh}。

显式候选参数分别为：
--split B5 --left E6_23 --right E8_23
--split B7 --left E8_23 --right E15_23
共同使用 --structural 1 --cleanup scoped-cfg --scorer llvm24。

注意：trial 的原生 block-provenance 编号来自规范化入口后的内部快照；完整叶子边界和 matched_* 标签用于对应原始父状态。
