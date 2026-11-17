#pragma once
#include <cstdint>
#include <map>
#include <optional>
#include <queue>
#include <set>
#include <string>
#include <stdexcept>

#include <vector>

namespace fusion {
// This scheduler never invents a validity proof. The caller supplies the full
// read set (including cleanup/scoring dependencies), and a stable candidate ID.
// IR artifacts are recipes, never entire old modules ready to commit.
class IncrementalCandidateQueue {
public:
  using ReadSet = std::map<std::string, std::string>;
  struct Candidate {
    std::string id;
    ReadSet reads;
    uint64_t order = 0;
  };
  struct Result {
    int64_t gain = 0;
    std::string recipe;
    int exitCode = 0;
  };
  struct Ticket {
    std::string id;
    uint64_t generation = 0;
  };
private:
  struct Entry {
    Candidate candidate;
    uint64_t generation;
    std::optional<Result> result;
  };
  struct Ranked {
    int64_t gain;
    uint64_t order, generation;
    std::string id;
    bool operator<(const Ranked &r) const {
      if (gain != r.gain) return gain < r.gain;
      if (order != r.order) return order > r.order;
      return id > r.id;
    }
  };
  uint64_t generation = 0;
  std::map<std::string, Entry> entries;
  std::priority_queue<Ranked> heap;
public:
  // A fresh inventory includes newly exposed candidates and drops disappeared
  // ones. Invalidated candidates must be evaluated again, not silently skipped.
  std::vector<Ticket> synchronize(const std::vector<Candidate> &inventory) {
    std::set<std::string> present;
    std::vector<Ticket> pending;
    for (const auto &candidate : inventory) {
      if (!present.insert(candidate.id).second)
        throw std::runtime_error("duplicate incremental candidate identity");
      auto found = entries.find(candidate.id);
      if (found == entries.end() || found->second.candidate.reads != candidate.reads) {
        Entry replacement{candidate, ++generation, std::nullopt};
        entries.insert_or_assign(candidate.id, std::move(replacement));
        pending.push_back({candidate.id, generation});
      } else {
        auto &entry = found->second;
        // Refresh the original enumeration tie-break after every CFG update.
        if (entry.candidate.order != candidate.order) {
          entry.generation = ++generation;
          entry.candidate.order = candidate.order;
          if (entry.result)
            heap.push({entry.result->gain, candidate.order, entry.generation, candidate.id});
        }
        if (!entry.result) pending.push_back({candidate.id, entry.generation});
      }
    }
    for (auto it = entries.begin(); it != entries.end();)
      if (!present.count(it->first)) it = entries.erase(it); else ++it;
    return pending;
  }
  bool publish(const Ticket &ticket, Result result) {
    auto found = entries.find(ticket.id);
    if (found == entries.end() || found->second.generation != ticket.generation)
      return false; // An asynchronous result for an obsolete parent/read set.
    auto &entry = found->second;
    entry.result = std::move(result);
    heap.push({entry.result->gain, entry.candidate.order, entry.generation, ticket.id});
    return true;
  }
  std::optional<Result> cached(const std::string &id) const {
    auto found=entries.find(id);
    if(found==entries.end())return std::nullopt;
    return found->second.result;
  }
  bool ready() const {
    for (const auto &entry : entries) if (!entry.second.result) return false;
    return true;
  }
  std::optional<std::pair<Candidate, Result>> best() {
    // Old scores are not upper bounds on unevaluated candidates. Never commit
    // while an invalidated or newly exposed candidate still lacks a score.
    if (!ready()) return std::nullopt;
    while (!heap.empty()) {
      const auto top = heap.top();
      auto found = entries.find(top.id);
      if (found == entries.end() || found->second.generation != top.generation ||
          !found->second.result || found->second.result->gain != top.gain) {
        heap.pop(); continue;
      }
      if (top.gain <= 0) return std::nullopt;
      return std::make_pair(found->second.candidate, *found->second.result);
    }
    return std::nullopt;
  }
};
} // namespace fusion
