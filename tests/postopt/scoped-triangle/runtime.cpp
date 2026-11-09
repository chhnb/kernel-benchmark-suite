#include <cstdio>
using Fn=int(bool,int,int,int*);
extern "C" Fn safe_base,safe_old,safe_new,divide_base,divide_old,divide_new,load_base,load_old,load_new;
int main(){Fn* cases[3][3]={{safe_base,safe_old,safe_new},{divide_base,divide_old,divide_new},{load_base,load_old,load_new}};unsigned count=0;
 for(int kind=0;kind<3;++kind)for(int pick=0;pick<2;++pick)for(int x=-20;x<=20;++x)for(int y=-15;y<=15;++y){
  if(kind==1&&!pick&&x==0)continue;int value=x+y+31;int* ptr=pick?nullptr:&value;
  int a=cases[kind][0](pick,x,y,ptr),b=cases[kind][1](pick,x,y,ptr),c=cases[kind][2](pick,x,y,ptr);
  if(a!=b||a!=c){std::fprintf(stderr,"mismatch %d %d %d %d\n",kind,pick,x,y);return 1;}++count;
 }std::printf("PASS %u inputs: short scalar speculation, guarded division by zero and NULL loads\n",count);}
