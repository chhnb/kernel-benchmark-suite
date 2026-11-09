#include <cstring>
#include <initializer_list>
#include <cstdio>
using Fn=void(bool,int,int,int,double,double*,double*,double*,double*,double*,double*,double*,double*,double*,double*,double*,double*,double*);
extern "C" Fn baseline,gap_off,gap_on;
int main(){unsigned count=0;double data[12][32];for(int i=0;i<12;++i)for(int j=0;j<32;++j)data[i][j]=0.125*(i+1)*(j+1);
 for(bool left:{false,true})for(int idx=0;idx<32;++idx)for(double gamma:{1.01,1.4,2.0}){
 double *p[12];for(int i=0;i<12;++i)p[i]=(left?(i>=4):(i<4))?data[i]:nullptr;
 double out[3][10];for(auto &a:out)for(auto &x:a)x=-777;
 Fn* funcs[]={baseline,gap_off,gap_on};for(int k=0;k<3;++k)funcs[k](left,0,idx,idx,gamma,p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],p[11],out[k]);
 if(std::memcmp(out[0],out[1],sizeof out[0])||std::memcmp(out[0],out[2],sizeof out[0])){std::fprintf(stderr,"mismatch %d %d %g\n",left,idx,gamma);return 1;}++count;
 }std::printf("PASS %u inputs: positive grouping, guarded NULL loads, 8 live-outs and output guards, bitwise comparison\n",count);}
