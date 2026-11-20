#include <cuda_runtime.h>
#define BOOST_MATH_CUDA_ENABLED __host__ __device__
#define BOOST_MATH_HAS_GPU_SUPPORT
#define BOOST_MATH_NO_EXCEPTIONS
#include <boost/math/distributions/saspoint5.hpp>
extern "C" __global__ void evaluate(const double* input, double* output, int n) {
 int i=blockIdx.x*blockDim.x+threadIdx.x;
 if(i<n) output[i]=boost::math::pdf(boost::math::saspoint5_distribution<double>(),input[i]);
}
