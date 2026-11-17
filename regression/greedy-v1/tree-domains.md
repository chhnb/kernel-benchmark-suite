# 按决策树调度（开发中）

入口 `decision-greedy --domain-schedule trees`，旧对照为 `legacy`，默认暂未切换。仅支持原 whole-function trial，不能与 scoped 清理实验混用。

## 归属与顺序

`FusionDomains` 按 discover 的条件测试链合并归属，包含 arm 准备失败的 decision。嵌套于 arm 正文的 decision 单独归属；跨两侧的 region 候选属于控制它的 split，而不是按左右块是否相邻判定。归属是调度边界，不是独立性证明。

初始 decision 阶段保留旧直接 split 候选、prepared 相邻候选的顺序，同树其他 split 的结构候选追加。树内比较使用原队列的 parentCost-after，原合法性及正收益准入不变；不能使用日志中 controlCost-after 替代队列排序。新增候选同分不能抢占原有候选。

结构扫尾每次从当前 catalog 找第一组未试过的域，试跑这个域的全部候选，再选最大正收益。无收益就继续下一个域。提交后清空当前父 IR 的 attempted 集合，重新枚举：消失的候选不再出现，新候选自然加入，所有旧域保守重新激活。没有跨提交复用收益、没有旧模块回放，也没有按块编号推断跨版本身份。当前 B 坐标只在同一父 IR 上有效。

代价：已无收益的前置域可能被重复试跑；尚未实现精细影响依赖。优点：不依赖尚未证明的局部清理可交换性。终止要求最终父 IR 的所有可试结构候选都已评估且无正收益。调度变化可以改变提交顺序和最终 IR，须记录第一处分歧，不能称为原流程完全等价。

## 已有证据

- PCM256 原流程：122提交、13254 trial，其中13253发生在全函数扫尾。首扫121个split根，120个单候选根、一个31候选根。
- v3 PCM256 trees：177.487秒、122提交、137 trial、TTI2214。历史旧版626.96秒、TTI2257。前90步逐步IR一致，第91步分歧。当前同场legacy仍在运行，首轮计时同期有诊断引擎编译，不作为稳定加速结论。
- 所有提交IR verifier通过；终态结构候选覆盖检查通过。
- PCM256 GPU：4 seeds，每seed131072元素，未融合/新IR/CPU分组排序逐元素一致，16个block、每block256线程。不是原artifact完整32768个block规模的性能测试。
- vLLM真实八叶树提取：旧44 trial、新76 trial；7次提交、TTI25；每步IR仅忽略ModuleID后相同。最早v2曾TTI38，原因是扩展候选抢占同分优先级，失败产物保留。
- PCM32：71→26trial，17提交，TTI1142→1138；调度差异从第9次开始。三次中位4.083→3.896秒，范围重叠，不声称稳定收益。

脚本：audit-decision-domains.py、compare-domain-driver.py、check-domain-driver.py、check-domain-pcm-gpu.py。路径均在 tests/fusion-search。

产物：build/incremental-unit-audit/pcm-domain-v3-complete、domain-small-v2、quant8-domain-v3、pcm-domain-gpu、pcm256-trial100-profile。

## 计时口径

driver_phase_timings 是顺序的driver阶段wall时间。trial_workers_wall包含多个worker并行执行，不能与worker累计时间相加。request-profile.json是单请求inclusive计时，父子scope重叠，不能直接求和。profile引擎独立构建，六组同父候选score_result与IR完全一致。

尚缺：同场和无干扰重复完整计时、全部worker阶段细分、完善生命周期测试、正式checkpoint。Goal未完成。
