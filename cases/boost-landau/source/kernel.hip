#include <hip/hip_runtime.h>
// The pinned Boost release annotates CUDA, but does not auto-enable HIP.
// Supply execution-space annotations without changing upstream math code.
#define BOOST_MATH_CUDA_ENABLED __host__ __device__
#define BOOST_MATH_HAS_GPU_SUPPORT
#define BOOST_MATH_NO_EXCEPTIONS
#include <boost/math/distributions/landau.hpp>
extern "C" __global__ void evaluate(const double* input, double* output, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n) output[i] = boost::math::quantile(boost::math::landau_distribution<double>(), input[i]);
}
