# Hypersonic face_decide ablation

This archive preserves the final LLVM 12 O3 IR for the two roles in
`measure-pair-auto-vs-none`. Both kernels share the prepared outer wrapper
with seven DARM merges. The auto role applies seven further merges to the
separate `face_decide` function with similarity threshold 0.2. Both roles inline
the function back into `face_kernel` and use the same finalization pipeline.

| Input | Shared-wrapper baseline (μs) | Auto (μs) | Time reduction |
| --- | ---: | ---: | ---: |
| hypersonic-1 | 1713.066 | 1598.720 | 6.67% |
| hypersonic-24 | 1712.267 | 1598.613 | 6.64% |

Values are geometric means of batch medians from three batches with two warmups
and five measurements per batch. See [the measurement summary](summary.json).
The performance comparison is scoped to this prepared-wrapper ablation.

Both final IR files match the saved experiment files byte for byte.
The build manifest records the original compilation commands and binary hashes.
Its paths refer to the original experiment workspace.

| Final IR | SHA256 |
| --- | --- |
| [Baseline](pair-auto-vs-none/baseline-final.ll) | `213ce33346f0d7374902520525a4b7e78533ccecb1cd0343489a48d7bbaaec9a` |
| [Auto](pair-auto-vs-none/variant-final.ll) | `9de2f8b325b86dd47e9a06d81c17ad3c296bc88fa148f5efbc93004db850d07c` |
