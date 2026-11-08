#pragma once
#include "llvm/IR/Module.h"
#include "llvm/Analysis/RegionInfo.h"
#include "llvm/Analysis/DominanceFrontier.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/PostDominators.h"
#include <memory>
#include <map>
#include <tuple>
#include <string>
#include <vector>
namespace fusion {
class LogicalRegionState;
enum class CleanupMode { None, O3, DarmCFG, DarmCFGEarlyCSE, DarmCFGScalarFixedPoint, PostOptFixedPoint };
struct Candidate {
  std::string function, split, left, right;
  unsigned version = 0;
  std::string logicalDecision, logicalLeft, logicalRight;
  bool localCopysign=false;
  std::string key() const { return function+":"+split+":"+left+":"+right; }
};
struct OperationKey {
  std::string opcode, type, operandTypes, category, callee, attributes;
  unsigned scalarBits=0, lanes=1;
  bool scalable=false;
  int64_t legacyWeight=0;
  auto tuple() const { return std::tie(opcode,type,operandTypes,category,callee,attributes,scalarBits,lanes,scalable,legacyWeight); }
  bool operator<(const OperationKey&o)const{return tuple()<o.tuple();}
};
struct Features {
  int64_t blocks=0, instructions=0, cost=0, phis=0, selects=0, branches=0, loops=0;
  std::map<OperationKey,int64_t> operations;
};
struct Boundary {
  std::string entry, exit;
  std::vector<std::string> blocks, liveIns, liveOuts;
};
// These analyses and their pointers belong to exactly one IR snapshot.
struct Analysis {
  llvm::DominatorTree dt;
  llvm::PostDominatorTree pdt;
  llvm::DominanceFrontier df;
  llvm::RegionInfo regions;
  llvm::LoopInfo loops;
  explicit Analysis(llvm::Function &);
};
struct RoundContext {
  CleanupMode cleanupMode=CleanupMode::O3;
  unsigned parentVersion=0;
  std::string function, parentHash, controlHash, targetTriple, dataLayout;
  std::string targetAttributes, llvmVersion, cleanup;
  std::string featureSchema="opcode-type-v1", weightVersion="legacy-darm-v1";
  std::unique_ptr<llvm::Module> control;
  Features parentFeatures, controlFeatures;
  double normalizationScale=1, controlMs=0;
  unsigned controlCleanupIterations=0;
};
enum class ScoreStatus { Scored, NotEvaluable };
struct CostContribution {
  OperationKey operation;
  int64_t controlCount=0, afterCount=0, gain=0;
};
struct ModelCoverage {
  std::string dependency="unavailable", liveness="unavailable", divergence="unavailable";
  std::string provenance="unavailable", hardwareCosts="uncalibrated";
  bool legacyCountsComplete=false;
};
struct ScoreResult {
  ScoreStatus status=ScoreStatus::NotEvaluable;
  std::string reason="trial_not_scored";
  double staticGain=0, cleanupGain=0, parentGain=0, staticScore=0;
  double dependencyPenalty=0, livenessPenalty=0, total=0;
  std::vector<CostContribution> contributions;
  ModelCoverage coverage;
  std::map<std::string,double> metrics;
};
struct BlockProvenance {
  std::string leftID,rightID,leftLabel,rightLabel,rawBlock,cleanedBlock;
};
struct Trial {
  std::shared_ptr<LogicalRegionState> logicalState;
  CleanupMode cleanupMode=CleanupMode::O3;
  Candidate candidate;
  std::unique_ptr<llvm::Module> raw, normalized;
  Features before, afterRaw, after;
  Boundary left, right;
  std::vector<BlockProvenance> blockProvenance;
  bool valid=false, replication=false, swapped=false;
  double originalSimilarity=0;
  bool originalProfitable=false;
  unsigned cleanupIterations=0;
  std::string reason;
  double mergeMs=0, normalizeMs=0, featuresMs=0, totalMs=0, scoreMs=0;
};
struct ScoreInput {
  const Candidate &candidate;
  const llvm::Function &beforeIR, &afterRawIR, &afterIR;
  const Analysis &beforeAnalysis, &afterAnalysis;
  const Features &before, &afterRaw, &after;
  const Boundary &left, &right;
  bool replication;
};
class Scorer {
public:
  virtual ~Scorer() = default;
  virtual ScoreResult evaluate(const ScoreInput &, const RoundContext &) const = 0;
};
// Temporary policy, replace this class without changing search or transformation.
class StaticCostScorer final : public Scorer {
public:
  ScoreResult evaluate(const ScoreInput &, const RoundContext &) const override;
};
struct Options {
  CleanupMode cleanupMode=CleanupMode::DarmCFGEarlyCSE;
  unsigned maxRounds=8, maxTrials=256, optLevel=3;
  double threshold=0;
  bool requireParentGain=true;
  bool adjacentOnly=false;
  bool localCopysign=false;
};
struct Observer {
  virtual ~Observer() = default;
  virtual void initial(const llvm::Module &) {}
  virtual void logical(unsigned version, const std::string &json) {}
  virtual void round(const RoundContext &) {}
  virtual void trial(const Trial &, const RoundContext &, const ScoreResult &, bool eligible) {}
  virtual void commit(unsigned version, const Candidate &, const ScoreResult &,
                      const llvm::Module &) {}
};
struct Result {
  std::unique_ptr<llvm::Module> module;
  unsigned commits=0, trials=0;
  std::string stop;
};
std::string moduleHash(const llvm::Module &);
Features features(llvm::Function &);
RoundContext makeRound(const llvm::Module &, const std::string &function,
                       unsigned version, unsigned optLevel, CleanupMode mode=CleanupMode::O3);
ScoreResult evaluateTrial(const llvm::Module &, Trial &, const RoundContext &, const Scorer &);
bool eligible(const Trial &, const ScoreResult &, const Options &);
void normalize(llvm::Module &, unsigned optLevel);
unsigned cleanup(llvm::Module &, const std::string &function, unsigned level, CleanupMode);
std::vector<Candidate> enumerate(llvm::Function &, unsigned version);
std::vector<Candidate> enumerateAdjacent(llvm::Function &, unsigned version);
Trial tryPair(const llvm::Module &, const Candidate &, unsigned currentVersion,
              unsigned optLevel, CleanupMode mode=CleanupMode::O3, const LogicalRegionState *logical=nullptr);
Result greedy(const llvm::Module &, const std::string &function,
              const Options &, const Scorer &, Observer *observer=nullptr);
}
