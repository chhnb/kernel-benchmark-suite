# Dataflow B2B 阶段结论

- 第 3b 步至第 5 步建立了 small 档真值。187 个可计价区域在抽象和真实两种代价下通过对拍。真实代价下，44 个可计价 diamond 中 anchor 有 33 个达到最小 $T_D$，DARM 有 15 个。 [第 3b 步](../../tests/dataflow-b2b/results/step3b-summary.md) · [第 5 步](../../tests/dataflow-b2b/results/step5-summary.md)
- 第 4a 和第 4b 步在 DCT8 与 PCM32 验证了 dataflow-exact。相对 anchor，静态 TTI 分别从 62 降至 44、从 1136 降至 1130，设备时间没有相同幅度的改善。 [DCT8](../../tests/dataflow-b2b/results/step4a-dct8.md) · [PCM32](../../tests/dataflow-b2b/results/step4b.md)
- 第 5b 步的真实代价结果中，small 和 medium 相对 anchor 的 612 点净收益有 476 点来自控制项。其中 443 点来自消除 anchor 的条件分支。 [第 5b 步](../../tests/dataflow-b2b/results/step5b-summary.md)
- 第 6 步中，独立区域的控制优势未在端到端兑现。NQU64 两版 HSACO 相同，MapAiry 的最终 anchor 已把两处相关谓词降为 select，两版 GPU 时间中位数均为 31.520 µs。 [第 6 步](../../tests/dataflow-b2b/results/step6.md)
- 第 7 步在 anchor 上下文中重放候选。按 §7.2 计算的已证明正遗憾大多很小，DCT8 的中间链是确认的例外，单步替换使最终 TTI 降 18。MapAiry 的局部优势在替换后改走其他贪心路径，最终 TTI 升 304。 [第 7 步](../../tests/dataflow-b2b/results/step7.md)
- 第 7 步的 LUD8 对照中，anchor 的最终 TTI 为 628，DARM 为 681。入口菱形单独计价时 DARM 低 6 点，这项局部收益未转化为相同父 IR 上的整核优势。 [LUD8](../../tests/dataflow-b2b/results/step7.md#lud8)
- 第 8 步移除 ILP 执行路径。单保护段模型在 LUD8 的大区域筛掉约 85 万个需要多个保护段的决策，两条搜索各只有一个改写取得报价。归档 tag 保留原实现，small 真值和上下文 IR 继续作为检验基准。 [第 7 步的 LUD8 证据](../../tests/dataflow-b2b/results/step7.md#lud8) · [归档说明](../../tests/dataflow-b2b/results/README.md)
