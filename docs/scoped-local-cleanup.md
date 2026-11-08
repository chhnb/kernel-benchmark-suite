# Experimental scoped-local cleanup

Use `--cleanup scoped-local` with the C++ fusion search. The default mode is unchanged.
Local adjacent mode accepts `--local-copysign 1 --local-union 1 --adjacent-only 1`;
structural dispatch may also use this mode after DARM melding.

The additional cleanup snapshots the target function before the merge, identifies
surviving instructions with changed parents/operands and newly created instructions,
and operates only on that set. PHI edge/value pairs are compared independent of order.
Terminators are excluded. It applies InstructionSimplify, local common-expression
elimination among allowed instructions in the same block, and non-recursive dead
instruction deletion. Memory operations and convergent calls are excluded from CSE.
No instructions move and no CFG rewrite is performed.

Unchanged instructions are protected: every iteration checks their continued existence,
parent, opcode and operands. Operand updates through replacement of an allowed value
are permitted, but the users are not added to the optimization scope. The no-fusion
control does no additional cleanup. Existing canonical PHI ordering is retained.

This boundary covers the additional cleanup, not the preceding fusion algorithm.
DARM's existing internal post-merge cleanup, PHI/branch repair and unpredication remain
part of melding and have not been replaced or claimed to be scope-restricted.

Regression: tests/postopt/build_scoped_local.sh verifies that redundant selected
operands disappear while an outside add-zero and an outside trivial PHI remain.
It also verifies the parent is unchanged and the final IR is valid. The existing
hybrid/structural regression remains passing.

## Results, 2026-11-09

vLLM: 32 instances, 224 commits, all left-deep trees. Each first six merges gain 11;
the last gains 12 instead of the prior 11 because one redundant instruction is removed.
Across 1184 trials, 1152 removed no extra instruction and 32 removed one. The common
final LLVM12 backend emits a byte-identical hsaco to the no-cleanup greedy baseline.
The real Qwen64K six-layer GPU correctness check passes. No new runtime speedup is claimed.

TIGRE: all six initial trials pass verification and scope audit, but no positive scores:
three R2R pairs each -62; X/Y and X/Z each -151; Y/Z -134. Consequently zero commits;
the final binary is identical to unmerged baseline. The extra cleanup removes 5, 2,
and 4 instructions respectively, but cannot simplify the generated CFG or combine
mutually exclusive image sampling calls. It is insufficient as a replacement for CFG cleanup.

Experiments: experiments/vllm-scoped-local-20261109-v1 and
experiments/tigre-scoped-local-20261109-v1. vLLM search-final is the final regression
rerun with order-insensitive PHI-boundary detection; search is the initial run.

Separate finding: InstructionMatch.cpp is byte-identical to original artifacts DARM.
Its intrinsic matcher returns false for unlisted intrinsics, including image.sample,
floor and amdgcn.rcp. Thus raw melding can share arithmetic while retaining guarded
copies of these calls. Removing this limitation would require a separately validated
matching rule; it is not changed by scoped-local cleanup.
