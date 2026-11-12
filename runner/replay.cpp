#include "gpu.hpp"
#include <map>
#include <cstdint>
#include <sstream>
#include <cmath>
#include <algorithm>
#include <iomanip>
struct Buffer {std::string name,check;std::vector<unsigned char> initial,reference,got,exact;Ptr base{},ptr{};double atol=0,rtol=0;};
template<class T>T value(const std::vector<unsigned char>&b,size_t i){need((i+1)*sizeof(T)<=b.size(),"array bounds");T v;memcpy(&v,b.data()+i*sizeof(T),sizeof(T));return v;}
static void geometry(std::map<std::string,Buffer>&buf,const int dims[3],const int nn[3]){
 auto get=[&](const char*n,size_t i){return double(value<float>(buf.at(n).got,i));};
 size_t count=buf.at("alive").got.size();const char*indices[]={"pic","pjc","pkc"};const char*positions[]={"px","py","pz"};const char*xyz[]={"x","y","z"};
 for(size_t p=0;p<count;p++){
  int cell[3];for(int a=0;a<3;a++){cell[a]=value<int>(buf.at(indices[a]).got,p);need(cell[a]>=0&&cell[a]<dims[a],"cell range");}
  if(value<signed char>(buf.at("alive").got,p)!=1)continue;
  double nodes[8][3],target[3],s[3]={.5,.5,.5};for(int a=0;a<3;a++)target[a]=get(positions[a],p);
  for(int c=0;c<8;c++){size_t idx=((cell[2]+((c>>2)&1))*nn[1]+cell[1]+((c>>1)&1))*size_t(nn[0])+cell[0]+(c&1);for(int a=0;a<3;a++)nodes[c][a]=get(xyz[a],idx);}
  auto evaluate=[&](double val[3],double J[3][3]){for(int a=0;a<3;a++){val[a]=0;for(int b=0;b<3;b++)J[a][b]=0;}for(int c=0;c<8;c++){double f[3];for(int a=0;a<3;a++)f[a]=(c&(1<<a))?s[a]:1-s[a];for(int a=0;a<3;a++){val[a]+=f[0]*f[1]*f[2]*nodes[c][a];for(int b=0;b<3;b++)J[a][b]+=((c&(1<<b))?1:-1)*f[(b+1)%3]*f[(b+2)%3]*nodes[c][a];}}};
  for(int it=0;it<12;it++){double v[3],J[3][3],A[3][4];evaluate(v,J);for(int a=0;a<3;a++){for(int b=0;b<3;b++)A[a][b]=J[a][b];A[a][3]=target[a]-v[a];}
   for(int col=0;col<3;col++){int pivot=col;for(int a=col+1;a<3;a++)if(std::abs(A[a][col])>std::abs(A[pivot][col]))pivot=a;for(int b=col;b<4;b++)std::swap(A[col][b],A[pivot][b]);need(std::abs(A[col][col])>1e-30,"singular geometry");double z=A[col][col];for(int b=col;b<4;b++)A[col][b]/=z;for(int a=0;a<3;a++)if(a!=col){z=A[a][col];for(int b=col;b<4;b++)A[a][b]-=z*A[col][b];}}
   double maxstep=0;for(int a=0;a<3;a++){s[a]+=A[a][3];maxstep=std::max(maxstep,std::abs(A[a][3]));}if(maxstep<1e-12)break;
  }
  double v[3],J[3][3];evaluate(v,J);for(int a=0;a<3;a++){need(std::isfinite(s[a])&&s[a]>=double(float(-1e-4))&&s[a]<=double(float(1)+float(1e-4)),"active cell containment");need(std::abs(v[a]-target[a])<=1e-10,"inverse geometry residual");}
 }
}
int main(int argc,char**argv){try{
 Options o(argc,argv,true);fs::path config=fs::absolute(o.input),root=config.parent_path();std::ifstream spec(config);need(bool(spec),"input spec");std::string line,symbol;unsigned grid[3]={1,1,1},block[3]={1,1,1};std::map<std::string,Buffer> buffers;std::vector<std::pair<std::string,std::string>> args;bool geo=false;int dims[3]{},nodes[3]{};
 while(std::getline(spec,line)){if(line.empty()||line[0]=='#')continue;std::istringstream in(line);std::string op;in>>op;
  if(op=="kernel")in>>symbol;else if(op=="grid")in>>grid[0]>>grid[1]>>grid[2];else if(op=="block")in>>block[0]>>block[1]>>block[2];
  else if(op=="buffer"){Buffer b;std::string initial,ref;in>>b.name>>initial>>b.check>>ref>>b.atol>>b.rtol;b.initial=readbytes(root/initial);need(!b.initial.empty(),"empty buffer "+b.name);if(ref!="-")b.reference=readbytes(root/ref);need(b.reference.empty()||b.reference.size()==b.initial.size(),"reference size");buffers.emplace(b.name,std::move(b));}
  else if(op=="exactref"){std::string n,path;in>>n>>path;buffers.at(n).exact=readbytes(root/path);}
  else if(op=="arg"){std::string type,v;in>>type>>v;args.emplace_back(type,v);}
  else if(op=="geometry"){geo=true;in>>dims[0]>>dims[1]>>dims[2]>>nodes[0]>>nodes[1]>>nodes[2];}else throw std::runtime_error("unknown spec directive "+op);
  need(bool(in),"malformed spec: "+line);
 }
 need(!symbol.empty()&&!args.empty(),"incomplete spec");
 for(auto&[n,b]:buffers)if(b.check=="profile_u64"){
  need(o.mode=="validate"&&o.timing=="event","profile capture requires validate/event");
  need(n=="wave_profile"&&b.initial.size()==32&&b.reference.empty()&&b.exact.empty(),"invalid wave profile buffer");
  need(std::all_of(b.initial.begin(),b.initial.end(),[](auto c){return c==0;}),"profile counters must start at zero");
 }
 const bool compare=!o.darm.empty();
 need(!compare||o.mode=="benchmark","three-way comparison requires benchmark mode");
 for(auto&[n,b]:buffers)need(!compare||b.check!="profile_u64","three-way comparison does not support profile capture");
 struct Variant {
  std::string role, path;
  Module module{};
  Function kernel{};
  Graph graph{};
  GraphExec executable{};
  std::vector<double> measured;
 };
 std::vector<Variant> variants{{"baseline",o.kernel}};
 if(compare){variants.push_back({"darm",o.darm});variants.push_back({"greedy",o.greedy});}
 init();
 for(auto& variant:variants){load(&variant.module,variant.path.c_str());function(&variant.kernel,variant.module,symbol.c_str());}
 Stream stream;streamCreate(&stream);Event start,stop;eventCreate(&start);eventCreate(&stop);
 for(auto&[n,b]:buffers){b.base=alloc(b.initial.size()+512);b.ptr=(Ptr)((std::uintptr_t)b.base+256);}
 std::vector<std::vector<unsigned char>> storage;for(auto&[type,v]:args){std::vector<unsigned char>a;if(type=="ptr"){auto p=buffers.at(v).ptr;a.resize(8);memcpy(a.data(),&p,8);}else if(type=="hex"){need(v.size()%2==0,"hex size");for(size_t i=0;i<v.size();i+=2)a.push_back(std::stoul(v.substr(i,2),nullptr,16));}else if(type=="file")a=readbytes(root/v);else throw std::runtime_error("arg type");storage.push_back(std::move(a));}
 std::vector<void*> argvp;for(auto&a:storage)argvp.push_back(a.data());
 if(o.timing=="graph")for(auto& variant:variants){
  beginCapture(stream);launch(variant.kernel,grid,block,stream,argvp.data());endCapture(stream,&variant.graph,&variant.executable);
 }
 std::ofstream samples(fs::path(o.output)/"samples.csv");
 samples<<"round,warmup,microseconds,timing,full_output_passed";
 if(compare)samples<<",role";
 samples<<"\n"<<std::setprecision(10);
 for(int r=0;r<o.rounds();r++)for(size_t slot=0;slot<variants.size();++slot){
  auto& variant=variants[(r+slot)%variants.size()];
  for(auto&[n,b]:buffers){std::vector<unsigned char>padded(b.initial.size()+512,0xa5);std::copy(b.initial.begin(),b.initial.end(),padded.begin()+256);upload(b.base,padded.data(),padded.size());}
  record(start,stream);if(variant.executable)graphLaunch(variant.executable,stream);else launch(variant.kernel,grid,block,stream,argvp.data());record(stop,stream);float ms=elapsed(start,stop);
  for(auto&[n,b]:buffers){std::vector<unsigned char>padded(b.initial.size()+512);download(padded.data(),b.base,padded.size());bool guards=std::all_of(padded.begin(),padded.begin()+256,[](auto c){return c==0xa5;})&&std::all_of(padded.end()-256,padded.end(),[](auto c){return c==0xa5;});b.got.assign(padded.begin()+256,padded.end()-256);bool pass=guards;if(!b.exact.empty())pass&=b.got==b.exact;
   if(b.check=="readonly")pass&=b.got==b.initial;else if(b.check=="exact")pass&=b.got==b.reference;else if(b.check=="f32"||b.check=="f64"){size_t width=b.check=="f32"?4:8;need(b.reference.size()==b.got.size()&&b.got.size()%width==0,"numeric reference size");for(size_t i=0;i<b.got.size()/width;i++){double x=width==4?value<float>(b.got,i):value<double>(b.got,i),y=width==4?value<float>(b.reference,i):value<double>(b.reference,i);pass&=std::isfinite(x)&&std::isfinite(y)&&std::abs(x-y)<=b.atol+b.rtol*std::abs(y);}}else need(b.check=="geometry"||b.check=="profile_u64", "unknown check "+b.check);
   if(!pass){writebytes(fs::path(o.output)/(n+"-failure.bin"),padded);throw std::runtime_error((compare?variant.role+" ":"")+"output/guard failure "+n);}
  }
  if(geo)geometry(buffers,dims,nodes);
  for(auto&[n,b]:buffers)if(b.check=="profile_u64"){
   auto visits=value<uint64_t>(b.got,0),t=value<uint64_t>(b.got,1),f=value<uint64_t>(b.got,2),both=value<uint64_t>(b.got,3);
   need(t<=visits&&f<=visits&&both<=t&&both<=f&&t-both==visits-f,"invalid wave profile counters");
   writebytes(fs::path(o.output)/"wave-profile.bin",b.got);
  }
  if(compare&&o.measured(r)){
   need(std::isfinite(ms)&&ms>0,"invalid GPU timing for "+variant.role);
   variant.measured.push_back(1000.0*ms);
  }
  samples<<r<<","<<(o.mode=="benchmark"&&!o.measured(r))<<","<<(o.mode=="benchmark"?ms*1000:0)<<","<<o.timing<<",1";
  if(compare)samples<<","<<variant.role;
  samples<<"\n";samples.flush();
 }
 for(auto& variant:variants)if(variant.executable)graphFree(variant.executable,variant.graph);
 for(auto&[n,b]:buffers)release(b.base);
 eventFree(start);eventFree(stop);streamFree(stream);
 for(auto& variant:variants)unload(variant.module);
 finish();
 std::ofstream result(fs::path(o.output)/"result.json");
 result<<"{\"passed\":true,\"launches\":"<<o.rounds()*variants.size()<<",\"timing\":\""<<o.timing
       <<"\",\"graph_nodes\":"<<(o.timing=="graph"?variants.size():0);
 if(compare){
  auto median=[](std::vector<double> values){
   std::sort(values.begin(),values.end());
   const size_t mid=values.size()/2;
   return values.size()%2 ? values[mid] : (values[mid-1]+values[mid])*0.5;
  };
  auto pairedDelta=[&](const Variant& candidate,const Variant& reference){
   std::vector<double> deltas;
   for(size_t r=0;r<candidate.measured.size();++r)
    deltas.push_back(100*(candidate.measured[r]/reference.measured[r]-1));
   return median(deltas);
  };
  result<<",\"variants\":{";
  for(size_t i=0;i<variants.size();++i){
   auto& variant=variants[i];
   if(i)result<<",";
   result<<"\""<<variant.role<<"\":{\"median_us\":"<<std::setprecision(10)<<median(variant.measured)
         <<",\"paired_delta_vs_baseline_pct\":"<<pairedDelta(variant,variants.front())<<"}";
  }
  result<<"},\"greedy_vs_darm_paired_pct\":"<<pairedDelta(variants[2],variants[1]);
 }
 result<<"}\n";
 std::cout<<"PASS "<<o.rounds()*variants.size()<<" full-output checks\n";
 return 0;
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
