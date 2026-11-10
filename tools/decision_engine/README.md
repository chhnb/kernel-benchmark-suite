# Isolated experimental engine policy

`speculation-modes.patch` is the RegionMelder.cpp/.h subset of the reviewed user-supplied speculation patch series (0002/0003), relative to base e4138fb. It adds none/legacy/budget handling and convergent-operation safety.

`build-decision-fuse` applies this patch to a temporary copy of the existing engine, only for the opt-in experimental executable. The driver explicitly selects none. Production engine sources, production CLI defaults, search and frozen regressions are unchanged; the complete 0001–0004 series is not applied by this build.

Alternatively ENGINE_ROOT may select an existing engine with this API. Build artifacts are temporary or under build/, never part of the source commit. LLVM12 is required.
