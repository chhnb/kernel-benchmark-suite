#include "tti_memory_io.h"
#include "llvm/Support/SHA1.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/JSON.h"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>

namespace fs = std::filesystem;
using llvm::StringRef;

namespace {
constexpr const char *Magic = "kbs-tti-v2";

std::string env(const char *name) {
  const char *value = std::getenv(name);
  return value ? value : "";
}

std::unique_ptr<llvm::MemoryBuffer> read(const fs::path &path) {
  auto data = llvm::MemoryBuffer::getFile(path.string());
  if (!data)
    throw std::runtime_error("cannot read " + path.string() + ": " + data.getError().message());
  return std::move(*data);
}

std::string keyFor(StringRef ir, StringRef function, bool summary, bool server) {
  // LLVM's textual printer adds this path-derived comment. It is not parsed.
  if (ir.startswith("; ModuleID = "))
    ir = ir.split('\n').second;
  llvm::SHA1 hash;
  hash.update(server ? "server\n" : "file\n");
  hash.update(summary ? "summary\n" : "full\n");
  hash.update(function);
  hash.update("\n");
  hash.update(ir);
  return llvm::toHex(hash.final(), true);
}

bool hex(StringRef value, size_t size) {
  return value.size() == size && llvm::all_of(value, llvm::isHexDigit);
}

using llvm::json::Array;
using llvm::json::Object;
using llvm::json::Value;

Value parse(StringRef text) {
  auto result = llvm::json::parse(text);
  if (!result)
    throw std::runtime_error(llvm::toString(result.takeError()));
  return std::move(*result);
}

int64_t number(const Value &value) {
  auto integer = value.getAsInteger();
  if (!integer || *integer < 0)
    throw std::runtime_error("invalid compact TTI integer");
  return *integer;
}

Array &array(Value &value) {
  auto *a = value.getAsArray();
  if (!a)
    throw std::runtime_error("invalid compact TTI array");
  return *a;
}

std::string serialize(const Value &value) {
  std::string text;
  llvm::raw_string_ostream stream(text);
  stream << value;
  stream.flush();
  return text;
}

Value compact(StringRef response) {
  auto value = parse(response);
  auto *entry = value.getAsObject();
  if (!entry || !entry->getBoolean("verifier_passed").getValueOr(false) ||
      entry->getString("schema").getValueOr("") != "llvm24-tti-v1" ||
      entry->getString("source_revision").getValueOr("") != "6be16f356d3e" ||
      entry->getString("cost_kind").getValueOr("") != "TCK_RecipThroughput")
    throw std::runtime_error("invalid live LLVM 24 response");
  Array fields;
  for (const char *field : {"modeled_cost", "instructions", "unknown", "zero"}) {
    auto v = entry->getInteger(field);
    if (!v || *v < 0)
      throw std::runtime_error("missing live TTI count");
    fields.push_back(*v);
  }
  fields.push_back(!entry->getString("compatibility_adjustment").getValueOr("").empty());
  auto *rows = entry->getArray("instruction_costs");
  if (!rows)
    return Value(std::move(fields));
  Array blocks;
  int64_t last = -1;
  std::map<std::string, int64_t> histogram;
  int64_t unknown = 0, zero = 0, cost = 0;
  for (const auto &row : *rows) {
    auto *obj = row.getAsObject();
    if (!obj)
      throw std::runtime_error("invalid live instruction row");
    auto block = obj->getInteger("block_index"), inst = obj->getInteger("instruction_index");
    auto key = obj->getString("key");
    auto accepted = obj->getInteger("accepted_cost");
    if (!block || *block < last || *block < 0 || !inst || !key ||
        (accepted && (*accepted < 0 || *accepted == INT64_MAX)))
      throw std::runtime_error("invalid live instruction fields");
    if (*block != last) {
      blocks.push_back(Array{*block, Array{}});
      last = *block;
    }
    auto &quotes = array(array(blocks.back())[1]);
    if (*inst != static_cast<int64_t>(quotes.size() / 2))
      throw std::runtime_error("nonconsecutive live instruction index");
    quotes.push_back(accepted ? *accepted + 1 : 0);
    quotes.push_back(accepted ? key->str() : "");
    if (accepted) {
      cost += *accepted;
      zero += *accepted == 0;
      ++histogram[key->str() + ":cost" + std::to_string(*accepted)];
    } else {
      ++unknown;
    }
  }
  auto *liveHist = entry->getObject("histogram");
  if (!liveHist || liveHist->size() != histogram.size() ||
      number(fields[0]) != cost || number(fields[1]) != static_cast<int64_t>(rows->size()) ||
      number(fields[2]) != unknown || number(fields[3]) != zero)
    throw std::runtime_error("inconsistent live TTI totals");
  for (const auto &[key, count] : histogram)
    if (liveHist->getInteger(key).getValueOr(-1) != count)
      throw std::runtime_error("inconsistent live TTI histogram");
  fields.push_back(std::move(blocks));
  return Value(std::move(fields));
}

template <typename Visit> void visitKeys(Value &value, Visit visit) {
  auto &fields = array(value);
  if (fields.size() == 5)
    return;
  if (fields.size() != 6)
    throw std::runtime_error("invalid compact TTI record");
  for (auto &block : array(fields[5])) {
    auto &pair = array(block);
    if (pair.size() != 2)
      throw std::runtime_error("invalid compact TTI block");
    auto &quotes = array(pair[1]);
    if (quotes.size() % 2)
      throw std::runtime_error("invalid compact TTI quote array");
    for (size_t i = 1; i < quotes.size(); i += 2)
      visit(quotes[i]);
  }
}

std::string expand(StringRef record, const std::vector<std::string> &keys) {
  auto value = parse(record);
  auto &fields = array(value);
  if ((fields.size() != 5 && fields.size() != 6) || !fields[4].getAsBoolean())
    throw std::runtime_error("invalid compact TTI record");
  const auto cost = number(fields[0]), count = number(fields[1]);
  const auto unknown = number(fields[2]), zero = number(fields[3]);
  Object output{{"modeled_cost",cost}, {"instructions",count}, {"unknown",unknown},
                {"zero",zero}, {"cost", unknown ? Value(nullptr) : Value(cost)},
                {"compatibility_adjustment", *fields[4].getAsBoolean() ? "recorded" : ""}};
  if (fields.size() == 6) {
    Array rows;
    std::map<std::string, int64_t> histogram;
    int64_t previous = -1;
    for (auto &block : array(fields[5])) {
      auto &pair = array(block);
      if (pair.size() != 2)
        throw std::runtime_error("invalid compact TTI block");
      auto index = number(pair[0]);
      auto &quotes = array(pair[1]);
      if (index <= previous || quotes.empty() || quotes.size() % 2)
        throw std::runtime_error("invalid compact TTI quote order");
      previous = index;
      for (size_t i = 0; i < quotes.size(); i += 2) {
        auto quote = number(quotes[i]), key = number(quotes[i+1]);
        if (size_t(key) >= keys.size() || (quote == 0) != keys[key].empty())
          throw std::runtime_error("invalid compact TTI key");
        rows.push_back(Object{{"block_index",index}, {"instruction_index",int64_t(i/2)},
            {"accepted_cost",quote ? Value(quote-1) : Value(nullptr)}, {"key",keys[key]}});
        if (quote)
          ++histogram[keys[key] + ":cost" + std::to_string(quote-1)];
      }
    }
    if (static_cast<int64_t>(rows.size()) != count)
      throw std::runtime_error("invalid compact TTI instruction count");
    Object hist;
    for (const auto &[key, total] : histogram)
      hist[key] = total;
    output["instruction_costs"] = std::move(rows);
    output["histogram"] = std::move(hist);
  }
  return serialize(Value(std::move(output))) + "\n";
}

void record(const fs::path &dir, const std::string &key, StringRef response) {
  auto destination = dir / key;
  if (!fs::exists(destination)) {
    auto temporary = dir / (key + "." + std::to_string(getpid()));
    auto bytes = response;
    std::ofstream output(temporary, std::ios::binary);
    output.write(bytes.data(), bytes.size());
    output.close();
    if (!output)
      throw std::runtime_error("cannot write TTI recording");
    std::error_code error;
    fs::create_hard_link(temporary, destination, error);
    fs::remove(temporary);
    if (!error)
      return;
    if (error != std::errc::file_exists)
      throw std::runtime_error("cannot publish TTI recording: " + error.message());
  }
  if (read(destination)->getBuffer() != response)
    throw std::runtime_error("different live responses for TTI query " + key);
}

void pack(const fs::path &dir, const std::string &file, StringRef liveSHA) {
  if (!hex(liveSHA, 64))
    throw std::runtime_error("invalid LLVM 24 worker SHA-256");
  std::map<std::string, fs::path> files;
  for (const auto &entry : fs::directory_iterator(dir)) {
    auto name = entry.path().filename().string();
    if (!hex(name, 40) || !entry.is_regular_file())
      throw std::runtime_error("unexpected recording file " + entry.path().string());
    files.emplace(name, entry.path());
  }
  std::map<std::string, int64_t> keys{{"",0}};
  for (const auto &item : files) {
    auto value = parse(read(item.second)->getBuffer());
    visitKeys(value, [&](Value &key) { keys.emplace(key.getAsString().getValueOr("").str(), 0); });
  }
  Array dictionary;
  for (auto &[key, id] : keys) {
    id = dictionary.size();
    dictionary.push_back(key);
  }
  std::ofstream output(file, std::ios::binary);
  output << Magic << '\n' << liveSHA.str() << '\n'
         << serialize(Value(std::move(dictionary))) << '\n' << files.size() << '\n';
  for (const auto &[key, path] : files) {
    auto value = parse(read(path)->getBuffer());
    visitKeys(value, [&](Value &key) { key = keys.at(key.getAsString().getValueOr("").str()); });
    auto bytes = serialize(value);
    output << key << ' ' << bytes.size() << '\n';
    output.write(bytes.data(), bytes.size());
  }
  output.close();
  if (!output || files.empty())
    throw std::runtime_error("cannot write TTI table");
  std::cerr << files.size() << " queries, " << fs::file_size(file) << " bytes\n";
}

class Table {
  std::unique_ptr<llvm::MemoryBuffer> file;
  std::map<StringRef, StringRef> entries;
  std::vector<std::string> keys;

public:
  Table(const std::string &path, const std::string &sha) : file(read(path)) {
    StringRef data = file->getBuffer();
    auto line = [&] {
      auto pair = data.split('\n');
      data = pair.second;
      return pair.first;
    };
    if (line() != Magic || !hex(sha, 64) || line() != sha)
      throw std::runtime_error("TTI table version or LLVM 24 worker SHA-256 mismatch");
    auto dictionary = parse(line());
    for (auto &entry : array(dictionary)) {
      auto key = entry.getAsString();
      if (!key || (!keys.empty() && *key <= keys.back()))
        throw std::runtime_error("invalid TTI key dictionary");
      keys.push_back(key->str());
    }
    if (keys.empty() || !keys.front().empty())
      throw std::runtime_error("missing TTI key dictionary sentinel");
    size_t count;
    if (line().getAsInteger(10, count) || !count)
      throw std::runtime_error("invalid TTI table entry count");
    StringRef previous;
    for (size_t i = 0; i < count; ++i) {
      auto [key, length] = line().split(' ');
      size_t size;
      if (!hex(key, 40) || key <= previous || length.getAsInteger(10, size) ||
          !size || size > data.size())
        throw std::runtime_error("invalid TTI table index");
      entries.emplace(key, data.take_front(size));
      previous = key;
      data = data.drop_front(size);
    }
    if (!data.empty())
      throw std::runtime_error("extra bytes in TTI table");
  }

  std::string lookup(StringRef key) const {
    auto it = entries.find(key);
    if (it == entries.end())
      throw std::runtime_error("missing TTI query " + key.str());
    return expand(it->second, keys);
  }
};
}

int main(int argc, char **argv) try {
  if (argc == 5 && StringRef(argv[1]) == "--pack") {
    pack(argv[2], argv[3], argv[4]);
    return 0;
  }
  const bool server = argc == 3 &&
      (StringRef(argv[1]) == "--serve-summary" || StringRef(argv[1]) == "--serve-full");
  const bool summary = (server && StringRef(argv[1]) == "--serve-summary") ||
      (argc == 4 && StringRef(argv[3]) == "--summary-only");
  if (argc != 3 && !summary)
    throw std::runtime_error("usage: kbs-tti IR FUNCTION [--summary-only]");
  const std::string function = argv[2];
  const auto recording = env("KBS_RECORD_DIR"), tablePath = env("KBS_TTI_TABLE");
  if (recording.empty() == tablePath.empty())
    throw std::runtime_error("select exactly one TTI mode");
  std::unique_ptr<Table> table;
  std::unique_ptr<decision::PersistentTTI> live;
  if (!tablePath.empty())
    table = std::make_unique<Table>(tablePath, env("KBS_TTI_WORKER_SHA"));
  else if (server)
    live = std::make_unique<decision::PersistentTTI>(env("KBS_LIVE_TTI"), function, summary);

  auto query = [&](const std::string &path) {
    auto ir = read(path);
    auto key = keyFor(ir->getBuffer(), function, summary, server);
    try {
      if (table)
        return table->lookup(key);
      auto response = live ? live->score(ir->getBuffer()) :
          decision::runMemoryTTI(env("KBS_LIVE_TTI"), ir->getBuffer(), function, summary, 120);
      if (StringRef(response).trim() == "null")
        throw std::runtime_error("live LLVM 24 rejected the query");
      record(recording, key, serialize(compact(response)));
      return response;
    } catch (const std::exception &error) {
      throw std::runtime_error(std::string(summary ? "summary" : "full") +
                               " " + function + " " + key + ": " + error.what());
    }
  };
  if (!server)
    std::cout << query(argv[1]);
  else
    for (std::string input; std::getline(std::cin, input);)
      std::cout << query(input) << std::flush;
  return 0;
} catch (const std::exception &error) {
  std::cerr << "tti_quote_replay: TTI case " << env("KBS_CASE") << ": " << error.what() << '\n';
  return 2;
}
