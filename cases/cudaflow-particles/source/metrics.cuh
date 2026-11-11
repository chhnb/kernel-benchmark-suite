// On-the-fly face metrics from node coordinates (no stored metric arrays).
// S = 0.5*(d1 x d2) (diagonal cross product) oriented toward +index direction;
// sum over a closed cell is exactly zero -> freestream preserved at any order.
#pragma once
#include "common.h"

__device__ __host__ inline void faceVec(float ax, float ay, float az, float bx, float by, float bz,
                                        float cx, float cy, float cz, float dx, float dy, float dz,
                                        float S[3], float C[3]) {
  float d1x = cx - ax, d1y = cy - ay, d1z = cz - az;
  float d2x = dx - bx, d2y = dy - by, d2z = dz - bz;
  S[0] = 0.5f * (d1y * d2z - d1z * d2y);
  S[1] = 0.5f * (d1z * d2x - d1x * d2z);
  S[2] = 0.5f * (d1x * d2y - d1y * d2x);
  C[0] = 0.25f * (ax + bx + cx + dx);
  C[1] = 0.25f * (ay + by + cy + dy);
  C[2] = 0.25f * (az + bz + cz + dz);
}

__host__ __device__ inline void faceI(const Blk& B, const float* x, const float* y, const float* z,
                             int i, int j, int k, float S[3], float C[3]) {
  long a = B.noff + nidx(B, i, j, k),         b = B.noff + nidx(B, i, j + 1, k);
  long c = B.noff + nidx(B, i, j + 1, k + 1), d = B.noff + nidx(B, i, j, k + 1);
  faceVec(x[a], y[a], z[a], x[b], y[b], z[b], x[c], y[c], z[c], x[d], y[d], z[d], S, C);
}
__host__ __device__ inline void faceJ(const Blk& B, const float* x, const float* y, const float* z,
                             int i, int j, int k, float S[3], float C[3]) {
  long a = B.noff + nidx(B, i, j, k),         b = B.noff + nidx(B, i, j, k + 1);
  long c = B.noff + nidx(B, i + 1, j, k + 1), d = B.noff + nidx(B, i + 1, j, k);
  faceVec(x[a], y[a], z[a], x[b], y[b], z[b], x[c], y[c], z[c], x[d], y[d], z[d], S, C);
}
__host__ __device__ inline void faceK(const Blk& B, const float* x, const float* y, const float* z,
                             int i, int j, int k, float S[3], float C[3]) {
  long a = B.noff + nidx(B, i, j, k),         b = B.noff + nidx(B, i + 1, j, k);
  long c = B.noff + nidx(B, i + 1, j + 1, k), d = B.noff + nidx(B, i, j + 1, k);
  faceVec(x[a], y[a], z[a], x[b], y[b], z[b], x[c], y[c], z[c], x[d], y[d], z[d], S, C);
}

// face of given direction (0,1,2) at face-plane index f, cell column (a=other1, b=other2)
// dir 0: (f, j=a, k=b) ; dir 1: (i=b, f, k=a) ; dir 2: (i=a, j=b, f)  -- see flux kernel
__host__ __device__ inline void faceD(const Blk& B, int dir, const float* x, const float* y, const float* z,
                             int i, int j, int k, float S[3], float C[3]) {
  if (dir == 0) faceI(B, x, y, z, i, j, k, S, C);
  else if (dir == 1) faceJ(B, x, y, z, i, j, k, S, C);
  else faceK(B, x, y, z, i, j, k, S, C);
}

// cell center from 8 nodes
__host__ __device__ inline void cellCenter(const Blk& B, const float* x, const float* y, const float* z,
                                  int i, int j, int k, float C[3]) {
  C[0] = C[1] = C[2] = 0.f;
  for (int dk = 0; dk < 2; dk++) for (int dj = 0; dj < 2; dj++) for (int di = 0; di < 2; di++) {
    long p = B.noff + nidx(B, i + di, j + dj, k + dk);
    C[0] += x[p]; C[1] += y[p]; C[2] += z[p];
  }
  C[0] *= 0.125f; C[1] *= 0.125f; C[2] *= 0.125f;
}

// Sutherland (nondim): mu = muinf * T^1.5 (1+Sc)/(T+Sc), T = gamma*p/rho
__host__ __device__ inline float sutherland(float T, float muinf, float Sc) {
  return muinf * T * sqrtf(T) * (1.f + Sc) / (T + Sc);
}

// rigid-body grid velocity at point C: ug = omega x (C - center)
__host__ __device__ inline void gridVel(const Blk& B, const float C[3], float ug[3]) {
  if (!B.moving) { ug[0] = ug[1] = ug[2] = 0.f; return; }
  float rx = C[0]-B.mc[0], ry = C[1]-B.mc[1], rz = C[2]-B.mc[2];
  ug[0] = B.mw[1]*rz - B.mw[2]*ry;
  ug[1] = B.mw[2]*rx - B.mw[0]*rz;
  ug[2] = B.mw[0]*ry - B.mw[1]*rx;
}
