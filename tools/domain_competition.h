#pragma once

#include "fusion_domains.h"
#include "llvm/Support/JSON.h"
#include <algorithm>

namespace fusion {
// This is a scheduling heuristic on one parent. It neither prunes candidates
// nor certifies the independence of the domains outside the chosen group.
struct CompetingDomains {
  std::set<llvm::BasicBlock *> owners;
  std::string seed;
  unsigned commonWork = 0;
};

inline CompetingDomains competingDomains(llvm::Function &function,
    const FusionDomains &domains, const llvm::json::Array &catalog,
    const std::set<std::string> &attempted) {
  using Block = llvm::BasicBlock;
  std::map<std::string, Block *> blocks;
  unsigned index = 0;
  for (auto &block : function) blocks["B" + std::to_string(index++)] = &block;

  struct Pair {
    std::string id;
    Block *owner, *left, *right;
  };
  std::vector<Pair> pairs;
  std::map<Block *, std::set<Block *>> consumers;
  for (auto &entry : catalog) {
    const auto &c = *entry.getAsObject();
    auto id = c.getString("candidate")->str();
    if (attempted.count(id) || !c.getString("preflight_rejection")->empty()) continue;
    auto *owner = domains.root(c.getString("split")->str());
    auto left = blocks.find(c.getString("left")->str());
    auto right = blocks.find(c.getString("right")->str());
    if (left != blocks.end()) consumers[left->second].insert(owner);
    if (right != blocks.end()) consumers[right->second].insert(owner);
    if (left != blocks.end() && right != blocks.end())
      pairs.push_back({id, owner, left->second, right->second});
  }

  using Histogram = std::map<unsigned, unsigned>;
  std::map<Block *, Histogram> histograms;
  auto histogram = [&](Block *block) -> const Histogram & {
    auto entry = histograms.try_emplace(block);
    if (entry.second)
      for (auto &i : *block)
        if (llvm::isa<llvm::BinaryOperator>(i) || llvm::isa<llvm::CmpInst>(i) ||
            llvm::isa<llvm::SelectInst>(i))
          ++entry.first->second[i.getOpcode()];
    return entry.first->second;
  };
  CompetingDomains best;
  for (auto &p : pairs) {
    auto *exit = p.left->getSingleSuccessor();
    if (!exit || exit != p.right->getSingleSuccessor()) continue;
    if (consumers[p.left].size() == 1 && consumers[p.right].size() == 1) continue;
    const auto &right = histogram(p.right);
    unsigned common = 0;
    for (auto [op, count] : histogram(p.left)) {
      auto it = right.find(op);
      if (it != right.end()) common += std::min(count, it->second);
    }
    // Avoid grouping every tiny unpacked comparison in an unrolled kernel.
    // This budget ranks scheduling opportunities only; real trials decide.
    constexpr unsigned minCommonWork = 8;
    if (common < minCommonWork || common <= best.commonWork) continue;
    best.commonWork = common;
    best.seed = p.id;
    best.owners = consumers[p.left];
    best.owners.insert(consumers[p.right].begin(), consumers[p.right].end());
  }
  return best;
}
}
