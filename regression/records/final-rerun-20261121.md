# Anchor 发布线最终清理与复验

起点为 feature/anchor-default 的 `b54c3c0f45cd7bbada375a5d94e9fdbe169cd9f8`。以下清单在代码删改前按实际调用路径登记。冻结的输入、黄金产物、manifest、旧测量和试验记录仍是复现材料。

## 代码清单

| 项目 | 分类及处理 |
| --- | --- |
| `decision-greedy` 的 INPUT、FUNCTION、可选 TOOL_ROOT、NEW_OUTPUT；`--help` | 默认搜索接口，保留 |
| `--b2b-strategy anchor`；`b2b_anchor`、`b2b_optimization_unit`、`b2b_unit_capsule` | 默认 B2B，保留 |
| `--b2b-strategy darm-artifact`；`tools/darm_artifact` 的 bridge、上游工程、patch 与 provenance；独立 Auto DARM 的固定输入和入口 | 基线对照，保留 |
| `--b2b-strategy darm` | 默认 anchor 失败时仍需项目内 DARM 发射。独立的强制布局入口与默认回退分别核查 |
| 默认 `darm` B2R、R2B、R2R；`fusion_search`、`darm_pair_engine`、`logical_region_state`、`ordered_arms` | 默认路径，保留；单独检查实验分支 |
| `--darm-legacy-flags` 及三个入口的旧行为传播 | 仅用于正确性修复前后对照，删除；保留交集逻辑及其测试 |
| `--b2r-strategy guarded` 和对应实验发射；`compile_kernel.py` 的选择入口 | 仅用于 guarded 试验，删除实验入口与仅供该策略的逻辑；共享的安全条件保留 |
| `--domain-schedule ordered`、`--structural 1`、`--darm-region-candidates 1`、`--cleanup darm-cfg-dce-instcombine` | 当前固定行为，保留默认调度、枚举和 cleanup；仅用于兼容旧调用的显式选项逐个核查 |
| `--ir`、`--function`、`--out`、`--tti-worker`、`--catalog-only`、`--control-only`、`--split`、`--left`、`--right`、`--debug-dir`、`--replay-parent-hash`、`--worker` | 枚举、逐候选执行、父状态复验及诊断路径，保留 |
| `--ir-snapshots full/compact`、`incremental_ir_snapshot`、`incremental_ir_identity`、`incremental_candidate_queue`、`incremental_metadata` | compact 是默认发布路径，保留；full 同时供 `compile_kernel --work-dir` 的诊断证据和测试检查 |
| `--tti-quote-cache on/audit/off`、`llvm24_scorer`、`tti_quote_key`、LLVM24 worker 的 `--serve-full`、`--serve-summary`、`--summary-only` | on 及 worker 是默认路径；删除纯试验成本档前，核对 audit、off 对默认报价验证的作用 |
| 搜索器 `--rounds`、`--trials`、`--opt-level`、`--threshold`、`--require-parent-gain`；`decision_compare`、`domain_competition`、`decision_model`、`fusion_domains`、`condition_simplify`、`fusion_profile` | 按默认 driver 实际调用、直接搜索调用和历史试验参数分别核对 |
| `FUSION_TTI_COST_KIND=latency` 与显式 throughput 环境入口；`tti_cost_kind` | 固定为默认 throughput；删除选择及仅为跨档的测试 |
| `FUSION_TTI_MODE=record/strict/offline`、`FUSION_TTI_DB`、`FUSION_TTI_OVERRIDES`、`FUSION_TTI_WARNINGS`、`FUSION_TTI_STRICT_ERRORS`；`offline_tti.py`、`offline_tti_layout.cpp`、`tti_memory_io.h` | 实验报价路径；单独区分实时报价与离线复现工具的共享代码 |
| `DECISION_CHECKPOINT_TOOL`、`decision_checkpoint`、`ir_pressure`、`isolated_b2b_greedy`、`isolated_b2b_trial` | 标出默认调用和仅供旧试验或报告的依赖后清理 |
| `DECISION_GREEDY_JOBS`、`LLVM_CONFIG`、`LLVM24_CONFIG`、`LLVM24_LIBDIR`、`LD_LIBRARY_PATH`、`CXX` | 默认 driver 并发与固定工具链构建，保留 |
| `build-v1`、`build-llvm24-tti`、`build-decision-greedy`、`build-decision-model`、`compile_kernel`、发布重建脚本 | 默认构建、后端和发布复验保留；按依赖检查仅用于实验模式的构建目标 |
| `runner/gpu.hpp`、`runner/options.hpp`、`runner/measurement.hpp`、`runner/replay.cpp`、各 case 的验证 harness 和 `regression/measure_anchor_gpu.py` | 进程内计时、A/A、bootstrap、输入与完整输出验证，保留 |
| `tools/run_case.py`、`run_cpu.py`、`run_portable_benchmark.py`、`suite.py`、`run_*_regression.py`、`verify_anchor_release.py` | 发布或历史验证入口。仅改仍生效的调用，保留已冻结材料 |
| `pair_trial`、`region_inventory`、`region_similarity` 及 build/run 包装；生成输入的 `export_*`、`migrate_*`、`freeze_*`、`setup_*`、注册/修正脚本 | 逐个检查是否服务于当前输入与历史基线；不动已冻结的结果 |
| `audit_b2b_layouts.py`、`compact_scores.py`、`review_cpp.py`、`scripts/maintenance/prune_search_ir.py` | 非默认搜索路径。逐项确认当前归档、审计或维护调用后决定 |
| DP1／DP2、DP3、DP 布局研究、静态接受规则 RIR/RIRv2/R/RB | 发布线无可选 DP1/DP2/DP3 或预注册接受规则；保留历史记录，核对是否有残留生产入口 |

## 清理前基准

清理前在 EPYC 从 `b54c3c0` 干净导出并构建，固定 LLVM12/LLVM24 运行默认 throughput 完整 Greedy。独立检查 25 项通过，包括套件中的 DARM 标志及 metadata 交集测试。四个缺件项目按 `KNOWN_FAILURES` 跳过。16 例均过 LLVM verifier，提交数和最终 TTI 均匹配发布 manifest。16 个 HSACO/cubin 逐字节一致，15 个 IR 逐字节一致。HLLD 的 IR 少一条 `!fusion.logical.arm` 附件，余下 IR 一致。后续验证以本次 IR/二进制的完整字节为基准。

EPYC 基准目录为 `/data/home/chh/simplify-v2/build/final-release.kzxLp5/base-outputs/`。每例原始 IR、HSACO/cubin 及 SHA-256 见 `results.json`，文件 SHA-256 为 `3f4bbdd98b5a598257b8f3943f23769efe083dd919367891f84f37da183b3b4c`。
