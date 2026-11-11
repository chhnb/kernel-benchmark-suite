#include <hip/hip_runtime.h>
#include "types_TIGRE.hpp"
#define PROJ_PER_BLOCK 9
#define IS_FOR_MATLAB_TIGRE 0
using cudaTextureObject_t=hipTextureObject_t;
__constant__ Point3D projParamsArrayDev[36];
// Positive-input round-down adapters; exact double products decide one-ULP correction.
__device__ __forceinline__ float tigre_rcp_rd(float x){
 if(x==0) return INFINITY;
 float r=(float)(1.0/(double)x);
 if(isinf(r))return 0x1.fffffep127f;
 if((double)r*(double)x>1.0)r=nextafterf(r,0.0f);
 return r;
}
__device__ __forceinline__ float tigre_sqrt_rd(float x){
 float r=(float)sqrt((double)x);
 if((double)r*(double)r>(double)x)r=nextafterf(r,0.0f);
 return r;
}
#define __frcp_rd tigre_rcp_rd
#define __fsqrt_rd tigre_sqrt_rd
#include "kernel.inc"
