# Structural fusion plans (LLVM12 transformation, LLVM24 scoring)

Current entry: `--structural 1 --adjacent-only 0 --cleanup structural-cfg`.
`--hybrid 1` is retained as a compatibility alias. Unlike the first hybrid revision,
the engine is chosen from structure before mutation, not by trying local fusion and falling back on failure.

## Candidate representation

The existing candidate key identifies a parent-version split and matched blocks/regions.
`Trial` additionally records `planKind`, `matchedLeft`, `matchedRight`,
`leftContext`, `rightContext`, `loopHeaderSplit` and `replication`.
Debug JSON exposes these under `fusion_plan`; C++ owns the data and decisions.
B/B IDs can describe a B2R plan: one matched block is optional inside a larger region.
Mixed B/R CLI IDs are not resolved by guessing a matching block. Enumeration expands supported internal block matches into explicit candidates; arbitrary non-isomorphic R2R remains unsupported.

- Direct closed pure B2B with a common successor can use the local computation engine.
- Other B2B and structurally matched R2R use RegionMelder.
- A required block versus an optional block inside the opposite region is B2R (or R2B).
  RegionMelder selects the containing region, normalizes its exit, and uses RegionReplicator.
- Only the block being expanded must have a unique successor. The matched block may have a conditional terminator.

Each trial clones the parent. Raw and cleaned results must pass LLVM verification.
Each committed state rebuilds dominance, postdominance, RegionInfo and LoopInfo.
Parent hashes, versioned IDs, contexts and block provenance track the transformation.
This general CFG mode does not yet maintain a persistent multi-way ordered-leaf partition.

## Loop and memory boundary

A split may be a loop header when the transformed scope excludes that header and is
acyclic, single-entry/single-exit, entirely within the same loop. Header PHIs and
backedges are outside that scope. The join cannot be the header. Nested loops,
backedges in scope, escaping edges, external entries, stores and side effects remain rejected.
The outer TIGRE if.end36 scope remains unsupported; this is not full original-DARM coverage.

## Cleanup

`structural-cfg` adds a narrowly scoped dominating-edge boolean implication fold to
existing DARM-style SimplifyCFG. For example, taking the true edge of
`select p, false, q` proves `p=false` and `q=true` on that path.
Only conditional terminators proven by dominating edges are folded. Unknown
predicates, loads and sampling calls are not speculated. Dominance is rebuilt after
each fold. Both no-fusion control and fused candidate use the same cleanup.
`none` and the previous `darm-cfg` retain their prior cleanup behavior.
Final backend O3 remains separate from trial cleanup.

## Acceptance

`tests/postopt/hybrid.cpp` covers local B2B, all three two-block TIGRE R2R pairs,
loop-header X/Z B2R, another replication after that fusion, parent immutability,
verifiers, proven versus unknown guards, retained live stores, cyclic-scope and
side-effect rejection. Build with `tests/postopt/build_hybrid_test.sh` under CPU admission.

2026-11-09 experiment: `experiments/tigre-structural-20261109-v2`.
Initial X/Y and X/Z each have native similarity 0.5 and LLVM24 gain +5;
Y/Z gain is +6. Automatic greedy makes 4 commits in 20 trials and stops at
`no_positive_candidate`. The next X + merged(Y,Z) trial is now legal but has gain -32.
Its compiled GPU output passed full CPU-reference validation; legality does not imply positive score.
The automatic result and original artifacts comparator also passed validation and timed-output checks.
