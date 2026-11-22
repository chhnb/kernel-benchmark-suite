#pragma once
#include "fusion_search.h"
#include "tti_quote_key.h"
#include "tti_cost_kind.h"
#include "tti_memory_io.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include <array>
#include <cmath>
#include <set>
#include <stdexcept>
namespace fusion {
// LLVM12 owns all transformation IR; the isolated worker only reads text snapshots.
class LLVM24Scorer final:public Scorer {
  struct Cost {double value=0;int64_t unknown=0,zero=0,count=0;bool adjusted=false;std::map<std::string,double> counts;
    std::vector<double> blockCost;std::vector<bool> blockUnknown;}; // indexed by function block position
  std::string worker;
  mutable std::string cachedHash;
  mutable Cost cachedControl;
  mutable std::string cachedParentHash;
  mutable Cost cachedParent;
  std::string quoteMode;
  struct Quote { int64_t value; std::string histogramKey; };
  mutable std::map<std::string, Quote> quotes;
  mutable std::string quoteContext;
  mutable uint64_t quoteHits=0, quoteAudits=0, quoteWorkerQueries=0;
  using QuoteKeys = std::vector<std::vector<std::optional<std::string>>>;
  QuoteKeys quoteKeys(const llvm::Function &f) const {
    using namespace llvm;
    if (quoteMode=="off" || f.getParent()->getTargetTriple()!="amdgcn-amd-amdhsa" ||
        f.getFnAttribute("target-cpu").getValueAsString()!="gfx906" || f.hasMetadata()) return {};
    std::string context; raw_string_ostream stream(context);
    stream << f.getName() << ';' << f.getCallingConv() << ';' << f.getParent()->getDataLayoutStr() << ';';
    for (unsigned index=0; index<=f.arg_size(); ++index)
      stream << index << ":" << f.getAttributes().getAsString(index) << ";";
    stream << f.getAttributes().getAsString(AttributeList::FunctionIndex); stream.flush();
    if (context!=quoteContext) { quotes.clear(); quoteContext=std::move(context); }
    std::set<const BasicBlock*> reachable; std::vector<const BasicBlock*> pending{&f.getEntryBlock()};
    while(!pending.empty()) { auto *b=pending.back();pending.pop_back();if(!reachable.insert(b).second)continue;
      for(auto *successor:successors(b))pending.push_back(successor); }
    QuoteKeys keys(f.size()); unsigned block=0;
    for (const auto &b:f) {
      if (reachable.count(&b)) for (const auto &i:b)
        if(!isa<DbgInfoIntrinsic>(i) && !legacyLifetimeMarker(i)) keys[block].push_back(gcnQuoteKey(i));
      ++block;
    }
    return keys;
  }
  std::optional<Cost> quotedCost(const QuoteKeys &keys) const {
    if(keys.empty())return std::nullopt;
    Cost c;c.blockCost.assign(keys.size(),0);c.blockUnknown.assign(keys.size(),false);
    for(unsigned block=0;block<keys.size();++block)for(const auto &key:keys[block]) {
      if(!key)return std::nullopt;
      auto found=quotes.find(*key);if(found==quotes.end())return std::nullopt;
      const auto &q=found->second;c.value+=q.value;c.blockCost[block]+=q.value;
      ++c.count;c.zero+=q.value==0;++c.counts[q.histogramKey];
    }
    return c;
  }
#ifdef __linux__
  mutable std::unique_ptr<decision::PersistentTTI> session;
  mutable std::string sessionFunction;
  mutable bool persistentUnavailable=false;
#endif

  // Sum of accepted per-instruction costs over the given blocks; false if any
  // listed block has an unknown cost or lies outside the worker's block range.
  static bool sideCost(const Cost&c,const std::vector<unsigned>&blocks,double&out){
    out=0;for(auto b:blocks){if(b>=c.blockCost.size()||c.blockUnknown[b])return false;out+=c.blockCost[b];}return true;
  }
  // LLVM 24 cannot represent legacy lifetime markers with a PHI or select
  // as their underlying object. Normalize those markers in the scoring copy.
  static bool legacyLifetimeMarker(const llvm::Instruction &instruction) {
    using namespace llvm;
    const auto *intrinsic = dyn_cast<IntrinsicInst>(&instruction);
    if (!intrinsic || (intrinsic->getIntrinsicID() != Intrinsic::lifetime_start &&
                       intrinsic->getIntrinsicID() != Intrinsic::lifetime_end))
      return false;
    const auto *object = intrinsic->getArgOperand(1)->stripPointerCasts();
    return isa<PHINode>(object) || isa<SelectInst>(object);
  }
  Cost query(const llvm::Function&f,
             llvm::DenseMap<const llvm::Instruction *, int> *instructions = nullptr) const {
    using namespace llvm;
    std::unique_ptr<Module> scoringModule;
    for(const auto &block:f)
      for(const auto &instruction:block)
        if(legacyLifetimeMarker(instruction)&&!scoringModule)
          scoringModule=CloneModule(*f.getParent());
    if(scoringModule)
      for(auto &block:*scoringModule->getFunction(f.getName()))
        for(auto it=block.begin();it!=block.end();){
          auto &instruction=*it++;
          if(legacyLifetimeMarker(instruction))instruction.eraseFromParent();
        }
    const auto &module=scoringModule?*scoringModule:*f.getParent();
    const auto keys=scoringModule?QuoteKeys{}:quoteKeys(f);
    const auto predicted=quotedCost(keys);
    if(predicted && quoteMode=="on" && !instructions) { ++quoteHits; return *predicted; }
    ++quoteWorkerQueries;
    std::string result;
#ifdef __linux__
    std::string ir;
    raw_string_ostream stream(ir);
    module.print(stream,nullptr);
    stream.flush();
    if(!persistentUnavailable){
      try {
        if(!session||sessionFunction!=f.getName()){
          session=std::make_unique<decision::PersistentTTI>(worker,f.getName(),false);
          sessionFunction=f.getName().str();
        }
        result=session->score(ir);
        if(StringRef(result).trim()=="null")
          throw std::runtime_error("persistent worker rejected IR");
      }catch(const std::runtime_error &){
        session.reset();
        persistentUnavailable=true;
        result.clear();
      }
    }
    if(result.empty())result=decision::runMemoryTTI(worker,ir,f.getName(),false,60);
#else
    SmallString<128> directory;
    if(auto e=sys::fs::createUniqueDirectory("fusion-llvm24-tti",directory))throw std::runtime_error(e.message());
    struct Remove {std::string dir;~Remove(){sys::fs::remove_directories(dir);}} remove{directory.str().str()};
    const std::string input=remove.dir+"/input.ll",output=remove.dir+"/cost.json",error=remove.dir+"/error.txt";
    {
      std::error_code ec;
      raw_fd_ostream stream(input,ec);
      if(ec)throw std::runtime_error(ec.message());
      module.print(stream,nullptr);
    }
    std::array<StringRef,3> args{{worker,input,f.getName()}};
    std::array<Optional<StringRef>,3> redirects{{StringRef(""),StringRef(output),StringRef(error)}};
    if(sys::ExecuteAndWait(worker,args,None,redirects,60))throw std::runtime_error("llvm24_worker_failed");
    auto buffer=MemoryBuffer::getFile(output);
    if(!buffer)throw std::runtime_error("missing LLVM24 output");
    result=(*buffer)->getBuffer().str();
#endif
    auto j=json::parse(result);if(!j)throw std::runtime_error(toString(j.takeError()));
    auto*o=j->getAsObject();if(!o)throw std::runtime_error("invalid worker JSON");
    if(o->getString("schema")!=Optional<StringRef>("llvm24-tti-v1")||
       o->getString("source_revision")!=Optional<StringRef>("6be16f356d3e"))throw std::runtime_error("worker identity mismatch");
    if (o->getString("cost_kind")!=Optional<StringRef>(ttiCostKindName()))
      throw std::runtime_error("worker cost kind mismatch");
    if(o->getString("triple")!=Optional<StringRef>(f.getParent()->getTargetTriple())||
       o->getString("cpu")!=Optional<StringRef>(f.getFnAttribute("target-cpu").getValueAsString())||
       o->getString("features")!=Optional<StringRef>(f.getFnAttribute("target-features").getValueAsString()))throw std::runtime_error("worker target mismatch");
    auto n=o->getInteger("instructions"),u=o->getInteger("unknown"),z=o->getInteger("zero"),v=o->getInteger("modeled_cost");
    if(!n||!u||!z||!v)throw std::runtime_error("worker cost fields missing");
    int64_t count=0;std::set<const BasicBlock*> seen;std::vector<const BasicBlock*> pending{&f.getEntryBlock()};
    while(!pending.empty()){auto*b=pending.back();pending.pop_back();if(!seen.insert(b).second)continue;
      for(auto*s:successors(b))pending.push_back(s);for(auto&i:*b)if(!isa<DbgInfoIntrinsic>(i)&&!legacyLifetimeMarker(i))++count;}
    if(count!=*n)throw std::runtime_error("IR_upgrade_changed_instruction_count");
    Cost c;c.value=*v;c.count=*n;c.unknown=*u;c.zero=*z;
    auto adjustment=o->getString("compatibility_adjustment");c.adjusted=adjustment&&!adjustment->empty();
    auto*h=o->getObject("histogram");if(!h)throw std::runtime_error("worker histogram missing");
    for(auto&kv:*h){auto value=kv.second.getAsInteger();if(!value)throw std::runtime_error("invalid histogram");c.counts[kv.first.str()]=*value;}
    // Per-block costs. block_index counts every block in function order, the
    // same order LLVM12 uses, so side block indices map directly.
    // Diagnostic only: a malformed row disables side metrics (empty vectors),
    // it never rejects the main score.
    c.blockCost.assign(f.size(),0);c.blockUnknown.assign(f.size(),false);
    bool rowsOk=true;
    if(auto*rows=o->getArray("instruction_costs")){
      for(auto&row:*rows){auto*r=row.getAsObject();if(!r){rowsOk=false;break;}
        auto bi=r->getInteger("block_index");if(!bi||*bi<0||size_t(*bi)>=f.size()){rowsOk=false;break;}
        Optional<int64_t> v;if(auto*accepted=r->get("accepted_cost"))v=accepted->getAsInteger();
        if(v)c.blockCost[*bi]+=*v;else c.blockUnknown[*bi]=true;}
    }else rowsOk=false;
    if(!rowsOk){c.blockCost.clear();c.blockUnknown.clear();}
    if (instructions && rowsOk) {
      const auto &rows = *o->getArray("instruction_costs");
      size_t position = 0;
      int64_t blockIndex = 0;
      for (const auto &block : f) {
        int64_t index = 0;
        if (seen.count(&block))
          for (const auto &inst : block) {
            if (isa<DbgInfoIntrinsic>(inst) || legacyLifetimeMarker(inst)) continue;
            if (position >= rows.size())
              throw std::runtime_error("anchor_instruction_quote_row_missing");
            const auto &row = *rows[position++].getAsObject();
            if (row.getInteger("block_index") != blockIndex ||
                row.getInteger("instruction_index") != index++)
              throw std::runtime_error("anchor_instruction_quote_row_mismatch");
            auto value = row.getInteger("accepted_cost");
            if (value && *value >= 0 && *value <= 1000000)
              instructions->insert({&inst, static_cast<int>(*value)});
          }
        ++blockIndex;
      }
      if (position != rows.size())
        throw std::runtime_error("anchor_instruction_quote_row_count");
    }
    if(predicted) {
      ++quoteAudits;
      if(predicted->value!=c.value || predicted->count!=c.count || predicted->zero!=c.zero ||
         c.unknown || predicted->counts!=c.counts || predicted->blockCost!=c.blockCost)
        throw std::runtime_error("tti_quote_context_incomplete");
    }
    if(!keys.empty() && rowsOk) if(auto *rows=o->getArray("instruction_costs")) {
      for(const auto &row:*rows) {
        const auto *r=row.getAsObject();if(!r)continue;
        auto block=r->getInteger("block_index"), index=r->getInteger("instruction_index");
        auto value=r->getInteger("accepted_cost");auto reportKey=r->getString("key");
        if(!block || !index || !value || *value<0 || !reportKey || *block<0 || *index<0 ||
           size_t(*block)>=keys.size() || size_t(*index)>=keys[*block].size()) continue;
        const auto &key=keys[*block][*index];if(!key)continue;
        Quote q{*value,reportKey->str()+":cost"+std::to_string(*value)};
        auto found=quotes.emplace(*key,q);
        if(!found.second && (found.first->second.value!=q.value || found.first->second.histogramKey!=q.histogramKey))
          throw std::runtime_error("tti_quote_key_conflict");
      }
    }
    return c;
  }
public:
  llvm::DenseMap<const llvm::Instruction *, int> instructionCosts(
      const llvm::Function &f) const {
    llvm::DenseMap<const llvm::Instruction *, int> result;
    query(f, &result);
    return result;
  }

  struct TransferCosts {
    llvm::DenseMap<llvm::Type *, int> selects, phis;
  };

  TransferCosts anchorTransferCosts(const llvm::Function &f) const {
    using namespace llvm;
    SmallVector<Type *, 16> types;
    DenseSet<Type *> seen;
    for (const auto &block : f)
      for (const auto &inst : block)
        for (const auto &operand : inst.operands()) {
          auto *type = operand->getType();
          if (type->isSingleValueType() && !type->isX86_MMXTy() &&
              seen.insert(type).second)
            types.push_back(type);
        }
    auto &context = f.getContext();
    Module probe("anchor-transfer-quotes", context);
    probe.setTargetTriple(f.getParent()->getTargetTriple());
    probe.setDataLayout(f.getParent()->getDataLayout());
    SmallVector<Type *, 32> params{Type::getInt1Ty(context)};
    for (auto *type : types) {
      params.push_back(type);
      params.push_back(type);
    }
    auto *fn = Function::Create(FunctionType::get(Type::getVoidTy(context), params, false),
                                GlobalValue::ExternalLinkage, f.getName(), probe);
    for (StringRef name : {"target-cpu", "target-features"})
      if (f.hasFnAttribute(name))
        fn->addFnAttr(f.getFnAttribute(name));
    IRBuilder<> builder(BasicBlock::Create(context, "entry", fn));
    SmallVector<const Instruction *, 16> selects;
    auto arg = fn->arg_begin();
    auto *condition = &*arg++;
    SmallVector<std::pair<Value *, Value *>, 16> operands;
    for (auto *type : types) {
      auto *left = &*arg++;
      auto *right = &*arg++;
      operands.emplace_back(left, right);
      selects.push_back(cast<Instruction>(builder.CreateSelect(condition, left, right)));
    }
    SmallVector<const Instruction *, 16> phis;
    auto *left = BasicBlock::Create(context, "left", fn);
    auto *right = BasicBlock::Create(context, "right", fn);
    auto *join = BasicBlock::Create(context, "join", fn);
    builder.CreateCondBr(condition, left, right);
    BranchInst::Create(join, left);
    BranchInst::Create(join, right);
    builder.SetInsertPoint(join);
    for (auto [l, r] : operands) {
      auto *phi = builder.CreatePHI(l->getType(), 2);
      phi->addIncoming(l, left);
      phi->addIncoming(r, right);
      phis.push_back(phi);
    }
    builder.CreateRetVoid();
    auto quoted = instructionCosts(*fn);
    TransferCosts result;
    for (auto item : llvm::enumerate(types)) {
      const auto sel = quoted.find(selects[item.index()]);
      if (sel != quoted.end()) result.selects.insert({item.value(), sel->second});
      const auto phi = quoted.find(phis[item.index()]);
      if (phi != quoted.end()) result.phis.insert({item.value(), phi->second});
    }
    return result;
  }

  std::map<std::string, int64_t> intrinsicCosts(const llvm::Function &f) const {
    std::map<std::string, int64_t> costs;
    for (const auto &entry : query(f).counts) {
      llvm::StringRef key(entry.first);
      if (!key.consume_front("call:llvm.")) continue;
      auto [name, rest] = key.split(':');
      llvm::StringRef cost = rest.rsplit(':').second;
      int64_t value;
      if (cost.consume_front("cost") && !cost.getAsInteger(10, value))
        costs.emplace(("llvm." + name).str(), value);
    }
    return costs;
  }

  std::vector<Trial> planAnchorB2B(const llvm::Module &module, const Candidate &candidate,
                                   CleanupMode cleanup, AnchorGap gap, AnchorScoring scoring) const {
    using namespace llvm;
    auto *f = module.getFunction(candidate.function);
    if (!f) return {};
    std::optional<std::map<std::string, int64_t>> intrinsicQuotes;
    std::set<std::string> unquotedIntrinsics;
    auto intrinsicCost = [&](const Instruction &inst) -> int {
      if (!intrinsicQuotes) {
        intrinsicQuotes = intrinsicCosts(*f);
      }
      StringRef name = cast<CallInst>(inst).getCalledFunction()->getName();
      auto found = intrinsicQuotes->lower_bound(name.str());
      if (found != intrinsicQuotes->end() &&
          (found->first == name || StringRef(found->first).startswith((name + ".").str())))
        return found->second;
      if (unquotedIntrinsics.insert(name.str()).second)
        errs() << "anchor intrinsic cost fallback (1): " << name << "\n";
      return 1;
    };
    std::optional<DenseMap<const Instruction *, int>> prices;
    auto cost = [&](const Instruction &inst) {
      if (!prices)
        prices = instructionCosts(*f);
      auto found = prices->find(&inst);
      return found == prices->end() ? -1 : found->second;
    };
    std::optional<LLVM24Scorer::TransferCosts> transferPrices;
    auto transferCost = [&](Type *type, bool phi) {
      if (!transferPrices)
        transferPrices = anchorTransferCosts(*f);
      const auto &prices = phi ? transferPrices->phis : transferPrices->selects;
      auto found = prices.find(type);
      return found == prices.end() ? -1 : found->second;
    };
    auto selectCost = [&](Type *type) { return transferCost(type, false); };
    auto phiCost = [&](Type *type) { return transferCost(type, true); };
    return planSingleBranchB2B(module, candidate, cleanup, intrinsicCost, cost, selectCost, phiCost, gap, scoring);
  }

  explicit LLVM24Scorer(std::string executable, std::string mode="on")
      :worker(std::move(executable)),quoteMode(std::move(mode)){}
  llvm::json::Object quoteCacheStats() const {
    return llvm::json::Object{{"mode",quoteMode},{"hits",int64_t(quoteHits)},
      {"audited_hits",int64_t(quoteAudits)},{"worker_queries",int64_t(quoteWorkerQueries)},
      {"quotes",int64_t(quotes.size())}};
  }
  // LLVM24 quotation reads IR and the round, not the legacy Analysis objects.
  // This entry point lets bounded callers avoid rebuilding unused DT/PDT/RI.
  ScoreResult evaluatePair(const Candidate &candidate,const llvm::Function &beforeIR,
      const llvm::Function &afterIR,const RoundContext &r,const Trial *trial=nullptr) const {
    ScoreResult s;s.coverage.hardwareCosts="LLVM24_TTI_6be16f356d3e_reciprocal_throughput_uncalibrated";
    if(candidate.version!=r.parentVersion||candidate.function!=r.function){s.reason="round_identity_mismatch";return s;}
    try {
      if(cachedHash!=r.controlHash){auto*f=r.control->getFunction(r.function);if(!f)throw std::runtime_error("control_missing");cachedControl=query(*f);cachedHash=r.controlHash;}
      auto after=query(afterIR);auto &before=cachedControl;
      s.metrics={{"work_before",before.value},{"work_after",after.value},{"unknown_before",double(before.unknown)},
        {"unknown_after",double(after.unknown)},{"zero_before",double(before.zero)},{"zero_after",double(after.zero)},
        {"instructions_before",double(before.count)},{"instructions_after",double(after.count)},{"tti_major",24},
        {"sm70_ptx32_to_ptx60_before",before.adjusted?1.0:0.0},{"sm70_ptx32_to_ptx60_after",after.adjusted?1.0:0.0}};
      for(auto&kv:before.counts)s.metrics["tti24_before_count:"+kv.first]=kv.second;
      for(auto&kv:after.counts)s.metrics["tti24_after_count:"+kv.first]=kv.second;
      if(before.unknown||after.unknown){s.reason="llvm24_unknown_cost_rejection";return s;}
      auto cfgPhiCost = [](const Cost &cost) {
        double total = 0;
        for (const auto &entry : cost.counts) {
          llvm::StringRef key(entry.first);
          if (!key.startswith("br.") && !key.startswith("phi:")) continue;
          int64_t unit = 0;
          if (!key.rsplit(":cost").second.getAsInteger(10, unit))
            total += unit * entry.second;
        }
        return total;
      };
      const double cfgGain = cfgPhiCost(before) - cfgPhiCost(after);
      const double totalGain = before.value - after.value;
      const double workGain = totalGain - cfgGain;
      s.metrics["non_cfg_work_gain"] = workGain;
      s.metrics["cfg_phi_gain"] = cfgGain;
      s.metrics["total_tti_gain"] = totalGain;
      s.staticGain=before.value-after.value;s.staticScore=s.staticGain/std::max(1.0,before.value);s.total=s.staticScore;
      s.parentGain=s.staticGain; // Preserve v1 acceptance semantics, not diagnostic S-A.
      // staticGain equals the gain of a wave in which both sides execute every
      // block. Report the uniform-wave gains alongside: the cost of the blocks a
      // wave executes when all its lanes take one side, before vs after fusion.
      // "before" is the parent S (equal to control in scoped cleanup modes).
      s.metrics["side_metrics_available"]=0;
      if(trial&&trial->sideBeforeOk&&trial->sideAfterOk){
        // A failing parent query only disables side metrics for this trial.
        if(cachedParentHash!=r.parentHash){
          try{cachedParent=query(beforeIR);}catch(const std::exception &error){if(llvm::StringRef(error.what()).startswith("tti_quote_"))throw;cachedParent=Cost();}
          cachedParentHash=r.parentHash;
        }
        double b0,b1,a0,a1;
        if(sideCost(cachedParent,trial->sideBefore[0],b0)&&sideCost(cachedParent,trial->sideBefore[1],b1)&&
           sideCost(after,trial->sideAfter[0],a0)&&sideCost(after,trial->sideAfter[1],a1)){
          s.metrics["side_false_before"]=b0;s.metrics["side_false_after"]=a0;
          s.metrics["side_true_before"]=b1;s.metrics["side_true_after"]=a1;
          s.metrics["uniform_gain_false"]=b0-a0;s.metrics["uniform_gain_true"]=b1-a1;
          s.metrics["side_metrics_available"]=1;
        }else s.metrics["side_metrics_unknown_cost"]=1;
      }
      s.status=ScoreStatus::Scored;s.reason="llvm24_static_control_delta";
    }catch(const std::exception&e){s.reason=e.what();}
    if(s.status==ScoreStatus::Scored&&(!std::isfinite(s.total)||!std::isfinite(s.staticGain)||
       !std::isfinite(s.staticScore)||!std::isfinite(s.cleanupGain)||!std::isfinite(s.parentGain)||
       !std::isfinite(s.dependencyPenalty)||!std::isfinite(s.livenessPenalty))){
      s.status=ScoreStatus::NotEvaluable;s.reason="nonfinite_score";
    }
    return s;
  }
  bool evaluateWithoutAnalysis(const Candidate &candidate,const llvm::Function &before,
      const llvm::Function &after,const RoundContext &round,const Trial *trial,ScoreResult &out) const override {
    out=evaluatePair(candidate,before,after,round,trial);return true;
  }
  ScoreResult evaluate(const ScoreInput&i,const RoundContext&r)const override {
    return evaluatePair(i.candidate,i.beforeIR,i.afterIR,r,i.trial);
  }

};
}
