#define __device__ __attribute__((device))
#define __global__ __attribute__((global))
#define __forceinline__ __attribute__((always_inline)) inline
extern "C" __device__ int __nvvm_read_ptx_sreg_tid_x();
extern "C" __device__ int __nvvm_read_ptx_sreg_ctaid_x();
extern "C" __device__ int __nvvm_read_ptx_sreg_ntid_x();
struct dim1{int x;};
#define threadIdx dim1{__nvvm_read_ptx_sreg_tid_x()}
#define blockIdx dim1{__nvvm_read_ptx_sreg_ctaid_x()}
#define blockDim dim1{__nvvm_read_ptx_sreg_ntid_x()}
extern "C" __device__ float __nv_fabsf(float),__nv_copysignf(float,float),__nv_fmaxf(float,float),__nv_ldexpf(float,int);
#define fabsf __nv_fabsf
#define copysignf __nv_copysignf
#define fmaxf __nv_fmaxf
#define ldexpf __nv_ldexpf
__device__ inline float __uint_as_float(unsigned u){union{unsigned u;float f;}v;v.u=u;return v.f;}
__device__ inline unsigned __float_as_uint(float f){union{unsigned u;float f;}v;v.f=f;return v.u;}

extern "C" __device__ __forceinline__ void quant_decide(float x,float,float,float* out){
 float a=fabsf(x);float v;
 if(a<=.25f)v=0;else if(a<.75f)v=.5f;else if(a<=1.25f)v=1;else if(a<1.75f)v=1.5f;else if(a<=2.5f)v=2;else if(a<3.5f)v=3;else if(a<=5)v=4;else v=6;
 *out=copysignf(v,x);
}
// CUDA sm_70 software experimental port of vLLM 5d55ef1590c92213e3893dc8e8712f7f2e0bc508.
// SPDX-License-Identifier: Apache-2.0
// Finite BF16 inputs; positive finite global scales; 16 elements/thread.
// Software E4M3/E2M1; precise reciprocal replaces NVIDIA rcp.approx.ftz.
extern "C" __device__ void quant_decide(float,float,float,float*);
__device__ __forceinline__ float q(float x){float out;quant_decide(x,5.f,3.f,&out);return out;}
__device__ __forceinline__ float dec8(int c){int e=c>>3,m=c&7;return e?ldexpf(1.f+float(m)*.125f,e-7):float(m)*.001953125f;}
__device__ __forceinline__ unsigned char enc8(float x){
 if(x>=448.f)return 126;int lo=0,hi=126;
 for(int i=0;i<7;i++){int m=(lo+hi)/2;if(dec8(m)<x)lo=m+1;else hi=m;}
 if(lo==0)return 0;float a=x-dec8(lo-1),b=dec8(lo)-x;return a<b ? lo-1 : (b<a ? lo : ((lo&1)?lo-1:lo));
}
__device__ __forceinline__ float bf(unsigned short u){return __uint_as_float(unsigned(u)<<16);}
__device__ __forceinline__ unsigned pack4(float x){float a=fabsf(x);unsigned c=a<=.25f?0:a<.75f?1:a<=1.25f?2:a<1.75f?3:a<=2.5f?4:a<3.5f?5:a<=5.f?6:7;return c|((__float_as_uint(x)>>28)&8);}
extern "C" __global__ void cache_eval(const unsigned short* key,const unsigned short* value,const long* slots,unsigned char* kd,unsigned char* vd,unsigned char* ks,unsigned char* vs,int heads,int dim,int page,int stride,float kg,float vg){
 int token=blockIdx.x;long slot=slots[token];if(slot<0)return;long block=slot/page;int t=slot%page,sd=dim/16,groups=heads*sd;
 for(int kv=0;kv<2;kv++){
  const unsigned short* src=(kv?value:key)+long(token)*stride;unsigned char* data=kv?vd:kd;unsigned char* scales=kv?vs:ks;float global=kv?vg:kg;
  for(int g=threadIdx.x;g<groups;g+=blockDim.x){
   int h=g/sd,s=g%sd;float v[16],mx=0;
   #pragma unroll
   for(int i=0;i<16;i++){v[i]=bf(src[h*dim+s*16+i]);mx=fmaxf(mx,fabsf(v[i]));}
   unsigned char code[2];float os[2],err[2];
   #pragma unroll
   for(int c=0;c<2;c++){
    float den=c?4.f:6.f;code[c]=enc8(global*(mx*(1.f/den)));float sf=dec8(code[c]);os[c]=sf!=0?1.f/(sf*(1.f/global)):0;float ds=os[c]!=0?1.f/os[c]:0;float e=0;
    #pragma unroll
    for(int i=0;i<16;i+=2){if(os[c]==0){e+=v[i]*v[i]+v[i+1]*v[i+1];}else{float dx=q(v[i]*os[c])*ds-v[i],dy=q(v[i+1]*os[c])*ds-v[i+1];e+=dx*dx+dy*dy;}}
    err[c]=e;
   }
   int c=err[1]<err[0];long off=((block*heads+h)*page+t)*(dim/2)+s*8;
   #pragma unroll
   for(int i=0;i<8;i++)data[off+i]=pack4(v[2*i]*os[c])|(pack4(v[2*i+1]*os[c])<<4);
   int st=t,ss=s;if(kv){st=(t/4)*4+s/(sd/4);ss=(s%(sd/4))*4+t%4;}
   scales[((block*heads+h)*page+st)*sd+ss]=code[c];
  }
 }
}
