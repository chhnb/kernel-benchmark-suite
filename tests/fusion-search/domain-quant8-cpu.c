#include <stdint.h>
#include <stdio.h>
#include <string.h>
extern float quant8(float);
int main(){uint32_t state=1;for(unsigned i=0;i<100000;i++){state=1664525u*state+1013904223u;float x;memcpy(&x,&state,4);float y=quant8(x);uint32_t bits;memcpy(&bits,&y,4);printf("%08x\n",bits);}float t[]={0,.25,.75,1.25,1.75,2.5,3.5,5,6};for(int i=0;i<9;i++)for(int s=-1;s<=1;s+=2){float y=quant8(t[i]*s);uint32_t bits;memcpy(&bits,&y,4);printf("%08x\n",bits);}return 0;}
