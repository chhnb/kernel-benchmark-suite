#include <cuda_runtime.h>
#include "KernelFunc.cuh"

// Match GPU.cu's checked-in double-precision Euler profile.
template __global__ void ComputeX_kernel<double, EulerCons2DGrid>(
    EulerCons2DGrid<double>, EulerCons2DGrid<double>);
