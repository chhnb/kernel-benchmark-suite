#pragma once

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallVector.h"
#include <array>
#include <algorithm>
#include <cstdint>
#include <limits>
#include <vector>

namespace dataflow {
// A common block closes a guarded diamond. A left run followed by a right
// run can share one split; right-to-left starts a new diamond. The opposite
// order of the two independent arms represents the same diamond.
enum class Lane : unsigned { Common, Left, Right };
struct Scheduled {
  unsigned node;
  bool opensGuard;
};
struct Schedule {
  unsigned branches;
  llvm::SmallVector<Scheduled, 16> steps;
};

inline Schedule minimumGuards(llvm::ArrayRef<unsigned> dependencies,
                              llvm::ArrayRef<Lane> lanes) {
  const unsigned full = (1u << lanes.size()) - 1;
  struct Cell {
    unsigned cost = std::numeric_limits<unsigned>::max();
    unsigned node = 0;
    Lane prior = Lane::Common;
  };
  std::vector<std::array<Cell, 3>> dp(full + 1);
  dp[0][0].cost = 0;
  auto opens = [](Lane before, Lane next) {
    return next != Lane::Common && before != next &&
           !(before == Lane::Left && next == Lane::Right);
  };
  for (unsigned mask = 0; mask < full; ++mask)
    for (unsigned old = 0; old < 3; ++old) {
      auto before = static_cast<Lane>(old);
      auto cost = dp[mask][old].cost;
      if (cost == std::numeric_limits<unsigned>::max())
        continue;
      for (unsigned i = 0; i < lanes.size(); ++i) {
        unsigned bit = 1u << i;
        if ((mask & bit) || (dependencies[i] & ~mask))
          continue;
        auto next = lanes[i];
        auto &cell = dp[mask | bit][static_cast<unsigned>(next)];
        unsigned total = cost + opens(before, next);
        if (total < cell.cost)
          cell = {total, i, before};
      }
    }
  unsigned last = 0;
  for (unsigned lane = 1; lane < 3; ++lane)
    if (dp[full][lane].cost < dp[full][last].cost)
      last = lane;
  Schedule schedule{dp[full][last].cost, {}};
  if (schedule.branches == std::numeric_limits<unsigned>::max())
    return schedule;
  for (unsigned mask = full; mask;) {
    const auto &cell = dp[mask][last];
    schedule.steps.push_back({cell.node, opens(cell.prior, static_cast<Lane>(last))});
    mask ^= 1u << cell.node;
    last = static_cast<unsigned>(cell.prior);
  }
  std::reverse(schedule.steps.begin(), schedule.steps.end());
  return schedule;
}
} // namespace dataflow
