# Decision fusion checkpoint before gap planning

2026-11-10. Experimental checkout on musa:
`/home/chh/kernel-benchmark-suite-review-speculation`.
This checkpoint precedes `planGaps` extraction and match pruning; neither is implemented.

## Implemented

- Decision/Arm discovery, persistent provenance and adjacent-pair normalization.
- Safe, budgeted condition hoisting; otherwise short-circuit normalization.
  The dominating first condition selects the arm directly. Only escaping prefix
  definitions receive bridge PHIs, including definitions in multi-block prefixes.
- Same-value integer/floating comparison DAG simplification, including ordered /
  unordered floating predicates and NaN partitions.
- Single-pair RegionMelder bridge, scoped CFG cleanup and scoped SimplifyCFG.
  The SimplifyCFG two-entry PHI folding threshold retains LLVM's default.
- Per-decision greedy search using whole-function LLVM24 TTI cost. A candidate
  must strictly improve cost; ties retain the first candidate in catalog order.
- Stable decision/left/right IDs are resolved after order metadata is installed.
  The greedy driver checks actual identities before scoring a successful trial.
- Short-circuit condition-prefix metadata preserves discovery through inverted
  selectors. Rebinding uniqueness and LLVM verification remain required.
- Per-trial IR pressure diagnostics; final compiler register/spill metadata is
  recorded by the experiment drivers.

`DECISION_SPECULATION=none|legacy|budget` controls unmatched-instruction handling
(default `none`). `DECISION_SPECULATION_BUDGET` defaults to 4 and is also used for
safe condition hoisting. A proposed `cost` mode is not implemented.

## Build and checks

```
bash tools/build-decision-model
bash tools/build-decision-fuse
bash tools/build-decision-greedy
python3 tests/decision-model/run.py
python3 tests/decision-model/fuse_check.py
python3 tests/decision-model/full_tree_check.py
python3 tests/decision-model/identity_check.py
```

LLVM12 is required by the build scripts. LLVM24 TTI uses the existing
`tools/run-llvm24-tti` worker and its pinned revision. Run compilation and
experiments through the project's CPU admission wrapper on shared machines.
Additional C++ checks cover interval simplification and scoped cleanup.
The checkpoint verification log in the evidence directory records the checks run.

Pair CLI (numeric compatibility retained):

```
decision-fuse INPUT FUNCTION DECISION_INDEX LEFT_INDEX NEW_DIR [ORDER_JSON [PAIR_JSON]]
```

`PAIR_JSON` contains `decision`, `left`, and `right` IDs. They must resolve to
exactly one adjacent pair; there is no fallback to numeric indices when supplied.

Greedy CLI:

```
decision-greedy INPUT FUNCTION TOOL_ROOT NEW_OUTPUT
python3 tests/decision-model/check_greedy_report.py NEW_OUTPUT/summary.json
```

## Verified results and limits

Map-Airy: the 13 previously rejected trials all pass replay. A fresh search has
99 scored trials, no rejection, 25 commits, and TTI 6402 -> 4183. The strengthened
report audit checks requested versus actual pair identity as well as selection.
Generated-input GPU validation passes; VGPR/SGPR = 37/44, both spill counts zero.
Candidate median = 24.960 us versus frozen reference = 24.640 us (+1.30%), within
the existing 2% performance limit. This is the generated mixed-input fixture,
not a claim about every Map-Airy distribution.

CPU tests include guarded loads/division, inverted short-circuit selectors,
multi-block prefix escaping selectors, stable-ID requests after catalog reorder,
and seven recursive / balanced fusions with all 201 outputs compared at each step.

The VLLM balanced-tree artifact still has 404 selects (128 i1 selects).
LLVM12 and LLVM24 InstCombine, repeated InstCombine, and
AggressiveInstCombine + InstCombine do not reduce those counts. A standalone
four-select pattern also remains unchanged. The current greedy and fixed-tree
performance evidence does not establish parity with the frozen local-union
reference; do not remove that path on the basis of this checkpoint.

The historical DARM-native-greedy comparison uses different search/build scopes:
VLLM merges a helper before kernel expansion; old Map-Airy retains a helper call.
It is an end-to-end artifact comparison, not an isolated scoring-policy ablation.
During diagnostic section extraction, an objcopy invocation touched source
binaries and interrupted the first measurement. All eight binary contents were
restored to their pre-analysis SHA256; the second complete measurement uses
independent copies. The restoration receipt and completed measurement summaries
are retained alongside the comparison evidence.

## Next step

First extract a shared gap plan without changing IR. The plan must represent
alignment order, range coalescing/reordering, segment dependencies and jointly
protected complementary gaps. Verify byte-for-byte output against this checkpoint
before adding pruning. Then implement deterministic, full-rescoring single-pair
pruning against actual plan cost, including operand-position selects and live-outs.
Do not introduce an arbitrary i1 multiplier into TTI. Single-pair pruning cannot
find improvements requiring several matches to be split together; document that
limitation. Final trial TTI and register checks remain necessary.

Historical prototype/normalization documents describe earlier stages, not this
checkpoint's full pipeline. Large IR, binaries, generated inputs and toolchains
remain in musa's build directories; only compact evidence is versioned here.
