#include <initializer_list>
#include <cstring>
#include <cmath>
#include <climits>
#include <cstdio>
extern "C" float baseline(int,float,bool);
extern "C" float candidate(int,float,bool);
int main(){int count=0;for(int e:{INT_MIN,-11,-10,-9,-1,0,1,10,INT_MAX})for(float x:{-100.f,-0.f,0.f,1.f,10.f})for(bool poison:{false,true}){
 if(poison&&e<=0)continue;float a=baseline(e,x,poison),b=candidate(e,x,poison);
 if(std::memcmp(&a,&b,sizeof(float))){std::printf("mismatch e=%d x=%g\n",e,x);return 1;}++count;
}std::printf("%d complete output checks including masked poison passed\n",count);}
