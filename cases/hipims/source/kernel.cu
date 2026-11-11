#include <cuda_runtime.h>
#include "mesh_fv_entities.h"
#include "riemann.h"
namespace GC { namespace fv {
#include "cuda_riemann_solvers.cuh"
#include "kernel-body.inc"
}}
