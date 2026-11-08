from pathlib import Path
P=Path('/home/chh/kernel-benchmark-suite')
p=P/'cases/boost-saspoint5/source/kernel.cu';s=p.read_text().replace('#include <boost/math/distributions/saspoint5.hpp>','#define BOOST_MATH_CUDA_ENABLED __host__ __device__\n#define BOOST_MATH_HAS_GPU_SUPPORT\n#define BOOST_MATH_NO_EXCEPTIONS\n#include <boost/math/distributions/saspoint5.hpp>');p.write_text(s)
p=P/'experiments/saspoint5-cuda-v1/build.sh';p.write_text(p.read_text().replace('mkdir "$b"','mkdir -p "$b"'))
