#pragma once
#include "fusion_search.h"
#include "ir_pressure.h"
#include "ir_dependency.h"
namespace fusion {
struct PostOptBlockWork {
  double work=0;
  uint64_t instructions=0, unknown=0;
  std::map<std::string,double> categories;
};
struct PostOptFeatures {
  double work=0;
  std::map<std::string,double> timingMs;
  uint64_t instructions=0, unknown=0;
  bool targetAvailable=false, uniformityAvailable=false;
  IRPressure pressure;
  IRDependency dependency;
  std::map<std::string,std::string> blockText;
  std::map<std::string,PostOptBlockWork> blockWork;
  std::map<std::string,double> categories;
  std::map<std::string,std::pair<uint64_t,int64_t>> costTable;
};
PostOptFeatures postOptFeatures(const llvm::Function&, int staticAllocaCost=-1, bool dependencyFeatures=false);
struct PostOptConfig {
  double absoluteThreshold=0, relativeThreshold=0, pressureWeight=0;
  bool profileEnabled=false;
  std::string profileBundleText, profileReadError;
  std::string profileParsedParent, profileSerializedParent;
  bool dependencyFeatures=false;
  int staticAllocaCost=-1; // Explicit uncalibrated AMD private static-allocation fallback.
};
void applyProfilePolicy(const ScoreInput&,const RoundContext&,const PostOptFeatures&,
                        const PostOptFeatures&,const PostOptConfig&,ScoreResult&);
class PostOptScorer final:public Scorer {
  PostOptConfig config;
  mutable std::string baselineKey;
  mutable PostOptFeatures baselineFeatures;
public:
  explicit PostOptScorer(PostOptConfig c):config(c){}
  ScoreResult evaluate(const ScoreInput&,const RoundContext&)const override;
};
}
