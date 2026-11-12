# Experimental matching and gap search

Based on checkpoint `38565fe`. Enable explicitly with `DECISION_GAP_SEARCH=1`
on the decision-fuse / decision-greedy path. Supported speculation configurations
are `none` and `cost`; the existing cost-threshold prototype remains available
when search is disabled. Existing structural/full cleanup selection is retained.

```
DECISION_GAP_SEARCH=1 DECISION_SPECULATION=cost DECISION_CFG_CLEANUP=structural \
  build/decision-fuse/decision-fuse INPUT FUNCTION DECISION LEFT NEW_DIR
```

Search starts with the existing alignment and every gap protected. Each round
fully rebuilds disposable candidate IR from the same input. It considers:

- Splitting a nonstructural match in place into adjacent left/right gaps.
- For a new split in cost mode, the four protected/speculated plans of its two
  new instructions, subject to the common safety/dependency checks.
- Switching an existing safe gap to speculation, or switching a speculated gap
  back to protection. Adjacent guards and complementary diamonds are planned
  jointly by `planGaps`, including existing range coalescing when enabled.

Basic-block, PHI, terminator, EH-pad and alloca matches cannot be split. IDs are
original alignment indices; gap instruction IDs are `2*index + side`. They do
not depend on allocator addresses or the rewritten sequence's positions.

The reference objective is the existing pinned LLVM24 worker's whole-function
reciprocal-throughput TTI on `meld-raw.ll`, with unknown costs rejected. Each
candidate is actually generated and verified before scoring, so selects are
counted per operand position, guard sharing and carrier/live-out PHIs are
included, and no later CSE/SimplifyCFG savings are assumed. There is no special
i1 multiplier. This is intentionally more expensive than a local estimator.
The generator executes the same gap plan that reports its segment decisions.

Explicit requests reuse the current cost policy's safety and availability
checks; the local cost threshold is replaced by the search objective for these
requests. The existing transitive protected-definition check includes intervening
matched computations/selects. An infeasible explicit plan is rejected rather
than silently executed with a different decision. Attribute sanitization follows
the checkpoint policy, after eligibility has been checked.

Only strict improvements are accepted, with deterministic alignment/segment
order for ties. Visited states are retained and each split is irreversible.
`gap-search.json` records every attempted state, rejection, cost and accepted
step. The selected IR and reports use the ordinary trial output paths so outer
greedy search continues to apply its final TTI, pressure and configured
side-loss acceptance checks.

On Linux, the default search parses the parent module once, clones it in process
for each candidate, and passes raw IR and aggregate TTI through anonymous memory
descriptors. Rejected candidate artifacts are not written to the filesystem.
The trace keeps every attempted state, outcome and score. The selected plan is replayed before its IR and report files are published.
The worker path checks raw IR equality and the in-process backport checks
throughput cost equality. Structural-cleanup trials compute pressure and side
reports only for the selected plan.
Set `DECISION_GAP_KEEP_TRIALS=1` to retain all candidate artifacts and detailed TTI.

Set `DECISION_VLLM_LLVM24_TTI=1` to try the in-process throughput backport
for the Linux `gfx906` vLLM `cache_eval` gap search. This overrides the branch,
freeze, alloca and three AMDGPU intrinsic costs that differ on the checked
vLLM IRs. Other instruction queries use LLVM 12 TTI. The pinned worker remains
the default and the oracle for parity checks. This option does not change
speculation cost policy, outer greedy scoring, cleanup diagnostics or codegen.

For the fixed vLLM schedules, run `tools/run_vllm_fixed_tree.py` with
`balanced` or `recursive` and a new `--out` directory. The driver receives
only the ordered decision roots over stdout and keeps a rolling fused IR
checkpoint. Set `DECISION_GAP_KEEP_CATALOG=1` to keep full catalogs and IR
snapshots for debugging. Existing direct callers keep the file-based catalog
unless they opt into `DECISION_GAP_ROOTS_STDOUT=1`.

Set `DECISION_GREEDY_JOBS=4` to evaluate up to four outer greedy candidates
concurrently. Each batch shares the current parent IR. Candidate numbering,
ranking and tie-breaking still follow adjacency order. The default is one
worker, and each new round starts after the previous decision is committed.

Set `DECISION_GAP_EARLY_SCORE=1` with the in-process vLLM scorer and structural
cleanup to stop an inner trial after raw IR verification if its throughput
score cannot beat the incumbent. These attempts are marked `score-only` in
the trace. Improving candidates still pass the full cleanup, scope audit,
and binding checks before they can become incumbents.

Limitations: this is single-match / single-segment greedy search, with small
joint plans only for the two newly split instructions. It does not exhaustively
split multiple matched pairs together, independently move segments, or flatten
arbitrary SESE regions. Complex region legality remains the existing analyzer,
replication and trial-verification responsibility. TTI is a static objective;
IR pressure is not a hardware register-allocation guarantee.

Verification entry: `bash tests/decision-model/gap_search.sh` through CPU admission.
Tests cover four-to-three selects in cost mode, four retained in none mode,
expensive fdiv match retention, strict cost descent, deterministic replay,
complete CPU output comparison including NaNs/infinities/signed zeros,
transitive protected-definition dependencies and a shared complementary guard.
Large disposable trials and baseline comparisons remain under
`build/gap-restart-38565fe/` on musa. No frozen reference is changed.

## VLLM full acceptance, 2026-11-11

Complete records: `evidence/gap-acceptance-v1/`. Both fixed shapes completed 224
verified fusions. All three candidates pass exact generated-output validation at
65,536 and 131,072 tokens; measurements use three batches with 3 warmups and 15
samples per batch under the existing serial GPU admission protocol.

| Strategy | VGPR/SGPR | spills | selects / i1 selects | 64K ms | 128K ms | Performance result |
| --- | --- | --- | --- | --- | --- | --- |
| recursive | 50/76 | 0/0 | 276/0 | 2.10864 | 4.18192 | pass |
| balanced | 53/76 | 0/0 | 276/0 | 2.10800 | 4.18192 | pass |
| default greedy | 78/76 | 0/0 | 200/0 | 2.53232 | 5.02912 | fail |

Select counts are final post-O3 counts. Each final post-O3 module has 32 copysign
calls. Fixed-tree performance differs from its paired frozen reference by less
than 0.04%; default greedy is 20.13%/20.27% slower, exceeding the 2% gate.
The dataset is generated synthetic input, not historical Qwen KV tensors.

Default greedy accepts 138 of 812 trials, TTI 5423 -> 3905. All outer trials
verify; 666 are rejected by uniform-side loss and 8 by IR pressure. This run
retains the current cost+structural defaults (uniform loss 0, pressure growth 0).
The fixed schedules force all valid pair fusions and do not use those outer
acceptance gates. The results establish the achievable fixed-tree benefit;
they do not establish that relaxing either gate alone fixes default greedy.
Do not remove the local-union reference on the basis of this acceptance.

The slow reference search required CPU checkpoint continuation. A dedicated
continuation controller preserves completed rounds, checks original target/order
metadata, configured limits and accepted parent TTI, and archives interrupted
attempts. A fixture reproduces uninterrupted rounds and final IR byte-for-byte.
The first fixed-tree CPU job reached its 1800-second limit; verified parent IR
and final input hashes were checked before reuse. Failed/interrupted receipts
remain in the build directory.

The LLVM24 worker now reuses ModuleSlotTracker for diagnostic instruction text.
Twenty real candidates have identical full JSON output before/after this change;
a measured worker invocation drops from ~76ms to ~50ms. Cost definitions and
pinned LLVM revision are unchanged. This is an output-generation optimization.
The GPU summary's source_commit identifies the main benchmark runner checkout;
the transform base is 38565fe with uncommitted changes and explicit source hashes
in this evidence directory. Frozen references were not changed.

## Greedy acceptance gates on epyc

The original `cost` + structural greedy run used
`DECISION_MAX_UNIFORM_LOSS=0` and `DECISION_MAX_PRESSURE_GROWTH=0`.
All 812 outer trials verified. The greedy search committed 138 fusions.
The recorded rejection reason was `uniform_loss_limit` for 666 trials
and `pressure_limit` for 8. All 674 rejected trials reduced whole-function
throughput cost. Pressure is checked first, so six of the eight pressure
rejections also exceeded the side-cost limit.

The side gate sums static TTI over blocks conservatively reachable with
the selected condition set to true or false. For example, the first
two-leaf fusion in the first quantization tree reduced whole-function TTI
from 5368 to 5357. The true side saved six points and the false side
increased by 72 points, so the zero-tolerance gate rejected it. The
pressure gate uses estimated peak live 32-bit IR slots. One E4M3 decode
candidate saved eleven TTI points and improved both side scores but was
rejected for increasing its estimate from 81 to 82. Neither metric is a
GPU timing or a hardware register-allocation measurement.

The relaxed run set both limits to 1000000. No candidate hit either
limit. IR verification and the strict whole-function TTI improvement
requirement still applied. Greedy evaluated 908 candidates and committed
236 fusions, including all 224 tree-internal fusions and 12 outside those
trees. Greedy's final throughput score was 2795, versus 3905 with the
original gates and 2927 for the fixed balanced schedule.

| Variant | Committed fusions | Remaining copysign calls | 64K | 128K |
| --- | ---: | ---: | ---: | ---: |
| Original greedy, earlier run | 138 | 128 | 2.636 ms | 5.139 ms |
| Relaxed greedy | 236 | 32 | 2.228 ms | 4.305 ms |
| Fixed balanced tree, paired with relaxed greedy | 224 | 32 | 2.167 ms | 4.335 ms |
| Unfused baseline, paired with relaxed greedy | 0 | 256 | 3.021 ms | 5.919 ms |

These are kernel medians on the same Radeon VII, with three warmups and
15 measured launches per variant and input. Both sizes passed exact
generated-output validation. The relaxed candidate had zero spills and
reduced time versus its paired baseline by approximately 26% and 27%.
It was 2.8% slower than balanced at 64K and 0.7% faster at 128K. Both
limits changed together, so the measurements do not isolate their
individual effects or change the default acceptance policy.

For the same relaxed configuration, four outer workers reduced search
wall time from 480.06 s to 246.41 s. Early scoring reduced it further to
179.30 s. Of 6296 inner gap plans, 4392 could not beat the incumbent
after verified raw-IR scoring and skipped late validation. All 908 outer
candidate results, 236 commits and the final IR matched the serial run.
The optimized configuration used `DECISION_GAP_SEARCH=1`,
`DECISION_SPECULATION=cost`, `DECISION_CFG_CLEANUP=structural`,
`DECISION_VLLM_LLVM24_TTI=1`, `DECISION_GREEDY_JOBS=4` and
`DECISION_GAP_EARLY_SCORE=1`. This is a generated-input GPU comparison.
The frozen runner and reference binaries were unavailable on epyc, so
the formal frozen 2% regression gate was not rerun.

## Per-arm uniform-cost diagnostics

Set `DECISION_UNIFORM_REPORT=1` to record per-arm cost for verified outer
trials. This mode leaves the existing acceptance gates in charge. The
report compares the original decision entry through its original join,
excluding the join and everything after it. Each original arm's path
facts are used on both IRs. Scalar comparisons on one value share exact
integer or floating-point cells, including a separate NaN cell. Duplicate
`fabs` and deterministic cast expressions use the same key. Multi-variable
relationships and unrecognized values remain unknown.

When a conditional branch cannot be proved under the facts, both
successors contribute to the static cost. PHIs merge only reachable
incoming edges. A cyclic or leaking decision scope yields unavailable
data. For each arm, the before-path invariant compares the calculated
set against its original tests and arm blocks. The invariant is recorded
even if it fails.

The report sums LLVM 24 reciprocal-throughput TTI over the reachable
blocks. It records the raw delta, surviving approved gap speculation,
surviving eager condition hoists, and the residual. The trial tracks surviving instructions through cleanup and marks them
when collecting coordinates. It removes the markers before publishing
the IR. The report joins the coordinates with the worker's instruction
costs. A marked instruction is counted at
most once. These are static sums, with no path-probability weighting.

In the archived vLLM trial that previously reported +72 on the false
side, the per-arm delta is +2. The eager comparison accounts for 1 point,
gap speculation contributes 0, and the residual is +1. The earlier 70
points came from later test and leaf blocks that are unreachable under
the original arm's comparison facts.

## Decision checkpoints

The greedy driver defaults to `DECISION_SPECULATION=cost`,
`DECISION_CFG_CLEANUP=structural` and `DECISION_CHECKPOINT_MODE=enforce`.
It probes the input triple and CPU with the same LLVM 12 TargetMachine
used by the speculation pass before scoring candidates. Use
`DECISION_CHECKPOINT_MODE=report` to inspect endpoints without rolling
them back. Both modes retain the hard IR pressure cap
(`DECISION_MAX_PRESSURE`) and require each selected trial to verify and
strictly improve function TTI. The per-step growth gate applies only
with checkpoints off. The legacy `DECISION_MAX_UNIFORM_LOSS` defaults to
disabled in all modes and is deprecated. Explicit values are honored
only with checkpoints off and structural cleanup. Direct invocations
of the pair tool keep their own defaults.

The executable in `DECISION_CHECKPOINT_TOOL` receives the snapshot IR path
and kernel name. If unset, the driver uses the repository AMDGPU adapter.
The executable returns JSON containing VGPR and SGPR counts, their
spill counts, and active blocks per CU. The AMDGPU adapter is
`tools/decision_amdgpu_checkpoint.py`. Configure the LLVM 12 bin directory
with `DECISION_AMDGPU_LLVM_BIN`, the GPU with `DECISION_AMDGPU_CPU`,
target features with `DECISION_AMDGPU_FEATURES`, and the launch size with
`DECISION_AMDGPU_BLOCK_SIZE`. Build `tools/decision_amdgpu_occupancy.cpp`
with `hipcc` and set `DECISION_AMDGPU_OCCUPANCY_TOOL` to its executable.
The occupancy probe assumes zero dynamic shared memory. Set the visible
HIP device to match the target before running the search.

Each endpoint is compared with the decision's starting resources.
Increases in either spill count or decreases in active blocks per CU
fail the check. On failure in enforce mode, the driver searches
backwards for the longest passing prefix and blacklists the next pair
by its original arm identities. Backend admissibility can alternate
between prefixes, so a binary search can miss a longer passing prefix.
The compiler cache reuses the preceding decision's endpoint and any
already checked rollback prefix. `DECISION_CHECKPOINT_RETRIES` defaults
to four continuation attempts after rollback.

Checkpoint reports also contain cumulative uniform costs for the
original arms, with each value evaluated from the decision's initial
predicates in the endpoint CFG. Candidate reports carry coordinate
mappings for surviving predicate operands and marked instructions.
The endpoint subtracts surviving approved speculation and condition
hoists once per instruction. The cumulative side cost is diagnostic.
Unsupported scopes yield unavailable cost data. The existing
`tests/decision-model/check_greedy_report.py` audits selection, the
checkpoint comparisons, the rollback prefix, the blacklist, and the
number of retained commits.

The vLLM acceptance run used gap search and the vLLM scorer
(`DECISION_GAP_SEARCH=1`, `DECISION_VLLM_LLVM24_TTI=1`,
`DECISION_GAP_EARLY_SCORE=1`). All 44 decisions passed their backend
checks. The 236 selections included 224 tree merges and produced
51 VGPR, 76 SGPR, zero spill and 16 active workgroups per CU. A
forced-spill checkpoint exercised rollback and blacklisting. Four
alternating-order batches against balanced gave median paired deltas of
−0.05% and +0.18% at 64K and 128K. The paired 95% mean-difference
intervals were [−2.36%, +1.94%] and [−1.14%, +1.76%], respectively.
Both include zero under the chosen acceptance rule. The intervals are
wider than ±0.5%, so this run does not establish equivalence within that
margin. All 280 vLLM cumulative side-cost residuals were negative.
Keep the cumulative metric in report mode pending evidence on
positive residuals and GPU performance.

Retire the local-union reference only after all four workloads pass the
2% frozen-reference gate and paired vLLM results satisfy the agreed
noise criterion against local-union. Preserve the comparisons before
removing the reference path. When timing exceeds 2%, use the recorded
endpoints to shortlist decisions, then rerun with each suspect decision
omitted and remeasure on the same GPU and inputs. Rebuild the subsequent
search from the changed state for each omission.

## Decision joins and pair-local exits

Discovery walks the portion reachable from each arm entry and dominated
by it, stopping at the decision join or a boundary edge. The catalog
records the outgoing targets of that private portion. Adjacent arms
can be paired when both have exactly one target and that target is
their nearest common postdominator. A pair exposed through an outer
test-only prefix keeps its canonical nested owner if that owner
already exposes the same entries at its regular decision join.

Normalization splits the two arms' incoming edges to the selected
join. For a pair whose join differs from the decision join, scoped
cleanup retains that split boundary and the branch to the shared
suffix. The decision join still defines the uniform-cost accounting
scope, including reachable shared suffixes. Both joins appear in
verified trial reports.

For a pair with a SESE arm, greedy generates both a single-anchor trial
and a protected multi-anchor trial from the same parent. Both go through
verification, LLVM24 TTI scoring and the usual pressure checks. The
lowest eligible TTI wins. Ties preserve the previous preference
(multi-anchor for a local exit and single-anchor for a regular exit).
Both trial reports record `pair_plan_scores`, including rejection
reasons when a plan cannot produce a score. Linear pairs retain one
B2B trial. The multi-anchor plan shares the complete-leaf implementation. This plan moves only mandatory load
dependency chains to their own leaf prefix and aligns compatible
mutually exclusive blocks under the original selector. The compound
plan is verified and scored once. The existing same-join plans and
their gap search continue to use their existing alignment paths.

### Hypersonic and vLLM replay

The recovered Hypersonic no-JT input selects the complete L1 + L2 pair.
Its trial uses `complete-leaf-multi-anchor`, with `%if.end52` as the
pair join and `%cleanup65` as the decision join. Four anchors move 22
mandatory load-chain instructions and reduce LLVM24 TTI from 1915 to
1810. The following local merge reduces it to 1787. Both transactions
pass. On the L1 + L2 checkpoint, VGPR count goes from 92 to 91 and SGPR
count goes from 54 to 62. Both endpoints have no spills and two active
workgroups per CU. The single-anchor plan scores 1938 for this same
pair, and the four-anchor plan scores 1810. The unmerged parent scores
1915. After rebinding, the merged arm still exits
at `%if.end52`, since L0 also reaches it. L3 exits at `%cleanup65` and its
store leaves the arm unsupported.

The Radeon VII synthetic replay used the same recovered IR and input for
all roles. All outputs agreed exactly. The medians were 2.023 ms unmerged,
1.992 ms with the original greedy, 1.963 ms with the archived explicit
plan, and 1.957 ms with the current greedy. The last role reduced the
median paired time by 3.25% versus unmerged and was effectively tied
with the archived explicit plan on that input. The historical frozen-input
experiment measured 4.86% and 4.81% on steps 1 and 24. Those input files
were unavailable for this replay, so the current frozen 2% gate remains
unverified.

Trial reports include the must-execute status of each anchor on each
side, skipped anchor pairs with their reasons, and native segment
decisions tagged by anchor. The Hypersonic trial used one must-execute
pair on both sides and three optional pairs. In a separate first-pair
ablation, the required-only plan ran in 1.986 ms and the complete plan
in 1.963 ms, against 2.022 ms unmerged on the same synthetic input. The
required-only TTI was 1931, above the unmerged 1915. The strict static
gain rule would therefore reject that plan despite the measured
speedup. This is a known ranking limitation for guarded multi-anchor
plans. Reconvergence and load motion are possible contributors.
These measurements
compare the two compound plans. Individual optional-anchor effects
were not isolated.

An anchor can be guarded by control flow on both sides. Its performance
depends on how AMDGPU StructurizeCFG and code generation lower the
guarded reconvergence. The GPU timing evidence here applies to gfx906.
The checkpoint measures occupancy and spills. The benchmark checks
timing effects that those resource metrics cannot detect. Gap search
still does not prune the component matches of the composite plan.

The vLLM replay evaluated 908 trials and retained the original 236
selections, including 224 tree merges. The ordered pair IDs and TTI
scores matched. LLVM12 bitcode was byte-identical, and the textual IR
differed only in the ModuleID path.

The plan-choice replay kept the original selected sequence and final
LLVM12 bitcode in vLLM (236 selections), Map-Airy (25), TIGRE (5), and
Hypersonic (2). Hypersonic selected the multi-anchor plan above. Three
TIGRE pairs selected single-anchor after the multi-anchor trials found
no compatible anchors. Map-Airy evaluated one additional plan without
changing its selection. These results were obtained on epyc.
The musa machine has an NVIDIA TITAN V, and the frozen references are
AMDGPU gfx906 code objects. The frozen three-case performance gate
requires a compatible AMD GPU and the original reference files and
fixtures.
