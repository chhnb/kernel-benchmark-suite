#include <cstdio>
extern "C" int before(int,int,int);
extern "C" int after(int,int,int);
int main(){for(int x=1;x<=100;++x)for(int a=0;a<2;++a)for(int b=0;b<2;++b)if(before(x,a,b)!=after(x,a,b)){std::fprintf(stderr,"mismatch %d %d %d\n",x,a,b);return 1;}return 0;}
