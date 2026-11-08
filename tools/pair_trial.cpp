#include "darm_pair_engine/RegionMelder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/FormatVariadic.h"
#include <map>
#include <set>
#include <functional>
using namespace llvm;
static std::string text(const Value&V){std::string s;raw_string_ostream o(s);V.print(o);return o.str();}
static std::string text(const Module&M){std::string s;raw_string_ostream o(s);M.print(o,nullptr);return o.str();}
static std::string name(const Value*V){if(!V)return "<exit>";std::string s;raw_string_ostream o(s);V->printAsOperand(o,false);return o.str();}
static void write(StringRef path,StringRef s){std::error_code ec;raw_fd_ostream out(path,ec);if(ec){errs()<<ec.message();exit(3);}out<<s;}
static void jsonwrite(StringRef path,json::Object value){write(path,formatv("{0:2}\n",json::Value(std::move(value))).str());}
struct Unit{BasicBlock*entry;BasicBlock*exit;Region*region;std::set<BasicBlock*> blocks;};
static json::Object boundary(const Unit&u){std::set<std::string> ins,outs;json::Array blocks;for(auto*B:u.blocks){blocks.push_back(name(B));for(auto&I:*B){for(auto&op:I.operands()){auto*V=op.get();auto*Def=dyn_cast<Instruction>(V);if((Def&&!u.blocks.count(Def->getParent()))||isa<Argument>(V))ins.insert(name(V));}for(auto*U:I.users())if(auto*Use=dyn_cast<Instruction>(U))if(!u.blocks.count(Use->getParent()))outs.insert(name(&I));}}json::Array a,b;for(auto&s:ins)a.push_back(s);for(auto&s:outs)b.push_back(s);return json::Object{{"entry",name(u.entry)},{"exit",name(u.exit)},{"blocks",std::move(blocks)},{"live_ins",std::move(a)},{"live_outs",std::move(b)}};}
static json::Object facts(Function&F){
 json::Array bs;std::map<std::string,int64_t> histogram;int64_t total=0,cost=0,phis=0,selects=0,loads=0,stores=0,calls=0,conditional=0;
 for(auto&B:F){json::Array instructions,succ,pred;int64_t bc=0;for(auto*S:successors(&B))succ.push_back(name(S));for(auto*P:predecessors(&B))pred.push_back(name(P));
  for(auto&I:B){histogram[I.getOpcodeName()]++;total++;int c=InstructionMatch::getInstructionCost(&I);cost+=c;bc+=c;phis+=isa<PHINode>(I);selects+=isa<SelectInst>(I);loads+=isa<LoadInst>(I);stores+=isa<StoreInst>(I);calls+=isa<CallBase>(I);if(auto*br=dyn_cast<BranchInst>(&I))conditional+=br->isConditional();
   json::Array uses,operands;for(auto&op:I.operands())operands.push_back(name(op.get()));for(auto*U:I.users())uses.push_back(name(U));instructions.push_back(json::Object{{"name",name(&I)},{"opcode",I.getOpcodeName()},{"llvm",text(I)},{"type",[&](){std::string s;raw_string_ostream o(s);I.getType()->print(o);return o.str();}()},{"operands",std::move(operands)},{"users",std::move(uses)},{"darm_static_cost",c},{"may_read",I.mayReadFromMemory()},{"may_write",I.mayWriteToMemory()},{"side_effects",I.mayHaveSideEffects()}});
  }bs.push_back(json::Object{{"name",name(&B)},{"instructions",std::move(instructions)},{"successors",std::move(succ)},{"predecessors",std::move(pred)},{"darm_static_cost",bc}});
 }json::Object hist;for(auto&x:histogram)hist[x.first]=x.second;
 return json::Object{{"function",F.getName().str()},{"summary",json::Object{{"blocks",int64_t(F.size())},{"instructions",total},{"darm_static_cost",cost},{"phis",phis},{"selects",selects},{"loads",loads},{"stores",stores},{"calls",calls},{"conditional_branches",conditional}}},{"opcode_histogram",std::move(hist)},{"blocks",std::move(bs)}};
}
int main(int argc,char**argv){
 if(argc==4&&std::string(argv[1])=="--facts"){LLVMContext C;SMDiagnostic E;auto M=parseIRFile(argv[2],E,C);if(!M)return 1;auto*F=M->getFunction(argv[3]);if(!F)return 2;outs()<<formatv("{0:2}\n",json::Value(facts(*F)));return 0;}
 if(argc!=4){errs()<<"usage: pair-trial INPUT.ll REQUEST.json OUTPUT-DIRECTORY\n";return 2;}
 std::string out=argv[3];auto reject=[&](StringRef why){jsonwrite(out+"/engine-result.json",json::Object{{"status","rejected_precheck"},{"reason",why},{"transformation_applied",false}});errs()<<why<<"\n";return 4;};
 auto buf=MemoryBuffer::getFile(argv[2]);if(!buf)return reject("request_missing");auto value=json::parse((*buf)->getBuffer());if(!value)return reject("invalid_request_json");auto*req=value->getAsObject();if(!req)return reject("invalid_request_object");auto get=[&](StringRef k){return req->getString(k).getValueOr("").str();};
 LLVMContext C;SMDiagnostic E;auto M=parseIRFile(argv[1],E,C);if(!M){E.print(argv[0],errs());return reject("input_parse_failed");}if(verifyModule(*M,&errs()))return reject("input_verifier_failed");auto*F=M->getFunction(get("function"));if(!F||F->isDeclaration())return reject("function_missing");
 std::map<BasicBlock*,std::string> ids;std::map<std::string,BasicBlock*> byid;int i=0;for(auto&B:*F){std::string id="B"+std::to_string(i++);ids[&B]=id;byid[id]=&B;}
 DominatorTree DT(*F);PostDominatorTree PDT(*F);DominanceFrontier DF;DF.analyze(DT);RegionInfo RI;RI.recalculate(*F,&DT,&PDT,&DF);LoopInfo LI(DT);
 std::map<std::string,Unit> units;for(auto&B:*F)units[ids[&B]]={&B,B.getSingleSuccessor(),nullptr,{&B}};
 int r=0;std::function<void(Region*)> visit=[&](Region*R){std::set<BasicBlock*> set;for(auto*B:R->blocks())set.insert(B);units["R"+std::to_string(r++)]={R->getEntry(),R->getExit(),R,set};for(auto&child:*R)visit(child.get());};visit(RI.getTopLevelRegion());
 if(!byid.count(get("split"))||!units.count(get("left"))||!units.count(get("right")))return reject("unknown_block_or_region_id");
 BasicBlock*split=byid[get("split")];auto*br=dyn_cast<BranchInst>(split->getTerminator());if(!br||!br->isConditional()||!Utils::isValidMergeLocation(*split,PDT))return reject("unsupported_split_location");
 Unit L=units[get("left")],R=units[get("right")];if(bool(L.region)!=bool(R.region))return reject("mixed_granularity_not_supported");for(auto*B:L.blocks)if(R.blocks.count(B))return reject("overlapping_pair");
 auto*join=PDT.getNode(split)->getIDom()->getBlock();auto reachable=[&](BasicBlock*start){std::set<BasicBlock*> seen;std::vector<BasicBlock*> todo{start};while(!todo.empty()){auto*B=todo.back();todo.pop_back();if(B==join||!seen.insert(B).second)continue;for(auto*S:successors(B))todo.push_back(S);}return seen;};
 auto a=reachable(br->getSuccessor(0)),b=reachable(br->getSuccessor(1));auto belongs=[](const Unit&u,const std::set<BasicBlock*>&yes,const std::set<BasicBlock*>&no){for(auto*B:u.blocks)if(!yes.count(B)||no.count(B))return false;return true;};bool swapped=false;
 if(belongs(L,b,a)&&belongs(R,a,b)){std::swap(L,R);swapped=true;}else if(!(belongs(L,a,b)&&belongs(R,b,a)))return reject("pair_not_exclusive_on_opposite_sides");
 auto affected=a;affected.insert(b.begin(),b.end());for(auto*B:affected)if(LI.getLoopFor(B))return reject("loop_in_trial_scope_not_supported");
 bool lp=PDT.dominates(L.entry,br->getSuccessor(0)),rp=PDT.dominates(R.entry,br->getSuccessor(1));if(!L.region&&!lp&&!rp)return reject("both_selected_blocks_optional_replication_not_supported");
 // Initial supported subset: avoid replication/reordering of observable effects.
 for(auto*B:affected)for(auto&I:*B)if(I.mayHaveSideEffects()||I.mayWriteToMemory())return reject("side_effect_in_trial_scope_not_supported");
 RegionAnalyzer MA(split,DT,PDT);if(L.region){if(!L.exit||!R.exit||!MA.selectExplicitRegions(L.region,R.region))return reject("region_structure_mismatch");}else MA.selectExplicitBlocks(L.entry,R.entry);
 jsonwrite(out+"/selection.json",json::Object{{"function",F->getName().str()},{"split_name",name(split)},{"requested_left",get("left")},{"requested_right",get("right")},{"engine_left_entry",name(L.entry)},{"engine_right_entry",name(R.entry)},{"engine_left_boundary",boundary(L)},{"engine_right_boundary",boundary(R)},{"orientation_swapped",swapped},{"region_pair",bool(L.region)},{"replication_required",MA.requireRegionReplication()},{"engine_calls",1},{"proof_scope","structural prechecks only; semantic tests required"}});
 jsonwrite(out+"/before-features.json",facts(*F));write(out+"/before-canonical.ll",text(*M));std::map<std::string,std::string> untouched;for(auto&other:*M)if(&other!=F)untouched[other.getName().str()]=text(other);
 RegionMelder melder(MA);melder.merge(0);write(out+"/after-raw.ll",text(*M));jsonwrite(out+"/after-raw-features.json",facts(*F));bool verifier=!verifyModule(*M,&errs());bool otherSame=true;for(auto&other:*M)if(&other!=F)otherSame&=untouched.count(other.getName().str())&&untouched[other.getName().str()]==text(other);
 jsonwrite(out+"/engine-result.json",json::Object{{"status",verifier&&otherSame?"transformed_ir_verified":"failed_postcheck"},{"transformation_applied",true},{"llvm_verifier_passed",verifier},{"other_functions_unchanged",otherSame},{"semantic_equivalence","not_proved_by_verifier"},{"engine_calls",1}});return verifier&&otherSame?0:5;
}
