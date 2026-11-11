#include <boost/math/distributions/mapairy.hpp>
#include <fstream>
#include <iostream>
#include <cmath>
int main(int argc,char**argv){if(argc!=3)return 2;std::ifstream in(argv[1],std::ios::binary);std::ofstream out(argv[2],std::ios::binary);if(!in||!out)return 3;double x;size_t n=0;while(in.read((char*)&x,8)){double y=(double)boost::math::quantile(boost::math::mapairy_distribution<long double>(),(long double)x);if(!std::isfinite(y))return 4;out.write((char*)&y,8);++n;}if(!in.eof()||in.gcount()!=0||!out)return 5;std::cout<<n<<" reference values\n";}
