#include "../../../runner/options.hpp"
#include <hip/hip_runtime.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <algorithm>
#include <fstream>
#include <cstring>
#include <limits>
#include <string>
#include "types_TIGRE.hpp"
#include "geometry.inc"
#define CK(x) do {auto e=(x);if(e!=hipSuccess){fprintf(stderr,"%s:%d %s\n",#x,__LINE__,hipGetErrorString(e));exit(2);}}while(0)
static void need(bool v,const char*msg){if(!v){fprintf(stderr,"FAIL %s\n",msg);exit(3);}}
static void writebin(std::string path,const void*p,size_t n){std::ofstream f(path,std::ios::binary);f.write((const char*)p,n);need(bool(f),"write file");}
int main(int argc,char**argv){Options options(argc,argv);need(options.timing=="event","TIGRE currently supports Event timing only");std::string out=options.output;std::string inputfile=(fs::path(options.input)/"head64.bin").string();std::string manifestfile=out+"/roles.txt";{std::ofstream f(manifestfile);f<<"baseline "<<options.kernel<<" _Z19kernelPixelDetector8GeometryPfiiP13__hip_texture\n";}

 hipDeviceProp_t prop{};CK(hipGetDeviceProperties(&prop,0));need(prop.warpSize==64,"wave64 required");printf("DEVICE %s wave=%d\n",prop.name,prop.warpSize);
 Geometry g{};g.nVoxelX=g.nVoxelY=g.nVoxelZ=64;g.sVoxelX=g.sVoxelY=g.sVoxelZ=256;g.dVoxelX=g.dVoxelY=g.dVoxelZ=4;g.nDetecU=g.nDetecV=128;g.dDetecU=g.dDetecV=3.2f;g.sDetecU=g.sDetecV=409.6f;
 std::vector<float> zero(50,0),dso(50,1000),dsd(50,1536);g.offOrigX=g.offOrigY=g.offOrigZ=zero.data();g.offDetecU=g.offDetecV=zero.data();g.COR=g.dRoll=g.dPitch=g.dYaw=zero.data();g.DSO=dso.data();g.DSD=dsd.data();
 std::vector<float> img(64*64*64);std::ifstream f(inputfile,std::ios::binary);f.read((char*)img.data(),img.size()*4);need(bool(f),"read phantom");
 hipArray_t array;auto desc=hipCreateChannelDesc<float>();auto ext=make_hipExtent(64,64,64);CK(hipMalloc3DArray(&array,&desc,ext,0));hipMemcpy3DParms copy{};copy.srcPtr=make_hipPitchedPtr(img.data(),64*4,64,64);copy.dstArray=array;copy.extent=ext;copy.kind=hipMemcpyHostToDevice;CK(hipMemcpy3D(&copy));hipResourceDesc res{};res.resType=hipResourceTypeArray;res.res.array.array=array;hipTextureDesc td{};td.normalizedCoords=0;td.filterMode=hipFilterModePoint;td.readMode=hipReadModeElementType;for(int i=0;i<3;i++)td.addressMode[i]=hipAddressModeBorder;hipTextureObject_t tex;CK(hipCreateTextureObject(&tex,&res,&td,nullptr));
 dim3 block(9,9,9),grid(15,15,1);size_t plane=128*128,count=plane*9,slots=15*15*729;unsigned maxsteps=3*64+3;float*raw;CK(hipMalloc(&raw,(count+128)*4));float*dst=raw+64;std::vector<float> initial(count+128,12345.25f),gpu(count+128),ref(count);std::vector<std::vector<float>> baselines;
 std::vector<Point3D> params(6*36);
 for(int batch=0;batch<6;batch++)for(int j=0;j<9&&batch*9+j<50;j++){int angle=batch*9+j;g.alpha=(float)(angle*(2*acos(-1.0)/50));computeDeltas_Siddon(g,angle,&params[batch*36+j*4],&params[batch*36+j*4+1],&params[batch*36+j*4+2],&params[batch*36+j*4+3]);}
 writebin(out+"/params.bin",params.data(),params.size()*sizeof(Point3D));

 struct Variant{std::string name,path,symbol;hipModule_t mod;hipFunction_t fn;hipDeviceptr_t param;};std::vector<Variant> vars;std::ifstream manifest(manifestfile);Variant v{};
 while(manifest>>v.name>>v.path>>v.symbol){CK(hipModuleLoad(&v.mod,v.path.c_str()));CK(hipModuleGetFunction(&v.fn,v.mod,v.symbol.c_str()));size_t bytes;CK(hipModuleGetGlobal(&v.param,&bytes,v.mod,"projParamsArrayDev"));need(bytes==36*sizeof(Point3D),"constant parameters layout");vars.push_back(v);}need(vars.size()>0,"manifest");
 std::vector<std::vector<float>> refs(6,std::vector<float>(count+128,12345.25f));std::string input=inputfile;input=input.substr(0,input.find_last_of('/'));
 for(int b=0;b<6;b++){std::ifstream rf(input+"/cpu-recurrence-"+std::to_string(b)+".bin",std::ios::binary);rf.read((char*)(refs[b].data()+64),count*4);need(bool(rf),"CPU recurrence reference");}
 auto loadparams=[&](Variant&v,int b){CK(hipMemcpyHtoD(v.param,params.data()+b*36,36*sizeof(Point3D)));};
 auto launch=[&](Variant&v,int b){int total=50;void*args[]={&g,&dst,&b,&total,&tex};CK(hipModuleLaunchKernel(v.fn,15,15,1,9,9,9,0,nullptr,args,nullptr));};
 auto equal=[&](const std::vector<float>&x,int b){size_t valid=std::min(9,50-b*9)*plane;for(size_t i=64;i<64+valid;i++)if(!std::isfinite(x[i]))return false;return memcmp(x.data(),refs[b].data(),x.size()*4)==0;};
 auto check=[&](Variant&v,int b){CK(hipMemcpy(gpu.data(),raw,gpu.size()*4,hipMemcpyDeviceToHost));if(!equal(gpu,b)){writebin(out+"/FAIL-"+v.name+"-"+std::to_string(b)+".bin",gpu.data(),gpu.size()*4);size_t nbad=0;double mx=0;for(size_t i=0;i<gpu.size();i++)if(memcmp(&gpu[i],&refs[b][i],4)){if(nbad<8)printf("DIFF %s b=%d index=%zu got=%.9g ref=%.9g\n",v.name.c_str(),b,i,gpu[i],refs[b][i]);nbad++;mx=std::max(mx,fabs((double)gpu[i]-refs[b][i]));}printf("BAD %s b=%d count=%zu maxabs=%.9g\n",v.name.c_str(),b,nbad,mx);fflush(stdout);need(false,"CPU recurrence bitwise/finite/guards");}};
 if(options.mode=="validate"){
  for(auto&v:vars)for(int b=0;b<6;b++){loadparams(v,b);CK(hipMemcpy(raw,initial.data(),initial.size()*4,hipMemcpyHostToDevice));launch(v,b);CK(hipDeviceSynchronize());check(v,b);writebin(out+"/"+v.name+"-"+std::to_string(b)+".bin",gpu.data(),gpu.size()*4);
   printf("VALID %s batch=%d bitwise=1\n",v.name.c_str(),b);fflush(stdout);
  }
 }else{need(options.mode=="benchmark","mode");hipEvent_t start,stop;CK(hipEventCreate(&start));CK(hipEventCreate(&stop));std::ofstream times(out+"/timing.csv");times<<"round,variant,batch,warmup,ms\n";
  for(int rd=0;rd<options.rounds();rd++)for(size_t pos=0;pos<vars.size();pos++){size_t idx=(rd/2+(rd%2?vars.size()-1-pos:pos))%vars.size();auto&v=vars[idx];for(int bp=0;bp<6;bp++){int b=rd%2?5-bp:bp;loadparams(v,b);CK(hipMemcpy(raw,initial.data(),initial.size()*4,hipMemcpyHostToDevice));CK(hipEventRecord(start));launch(v,b);CK(hipEventRecord(stop));CK(hipEventSynchronize(stop));float ms;CK(hipEventElapsedTime(&ms,start,stop));check(v,b);times<<rd<<","<<v.name<<","<<b<<","<<(!options.measured(rd))<<","<<ms<<"\n";times.flush();}}
  CK(hipEventDestroy(start));CK(hipEventDestroy(stop));
 }
 for(auto&v:vars)CK(hipModuleUnload(v.mod));CK(hipDestroyTextureObject(tex));CK(hipFreeArray(array));CK(hipFree(raw));printf("COMPLETE %s\n",options.mode.c_str());return 0;
}
