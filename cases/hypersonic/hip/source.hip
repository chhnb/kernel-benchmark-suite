#include <hip/hip_runtime.h>
#include "hip/hip_runtime.h"
// tau_hypersonic_cuda.cu
//
// nvcc -O3 -o tau_2d_hypersonic_cuda tau_hypersonic_cuda.cu -std=c++17 -lraylib
//
// Controls: SPACE pause, R reset, M mode
//
// View modes:
//   0 log(rho)
//   1 log(p)
//   2 speed
//   3 schlieren (|∇rho|)
//   4 vorticity (asinh(omega))
//   5 Mach
//   6 log(p/rho)


#include <hip/hip_runtime.h>
#include <errno.h>
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define W 8192
#define H 1024
#define SCALE 0.25

#define EPS_RHO 1e-25
#define EPS_P 1e-25

constexpr double kPi = 3.14159265358979323846;

struct SimConfig {
  double gamma;
  double cfl;
  double visc_nu;
  double visc_rho;
  double visc_e;
  double inflow_mach;
  double geom_x0;
  double geom_cy;
  double geom_Rb;
  double geom_Rn;
  double geom_theta;
  int steps_per_frame;
};

struct TileCliConfig {
  int tile_bx;
  int tile_by;
  bool tile_bx_set;
  bool tile_by_set;
};

struct TileLaunchConfig {
  dim3 block;
  dim3 grid;
  size_t shm_predict;
  size_t shm_step;
  const char *preset_name;
};

extern __constant__ SimConfig d_cfg;

static inline void ck(hipError_t e, const char *msg) {
  if (e != hipSuccess) {
    fprintf(stderr, "CUDA error: %s: %s\n", msg, hipGetErrorString(e));
    exit(1);
  }
}
#define CK(x) ck((x), #x)

static void validate_reduction_launch_config(int threads,
                                             size_t shared_bytes_per_array) {
  if (threads <= 0 || (threads & (threads - 1)) != 0) {
    fprintf(stderr,
            "Invalid thread count %d: reductions require a positive "
            "power-of-two block size.\n",
            threads);
    exit(1);
  }

  int dev = 0;
  CK(hipGetDevice(&dev));
  hipDeviceProp_t prop{};
  CK(hipGetDeviceProperties(&prop, dev));

  if (threads > prop.maxThreadsPerBlock) {
    fprintf(stderr,
            "Invalid thread count %d: device maxThreadsPerBlock is %d.\n",
            threads, prop.maxThreadsPerBlock);
    exit(1);
  }

  size_t shared_bytes = shared_bytes_per_array * (size_t)threads;
  if (shared_bytes > prop.sharedMemPerBlock) {
    fprintf(stderr,
            "Invalid shared memory request %zu bytes: device sharedMemPerBlock "
            "is %zu bytes.\n",
            shared_bytes, (size_t)prop.sharedMemPerBlock);
    exit(1);
  }
}

typedef struct {
  double *rho, *mx, *my, *E;
} Usoa;

typedef struct {
  double *rho, *mx, *my, *E;
} Csoa;

struct Cons {
  double rho, mx, my, E;
};

struct Prim {
  double rho, u, v, p;
};

struct FacePrim {
  Prim L, R;
};

// d_*
__device__ __forceinline__ int d_idx(int x, int y) { return y * W + x; }
__device__ __forceinline__ double d_fmax(double a, double b) {
  return a > b ? a : b;
}
__device__ __forceinline__ double d_fmin(double a, double b) {
  return a < b ? a : b;
}
__device__ __forceinline__ double d_fabs(double a) { return a < 0 ? -a : a; }
__device__ __forceinline__ double d_isfinite(double x) {
  return isfinite(x) ? 1.0 : 0.0;
}

// primitaves and conserved
__device__ __forceinline__ Prim cons_to_prim(Cons c) {
  Prim p;
  double rho = d_fmax(c.rho, EPS_RHO);
  double inv = 1.0 / rho;
  double u = c.mx * inv;
  double v = c.my * inv;

  double kin = 0.5 * rho * (u * u + v * v);
  double eint = c.E - kin;
  double pr = d_fmax((d_cfg.gamma - 1.0) * eint, EPS_P);

  p.rho = rho;
  p.u = u;
  p.v = v;
  p.p = pr;
  return p;
}

__device__ __forceinline__ Cons prim_to_cons(Prim p) {
  Cons c;
  double rho = d_fmax(p.rho, EPS_RHO);
  double pr = d_fmax(p.p, EPS_P);
  c.rho = rho;
  c.mx = rho * p.u;
  c.my = rho * p.v;
  c.E = pr / (d_cfg.gamma - 1.0) + 0.5 * rho * (p.u * p.u + p.v * p.v);
  return c;
}

__device__ __forceinline__ double sound_speed(Prim p) {
  return sqrt(d_cfg.gamma * d_fmax(p.p, EPS_P) / d_fmax(p.rho, EPS_RHO));
}

enum class Axis : int { X = 0, Y = 1 };

template <Axis AX>
__device__ __forceinline__ double prim_normal(const Prim &p) {
  if constexpr (AX == Axis::X) {
    return p.u;
  }
  return p.v;
}

template <Axis AX>
__device__ __forceinline__ double prim_tangent(const Prim &p) {
  if constexpr (AX == Axis::X) {
    return p.v;
  }
  return p.u;
}

template <Axis AX> __device__ __forceinline__ Cons flux_axis(Cons c) {
  Prim p = cons_to_prim(c);
  Cons f;
  double un = prim_normal<AX>(p);
  f.rho = (AX == Axis::X) ? c.mx : c.my;
  f.mx = (AX == Axis::X) ? (c.mx * un + p.p) : (c.mx * un);
  f.my = (AX == Axis::X) ? (c.my * un) : (c.my * un + p.p);
  f.E = (c.E + p.p) * un;
  return f;
}

template <Axis AX> __device__ __forceinline__ Cons flux_axis(Prim p) {
  return flux_axis<AX>(prim_to_cons(p));
}

__device__ __forceinline__ Cons flux_x(Cons c) { return flux_axis<Axis::X>(c); }

__device__ __forceinline__ Cons flux_x(Prim p) { return flux_axis<Axis::X>(p); }

__device__ __forceinline__ Cons flux_y(Cons c) { return flux_axis<Axis::Y>(c); }

__device__ __forceinline__ Cons flux_y(Prim p) { return flux_axis<Axis::Y>(p); }

__device__ __forceinline__ double minmod(double a, double b) {
  if (a * b <= 0.0)
    return 0.0;
  return (d_fabs(a) < d_fabs(b)) ? a : b;
}

__device__ __forceinline__ double mc_limiter(double dl, double dc, double dr) {
  double mm1 = minmod(dl, dr);
  double mm2 = minmod(dc, 2.0 * dl);
  double mm3 = minmod(dc, 2.0 * dr);
  return minmod(mm1, minmod(mm2, mm3));
}

__device__ __forceinline__ Prim inflow_state() {
  const double mach = d_cfg.inflow_mach;
  const double rho = 1.0;
  const double p = 1.0;
  double a = sqrt(d_cfg.gamma * p / rho);
  double u = mach * a;
  double v = 0;
  return Prim{rho, u, v, p};
}

__device__ __forceinline__ Cons load_cons(const Usoa U, int i) {
  return Cons{U.rho[i], U.mx[i], U.my[i], U.E[i]};
}

__device__ __forceinline__ void store_cons(Usoa U, int i, Cons c) {
  U.rho[i] = c.rho;
  U.mx[i] = c.mx;
  U.my[i] = c.my;
  U.E[i] = c.E;
}

__device__ __forceinline__ Cons load_cons(const Csoa A, int i) {
  return Cons{A.rho[i], A.mx[i], A.my[i], A.E[i]};
}

__device__ __forceinline__ void store_cons(Csoa A, int i, Cons c) {
  A.rho[i] = c.rho;
  A.mx[i] = c.mx;
  A.my[i] = c.my;
  A.E[i] = c.E;
}

__device__ __forceinline__ Prim wall_ghost_prim(Prim inside) {
  return Prim{inside.rho, -inside.u, -inside.v, inside.p};
}

__device__ __forceinline__ Cons neighbor_or_wall(const Usoa U,
                                                 const uint8_t *mask, int x,
                                                 int y, int dx, int dy) {
  int xn = x + dx;
  int yn = y + dy;

  if (yn < 0)
    yn = 0;
  if (yn >= H)
    yn = H - 1;

  if (xn < 0) {
    return prim_to_cons(inflow_state());
  }
  if (xn >= W) {
    return load_cons(U, d_idx(W - 1, yn));
  }

  int j = d_idx(xn, yn);
  if (mask[j]) {
    return prim_to_cons(
        wall_ghost_prim(cons_to_prim(load_cons(U, d_idx(x, y)))));
  }
  return load_cons(U, j);
}

__device__ __forceinline__ Cons neighbor_for_diff(const Usoa U,
                                                  const uint8_t *mask, int xc,
                                                  int yc, int xn, int yn) {
  if (yn < 0)
    yn = 0;
  if (yn >= H)
    yn = H - 1;

  if (xn < 0) {
    return prim_to_cons(inflow_state());
  }
  if (xn >= W) {
    return load_cons(U, d_idx(W - 1, yn));
  }

  int j = d_idx(xn, yn);
  if (mask[j]) {
    return prim_to_cons(
        wall_ghost_prim(cons_to_prim(load_cons(U, d_idx(xc, yc)))));
  }
  return load_cons(U, j);
}

struct TileView {
  const double *rho;
  const double *mx;
  const double *my;
  const double *E;
  const uint8_t *mask;
  int tileW;
  int tileH;
  int x0;
  int y0;
};

__device__ __forceinline__ int tile_index(const TileView &tv, int lx, int ly) {
  return ly * tv.tileW + lx;
}

__device__ __forceinline__ bool tile_contains(const TileView &tv, int x,
                                              int y) {
  return x >= tv.x0 && x < (tv.x0 + tv.tileW) && y >= tv.y0 &&
         y < (tv.y0 + tv.tileH);
}

__device__ __forceinline__ Cons tile_load_cons(const TileView &tv, int x,
                                               int y) {
  int li = tile_index(tv, x - tv.x0, y - tv.y0);
  return Cons{tv.rho[li], tv.mx[li], tv.my[li], tv.E[li]};
}

__device__ __forceinline__ uint8_t tile_load_mask(const TileView &tv, int x,
                                                  int y) {
  int li = tile_index(tv, x - tv.x0, y - tv.y0);
  return tv.mask[li];
}

__device__ __forceinline__ Cons load_neighbor_or_wall_tiled(
    const Usoa U, const uint8_t *mask, const TileView &tv,
    const Prim &centerPrim, int xn, int yn) {
  if (yn < 0)
    yn = 0;
  if (yn >= H)
    yn = H - 1;

  if (xn < 0) {
    return prim_to_cons(inflow_state());
  }
  if (xn >= W) {
    return load_cons(U, d_idx(W - 1, yn));
  }

  uint8_t m = tile_contains(tv, xn, yn) ? tile_load_mask(tv, xn, yn)
                                        : mask[d_idx(xn, yn)];
  if (m) {
    return prim_to_cons(wall_ghost_prim(centerPrim));
  }
  return tile_contains(tv, xn, yn) ? tile_load_cons(tv, xn, yn)
                                   : load_cons(U, d_idx(xn, yn));
}

__device__ __forceinline__ void enforce_positive_faces(Prim &qm, const Prim &qc,
                                                       Prim &qp) {
  for (int it = 0; it < 8; it++) {
    int bad = 0;
    if (qm.rho <= EPS_RHO || qp.rho <= EPS_RHO)
      bad = 1;
    if (qm.p <= EPS_P || qp.p <= EPS_P)
      bad = 1;
    if (!bad)
      return;

    qm.rho = 0.5 * (qm.rho + qc.rho);
    qm.u = 0.5 * (qm.u + qc.u);
    qm.v = 0.5 * (qm.v + qc.v);
    qm.p = 0.5 * (qm.p + qc.p);

    qp.rho = 0.5 * (qp.rho + qc.rho);
    qp.u = 0.5 * (qp.u + qc.u);
    qp.v = 0.5 * (qp.v + qc.v);
    qp.p = 0.5 * (qp.p + qc.p);
  }
  qm.rho = d_fmax(qm.rho, EPS_RHO);
  qp.rho = d_fmax(qp.rho, EPS_RHO);
  qm.p = d_fmax(qm.p, EPS_P);
  qp.p = d_fmax(qp.p, EPS_P);
}

__device__ __forceinline__ FacePrim reconstruct_limited_faces(const Prim &qm,
                                                              const Prim &qc,
                                                              const Prim &qp) {
  double dl_rho = qc.rho - qm.rho, dr_rho = qp.rho - qc.rho;
  double dc_rho = 0.5 * (qp.rho - qm.rho);
  double s_rho = mc_limiter(dl_rho, dc_rho, dr_rho);

  double dl_u = qc.u - qm.u, dr_u = qp.u - qc.u;
  double dc_u = 0.5 * (qp.u - qm.u);
  double s_u = mc_limiter(dl_u, dc_u, dr_u);

  double dl_v = qc.v - qm.v, dr_v = qp.v - qc.v;
  double dc_v = 0.5 * (qp.v - qm.v);
  double s_v = mc_limiter(dl_v, dc_v, dr_v);

  double dl_p = qc.p - qm.p, dr_p = qp.p - qc.p;
  double dc_p = 0.5 * (qp.p - qm.p);
  double s_p = mc_limiter(dl_p, dc_p, dr_p);

  Prim qL{qc.rho - 0.5 * s_rho, qc.u - 0.5 * s_u, qc.v - 0.5 * s_v,
          qc.p - 0.5 * s_p};
  Prim qR{qc.rho + 0.5 * s_rho, qc.u + 0.5 * s_u, qc.v + 0.5 * s_v,
          qc.p + 0.5 * s_p};
  enforce_positive_faces(qL, qc, qR);
  return FacePrim{qL, qR};
}

template <Axis AX>
__device__ __forceinline__ FacePrim reconstruct_axis_tiled(const Usoa U,
                                                           const uint8_t *mask,
                                                           const TileView &tv,
                                                           const Prim &qc,
                                                           int x, int y) {
  constexpr int DX = (AX == Axis::X) ? 1 : 0;
  constexpr int DY = (AX == Axis::X) ? 0 : 1;
  Prim qm = cons_to_prim(
      load_neighbor_or_wall_tiled(U, mask, tv, qc, x - DX, y - DY));
  Prim qp = cons_to_prim(
      load_neighbor_or_wall_tiled(U, mask, tv, qc, x + DX, y + DY));
  return reconstruct_limited_faces(qm, qc, qp);
}

template <Axis AX>
__device__ __forceinline__ Prim half_step_predict_axis(Prim q, Cons dF,
                                                       double half_dt_dn) {
  (void)AX;
  Cons c = prim_to_cons(q);
  c.rho -= half_dt_dn * dF.rho;
  c.mx -= half_dt_dn * dF.mx;
  c.my -= half_dt_dn * dF.my;
  c.E -= half_dt_dn * dF.E;
  Prim out = cons_to_prim(c);
  out.rho = d_fmax(out.rho, EPS_RHO);
  out.p = d_fmax(out.p, EPS_P);
  return out;
}

__device__ __forceinline__ Prim half_step_predict_x(Prim q, double dF_rho,
                                                    double dF_mx, double dF_my,
                                                    double dF_E,
                                                    double half_dt_dx) {
  return half_step_predict_axis<Axis::X>(q, Cons{dF_rho, dF_mx, dF_my, dF_E},
                                         half_dt_dx);
}

__device__ __forceinline__ Prim half_step_predict_y(Prim q, double dG_rho,
                                                    double dG_mx, double dG_my,
                                                    double dG_E,
                                                    double half_dt_dy) {
  return half_step_predict_axis<Axis::Y>(q, Cons{dG_rho, dG_mx, dG_my, dG_E},
                                         half_dt_dy);
}

__device__ __forceinline__ Cons cons_sub(Cons a, Cons b) {
  return Cons{a.rho - b.rho, a.mx - b.mx, a.my - b.my, a.E - b.E};
}
__device__ __forceinline__ Cons cons_add(Cons a, Cons b) {
  return Cons{a.rho + b.rho, a.mx + b.mx, a.my + b.my, a.E + b.E};
}
__device__ __forceinline__ Cons cons_mul(double s, Cons a) {
  return Cons{s * a.rho, s * a.mx, s * a.my, s * a.E};
}

template <Axis AX> __device__ __forceinline__ Cons hlle_axis(Cons UL, Cons UR) {
  Prim L = cons_to_prim(UL);
  Prim R = cons_to_prim(UR);
  double uL = prim_normal<AX>(L);
  double uR = prim_normal<AX>(R);
  double aL = sound_speed(L);
  double aR = sound_speed(R);
  double SL = d_fmin(uL - aL, uR - aR);
  double SR = d_fmax(uL + aL, uR + aR);

  Cons FL = flux_axis<AX>(UL);
  Cons FR = flux_axis<AX>(UR);

  if (SL >= 0.0)
    return FL;
  if (SR <= 0.0)
    return FR;

  double denom = SR - SL;
  if (d_fabs(denom) < 1e-14)
    return cons_mul(0.5, cons_add(FL, FR));

  Cons term1 = cons_mul(SR, FL);
  Cons term2 = cons_mul(-SL, FR);
  Cons term3 = cons_mul(SL * SR, cons_sub(UR, UL));
  return cons_mul(1.0 / denom, cons_add(cons_add(term1, term2), term3));
}

__device__ __forceinline__ Cons hlle_x(Cons UL, Cons UR) {
  return hlle_axis<Axis::X>(UL, UR);
}

__device__ __forceinline__ Cons hlle_y(Cons UL, Cons UR) {
  return hlle_axis<Axis::Y>(UL, UR);
}

template <Axis AX> __device__ __forceinline__ Cons hllc_axis(Cons UL, Cons UR) {
  Prim L = cons_to_prim(UL);
  Prim R = cons_to_prim(UR);

  double unL = prim_normal<AX>(L);
  double unR = prim_normal<AX>(R);
  double utL = prim_tangent<AX>(L);
  double utR = prim_tangent<AX>(R);

  double aL = sound_speed(L);
  double aR = sound_speed(R);

  double SL = d_fmin(unL - aL, unR - aR);
  double SR = d_fmax(unL + aL, unR + aR);

  Cons FL = flux_axis<AX>(UL);
  Cons FR = flux_axis<AX>(UR);

  if (SL >= 0.0)
    return FL;
  if (SR <= 0.0)
    return FR;

  double rhoL = L.rho, rhoR = R.rho;
  double pL = L.p, pR = R.p;

  double num = pR - pL + rhoL * unL * (SL - unL) - rhoR * unR * (SR - unR);
  double den = rhoL * (SL - unL) - rhoR * (SR - unR);

  if (d_fabs(den) < 1e-14 || !isfinite(num) || !isfinite(den)) {
    return hlle_axis<AX>(UL, UR);
  }

  double SM = num / den;
  if (!isfinite(SM))
    return hlle_axis<AX>(UL, UR);

  double pStar = pL + rhoL * (SL - unL) * (SM - unL);
  pStar = d_fmax(pStar, EPS_P);

  double dLS = (SL - SM);
  double dRS = (SR - SM);
  if (d_fabs(dLS) < 1e-14 || d_fabs(dRS) < 1e-14) {
    return hlle_axis<AX>(UL, UR);
  }

  double rhoStarL = rhoL * (SL - unL) / dLS;
  double rhoStarR = rhoR * (SR - unR) / dRS;

  if (!(rhoStarL > 0.0) || !(rhoStarR > 0.0) || !isfinite(rhoStarL) ||
      !isfinite(rhoStarR)) {
    return hlle_axis<AX>(UL, UR);
  }

  double momNL = rhoStarL * SM;
  double momTL = rhoStarL * utL;
  double EL = UL.E;
  double EStarL = ((SL - unL) * EL - pL * unL + pStar * SM) / dLS;
  if (!isfinite(EStarL))
    return hlle_axis<AX>(UL, UR);
  Cons UStarL = (AX == Axis::X) ? Cons{rhoStarL, momNL, momTL, EStarL}
                                : Cons{rhoStarL, momTL, momNL, EStarL};

  double momNR = rhoStarR * SM;
  double momTR = rhoStarR * utR;
  double ER = UR.E;
  double EStarR = ((SR - unR) * ER - pR * unR + pStar * SM) / dRS;
  if (!isfinite(EStarR))
    return hlle_axis<AX>(UL, UR);
  Cons UStarR = (AX == Axis::X) ? Cons{rhoStarR, momNR, momTR, EStarR}
                                : Cons{rhoStarR, momTR, momNR, EStarR};

  if (SM >= 0.0) {
    Cons F;
    F.rho = FL.rho + SL * (UStarL.rho - UL.rho);
    F.mx = FL.mx + SL * (UStarL.mx - UL.mx);
    F.my = FL.my + SL * (UStarL.my - UL.my);
    F.E = FL.E + SL * (UStarL.E - UL.E);
    return F;
  }

  Cons F;
  F.rho = FR.rho + SR * (UStarR.rho - UR.rho);
  F.mx = FR.mx + SR * (UStarR.mx - UR.mx);
  F.my = FR.my + SR * (UStarR.my - UR.my);
  F.E = FR.E + SR * (UStarR.E - UR.E);
  return F;
}

__device__ __forceinline__ Cons hllc_x(Cons UL, Cons UR) {
  return hllc_axis<Axis::X>(UL, UR);
}

__device__ __forceinline__ Cons hllc_x(Prim qL, Prim qR) {
  return hllc_axis<Axis::X>(prim_to_cons(qL), prim_to_cons(qR));
}

__device__ __forceinline__ Cons hllc_y(Cons UL, Cons UR) {
  return hllc_axis<Axis::Y>(UL, UR);
}

__device__ __forceinline__ Cons hllc_y(Prim qB, Prim qT) {
  return hllc_axis<Axis::Y>(prim_to_cons(qB), prim_to_cons(qT));
}

// device helpers
__device__ __forceinline__ double clamp01(double t) {
  return t < 0.0 ? 0.0 : (t > 1.0 ? 1.0 : t);
}

__device__ __forceinline__ double len2(double x, double y) {
  return sqrt(x * x + y * y);
}

__device__ __forceinline__ double sdSegment(double px, double py, double ax,
                                            double ay, double bx, double by) {
  double abx = bx - ax, aby = by - ay;
  double apx = px - ax, apy = py - ay;
  double denom = abx * abx + aby * aby + 1e-30;
  double t = (apx * abx + apy * aby) / denom;
  t = clamp01(t);
  double qx = ax + t * abx, qy = ay + t * aby;
  return len2(px - qx, py - qy);
}

__device__ __forceinline__ double
sdSphereConeCapsule(double x, double y, double Rb, double Rn, double theta) {
  double r = d_fabs(y);

  double st = sin(theta);
  double ct = cos(theta);
  double tt = tan(theta);

  double xt = Rn * (1.0 - st);
  double rt = Rn * ct;

  double xb = xt + (Rb - rt) / d_fmax(tt, 1e-30);

  double rprof = 0.0;
  if (x < 0.0) {
    rprof = -1.0;
  } else if (x <= xt) {
    double dx = x - Rn;
    double inside = Rn * Rn - dx * dx;
    rprof = (inside > 0.0) ? sqrt(inside) : 0.0;
  } else if (x <= xb) {
    rprof = rt + (x - xt) * tt;
  } else {
    rprof = -1.0;
  }

  int inside = (x >= 0.0 && x <= xb && r <= rprof);

  double d_sphere = d_fabs(len2(x - Rn, r) - Rn);
  double d_cone = sdSegment(x, r, xt, rt, xb, Rb);
  double d_base = sdSegment(x, y, xb, -Rb, xb, +Rb);
  double d_rim = len2(x - xb, r - Rb);

  double d = d_sphere;
  if (d_cone < d)
    d = d_cone;
  if (d_base < d)
    d = d_base;
  if (d_rim < d)
    d = d_rim;

  return inside ? -d : d;
}

__device__ __forceinline__ uchar4 pack_rgba(uint8_t r, uint8_t g, uint8_t b) {
  return uchar4{r, g, b, 255};
}

__device__ __forceinline__ void get_color(double t, uint8_t &r, uint8_t &g,
                                          uint8_t &b) {
  if (t < 0)
    t = 0;
  if (t > 1)
    t = 1;
  double rr = 255.0 * d_fmin(1.0, d_fmax(0.0, 3.0 * t - 1.0));
  double gg = 255.0 * d_fmin(1.0, d_fmax(0.0, 2.0 - 4.0 * d_fabs(t - 0.5)));
  double bb = 255.0 * d_fmin(1.0, d_fmax(0.0, 2.0 - 3.0 * t));
  r = (uint8_t)rr;
  g = (uint8_t)gg;
  b = (uint8_t)bb;
}

__device__ __forceinline__ Prim sample_prim_bc(const Usoa U,
                                               const uint8_t *mask, int xc,
                                               int yc, int x, int y) {
  if (y < 0)
    y = 0;
  if (y >= H)
    y = H - 1;

  if (x < 0)
    return inflow_state();
  if (x >= W) {
    int i = d_idx(W - 1, y);
    return cons_to_prim(load_cons(U, i));
  }

  int i = d_idx(x, y);
  if (mask[i]) {
    Prim interior = cons_to_prim(load_cons(U, d_idx(xc, yc)));
    return wall_ghost_prim(interior);
  }
  return cons_to_prim(load_cons(U, i));
}

__device__ __forceinline__ double spherecone_xb(double Rb, double Rn,
                                                double theta) {
  double st = sin(theta);
  double ct = cos(theta);
  double tt = tan(theta);
  double xt = Rn * (1.0 - st);
  double rt = Rn * ct;
  return xt + (Rb - rt) / d_fmax(tt, 1e-30);
}

// k_*

struct Frame { Usoa U; const uint8_t* mask; Csoa xL_states,xR_states; int xl,xr,y; bool hasL,hasR,active; Cons UL,UR; };
__constant__ SimConfig d_cfg;
extern "C" __global__ void face_kernel(Usoa U,const uint8_t *mask,Csoa xL_states,Csoa xR_states,Csoa xFlux) {
  int i = (int)(blockIdx.x * blockDim.x + threadIdx.x);
  int NF = (W + 1) * H;
  if (i >= NF)
    return;

  int fx = i % (W + 1);
  int y = i / (W + 1);
  int xl = fx - 1;
  int xr = fx;

  bool hasL = (xl >= 0) && !mask[d_idx(xl, y)];
  bool hasR = (xr < W) && !mask[d_idx(xr, y)];

  Cons UL{}, UR{};
  if (hasL && hasR) {
    UL = load_cons(xR_states, d_idx(xl, y));
    UR = load_cons(xL_states, d_idx(xr, y));
  } else if (hasR) {
    UL = neighbor_or_wall(U, mask, xr, y, -1, 0);
    UR = load_cons(xL_states, d_idx(xr, y));
  } else if (hasL) {
    UL = load_cons(xR_states, d_idx(xl, y));
    UR = neighbor_or_wall(U, mask, xl, y, +1, 0);
  } else {
    store_cons(xFlux, i, Cons{0.0, 0.0, 0.0, 0.0});
    return;
  }

  store_cons(xFlux, i, hllc_x(UL, UR));
}
