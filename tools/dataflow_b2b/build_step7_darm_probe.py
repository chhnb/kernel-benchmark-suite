#!/usr/bin/env python3
"""Capture DARM alignment from its existing value map in a scratch build."""
import argparse
from pathlib import Path

MARK = "    melder.NativeReplicationPredication = darmReplication && t.replication;"


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("output", type=Path)
    args = p.parse_args()
    text = Path("tools/fusion_search.cpp").read_text()
    assert text.count(MARK) == 1
    hook = """
    SmallVector<Instruction *, 32> operands[2];
    if (std::getenv("STEP7_DARM_PAIRS") && t.planKind == "B2B") {
      auto *split = dyn_cast_or_null<BasicBlock>((Value *)originalSplit);
      auto *branch = split ? dyn_cast<BranchInst>(split->getTerminator()) : nullptr;
      if (branch && branch->isConditional() &&
          ((branch->getSuccessor(0) == l.entry && branch->getSuccessor(1) == r.entry) ||
           (branch->getSuccessor(1) == l.entry && branch->getSuccessor(0) == r.entry))) {
        for (unsigned side = 0; side < 2; ++side)
          for (auto &inst : *branch->getSuccessor(side))
            if (dataflow::extraction::semantic(inst) && !dataflow::extraction::laneInput(inst))
              operands[side].push_back(&inst);
        auto existing = melder.onValueMapping;
        melder.onValueMapping = [&, existing](const ValueToValueMapTy &map) {
          if (existing) existing(map);
          DenseMap<const Value *, unsigned> right;
          for (auto indexed : llvm::enumerate(operands[1]))
            if (Value *mapped = map.lookup(indexed.value()))
              right.try_emplace(mapped, indexed.index());
          json::Array pairs, guards, speculated, unmapped;
          DenseSet<unsigned> used[2];
          for (auto indexed : llvm::enumerate(operands[0])) {
            auto *a = indexed.value();
            Value *mapped = map.lookup(a);
            auto found = right.find(mapped);
            if (found == right.end() || used[1].count(found->second)) continue;
            auto *b = operands[1][found->second];
            if (a->getOpcode() != b->getOpcode()) continue;
            used[0].insert(indexed.index());
            used[1].insert(found->second);
            pairs.push_back(json::Object{{"left_index", int64_t(indexed.index())},
              {"right_index", found->second}, {"recipe", "R1"}, {"opcode", a->getOpcodeName()}});
          }
          bool swapped = branch->getSuccessor(0) != l.entry;
          for (unsigned side = 0; side < 2; ++side)
            for (auto item : llvm::enumerate(operands[side])) {
              if (used[side].count(item.index())) continue;
              auto *inst = dyn_cast_or_null<Instruction>((Value *)map.lookup(item.value()));
              json::Array where{side, int64_t(item.index()), item.value()->getOpcodeName()};
              if (!inst) unmapped.push_back(std::move(where));
              else if (melder.hasGuardedGap(inst, (side == 0) != swapped))
                guards.push_back(std::move(where));
              else speculated.push_back(std::move(where));
            }
          errs() << "STEP7_DARM_ALIGNMENT " << json::Value(json::Object{
              {"pairs", std::move(pairs)}, {"protected", std::move(guards)},
              {"speculated", std::move(speculated)}, {"unmapped", std::move(unmapped)}}) << "\\n";
        };
      }
    }
"""
    # Save the orientation before the melder replaces the branch.
    hook = hook.replace("        auto existing", "        const bool swapped = branch->getSuccessor(0) != l.entry;\n        auto existing")
    hook = hook.replace("[&, existing]", "[&, existing, swapped]").replace(
        "          bool swapped = branch->getSuccessor(0) != l.entry;\n", "")
    args.output.write_text(text.replace(MARK, hook + MARK))


if __name__ == "__main__":
    main()
