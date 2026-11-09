#include <initializer_list>

#include <cstdint>
#include <cstdio>
extern "C" int32_t base(bool,bool,bool,int32_t,int32_t*,int32_t*);
extern "C" int32_t multi(bool,bool,bool,int32_t,int32_t*,int32_t*);
int main(){unsigned count=0;for(bool l:{false,true})for(bool r:{false,true})for(bool take:{false,true})for(int x=-40;x<=40;++x){
 if(take&&!x)continue;
 int32_t input=x*13,optional=x*17;
 int32_t *p=(l||r)?&input:nullptr,*q=take?&optional:nullptr;
 auto a=base(l,r,take,x,p,q),b=multi(l,r,take,x,p,q);
 if(a!=b){std::printf("mismatch %d %d %d %d %d %d\n",l,r,take,x,a,b);return 1;}++count;
 }std::printf("PASS %u comparisons including inactive null pointers and zero divisors\n",count);}
