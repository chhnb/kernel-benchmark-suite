# Hybrid region fusion

`--hybrid 1` enables local-compute first, DARM merger fallback in the C++ search engine. It scans the entire selected function using the existing general CFG candidate enumerator. It is opt-in; existing modes are unchanged.

Example for TIGRE Siddon:

```sh
build/llvm24-tti/fusion-search-llvm24 \
  --ir results/tigre-baseline-binary-v1/post.ll \
  --function _Z19kernelPixelDetector8GeometryPfiiP13__hip_texture \
  --hybrid 1 --adjacent-only 0 --cleanup darm-cfg --scorer llvm24 \
  --rounds 256 --trials 100000 \
  --debug-dir experiments/my-tigre-search --out experiments/my-tigre.ll
```

## Selection and correctness contract

For every candidate, the engine attempts the existing local-compute/local-union transformation on a clone. If it is legal, that implementation is used. If it rejects, its clone is discarded and the existing suite DARM RegionMelder is tried on a fresh clone of the same immutable parent. This is a legality fallback, not a comparison of two scoring policies or a fallback triggered by a negative score.

The fallback retains structural matching, exclusive-side checks, loop/scope and side-effect guards, multi-output/PHI handling, verifier checks and the existing merge implementation's internal optimization. It does not remove safety checks or call the upstream automatic candidate selector to choose the committed pair. LLVM24 scoring and the outer greedy engine still select the highest eligible positive score.

The no-fusion control and fused candidate receive the same selected cleanup. `--cleanup darm-cfg` adds the existing DARM-style SimplifyCFG cleanup; it does not run full O3 after every trial. Final O3 code generation remains a separate step. Local-only mode retains its prior `adjacent-only 1, cleanup none` contract. Hybrid mode requires general CFG enumeration and rejects combination with local-only switches.

Every round re-enumerates the current module, reconstructing dominator/postdominator/RegionInfo/loop analyses. Candidate identities are scoped to their parent version; old R/B IDs are not permanent names. The existing debug records retain parent/cleaned hashes, before/after IR, region boundaries, live-ins/live-outs and block mappings. General CFG provenance is versioned transformation history, not the ordered-leaf union-find labels used by the vLLM-only adjacency path. Re-enumeration allows new regions to be candidates when the enumerator and legality checks support them; it is not a promise to support arbitrary loops or CFGs.

Trial JSON adds `merge_path` (`local-compute` or `darm-fallback`) and `local_reject_reason`. Empty values remain valid for legacy non-hybrid modes. A rejected local trial cannot modify the parent or become the input of the fallback.

## Tests

Run `tools/build-llvm24-tti`, then `bash tests/postopt/build_hybrid_test.sh` in the configured musa checkout. The C++ test checks local path preference, the three real TIGRE two-block/multi-output region pairs under both no cleanup and DarmCFG, verifier correctness, parent immutability, and rejection of a side-effecting scope.

GPU acceptance and performance records are retained at `experiments/tigre-hybrid-20261109-v1/`. The comparator is the clean original artifact checkout at commit `e9bc0540325ad9806313d34e84fc901496fd8be6`, invoked via `/home/chh/darm-artifacts-repro/build/bin/opt`. No upstream artifact source is modified by this change.

## Observed search coverage

On the retained TIGRE baseline, hybrid/no-external-cleanup produced legal candidates but no positive scores. With DARM-style CFG cleanup it performed 14 trials and committed four pairs (three multi-block region pairs and one block pair), then stopped at `no_supported_candidates`. The committed static gains were 15, 15, 15 and 6. All committed transformations on this case used the DARM fallback; the local path is separately regression-tested. Unsupported loop scopes remain excluded, so the original artifact pass can perform transformations the hybrid search still does not cover.
