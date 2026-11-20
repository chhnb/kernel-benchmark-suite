
#include <hip/hip_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <algorithm>
#include <vector>
#define CK(x) do {auto rc=(x); if(rc!=hipSuccess){fprintf(stderr,"%s: %s\n",#x,hipGetErrorString(rc));exit(1);}}while(0)
constexpr unsigned Blocks=768, Lanes=64, Rows=8192, Words=4096;

extern "C" __global__ void bench_0_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("s_waitcnt vmcnt(0)" :: "v"(val),"v"(p) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_0_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("global_load_dword v0, %1, off offset:0\nglobal_load_dword v1, %1, off offset:256\nglobal_load_dword v2, %1, off offset:512\nglobal_load_dword v3, %1, off offset:768\nglobal_load_dword v4, %1, off offset:1024\nglobal_load_dword v5, %1, off offset:1280\nglobal_load_dword v6, %1, off offset:1536\nglobal_load_dword v7, %1, off offset:1792\ns_waitcnt vmcnt(0)\nglobal_load_dword v8, %1, off offset:2048\nglobal_load_dword v9, %1, off offset:2304\nglobal_load_dword v10, %1, off offset:2560\nglobal_load_dword v11, %1, off offset:2816\nglobal_load_dword v12, %1, off offset:3072\nglobal_load_dword v13, %1, off offset:3328\nglobal_load_dword v14, %1, off offset:3584\nglobal_load_dword v15, %1, off offset:3840\ns_waitcnt vmcnt(0)\ns_waitcnt vmcnt(0)" :: "v"(val),"v"(p) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_1_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane*16;
   asm volatile("s_waitcnt vmcnt(0)" :: "v"(val),"v"(p) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_1_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane*16;
   asm volatile("global_load_dword v0, %1, off offset:0\nglobal_load_dword v1, %1, off offset:4\nglobal_load_dword v2, %1, off offset:8\nglobal_load_dword v3, %1, off offset:12\nglobal_load_dword v4, %1, off offset:16\nglobal_load_dword v5, %1, off offset:20\nglobal_load_dword v6, %1, off offset:24\nglobal_load_dword v7, %1, off offset:28\ns_waitcnt vmcnt(0)\nglobal_load_dword v8, %1, off offset:32\nglobal_load_dword v9, %1, off offset:36\nglobal_load_dword v10, %1, off offset:40\nglobal_load_dword v11, %1, off offset:44\nglobal_load_dword v12, %1, off offset:48\nglobal_load_dword v13, %1, off offset:52\nglobal_load_dword v14, %1, off offset:56\nglobal_load_dword v15, %1, off offset:60\ns_waitcnt vmcnt(0)\ns_waitcnt vmcnt(0)" :: "v"(val),"v"(p) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_2_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("s_waitcnt vmcnt(0)" :: "v"(val),"v"(p) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_2_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("global_store_dword %1, %0, off offset:0\nglobal_store_dword %1, %0, off offset:256\nglobal_store_dword %1, %0, off offset:512\nglobal_store_dword %1, %0, off offset:768\nglobal_store_dword %1, %0, off offset:1024\nglobal_store_dword %1, %0, off offset:1280\nglobal_store_dword %1, %0, off offset:1536\nglobal_store_dword %1, %0, off offset:1792\ns_waitcnt vmcnt(0)\nglobal_store_dword %1, %0, off offset:2048\nglobal_store_dword %1, %0, off offset:2304\nglobal_store_dword %1, %0, off offset:2560\nglobal_store_dword %1, %0, off offset:2816\nglobal_store_dword %1, %0, off offset:3072\nglobal_store_dword %1, %0, off offset:3328\nglobal_store_dword %1, %0, off offset:3584\nglobal_store_dword %1, %0, off offset:3840\ns_waitcnt vmcnt(0)\ns_waitcnt vmcnt(0)" :: "v"(val),"v"(p) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_3_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];
 for(unsigned x=lane;x<16*Lanes;x+=Lanes)local_data[x]=val; __syncthreads();
 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("s_waitcnt lgkmcnt(0)" :: "v"(val),"v"(val),"v"(local) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_3_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];
 for(unsigned x=lane;x<16*Lanes;x+=Lanes)local_data[x]=val; __syncthreads();
 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("ds_read_b32 v0, %2 offset:0\nds_read_b32 v1, %2 offset:256\nds_read_b32 v2, %2 offset:512\nds_read_b32 v3, %2 offset:768\nds_read_b32 v4, %2 offset:1024\nds_read_b32 v5, %2 offset:1280\nds_read_b32 v6, %2 offset:1536\nds_read_b32 v7, %2 offset:1792\nds_read_b32 v8, %2 offset:2048\nds_read_b32 v9, %2 offset:2304\nds_read_b32 v10, %2 offset:2560\nds_read_b32 v11, %2 offset:2816\nds_read_b32 v12, %2 offset:3072\nds_read_b32 v13, %2 offset:3328\nds_read_b32 v14, %2 offset:3584\nds_read_b32 v15, %2 offset:3840\ns_waitcnt lgkmcnt(0)" :: "v"(val),"v"(val),"v"(local) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_4_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];
 for(unsigned x=lane;x<16*Lanes;x+=Lanes)local_data[x]=val; __syncthreads();
 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("s_waitcnt lgkmcnt(0)" :: "v"(val),"v"(val),"v"(local) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_4_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];
 for(unsigned x=lane;x<16*Lanes;x+=Lanes)local_data[x]=val; __syncthreads();
 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("ds_write_b32 %2, %0 offset:0\nds_write_b32 %2, %0 offset:256\nds_write_b32 %2, %0 offset:512\nds_write_b32 %2, %0 offset:768\nds_write_b32 %2, %0 offset:1024\nds_write_b32 %2, %0 offset:1280\nds_write_b32 %2, %0 offset:1536\nds_write_b32 %2, %0 offset:1792\nds_write_b32 %2, %0 offset:2048\nds_write_b32 %2, %0 offset:2304\nds_write_b32 %2, %0 offset:2560\nds_write_b32 %2, %0 offset:2816\nds_write_b32 %2, %0 offset:3072\nds_write_b32 %2, %0 offset:3328\nds_write_b32 %2, %0 offset:3584\nds_write_b32 %2, %0 offset:3840\ns_waitcnt lgkmcnt(0)" :: "v"(val),"v"(val),"v"(local) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_5_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("v_cmp_ne_u32_e32 vcc, 0, %0" :: "v"(val) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_5_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("v_cmp_ne_u32_e32 vcc, 0, %0\nv_cndmask_b32_e32 v0, 0, %0, vcc\nv_cndmask_b32_e32 v1, 0, %0, vcc\nv_cndmask_b32_e32 v2, 0, %0, vcc\nv_cndmask_b32_e32 v3, 0, %0, vcc\nv_cndmask_b32_e32 v4, 0, %0, vcc\nv_cndmask_b32_e32 v5, 0, %0, vcc\nv_cndmask_b32_e32 v6, 0, %0, vcc\nv_cndmask_b32_e32 v7, 0, %0, vcc\nv_cndmask_b32_e32 v8, 0, %0, vcc\nv_cndmask_b32_e32 v9, 0, %0, vcc\nv_cndmask_b32_e32 v10, 0, %0, vcc\nv_cndmask_b32_e32 v11, 0, %0, vcc\nv_cndmask_b32_e32 v12, 0, %0, vcc\nv_cndmask_b32_e32 v13, 0, %0, vcc\nv_cndmask_b32_e32 v14, 0, %0, vcc\nv_cndmask_b32_e32 v15, 0, %0, vcc" :: "v"(val) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_6_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("v_cmp_ne_u32_e32 vcc, 0, %0" :: "v"(val) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_6_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("v_cmp_ne_u32_e32 vcc, 0, %0\nv_cndmask_b32_e32 v0, 0, %0, vcc\nv_cndmask_b32_e32 v1, 1, %0, vcc\nv_cndmask_b32_e32 v2, 0, %0, vcc\nv_cndmask_b32_e32 v3, 1, %0, vcc\nv_cndmask_b32_e32 v4, 0, %0, vcc\nv_cndmask_b32_e32 v5, 1, %0, vcc\nv_cndmask_b32_e32 v6, 0, %0, vcc\nv_cndmask_b32_e32 v7, 1, %0, vcc\nv_cndmask_b32_e32 v8, 0, %0, vcc\nv_cndmask_b32_e32 v9, 1, %0, vcc\nv_cndmask_b32_e32 v10, 0, %0, vcc\nv_cndmask_b32_e32 v11, 1, %0, vcc\nv_cndmask_b32_e32 v12, 0, %0, vcc\nv_cndmask_b32_e32 v13, 1, %0, vcc\nv_cndmask_b32_e32 v14, 0, %0, vcc\nv_cndmask_b32_e32 v15, 1, %0, vcc\nv_cndmask_b32_e32 v16, 0, %0, vcc\nv_cndmask_b32_e32 v17, 1, %0, vcc\nv_cndmask_b32_e32 v18, 0, %0, vcc\nv_cndmask_b32_e32 v19, 1, %0, vcc\nv_cndmask_b32_e32 v20, 0, %0, vcc\nv_cndmask_b32_e32 v21, 1, %0, vcc\nv_cndmask_b32_e32 v22, 0, %0, vcc\nv_cndmask_b32_e32 v23, 1, %0, vcc\nv_cndmask_b32_e32 v24, 0, %0, vcc\nv_cndmask_b32_e32 v25, 1, %0, vcc\nv_cndmask_b32_e32 v26, 0, %0, vcc\nv_cndmask_b32_e32 v27, 1, %0, vcc\nv_cndmask_b32_e32 v28, 0, %0, vcc\nv_cndmask_b32_e32 v29, 1, %0, vcc\nv_cndmask_b32_e32 v30, 0, %0, vcc\nv_cndmask_b32_e32 v31, 1, %0, vcc" :: "v"(val) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_7_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("" :: "v"(val) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_7_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("v_add_u32_e32 v0, 1, %0\nv_add_u32_e32 v1, 1, %0\nv_add_u32_e32 v2, 1, %0\nv_add_u32_e32 v3, 1, %0\nv_add_u32_e32 v4, 1, %0\nv_add_u32_e32 v5, 1, %0\nv_add_u32_e32 v6, 1, %0\nv_add_u32_e32 v7, 1, %0\nv_add_u32_e32 v8, 1, %0\nv_add_u32_e32 v9, 1, %0\nv_add_u32_e32 v10, 1, %0\nv_add_u32_e32 v11, 1, %0\nv_add_u32_e32 v12, 1, %0\nv_add_u32_e32 v13, 1, %0\nv_add_u32_e32 v14, 1, %0\nv_add_u32_e32 v15, 1, %0" :: "v"(val) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_8_0(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("s_waitcnt lgkmcnt(0)" :: "v"(val),"v"(val),"v"(val),"s"(row) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory","s48","s49","s50","s51","s52","s53","s54","s55","s56","s57","s58","s59","s60","s61","s62","s63");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

extern "C" __global__ void bench_8_16(unsigned *buffer,unsigned *sink,unsigned count){
 unsigned lane=threadIdx.x;
 unsigned val=lane+blockIdx.x;
 __shared__ unsigned local_data[16*Lanes];

 unsigned local=(unsigned)(uintptr_t)(local_data+lane);
 #pragma clang loop unroll(disable)
 for(unsigned j=0;j<count;++j){
   auto row=buffer+(((blockIdx.x+j*Blocks)&(Rows-1))*Words);
   auto p=row+lane;
   asm volatile("s_load_dword s48, %3, 0\ns_load_dword s49, %3, 256\ns_load_dword s50, %3, 512\ns_load_dword s51, %3, 768\ns_load_dword s52, %3, 1024\ns_load_dword s53, %3, 1280\ns_load_dword s54, %3, 1536\ns_load_dword s55, %3, 1792\ns_load_dword s56, %3, 2048\ns_load_dword s57, %3, 2304\ns_load_dword s58, %3, 2560\ns_load_dword s59, %3, 2816\ns_load_dword s60, %3, 3072\ns_load_dword s61, %3, 3328\ns_load_dword s62, %3, 3584\ns_load_dword s63, %3, 3840\ns_waitcnt lgkmcnt(0)" :: "v"(val),"v"(val),"v"(val),"s"(row) : "v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15","v16","v17","v18","v19","v20","v21","v22","v23","v24","v25","v26","v27","v28","v29","v30","v31","vcc","memory","s48","s49","s50","s51","s52","s53","s54","s55","s56","s57","s58","s59","s60","s61","s62","s63");
 }
 if(lane==0) sink[blockIdx.x]=val;
}

struct Config{const char *kind; unsigned n;const void *fn;};
Config config[]={{"global_coalesced",0,(const void*)bench_0_0},{"global_coalesced",16,(const void*)bench_0_16},{"global_strided",0,(const void*)bench_1_0},{"global_strided",16,(const void*)bench_1_16},{"global_store",0,(const void*)bench_2_0},{"global_store",16,(const void*)bench_2_16},{"lds_load",0,(const void*)bench_3_0},{"lds_load",16,(const void*)bench_3_16},{"lds_store",0,(const void*)bench_4_0},{"lds_store",16,(const void*)bench_4_16},{"select32",0,(const void*)bench_5_0},{"select32",16,(const void*)bench_5_16},{"select64",0,(const void*)bench_6_0},{"select64",16,(const void*)bench_6_16},{"add",0,(const void*)bench_7_0},{"add",16,(const void*)bench_7_16},{"scalar_load",0,(const void*)bench_8_0},{"scalar_load",16,(const void*)bench_8_16}};
int main(){
 unsigned *in,*out;
 CK(hipMalloc(&in,Rows*Words*sizeof(unsigned)));CK(hipMalloc(&out,Blocks*sizeof(unsigned)));
 CK(hipMemset(in,1,Rows*Words*sizeof(unsigned)));
 hipEvent_t start,end;CK(hipEventCreate(&start));CK(hipEventCreate(&end));
 puts("kind,round,phase,tag,n,iter,blocks,ms");
 std::vector<unsigned> proof(Blocks);
 auto time=[&](const Config& c,unsigned iter){
   CK(hipEventRecord(start));
   void* args[]={&in,&out,&iter};
   CK(hipLaunchKernel(c.fn,dim3(Blocks),dim3(Lanes),args,0,0));
   CK(hipEventRecord(end));CK(hipEventSynchronize(end));float ms;CK(hipEventElapsedTime(&ms,start,end));return ms;
 };
 auto role=[&](const Config& c,int i,const char *phase,int tag,unsigned iter){
   time(c,iter);
   float t[5];
   for(auto &x:t)x=time(c,iter);
   std::sort(t,t+5);
   CK(hipMemcpy(proof.data(),out,Blocks*sizeof(unsigned),hipMemcpyDeviceToHost));
   for(unsigned b=0;b<Blocks;b++)if(proof[b]!=b){fprintf(stderr,"sink mismatch\n");exit(4);}
   printf("%s,%d,%s,%d,%u,%u,%u,%.9f\n",c.kind,i,phase,tag,c.n,iter,Blocks,t[2]);
   fflush(stdout);return t[2];
 };
 for(unsigned k=0;k<sizeof(config)/sizeof(config[0]);k+=2){
   const auto &lo=config[k],&hi=config[k+1];
   unsigned it=256;
   float t=time(hi,it); if(t<2)it=std::min(8192u,unsigned(512/t)+1);
   for(float warm=0;warm<200;)warm+=time(hi,it);
   for(int i=0;i<12;i++)for(int j=0;j<2;j++)role(hi,i,"aa",i%2?1-j:j,it);
   for(int i=0;i<12;i++)for(int j=0;j<2;j++){
    int which=i%2?1-j:j;role(which?hi:lo,i,"sample",which,it);
   }
 }
}
