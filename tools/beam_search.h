#pragma once
#include "fusion_search.h"
#include <functional>
#include <map>
#include <string>
#include <vector>
namespace fusion {
struct BeamOptions {
 unsigned depth=4, beamMain=4, beamExplore=2, poolFactor=3, maxTrials=256, topK=5, optLevel=3;
 CleanupMode cleanupMode=CleanupMode::DarmCFGScalarFixedPoint;
 // Bucketing only: exact IR text is compared as well to avoid unsafe dedup.
 std::function<std::string(const llvm::Module&)> stateKey;
 // State cost, used identically for the cleaned baseline and all candidates.
 std::function<double(llvm::Module&, const std::string&)> stateCost;
 std::function<bool(const llvm::Module&, const llvm::Module&)> semanticCheck;
};
struct Step { std::string parentHash,candidateKey,childHash; };
struct TopEntry { std::string hash; double cost=0; std::vector<Step> path; std::string irText; };
struct BeamResult {
 std::unique_ptr<llvm::Module> best, replayMismatch;
 double baselineCost=0,bestCost=0;
 std::vector<Step> bestPath;
 bool bestReplayVerified=false;
 std::string replayError;
 std::vector<TopEntry> top;
 unsigned trials=0,nodesExpanded=0,dedupHits=0,semanticRejects=0,replayTrials=0;
 unsigned layerBudgetCuts=0,poolDrops=0,beamDrops=0;
 std::map<std::string,unsigned> failures;
 bool truncated=false;
 std::string stop;
};
BeamResult beamSearch(const llvm::Module&,const std::string&,const BeamOptions&);
std::unique_ptr<llvm::Module> replay(const llvm::Module&,const std::string&,const std::vector<Step>&,const BeamOptions&,std::string* error=nullptr,unsigned* trials=nullptr,std::unique_ptr<llvm::Module>* mismatch=nullptr);
}
