# 当前父 IR 的融合域调度验收

被测实现为 953fa85。PCM256 使用相同输入、同一驱动和引擎、16 个 worker，顺序 legacy / trees / trees / legacy。

| PCM256 | legacy | trees |
|---|---:|---:|
| seconds_median | 625.648 | 182.101 |
| seconds_min | 622.173 | 181.017 |
| seconds_max | 629.124 | 183.184 |
| trials | 13254 | 257 |
| commits | 122 | 122 |
| final_tti | 2257 | 2214 |

| 计时 / 阶段 | 旧次数 | 树次数 | 旧秒 | 树秒 |
|---|---:|---:|---:|---:|
| driver / domain_queue_and_requests | 124 | 128 | 1.499 | 0.117 |
| driver / enumerate_catalog | 124 | 128 | 6.311 | 6.088 |
| driver / enumerate_prepared_catalog | 124 | 128 | 0.000 | 0.004 |
| driver / initialization | 1 | 1 | 0.102 | 0.103 |
| driver / parse_and_discover | 124 | 128 | 5.578 | 6.013 |
| driver / prepare_arms | 124 | 128 | 0.045 | 2.292 |
| driver / read_scores_and_select | 124 | 128 | 4.272 | 0.182 |
| driver / record_and_commit | 124 | 128 | 13.222 | 1.096 |
| driver / trial_workers_wall | 124 | 128 | 594.395 | 166.172 |
| worker / b2b_plan_generate_clean_total | 13524 | 261 | 3529.018 | 97.225 |
| worker / cleanup | 216838 | 7087 | 1232.176 | 34.622 |
| worker / clone_before_cleanup | 216838 | 7087 | 237.837 | 7.519 |
| worker / clone_layout | 216838 | 7087 | 197.852 | 5.086 |
| worker / clone_parent | 12917 | 260 | 12.821 | 0.243 |
| worker / decode_layout_recipe | 6719 | 107 | 0.093 | 0.001 |
| worker / emit_layout | 216838 | 7087 | 2.708 | 0.082 |
| worker / evaluate_score | 201536 | 6489 | 3278.283 | 184.862 |
| worker / features | 433676 | 14174 | 932.237 | 24.601 |
| worker / plan_layouts | 550 | 135 | 0.033 | 0.008 |
| worker / round_control_analysis_cleanup | 1902 | 257 | 34.897 | 4.058 |
| worker / serialize_and_hash | 464722 | 15104 | 1511.845 | 41.845 |
| worker / verify | 446593 | 14434 | 191.039 | 5.102 |

driver 为墙钟时间。worker 为跨并行请求的 inclusive 时间，嵌套计时区间有重叠。独立 SSA 深度分析 localDependencies 在该评分配置中无调用。

其余 39 个冻结条目对照上一版树调度。逐步 IR 首次分歧条目：无。分歧按每次提交的成本和 IR 哈希检测，只规范化 ModuleID。

## 提交与复现

两组 legacy 对 trees 均在第 91 次提交首次分歧。旧调度在全函数选中了 B13:B106:B105，TTI 2847；树调度在当前域选中 B11:B109:B108，TTI 2848。前 90 次的候选、成本和逐步 IR 相同。两组所有提交均通过 LLVM verifier，终态父 IR 上可试结构候选分别覆盖 4/4 和 1/1。六个固定请求的完整 score_result 和生成 IR 字节均相同。真实 vLLM 八叶树与最小合成的逐步 CPU 输出校验见 tree-domains.md。

严格的跨次 IR 一致性检查在 legacy 通过，在 trees 失败。两次 trees 的提交数、每步成本和最终 TTI 相同。第 92 步使用同一父 IR、同一 B10:B11:B107 和原有 DARM B2R 复制路径，清理前 IR 已有差异。清理后，一个产物使用 icmp sle，另一个使用 icmp sgt 并对调后继。第 93 步两次请求的左右块坐标随之互换。直接重放同一冻结请求 8 次，两个已知 IR 哈希分别出现 5 次和 3 次，评分相同。当前该 B2R 路径存在逐字节复现差异。

PCM256 两个最终代码对象均有 GPU 完整输出依据。对本轮第一份代码对象使用 32768 个 block、种子 42 交错测量，三组各预热一次并测六次，21 次全输出与 CPU 排序逐元素相同。未融合、legacy、trees 的中位时间分别为 1551.094、1066.305、1104.722 ms。另一份代码对象逐字节等于此前同规模同输入测得 1106.638 ms 的代码对象。其余 39 个冻结条目的最终代码对象均与此前测试的对应二进制逐字节一致。NQU256 和 LUD64 internal 的 GPU 对照缺少有效耗时，具体原因见全套对照。

实现位于独立分支 experiment/domain-reactivation。全局 legacy 仍为默认值。使用 --domain-schedule trees 选择树调度。
