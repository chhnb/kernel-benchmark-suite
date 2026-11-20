# Independent trial cleanup and speculation settings

`DECISION_CFG_CLEANUP=structural|full` is independent of
`DECISION_SPECULATION=none|legacy|budget`. The current default cleanup is
`structural`. A cost-policy prototype exists in the working tree but is not part
of this comparison or a validated release configuration.

- `structural`: scoped scalar and CFG cleanup, with no generic LLVM12
  SimplifyCFG invocation or conditional instruction hoisting. Safe condition
  merging remains governed by `DECISION_CONDITION_BUDGET` (default 4).
- `full`: LLVM12 SimplifyCFG defaults, including implicit speculation. Uses the
  actual target's LLVM12 TTI; a missing target is an explicit rejection, never a
  generic TTI fallback. Any convergent call in the whole function rejects the
  trial before transformation. Scoped outside-instruction auditing, SESE
  boundary validation and LLVM verification remain enabled.

Full-mode effects are diagnostic, not acceptance requirements. The driver saves
`pre-full-cleanup.ll` and `post-full-cleanup.ll`, runs the existing independent
LLVM24 TTI worker, and reports:

- `implicit_speculation_cost_true` / `_false`: **after minus before** for the
  conservative uniform-side reachable-block costs; negative means net cost
  decreased. This includes structural cleanup benefits, so it is a net cleanup
  delta, not a precise runtime charge attributable to hoisting alone.
- `implicit_speculation_metrics_available` and a reason when unavailable. A
  diagnostic worker failure does not reject an otherwise valid full trial.
- `full_cleanup_moved_instructions`: opcode, speculation weight, LLVM12
  SizeAndLatency TTI cost, IR, and conditional-hoist versus other move
  classification. The latter includes straight-line block merges; it must not
  all be counted as speculation.

The greedy report explicitly records cleanup configuration. Full-mode uniform
side effects are diagnostic-only, even if a uniform-loss limit was supplied.
The separately configured pressure check still applies.

## Checkpoint comparison settings

Use the same baseline, scorer and final codegen for both cleanup settings:

```ini
DECISION_SPECULATION=none
DECISION_CFG_CLEANUP=full        # or structural
DECISION_CONDITION_BUDGET=4
DECISION_SPECULATION_BUDGET=4
DECISION_MAX_PRESSURE_GROWTH=1000000
DECISION_MAX_PRESSURE=1000000
# DECISION_MAX_UNIFORM_LOSS unset
```

The deliberately nonbinding pressure limits reproduce the acceptance policy of
35f9ccd. They are comparison settings, not new production defaults. Comparing a
full/no-pressure run to a structural/no-growth run would mix two factors.

Checkpoint search uses the actual 35f9ccd model and greedy sources plus the
preserved checkpoint fuse binary. Record both source and binary hashes. Compare
final compiled SHA; do not update frozen references to hide a mismatch.

## First-pair terminology and checks

The first pair in greedy order is a decoder pair outside the eight-leaf
quantization trees:
`%cond.false.i72.i + %cond.true.i69.i`. On identical input:

| Cleanup | Total TTI |
| --- | ---: |
| none + structural | 5424 |
| none + full | 5412 |
| checkpoint | 5412 |

Both full-stage output IR and `meld-raw.ll` match the checkpoint byte for byte.
The full cleanup hoists fadd, integer add, and amdgcn.ldexp. Their weights are
1/1/4; LLVM12 SizeAndLatency costs are 1/1/1. The raw IR of both cleanup settings
is identical. This fixture is distinct from copysign L0+L1 in a quantization tree.

Unit checks: `tests/decision-model/cleanup_mode_check.py` covers raw-stage parity,
observable hoisting, diagnostic-only failures, convergent isolation and target
failure. Real checkpoint fixture evidence is under
`build/decision-fuse/cleanup-mode-check-v2/`.

Full-search/compile comparison evidence:
`build/decision-fuse/cleanup-comparison-v1/`. GPU comparison aliases identical
binaries explicitly; it does not present shared samples as independent runs.
Hypersonic uses the common no-JT face_kernel baseline and one frozen fixture per
runner process to preserve the existing isolated-fixture protocol.

## Completed regression

The full searches on Map-Airy, TIGRE, Hypersonic and VLLM reproduce both the
checkpoint commit sequence and final compiled SHA. GPU full-output validation
passes for all four. Identical checkpoint/full binaries explicitly share samples.
Structural matches performance within 2% on Map-Airy, TIGRE and Hypersonic;
VLLM remains 11.63%/11.86% slower than the same-run checkpoint at 64K/128K.
See `docs/evidence/cleanup-comparison-v1/` for compact receipts and the report.

The distinct quantization L0+L1 fixture costs 5412 in structural, full and
checkpoint, with no full-stage instruction motion. Only the decoder-first fixture
has the 5424 versus 5412 split described above.

Do not combine the new explicit cleanup setting with the legacy
`DECISION_DISABLE_SIMPLIFYCFG` debugging flag. Both drivers reject that ambiguous
combination. Legacy scripts that only set the old flag retain their compatibility
path; new comparisons should use the explicit cleanup setting.
