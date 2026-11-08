#include "beam_search.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <algorithm>
#include <exception>
#include <cmath>
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"
#include <stdexcept>
#include <unordered_map>
#include <unordered_set>

using namespace llvm;
namespace fusion {
namespace {

struct Node {
  std::unique_ptr<Module> m;
  std::string hash, identity;
  double cost = 0;
  std::vector<Step> path;
  size_t parentCands = 0;          // 父状态的候选数
  std::vector<Candidate> cands;    // 本状态在下一层版本号下的候选
  long exploreScore = 0;           // cands.size() - parentCands
};

// 成本低者优先；同成本取融合次数少者；最后按哈希保证确定性。
bool better(const Node& a, const Node& b) {
  if (a.cost != b.cost) return a.cost < b.cost;
  if (a.path.size() != b.path.size()) return a.path.size() < b.path.size();
  return a.hash < b.hash;
}

std::string keyOf(const BeamOptions&, const Module& m) { return moduleHash(m); }
std::string identityOf(const BeamOptions& o,const Module& m) {
  std::string text; raw_string_ostream os(text); m.print(os,nullptr); os.flush();
  return (o.stateKey ? o.stateKey(m) : moduleHash(m))+"\n"+text;
}
double costOf(const BeamOptions& o,Module& m,const std::string& fn) {
  double cost=o.stateCost ? o.stateCost(m,fn) : double(features(*m.getFunction(fn)).cost);
  if(!std::isfinite(cost)) throw std::runtime_error("nonfinite_state_cost");
  return cost;
}

// PHI incoming pair order is not semantic. Stabilize it by function block order,
// preserving each (value, predecessor) pair, before hashing or expanding states.
void canonicalPhiOrder(Module& m) {
 for(auto& f:m) {
  std::map<BasicBlock*,unsigned> order;unsigned ordinal=0;
  for(auto& b:f) order[&b]=ordinal++;
  for(auto& b:f) for(auto& inst:b) {
   auto* phi=dyn_cast<PHINode>(&inst);if(!phi)break;
   std::vector<std::pair<BasicBlock*,Value*>> incoming;
   for(unsigned i=0;i<phi->getNumIncomingValues();++i) incoming.push_back({phi->getIncomingBlock(i),phi->getIncomingValue(i)});
   std::stable_sort(incoming.begin(),incoming.end(),[&](const auto&a,const auto&b){return order.at(a.first)<order.at(b.first);});
   for(unsigned i=0;i<incoming.size();++i) {
    if(phi->getIncomingBlock(i)!=incoming[i].first) phi->setIncomingBlock(i,incoming[i].first);
    if(phi->getIncomingValue(i)!=incoming[i].second) phi->setIncomingValue(i,incoming[i].second);
   }
  }
 }
}

// A block's use-list order controls printed predecessor comments. CloneModule
// may rebuild that list in a different order although the CFG is unchanged.
void canonicalState(Module& m) {
 canonicalPhiOrder(m);
 for(auto& f:m) {
  std::map<const User*,unsigned> rank;unsigned index=0;
  for(auto& b:f)for(auto& inst:b)rank[&inst]=index++;
  for(auto& b:f)b.sortUseList([&](const Use&a,const Use&b){
   auto ai=rank.find(a.getUser()),bi=rank.find(b.getUser());
   if(ai==rank.end() || bi==rank.end()) {
    if(ai==rank.end() && bi==rank.end())return false;
    return ai!=rank.end();
   }
   return ai->second!=bi->second ? ai->second<bi->second : a.getOperandNo()<b.getOperandNo();
  });
 }
}

// Canonicalization can expose duplicate PHIs that cleanup previously missed.
// Normalize and clean together, with the same policy for baseline and children.
void stabilizeState(Module& m,const std::string& fn,const BeamOptions& o) {
 std::set<std::string> seen;
 for(unsigned i=0;i<32;++i) {
  canonicalState(m);auto before=moduleHash(m);
  if(!seen.insert(before).second)throw std::runtime_error("beam_cleanup_cycle");
  cleanup(m,fn,o.optLevel,o.cleanupMode);
  canonicalState(m);
  if(moduleHash(m)==before)return;
 }
 throw std::runtime_error("beam_cleanup_did_not_converge");
}

// tryPair 内部的 cleanup 可能抛异常（如 scalar_cleanup_cycle），这里统一转成失败原因，避免整次搜索中断。
bool safeTry(const Module& parent, const Candidate& c, unsigned version, const BeamOptions& o,
             Trial& out, std::string& why) {
  try {
    out = tryPair(parent, c, version, o.optLevel, o.cleanupMode);
    if(out.valid) {stabilizeState(*out.normalized,c.function,o);out.after=features(*out.normalized->getFunction(c.function));}
  } catch (const std::exception& e) {
    why = std::string("exception:") + e.what();
    return false;
  }
  if (!out.valid) { why = out.reason; return false; }
  canonicalState(*out.normalized);
  return true;
}

bool topLess(const TopEntry& a, const TopEntry& b) {
  if (a.cost != b.cost) return a.cost < b.cost;
  if (a.path.size() != b.path.size()) return a.path.size() < b.path.size();
  return a.hash < b.hash;
}

void offerTop(BeamResult& R, size_t k, const Node& n) {
  if (k == 0) return;
  TopEntry e{n.hash, n.cost, n.path, {}};
  raw_string_ostream snapshot(e.irText); n.m->print(snapshot,nullptr); snapshot.flush();
  auto pos = std::upper_bound(R.top.begin(), R.top.end(), e, topLess);
  R.top.insert(pos, std::move(e));
  if (R.top.size() > k) R.top.pop_back();
}

}  // namespace

std::unique_ptr<Module> replay(const Module& root, const std::string& fn, const std::vector<Step>& path,
                               const BeamOptions& o, std::string* error, unsigned* trials,std::unique_ptr<Module>* mismatch) {
  if(error) error->clear();
  auto fail = [&](const std::string& msg) -> std::unique_ptr<Module> {
    if (error) *error = msg;
    return nullptr;
  };
  auto cur = CloneModule(root);
  stabilizeState(*cur,fn,o);
  for (size_t i = 0; i < path.size(); ++i) {
    if (keyOf(o, *cur) != path[i].parentHash) return fail("parent_hash_mismatch@" + std::to_string(i));
    auto* f = cur->getFunction(fn);
    if (!f) return fail("function_missing@" + std::to_string(i));
    auto cands = enumerate(*f, unsigned(i));
    const Candidate* hit = nullptr;
    for (auto& c : cands) if (c.key() == path[i].candidateKey) { hit = &c; break; }
    if (!hit) return fail("candidate_not_found@" + std::to_string(i));
    Trial t; std::string why;
    if(trials) ++*trials;
    if (!safeTry(*cur, *hit, unsigned(i), o, t, why)) return fail("trial_failed@" + std::to_string(i) + ":" + why);
    if (keyOf(o, *t.normalized) != path[i].childHash) {
      if(mismatch) {*mismatch=CloneModule(*t.normalized);canonicalState(**mismatch);}
      return fail("child_hash_mismatch@" + std::to_string(i));
    }
    cur = std::move(t.normalized);
  }
  return cur;
}

BeamResult beamSearch(const Module& input, const std::string& fn, const BeamOptions& o) {
  BeamResult R;
  if(!o.beamMain || !o.poolFactor || o.depth>64 || o.maxTrials>100000) throw std::runtime_error("invalid_beam_options");

  // 根状态：先做与候选相同的清理，baseline 与试融合结果口径一致。
  auto rootM = CloneModule(input);
  stabilizeState(*rootM,fn,o);
  auto* rf = rootM->getFunction(fn);
  if (!rf || rf->isDeclaration()) throw std::runtime_error("beam: function missing");

  Node root;
  root.m = CloneModule(*rootM); canonicalState(*root.m);
  root.hash = keyOf(o, *rootM);
  root.identity = identityOf(o,*rootM);
  root.cost = costOf(o,*rootM,fn);
  root.cands = enumerate(*root.m->getFunction(fn), 0);
  root.parentCands = root.cands.size();
  R.baselineCost = R.bestCost = root.cost;
  R.best=CloneModule(*rootM); canonicalState(*R.best);

  const size_t poolCap = std::max<size_t>(1, (size_t(o.beamMain) + o.beamExplore) * std::max(1u, o.poolFactor));
  std::unordered_set<std::string> expanded;        // 已作为 beam 成员展开过：之后再到达只会剩余深度更小
  std::unordered_set<std::string> seenAll{root.identity};  // 出现过的所有状态，仅用于 top-k 去重
  bool budgetHit = false, trialException = false;
  unsigned trialsUsed = 0;

  std::vector<Node> frontier;
  frontier.push_back(std::move(root));

  for (unsigned level = 0; level < o.depth && !frontier.empty(); ++level) {
    std::vector<size_t> attempted(frontier.size(),0);
    R.nodesExpanded += unsigned(frontier.size());

    // 本层预算 = 剩余预算 / 剩余层数；没用完的自动留给后面的层。
    unsigned left = o.maxTrials > trialsUsed ? o.maxTrials - trialsUsed : 0;
    unsigned levelBudget = left / (o.depth - level);
    if (levelBudget == 0 && left > 0) levelBudget = 1;
    unsigned levelUsed = 0;

    std::unordered_map<std::string, Node> pool;     // 本层新状态，按哈希去重
    size_t maxC = 0;
    for (auto& s : frontier) maxC = std::max(maxC, s.cands.size());

    bool stopLevel = false;
    // 轮转遍历 (父状态, 候选)，避免第一个父状态把预算吃光。
    for (size_t ci = 0; ci < maxC && !stopLevel; ++ci) {
      for (size_t si=0;si<frontier.size();++si) {
        auto& s=frontier[si];
        if (ci >= s.cands.size()) continue;
        if (levelUsed >= levelBudget || trialsUsed >= o.maxTrials) {
          stopLevel = true; budgetHit |= trialsUsed >= o.maxTrials; R.truncated = true;
          ++R.layerBudgetCuts;
          break;
        }
        ++levelUsed; ++trialsUsed; ++R.trials; ++attempted[si];

        Trial t; std::string why;
        if (!safeTry(*s.m, s.cands[ci], level, o, t, why)) { ++R.failures[why]; if(why.rfind("exception:",0)==0){trialException=true;R.truncated=true;} continue; }
        t.raw.reset();                               // 只保留清理后的版本，内存减半

        auto h = keyOf(o, *t.normalized);
        auto identity=identityOf(o,*t.normalized);
        if (expanded.count(identity) || pool.count(identity)) { ++R.dedupHits; continue; }
        if (o.semanticCheck && !o.semanticCheck(*rootM, *t.normalized)) { ++R.semanticRejects; continue; }

        Node n;
        n.cost = costOf(o,*t.normalized,fn);
        n.identity=identity;
        n.hash = h;
        n.m = std::move(t.normalized);
        n.path = s.path;
        n.path.push_back({s.hash, s.cands[ci].key(), h});
        n.parentCands = s.cands.size();

        if (seenAll.insert(identity).second) offerTop(R, o.topK, n);   // 任意中间状态都可作为最终结果
        if (n.cost < R.bestCost || (n.cost == R.bestCost && n.path.size()<R.bestPath.size())) { R.bestCost = n.cost; R.bestPath = n.path; R.best=CloneModule(*n.m); canonicalState(*R.best); }

        if(level+1 >= o.depth) continue; // No child pool is needed at the terminal depth.
        if(level+1 < o.depth) {
          n.cands=enumerate(*n.m->getFunction(fn),level+1);
          n.exploreScore=long(n.cands.size())-long(n.parentCands);
        }
        pool.emplace(identity, std::move(n));
        if (pool.size() > poolCap) {                // 限制内存：淘汰池中最差者（已记录到 best/top）
          // Reserve exploration slots BEFORE trimming by static cost.
          std::vector<Node*> ranked;
          for(auto& kv:pool) ranked.push_back(&kv.second);
          std::sort(ranked.begin(),ranked.end(),[](Node*a,Node*b){return better(*a,*b);});
          std::unordered_set<std::string> keep;
          size_t mainCap=size_t(o.beamMain)*o.poolFactor;
          for(size_t i=0;i<std::min(mainCap,ranked.size());++i) keep.insert(ranked[i]->identity);
          std::stable_sort(ranked.begin(),ranked.end(),[](Node*a,Node*b){return a->exploreScore>b->exploreScore;});
          for(auto*n:ranked) if(keep.size()<poolCap) keep.insert(n->identity);
          for(auto it=pool.begin();it!=pool.end();) {
            if(!keep.count(it->first)){it=pool.erase(it);++R.poolDrops;} else ++it;
          }
          R.truncated = true;
        }
      }
    }

    for(size_t si=0;si<frontier.size();++si)
      if(attempted[si]==frontier[si].cands.size()) expanded.insert(frontier[si].identity);

    if (level + 1 >= o.depth) { frontier.clear(); break; }   // 深度上限，无需再选下一层

    // 为池中每个状态枚举下一层候选（探索信号和下一层展开都要用）；没有候选的状态是终点，不进 beam。
    std::vector<Node> cand;
    for (auto& kv : pool) {
      Node n = std::move(kv.second);
      // Candidates were computed before bounded-pool selection.
      n.exploreScore = long(n.cands.size()) - long(n.parentCands);
      if (!n.cands.empty()) cand.push_back(std::move(n));
    }
    std::sort(cand.begin(), cand.end(), better);

    std::vector<bool> chosen(cand.size(), false);
    size_t nMain = std::min<size_t>(o.beamMain, cand.size());
    for (size_t i = 0; i < nMain; ++i) chosen[i] = true;
    std::vector<size_t> rest;
    for (size_t i = nMain; i < cand.size(); ++i) rest.push_back(i);
    std::stable_sort(rest.begin(), rest.end(),
                     [&](size_t a, size_t b) { return cand[a].exploreScore > cand[b].exploreScore; });
    for (size_t j = 0; j < rest.size() && j < o.beamExplore; ++j) chosen[rest[j]] = true;

    std::vector<Node> next;
    for (size_t i = 0; i < cand.size(); ++i) {
      if (chosen[i]) next.push_back(std::move(cand[i]));
      else {R.truncated = true; ++R.beamDrops;}                      // 有可展开的状态被 beam 丢弃
    }
    frontier = std::move(next);
  }

  R.stop = trialException ? "trial_exception_incomplete" : budgetHit ? "trial_budget_exhausted" : (R.layerBudgetCuts ? "layer_budget_truncated" : (R.truncated ? "beam_truncated" : "exhaustive_within_depth"));

  // 最优状态：按记录重放，同时验证确定性。
  if (R.bestPath.empty()) {
    R.best = CloneModule(*rootM); canonicalState(*R.best);
    R.bestReplayVerified = true;
  } else {
    auto checked = replay(*rootM, fn, R.bestPath, o, &R.replayError,&R.replayTrials,&R.replayMismatch);
    R.bestReplayVerified = checked && identityOf(o,*checked)==identityOf(o,*R.best);
    if(checked && !R.bestReplayVerified) {R.replayError="replayed_text_mismatch"; R.replayMismatch=std::move(checked);}
    // Keep the actual selected IR on replay failure: never mismatch IR and cost.

  }
  return R;
}

}  // namespace fusion