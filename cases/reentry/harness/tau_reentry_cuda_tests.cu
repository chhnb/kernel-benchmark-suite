#define TAU_REENTRY_CUDA_NO_RAYLIB
#define TAU_REENTRY_CUDA_NO_MAIN
#include "tau_reentry_cuda.cu"

static std::vector<unsigned char> read_fixture(const std::string&file){std::ifstream f(file,std::ios::binary|std::ios::ate);if(!f)exit(30);size_t n=f.tellg();f.seekg(0);std::vector<unsigned char>b(n);f.read((char*)b.data(),n);if(size_t(f.gcount())!=n)exit(31);return b;}
int main(int argc,char**argv){
Options options(argc,argv);suite_options=&options;need(options.timing=="event","this case supports Event timing only");
setenv("SUITE_INPUT",options.input.c_str(),1);setenv("SUITE_OUTPUT",options.output.c_str(),1);setenv("PERF_PHASE",options.mode=="benchmark"?"screen":"qualification",1);
std::string manifest=options.output+"/roles.txt";{std::ofstream f(manifest);f<<"baseline "<<options.kernel<<"\n";}setenv("SUITE_ROLES",manifest.c_str(),1);

for(int step:{1,24,256,1024}){
std::string folder=std::string(getenv("SUITE_INPUT"))+"/reentry-"+std::to_string(step)+"/";
SimConfig cfg{};auto cfgbytes=read_fixture(folder+"cfg.bin");if(cfgbytes.size()!=sizeof(cfg))exit(32);memcpy(&cfg,cfgbytes.data(),sizeof(cfg));
std::vector<InputView> inputs;std::vector<void*> allocated;
for(int j=0;j<6;j++){auto bytes=read_fixture(folder+"input"+std::to_string(j)+".bin");void*ptr=nullptr;CK(hipMalloc(&ptr,bytes.size()));CK(hipMemcpy(ptr,bytes.data(),bytes.size(),hipMemcpyHostToDevice));inputs.push_back({ptr,bytes.size()});allocated.push_back(ptr);}
int faces=(NFACE_X*NY);int cells=NCELL;
auto index=[](int t){return cell_index(t%NFACE_X+2,t/NFACE_X+ROW_FIRST);};
double*ref[4];for(int k=0;k<4;k++){auto b=read_fixture(folder+"reference"+std::to_string(k)+".bin");if(b.size()!=size_t(faces)*8)exit(33);std::vector<double> expanded(cells,NAN);for(int t=0;t<faces;t++)memcpy(&expanded[index(t)],b.data()+t*8,8);CK(hipMalloc(&ref[k],cells*8));CK(hipMemcpy(ref[k],expanded.data(),cells*8,hipMemcpyHostToDevice));}
Field U{(double*)allocated[0],(double*)allocated[1],(double*)allocated[2],(double*)allocated[3]};uint8_t*mask=(uint8_t*)allocated[4],*flags=(uint8_t*)allocated[5];
validate_batch("reentry",step,cfg,inputs,ref,cells,faces,index,[&](hipFunction_t fn,double**p){Field out{p[0],p[1],p[2],p[3]};void*args[]={&U,&mask,&flags,&out};CK(hipModuleLaunchKernel(fn,(faces+255)/256,1,1,256,1,1,0,0,args,nullptr));});
for(auto ptr:allocated)CK(hipFree(ptr));for(auto ptr:ref)CK(hipFree(ptr));
}
return 0;
}
