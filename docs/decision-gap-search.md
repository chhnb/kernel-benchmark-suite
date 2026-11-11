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
step. The chosen child's IR/report files are copied to the ordinary trial output
paths so outer greedy search continues to apply its final TTI, pressure and
configured side-loss acceptance checks.

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
