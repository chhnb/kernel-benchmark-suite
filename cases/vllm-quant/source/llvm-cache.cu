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

#include "cache-software.cuh"
