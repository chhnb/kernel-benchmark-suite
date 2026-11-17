# 保持原流程的评分入口去重

仅移除 LLVM24 scorer 不读取的 DT/PDT/RegionInfo 构造。`evaluateTrial` 保留 valid、cleanup mode、版本、function、完整 parent hash 和非有限值检查；只有明确提供无分析入口的 scorer 才跳过 Analysis，其他 scorer 仍走原分支。枚举、DP1/DARM、清理、收益公式、同分和提交策略不变。

原二进制与独立新二进制，对 PCM32、PCM256、BIT32、MS32、vLLM、TIGRE 的第一份实际获选请求逐个重放。六组完整 score_result 相同，融合 IR 字节相同。测试脚本为 `tests/fusion-search/check-score-fastpath.py`。

`check-direct-tti.cpp` 用不提供快捷入口的包装 scorer 强制走旧 Analysis 分支，与新入口比较。报价缓存均 on，PCM256 同父同产物，预热后交错运行十次：完整评分字段相同，旧热评分中位 6.097ms，新 4.960ms。只代表该评分调用，不代表完整 trial 或编译加速。

使用相同旧 decision-greedy driver，只通过独立 tool root 替换 fusion-search 引擎，PCM32 全程17步的 decision、候选、TTI及IR均一致（仅忽略 ModuleID 路径），最终1142。单次总耗时旧3.917s、新3.929s，**没有观察到整体加速**；同时有两条旧长测运行，不能据此估计稳定百分比。

证据：`score-fastpath-check.json`；详细产物 `build/incremental-unit-audit/score-fast-six/`、`score-fast-driver/`。两个运行中的 PCM256 二进制未替换。这不是跨提交整次 trial 复用的完成证明，原 Goal 仍未完成。
