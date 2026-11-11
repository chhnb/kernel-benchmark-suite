#pragma once

#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/raw_ostream.h"
#include <array>
#include <cerrno>
#include <stdexcept>
#ifdef __linux__
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

namespace decision {
#ifdef __linux__
// Keep the descriptors available to the LLVM 24 child. /proc/self/fd lets
// both versions of LLVM use their ordinary path-based IR reader.
class TTIFile {
  int FD;

public:
  TTIFile() : FD(::memfd_create("decision-tti", 0)) {
    if (FD < 0)
      throw std::runtime_error("cannot allocate anonymous TTI buffer");
  }
  TTIFile(const TTIFile &) = delete;
  TTIFile &operator=(const TTIFile &) = delete;
  ~TTIFile() { ::close(FD); }

  std::string path() const { return "/proc/self/fd/" + std::to_string(FD); }

  void write(llvm::StringRef Text) const {
    std::error_code Error;
    llvm::raw_fd_ostream Out(path(), Error);
    if (Error)
      throw std::runtime_error(Error.message());
    Out << Text;
    Out.flush();
    if (Out.has_error()) {
      Out.clear_error();
      throw std::runtime_error("cannot write anonymous TTI buffer");
    }
  }

  std::string read() const {
    struct stat Status;
    if (::fstat(FD, &Status) != 0)
      throw std::runtime_error("cannot stat anonymous TTI buffer");
    std::string Text(Status.st_size, '\0');
    size_t Offset = 0;
    while (Offset < Text.size()) {
      ssize_t Count = ::pread(FD, &Text[Offset], Text.size() - Offset, Offset);
      if (Count < 0 && errno == EINTR)
        continue;
      if (Count <= 0)
        throw std::runtime_error("cannot read anonymous TTI buffer");
      Offset += Count;
    }
    return Text;
  }
};

inline std::string runMemoryTTI(llvm::StringRef Worker, llvm::StringRef IR,
                                llvm::StringRef Function, bool SummaryOnly,
                                unsigned Timeout) {
  TTIFile Input, Output, Error;
  Input.write(IR);
  auto InputPath = Input.path(), OutputPath = Output.path(), ErrorPath = Error.path();
  llvm::SmallVector<llvm::StringRef, 4> Args{Worker, InputPath, Function};
  if (SummaryOnly)
    Args.push_back("--summary-only");
  std::array<llvm::Optional<llvm::StringRef>, 3> Redirects{
      llvm::StringRef(""), llvm::StringRef(OutputPath), llvm::StringRef(ErrorPath)};
  if (llvm::sys::ExecuteAndWait(Worker, Args, llvm::None, Redirects, Timeout))
    throw std::runtime_error("TTI worker failed: " + Error.read());
  return Output.read();
}
#endif
} // namespace decision
