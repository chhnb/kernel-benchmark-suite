#include <hip/hip_runtime.h>
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

static void require(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
static void check(hipError_t result) { require(result == hipSuccess, hipGetErrorString(result)); }
template<class T> static std::vector<T> read(const char *path) {
  std::ifstream f(path, std::ios::binary | std::ios::ate);
  require(bool(f), "open fixture");
  auto bytes = static_cast<size_t>(f.tellg());
  require(bytes % sizeof(T) == 0, "invalid fixture extent");
  f.seekg(0);
  std::vector<T> v(bytes / sizeof(T));
  require(bool(f.read(reinterpret_cast<char*>(v.data()), bytes)), "read fixture");
  return v;
}
static uint64_t mix(uint64_t state, const uint32_t *data, size_t words) {
  const auto *bytes = reinterpret_cast<const uint8_t*>(data);
  for (size_t i = 0; i < words * sizeof(uint32_t); ++i)
    state = (state ^ bytes[i]) * UINT64_C(1099511628211);
  return state;
}
int main(int argc, char **argv) try {
  require(argc >= 6, "replay input output rounds timed|count|profile hsacos...");
  auto input = read<uint32_t>(argv[1]);
  auto expected = read<uint32_t>(argv[2]);
  const int rounds = std::stoi(argv[3]);
  const bool count = !std::strcmp(argv[4], "count");
  const bool profile = !std::strcmp(argv[4], "profile");
  const int warmup = count || profile ? 0 : 1;
  const int roles = argc - 5;
  constexpr int threads = 64;
  constexpr int capacity = 24576;
  constexpr int blocks = capacity / threads;
  constexpr std::array<int,3> batch{24576,17392,5492};
  constexpr uint64_t fnv = UINT64_C(14695981039346656037);
  require(input.size() == 3ul * (batch[0] + batch[1] + batch[2]), "input words");
  require(expected.size() == batch.size() * blocks, "reference words");
  uint64_t ih = mix(fnv, input.data(), input.size());
  require(ih == UINT64_C(0xdce970f2732b8f02), "release input fingerprint");
  check(hipSetDevice(0));
  std::vector<hipModule_t> modules(roles);
  std::vector<hipFunction_t> functions(roles);
  for(int i=0;i<roles;++i) {
    check(hipModuleLoad(&modules[i], argv[i+5]));
    check(hipModuleGetFunction(&functions[i],modules[i],"_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i"));
  }
  uint32_t *mask, *left, *right, *result;
  uint64_t *counters = nullptr;
  for (auto ptr : {&mask, &left, &right}) check(hipMalloc(ptr, capacity * sizeof(uint32_t)));
  check(hipMalloc(&result, blocks * sizeof(uint32_t)));
  if(count) check(hipMalloc(&counters, blocks * 4 * sizeof(uint64_t)));
  std::vector<uint32_t> got(blocks);
  std::vector<uint64_t> diagnostic(blocks*4);
  hipStream_t stream;
  hipEvent_t start,stop;
  check(hipStreamCreate(&stream)); check(hipEventCreate(&start)); check(hipEventCreate(&stop));
  std::puts("round,role,warmup,milliseconds,solutions,input_fingerprint,output_fingerprint");
  for(int r=0;r<rounds;++r) for(int position=0;position<roles;++position) {
    const int role=(r%roles + (r/roles%2 ? roles-1-position : position))%roles;
    for(int rep=-warmup;rep<1;++rep) {
      float ms=0;
      uint64_t hash=fnv, solutions=0;
      size_t offset=0;
      std::array<uint64_t,4> totals{};
      for(size_t b=0;b<batch.size();++b) {
        int n=15, remaining=10, conditions=batch[b];
        for(auto ptr:{mask,left,right}) {
          check(hipMemcpy(ptr,input.data()+offset,conditions*sizeof(uint32_t),hipMemcpyHostToDevice));
          offset+=conditions;
        }
        check(hipMemsetAsync(result,0xa5,blocks*sizeof(uint32_t),stream));
        if(count) check(hipMemsetAsync(counters,0,blocks*4*sizeof(uint64_t),stream));
        void *args[]={&n,&remaining,&mask,&left,&right,&result,&conditions,&counters};
        check(hipEventRecord(start,stream));
        check(hipModuleLaunchKernel(functions[role],blocks,1,1,threads,1,1,0,stream,args,nullptr));
        check(hipEventRecord(stop,stream)); check(hipEventSynchronize(stop));
        float current;
        check(hipEventElapsedTime(&current,start,stop)); ms+=current;
        check(hipMemcpy(got.data(),result,blocks*sizeof(uint32_t),hipMemcpyDeviceToHost));
        if(!std::equal(got.begin(),got.end(),expected.begin()+b*blocks)) {
          std::fprintf(stderr,"full output differs role=%d round=%d batch=%zu\n",role,r,b);
          return 4;
        }
        hash=mix(hash,got.data(),got.size());
        for(auto q:got) solutions+=(b==2 ? 1 : 2)*q;
        if(count) {
          check(hipMemcpy(diagnostic.data(),counters,diagnostic.size()*sizeof(uint64_t),hipMemcpyDeviceToHost));
          for(int i=0;i<blocks;++i)
            for(int k=0;k<4;++k) totals[k]+=diagnostic[i*4+k];
        }
      }
      require(solutions == 2279184 && hash == UINT64_C(0x3fa1162a3cadaeea), "solve count/fingerprint mismatch");
      std::printf("%d,%d,%d,%.9f,%llu,%016llx,%016llx\n",r,role,rep<0,count?0.0:ms,
        (unsigned long long)solutions,(unsigned long long)ih,(unsigned long long)hash);
      if(count) std::fprintf(stderr,"role=%d wave_none=%llu wave_leaf_only=%llu wave_descend=%llu lane_iterations=%llu\n",
        role,(unsigned long long)totals[0],(unsigned long long)totals[1],(unsigned long long)totals[2],(unsigned long long)totals[3]);
      std::fflush(stdout);
    }
  }
  return 0;
} catch(const std::exception& ex) {
  std::fprintf(stderr,"%s\n",ex.what());return 2;
}
