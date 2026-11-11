#include <hip/hip_runtime.h>
#include "../../../runner/options.hpp"
#include <algorithm>
#include <iomanip>
#define H(x) do{auto e=(x);need(e==hipSuccess,std::string(#x)+": "+hipGetErrorString(e));}while(0)
struct Buf{unsigned char*p;size_t n;Buf(size_t n):n(n){H(hipMalloc((void**)&p,n+512));}void*data(){return p+256;}void reset(const std::vector<unsigned char>*v=nullptr){H(hipMemset(p,165,n+512));if(v)H(hipMemcpy(data(),v->data(),n,hipMemcpyHostToDevice));}std::vector<unsigned char> get(){std::vector<unsigned char>v(n+512);H(hipMemcpy(v.data(),p,n+512,hipMemcpyDeviceToHost));return v;}~Buf(){hipFree(p);}};
int main(int argc,char**argv){try{
 Options o(argc,argv);need(o.timing=="event","CED event only");int rows=354,cols=626;size_t n=size_t(rows)*cols;
 struct Frame{std::vector<unsigned char>m,t,e;};std::vector<Frame> frames;
 for(int f=0;f<110;f++){auto p=fs::path(o.input)/std::to_string(f);Frame x{readbytes(p.string()+"-magnitude.bin"),readbytes(p.string()+"-theta.bin"),readbytes(p.string()+"-expected.bin")};need(x.m.size()==n&&x.t.size()==n&&x.e.size()==n,"fixture extent");frames.push_back(std::move(x));}
 H(hipInit(0));H(hipSetDevice(0));hipModule_t mod;H(hipModuleLoad(&mod,o.kernel.c_str()));hipFunction_t fn;H(hipModuleGetFunction(&fn,mod,"_Z19non_max_supp_kernelPKhPhS0_ii"));Buf m(n),t(n),out(n);void*mp=m.data();void*tp=t.data();void*op=out.data();void*args[]={&mp,&op,&tp,&rows,&cols};hipEvent_t start,stop;H(hipEventCreate(&start));H(hipEventCreate(&stop));
 std::ofstream samples(fs::path(o.output)/"samples.csv"),perframe(fs::path(o.output)/"per-frame.csv");samples<<std::setprecision(12)<<"round,warmup,microseconds,timing,full_output_passed\n";perframe<<std::setprecision(12)<<"round,frame,microseconds,full_output_passed\n";
 auto check=[&](Buf&b,const std::vector<unsigned char>&want,const std::string&tag){auto v=b.get();bool ok=std::all_of(v.begin(),v.begin()+256,[](auto x){return x==165;})&&std::all_of(v.end()-256,v.end(),[](auto x){return x==165;})&&std::equal(want.begin(),want.end(),v.begin()+256);if(!ok){writebytes(fs::path(o.output)/(tag+"-failure.bin"),v);throw std::runtime_error(tag+" output/guard mismatch");}};
 for(int r=0;r<o.rounds();r++){double total=0;for(int f=0;f<110;f++){auto&x=frames[f];m.reset(&x.m);t.reset(&x.t);out.reset();H(hipEventRecord(start,0));H(hipModuleLaunchKernel(fn,39,22,1,16,16,1,18*18*sizeof(int),0,args,nullptr));H(hipEventRecord(stop,0));H(hipEventSynchronize(stop));float ms;H(hipEventElapsedTime(&ms,start,stop));check(out,x.e,"output-"+std::to_string(f));check(m,x.m,"magnitude-"+std::to_string(f));check(t,x.t,"theta-"+std::to_string(f));total+=ms*1000.;perframe<<r<<","<<f<<","<<(o.mode=="benchmark"?ms*1000.:0)<<",1\n";}
 samples<<r<<","<<(o.mode=="benchmark"&&!o.measured(r))<<","<<(o.mode=="benchmark"?total:0)<<",event,1\n";samples.flush();perframe.flush();need(bool(samples)&&bool(perframe),"write samples");}
 H(hipEventDestroy(start));H(hipEventDestroy(stop));H(hipModuleUnload(mod));std::ofstream result(fs::path(o.output)/"result.json");result<<"{\"passed\":true,\"frames_per_round\":110,\"rounds\":"<<o.rounds()<<",\"metric\":\"sum of individual full-kernel event intervals, not pipeline time\"}\n";return 0;
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
