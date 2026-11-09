#include <cstdint>
#include <cstdio>
extern "C" int baseline(int,int,int*,int*);
extern "C" int fusion01(int,int,int*,int*);
extern "C" int fusion12(int,int,int*,int*);
int main(){unsigned count=0;for(int which=-1;which<5;++which)for(int x=-1000;x<=1000;++x){
 int data=x*13+17;int *p=(which!=0&&(x<=0||which!=1&&which!=2))?nullptr:&data;
 int m0=0,m1=0,m2=0;int a=baseline(which,x,p,&m0),b=fusion01(which,x,p,&m1),c=fusion12(which,x,p,&m2);
 if(a!=b||a!=c||m0!=m1||m0!=m2){std::fprintf(stderr,"mismatch %d %d\n",which,x);return 1;}++count;
}std::printf("%u input comparisons passed (two fused variants; guarded null inputs and early-exit stores)\n",count);}
