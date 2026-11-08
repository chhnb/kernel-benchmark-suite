# SRAD stage 2
Original full srad_cuda_2 from the DARM artifacts source, with only the HIP include, BLOCK_SIZE=16 and extern C wrapper added. The original complete source and SHA256 are retained.

Four source branches select south/east diffusion coefficients for southeast corner, east edge, south edge and interior. This is distinct from cases/srad (srad_cuda_1).

Inputs: existing fixed 256/1024 random SRAD images plus the independent first-stage CPU oracle's C/N/S/W/E arrays. lambda=0.5; q0sqr=0.1 (unused by this kernel). The C++ fixture generator computes the second-stage global-coordinate clamped-neighbor update. No simulated end-to-end timing is claimed.

bench_hip resets all input buffers before every launch; only J is writable. Complete J is compared to the CPU oracle with abs3e-5+rel3e-5, the other five buffers are checked byte-identical, and all guards checked. Timing is C++ HIP event.

LLVM12 frontend O3 is followed by the same always-inline/O3/internalize(public=srad_cuda_2)/globaldce preparation used by stage1. This discards unreachable device-library definitions. The initial unprepared v1 backend failure in unrelated __ockl_printf_append_string_n is preserved in the experiment logs; v2 is the tested pipeline.

Experiment: /home/chh/kernel-benchmark-suite/experiments/srad-stage2-greedy-20261109-v2/
Source/fixture build instructions: prepare.py and build-plan.json there.
fixture-manifest.json records input hashes.
