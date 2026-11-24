#include <hip/hip_runtime.h>
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <limits>
#include <numeric>
#include <stdexcept>
#include <string>
#include <vector>

static void check(hipError_t e) {
  if (e != hipSuccess) throw std::runtime_error(hipGetErrorString(e));
}
template<class T> struct Buffer {
  T *ptr = nullptr;
  size_t count;
  explicit Buffer(size_t n) : count(n) { check(hipMalloc(&ptr,n*sizeof(T))); }
  ~Buffer() { hipFree(ptr); }
  Buffer(const Buffer&) = delete;
  void upload(const T *source) { check(hipMemcpy(ptr,source,count*sizeof(T),hipMemcpyHostToDevice)); }
  void read(T *destination) { check(hipMemcpy(destination,ptr,count*sizeof(T),hipMemcpyDeviceToHost)); }
  void reset(const Buffer &src) { check(hipMemcpy(ptr,src.ptr,count*sizeof(T),hipMemcpyDeviceToDevice)); }
};
struct Events {
  hipEvent_t start,stop;
  Events() { check(hipEventCreate(&start)); check(hipEventCreate(&stop)); }
  ~Events() { hipEventDestroy(start); hipEventDestroy(stop); }
  float time(const std::function<void()> &launch) {
    check(hipEventRecord(start));
    launch();
    check(hipEventRecord(stop)); check(hipEventSynchronize(stop));
    float ms;
    check(hipEventElapsedTime(&ms,start,stop));
    if (!std::isfinite(ms) || ms <= 0) throw std::runtime_error("invalid event interval");
    return ms;
  }
};
struct Kernel {
  hipFunction_t fn;
  void launch(dim3 grid, dim3 block, void **args, unsigned shared=0) const {
    check(hipModuleLaunchKernel(fn,grid.x,grid.y,grid.z,block.x,block.y,block.z,shared,nullptr,args,nullptr));
  }
};
struct Variant {
  hipModule_t module;
  std::vector<Kernel> kernels;
  std::string name;
};
static Kernel kernel(hipModule_t mod,const char *symbol) {
  hipFunction_t fn;
  check(hipModuleGetFunction(&fn,mod,symbol));
  return {fn};
}
static std::vector<const char *> symbols(const std::string &p) {
  if(p=="BIT")return {"_ZL11bitonicSortPi"};
  if(p=="DCT")return {"_Z27CUDAkernelQuantizationShortPsi"};
  if(p=="LUD")return {"_Z13lud_perimeterPfii"};
  if(p=="MS")return {"_Z13gpu_mergesortPlS_lllP4dim3S1_"};
  if(p=="PCM")return {"_Z3pcmPi"};
  if(p=="NQU")return {"_Z24solve_nqueen_cuda_kerneliiPjS_S_S_i"};
  if(p=="SRAD")return {"_Z11srad_cuda_1PfS_S_S_S_S_iif","_Z11srad_cuda_2PfS_S_S_S_S_iiff"};
  throw std::runtime_error("unknown program");
}
template<class T> void verify(const std::vector<T> &expected,const std::vector<T> &actual,
                              double atol=0,double rtol=0,bool matchNaN=false) {
  for(size_t i=0;i<expected.size();++i) {
    if(expected[i]==actual[i])continue;
    double a=actual[i],e=expected[i];
    if(matchNaN && std::isnan(e) && std::isnan(a))continue;
    if(std::isfinite(a)&&std::isfinite(e)&&std::abs(a-e)<=atol+rtol*std::abs(e))continue;
    char msg[175];
    std::snprintf(msg,sizeof(msg),"CPU mismatch index %zu expected %.9g got %.9g",i,e,a);
    throw std::runtime_error(msg);
  }
}
static void run(const std::vector<Variant> &roles,int windows,
const std::function<float(const Variant&,bool)> &sample) {
  std::vector<int> valid;
  for(unsigned i=0;i<roles.size();++i) {
    try {
      sample(roles[i],true);
      std::printf("validation,%s,pass\n",roles[i].name.c_str());
      valid.push_back(i);
    } catch(const std::exception &e) {
      std::printf("validation,%s,fail,%s\n",roles[i].name.c_str(),e.what());
    }
    std::fflush(stdout);
  }
  if(valid.empty())return;
  for(int r=0;r<windows;++r) {
    for(size_t p=0;p<valid.size();++p) {
      size_t position = r / valid.size() % 2 ? valid.size()-1-p : p;
      const auto &role=roles[valid[(r+position)%valid.size()]];
      for(int repeat=0;repeat<18;++repeat) {
        float ms=sample(role,false);
        std::printf("event,%d,%s,%d,%.9g\n",r,role.name.c_str(),repeat,ms);
      }
      std::fflush(stdout);
    }
  }
}
static void bit(const std::vector<Variant> &roles,int b,int windows) {
  const int n=1<<26;
  std::vector<int> host(n);
  for(int i=0;i<n;++i)host[i]=b-i;
  Buffer<int> initial(n),data(n);
  initial.upload(host.data());
  Events events;
  run(roles,windows,[&](const Variant &v,bool validate){
    data.reset(initial);
    void *args[]={&data.ptr};
    auto ms=events.time([&]{v.kernels[0].launch(n/b,b,args,sizeof(int)*b);});
    if(validate) {
      data.read(host.data());
      for(int i=0;i<n;++i)
        if(host[i] != b-(i-i%b+b-1-i%b))
          throw std::runtime_error("CPU bitonic sort mismatch at "+std::to_string(i));
    }
    return ms;
  });
}
static void dct(const std::vector<Variant> &roles,int b,int windows) {
  int width=4096; const size_t n=size_t(width)*width;
  std::vector<short> initial(n),reference(n),actual(n);
  constexpr short q[]={32,33,51,81,66,39,34,17,33,36,48,47,28,23,12,12,
      51,48,47,28,23,12,12,12,81,47,28,23,12,12,12,12,
      66,28,23,12,12,12,12,12,39,23,12,12,12,12,12,12,
      34,12,12,12,12,12,12,12,17,12,12,12,12,12,12,12};
  std::srand(0);
  for(int y=0;y<width;++y)for(int x=0;x<width;++x) {
    size_t i=size_t(y)*width+x;
    int a=std::rand()%255-128,quant=q[((y%b)*b+(x%b))%64];
    initial[i]=a;
    reference[i]=(a<0?-1:1)*((std::abs(a)+quant/2)/quant)*quant;
  }
  Buffer<short> source(n),data(n);
  source.upload(initial.data());
  Events events;
  run(roles,windows,[&](const Variant &v,bool validate){
    data.reset(source);
    void *args[]={&data.ptr,&width};
    auto ms=events.time([&]{v.kernels[0].launch(dim3(width/b,width/b),dim3(b,b),args);});
    if(validate){data.read(actual.data());verify(reference,actual);}
    return ms;
  });
}
static void sort(const std::vector<Variant> &roles,int b,int windows,bool pcm) {
  constexpr int segments=1<<15, segment=1<<13;
  Events events;
  std::srand(0);
  if(pcm) {
    size_t n=size_t(segments)*segment;
    std::vector<int> host(n),reference(n);
    for(int k=0;k<segments;++k) {
      int span=segment/b;
      for(int j=0;j<b;++j) {
        int value=std::rand()%n;
        for(int i=0;i<span;++i) host[size_t(k)*segment+j*span+i]=value+i;
      }
    }
    Buffer<int> source(n),data(n);
    source.upload(host.data());
    reference=host;
    #pragma omp parallel for
    for(int k=0;k<segments;++k)
      std::sort(reference.begin()+size_t(k)*segment,reference.begin()+size_t(k+1)*segment);
    run(roles,windows,[&](const Variant &v,bool validate){
      data.reset(source);
      void *args[]={&data.ptr};
      auto ms=events.time([&]{v.kernels[0].launch(segments,b,args);});
      if(validate){data.read(host.data());verify(reference,host);}
      return ms;
    });
  } else {
    long n=1<<20;
    int blocks=1024;
    std::vector<long> host(n);
    for(auto &v:host)v=std::rand()%1024;
    Buffer<long> source(n),data(n),swap(n);
    source.upload(host.data());
    auto reference=host;
    std::sort(reference.begin(),reference.end());
    dim3 block(b),grid(blocks);
    Buffer<dim3> gpuBlock(1),gpuGrid(1);
    gpuBlock.upload(&block);gpuGrid.upload(&grid);
    run(roles,windows,[&](const Variant &v,bool validate){
      data.reset(source);
      long *left=data.ptr,*right=swap.ptr;
      auto ms=events.time([&]{
        for(long width=2;width<(n<<1);width<<=1) {
          long slices=n/(long(blocks)*b*width)+1;
          void *args[]={&left,&right,&n,&width,&slices,&gpuBlock.ptr,&gpuGrid.ptr};
          v.kernels[0].launch(grid,block,args);
          std::swap(left,right);
        }
      });
      if(validate){check(hipMemcpy(host.data(),left,n*sizeof(long),hipMemcpyDeviceToHost));verify(reference,host);}
      return ms;
    });
  }
}
struct Board {
  static constexpr uint32_t full=(1u<<15)-1;
  uint32_t occupied,left,right;
  uint32_t available() const { return full & ~(occupied|left|right); }
  Board place(uint32_t q) const { return {occupied|q,(left|q)<<1,(right|q)>>1}; }
};
static void prefixes(Board state,int depth,std::vector<Board> &v) {
  if(depth==0){v.push_back(state);return;}
  for(auto p=state.available();p;p&=p-1)prefixes(state.place(p&-p),depth-1,v);
}
static unsigned queens(Board state) {
  if(state.occupied==Board::full)return 1;
  unsigned count=0;
  for(auto p=state.available();p;p&=p-1)count+=queens(state.place(p&-p));
  return count;
}
static void nqu(const std::vector<Variant> &roles,int b,int windows,bool native256) {
  int n=15,mark=10;
  int capacity=24576,groups=capacity/b,lanes=(b==256&&!native256)?128:b;
  struct Batch { std::vector<uint32_t> fields[3], reference; };
  std::vector<Batch> packets;
  unsigned cpuSolutions=0;
  for(int center=0;center<2;++center) {
    std::vector<Board> boards;
    for(int col=center?7:0;col<(center?8:7);++col)prefixes(Board{}.place(1u<<col),4,boards);
    int logical=groups*lanes;
    for(int start=0;start<int(boards.size());start+=logical) {
      Batch batch;
      for(auto &x:batch.fields)x.assign(capacity,0);
      std::fill(batch.fields[0].begin(),batch.fields[0].end(),Board::full);
      batch.reference.assign(groups,0);
      #pragma omp parallel for
      for(int g=0;g<groups;++g) for(int lane=0;lane<lanes;++lane) {
        int src=start+g*lanes+lane;
        if(src>=int(boards.size()))break;
        Board board=boards[src];int dst=g*b+lane;
        batch.fields[0][dst]=board.occupied;batch.fields[1][dst]=board.left;batch.fields[2][dst]=board.right;
        batch.reference[g]+=queens(board);
      }
      cpuSolutions+=std::accumulate(batch.reference.begin(),batch.reference.end(),0u)*(center?1:2);
      packets.push_back(std::move(batch));
    }
  }
  if(cpuSolutions!=2279184)throw std::runtime_error("CPU n-queens enumeration count");
  struct Packet {
    Buffer<uint32_t> a,b,c;
    explicit Packet(int count):a(count),b(count),c(count){}
  };
  std::vector<Packet*> devicePackets;
  for(auto &x:packets) {
    auto d=new Packet(capacity); devicePackets.push_back(d);
    d->a.upload(x.fields[0].data());d->b.upload(x.fields[1].data());d->c.upload(x.fields[2].data());
  }
  Buffer<uint32_t> output(groups);
  std::vector<uint32_t> actual(groups);
  Events events;
  run(roles,windows,[&](const Variant &v,bool validate){
    float total=0;
    for(unsigned j=0;j<devicePackets.size();++j) {
      auto &p=*devicePackets[j];
      void *args[]={&n,&mark,&p.a.ptr,&p.b.ptr,&p.c.ptr,&output.ptr,&capacity};
      total+=events.time([&]{v.kernels[0].launch(groups,b,args);});
      if(validate){output.read(actual.data());verify(packets[j].reference,actual);}
    }
    return total;
  });
  for(auto p:devicePackets)delete p;
}
static void lud(const std::vector<Variant> &roles,int b,int windows) {
  int n=16384;const size_t count=size_t(n)*n;
  std::vector<float> diagonal(n),reference(count),actual(count);
  for(int j=0;j<n;++j)diagonal[j]=10.0*std::exp(double(-0.001f*j));
  #pragma omp parallel for
  for(int y=0;y<n;++y)for(int x=0;x<n;++x)reference[size_t(y)*n+x]=diagonal[std::abs(y-x)];
  Buffer<float> source(count),data(count);
  source.upload(reference.data());
  // Each off-diagonal tile belongs to one panel launch. The diagonal remains read-only.
  #pragma omp parallel for schedule(dynamic,1)
  for(int o=0;o<n-b;o+=b) {
    for(int u=o+b;u<n;u+=b) {
      for(int i=1;i<b;++i) for(int j=0;j<i;++j) {
        const float a=reference[size_t(o+i)*n+o+j];
        for(int x=0;x<b;++x) {
          auto &v=reference[size_t(o+i)*n+u+x];
          v=std::fma(-a,reference[size_t(o+j)*n+u+x],v);
        }
      }
      for(int i=0;i<b;++i) {
        const float d=reference[size_t(o+i)*n+o+i];
        for(int x=0;x<b;++x) {
          auto index=size_t(u+x)*n+o;float val=reference[index+i];
          for(int j=0;j<i;++j)val=std::fma(-reference[index+j],reference[size_t(o+j)*n+o+i],val);
          reference[index+i]=val/d;
        }
      }
    }
  }
  size_t nan=0,inf=0;
  for(float x:reference) {
    nan+=std::isnan(x);
    inf+=std::isinf(x);
  }
  std::printf("oracle,LUD%d,nan,%zu,inf,%zu\n",b,nan,inf);
  Events events;
  run(roles,windows,[&](const Variant &v,bool validate){
    data.reset(source);
    auto ms=events.time([&]{
      for(int o=0;o<n-b;o+=b) {
        void *args[]={&data.ptr,&n,&o};
        v.kernels[0].launch((n-o)/b-1,2*b,args);
      }
    });
    if(validate) {
      data.read(actual.data());
      // The perimeter-only sweep may overflow on the frozen Toeplitz input.
      // Agreement requires the same exceptional class at every such element.
      verify(reference,actual,4e-5,4e-5,true);
    }
    return ms;
  });
}
static float roi(const std::vector<float>& image,int width) {
  float a=0,b=0;
  for(int y=0;y<128;++y)for(int x=0;x<128;++x) {
    float v=image[size_t(y)*width+x];a+=v;b+=v*v;
  }
  a/=128*128;b/=128*128;
  return (b-a*a)/(a*a);
}
static void srad(const std::vector<Variant> &roles,int b,int windows) {
  int size=4096;float lambda=0.5f;size_t count=size_t(size)*size;
  std::vector<float> initial(count),J(count),E(count),W(count),N(count),S(count),C(count);
  float coeffs[2];
  std::srand(7);
  for(auto &v:initial)v=std::exp(float(std::rand())/RAND_MAX);
  J=initial;
  for(int iter=0;iter<2;++iter) {
    float q=coeffs[iter]=roi(J,size);
    #pragma omp parallel for
    for(int y=0;y<size;++y)for(int x=0;x<size;++x) {
      size_t i=size_t(y)*size+x;
      float j=J[i],e=E[i]=J[x<size-1?i+1:i]-j,w=W[i]=J[x?i-1:i]-j,
        n=N[i]=J[y?i-size:i]-j,s=S[i]=J[y<size-1?i+size:i]-j;
      float g=(n*n+s*s+w*w+e*e)/(j*j),l=(n+s+w+e)/j;
      float num=(0.5f*g)-(1.f/16)*(l*l),den=1.f+0.25f*l;
      float qs=num/(den*den);
      // The artifact stores the coefficient directly. Its clipping code is disabled.
      C[i]=1.f/(1.f+(qs-q)/(q*(1.f+q)));
    }
    #pragma omp parallel for
    for(int y=0;y<size;++y)for(int x=0;x<size;++x) {
      size_t i=size_t(y)*size+x;
      J[i]+=0.25f*lambda*(C[i]*N[i]+C[y<size-1?i+size:i]*S[i]+C[i]*W[i]+C[x<size-1?i+1:i]*E[i]);
    }
  }
  Buffer<float> source(count),image(count),e(count),w(count),n(count),s(count),c(count);
  source.upload(initial.data());
  Events events;
  run(roles,windows,[&](const Variant &v,bool validate){
    image.reset(source);
    auto ms=events.time([&]{
      for(float q:coeffs) {
        dim3 grid(size/b,size/b),block(b,b);
        void *first[]={&e.ptr,&w.ptr,&n.ptr,&s.ptr,&image.ptr,&c.ptr,&size,&size,&q};
        void *second[]={&e.ptr,&w.ptr,&n.ptr,&s.ptr,&image.ptr,&c.ptr,&size,&size,&lambda,&q};
        v.kernels[0].launch(grid,block,first);
        v.kernels[1].launch(grid,block,second);
      }
    });
    if(validate){image.read(initial.data());verify(J,initial,2e-5,2e-5);}
    return ms;
  });
}
int main(int argc,char **argv) try {
  if(argc<5)throw std::runtime_error("PROGRAM BLOCK WINDOWS ROLE=DEVICE...");
  std::string p=argv[1];int b=std::stoi(argv[2]),windows=std::stoi(argv[3]);
  check(hipSetDevice(0));
  std::vector<Variant> roles;
  for(int i=4;i<argc;++i) {
    std::string spec=argv[i];auto split=spec.find('=');
    if(split==std::string::npos)throw std::runtime_error("missing role name");
    Variant role;role.name=spec.substr(0,split);
    check(hipModuleLoad(&role.module,spec.substr(split+1).c_str()));
    for(auto fn:symbols(p))role.kernels.push_back(kernel(role.module,fn));
    roles.push_back(std::move(role));
  }
  if(p=="BIT")bit(roles,b,windows);
  if(p=="DCT")dct(roles,b,windows);
  if(p=="MS"||p=="PCM")sort(roles,b,windows,p=="PCM");
  if(p=="NQU")nqu(roles,b,windows,std::getenv("KBS_NQU_NATIVE_256"));
  if(p=="LUD")lud(roles,b,windows);
  if(p=="SRAD")srad(roles,b,windows);
  for(auto &r:roles)check(hipModuleUnload(r.module));
  return 0;
} catch(const std::exception &e) {
  std::fprintf(stderr,"%s\n",e.what());
  return 2;
}
