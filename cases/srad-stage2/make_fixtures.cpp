#include <filesystem>
#include <fstream>
#include <vector>
#include <stdexcept>
#include <algorithm>
#include <string_view>

namespace fs=std::filesystem;
std::vector<float> read(fs::path p,size_t n){std::ifstream f(p,std::ios::binary);std::vector<float>x(n);if(!f.read(reinterpret_cast<char*>(x.data()),n*4))throw std::runtime_error(p.string());return x;}

static void makeReference(const fs::path &source, const fs::path &output, int n) {
  const size_t size = size_t(n) * n;
  const auto J = read(source / "J.bin", size);
  const auto C = read(source / "C-ref.bin", size);
  const auto N = read(source / "N-ref.bin", size);
  const auto S = read(source / "S-ref.bin", size);
  const auto W = read(source / "W-ref.bin", size);
  const auto E = read(source / "E-ref.bin", size);
  std::vector<float> reference(size);
  for (int y = 0; y < n; ++y)
    for (int x = 0; x < n; ++x) {
      const size_t i = size_t(y) * n + x;
      const float south = C[size_t(std::min(y + 1, n - 1)) * n + x];
      const float east = C[size_t(y) * n + std::min(x + 1, n - 1)];
      const float d = C[i] * N[i] + south * S[i] + C[i] * W[i] + east * E[i];
      reference[i] = float(double(J[i]) + 0.25 * double(0.5f) * double(d));
    }
  std::ofstream file(output / "J-ref.bin", std::ios::binary);
  file.write(reinterpret_cast<const char *>(reference.data()), size * sizeof(float));
  file.close();
  if (!file)
    throw std::runtime_error("could not write SRAD-stage2 reference");
}

int main(int argc,char**argv){
 if (argc != 3) return 2;
 if (std::string_view(argv[2]) == "--reference-only") {
   makeReference(argv[1], argv[1], 256);
   return 0;
 }
 fs::path source=argv[1],out=argv[2];
 for(int n:{256,1024}){auto a=source/std::to_string(n),b=out/std::to_string(n);fs::create_directories(b);
  makeReference(a,b,n);
 for(auto name:{"J.bin","C-ref.bin","N-ref.bin","S-ref.bin","W-ref.bin","E-ref.bin"})fs::copy_file(a/name,b/name,fs::copy_options::overwrite_existing);
 std::ofstream cfg(b/"input.txt");cfg<<"kernel srad_cuda_2\ngrid "<<n/16<<" "<<n/16<<" 1\nblock 16 16 1\nbuffer J J.bin f32 J-ref.bin 3e-05 3e-05\n";
 for(auto name:{"C","N","S","W","E"})cfg<<"buffer "<<name<<" "<<name<<"-ref.bin readonly - 0 0\n";
 cfg<<"arg ptr E\narg ptr W\narg ptr N\narg ptr S\narg ptr J\narg ptr C\n";
 cfg<<"arg hex "<<(n==256?"00010000":"00040000")<<"\narg hex "<<(n==256?"00010000":"00040000")<<"\narg hex 0000003f\narg hex cdcccc3d\n";
 }
}
