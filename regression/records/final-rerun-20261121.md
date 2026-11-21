# Anchor 发布线最终清理与复验

起点为 feature/anchor-default 的 `b54c3c0f45cd7bbada375a5d94e9fdbe169cd9f8`。以下清单在代码删改前按实际调用路径登记。冻结的输入、黄金产物、manifest、旧测量和试验记录仍是复现材料。

## 代码清单

| 项目 | 分类及处理 |
| --- | --- |
| `decision-greedy` 的 INPUT、FUNCTION、可选 TOOL_ROOT、NEW_OUTPUT；`--help` | 默认搜索接口，保留 |
| `--b2b-strategy anchor`；`b2b_anchor` | 默认 B2B，保留 |
| `--b2b-strategy darm-artifact`；`tools/darm_artifact` 的 bridge、上游工程、patch 与 provenance；独立 Auto DARM 的固定输入和入口 | 基线对照，保留 |
| `--b2b-strategy darm` | 发布 manifest 的项目内 DARM 独立基线，保留该入口和对应发射 |
| 默认 `darm` B2R、R2B、R2R；`fusion_search`、`darm_pair_engine`、`logical_region_state`、`ordered_arms` | 默认路径，保留；单独检查实验分支 |
| `--darm-legacy-flags` 及三个入口的旧行为传播 | 仅用于正确性修复前后对照，删除；保留交集逻辑及其测试 |
| `--b2r-strategy guarded` 和对应实验发射；`compile_kernel.py` 的选择入口 | 仅用于 guarded 试验，删除实验入口与仅供该策略的逻辑；共享的安全条件保留 |
| `--domain-schedule ordered`、`--structural 1`、`--darm-region-candidates 1`、`--cleanup darm-cfg-dce-instcombine` | 保留固定调度和 driver 发送到 worker 的调度／枚举／cleanup 参数 |
| `--ir`、`--function`、`--out`、`--tti-worker`、`--catalog-only`、`--control-only`、`--split`、`--left`、`--right`、`--debug-dir`、`--replay-parent-hash`、`--worker` | 枚举、逐候选执行、父状态复验及诊断路径，保留 |
| `--ir-snapshots full/compact`、`incremental_candidate_queue` | compact 是默认发布路径，保留；full 同时供 `compile_kernel --work-dir` 的诊断证据和测试检查 |
| `--tti-quote-cache on/audit/off`、`llvm24_scorer`、`tti_quote_key`、LLVM24 worker 的 `--serve-full`、`--serve-summary`、`--summary-only` | on 及 worker 是默认路径。保留 audit 和 off，用于对照验证默认报价缓存 |
| 搜索器 `--rounds`、`--trials`、`--opt-level`、`--threshold`、`--require-parent-gain`；`decision_compare`、`domain_competition`、`decision_model`、`fusion_domains`、`condition_simplify`、`fusion_profile` | 删除 `--rounds`、`--trials`、`--opt-level`、`--threshold`、`--require-parent-gain`。保留在线搜索调用的模型、域调度和条件处理模块 |
| `FUSION_TTI_COST_KIND=latency` 与显式 throughput 环境入口；`tti_cost_kind` | 固定为默认 throughput；删除选择及仅为跨档的测试 |
| `FUSION_TTI_MODE=record/strict/offline`、`FUSION_TTI_DB`、`FUSION_TTI_OVERRIDES`、`FUSION_TTI_WARNINGS`、`FUSION_TTI_STRICT_ERRORS`；`offline_tti.py`、`offline_tti_layout.cpp` | 删除离线实验报价路径。实时缓存仍用 `tti_memory_io.h`，保留 |
| `DECISION_CHECKPOINT_TOOL`、`decision_checkpoint` | 删除未使用的 checkpoint 环境入口和报告辅助代码。保留在线诊断用的 `ir_pressure` |
| `DECISION_GREEDY_JOBS`、`LLVM_CONFIG`、`LLVM24_CONFIG`、`LLVM24_LIBDIR`、`LD_LIBRARY_PATH`、`CXX` | 默认 driver 并发与固定工具链构建，保留 |
| `build-v1`、`build-llvm24-tti`、`build-decision-greedy`、`build-decision-model`、`compile_kernel`、发布重建脚本 | 保留默认构建、后端、发布复验和已有 worker 的 `--search-only` 构建。删除导出 SQLite 布局的构建目标 |
| `runner/gpu.hpp`、`runner/options.hpp`、`runner/measurement.hpp`、`runner/replay.cpp`、各 case 的验证 harness 和 `regression/measure_anchor_gpu.py` | 进程内计时、A/A、bootstrap、输入与完整输出验证，保留 |
| `tools/run_case.py`、`run_cpu.py`、`run_portable_benchmark.py`、`suite.py`、`run_*_regression.py`、`verify_anchor_release.py` | 发布或历史验证入口。仅改仍生效的调用，保留已冻结材料 |
| `pair_trial`、`region_inventory`、`region_similarity` 及 build/run 包装；生成输入的 `export_*`、`migrate_*`、`freeze_*`、`setup_*`、注册/修正脚本 | 保留历史输入生成和对照接口，继续记录四个缺件测试 |
| `audit_b2b_layouts.py`、`compact_scores.py`、`review_cpp.py`、`scripts/maintenance/prune_search_ir.py` | 移除旧 DP1 的布局审计脚本。分解工具仍由历史 region similarity 的复现入口导入。保留计时报告和 IR 维护工具 |
| `isolated_b2b_greedy`、`isolated_b2b_trial`、`b2b_unit_capsule`、`b2b_optimization_unit`、`incremental_ir_snapshot`、`incremental_ir_identity`、`incremental_metadata` | 仅由隔离原型测试编译，删除模块和专用测试。现行 whole-function 队列与快照输出继续使用 |
| DP1／DP2、DP3、DP 布局研究、静态接受规则 RIR/RIRv2/R/RB | 保留历史记录。DP1/DP2/DP3、RIR/RIRv2/R/RB 不进入当前发布路径 |

## 清理前基准

清理前在 EPYC 从 `b54c3c0` 干净导出并构建，固定 LLVM12/LLVM24 运行默认 throughput 完整 Greedy。独立检查 25 项通过，包括套件中的 DARM 标志及 metadata 交集测试。四个缺件项目按 `KNOWN_FAILURES` 跳过。16 例均过 LLVM verifier，提交数和最终 TTI 均匹配发布 manifest。16 个 HSACO/cubin 逐字节一致，15 个 IR 逐字节一致。HLLD 的 IR 少一条 `!fusion.logical.arm` 附件，余下 IR 一致。后续验证以本次 IR/二进制的完整字节为基准。

EPYC 基准目录为 `/data/home/chh/simplify-v2/build/final-release.kzxLp5/base-outputs/`。每例原始 IR、HSACO/cubin 及 SHA-256 见 `results.json`，文件 SHA-256 为 `3f4bbdd98b5a598257b8f3943f23769efe083dd919367891f84f37da183b3b4c`。

### 清理提交与复验

- `506e386` 删除旧 DARM 标志开关，只保留交集发射。交集测试继续覆盖整数、浮点及访存 metadata。25 项通过、4 项缺件跳过；16 例 IR、HSACO/cubin 的完整字节均与清理前一致。
- `2ff9730` 将实时报价固定为原有 reciprocal throughput，删除 latency 及 SQLite 记录、重放、自定义报价的试验路径和专用测试。最初测试检查发现 guarded 实验测试依赖空 SQLite 报价，改为由同一提交移除该测试及其独有的 fixture。保留默认报价的身份核对、缓存以及独立 worker。23 项通过、4 项缺件跳过；16 例 IR、HSACO/cubin 的完整字节均与清理前一致。
- `5009355` 移除保护 B2R 试验发射、隔离 B2B 原型、对应辅助测试、无调用的 checkpoint 入口，以及只读 worker 中从未被发布路径设定的查询参数。默认 DARM 的共享执行域和访存保护照常保留。同步更新运行文档和 PCM32 已知问题。16 项通过、4 项缺件跳过，16 例 IR、HSACO/cubin 的完整字节均与清理前一致。

普通合并提交为 `e3bb5fd84cf13478d386cb1752cc1216a81ba732`。合并后在新目录干净构建，16 项通过、4 项缺件跳过，普通推送 feature/anchor-default。清理前三批的完整字节收据分别在同一 EPYC 目录的 `merge-flags-outputs`、`throughput-verified-outputs`、`default-only-outputs` 中。

## EPYC 磁盘清理前清单

项目所在 /data 共 7,392.19 GiB，已用 4,132.67 GiB，可用 2,886.90 GiB。
按项目构建与运行时根目录下已分配的空间排名，目录大小不与它的子项重复计数。

| # | 原路径（相对 /data/home/chh） | GiB | 检查与处理 |
| ---: | --- | ---: | --- |
| 1 | simplify-v2/build/simplify-fingerprint | 44.73 | 保留冻结输入和固定序列化路径，逐项删除无提交路径引用的旧构建或试验中间产物 |
| 2 | simplify-v2/build/b2b-layouts | 25.02 | 保留发布 GPU fixtures、CUDA 工具及历史依据 |
| 3 | simplify-v2/build/dp1-removal | 13.65 | 保留发布排序、NQU64、SRAD 输入和对照 |
| 4 | simplify-v2-normalize/build/normalize-candidate | 10.49 | 保留包含 srad32-frozen-manifest.json 的子目录，引用的运行产物核对后归档，逐项删除无提交路径引用的旧构建或试验中间产物 |
| 5 | simplify-v2/build/final-release.kzxLp5 | 6.71 | 本轮构建、校验和测量原始数据，保留 |
| 6 | simplify-v2/build/cost-model-eval | 5.14 | 引用的运行产物核对后归档 |
| 7 | v2-runtime/cases | 5.05 | 保留冻结 GPU 输入和对照 |
| 8 | simplify-v2/build/darm-metadata-release.A2YwDz | 3.29 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 9 | simplify-v2/build/darm-flags-fix.1WbCvz | 3.28 | 引用的运行产物核对后归档 |
| 10 | simplify-v2-normalize/build/memory-metadata | 3.25 | 引用的运行产物核对后归档 |
| 11 | kernel-benchmark-suite/build/fluid-sims | 3.22 | 保留 Landau 发布输入 |
| 12 | v2-runtime/wave-calibration.NcpNDg | 3.17 | 保留原始校准捕获 |
| 13 | v2-runtime/hypersonic-history | 2.02 | 保留历史 GPU 捕获 |
| 14 | v2-runtime/toolchains | 1.83 | 保留固定编译器、运行时及 Auto DARM |
| 15 | simplify-v2/build/accept-rir-v2.QJqs83 | 1.76 | 引用的运行产物核对后归档 |
| 16 | simplify-v2-normalize/build/region-anchor | 1.74 | 引用的运行产物核对后归档 |
| 17 | domain-reactivation/build/frozen-parity | 1.63 | 保留冻结正确性产物 |
| 18 | domain-reactivation/build/ordered-gpu-confirm | 0.88 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 19 | domain-reactivation/build/paired-large | 0.66 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 20 | v2-runtime/offline-tti.mP1qFj | 0.61 | 保留 frozen-databases |
| 21 | domain-reactivation/build/v2-simplification | 0.53 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 22 | domain-reactivation/build/final-pcm256 | 0.52 | 保留有历史路径引用的回放 |
| 23 | domain-reactivation/build/diagnose-trees | 0.52 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 24 | domain-reactivation/build/ordered-verified | 0.49 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 25 | domain-reactivation/build/v2-compact | 0.46 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 26 | simplify-v2/build/cost-model-unbiased | 0.46 | 保留有历史引用的成本模型数据 |
| 27 | domain-reactivation/build/shared-arm-competition | 0.42 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 28 | domain-reactivation/build/mapairy-owner-before | 0.41 | 逐项删除无提交路径引用的旧构建或试验中间产物 |
| 29 | kernel-benchmark-suite/build/arm-stores-regression.PbNYfp | 0.35 | 保留含未提交改动的独立工作树数据 |
| 30 | simplify-v2/build/region-audit | 0.28 | 保留冻结的区域审计证据 |

## 磁盘清理结果

清理前已用 4,132.68 GiB、可用 2,886.89 GiB，清理后已用 4,096.66 GiB、可用 2,922.91 GiB。可用空间增加 36.03 GiB。
共归档 8 个目录、直接删除 16 个可重建目录。下表中的大小是清理前的已分配空间。归档均已通过 zstd 流校验和 tar 对源文件内容的逐项核对。

| 原路径 | 原始 GiB | 操作与证据 |
| --- | ---: | --- |
| `/data/home/chh/simplify-v2-normalize/build/memory-metadata` | 3.25 | `simplify-v2-normalize__build__memory-metadata.tar.zst`，0.07 GiB，SHA-256 `9c731faf3af083f5025b2151a2fdb7d3ce22e4feeb157bd888ff7c622e93ca89`，引用 `regression/records/memory-metadata-merge-20261121.md (origin/fix/memory-metadata-merge)` |
| `/data/home/chh/simplify-v2/build/darm-flags-fix.1WbCvz/build/release-new-old` | 3.24 | `simplify-v2__build__darm-flags-fix.1WbCvz__build__release-new-old.tar.zst`，0.07 GiB，SHA-256 `874a5512cdd1c508513de16ab25c26310fe57d60a1b19d66d8cb23b94cc72708`，引用 `regression/records/darm-merge-flags-20261121.md` |
| `/data/home/chh/simplify-v2/build/cost-model-eval/20261120-v1` | 5.14 | `simplify-v2__build__cost-model-eval__20261120-v1.tar.zst`，0.11 GiB，SHA-256 `00b836f591ee068829148a9b44e660fa6b29a7bda508b9bca56a8d4a5580ed4d`，引用 `regression/records/cost-model-eval-20261120.md (09778be)` |
| `/data/home/chh/simplify-v2/build/accept-rir-v2.QJqs83/build/study-3b` | 1.68 | `simplify-v2__build__accept-rir-v2.QJqs83__build__study-3b.tar.zst`，0.04 GiB，SHA-256 `4ba4a87e831e1f224591a5c0a1832575641220eee1af702b99d054b3da13de1f`，引用 `regression/records/accept-rule-eval-20261121.md (81bbd4a)` |
| `/data/home/chh/simplify-v2/build/accept-rir-v2.QJqs83/build/batch-protocol.yNsnRk` | 0.04 | `simplify-v2__build__accept-rir-v2.QJqs83__build__batch-protocol.yNsnRk.tar.zst`，0.00 GiB，SHA-256 `d70c341d8e3b4a21f3740b0e62e7016bc5410308447d7ee358a593e807983c25`，引用 `regression/records/accept-rule-eval-20261121.md (81bbd4a)` |
| `/data/home/chh/simplify-v2-normalize/build/region-anchor` | 1.74 | `simplify-v2-normalize__build__region-anchor.tar.zst`，0.04 GiB，SHA-256 `b7184541ffd767bd11f609b793d04bc0eaa03d68454712a075ad40c0d69be379`，引用 `regression/records/region-anchor-20261120.md (c89b380), region-anchor-parity-20261121.md (2c112f0)` |
| `/data/home/chh/simplify-v2-normalize/build/normalize-candidate/20261120-v1` | 7.64 | `simplify-v2-normalize__build__normalize-candidate__20261120-v1.tar.zst`，0.17 GiB，SHA-256 `6715ef7ac31cf9a06faecf0f2b3cbcd2e4d2733a3d945ba24402a1eadb20ec59`，引用 `regression/records/normalize-candidate-20261120/greedy.json (origin/fix/normalize-only-candidate)` |
| `/data/home/chh/simplify-v2-normalize/build/normalize-candidate/20261120-memory42-v8` | 1.41 | `simplify-v2-normalize__build__normalize-candidate__20261120-memory42-v8.tar.zst`，0.04 GiB，SHA-256 `7f8b30b3e4b6dced5ca9d3d8e4be3d1e5ee36e915cd35627f81400785c7a1a0f`，引用 `regression/records/normalize-candidate-20261120/gpu-on-memory42-vs-auto-darm-v8.json (origin/experiment/tti-memory-42)` |
| `/data/home/chh/simplify-v2/build/darm-metadata-release.A2YwDz/build/release-new-old` | 3.24 | 删除。Duplicate comparison in scratch. The committed record points to the archived original from darm-flags-fix.1WbCvz. |
| `/data/home/chh/domain-reactivation/build/v2-compact` | 0.46 | 删除。Regenerable driver-build and trial snapshots. No exact committed path reference. |
| `/data/home/chh/domain-reactivation/build/mapairy-owner-before` | 0.41 | 删除。Regenerable trial snapshots. No exact committed path reference. |
| `/data/home/chh/domain-reactivation/build/diagnose-trees` | 0.52 | 删除。Intermediate experiment output. No exact committed path reference. |
| `/data/home/chh/domain-reactivation/build/v2-simplification` | 0.53 | 删除。Intermediate experiment output. No exact committed path reference. |
| `/data/home/chh/domain-reactivation/build/ordered-verified` | 0.49 | 删除。Intermediate experiment output. No exact committed path reference. |
| `/data/home/chh/domain-reactivation/build/paired-large` | 0.66 | 删除。Intermediate experiment output. No exact committed path reference. |
| `/data/home/chh/domain-reactivation/build/ordered-gpu-confirm` | 0.88 | 删除。Intermediate experiment output. No exact committed path reference. |
| `/data/home/chh/domain-reactivation/build/shared-arm-competition` | 0.42 | 删除。Intermediate experiment output. No exact committed path reference. |
| `/data/home/chh/simplify-v2/build/simplify-fingerprint/active-darm-tti-exp-vllm` | 1.15 | 删除。Old intermediate vLLM cost experiment. No committed path reference. |
| `/data/home/chh/simplify-v2/build/simplify-fingerprint/finalist-decision-u32` | 0.83 | 删除。Superseded search trial snapshots. No committed path reference. |
| `/data/home/chh/simplify-v2/build/simplify-fingerprint/unified-k16-default` | 0.77 | 删除。Old unified planner default-policy replay. No committed path reference. |
| `/data/home/chh/simplify-v2/build/simplify-fingerprint/unified-seeds-default` | 0.77 | 删除。Old unified planner seed-policy replay. No committed path reference. |
| `/data/home/chh/simplify-v2/build/simplify-fingerprint/unified-default-v4` | 0.77 | 删除。Old unified planner default-policy replay. No committed path reference. |
| `/data/home/chh/simplify-v2/build/simplify-fingerprint/unified-restricted-default` | 0.77 | 删除。Old unified planner restricted-policy replay. No committed path reference. |
| `/data/home/chh/simplify-v2-normalize/build/normalize-candidate/20261120-load42-v7` | 1.40 | 删除。Superseded memory quote experiment build and intermediate corpus. No exact committed path reference. |

归档目录为 `/data/home/chh/simplify-v2/build/final-release.kzxLp5/disk-archives`。归档内部保留来源目录名，按表中原路径的父目录解包可恢复原目录结构。
已删除当前本地检出的 study/pcm32-store-pairing 和 scoring/accept-rule 分支指针，两者在删除前与 origin 对应分支相同。EPYC 的独立工作树保留，其中 kernel-benchmark-suite 的 release/greedy-v1 检出存在未提交改动。

## 合并后离线复跑

在 e3bb5fd 的新检出中构建完成，16 项通过、4 个缺件测试按原清单跳过。16 个完整默认 Greedy 均通过 LLVM verifier，IR 和代码对象逐字节匹配第 0 节基准。两份收据的 SHA-256 同为 3f4bbdd98b5a598257b8f3943f23769efe083dd919367891f84f37da183b3b4c。

| Case | 提交数 | 最终 TTI | 最终 IR SHA-256 | HSACO／cubin SHA-256 |
| --- | ---: | ---: | --- | --- |
| vllm | 224 | 2619 | `36a74e727eaa9f71deeff97510180882c19b6269fcabbd59e2322a7f2b355135` | hsaco `9aa97bca3906c0d31452e4594b5fc17c535bce25ba5e7e4df92e5ff6841c5fa6` |
| MapAiry | 29 | 4099 | `860a6ffaffc03080484e40ad417795f70a3cc6e3b8f5455c657bd9d86cb8cd70` | hsaco `51c13dcce91306bb0c84aae7a3e4a1facc70d448d718483fbdb685f1fb48918d` |
| tigre | 6 | 946 | `420e5b216b5a97291a2cd89414acee8a298a57b9e5c351660196468a3783cb48` | hsaco `02452bc591290cb318b1ed9d876a907a56fd849fa9094e4efd74a76892e83a9a` |
| HLLD | 5 | 1696 | `a17bf4d4916553c59ed9f34e7aa003aedf4f46d20459c7ecde011955be450ed1` | hsaco `3aa2cad420017f246aa3f3f148eb23baa0d834dd92611c3bf68196393ceaf9a3` |
| NQU64 | 1 | 282 | `57d5c232299189c2b537ed51b2fe8de04dfce37d9ff2872c849151c743c282d4` | hsaco `42b2bda66286d3c3b437dd6fe78ecba602f6718f4f75659fe101bb5dc2c6865c` |
| MS32 | 1 | 212 | `077db63bbb806621cd55dde9359950f6fda9fe790d81646bc0c795fee160f2b5` | hsaco `1021292447be6660cf0366d7f785167c629f2b384a386f146568fa20eb2eaa9f` |
| PCM32 | 17 | 1138 | `b35648e90ca12b9b527363e39f19352a47987ae07582826575f06d5922b290a7` | hsaco `a0a8df33ee604bc77519a3887af2c8663afa6c7f0cd609dd392d136a815ec116` |
| SRAD16 | 4 | 452 | `8877d8d651d30f090848af6440690063a478eed6cf42ea257a418fed9d1c3591` | hsaco `2a6a3d958d37e110a4ca5107ca9346c31aa7e8393524dd4b95de2df56385e16e` |
| SRAD32 | 4 | 452 | `3195a5d7dcea8d3345c2c0e855bf3ea73113f6d8e50b41e411f6257e63b63bb5` | hsaco `6d603103809374c6fe65a05a39dd3fb5ea2b190cf2944ba4495b57fe391041e6` |
| Landau | 20 | 1708 | `e7617ca5482ee00c0c05cab548e7d3dd6f4134041b362fee354cf4e76c1b0de7` | hsaco `2c49a3bcb7798476672355fa5c579a6c917d3ad84668f8d302b8e065ae21d669` |
| SW2D | 0 | 1926 | `8468fbe02c5276b65129a84a4d84ea2b36c887e2088341c9475a72609ec9ef5e` | hsaco `cd0e00d276836e765fe1dba400bfab62312a79121226fcc8ef4e4d7fa95b3518` |
| CED | 5 | 280 | `595f62ff52ffe7c360bb13f38fff382caa799e3bce192d654d0c16fbf99be55b` | hsaco `a213f9bb1677d2079917ec3398dcb902cc5eabda8dd04353c8aa8799bfd5a93b` |
| TPACF | 12 | 483 | `0c2d53c8572879a010939a4c0db4b944878469a43ac855610af5df77fc262266` | hsaco `7b805ab747a196bae398d1df12d58ba34fb9f2f2dd4fbc29ec5b2c6daa408986` |
| SRAD-stage2 | 2 | 210 | `1fa2ae82a945b3d922eefab4f0b69e652f8e8f1177363e360500a1fa973278a1` | hsaco `67e86ccd15676d38fb247efa7f161ac6f0cb42dc6a040973de329a86763f296a` |
| SasPoint5 | 8 | 491 | `59ccd0e14e265309af938399da0f52fcfd4550c8b8e9379d7b40fcd8840627e3` | cubin `d79a4f5f5b6cff913644f66bba6a958b3541a810ffe83a8de5f9ababbe43456d` |
| HiPIMS-George | 4 | 5572 | `8359aaaa1de0ccdb7d757f4b321af809cc0b72b6df14f9274f2d370de1e076cd` | cubin `5775bc0c9c040ba7b55d84bd29d0719342a2f38043dff855fea723a9c5510b3b` |

## GPU 复验

设备为 EPYC 7C13、Radeon VII（gfx906，ROCm 6.3.3，自动性能档）及 RTX 3090（驱动 620.70.06）。CPU 侧先按冻结 manifest 核对所有输入和参考文件。发布角色使用合并后重建的代码对象；SRAD32 因已知冻结工作组上限缺陷，另用各角色统一调整上限到 1024 的诊断构建做 A/A。

在同一进程载入所有角色，每批开始预热至少 200 ms。先用未融合 baseline 的两份同一代码对象做 A/A，12 轮成对比值的中位数须在 1±1%，最大除最小减 1 须不超过 3%。失败允许立即重试一次。通过后，三角色同进程轮换 12 轮，每轮检查完整输出，GPU event 区间只计 kernel。MapAiry 每角色每轮取 300 次的中位数，TIGRE 分角度各取 15 次的中位数后加总。其余输入以一个完整工作负载为该轮单个角色的时样。用逐轮配对比值的中位数及 10,000 次 bootstrap 计算 95% 区间。

21 个输入中，8 个通过 A/A 并完成三角色输出校验及比较。13 个两次 A/A 均超限，在各自 A/A 后停止计时，A/A 的完整输出校验均通过。NQU64 A/A 首次中位数／跨度为 0.999112／4.4178%，重试为 1.000889／2.8809%。SasPoint5 interval-mixture 首次为 1.000000／121.0937%，重试为 0.995764／2.3006%。

vLLM 在固定的上游 Auto DARM 0.2 阈值、开启区域复制的命令中停在首个区域复制，360 秒超时。表中使用已验证的无区域复制 Auto DARM。CED 和 TPACF 的 Auto DARM 构建沿用历史 G1／mustprogress 解析兼容方式，SW2D 沿用 G1 解析兼容方式。这三者仅完成本次 A/A。SasPoint5 与 HiPIMS-George 的已发布 cubin 逐字节匹配，且本轮都在 RTX 3090 上执行了完整输出校验。

| 场景 | 发布／baseline [95% 区间] | 发布／Auto DARM [95% 区间] | 状态 |
| --- | --- | --- | --- |
| vLLM 64K | 0.72786 [0.72573, 0.73099] | 0.82609 [0.82479, 0.82707] | 12 轮完整输出通过，Auto DARM 使用 no-region-replication |
| vLLM 128K | 0.73688 [0.72894, 0.74079] | 0.83199 [0.82665, 0.83790] | 12 轮完整输出通过，Auto DARM 使用 no-region-replication |
| MapAiry | 0.38290 [0.38255, 0.38290] | 0.69595 [0.69595, 0.69595] | 12 轮完整输出通过 |
| TIGRE | 0.51339 [0.51083, 0.51923] | 0.74469 [0.74339, 0.74499] | 12 轮完整输出通过 |
| HLLD | — | — | 无法可靠计时，A/A 0.99372／19.45%、0.99495／19.02% |
| Landau/mixed | — | — | 无法可靠计时，A/A 0.99907／14.56%、0.99629／13.98% |
| Landau/coherent | — | — | 无法可靠计时，A/A 0.98982／30.04%、1.01025／36.33% |
| SW2D | — | — | 无法可靠计时，A/A 0.99755／12.09%、1.00617／12.13% |
| CED | — | — | 无法可靠计时，A/A 1.00118／22.39%、0.98155／32.93% |
| TPACF | — | — | 无法可靠计时，A/A 0.99856／13.88%、1.00025／14.68% |
| SRAD stage2 256 | — | — | 无法可靠计时，A/A 1.00855／51.66%、0.98728／45.43% |
| SRAD stage2 1024 | — | — | 无法可靠计时，A/A 1.00711／46.56%、1.00310／21.57% |
| SasPoint5/interval-mixture | 0.47298 [0.47287, 0.47847] | 0.47656 [0.47287, 0.47835] | 12 轮完整输出通过 |
| SasPoint5/coherent-blocks | — | — | 无法可靠计时，A/A 1.00000／655.34%、1.00000／49.66% |
| SasPoint5/uniform-01 | — | — | 无法可靠计时，A/A 1.00795／5.29%、1.00000／7.00% |
| HiPIMS-George | — | — | 无法可靠计时，A/A 1.00066／8.40%、1.00075／15.86% |
| SRAD16/256 | — | — | 无法可靠计时，A/A 1.00357／49.39%、1.00004／56.69% |
| SRAD32/256 | — | — | 无法可靠计时，A/A 0.99998／58.18%、0.99303／47.68% |
| MS32 | 0.91715 [0.91164, 0.92200] | 1.02017 [1.01041, 1.02690] | 12 轮完整输出通过 |
| PCM32 | 0.80848 [0.80836, 0.80857] | 1.07327 [1.07319, 1.07332] | 12 轮完整输出通过 |
| NQU64 | 0.96571 [0.95534, 0.97253] | 1.12407 [1.11958, 1.12622] | 12 轮完整输出通过 |

### 计时排除的历史参考

以下区间从各自的历史逐轮结果按同样的 10,000 次配对 bootstrap 计算。历史数据的计时方式以原记录为准。发布／baseline 优先使用发布存档。历史 Auto DARM 对照来自 EPYC 的 `/data/home/chh/simplify-v2/build/auto-darm-release-compare/20261120-v1/` 下的 `results.json`、`compat-results.json`、`extra-results.json`。 [发布逐轮数据](../golden/20261120-anchor-release/gpu-paired.json)

| 本轮 A/A 两次超限的输入 | 发布／baseline 历史值 | 发布／Auto DARM 历史值 | 来源限制 |
| --- | --- | --- | --- |
| HLLD/65536 | 1.09276 [1.08917, 1.09846] | 0.71255 [0.71057, 0.71533] | 发布存档、上游 Auto DARM 对照 |
| Landau/mixed | 0.43045 [0.42938, 0.43086] | 0.67267 [0.67016, 0.67369] | 发布存档、上游 Auto DARM 对照 |
| Landau/coherent | 1.05970 [1.04848, 1.08539] | 0.76606 [0.76471, 0.77354] | 发布存档、上游 Auto DARM 对照 |
| TPACF/16384 | 1.19971 [1.19758, 1.20263] | 0.40067 [0.40016, 0.40116] | 发布存档、解析兼容 Auto DARM 对照 |
| SRAD-stage2/256 | 1.00435 [0.99528, 1.00971] | 1.00962 [0.98550, 1.00974] | 发布存档、上游 Auto DARM 对照 |
| SRAD-stage2/1024 | — | — | 冻结记录没有可靠时比 |
| SRAD16/256 | — | — | 冻结记录只报告正确性 |
| SRAD32/256 | — | — | 冻结记录没有可靠时比 |
| SW2D/258x259 | 1.00000 [0.99754, 1.00123] | 0.99938 [0.99572, 1.00062] | 发布存档、历史适配 Auto DARM 对照 |
| CED/110 | 0.88775 [0.86422, 0.90957] | 0.99043 [0.98651, 0.99328] | 发布存档、解析兼容 Auto DARM 对照 |
| SasPoint5/coherent-blocks | — | — | 冻结记录没有可靠时比 |
| SasPoint5/uniform-01 | — | — | 冻结记录没有可靠时比 |
| HiPIMS-George/128x128 | 1.00000 [0.99986, 1.00000] | — | 发布存档 |

### 与已知问题的对照

- **HLLD、Landau coherent、TPACF。** 本轮三者均止于 A/A。发布代码对象与原存档相同，历史的发布／baseline 分别为 1.09276、1.05970、1.19971，与已知问题的退化方向和幅度一致。现有数据无法给出新的退化估计。
- **SasPoint5。** 两种输入仍在 A/A 超限。interval-mixture 重试通过，完整输出正确，获得本轮单输入计时。
- **SRAD stage2 1024。** 两次 A/A 跨度分别为 46.56% 和 21.57%，完整输出校验通过。这与发布的计时排除状态一致。
- **PCM32。** 本轮完整 Greedy 相对 baseline 为 0.80848，相对 Auto DARM 为 1.07327。第 10 步和 `trial-33` 是同父单次试融证据，详见已知问题。完整 Greedy 产物与清理前逐字节一致，保留了原有接受判定。 [PCM32 已知问题](../../docs/KNOWN_ISSUES.md#pcm32tti-保守漏判)

原始 GPU 回执在 EPYC 的 `/data/home/chh/simplify-v2/build/final-release.kzxLp5/`。逐轮和判定在 `gpu-results/results.json`，SHA-256 为 `1aaad486d4a1109a38edac000c9ce044f4b6c683844b5816d4c45b10ac9f3738`。角色代码对象和校验和在 `gpu-roles/final-roles.json`，SHA-256 为 `a4b3e73917dfd0646af1897fa9c6e921eb79cdf083a005f04f5fe2df5c001545`。设备快照为 `final-gpu-env.txt`。
