#include <filesystem>
#include <fstream>
#include <vector>
#include <stdexcept>
#include <algorithm>
namespace fs=std::filesystem;
std::vector<float> read(fs::path p,size_t n){std::ifstream f(p,std::ios::binary);std::vector<float>x(n);if(!f.read(reinterpret_cast<char*>(x.data()),n*4))throw std::runtime_error(p.string());return x;}
int main(int argc,char**argv){
 if(argc!=3)return 2;fs::path source=argv[1],out=argv[2];
 for(int n:{256,1024}){auto a=source/std::to_string(n),b=out/std::to_string(n);fs::create_directories(b);size_t sz=size_t(n)*n;
 auto J=read(a/"J.bin",sz),C=read(a/"C-ref.bin",sz),N=read(a/"N-ref.bin",sz),S=read(a/"S-ref.bin",sz),W=read(a/"W-ref.bin",sz),E=read(a/"E-ref.bin",sz);std::vector<float>ref(sz);
 for(int y=0;y<n;y++)for(int x=0;x<n;x++){size_t i=size_t(y)*n+x;float cs=C[size_t(std::min(y+1,n-1))*n+x],ce=C[size_t(y)*n+std::min(x+1,n-1)];
 float d=C[i]*N[i]+cs*S[i]+C[i]*W[i]+ce*E[i];ref[i]=float(double(J[i])+0.25*double(0.5f)*double(d));}
 for(auto name:{"J.bin","C-ref.bin","N-ref.bin","S-ref.bin","W-ref.bin","E-ref.bin"})fs::copy_file(a/name,b/name,fs::copy_options::overwrite_existing);
 std::ofstream f(b/"J-ref.bin",std::ios::binary);f.write(reinterpret_cast<char*>(ref.data()),sz*4);f.close();
 std::ofstream cfg(b/"input.txt");cfg<<"kernel srad_cuda_2\ngrid "<<n/16<<" "<<n/16<<" 1\nblock 16 16 1\nbuffer J J.bin f32 J-ref.bin 3e-05 3e-05\n";
 for(auto name:{"C","N","S","W","E"})cfg<<"buffer "<<name<<" "<<name<<"-ref.bin readonly - 0 0\n";
 cfg<<"arg ptr E\narg ptr W\narg ptr N\narg ptr S\narg ptr J\narg ptr C\n";
 cfg<<"arg hex "<<(n==256?"00010000":"00040000")<<"\narg hex "<<(n==256?"00010000":"00040000")<<"\narg hex 0000003f\narg hex cdcccc3d\n";
 }
}
