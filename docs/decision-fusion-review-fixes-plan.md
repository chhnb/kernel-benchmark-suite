# Decision fusion: review fixes before gap planning

Baseline: `35f9ccdc1795348cfb314b3cbf750216bf5448e7` on
`review/speculation-modes`. Work is in the musa experimental checkout.

## Execution order and acceptance

1. **Separate generator policy from cleanup.** Compare `meld-raw.ll` byte for
   byte. Set `DECISION_DISABLE_SIMPLIFYCFG=1` for baseline replay. Preserve raw
   files and mode/budget settings. LLVM12 SimplifyCFG can speculate even with
   two-entry-PHI folding disabled and bonus threshold zero; those options alone
   are not a policy boundary. Mark generated protected branches and prevent
   generic SimplifyCFG from visiting them or modifying them through neighbours.
   Prefer explicit structural cleanup without conditional code motion. Test
   safe arithmetic, guarded divide/load, and complementary if/else separately.
2. **Restore/audit production cleanup compatibility.** Compare the shared helper
   to the pre-extraction implementation. Separate decision-only constant-branch
   folding from production defaults. Retain production convergence semantics.
   Build and run legacy plus B2R opt-in frozen-SHA regressions on musa. Record
   expected and actual hashes; investigate every mismatch rather than refreshing
   goldens. Decision-model checks do not substitute for this regression.
3. **Harden boundaries and identity.** Require entry dominance and exit
   postdominance for every scoped block; audit outside instructions. Fail on
   unsupported target / target-machine construction, with explicit TTI source.
   Scope convergent rejection to the affected decision tests, condition prefix,
   two arms and join; retain a test with an unrelated barrier outside the trial.
   Audit replication metadata. Give cloned block identities deterministic derived
   IDs while preserving source provenance; reject ambiguous root resolution.
4. **Numerics and independent controls.** Add DECISION_CONDITION_BUDGET, with
   default 4, independent of DECISION_SPECULATION_BUDGET. In non-IEEE denormal
   modes conservatively skip floating interval simplification involving denormal
   constants; cover function attributes and NaN/zero boundary fixtures.
5. **Candidate acceptance.** Wire the existing uniform-side loss metric and a
   documented pressure bound into decision-greedy acceptance. Fail closed for
   incomplete required metrics. Persist thresholds and rejection reasons.
   IR pressure is only a proxy: final backend VGPR/SGPR/spill reporting remains
   required. Recheck which historical tree actually spilled before quoting it.
6. **Header hygiene.** Replace header-local static definitions with inline
   functions where appropriate, and remove namespace imports from shared headers.
   Compile both decision-fuse and fusion-search consumers.
7. **Deferred: planGaps (outside the current request).** If separately requested, restore the isolated WIP,
   reconcile it with the corrected policies, and rerun raw-IR byte comparisons
   across none/legacy/budget and coalescing on/off. Then add deterministic match
   splitting and segment speculation/protection, using the same plan as emission.
   Strictly decreasing cost and visited-state tracking prevent cycles. Document
   the single-pair local optimum limitation and conservative dependency handling.

## Saved WIP and existing evidence

The initial planGaps extraction and materialized-cost search are saved in a Git
stash named `WIP gap planning and materialized cost search before review fixes`.
They are not part of the baseline and must not be treated as validated search.
The extraction-only experiment compared raw and later IR for 27 Map-Airy trials
and six coalescing/mode combinations. VLLM replay was also launched; inspect its
completion receipt before claiming success. These checks do not validate the
subsequently added, unfinished cost-search implementation.

Remote build evidence: `build/decision-fuse/gap-plan-equivalence-v1/`,
`gap-plan-equivalence-v2/`, and `gap-plan-baseline/`. Preserve the checkpoint
binary in `gap-plan-baseline/decision-fuse`.

## Required reporting

Each review item must be marked pending, implemented, or verified separately.
Include test command, binary/source revision, expected/actual frozen hashes and
raw-IR comparison results. Do not claim performance parity from static costs.
Do not silently delete a failed trial or update a frozen reference.

Current scope: review fixes only; gap planning remains isolated and is not resumed.

## 修复进展（2026-11-10）

本次范围仅为 review 修复和回归，**不恢复或实现 planGaps**。上面的第 7 步保留为历史后续建议，不属于本次执行范围。

- 已实现：trial 清理改为显式结构清理，移除 generic SimplifyCFG 的隐式投机路径。安全计算和 volatile load 都保持保护分支；空块、死 φ、常量分支仍可清理。清理不使用 TTI，因此也不存在 target lookup 失败后退到通用 TTI 的路径；trial 明确记录 `cleanup_structural_no_tti`。
- 已实现：生产 `fusion_search` 独立恢复提取前的 cleanup 固定点逻辑和 `moduleHash` 收敛判断，避免 decision 专用的常量折叠改变生产行为。
- 已实现：convergent 检查限于 trial 的 tests、两个 arm 和 join；区域外 barrier 的正例通过，区域内 convergent 的反例拒绝。
- 已实现：trial 区域检查 entry 支配与 exit 后支配；不满足 SESE 时拒绝。共享清理头文件改为 inline，移除命名空间级 `using namespace llvm`。
- 已实现：`DECISION_CONDITION_BUDGET` 与 `DECISION_SPECULATION_BUDGET` 独立，默认均为 4；none 模式仍允许条件预算范围内的安全条件提升。
- 已实现：非 IEEE denormal 模式遇到 denormal 比较常量，保守跳过区间化简。
- 已核查：当前 RegionReplicator 新建基本块和分支，未发现通过 CloneBasicBlock 复制 `decision.origin` 的路径。没有凭空添加 clone ID；greedy 增加重复 decision ID 的明确拒绝，并补测试。
- 已实现：greedy 同时要求严格 TTI 收益、压力限制及两个均匀 side 的成本限制；所需指标不完整时拒绝。使用生产 side-reachability 方法，按 worker 的 accepted instruction costs 求和。

接受条件的配置：

| 环境变量 | 默认 | 含义 |
| --- | ---: | --- |
| `DECISION_MAX_UNIFORM_LOSS` | 未设置：关闭 | 显式设置非负值后，限制每个 uniform side 的 TTI 成本增长 |
| `DECISION_MAX_PRESSURE_GROWTH` | 0 | 相对当前 parent 的 peak_slots32 允许增长量 |
| `DECISION_MAX_PRESSURE` | 1000000 | peak_slots32 绝对上限；实际默认约束来自“不增长” |

IR slots 是静态 liveness 代理，不是 VGPR/SGPR 分配结果，不保证消除后端 spill。以上阈值没有按 vLLM 结果调参。

已完成验证：

- 新增测试覆盖预算独立、区域外/内 convergent、FTZ denormal、SESE 侧入口、压力/均匀损失/缺失指标拒绝、重复身份拒绝及 report 一致性。
- 6620 个整数/浮点条件函数、460800 次执行结果一致，包含 NaN、无穷、正负零和边界。
- 三次连续融合，以及递归/平衡树各七次融合，每一步 201 个输出一致。
- 生产主线 `legacy + cross-level-b2r=1`：VLLM 224 次提交；Map-Airy 16 次提交、1337 个 trial。
- VLLM 最终 hsaco SHA 与冻结参考相同：`adc38fb80b4460edd9c442c08e5bc23ecd66c0186a6128a36f79df4bd0a362a9`。
- Map-Airy 最终 hsaco SHA 与冻结参考相同：`affe64a238c73c36aa5704f46b50becdd2f8d4902b355536fa83745bea098422`。

验证入口：`tests/decision-model/review_fixes.sh`，在 musa 上通过 CPU admission wrapper 执行。IR 转换和最终代码生成均使用 LLVM12；独立 LLVM24 worker 仅用于复现既有 TTI 评分配置。

远端证据：`build/review-evidence/`；失败的脚本执行记录也予以保留，未更新任何冻结参考。

最终补充验证：

- SESE 侧入口和提前返回反例均拒绝。
- 三种 speculation 模式下，chain 与 VLLM 第一对的 `meld-raw.ll` 共六组对比均逐字节相同。对比基准 binary SHA：`a6efd667ee699954df84a1190e9d183555648dbc43ffb1c1276e09e964d3d9e7`。
- TIGRE：2 次提交、19 个 trial；最终 hsaco SHA 与冻结参考相同：`3db26ca4a829da96931c5ef7f8b8e769b22c8e05e474ed046b30ffc865024a2a`。
- 最终重新编译 decision-fuse、decision-greedy 和生产 fusion-search 的消费者通过。
- 这是修复和静态/等价性回归；本轮没有重新测 GPU 耗时，也不将 IR pressure 解释为硬件寄存器分配保证。

代码与测试改动保存在实验 checkout 的工作区，未同步主项目目录，未恢复 stash，未推送本次修复。

真实 worker 指标检查（VLLM 第一对，none，条件预算 4）：总成本 `5423 → 5412`，peak_slots32 `81 → 81`；静态 uniform-side gain 为 false `-72`、true `+6`。因此默认 `DECISION_MAX_UNIFORM_LOSS=0` 会拒绝该候选，尽管全函数 TTI 有收益。这里是保守静态可达块成本，不能当作实测 uniform wave 耗时。若要放宽，应显式配置阈值并另做性能验证；本次没有为让 vLLM 通过而调整默认值。


## 最新调整：uniform-side guard 默认关闭

按用户要求，暂时不使用尚未校准的 uniform-side 损失作为默认拒绝条件。未设置 `DECISION_MAX_UNIFORM_LOSS` 时，summary 记录 `uniform_loss_guard_enabled=false`、`max_uniform_loss=-1`。仍然记录可获得的 side 指标；缺失 side 指标也不会单独导致拒绝。

显式设置 `DECISION_MAX_UNIFORM_LOSS=0` 或其他非负值才启用该 guard，此时指标缺失仍拒绝。压力限制和全函数严格 TTI 收益检查保持生效。因此上文 VLLM 第一对的 `-72` 不再作为默认拒绝理由，最终是否接受仍取决于其余检查。

## 后续授权与最终更新

上文“暂不恢复 planGaps”的范围后来被用户明确的新指令替换：纯规划已抽取，none/legacy/budget 的24组真实trial在原始与清理后阶段均逐字节一致。cost仅有未完成验收的原型，不属于本轮稳定配置或性能验收。

当前已验收的独立开关为 `DECISION_CFG_CLEANUP=structural|full`。四项 none+full 均复现35f9ccd的提交顺序与最终SHA；四项GPU正确性全通过。当前对照统一使用非约束的压力上限，以单独研究清理方式。详细数据、参数和指标含义见 `decision-cfg-cleanup-modes.md` 及 `docs/evidence/cleanup-comparison-v1/`，本地报告为 `outputs/cleanup-comparison-report.md`。

CPU优化已启用：反向liveness迭代，以及复用审计ModuleSlotTracker。同配置160次提交/876个trial，后者使整轮耗时由487秒降到396秒，提交序列及最终二进制相同。原始checkpoint重放使用未修改可执行文件作为参照。

full默认选项的隐式投机只作诊断记录，保留全函数convergent拒绝。诊断worker失败不会拒绝合法full trial；full目标TTI不可用仍明确拒绝。新CFG设置与旧DISABLE_SIMPLIFYCFG同时出现时显式报错，防止标签与实际执行不一致。代码尚未commit/push。
