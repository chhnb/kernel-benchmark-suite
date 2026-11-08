cmake_minimum_required(VERSION 3.20)
project(kernel_benchmark_suite LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
add_executable(bench_cuda runner/replay.cpp)
target_include_directories(bench_cuda PRIVATE /usr/local/cuda/include)
target_link_directories(bench_cuda PRIVATE /usr/local/cuda/lib64/stubs)
target_link_libraries(bench_cuda PRIVATE cuda)
add_executable(bench_hip runner/replay.cpp)
target_compile_definitions(bench_hip PRIVATE BENCH_HIP __HIP_PLATFORM_AMD__)
target_include_directories(bench_hip PRIVATE /opt/rocm/include)
target_link_directories(bench_hip PRIVATE /opt/rocm/lib)
target_link_libraries(bench_hip PRIVATE amdhip64)
set_target_properties(bench_hip PROPERTIES BUILD_RPATH /opt/rocm/lib)
function(hip_runner target source)
 add_custom_command(OUTPUT ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${target}
 COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
 COMMAND /opt/rocm/bin/hipcc -O2 -std=c++17 --offload-arch=gfx906 -x hip ${CMAKE_SOURCE_DIR}/${source} -o ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${target}
 DEPENDS ${source} runner/options.hpp ${ARGN} VERBATIM)
 add_custom_target(${target} ALL DEPENDS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${target})
endfunction()
hip_runner(bench_hypersonic cases/hypersonic/harness/tau_hypersonic_cuda_tests.cu cases/hypersonic/validate.hpp cases/hypersonic/harness/tau_hypersonic_cuda.cu)
hip_runner(bench_reentry cases/reentry/harness/tau_reentry_cuda_tests.cu cases/reentry/validate.hpp cases/reentry/harness/tau_reentry_cuda.cu)
hip_runner(bench_tigre cases/tigre-siddon/harness/bench.hip cases/tigre-siddon/harness/geometry.inc cases/tigre-siddon/harness/types_TIGRE.hpp)
set(HIPIMS ${CMAKE_SOURCE_DIR}/cases/hipims/source/lib)
add_custom_command(OUTPUT ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/bench_hipims
 COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
 COMMAND /usr/local/cuda/bin/nvcc -std=c++17 -O3 -arch=sm_70 --fmad=false
 -I${HIPIMS}/include/primitives -I${HIPIMS}/include/mesh -I${HIPIMS}/include/operators -I${HIPIMS}/include/utilities -I${HIPIMS}/src/operators
 ${CMAKE_SOURCE_DIR}/cases/hipims/harness/bench.cu -L/usr/local/cuda/lib64/stubs -lcuda -o ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/bench_hipims
 DEPENDS cases/hipims/harness/bench.cu cases/hipims/source/kernel.cu cases/hipims/source/kernel-body.inc runner/options.hpp VERBATIM)
add_custom_target(bench_hipims ALL DEPENDS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/bench_hipims)

hip_runner(bench_tpacf cases/tpacf/harness/bench.hip)

hip_runner(bench_ced cases/ced/harness/bench.hip)
