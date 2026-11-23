#pragma once

#include "b2b_anchor.h"
#include "llvm/Support/JSON.h"
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
enum class CleanupMode { None, DarmCFGInstCombine };
struct Candidate {
  std::string function, split, left, right;
  unsigned version = 0;
  std::string logicalDecision, logicalLeft, logicalRight;
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
  CleanupMode cleanupMode=CleanupMode::DarmCFGInstCombine;
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
  std::string profitabilityRejection;
};
struct BlockProvenance {
  std::string leftID,rightID,leftLabel,rightLabel,rawBlock,cleanedBlock;
};
struct Trial {
  CleanupMode cleanupMode=CleanupMode::DarmCFGInstCombine;
  Candidate candidate;
  std::unique_ptr<llvm::Module> raw, normalized;
  Features before, afterRaw, after;
  Boundary left, right;
  std::vector<BlockProvenance> blockProvenance;
  bool valid=false, replication=false, swapped=false, rewriteStarted=false;
  double originalSimilarity=0;
  bool originalProfitable=false;
  unsigned cleanupIterations=0;
  // Blocks reachable when the split condition is fixed to false ([0]) / true
  // ([1]); indices into the parent (before) and cleaned (after) functions.
  std::vector<unsigned> sideBefore[2], sideAfter[2];
  bool sideBeforeOk=false, sideAfterOk=false;
  std::string sideReason;
  std::string reason;
  std::string mergePath, localRejectReason;
  std::string planKind, matchedLeft, matchedRight;
  Boundary leftContext, rightContext;
  bool loopHeaderSplit=false;
  llvm::json::Array layoutProfitability;
  llvm::json::Object anchorStats, dataflowExact;
  std::string r2rSpeculationSplit;
  llvm::json::Object r2rSpeculation;
  double mergeMs=0, normalizeMs=0, featuresMs=0, totalMs=0, scoreMs=0;
};
struct ScoreInput {
  const Candidate &candidate;
  const llvm::Function &beforeIR, &afterRawIR, &afterIR;
  const Analysis &beforeAnalysis, &afterAnalysis;
  const Features &before, &afterRaw, &after;
  const Boundary &left, &right;
  bool replication;
  const Trial *trial=nullptr; // optional: side reachability for uniform-wave metrics
};
class Scorer {
public:
  virtual ~Scorer() = default;
  virtual ScoreResult evaluate(const ScoreInput &, const RoundContext &) const = 0;
  // Opt-in only for scorers whose complete input contract excludes CFG
  // analyses. Other scorers retain the existing Analysis-backed path.
  virtual bool evaluateWithoutAnalysis(const Candidate &,const llvm::Function &,
      const llvm::Function &,const RoundContext &,const Trial *,ScoreResult &) const {
    return false;
  }
};
std::string moduleHash(const llvm::Module &);
Features features(llvm::Function &);
RoundContext makeRound(const llvm::Module &, const std::string &function,
                       unsigned version, CleanupMode mode=CleanupMode::DarmCFGInstCombine);
ScoreResult evaluateTrial(const llvm::Module &, Trial &, const RoundContext &, const Scorer &);
bool eligible(const Trial &, const ScoreResult &);
// Complete E-leaves require same-SSA constant predicates unless explicitly enabled.
std::set<std::string> crossLevelCatalogRejections(llvm::Function &,
    const std::vector<Candidate> &);
std::vector<Candidate> enumerate(llvm::Function &, unsigned version);
Trial tryPair(const llvm::Module &, const Candidate &, unsigned currentVersion,
              CleanupMode, bool allowB2B, bool artifactB2B, bool speculateR2R);
void addDataflowCandidates(llvm::Function &, std::vector<Candidate> &);
llvm::Optional<Trial> tryDataflowExact(const llvm::Module &, const Candidate &, CleanupMode,
                                      llvm::StringRef solver, llvm::StringRef costs,
                                      llvm::StringRef worker);
enum class B2BExit { PreserveSuffix, Merge, ForkJoin, Independent };
// Emit an already-validated, order-preserving B2B alignment.
void emitB2BLinear(llvm::BranchInst &, llvm::BasicBlock &, llvm::BasicBlock &,
                   llvm::BasicBlock *join, llvm::ArrayRef<AnchorMatch>,
                   B2BExit exit, bool guarded, llvm::ArrayRef<AnchorGapPlacement>);
std::vector<Trial> planSingleBranchB2B(const llvm::Module &, const Candidate &, CleanupMode,
                                       llvm::function_ref<int(const llvm::Instruction &)> intrinsicCost,
                                       llvm::function_ref<int(const llvm::Instruction &)> anchorCost,
                                       llvm::function_ref<int(llvm::Type *)> anchorSelectCost,
                                       llvm::function_ref<int(llvm::Type *)> anchorPhiCost);
}
