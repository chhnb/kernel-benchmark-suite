#pragma once
#include "options.hpp"
#ifdef BENCH_HIP
#include <hip/hip_runtime.h>
using Module=hipModule_t;using Function=hipFunction_t;using Stream=hipStream_t;using Event=hipEvent_t;using Graph=hipGraph_t;using GraphExec=hipGraphExec_t;using Ptr=hipDeviceptr_t;
inline void ck(hipError_t e){if(e!=hipSuccess)throw std::runtime_error(hipGetErrorString(e));}
inline void init(){ck(hipInit(0));ck(hipSetDevice(0));}
inline void load(Module*m,const char*p){ck(hipModuleLoad(m,p));}
inline void function(Function*f,Module m,const char*n){ck(hipModuleGetFunction(f,m,n));}
inline void unload(Module m){ck(hipModuleUnload(m));}
inline Ptr alloc(size_t n){void*p;ck(hipMalloc(&p,n));return (Ptr)p;}
inline void release(Ptr p){ck(hipFree((void*)p));}
inline void upload(Ptr p,const void*h,size_t n){ck(hipMemcpyHtoD(p,const_cast<void*>(h),n));}
inline void download(void*h,Ptr p,size_t n){ck(hipMemcpyDtoH(h,p,n));}
inline void launch(Function f,unsigned*g,unsigned*b,Stream s,void**a){ck(hipModuleLaunchKernel(f,g[0],g[1],g[2],b[0],b[1],b[2],0,s,a,nullptr));}
inline void streamCreate(Stream*s){ck(hipStreamCreateWithFlags(s,hipStreamNonBlocking));}
inline void eventCreate(Event*e){ck(hipEventCreate(e));}
inline void record(Event e,Stream s){ck(hipEventRecord(e,s));}
inline float elapsed(Event a,Event b){ck(hipEventSynchronize(b));float ms;ck(hipEventElapsedTime(&ms,a,b));return ms;}
inline void beginCapture(Stream s){ck(hipStreamBeginCapture(s,hipStreamCaptureModeGlobal));}
inline void endCapture(Stream s,Graph*g,GraphExec*x){ck(hipStreamEndCapture(s,g));ck(hipGraphInstantiate(x,*g,nullptr,nullptr,0));}
inline void graphLaunch(GraphExec x,Stream s){ck(hipGraphLaunch(x,s));}
inline void graphFree(GraphExec x,Graph g){ck(hipGraphExecDestroy(x));ck(hipGraphDestroy(g));}
inline void eventFree(Event e){ck(hipEventDestroy(e));}
inline void streamFree(Stream s){ck(hipStreamDestroy(s));}
inline void finish(){}
#else
#include <cuda.h>
using Module=CUmodule;using Function=CUfunction;using Stream=CUstream;using Event=CUevent;using Graph=CUgraph;using GraphExec=CUgraphExec;using Ptr=CUdeviceptr;
inline CUcontext context;
inline void ck(CUresult e){if(e!=CUDA_SUCCESS){const char*s=nullptr;cuGetErrorString(e,&s);throw std::runtime_error(s?s:"CUDA error");}}
inline void init(){ck(cuInit(0));CUdevice d;ck(cuDeviceGet(&d,0));ck(cuCtxCreate(&context,0,d));}
inline void load(Module*m,const char*p){ck(cuModuleLoad(m,p));}
inline void function(Function*f,Module m,const char*n){ck(cuModuleGetFunction(f,m,n));}
inline void unload(Module m){ck(cuModuleUnload(m));}
inline Ptr alloc(size_t n){Ptr p;ck(cuMemAlloc(&p,n));return p;}
inline void release(Ptr p){ck(cuMemFree(p));}
inline void upload(Ptr p,const void*h,size_t n){ck(cuMemcpyHtoD(p,h,n));ck(cuCtxSynchronize());} // Complete default-stream upload before a nonblocking kernel stream.
inline void download(void*h,Ptr p,size_t n){ck(cuMemcpyDtoH(h,p,n));}
inline void launch(Function f,unsigned*g,unsigned*b,Stream s,void**a){ck(cuLaunchKernel(f,g[0],g[1],g[2],b[0],b[1],b[2],0,s,a,nullptr));}
inline void streamCreate(Stream*s){ck(cuStreamCreate(s,CU_STREAM_NON_BLOCKING));}
inline void eventCreate(Event*e){ck(cuEventCreate(e,0));}
inline void record(Event e,Stream s){ck(cuEventRecord(e,s));}
inline float elapsed(Event a,Event b){ck(cuEventSynchronize(b));float ms;ck(cuEventElapsedTime(&ms,a,b));return ms;}
inline void beginCapture(Stream s){ck(cuStreamBeginCapture(s,CU_STREAM_CAPTURE_MODE_GLOBAL));}
inline void endCapture(Stream s,Graph*g,GraphExec*x){ck(cuStreamEndCapture(s,g));ck(cuGraphInstantiate(x,*g,0));}
inline void graphLaunch(GraphExec x,Stream s){ck(cuGraphLaunch(x,s));}
inline void graphFree(GraphExec x,Graph g){ck(cuGraphExecDestroy(x));ck(cuGraphDestroy(g));}
inline void eventFree(Event e){ck(cuEventDestroy(e));}
inline void streamFree(Stream s){ck(cuStreamDestroy(s));}
inline void finish(){ck(cuCtxDestroy(context));}
#endif
