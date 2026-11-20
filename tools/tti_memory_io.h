#pragma once

#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/raw_ostream.h"
#include <array>
#include <cerrno>
#include <chrono>
#include <stdexcept>
#ifdef __linux__
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <spawn.h>
#include <sys/socket.h>
#include <sys/wait.h>
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

class PersistentTTI {
  TTIFile Input;
  TTIFile Error;
  int Socket=-1;
  pid_t Child=-1;

public:
  PersistentTTI(llvm::StringRef Worker, llvm::StringRef Function, bool SummaryOnly=true) {
    int Pair[2];
    if(::socketpair(AF_UNIX,SOCK_STREAM|SOCK_CLOEXEC,0,Pair)!=0)
      throw std::runtime_error("cannot create TTI worker socket");
    posix_spawn_file_actions_t Actions;
    int RC=::posix_spawn_file_actions_init(&Actions);
    if(!RC){
      RC=::posix_spawn_file_actions_adddup2(&Actions,Pair[1],STDIN_FILENO);
      if(!RC)RC=::posix_spawn_file_actions_adddup2(&Actions,Pair[1],STDOUT_FILENO);
      if(!RC)RC=::posix_spawn_file_actions_addopen(&Actions,STDERR_FILENO,Error.path().c_str(),O_WRONLY,0);
      std::string Path=Worker.str(), Name=Function.str();
      std::string Mode=SummaryOnly?"--serve-summary":"--serve-full";
      char *Args[]={Path.data(),Mode.data(),Name.data(),nullptr};
      if(!RC)RC=::posix_spawn(&Child,Path.c_str(),&Actions,nullptr,Args,::environ);
      ::posix_spawn_file_actions_destroy(&Actions);
    }
    ::close(Pair[1]);
    if(RC){
      ::close(Pair[0]);
      throw std::runtime_error("cannot start persistent TTI worker");
    }
    Socket=Pair[0];
  }
  PersistentTTI(const PersistentTTI &)=delete;
  PersistentTTI &operator=(const PersistentTTI &)=delete;
  ~PersistentTTI() {
    ::close(Socket);
    ::kill(Child,SIGKILL);
    while(::waitpid(Child,nullptr,0)<0&&errno==EINTR){}
  }
  std::string score(llvm::StringRef IR) {
    Input.write(IR);
    // procfs descriptors are reused. Opening the file in TTIFile::write
    // truncates the previous request before the worker receives the path.
    const std::string Request=Input.path()+"\n";
    size_t Sent=0;
    while(Sent<Request.size()){
      auto N=::send(Socket,Request.data()+Sent,Request.size()-Sent,MSG_NOSIGNAL);
      if(N<0&&errno==EINTR)continue;
      if(N<=0)throw std::runtime_error("cannot send TTI request");
      Sent+=N;
    }
    std::string Response;
    const size_t maxResponseSize=32*1024*1024;
    const auto deadline=std::chrono::steady_clock::now()+std::chrono::seconds(120);
    while(Response.size()<maxResponseSize){
      pollfd FD{Socket,POLLIN,0};
      int Ready;
      do {
        auto remaining=std::chrono::duration_cast<std::chrono::milliseconds>(
            deadline-std::chrono::steady_clock::now()).count();
        if(remaining<=0)throw std::runtime_error("persistent TTI response timed out");
        Ready=::poll(&FD,1,int(remaining));
      } while(Ready<0&&errno==EINTR);
      if(Ready<=0)throw std::runtime_error("persistent TTI response unavailable");
      char Buffer[4096];
      auto N=::read(Socket,Buffer,sizeof Buffer);
      if(N<0&&errno==EINTR)continue;
      if(N<=0)throw std::runtime_error("persistent TTI worker exited");
      Response.append(Buffer,N);
      if(Response.size()>maxResponseSize)break;
      if(Response.back()=='\n')return Response;
    }
    throw std::runtime_error("persistent TTI response exceeds size limit");
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
