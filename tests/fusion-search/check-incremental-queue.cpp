#include <algorithm>

#include "incremental_candidate_queue.h"
#include <cassert>
#include <iostream>
#include <random>
using Q = fusion::IncrementalCandidateQueue;
int main() {
  Q queue;
  std::vector<Q::Candidate> inventory = {{"a", {{"left", "1"}}, 0}, {"b", {{"right", "1"}}, 1}};
  auto first = queue.synchronize(inventory);
  assert(first.size() == 2 && !queue.best());
  queue.publish(first[1], {7, "b-plan"});
  assert(!queue.best());
  queue.publish(first[0], {7, "a-plan"});
  assert(queue.best()->first.id == "a");
  assert(queue.cached("a")->recipe == "a-plan");
  assert(!queue.cached("absent"));
  inventory[0].reads["left"] = "2";
  inventory.push_back({"new-after-a", {{"child", "1"}}, 2});
  auto changed = queue.synchronize(inventory);
  assert(changed.size() == 2 && !queue.best());
  assert(!queue.cached("a") && queue.cached("b")->gain == 7);
  assert(!queue.publish(first[0], {999, "stale"}));
  queue.publish(changed[0], {-1, "a-new"});
  queue.publish(changed[1], {8, "new-plan"});
  assert(queue.best()->first.id == "new-after-a");
  inventory.erase(inventory.begin() + 2);
  assert(queue.synchronize(inventory).empty());
  assert(queue.best()->first.id == "b");
  inventory[0].order = 2; inventory[1].order = 0;
  queue.synchronize(inventory);
  assert(queue.best()->first.id == "b");
  Q rejected;
  auto rejectedTickets=rejected.synchronize({{"same-path",{{"content","hash1"}},0}});
  rejected.publish(rejectedTickets[0],{0,"rejected-artifact",4});
  assert(rejected.cached("same-path")->exitCode==4);
  assert(rejected.synchronize({{"same-path",{{"content","hash1"}},0}}).empty());
  assert(rejected.synchronize({{"same-path",{{"content","hash2"}},0}}).size()==1);
  assert(!rejected.cached("same-path"));
  // Compare every incremental winner against full recomputation. Dependency
  // updates, appearance/disappearance and arbitrary tie orders are randomized.
  std::mt19937 random(17);
  Q incremental;
  unsigned versions[12] = {};
  size_t reused = 0, evaluated = 0;
  for (unsigned iteration = 0; iteration != 10000; ++iteration) {
    if (iteration % 3 == 0) ++versions[random() % 12];
    std::vector<Q::Candidate> rows;
    std::map<std::string, int64_t> scores;
    std::optional<std::pair<int64_t, std::string>> expected;
    for (unsigned c = 0; c != 24; ++c) {
      if (random() % 11 == 0) continue;
      auto id = std::to_string(c);
      auto x = c % 12, y = (c * 7 + 1) % 12;
      rows.push_back({id, {{std::to_string(x), std::to_string(versions[x])},
                          {std::to_string(y), std::to_string(versions[y])}}, c});
      int64_t gain = int64_t((versions[x] * 3 + versions[y] * 5 + c) % 19) - 5;
      scores[id] = gain;
      if (gain > 0 && (!expected || gain > expected->first)) expected = {{gain, id}};
    }
    auto work = incremental.synchronize(rows);
    reused += rows.size() - work.size(); evaluated += work.size();
    std::shuffle(work.begin(), work.end(), random);
    for (const auto &ticket : work) incremental.publish(ticket, {scores[ticket.id], ticket.id});
    auto actual = incremental.best();
    assert(bool(expected) == bool(actual));
    if (expected) assert(expected->second == actual->first.id && expected->first == actual->second.gain);
  }
  std::cout << "PASS 10000 incremental/full-rescore winner comparisons; reused="
            << reused << " evaluated=" << evaluated << "\n";
}
