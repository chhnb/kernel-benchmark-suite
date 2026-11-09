// Deterministic, transient regression fixtures. No GPU execution here.
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <vector>
#ifdef MAPAIRY
#include <boost/math/distributions/mapairy.hpp>
#endif
namespace fs=std::filesystem;
static uint64_t state;
static uint64_t random64(){uint64_t z=(state+=0x9e3779b97f4a7c15ULL);z=(z^(z>>30))*0xbf58476d1ce4e5b9ULL;z=(z^(z>>27))*0x94d049bb133111ebULL;return z^(z>>31);}
template<class T>static void write(const fs::path&p,const std::vector<T>&v){std::ofstream f(p,std::ios::binary);f.write((const char*)v.data(),v.size()*sizeof(T));if(!f)throw std::runtime_error("write "+p.string());}
static std::string hex32(uint32_t v){const char*h="0123456789abcdef";std::string s;for(int i=0;i<4;++i){unsigned b=(v>>(i*8))&255;s+=h[b>>4];s+=h[b&15];}return s;}
static uint32_t bits(float x){uint32_t u;std::memcpy(&u,&x,4);return u;}
static float unbits(uint32_t u){float x;std::memcpy(&x,&u,4);return x;}
static uint8_t fp4(float x){float a=std::fabs(x);const float piv[]={.25f,.75f,1.25f,1.75f,2.5f,3.5f,5.f};unsigned c=7;
 for(unsigned i=0;i<7;++i)if((i%2==0?a<=piv[i]:a<piv[i])){c=i;break;}return c|(std::signbit(x)?8:0);}
struct FP8Table {float v[127];FP8Table(){for(unsigned c=0;c<127;++c)v[c]=c<8?float(c)*0x1p-9f:std::ldexp(1.f+float(c&7)*.125f,int(c>>3)-7);}};
static const FP8Table fp8;
static float dec8(unsigned c){return fp8.v[c];}
static uint8_t enc8(float a){unsigned hi=std::min<unsigned>(126,std::lower_bound(fp8.v,fp8.v+127,a)-fp8.v);unsigned lo=hi?hi-1:0;float dl=a-dec8(lo),dh=dec8(hi)-a;return dl<dh?lo:dh<dl?hi:hi%2?lo:hi;}
static void quant(const std::vector<uint16_t>&input,const std::vector<int64_t>&slots,float global,bool swizzle,std::vector<uint8_t>&data,std::vector<uint8_t>&scales){
 constexpr unsigned heads=8,dim=128,sd=8,page=16,stride=1024;const float levels[]={0,.5f,1,1.5f,2,3,4,6};
 for(size_t t=0;t<slots.size();++t){if(slots[t]<0)continue;size_t b=slots[t]/page;unsigned row=slots[t]%page;
  for(unsigned h=0;h<heads;++h)for(unsigned s=0;s<sd;++s){float v[16],mx=0;
   for(unsigned i=0;i<16;++i){v[i]=unbits(uint32_t(input[t*stride+h*dim+s*16+i])<<16);mx=std::max(mx,std::fabs(v[i]));}
   float os[2],error[2];uint8_t code[2];
   for(unsigned c=0;c<2;++c){float den=c?4.f:6.f;code[c]=enc8(global*(mx*(1.f/den)));float sf=dec8(code[c]);os[c]=sf!=0?1.f/(sf*(1.f/global)):0;float ds=os[c]!=0?1.f/os[c]:0,e=0;
    for(unsigned i=0;i<16;i+=2){float z0=v[i]*os[c],z1=v[i+1]*os[c];float d0=std::copysign(levels[fp4(z0)&7],z0)*ds-v[i],d1=std::copysign(levels[fp4(z1)&7],z1)*ds-v[i+1];e=e+(d0*d0+d1*d1);}error[c]=e;}
   unsigned c=error[1]<error[0];size_t off=((b*heads+h)*page+row)*(dim/2)+s*8;
   for(unsigned i=0;i<8;++i)data[off+i]=fp4(v[i*2]*os[c])|(fp4(v[i*2+1]*os[c])<<4);
   unsigned st=swizzle?(row/4)*4+s/(sd/4):row,ss=swizzle?(s%(sd/4))*4+row%4:s;
   scales[((b*heads+h)*page+st)*sd+ss]=code[c];
  }
 }
}
int main(int argc,char**argv){try{
 if(argc!=4)throw std::runtime_error("usage: generate OUT COUNT SEED");fs::path p=argv[1];size_t n=std::stoull(argv[2]);state=std::stoull(argv[3]);if(!n||n>131072)throw std::runtime_error("count outside supported range");if(fs::exists(p))throw std::runtime_error("output exists");fs::create_directories(p);
 std::ofstream spec(p/"input.txt");
#ifdef MAPAIRY
 const double anchors[]={.4375,.3125,.1875,.0625,.015625,0x1p-12,0x1p-24,0x1p-48,0x1p-96,0x1p-192,0x1p-384,0x1p-768};
 std::vector<double>x(n),ref(n),zero(n,0);for(size_t i=0;i<n;++i)x[i]=anchors[i%12];for(size_t i=n-1;i;i--)std::swap(x[i],x[random64()%(i+1)]);
 for(size_t i=0;i<n;++i){ref[i]=double(boost::math::quantile(boost::math::mapairy_distribution<long double>(),(long double)x[i]));if(!std::isfinite(ref[i]))throw std::runtime_error("oracle nonfinite");}
 write(p/"input.bin",x);write(p/"reference.bin",ref);write(p/"output-init.bin",zero);
 spec<<"kernel evaluate\ngrid "<<(n+255)/256<<" 1 1\nblock 256 1 1\nbuffer input input.bin readonly - 0 0\nbuffer output output-init.bin f64 reference.bin 1e-14 5e-13\narg ptr input\narg ptr output\narg hex "<<hex32(n)<<"\n";
#else
 size_t capacity=((n+15)/16+1)*16;std::vector<int64_t>slots(n);std::iota(slots.begin(),slots.end(),0);for(size_t i=n-1;i;i--)std::swap(slots[i],slots[random64()%(i+1)]);for(size_t i=0;i<n;i+=17)slots[i]=-1;write(p/"slots.bin",slots);
 spec<<"kernel cache_eval\ngrid "<<n<<" 1 1\nblock 64 1 1\nbuffer slots slots.bin readonly - 0 0\n";
 for(unsigned which=0;which<2;++which){const char*input=which?"value":"key",*dn=which?"vd":"kd",*sn=which?"vs":"ks";std::vector<uint16_t>x(n*1024);
  // Fixed-integer CLT12 approximate normal, then BF16 nearest-even. No libstdc++ normal_distribution dependence.
  for(auto &u:x){uint32_t sum=0;for(unsigned j=0;j<2;++j){uint64_t w=random64();for(unsigned k=0;k<6;++k){sum+=w&1023;w>>=10;}}float v=float(int(sum)-6138)*0x1p-10f;uint32_t b=bits(v);u=(b+0x7fff+((b>>16)&1))>>16;}
  const float edge[]={.25f,.75f,1.25f,1.75f,2.5f,3.5f,5,6,-.25f,-.75f,-1.25f,-1.75f,-2.5f,-3.5f,-5,-6};
  for(size_t i=0;i<std::min(size_t(1024),x.size());++i)x[i]=0;
  if(n>1)for(unsigned i=0;i<16;++i)x[1024+i]=bits(edge[i])>>16;
  if(n>2){x[2048]=0x8000;x[2049]=0;}
  if(n>3)for(unsigned i=0;i<16;++i)x[3072+i]=0;
  write(p/(std::string(input)+".bin"),x);spec<<"buffer "<<input<<" "<<input<<".bin readonly - 0 0\n";
  std::vector<uint8_t>data(capacity*8*64,165),scales(capacity*8*8,165);
  write(p/(std::string(dn)+"-init.bin"),data);write(p/(std::string(sn)+"-init.bin"),scales);
  quant(x,slots,which?1.25f:1.f,which,data,scales);write(p/(std::string(dn)+"-ref.bin"),data);write(p/(std::string(sn)+"-ref.bin"),scales);
  for(auto name:{dn,sn})spec<<"buffer "<<name<<" "<<name<<"-init.bin exact "<<name<<"-ref.bin 0 0\n";
 }
 for(auto name:{"key","value","slots","kd","vd","ks","vs"})spec<<"arg ptr "<<name<<"\n";
 for(uint32_t v:{8u,128u,16u,1024u,bits(1.f),bits(1.25f)})spec<<"arg hex "<<hex32(v)<<"\n";
#endif
 if(!spec)throw std::runtime_error("spec write");std::cout<<"generated "<<n<<" elements at "<<p<<"\n";
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
