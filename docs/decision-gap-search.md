# Auto Greedy gap search

The normal entry point is:

```
build/decision-fuse/decision-greedy INPUT FUNCTION NEW_OUTPUT
```

With the structural engine and LLVM24 worker built, Auto Greedy prepares
adjacent arms and submits explicit block or region pairs to the shared
`fusion-search` trial. It defaults to cost-based speculation and
`darm-cfg-dce` cleanup. For supported direct B2B diamonds, the trial plans
a shared arithmetic prefix, a shared arithmetic suffix, or both. A bounded sequence alignment also
finds identical arithmetic with operands available before the split. The
original branch controls the arm bodies and their memory accesses. A
diamond with no supported arithmetic
match retains its two exit edges. These plans do not run gap search.

Other candidates use the general trial, which compares its default with
up to four alternative alignment or guard plans. Both paths rank legal
plans by LLVM24 whole-function score against the same cleaned control.
Unknown local costs keep work guarded. Pressure and uniform-wave metrics
are diagnostic only.

The three-argument entry uses these settings even if the environment contains
legacy experiment flags. Pass an explicit tool root as the third argument
(with the output directory fourth) when reproducing an experiment that uses
those flags. Both entries accept the optional backend checkpoint for diagnostics.

Each shared trial directory contains a `request.json` with the parent IR,
candidate ID and `replay_args`. To replay, append `--gap-replay` with the
path to `structural/trial-0/trial.json`, then provide new `--out` and
`--debug-dir` paths. Use the same tool build and scoring worker. The report
contains the selected layout or alignment and speculation IDs, along with the
cleaned IR hash.

## Legacy decision-fuse experiments

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
greedy search can apply its final TTI acceptance check and report resource diagnostics.

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

Set `DECISION_GAP_EARLY_SCORE=1` with structural cleanup and in-memory gap search to stop an inner trial after raw IR verification if its throughput
score cannot beat the incumbent. These attempts are marked `score-only` in
the trace. The default LLVM24 worker and the optional in-process vLLM scorer
both support this path. Improving candidates still pass the full cleanup, scope audit,
and binding checks before they can become incumbents.

On Linux, in-memory gap search reuses a summary-only LLVM24 worker across
the gap plans for one block pair. Set `DECISION_PERSISTENT_TTI=0` to disable reuse. Custom TTI workers and
file-based trial execution use the existing one-shot protocol. Set
`DECISION_FUSE_TIMINGS=1` to report process CPU time for module cloning,
meld, the two trial verifier calls, and empty-diamond folding.

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
