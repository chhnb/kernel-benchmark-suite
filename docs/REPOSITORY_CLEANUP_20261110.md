# 仓库精简执行记录

本轮已实际执行，不只是提出方案。未修改融合引擎或评分模型。

## 完成项

1. 将16份Landau、beam/backtracking、Share/Bloat、Saspoint5、OAMP历史专题文档移至 `docs/history/topics/`，增加旧文件名→归档位置索引，并修正实际Markdown链接。旧实验日志里的纯文本历史路径不改写，通过归档索引查找。
2. 新增公共 `tools/run_cpu.py`，内容复用原有CPU配额逻辑，保留相同slot和环境，避免新旧入口成为两个配额池。旧 `experiments/saspoint5-cuda-v1/run_cpu.py` 改为兼容转发。当前生成输入回归与主线文档改用公共入口。
3. 以固定清单删除三个近期Map-Airy搜索目录中5494份未选中、合法且已评分的 `after.ll` / `after-raw.ll`。逻辑文件大小合计820094059字节，约782.1MiB。
4. `regression/runs` 磁盘占用由1409308KiB降至598348KiB，净减少810960KiB，约792.0MiB；实际分配块大小与文件字节数不同。

完整删除清单、每个文件SHA256及应用收据保存在musa：

`/home/chh/kernel-benchmark-suite/regression/runs/20261110-repository-cleanup/`

Git保存小型汇总 `regression/records/20261110/repository-cleanup.json` 和可重用维护脚本 `scripts/maintenance/prune_search_ir.py`；大清单不混入源码。各搜索目录新增IR_RETENTION.md说明缺失IR的原因。

## 保留规则与检查

父状态、全部trial JSON/评分、选中方案IR、非法/未评分trial诊断、最终IR、冻结reference、输入生成器、CPU参考及原始计时CSV均保留。清理前记录了975份保留IR和二进制哈希，清理后逐个复核一致。未修改原始case数据和Qwen历史归档。

维护脚本先生成plan，再独立apply；apply先校验整份清单及trial身份，再删除，计划改变即拒绝。已用隔离fixture验证：选中、非法、未评分候选与父状态不被删除；只删未选中合法已评分候选的两份IR。重新分析被裁剪候选需从保留父状态和候选ID复跑，并使用对应历史源码版本/配置，不能继续声称所有trial仍有完整IR。

公共CPU入口与兼容入口均实际运行通过；修改的Python语法检查通过。引擎与回归二进制未变化，未重复GPU计时。

## 尚未做的事情

没有大规模移动case、tools或experiments；没有拆分fusion_search.cpp；没有删除build/toolchain/真实输入；没有创建remote或推送。多数case源码仍需补齐版本管理。继续迁移前，应先清点主线依赖并补重建清单，而不是直接搬走绝对路径引用的目录。
