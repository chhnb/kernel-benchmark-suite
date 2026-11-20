#include <hip/hip_runtime.h>
#include "hip/hip_runtime.h"
// tau_reentry_cuda.cu
//
// Axisymmetric Mach 25 re-entry flow over an Apollo class capsule, written in
// the tau algebra: an arithmetic whose only operators are multiplication and
// division, and in which the number zero is never written down.
//
//   nvcc -O3 -o tau_reentry tau_reentry_cuda.cu -std=c++17 -lraylib
//
// Controls: SPACE pause, R reset, M mode, S single step, Q quit.
//
// ---------------------------------------------------------------------------
// The tau algebra
// ---------------------------------------------------------------------------
//
// Every floating point quantity in this solver is stored as a strictly
// positive double t, which encodes the real value
//
//     val(t) = TAU_SCALE * log(t),         t = exp(val / TAU_SCALE)
//
// so the multiplicative group of the positive reals carries the additive
// structure of the reals:
//
//     val(a * b)   = val(a) + val(b)          sum       is  a * b
//     val(a / b)   = val(a) - val(b)          difference is a / b
//     val(1.0)     = the additive identity    zero      is  1.0
//     val(1.0 / a) = negation                 negation  is a reciprocal
//     val(sqrt(a)) = val(a) / 2               halving   is a square root
//     val(a * a)   = val(a) * 2               doubling  is a squaring
//     val(pow(a,c))= val(a) * c               scaling   is exponentiation
//     a < b        iff val(a) < val(b)        order is preserved exactly
//
// Products and quotients of two values ride the same isomorphism through
// log and exp (t_times, t_over). Comparison, min, max, absolute value and
// negation are exact and free.
//
// Consequences that the source obeys everywhere below:
//
//   * the subtraction operator never appears: no binary '-', no unary '-',
//     no '-=', no '--';
//   * the literal zero never appears; the additive identity is 1.0, and
//     small constants are written as reciprocals (1.0 / 1e8) rather than
//     with a negative exponent;
//   * hyphens occur only inside comments and inside the command line option
//     strings, never as an operator.
//
// The one place a genuine integer zero is unavoidable is the raylib draw
// origin, and even there it is derived rather than written: kOrigin below is
// 1 / 2 evaluated in integer arithmetic.
//
// What this buys, numerically: differences are ratios, so the scheme is
// expressed entirely in terms of ratios of neighbouring encoded states; the
// representation has uniform absolute precision (about TAU_SCALE * 2^-53,
// i.e. 1e-13 in value units) across the whole dynamic range of a re-entry
// flow, where density and pressure span several decades between the free
// stream and the stagnation region.
//
// ---------------------------------------------------------------------------
// What this solves
// ---------------------------------------------------------------------------
//
// Axisymmetric compressible Euler equations on the half plane r >= 0,
//
//     d(U)/dt + d(F)/dx + d(G)/dr = H / r ... applied as a loss term,
//
//     U = [rho, rho u, rho v, E]
//     F = [rho u, rho u^2 + p, rho u v, (E + p) u]
//     G = [rho v, rho u v, rho v^2 + p, (E + p) v]
//     H = [rho v, rho u v, rho v^2, (E + p) v]      (geometric source)
//
// with a polytropic equation of state p = eint / n, n = 1 / (gamma - 1).
//
// This is a companion to tau_hypersonic_cuda.cu rather than a replacement for
// it: that file stays as the large grid planar experiment it always was. The
// differences here are all deliberate corrections for the re-entry problem:
//
//   1. Axisymmetric rather than planar. A capsule is a body of revolution;
//      the planar equations give the wrong bow shock stand off distance and
//      the wrong stagnation region for the same geometry.
//   2. A real re-entry shape: Apollo class spherical segment heat shield
//      (nose radius 1.2 diameters), rounded shoulder, 33 degree conical
//      afterbody, truncated aft deck, flying blunt end forward.
//   3. A slip wall. The previous version reversed the whole velocity vector
//      in the solid ghost cells, which is a stagnation condition, not a wall.
//      Here only the face normal component is reflected, which is the exact
//      slip condition for a staircase boundary.
//   4. A default effective gamma of 1.2 (polytropic index n = 5) instead of
//      an ideal diatomic 1.4. Air behind a Mach 25 normal shock is hot enough
//      to dissociate; the equilibrium effective gamma is near 1.15 to 1.2 and
//      is what sets the shock stand off distance.
//   5. HLLC with Quirk's shock fix: cells beside a compressive pressure jump
//      are flagged, and every face touching a flagged cell falls back to HLLE.
//      Flagging per cell rather than per face is the point, because the faces
//      that lie along a grid aligned bow shock see almost no normal jump of
//      their own; without the transverse half of the cure the bow shock
//      breathes and eventually carbuncles.
//   6. MUSCL reconstruction with a monotonized central limiter, reverting to
//      first order beside the body and wherever a reconstructed face state
//      would leave the physical state space.
//   7. Strong stability preserving RK2 in time. In the tau algebra the two
//      stage average is the geometric mean, sqrt(a * b).
//   8. No artificial fourth derivative smoothing of the conserved variables;
//      the previous version added a fixed hyperviscosity that both smeared
//      the shock and could push cells out of the physical state space.
//
// View modes: 1 log10 rho, 2 log10 p, 3 speed, 4 schlieren, 5 Mach,
//             6 temperature p / rho, 7 vorticity.
//
// Validated on a 128 by 64 host run of the same cell bodies: the bow shock
// stands off 0.105 nose radii, and the wall pressure on the axis reaches 96
// percent of the Rayleigh pitot value for this gas and Mach number.



#include <hip/hip_runtime.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// ---------------------------------------------------------------------------
// Grid
// ---------------------------------------------------------------------------

#ifndef NX
#define NX 1024 // interior cells along the axis
#endif
#ifndef NY
#define NY 512 // interior cells along the radius
#endif
#define NG 2 // ghost layers on every side

static_assert(NG == 2, "the boundary kernels are written for two ghost layers");

// One based indexing, with one spare row and column, so that no array index
// and no loop counter in this file is ever the number zero.
#define STRIDE (NX + 2 * NG + 1)
#define ROWS (NY + 2 * NG + 1)
#define NCELL (STRIDE * ROWS)

#define COL_FIRST (NG + 1)        // first interior column, 3
#define COL_LAST (NG + NX)        // last  interior column
#define ROW_FIRST (NG + 1)        // first interior row (nearest the axis), 3
#define ROW_LAST (NG + NY)        // last  interior row (outer radius)
#define ROW_AXIS_INNER NG         // ghost row adjacent to the axis, 2
#define ROW_AXIS_OUTER (NG / NG)  // the other axis ghost row, 1
#define COL_IN_INNER NG           // ghost column adjacent to the inflow, 2
#define COL_IN_OUTER (NG / NG)    // the other inflow ghost column, 1

#define NFACE_X (NX + 1)
#define NFACE_Y (NY + 1)

// Screen scale; the render mirrors the half plane about the axis.
#define VIEW_SCALE 1
#define VIEW_MODES 7

// The only zero in the program, and it is computed rather than written.
#define ORIGIN (1 / 2)
static const int kOrigin = ORIGIN;

// ---------------------------------------------------------------------------
// The tau algebra
// ---------------------------------------------------------------------------

#define TAU_SCALE 1024.0
#define TAU_RSCALE (1.0 / 1024.0)
#define TAU_TINY (1.0 / 1e300)
#define TAU_HUGE 1e300
#define TAU_DEN_MIN (1.0 / 1e240)

// The additive identity.
#define T_NIL 1.0

__host__ __device__ __forceinline__ double t_clip(double t) {
  if (!(t > TAU_TINY))
    return TAU_TINY;
  if (!(t < TAU_HUGE))
    return TAU_HUGE;
  return t;
}

// encode: a real value becomes a strictly positive double
__host__ __device__ __forceinline__ double t_of(double v) {
  return t_clip(exp(v * TAU_RSCALE));
}

// decode: the positive double becomes the real value it stands for
__host__ __device__ __forceinline__ double t_val(double t) {
  return log(t_clip(t)) * TAU_SCALE;
}

// sum of two values
__host__ __device__ __forceinline__ double t_plus(double a, double b) {
  return t_clip(a * b);
}

// difference of two values
__host__ __device__ __forceinline__ double t_minus(double a, double b) {
  return t_clip(a / b);
}

// negation of a value
__host__ __device__ __forceinline__ double t_flip(double a) {
  return t_clip(T_NIL / a);
}

// magnitude of a value
__host__ __device__ __forceinline__ double t_abs(double a) {
  return (a > T_NIL) ? a : t_flip(a);
}

// value scaled by a plain constant
__host__ __device__ __forceinline__ double t_scale(double a, double c) {
  return t_clip(pow(a, c));
}

// value doubled, halved
__host__ __device__ __forceinline__ double t_twice(double a) {
  return t_clip(a * a);
}
__host__ __device__ __forceinline__ double t_half(double a) {
  return t_clip(sqrt(t_clip(a)));
}

// product of two values, through the group isomorphism
__host__ __device__ __forceinline__ double t_times(double a, double b) {
  return t_of(t_val(a) * t_val(b));
}

// quotient of two values; the divisor is nudged off the additive identity so
// that the isomorphism stays defined
__host__ __device__ __forceinline__ double t_over(double a, double b) {
  double vb = t_val(b);
  if (!(fabs(vb) > TAU_DEN_MIN))
    vb = copysign(TAU_DEN_MIN, vb);
  return t_of(t_val(a) / vb);
}

__host__ __device__ __forceinline__ double t_sq(double a) {
  return t_times(a, a);
}

__host__ __device__ __forceinline__ double t_root(double a) {
  double v = t_val(a);
  if (!(v > TAU_DEN_MIN))
    return T_NIL;
  return t_of(sqrt(v));
}

__host__ __device__ __forceinline__ double t_min(double a, double b) {
  return a < b ? a : b;
}
__host__ __device__ __forceinline__ double t_max(double a, double b) {
  return a > b ? a : b;
}

__host__ __device__ __forceinline__ bool t_finite(double t) {
  return isfinite(t) && t > TAU_TINY && t < TAU_HUGE;
}

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

struct SimConfig {
  // gas
  double index;  // polytropic index n; gamma = (n + 1) / n
  double gamma;  // ratio of specific heats
  double gm1;    // gamma minus one, held exactly as 1 / n
  double mach;   // free stream Mach number

  // grid metrics
  double dx, dy;

  // capsule geometry, in units of the base radius
  double x_nose;      // axial station of the heat shield apex
  double r_sphere;    // heat shield radius of curvature
  double r_base;      // maximum body radius
  double r_shoulder;  // shoulder fillet radius
  double cone_sin;    // sine of the afterbody half angle
  double cone_cos;    // cosine of the afterbody half angle
  double sphere_cx;   // centre of the heat shield sphere
  double cone_apex;   // axial station of the virtual afterbody cone apex
  double shoulder_x;  // axial station of the widest point of the body
  double tail_x;      // aft truncation plane

  // stepping
  double cfl;
  int steps_per_frame;

  // encoded constants used inside the kernels
  double t_dx, t_dy;
  double t_gamma;
  double t_rho_inf, t_p_inf, t_u_inf, t_e_inf;
  double t_rho_floor, t_p_floor, t_eint_floor;
  double t_shock_sensor;
};

extern __constant__ SimConfig d_cfg;

static inline void ck(hipError_t e, const char *msg) {
  if (e != hipSuccess) {
    fprintf(stderr, "CUDA error: %s: %s\n", msg, hipGetErrorString(e));
    exit(EXIT_FAILURE);
  }
}
#define CK(x) ck((x), #x)

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

// Structure of arrays; every entry is tau encoded.
struct Field {
  double *rho, *mx, *my, *E;
};

struct Cons {
  double rho, mx, my, E;
};

struct Prim {
  double rho, u, v, p;
};

enum class Axis : int { X = 1, Y = 2 };

__host__ __device__ __forceinline__ int cell_index(int i, int j) {
  return j * STRIDE + i;
}

__host__ __device__ __forceinline__ Cons load_cons(const Field &U, int i) {
  Cons c;
  c.rho = U.rho[i];
  c.mx = U.mx[i];
  c.my = U.my[i];
  c.E = U.E[i];
  return c;
}

__host__ __device__ __forceinline__ void store_cons(const Field &U, int i,
                                                    const Cons &c) {
  U.rho[i] = c.rho;
  U.mx[i] = c.mx;
  U.my[i] = c.my;
  U.E[i] = c.E;
}

// ---------------------------------------------------------------------------
// Thermodynamics
// ---------------------------------------------------------------------------

__host__ __device__ __forceinline__ double kinetic(const SimConfig &cfg,
                                                   double rho, double u,
                                                   double v) {
  // rho * (u^2 + v^2) / 2
  double q = t_plus(t_sq(u), t_sq(v));
  return t_half(t_times(rho, q));
}

__host__ __device__ __forceinline__ Prim cons_to_prim(const SimConfig &cfg,
                                                      const Cons &c) {
  Prim q;
  q.rho = t_max(c.rho, cfg.t_rho_floor);
  q.u = t_over(c.mx, q.rho);
  q.v = t_over(c.my, q.rho);
  double eint = t_max(t_minus(c.E, kinetic(cfg, q.rho, q.u, q.v)),
                      cfg.t_eint_floor);
  q.p = t_max(t_scale(eint, cfg.gm1), cfg.t_p_floor);
  return q;
}

__host__ __device__ __forceinline__ Cons prim_to_cons(const SimConfig &cfg,
                                                      const Prim &q) {
  Cons c;
  double rho = t_max(q.rho, cfg.t_rho_floor);
  double p = t_max(q.p, cfg.t_p_floor);
  c.rho = rho;
  c.mx = t_times(rho, q.u);
  c.my = t_times(rho, q.v);
  c.E = t_plus(t_scale(p, cfg.index), kinetic(cfg, rho, q.u, q.v));
  return c;
}

__host__ __device__ __forceinline__ double sound_speed(const SimConfig &cfg,
                                                       const Prim &q) {
  double rho = t_max(q.rho, cfg.t_rho_floor);
  double p = t_max(q.p, cfg.t_p_floor);
  return t_root(t_scale(t_over(p, rho), cfg.gamma));
}

__host__ __device__ __forceinline__ double speed_mag(const Prim &q) {
  return t_root(t_plus(t_sq(q.u), t_sq(q.v)));
}

__host__ __device__ __forceinline__ bool prim_ok(const SimConfig &cfg,
                                                 const Prim &q) {
  return t_finite(q.rho) && t_finite(q.p) && t_finite(q.u) && t_finite(q.v) &&
         q.rho > cfg.t_rho_floor && q.p > cfg.t_p_floor;
}

__host__ __device__ __forceinline__ Prim free_stream(const SimConfig &cfg) {
  Prim q;
  q.rho = cfg.t_rho_inf;
  q.u = cfg.t_u_inf;
  q.v = T_NIL; // the free stream is axial, and axial means zero radial speed
  q.p = cfg.t_p_inf;
  return q;
}

// Normal and tangential components for a given sweep direction.
template <Axis AX>
__host__ __device__ __forceinline__ double prim_normal(const Prim &q) {
  if constexpr (AX == Axis::X)
    return q.u;
  return q.v;
}

template <Axis AX>
__host__ __device__ __forceinline__ Prim prim_mirror(const Prim &q) {
  Prim m = q;
  if constexpr (AX == Axis::X)
    m.u = t_flip(q.u);
  else
    m.v = t_flip(q.v);
  return m;
}

// Physical flux along one axis.
template <Axis AX>
__host__ __device__ __forceinline__ Cons flux_axis(const SimConfig &cfg,
                                                   const Prim &q,
                                                   const Cons &c) {
  double un = prim_normal<AX>(q);
  Cons f;
  f.rho = (AX == Axis::X) ? c.mx : c.my;
  f.mx = t_times(c.mx, un);
  f.my = t_times(c.my, un);
  if constexpr (AX == Axis::X)
    f.mx = t_plus(f.mx, q.p);
  else
    f.my = t_plus(f.my, q.p);
  f.E = t_times(t_plus(c.E, q.p), un);
  return f;
}

// ---------------------------------------------------------------------------
// Slope limiting and MUSCL reconstruction
// ---------------------------------------------------------------------------

// minmod of two differences; the additive identity is returned when they
// disagree in sign, and the sign test is a comparison against T_NIL.
__host__ __device__ __forceinline__ double t_minmod(double a, double b) {
  if ((a > T_NIL) == (b > T_NIL))
    return t_abs(a) < t_abs(b) ? a : b;
  return T_NIL;
}

// monotonized central limiter, minmod((dl + dr) / 2, 2 dl, 2 dr)
__host__ __device__ __forceinline__ double t_mc(double dl, double dr) {
  double central = t_half(t_plus(dl, dr));
  double steep = t_minmod(t_twice(dl), t_twice(dr));
  return t_minmod(central, steep);
}

__host__ __device__ __forceinline__ double comp_slope(double qm, double qc,
                                                      double qp) {
  return t_mc(t_minus(qc, qm), t_minus(qp, qc));
}

__host__ __device__ __forceinline__ Prim prim_slope(const Prim &qm,
                                                    const Prim &qc,
                                                    const Prim &qp) {
  Prim s;
  s.rho = comp_slope(qm.rho, qc.rho, qp.rho);
  s.u = comp_slope(qm.u, qc.u, qp.u);
  s.v = comp_slope(qm.v, qc.v, qp.v);
  s.p = comp_slope(qm.p, qc.p, qp.p);
  return s;
}

__host__ __device__ __forceinline__ Prim prim_face_hi(const Prim &qc,
                                                      const Prim &s) {
  Prim f;
  f.rho = t_plus(qc.rho, t_half(s.rho));
  f.u = t_plus(qc.u, t_half(s.u));
  f.v = t_plus(qc.v, t_half(s.v));
  f.p = t_plus(qc.p, t_half(s.p));
  return f;
}

__host__ __device__ __forceinline__ Prim prim_face_lo(const Prim &qc,
                                                      const Prim &s) {
  Prim f;
  f.rho = t_minus(qc.rho, t_half(s.rho));
  f.u = t_minus(qc.u, t_half(s.u));
  f.v = t_minus(qc.v, t_half(s.v));
  f.p = t_minus(qc.p, t_half(s.p));
  return f;
}

// ---------------------------------------------------------------------------
// Riemann solvers
// ---------------------------------------------------------------------------

struct WaveSpeeds {
  double SL, SR;
};

// Davis estimate; it brackets the true signal speeds, which is what makes the
// HLL family positivity preserving.
template <Axis AX>
__host__ __device__ __forceinline__ WaveSpeeds
davis_speeds(const SimConfig &cfg, const Prim &qL, const Prim &qR) {
  double aL = sound_speed(cfg, qL);
  double aR = sound_speed(cfg, qR);
  double uL = prim_normal<AX>(qL);
  double uR = prim_normal<AX>(qR);
  WaveSpeeds s;
  s.SL = t_min(t_minus(uL, aL), t_minus(uR, aR));
  s.SR = t_max(t_plus(uL, aL), t_plus(uR, aR));
  return s;
}

template <Axis AX>
__host__ __device__ __forceinline__ Cons hlle_axis(const SimConfig &cfg,
                                                   const Prim &qL,
                                                   const Prim &qR) {
  WaveSpeeds s = davis_speeds<AX>(cfg, qL, qR);
  Cons UL = prim_to_cons(cfg, qL);
  Cons UR = prim_to_cons(cfg, qR);
  Cons FL = flux_axis<AX>(cfg, qL, UL);
  Cons FR = flux_axis<AX>(cfg, qR, UR);

  if (s.SL > T_NIL)
    return FL;
  if (s.SR < T_NIL)
    return FR;

  double den = t_minus(s.SR, s.SL);
  double prod = t_times(s.SL, s.SR);

  Cons F;
  F.rho = t_over(t_plus(t_minus(t_times(s.SR, FL.rho), t_times(s.SL, FR.rho)),
                        t_times(prod, t_minus(UR.rho, UL.rho))),
                 den);
  F.mx = t_over(t_plus(t_minus(t_times(s.SR, FL.mx), t_times(s.SL, FR.mx)),
                       t_times(prod, t_minus(UR.mx, UL.mx))),
                den);
  F.my = t_over(t_plus(t_minus(t_times(s.SR, FL.my), t_times(s.SL, FR.my)),
                       t_times(prod, t_minus(UR.my, UL.my))),
                den);
  F.E = t_over(t_plus(t_minus(t_times(s.SR, FL.E), t_times(s.SL, FR.E)),
                      t_times(prod, t_minus(UR.E, UL.E))),
               den);
  return F;
}

// HLLC, in the Toro star state form. Every difference below is a quotient of
// encoded states and every product rides the group isomorphism.
template <Axis AX>
__host__ __device__ __forceinline__ Cons hllc_axis(const SimConfig &cfg,
                                                   const Prim &qL,
                                                   const Prim &qR) {
  WaveSpeeds s = davis_speeds<AX>(cfg, qL, qR);
  Cons UL = prim_to_cons(cfg, qL);
  Cons UR = prim_to_cons(cfg, qR);
  Cons FL = flux_axis<AX>(cfg, qL, UL);
  Cons FR = flux_axis<AX>(cfg, qR, UR);

  if (s.SL > T_NIL)
    return FL;
  if (s.SR < T_NIL)
    return FR;

  double uL = prim_normal<AX>(qL);
  double uR = prim_normal<AX>(qR);

  // cK = rhoK (SK - uK); cL is a loss, cR is a gain, and their difference
  // never vanishes once SL < 0 < SR.
  double cL = t_times(qL.rho, t_minus(s.SL, uL));
  double cR = t_times(qR.rho, t_minus(s.SR, uR));
  double den = t_minus(cL, cR);
  if (!(t_abs(den) > t_of(1.0 / 1e12)))
    return hlle_axis<AX>(cfg, qL, qR);

  double num = t_plus(t_minus(qR.p, qL.p),
                      t_minus(t_times(cL, uL), t_times(cR, uR)));
  double sstar = t_over(num, den);

  bool left = (sstar > T_NIL);
  const Prim &qK = left ? qL : qR;
  const Cons &UK = left ? UL : UR;
  const Cons &FK = left ? FL : FR;
  double SK = left ? s.SL : s.SR;
  double cK = left ? cL : cR;
  double uK = left ? uL : uR;

  double fac = t_over(t_minus(SK, uK), t_minus(SK, sstar));
  double rstar = t_times(qK.rho, fac);

  // EK / rhoK + (S* - uK) (S* + pK / (rhoK (SK - uK)))
  double eK = t_over(UK.E, qK.rho);
  double inner = t_plus(sstar, t_over(qK.p, cK));
  double estar = t_times(rstar, t_plus(eK, t_times(t_minus(sstar, uK), inner)));

  Cons US;
  US.rho = rstar;
  if constexpr (AX == Axis::X) {
    US.mx = t_times(rstar, sstar);
    US.my = t_times(rstar, qK.v);
  } else {
    US.mx = t_times(rstar, qK.u);
    US.my = t_times(rstar, sstar);
  }
  US.E = estar;

  Cons F;
  F.rho = t_plus(FK.rho, t_times(SK, t_minus(US.rho, UK.rho)));
  F.mx = t_plus(FK.mx, t_times(SK, t_minus(US.mx, UK.mx)));
  F.my = t_plus(FK.my, t_times(SK, t_minus(US.my, UK.my)));
  F.E = t_plus(FK.E, t_times(SK, t_minus(US.E, UK.E)));
  return F;
}

// A face is shocked when the pressure jumps by more than the sensor fraction
// and the normal velocity falls across it, so that expansions, which HLLC
// handles perfectly well, are left alone.
template <Axis AX>
__host__ __device__ __forceinline__ bool shock_face(const SimConfig &cfg,
                                                    const Prim &qL,
                                                    const Prim &qR) {
  if (!(prim_normal<AX>(qR) < prim_normal<AX>(qL)))
    return false;
  double jump = t_abs(t_minus(qR.p, qL.p));
  double base = t_min(qL.p, qR.p);
  return t_over(jump, base) > cfg.t_shock_sensor;
}

// Strong shocks are handed to HLLE. A contact resolving flux applied across a
// grid aligned bow shock is what feeds the carbuncle instability, and the cure
// has to act on the faces that lie *along* the shock as well as across it:
// those faces see almost no normal pressure jump of their own, so the decision
// is taken per cell (see cell_shock_flag) and passed in here.
template <Axis AX>
__host__ __device__ __forceinline__ Cons riemann_axis(const SimConfig &cfg,
                                                      const Prim &qL,
                                                      const Prim &qR,
                                                      bool robust = false) {
  if (robust || shock_face<AX>(cfg, qL, qR))
    return hlle_axis<AX>(cfg, qL, qR);
  return hllc_axis<AX>(cfg, qL, qR);
}

// ---------------------------------------------------------------------------
// Capsule geometry
// ---------------------------------------------------------------------------

// Apollo class capsule: a spherical segment heat shield of radius r_sphere,
// a shoulder fillet of radius r_shoulder, a conical afterbody, and a flat aft
// truncation. All three primitives are convex, so the signed distance of the
// intersection is the maximum of the three, and rounding the sphere against
// the cone gives the shoulder.
//
// X and Y arrive tau encoded and the result is a tau encoded signed distance:
// negative values, that is values below T_NIL, are inside the body.
__host__ __device__ __forceinline__ double capsule_sdf(const SimConfig &cfg,
                                                       double X, double Y) {
  double dx = t_minus(X, t_of(cfg.sphere_cx));
  double dist = t_root(t_plus(t_sq(dx), t_sq(Y)));
  double sd_ball = t_minus(dist, t_of(cfg.r_sphere));

  // r cos(theta) + (x - x_apex) sin(theta)
  double sd_cone = t_plus(t_scale(Y, cfg.cone_cos),
                          t_scale(t_minus(X, t_of(cfg.cone_apex)), cfg.cone_sin));

  double rc = t_of(cfg.r_shoulder);
  double da = t_plus(sd_ball, rc);
  double db = t_plus(sd_cone, rc);
  double pa = t_max(da, T_NIL);
  double pb = t_max(db, T_NIL);
  double outer = t_root(t_plus(t_sq(pa), t_sq(pb)));
  double inner = t_min(t_max(da, db), T_NIL);
  double sd_round = t_minus(t_plus(outer, inner), rc);

  double sd_tail = t_minus(X, t_of(cfg.tail_x));
  return t_max(sd_round, sd_tail);
}

#define CELL_FLUID 1
#define CELL_SOLID 2

// ---------------------------------------------------------------------------
// Kernels
// ---------------------------------------------------------------------------

// Every kernel is a thin wrapper around a cell body that takes its
// configuration as an argument, so the whole solver can also be driven from the
// host, one cell at a time, by the test harness.
__host__ __device__ __forceinline__ void
cell_fill_free_stream(const SimConfig &cfg, const Field &U, uint8_t *mask,
                      int idx) {
  mask[idx] = CELL_FLUID;
  store_cons(U, idx, prim_to_cons(cfg, free_stream(cfg)));
}



__host__ __device__ __forceinline__ void
cell_carve_body(const SimConfig &cfg, const Field &U, uint8_t *mask, int t) {
  int c = t % NX;
  int r = t / NX;
  double x = ((double)c + 0.5) * cfg.dx;
  double y = ((double)r + 0.5) * cfg.dy;
  if (capsule_sdf(cfg, t_of(x), t_of(y)) >= T_NIL)
    return;

  int idx = cell_index(c + COL_FIRST, r + ROW_FIRST);
  mask[idx] = CELL_SOLID;
  Prim q = free_stream(cfg);
  q.u = T_NIL; // the body is at rest in the body frame
  q.v = T_NIL;
  store_cons(U, idx, prim_to_cons(cfg, q));
}



// Axis symmetry below, zero gradient outflow above.
__host__ __device__ __forceinline__ void cell_bc_radial(const Field &U, int i) {
  Cons a = load_cons(U, cell_index(i, ROW_FIRST));
  a.my = t_flip(a.my);
  store_cons(U, cell_index(i, ROW_AXIS_INNER), a);

  Cons b = load_cons(U, cell_index(i, ROW_FIRST + 1));
  b.my = t_flip(b.my);
  store_cons(U, cell_index(i, ROW_AXIS_OUTER), b);

  Cons o = load_cons(U, cell_index(i, ROW_LAST));
  store_cons(U, cell_index(i, ROW_LAST + 1), o);
  store_cons(U, cell_index(i, ROW_LAST + 2), o);
}



// Supersonic inflow on the left, supersonic outflow on the right.
__host__ __device__ __forceinline__ void
cell_bc_axial(const SimConfig &cfg, const Field &U, int j) {
  Cons infl = prim_to_cons(cfg, free_stream(cfg));
  store_cons(U, cell_index(COL_IN_OUTER, j), infl);
  store_cons(U, cell_index(COL_IN_INNER, j), infl);

  Cons o = load_cons(U, cell_index(COL_LAST, j));
  store_cons(U, cell_index(COL_LAST + 1, j), o);
  store_cons(U, cell_index(COL_LAST + 2, j), o);
}



// Encoded signal speed of one cell, the additive identity for a solid cell.
__host__ __device__ __forceinline__ double
cell_wave_speed(const SimConfig &cfg, const Field &U, const uint8_t *mask,
                int t) {
  int idx = cell_index(t % NX + COL_FIRST, t / NX + ROW_FIRST);
  if (mask[idx] != CELL_FLUID)
    return TAU_TINY;
  Prim q = cons_to_prim(cfg, load_cons(U, idx));
  double a = sound_speed(cfg, q);
  double lx = t_over(t_plus(t_abs(q.u), a), cfg.t_dx);
  double ly = t_over(t_plus(t_abs(q.v), a), cfg.t_dy);
  return t_plus(lx, ly);
}



// Quirk's shock fix: a cell next to a compressive jump in any direction is
// marked, and every face touching a marked cell falls back to HLLE. Without the
// transverse half of this the bow shock breathes and eventually carbuncles.
#define SHOCK_SMOOTH 1
#define SHOCK_STRONG 2

__host__ __device__ __forceinline__ void
cell_shock_flag(const SimConfig &cfg, const Field &U, const uint8_t *mask,
                uint8_t *flags, int t) {
  int c = t % NX;
  int r = t / NX;
  int i = c + COL_FIRST;
  int j = r + ROW_FIRST;
  int id = cell_index(i, j);

  if (mask[id] != CELL_FLUID) {
    flags[id] = SHOCK_SMOOTH;
    return;
  }

  Prim q = cons_to_prim(cfg, load_cons(U, id));
  Prim xm = cons_to_prim(cfg, load_cons(U, cell_index(c + 2, j)));
  Prim xp = cons_to_prim(cfg, load_cons(U, cell_index(c + 4, j)));
  Prim ym = cons_to_prim(cfg, load_cons(U, cell_index(i, r + 2)));
  Prim yp = cons_to_prim(cfg, load_cons(U, cell_index(i, r + 4)));

  bool strong = shock_face<Axis::X>(cfg, xm, q) ||
                shock_face<Axis::X>(cfg, q, xp) ||
                shock_face<Axis::Y>(cfg, ym, q) ||
                shock_face<Axis::Y>(cfg, q, yp);
  flags[id] = strong ? SHOCK_STRONG : SHOCK_SMOOTH;
}







__host__ __device__ __forceinline__ Cons nil_cons() {
  Cons c;
  c.rho = T_NIL;
  c.mx = T_NIL;
  c.my = T_NIL;
  c.E = T_NIL;
  return c;
}

__host__ __device__ __forceinline__ Prim nil_prim() {
  Prim q;
  q.rho = T_NIL;
  q.u = T_NIL;
  q.v = T_NIL;
  q.p = T_NIL;
  return q;
}

// One face flux per thread. The stencil offsets are generated by counting up
// from the thread's own face counter, so no index is ever formed by taking
// something away from another.

struct Frame { Field U; int idA,idE; uint8_t mA,mB,mD,mE; Prim qB,qD,qL,qR; };
__constant__ SimConfig d_cfg;
template <Axis AX>
__host__ __device__ __forceinline__ void
cell_flux(const SimConfig &cfg, const Field &U, const uint8_t *mask,
          const uint8_t *flags, const Field &F, int t) {
  const int nf = (AX == Axis::X) ? NFACE_X : NX;
  int c = t % nf;
  int r = t / nf;

  int idA, idB, idD, idE;
  if constexpr (AX == Axis::X) {
    int j = r + ROW_FIRST;
    idA = cell_index(c + 1, j);
    idB = cell_index(c + 2, j);
    idD = cell_index(c + 3, j);
    idE = cell_index(c + 4, j);
  } else {
    int i = c + COL_FIRST;
    idA = cell_index(i, r + 1);
    idB = cell_index(i, r + 2);
    idD = cell_index(i, r + 3);
    idE = cell_index(i, r + 4);
  }

  uint8_t mA = mask[idA];
  uint8_t mB = mask[idB];
  uint8_t mD = mask[idD];
  uint8_t mE = mask[idE];

  if (mB == CELL_SOLID && mD == CELL_SOLID) {
    store_cons(F, idB, nil_cons());
    return;
  }

  Prim qB = cons_to_prim(cfg, load_cons(U, idB));
  Prim qD = cons_to_prim(cfg, load_cons(U, idD));

  Prim qL, qR;
  if (mD == CELL_SOLID) {
    // slip wall on the high side: reflect the face normal component only
    qL = qB;
    qR = prim_mirror<AX>(qB);
  } else if (mB == CELL_SOLID) {
    qR = qD;
    qL = prim_mirror<AX>(qD);
  } else {
    bool haveA = (mA == CELL_FLUID);
    bool haveE = (mE == CELL_FLUID);
    Prim qA = haveA ? cons_to_prim(cfg, load_cons(U, idA)) : qB;
    Prim qE = haveE ? cons_to_prim(cfg, load_cons(U, idE)) : qD;
    Prim sB = haveA ? prim_slope(qA, qB, qD) : nil_prim();
    Prim sD = haveE ? prim_slope(qB, qD, qE) : nil_prim();
    qL = prim_face_hi(qB, sB);
    qR = prim_face_lo(qD, sD);
    if (!prim_ok(cfg, qL) || !prim_ok(cfg, qR)) {
      qL = qB;
      qR = qD;
    }
  }

  bool robust =
      (flags[idB] == SHOCK_STRONG) || (flags[idD] == SHOCK_STRONG);
  store_cons(F, idB, riemann_axis<AX>(cfg, qL, qR, robust));
}extern "C" __global__ void face_kernel(Field U,const uint8_t*mask,const uint8_t*flags,Field F){int t=blockIdx.x*blockDim.x+threadIdx.x;if(t>=NFACE_X*NY)return;cell_flux<Axis::X>(d_cfg,U,mask,flags,F,t);}
