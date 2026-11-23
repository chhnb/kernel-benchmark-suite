#include "region_extract.h"
#include "cost_model.h"

using namespace llvm;

namespace {
using namespace dataflow::extraction;

// Canonical operand numbers for non-B2B inventory entries. Keep printed
// modifiers, constants and types but discard spelling and numbering of local
// identifiers, which are encoded separately as def-use and block references.
std::string anonymousIR(StringRef line) {
  std::string result;
  for (size_t i = 0; i < line.size();) {
    char c = line[i++];
    if (c == '"') {
      result += c;
      while (i < line.size()) {
        char next = line[i++];
        result += next;
        if (next == '"')
          break;
      }
    } else if (c == '%' || c == '@') {
      result += c;
      if (i < line.size() && line[i] == '"') {
        ++i;
        while (i < line.size() && line[i++] != '"') {}
      } else {
        while (i < line.size() && (isAlnum(line[i]) || StringRef("-$._").contains(line[i])))
          ++i;
      }
    } else if (c == '!' && i < line.size() && isDigit(line[i])) {
      result += c;
      while (i < line.size() && isDigit(line[i]))
        ++i;
    } else if (c == '#' && i < line.size() && isDigit(line[i])) {
      while (i < line.size() && isDigit(line[i]))
        ++i;
    } else {
      result += c;
    }
  }
  return result;
}

// Type::print without a module may use an address for an unnamed identified
// struct. Number structs by first use and encode their bodies, including
// references back to recursive structs.
struct TypeEncoding {
  explicit TypeEncoding(raw_ostream &stream) : out(stream) {}
  raw_ostream &out;
  DenseMap<const StructType *, unsigned> structs;

  void write(Type *type) {
    if (auto *ptr = dyn_cast<PointerType>(type)) {
      out << "ptr" << ptr->getAddressSpace() << '(';
      write(ptr->getElementType());
      out << ')';
    } else if (auto *array = dyn_cast<ArrayType>(type)) {
      out << "array" << array->getNumElements() << '(';
      write(array->getElementType());
      out << ')';
    } else if (auto *vector = dyn_cast<VectorType>(type)) {
      auto count = vector->getElementCount();
      out << (count.isScalable() ? "scalable" : "vector") << count.getKnownMinValue() << '(';
      write(vector->getElementType());
      out << ')';
    } else if (auto *structure = dyn_cast<StructType>(type)) {
      auto entry = structs.try_emplace(structure, structs.size());
      out << "struct" << entry.first->second;
      if (!entry.second)
        return;
      if (structure->isOpaque()) {
        out << "(opaque)";
        return;
      }
      out << (structure->isPacked() ? "<(" : "(");
      for (auto *element : structure->elements()) {
        write(element);
        out << ',';
      }
      out << (structure->isPacked() ? ")>" : ")");
    } else if (auto *function = dyn_cast<FunctionType>(type)) {
      out << "fn(";
      write(function->getReturnType());
      for (auto *parameter : function->params()) {
        out << ',';
        write(parameter);
      }
      out << (function->isVarArg() ? ",...)" : ")");
    } else {
      type->print(out);
    }
  }
};

std::string structure(const Region &region, ModuleSlotTracker &slots) {
  std::string storage;
  raw_string_ostream out(storage);
  const auto &function = *region.split.getFunction();
  const auto &module = *function.getParent();
  out << region.kind << '\n' << module.getTargetTriple() << '\n'
      << module.getDataLayoutStr() << '\n' << region.extraPreds << '\n';
  out << function.getAttributes().getAsString(AttributeList::FunctionIndex);
  out << '\n';

  TypeEncoding types(out);
  DenseMap<const Value *, unsigned> ids;
  auto writeOperand = [&](const Value *value) {
    types.write(value->getType());
    out << ':';
    if (auto *constant = dyn_cast<Constant>(value)) {
      if (!isa<GlobalVariable>(constant)) {
        constant->printAsOperand(out, false, slots);
        out << ' ';
        return;
      }
    }
    auto item = ids.try_emplace(value, ids.size());
    out << 'v' << item.first->second << ' ';
  };
  auto writeInstruction = [&](const Instruction &instruction) {
    std::string text;
    raw_string_ostream line(text);
    instruction.print(line, slots);
    out << anonymousIR(line.str()) << " | ";
    if (!instruction.getType()->isVoidTy())
      writeOperand(&instruction);
    for (auto &op : instruction.operands())
      writeOperand(op.get());
    if (auto *phi = dyn_cast<PHINode>(&instruction))
      for (auto *block : phi->blocks())
        writeOperand(block);
    if (auto *call = dyn_cast<CallBase>(&instruction)) {
      auto attrs = call->getAttributes();
      out << attrs.getAsString(AttributeList::FunctionIndex) << ' ';
      for (unsigned index = 0; index <= call->arg_size(); ++index)
        out << index << '=' << attrs.getAsString(index) << ' ';
    }
    out << '\n';
  };

  writeOperand(region.split.getParent());
  if (region.join)
    writeOperand(region.join);
  writeInstruction(region.split);
  for (const auto &side : {ArrayRef<BasicBlock *>(region.left), ArrayRef<BasicBlock *>(region.right)}) {
    out << "side\n";
    for (const auto *block : side) {
      writeOperand(block);
      out << '\n';
      for (const auto &instruction : *block)
        if (!isa<DbgInfoIntrinsic>(instruction))
          writeInstruction(instruction);
    }
  }
  if (region.join) {
    SmallPtrSet<const BasicBlock *, 16> local;
    local.insert(region.split.getParent());
    local.insert(region.left.begin(), region.left.end());
    local.insert(region.right.begin(), region.right.end());
    for (const auto &phi : region.join->phis()) {
      types.write(phi.getType());
      out << ' ';
      for (unsigned i = 0; i < phi.getNumIncomingValues(); ++i)
        if (local.count(phi.getIncomingBlock(i))) {
          writeOperand(phi.getIncomingBlock(i));
          writeOperand(phi.getIncomingValue(i));
        }
      out << '\n';
    }
  }
  return storage;
}

struct Stats {
  unsigned left = 0, right = 0, loads = 0, stores = 0, common = 0;
  bool convergent = false, unportable = false;
  json::Value folds = nullptr;
  std::string foldReason = "outside B2B";
  unsigned numOutputs = 0;
};

Stats measure(const Region &region, ArrayRef<Output> result, const json::Object &costs,
              const dataflow::SizeLatency &real) {
  Stats stats;
  std::map<unsigned, unsigned> leftOpcodes;
  SmallPtrSet<const Instruction *, 32> visited;
  SmallVector<const Instruction *, 32> operations;
  for (bool left : {true, false}) {
    for (auto *block : left ? region.left : region.right) {
      for (auto &inst : *block) {
        if (!semantic(inst))
          continue;
        ++(left ? stats.left : stats.right);
        auto &count = leftOpcodes[inst.getOpcode()];
        if (left)
          ++count;
        else if (count) {
          --count;
          ++stats.common;
        }
        if (!visited.insert(&inst).second)
          continue;
        stats.loads += isa<LoadInst>(inst);
        stats.stores += isa<StoreInst>(inst);
        if (auto *call = dyn_cast<CallBase>(&inst))
          stats.convergent |= call->isConvergent();
        const bool unsafe = !dataflow::speculationFailure(inst, costs).empty();
        stats.unportable |= unsafe;
        operations.push_back(&inst);
      }
    }
  }
  if (region.join)
    for (const auto &phi : region.join->phis()) {
      (void)phi;
      ++stats.numOutputs;
    }
  if (!region.isB2B())
    return stats;

  stats.numOutputs = result.size();
  SmallVector<const PHINode *, 8> phis;
  for (const auto &output : result)
    phis.push_back(output.phi);
  stats.foldReason = dataflow::foldFailure(operations, phis, *region.join,
                                          *region.split.getCondition(), costs, &real);
  stats.folds = stats.foldReason.empty();
  if (stats.foldReason.empty())
    stats.foldReason = "within budget or single-operation exception";
  return stats;
}

json::Object graph(const Region &region) {
  DenseMap<const BasicBlock *, unsigned> ids;
  auto id = [&](const BasicBlock *block) {
    return ids.try_emplace(block, ids.size()).first->second;
  };
  auto *split = region.split.getParent();
  id(split);
  unsigned join = region.join ? id(region.join) : 0;
  json::Array left, right, edges;
  for (auto *block : region.left)
    left.push_back(id(block));
  for (auto *block : region.right)
    right.push_back(id(block));
  SmallPtrSet<const BasicBlock *, 16> seen;
  auto addEdges = [&](const BasicBlock *block) {
    if (!seen.insert(block).second)
      return;
    for (auto *successor : successors(block))
      edges.push_back(json::Array{id(block), id(successor)});
  };
  addEdges(split);
  for (auto *block : region.left)
    addEdges(block);
  for (auto *block : region.right)
    addEdges(block);
  return json::Object{{"split", 0}, {"join", region.join ? json::Value(join) : json::Value(nullptr)},
          {"left", std::move(left)}, {"right", std::move(right)}, {"edges", std::move(edges)}};
}

} // namespace

int main(int argc, char **argv) {
  if (argc != 4) {
    errs() << "usage: extract_regions INPUT.ll COST_TABLE.json OUTPUT_DIRECTORY\n";
    return 2;
  }
  LLVMContext context;
  SMDiagnostic diag;
  auto module = parseIRFile(argv[1], diag, context);
  if (!module) {
    diag.print(argv[0], errs());
    return 1;
  }
  if (verifyModule(*module, &errs()))
    return 1;

  auto costTable = dataflow::readCosts(argv[2]);
  if (!costTable) {
    errs() << toString(costTable.takeError()) << '\n';
    return 1;
  }
  const auto &costs = *costTable->getAsObject();
  if (auto error = sys::fs::create_directories(argv[3])) {
    errs() << error.message() << '\n';
    return 1;
  }

  dataflow::SizeLatency real(*module);
  ModuleSlotTracker slots(module.get());
  for (auto &function : *module) {
    if (function.isDeclaration())
      continue;
    slots.incorporateFunction(function);
    PostDominatorTree postdom(function);
    for (auto &block : function) {
      auto *branch = dyn_cast<BranchInst>(block.getTerminator());
      if (!branch || !branch->isConditional())
        continue;
      auto region = classify(*branch, postdom);
      auto result = outputs(region);
      auto stats = measure(region, result, costs, real);
      std::string text, error, id;
      if (region.isB2B()) {
        if (auto out = isolate(region, result, error)) {
          raw_string_ostream stream(text);
          out->print(stream, nullptr);
        }
      }
      id = digest(text.empty() ? structure(region, slots) : region.kind.str() + "\n" + text);
      if (!text.empty()) {
        SmallString<256> filename(argv[3]);
        sys::path::append(filename, id + ".ll");
        if (!sys::fs::exists(filename)) {
          std::error_code ec;
          raw_fd_ostream file(filename, ec);
          if (ec) {
            errs() << ec.message() << '\n';
            return 1;
          }
          file << text;
        }
      }
      json::Object occurrence{
          {"function", function.hasName() ? function.getName().str() : operand(function, slots)},
          {"block", operand(block, slots)},
          {"join", region.join ? json::Value(operand(*region.join, slots)) : json::Value(nullptr)},
          {"join_has_other_preds", region.extraPreds},
          {"condition_source", fusion::anchor_condition::classifySource(branch)}};
      json::Object entry{
          {"id", id}, {"kind", region.kind},
          {"left_ops", stats.left}, {"right_ops", stats.right},
          {"structure", graph(region)},
          {"num_outputs", stats.numOutputs}, {"loads", stats.loads},
          {"stores", stats.stores}, {"convergent", stats.convergent},
          {"unsafe_to_speculate", stats.unportable}, {"common_opcodes", stats.common},
          {"size_bucket", stats.left + stats.right <= 10 ? "small" :
                          stats.left + stats.right <= 50 ? "medium" : "large"},
          {"original_folds", std::move(stats.folds)}, {"fold_reason", stats.foldReason},
          {"occurrence", std::move(occurrence)}};
      if (region.isB2B()) {
        json::Array quotes;
        for (const auto &side : {region.left, region.right}) {
          json::Array quoteSide;
          for (const auto *arm : side)
            for (const auto &inst : *arm)
              if (semantic(inst))
                quoteSide.push_back(real.quote(inst));
          quotes.push_back(std::move(quoteSide));
        }
        entry["size_latency_quotes"] = std::move(quotes);
      }
      if (!text.empty())
        entry["ir"] = id + ".ll";
      if (!error.empty())
        entry["extraction_error"] = error;
      outs() << json::Value(std::move(entry)) << '\n';
    }
  }
}
