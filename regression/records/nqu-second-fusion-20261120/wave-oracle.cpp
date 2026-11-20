#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>
struct Lane {
 std::array<uint32_t,10> mask,left,right,combined;
 int depth=-1;
 int solutions=0;
};
int main(int argc,char** argv) {
 if(argc!=3) return 1;
 std::ifstream input(argv[1],std::ios::binary);
 std::ifstream ref(argv[2],std::ios::binary);
 constexpr uint32_t total=(1u<<15)-1;
 std::array<uint64_t,4> grand{};
 for(int n:{24576,17392,5492}) {
  std::array<std::vector<uint32_t>,3> x;
  for(auto& a:x) {
   a.resize(n);
   if(!input.read(reinterpret_cast<char*>(a.data()),4*n)) return 2;
  }
  for(int w=0;w<384;w++) {
   std::array<Lane,64> lanes;
   for(int t=0;t<64 && 64*w+t<n;t++) {
    const auto p=64*w+t;
    auto& a=lanes[t];a.depth=0;
    a.mask[0]=x[0][p];a.left[0]=x[1][p];a.right[0]=x[2][p];
    a.combined[0]=a.mask[0]|a.left[0]|a.right[0];
   }
   for(;;) {
    unsigned active=0;
    bool any_available=false,any_descend=false;
    for(auto& a:lanes) {
     int depth=a.depth;
     if(depth<0)continue;
     active++;
     auto m=a.combined[depth], piece=(m+1)&~m;
     bool full=(m&total)==total;
     if(!full)a.combined[depth]|=piece;
     bool available=!full && (piece&total);
     any_available|=available;
     if(!available) {
      --a.depth;
     } else if(depth+1==10) {
      ++a.solutions;
      --a.depth;
     } else {
      any_descend=true;
      auto next=++a.depth;
      a.mask[next]=a.mask[depth]|piece;
      a.left[next]=(a.left[depth]|piece)<<1;
      a.right[next]=(a.right[depth]|piece)>>1;
      a.combined[next]=a.mask[next]|a.left[next]|a.right[next];
     }
    }
    if(!active)break;
    grand[!any_available?0:!any_descend?1:2]++;
    grand[3]+=active;
   }
   unsigned total_solutions=0,expected;
   for(auto& a:lanes)total_solutions+=a.solutions;
   if(!ref.read(reinterpret_cast<char*>(&expected),4)||total_solutions!=expected) {
    std::cerr<<"full per-wave reference mismatch "<<n<<" "<<w<<" "<<total_solutions<<" "<<expected<<"\n";
    return 3;
   }
  }
 }
 for(auto count:grand) std::cout <<count<<" ";
 std::cout<<"\n";
 return 0;
}
