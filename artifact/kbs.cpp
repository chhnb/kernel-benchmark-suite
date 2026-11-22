#include "llvm/Support/FileSystem.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/raw_ostream.h"
#include <zlib.h>

#include <chrono>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <stdexcept>

namespace fs = std::filesystem;
using llvm::StringRef;
using llvm::json::Object;
using Clock = std::chrono::steady_clock;

namespace {
constexpr int Unavailable = 3;
constexpr int TimedOut = 124;
constexpr const char *Variants[] = {"base", "bf", "darm", "anchor"};

struct CommandFailure : std::runtime_error {
  int code;
  CommandFailure(int code, const std::string &message)
      : std::runtime_error(message), code(code) {}
};

fs::path setting(const char *key, const fs::path &fallback) {
  const char *value = std::getenv(key);
  return fs::absolute(value ? fs::path(value) : fallback);
}

std::string read(const fs::path &path) {
  auto buffer = llvm::MemoryBuffer::getFile(path.string());
  if (!buffer)
    throw std::runtime_error("cannot read " + path.string() + ": " + buffer.getError().message());
  return (*buffer)->getBuffer().str();
}

llvm::json::Value json(const fs::path &path) {
  auto value = llvm::json::parse(read(path));
  if (!value)
    throw std::runtime_error(llvm::toString(value.takeError()));
  return std::move(*value);
}

std::string req(const Object &row, StringRef key) {
  auto value = row.getString(key);
  if (!value || value->empty())
    throw std::runtime_error("manifest field missing: " + key.str());
  return value->str();
}

void run(const std::vector<std::string> &command, const fs::path &stdoutPath,
         const fs::path &stderrPath, unsigned timeout = 0, bool original = false) {
  llvm::SmallVector<StringRef, 16> args(command.begin(), command.end());
  auto out = stdoutPath.string(), err = stderrPath.string();
  std::array<llvm::Optional<StringRef>, 3> redirects{
      StringRef(""), StringRef(out), StringRef(err)};
  std::string message;
  auto start = Clock::now();
  int code = llvm::sys::ExecuteAndWait(args.front(), args, llvm::None, redirects,
                                       timeout, 0, &message);
  if (code == 0)
    return;
  if (original && code == -2 &&
      Clock::now() - start >= std::chrono::seconds(timeout))
    throw CommandFailure(TimedOut, "原版 DARM 超时（360 秒）");
  std::string diagnostic;
  if (fs::exists(stderrPath)) {
    auto log = read(stderrPath);
    diagnostic = StringRef(log).take_back(8192).str();
  }
  throw CommandFailure(1, command.front() + " failed (" + std::to_string(code) +
                        ") " + message + "\n" + diagnostic +
                        "\nLog: " + stderrPath.string());
}

std::string sha(const fs::path &file, const fs::path &logs) {
  auto executable = llvm::sys::findProgramByName("sha256sum");
  if (!executable)
    throw std::runtime_error("sha256sum is required");
  auto out = logs / "digest.txt";
  run({*executable, file.string()}, out, logs / "digest.log");
  return StringRef(read(out)).split(' ').first.str();
}

void unpack(const fs::path &input, const fs::path &output) {
  gzFile file = gzopen(input.c_str(), "rb");
  if (!file)
    throw std::runtime_error("cannot open frozen input " + input.string());
  std::ofstream out(output, std::ios::binary);
  std::array<char, 65536> chunk;
  int count;
  while ((count = gzread(file, chunk.data(), chunk.size())) > 0)
    out.write(chunk.data(), count);
  const int closed = gzclose(file);
  out.close();
  if (count < 0 || closed != Z_OK || !out)
    throw std::runtime_error("cannot unpack " + input.string());
}

void replaceOnce(const fs::path &from, const fs::path &to,
                 StringRef oldValue, StringRef newValue) {
  auto input = read(from);
  const auto at = input.find(oldValue.str());
  if (at != std::string::npos) {
    for (size_t offset = at; offset != std::string::npos;
         offset = input.find(oldValue.str(), offset + newValue.size()))
      input.replace(offset, oldValue.size(), newValue.str());
  }
  else if (input.find(newValue.str()) == std::string::npos)
    throw std::runtime_error("frozen backend metadata is missing");
  std::ofstream output(to);
  output << input;
  if (!output)
    throw std::runtime_error("cannot write backend IR");
}

struct Artifact {
  fs::path data, bin, llvm, rocm, lud;
  llvm::json::Value manifest;
  std::map<std::string, const Object *> cases;
  std::string worker;

  explicit Artifact(const fs::path &binary)
      : data(setting("KBS_DATA", KBS_DATA_DIR)), bin(binary.parent_path()),
        llvm(setting("KBS_LLVM12_BIN", KBS_LLVM_BIN)),
        rocm(setting("KBS_ROCM", "/opt/rocm-6.3.3")),
        lud(setting("KBS_LUD_ROCM42_BIN", "/opt/rocm-4.2.0/llvm/bin")),
        manifest(json(data / "manifest.json")) {
    auto *root = manifest.getAsObject();
    if (!root || root->getInteger("schema").getValueOr(0) != 1 || !root->getArray("cases"))
      throw std::runtime_error("invalid artifact manifest");
    worker = req(*root, "worker_sha256");
    for (const auto &value : *root->getArray("cases")) {
      auto *row = value.getAsObject();
      if (!row || !cases.emplace(req(*row, "name"), row).second)
        throw std::runtime_error("invalid or duplicate case");
    }
  }

  void build(const std::string &name, const std::string &variant, const fs::path &dir,
             bool pristine, bool original) const {
    const auto &row = *cases.at(name);
    if (variant == "bf" && row.getString("bf_unavailable"))
      throw CommandFailure(Unavailable, req(row, "bf_unavailable"));
    if (!fs::create_directory(dir))
      throw std::runtime_error("output directory already exists: " + dir.string());
    const auto begin = Clock::now();
    auto phase = [&](const std::vector<std::string> &command, const std::string &stage,
                     unsigned timeout = 0, bool isOriginal = false) {
      run(command, dir / (stage + ".stdout"), dir / (stage + ".log"), timeout, isOriginal);
    };
    auto input = dir / "input.ll";
    const auto inputSHA = req(row, "input_sha256");
    unpack(data / "inputs" / (inputSHA + ".ll.gz"), input);
    if (sha(input, dir) != inputSHA)
      throw std::runtime_error("frozen source SHA-256 mismatch");
    fs::path ir = input;
    if (variant == "anchor") {
      auto runtime = bin / "runtime";
      auto table = dir / "quotes.tti";
      auto archive = data / "tables" / (name + ".tti.xz");
      if (!fs::exists(archive)) {
        auto hint = row.getString("table_download_url");
        auto digest = row.getString("table_archive_sha256");
        throw std::runtime_error("missing TTI archive for " + name +
          (hint ? "; download " + hint->str() + " (SHA-256 " +
                  digest.getValueOr("").str() + ")" : "; restore " + archive.string()));
      }
      auto xz = llvm::sys::findProgramByName("xz");
      if (!xz)
        throw std::runtime_error("xz is required to unpack the TTI table");
      run({*xz, "-dc", archive.string()}, table, dir / "unpack-tti.log");
      if (auto expected = row.getString("table_sha256"))
        if (sha(table, dir) != *expected)
          throw std::runtime_error("TTI table SHA-256 mismatch for " + name);
      // Clear inherited development settings. The artifact only uses recorded TTI.
      unsetenv("KBS_RECORD_DIR");
      unsetenv("KBS_LIVE_TTI");
      setenv("KBS_TTI_TABLE", table.c_str(), 1);
      setenv("KBS_TTI_WORKER_SHA", worker.c_str(), 1);
      setenv("KBS_CASE", name.c_str(), 1);
      auto active = dir / "active";
      // The release receipts use the relative output name active.
      const auto previousDirectory = fs::current_path();
      fs::current_path(dir);
      try {
        phase({(runtime / "build/decision-fuse/decision-greedy").string(),
               input.string(), req(row, "function"), runtime.string(), "active"}, "anchor");
      } catch (...) {
        fs::current_path(previousDirectory);
        throw;
      }
      fs::current_path(previousDirectory);
      ir = active / "final.ll";
      auto summary = json(active / "summary.json");
      auto *report = summary.getAsObject();
      if (!report || report->getString("status").getValueOr("") != "completed" ||
          report->getInteger("commits") != row.getInteger("anchor_commits") ||
          report->getInteger("final_cost") != row.getInteger("anchor_tti") ||
          sha(ir, dir) != req(row, "anchor_ir_sha256"))
        throw std::runtime_error("Anchor search differs from the frozen release");
    } else if (variant == "bf" || variant == "darm") {
      ir = dir / "fused.ll";
      std::vector<std::string> command{
          (llvm / "opt").string(), "-load",
          (bin / ((pristine || original) ? "libkbs-darm-pristine.so" : "libkbs-darm.so")).string(),
          "-enable-new-pm=0", "-S", "-cfmelder", variant == "bf" ?
              "-run-branch-fusion-only" : "-cf-merging-similarity-threshold=0.2"};
      if (variant == "darm" && !original)
        if (const auto *options = row.getArray("darm_options"))
          for (const auto &option : *options) {
            auto value = option.getAsString();
            if (!value)
              throw std::runtime_error("malformed DARM exception");
            command.push_back(value->str());
          }
      command.insert(command.end(), {input.string(), "-o", ir.string()});
      phase(command, "cfmelder", 360, original);
    }

    bool ludBackend = req(row, "backend") == "lud8-rocm42";
    auto backend = ludBackend ? lud : llvm;
    if (ludBackend || row.getBoolean("correct_launch_bound").getValueOr(false)) {
      auto adjusted = dir / "launch.ll";
      if (ludBackend)
        replaceOnce(ir, adjusted, "-A5-ni:7", "-A5-G1-ni:7");
      else
        replaceOnce(ir, adjusted, "\"amdgpu-flat-work-group-size\"=\"1,256\"",
                    "\"amdgpu-flat-work-group-size\"=\"1,1024\"");
      ir = adjusted;
    }
    auto optimized = dir / "o3.ll", object = dir / "kernel.o", binary = dir / "kernel.hsaco";
    phase({(backend / "opt").string(), "-O3", "-verify-each", "-S", ir.string(),
           "-o", optimized.string()}, "o3");
    if (ludBackend) {
      phase({(backend / "llc").string(), "-O2", "-mtriple", "amdgcn-amd-amdhsa",
             "-mcpu=gfx906", "--amdhsa-code-object-version=4", "-filetype=obj",
             optimized.string(), "-o", object.string()}, "llc");
      phase({(backend / "lld").string(), "-flavor", "gnu", "--no-undefined", "-shared",
             "-plugin-opt=-amdgpu-internalize-symbols", "-plugin-opt=mcpu=gfx906",
             "-plugin-opt=O2", "-o", binary.string(), object.string()}, "link");
    } else {
      auto features = variant == "anchor" ? req(row, "anchor_features") : "+sramecc,-xnack";
      phase({(backend / "llc").string(), "-O3", "-mtriple=amdgcn-amd-amdhsa", "-mcpu=gfx906",
             "-mattr=" + features, "-filetype=obj", "-amdhsa-code-object-version=4",
             optimized.string(), "-o", object.string()}, "llc");
      phase({(rocm / "llvm/bin/ld.lld").string(), "-shared", object.string(),
             "-o", binary.string()}, "link");
    }
    auto seconds = std::chrono::duration<double>(Clock::now() - begin).count();
    auto actual = sha(binary, dir);
    std::ofstream receipt(dir / "build.json");
    std::string serialized;
    llvm::raw_string_ostream receiptStream(serialized);
    receiptStream << llvm::json::Value(Object{{"case",name}, {"variant",variant},
                                             {"seconds",seconds}, {"sha256",actual}});
    receiptStream.flush();
    receipt << serialized << '\n';
    if (!receipt)
      throw std::runtime_error("cannot write build receipt");
    std::cout << name << ' ' << variant << ' ' << seconds << " s " << actual << ' '
              << binary.string() << '\n';
    if (!pristine && !original) {
      auto *frozen = row.getObject("frozen");
      if (!frozen || req(*frozen, variant) != actual)
        throw std::runtime_error("device object differs from its frozen SHA-256");
    }
  }
};

void help() {
  std::cout << "kbs list\n"
            << "kbs build --variant base|bf|darm|anchor --case NAME [--out DIR]"
               " [--darm-original] [--darm-pristine]\n"
            << "kbs verify [--out DIR]\n";
}
}

int main(int argc, char **argv) try {
  if (argc == 1 || StringRef(argv[1]) == "--help") {
    help();
    return argc == 1 ? 1 : 0;
  }
  Artifact artifact(llvm::sys::fs::getMainExecutable(argv[0],
      reinterpret_cast<void *>(&help)));
  const StringRef command(argv[1]);
  if (command == "list" && argc == 2) {
    for (const auto &[name, row] : artifact.cases) {
      std::cout << name << " base bf darm anchor";
      if (auto exception = row->getString("bf_unavailable"))
        std::cout << " · bf 不可用〔1〕 " << exception->str();
      std::cout << '\n';
    }
    return 0;
  }
  std::string name, variant;
  fs::path output;
  bool original = false, pristine = false;
  for (int i = 2; i < argc; ++i) {
    StringRef option(argv[i]);
    if (option == "--darm-original") original = true;
    else if (option == "--darm-pristine") pristine = true;
    else if ((option == "--out" || option == "--case" || option == "--variant") && i + 1 < argc) {
      std::string value = argv[++i];
      if (option == "--out") output = value;
      else if (option == "--case") name = value;
      else variant = value;
    } else throw std::runtime_error("invalid option: " + option.str());
  }
  if (command == "build") {
    if (!artifact.cases.count(name) || !llvm::is_contained(Variants, variant))
      throw std::runtime_error("select a listed case and variant");
    if ((original && variant != "darm") || (pristine && variant != "darm" && variant != "bf"))
      throw std::runtime_error("DARM control flag is invalid for this variant");
    if (output.empty()) output = "kbs-" + name + "-" + variant;
    artifact.build(name, variant, fs::absolute(output), pristine, original);
    return 0;
  }
  if (command != "verify" || original || pristine || !name.empty() || !variant.empty())
    throw std::runtime_error("invalid command");
  if (output.empty()) output = "kbs-verify";
  output = fs::absolute(output);
  if (!fs::create_directory(output))
    throw std::runtime_error("verification directory already exists");
  unsigned passed = 0, failed = 0, unavailable = 0;
  for (const auto &[caseName, row] : artifact.cases)
    for (const char *configuration : Variants) {
      try {
        artifact.build(caseName, configuration, output / (caseName + "-" + configuration), false, false);
        ++passed;
      } catch (const std::exception &error) {
        auto *status = dynamic_cast<const CommandFailure *>(&error);
        if (status && status->code == Unavailable) {
          ++unavailable;
          std::cerr << caseName << " " << configuration << " 不可用〔1〕 " << error.what() << '\n';
        } else {
          ++failed;
          std::cerr << caseName << " " << configuration << " FAIL: " << error.what() << '\n';
        }
      }
    }
  std::cout << "verify " << passed << " passed, " << unavailable
            << " unavailable, " << failed << " failed\n";
  return failed != 0;
} catch (const std::exception &error) {
  std::cerr << error.what() << '\n';
  auto *status = dynamic_cast<const CommandFailure *>(&error);
  return status ? status->code : 1;
}
