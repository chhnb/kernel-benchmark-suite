#pragma once

#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include <algorithm>
#include <cstdint>
#include <functional>
#include <numeric>
#include <queue>
#include <set>
#include <vector>

namespace dataflow::placement {
using namespace llvm;

struct Fraction {
  int64_t n = 0, d = 1;
  Fraction(int64_t numerator, int64_t denominator) {
    if (denominator < 0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    auto gcd = std::gcd(numerator, denominator);
    n = numerator / gcd;
    d = denominator / gcd;
  }
};

inline bool operator<(Fraction a, Fraction b) {
  return static_cast<__int128>(a.n) * b.d < static_cast<__int128>(b.n) * a.d;
}

struct Value {
  unsigned node;
  bool speculatable;
  int64_t instruction, escape;
  bool publicUse;
  SmallVector<unsigned, 4> users;
};

class Flow {
  struct Edge {
    unsigned peer, reverse;
    int64_t remaining;
  };
  std::vector<std::vector<Edge>> edges;
  std::vector<int> level;
  std::vector<unsigned> next;

  int64_t send(unsigned node, unsigned sink, int64_t cap) {
    if (node == sink)
      return cap;
    for (auto &i = next[node]; i < edges[node].size(); ++i) {
      auto &e = edges[node][i];
      if (e.remaining <= 0 || level[e.peer] != level[node] + 1)
        continue;
      auto moved = send(e.peer, sink, std::min(cap, e.remaining));
      if (!moved)
        continue;
      e.remaining -= moved;
      edges[e.peer][e.reverse].remaining += moved;
      return moved;
    }
    return 0;
  }

  bool layer(unsigned source, unsigned sink) {
    std::fill(level.begin(), level.end(), -1);
    std::queue<unsigned> ready;
    level[source] = 0;
    ready.push(source);
    while (!ready.empty()) {
      auto node = ready.front();
      ready.pop();
      for (const auto &e : edges[node])
        if (e.remaining > 0 && level[e.peer] < 0) {
          level[e.peer] = level[node] + 1;
          ready.push(e.peer);
        }
    }
    return level[sink] >= 0;
  }

public:
  explicit Flow(unsigned size) : edges(size), level(size), next(size) {}

  void add(unsigned from, unsigned to, int64_t cost) {
    auto reverse = static_cast<unsigned>(edges[to].size());
    edges[to].push_back({from, static_cast<unsigned>(edges[from].size()), 0});
    edges[from].push_back({to, reverse, cost});
  }

  BitVector cut(unsigned source, unsigned sink, int64_t limit) {
    while (layer(source, sink)) {
      std::fill(next.begin(), next.end(), 0);
      while (send(source, sink, limit)) {}
    }
    BitVector reachable(edges.size());
    for (unsigned i = 0; i < level.size(); ++i)
      if (level[i] >= 0)
        reachable.set(i);
    return reachable;
  }
};

struct Plan {
  BitVector speculated;
  int64_t constant = 0, slope = 0;
  Fraction lower{0, 1}, upper{1, 1};
};

inline std::vector<Plan> scan(ArrayRef<Value> values, unsigned nodeCount) {
  if (values.empty())
    return {{BitVector(nodeCount)}};
  const unsigned source = 2 * values.size(), sink = source + 1;
  int64_t instructions = 0, escapes = 0;
  for (const auto &v : values) {
    instructions += v.speculatable ? v.instruction : 0;
    escapes += v.escape;
  }
  auto optimum = [&](Fraction q, bool preferSmallSlope) {
    Flow flow(sink + 1);
    // Resolve ties symbolically. One integer unit of the primary objective
    // outweighs any possible total secondary unary charge.
    const auto scale = instructions + 1;
    const auto inf = (q.d * escapes + q.n * instructions) * scale + instructions + 1;
    for (unsigned i = 0; i < values.size(); ++i) {
      const auto &v = values[i];
      const auto speculate = q.n * v.instruction * scale + (preferSmallSlope ? v.instruction : 0);
      flow.add(source, i, v.speculatable ? speculate : inf);
      if (v.speculatable && !preferSmallSlope)
        flow.add(i, sink, v.instruction);
      if (!v.escape)
        continue;
      auto aux = i + values.size();
      flow.add(i, aux, q.d * v.escape * scale);
      if (v.publicUse)
        flow.add(aux, sink, inf);
      else
        for (auto user : v.users)
          flow.add(aux, user, inf);
    }
    const auto reachable = flow.cut(source, sink, inf);
    Plan result{BitVector(nodeCount)};
    for (unsigned i = 0; i < values.size(); ++i) {
      const auto &v = values[i];
      if (!reachable.test(i)) {
        result.speculated.set(v.node);
        result.slope += v.instruction;
      } else if (v.publicUse || llvm::any_of(v.users, [&](auto user) { return !reachable.test(user); })) {
        result.constant += v.escape;
      }
    }
    return result;
  };
  std::vector<Plan> plans;
  auto keep = [&](const Plan &plan) {
    if (llvm::none_of(plans, [&](const Plan &old) { return old.speculated == plan.speculated; }))
      plans.push_back(plan);
  };
  const auto first = optimum({0, 1}, true);
  const auto last = optimum({1, 1}, false);
  keep(first);
  keep(last);
  std::set<std::pair<int64_t, int64_t>> intersections;
  std::function<void(const Plan &, const Plan &)> visit = [&](const Plan &a, const Plan &b) {
    if (a.slope <= b.slope)
      return;
    Fraction q(b.constant - a.constant, a.slope - b.slope);
    if (q < Fraction(0, 1) || Fraction(1, 1) < q || !intersections.emplace(q.n, q.d).second)
      return;
    const auto left = optimum(q, false), right = optimum(q, true);
    keep(left);
    keep(right);
    const auto score = [&](const Plan &p) {
      return static_cast<__int128>(p.constant) * q.d + static_cast<__int128>(p.slope) * q.n;
    };
    if (score(left) < score(a)) {
      visit(a, left);
      visit(right, b);
    }
  };
  visit(first, last);
  // At the two boundary weights, retain the other extremal tied cut too.
  keep(optimum({0, 1}, false));
  keep(optimum({1, 1}, true));
  for (auto &p : plans)
    for (const auto &other : plans) {
      if (p.slope == other.slope)
        continue;
      Fraction q(other.constant - p.constant, p.slope - other.slope);
      if (p.slope > other.slope)
        p.upper = std::min(p.upper, q);
      else
        p.lower = std::max(p.lower, q);
    }
  return plans;
}
} // namespace dataflow::placement
