// CuDAFLOW — FP32 GPU finite-volume RANS/LES solver (structured multiblock, overset, multi-GPU)
// High-order upwind (up to 5th, MLP limiter) / 6th central blend, AUSMPW+,
// SA-noft2 / DDES / IDDES / Vreman SGS, dual-time unsteady.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <string>
#include <vector>
#include <array>
#include <cuda_runtime.h>

#define NG 3          // ghost layers
#define NV 6          // rho, rho*u, rho*v, rho*w, rho*E, rho*nut  (Q)
                      // rho, u, v, w, p, nut                      (W)

#define CUCHK(call) do { cudaError_t e_ = (call); if (e_ != cudaSuccess) { \
  fprintf(stderr, "CUDA error %s at %s:%d\n", cudaGetErrorString(e_), __FILE__, __LINE__); exit(1);} } while (0)

// ---------------- gas / turbulence constants (device-usable) ----------------
#define GAM   1.4f
#define GM1   0.4f
#define PRL   0.72f
#define PRT   0.9f
// SA constants
#define SA_CB1 0.1355f
#define SA_CB2 0.622f
#define SA_SIG (2.0f/3.0f)
#define SA_KAP 0.41f
#define SA_CW1 (SA_CB1/(SA_KAP*SA_KAP) + (1.0f+SA_CB2)/SA_SIG)
#define SA_CW2 0.3f
#define SA_CW3 2.0f
#define SA_CV1 7.1f
#define VREMAN_C 0.07f   // ~2.5*Cs^2, Cs=0.17
// SA-IDDES constants (Shur, Spalart, Strelets & Travin, IJHFF 29, 2008)
#define IDDES_CW    0.15f   // subgrid length-scale wall-normal weight
#define IDDES_CT    1.63f   // f_t turbulent blending constant (SA branch)
#define IDDES_CL    3.55f   // f_l laminar blending constant (SA branch)
#define IDDES_FWSTAR 0.424f // f_w* in the low-Re Psi correction

enum BCType { BC_WALL = 0, BC_SYMM, BC_FARF, BC_EXTRAP, BC_OVERSET, BC_MATCH,
              BC_SUPINF, BC_SUPOUT,     // supersonic inflow (all freestream) / outflow (all extrapolate)
              BC_SLIPWALL,              // inviscid (slip) wall: velocity reflected like symmetry, but
                                        // COUNTED in wall distance (unlike symmetry) so SA/BCM/DES see
                                        // the surface. Use for slip surfaces coplanar with a wall
                                        // (flat-plate pre-plate, nozzle/tunnel slip sections).
              BC_PRESOUT,               // subsonic pressure outlet: static p fixed to p_inf (back
                                        // pressure), rho/u/v/w/nut zero-gradient. Anchors the elliptic
                                        // low-Mach pressure field (unlike characteristic farfield, which
                                        // leaks a spurious streamwise dp and reflects). Use for subsonic
                                        // outflow / top boundaries (SU2 MARKER_OUTLET equivalent).
              BC_VELIN };               // subsonic velocity inlet: rho/u/v/w/nut fixed to freestream,
                                        // static p zero-gradient (extrapolated). SU2 MARKER_INLET
                                        // equivalent — clean uniform inflow (no characteristic drift).
enum { IB_HOLE = 0, IB_ACTIVE = 1, IB_RECV = 2 };
enum TurbModel { TURB_NONE = 0, TURB_SA, TURB_DDES, TURB_VREMAN, TURB_IDDES };
// DES length-scale mode passed to the SA source kernel: 0 RANS, 1 DDES, 2 IDDES
#define DES_MODE(t) ((t) == TURB_IDDES ? 2 : ((t) == TURB_DDES ? 1 : 0))
// SA-family models carry a transported eddy-viscosity nu~ (RANS/DDES/IDDES share the fv1 closure)
__host__ __device__ inline bool isSAfam(int t) {
  return t == TURB_SA || t == TURB_DDES || t == TURB_IDDES;
}

// ---------------- block geometry bookkeeping ----------------
struct Blk {
  int ni, nj, nk;          // interior cell counts
  int nit, njt, nkt;       // padded (+2*NG)
  long ncT;                // nit*njt*nkt
  long coff;               // offset into this DEVICE's padded cell arrays
  int niN, njN, nkN;       // node counts (ni+1 ...)
  long noff;               // offset into this DEVICE's node arrays
  int dev;                 // owning GPU
  // rigid-body rotation (ALE): angular velocity vector, center. moving=0 -> static
  int moving;
  float mw[3], mc[3];
};

// padded cell index (i,j,k are interior indices; ghosts at negative / >= n)
__host__ __device__ inline long cidx(const Blk& b, int i, int j, int k) {
  return ((long)(k + NG) * b.njt + (j + NG)) * b.nit + (i + NG);
}
__host__ __device__ inline long nidx(const Blk& b, int i, int j, int k) {
  return ((long)k * b.njN + j) * b.niN + i;
}

// ---------------- boundary patch ----------------
// face: 0 imin 1 imax 2 jmin 3 jmax 4 kmin 5 kmax
// (a,b) tangential dirs in cyclic order: i->(j,k), j->(k,i), k->(i,j)
struct Patch {
  int blk, face, type;
  int a0, a1, b0, b1;      // cell ranges, inclusive, 0-based
  int donorBlk, donorFace; // for BC_MATCH
  // match transform: receiver tangential axis a maps to donor axis |ta| (1=a',2=b')
  // with sign; da0/db0 = donor coords (0-based) of receiver (a0,b0) on axes |ta|/|tb|.
  int ta, tb, da0, db0;
};

// ---------------- exchange records ----------------
// addresses are "variable-slab" form within the owning device:
//   base = NV*coff + paddedCell, stride = ncT
struct MPair { long db, sb; int ds, ss; };                 // same-device match pair
struct Recv {                                              // same-device overset receiver
  long dstB, donB;
  int dstS, donS;
  int donSI, donSJ, donSK;   // base->(+i,+j,+k) corner offsets (periodic-aware)
  float wx, wy, wz;
  long ibB;                  // donor base-cell index into ib[] (hole-corner masking); <0 = skip mask
};
struct Addr { long b; int s; };                            // address + var stride
struct RecvDon { long donB; int donS, donSI, donSJ, donSK; float wx, wy, wz; long ibB; };

// cross-device transfer: pack on src device -> staged copy -> unpack on dst
struct Xfer {
  int sd = 0, dd = 0; long n = 0;
  Addr*    src = nullptr;   // on sd (match gather)
  RecvDon* don = nullptr;   // on sd (overset interpolation)
  Addr*    dst = nullptr;   // on dd
  float *bs = nullptr, *bd = nullptr;   // staging buffers [NV*n]
};

// ---------------- run configuration ----------------
struct Cfg {
  std::string gridFile, bcFile, outPrefix = "sol";
  int gridBinary = 1;
  float mach = 0.2f, aoa = 0.f, beta = 0.f, reynolds = 1e6f, tinf = 288.15f;
  float muInf = 0.f;        // direct nondim viscosity override (hover: mach=0 makes mach/Re=0); mu/(rho a_inf L)
  int hoverSink = 0;        // 1 = point-sink far-field for hover (correct entrainment in a finite domain)
  float cfl0 = 0.5f, cflMax = 20.f; int cflRamp = 500;
  int niter = 1000, nprint = 50, nsave = 1000;
  int order = 5;            // 2 (limited MUSCL), 3, 5
  int limiter = 1;          // 0 none, 1 MLP, 2 eMLP-VC (applies to order 3/5)
  float emlpvcEps = 0.01f;  // eMLP-VC flow-distinguishing threshold (Kang et al: 0.001-0.01)
  int emlpvcLM = 1;         // eMLP-VC low-Mach-number adjustment (1 on, 0 off)
  int lowMachFlux = 0;      // 1: add AUSM+-up low-Mach dissipation to AUSMPW+ (fixes near-wall checkerboard)
  float central6 = 0.f;     // blend toward 6th-central face state
  int implicitOn = 1, nsweep = 4;
  int implicitLine = 0;     // 0 = red-black point-implicit; 1 = line-implicit ADI (tridiagonal ξ/η/ζ sweeps, KFLOW-style, much stronger smoother)
  int precond = 0;          // low-Mach preconditioning of the pseudo-time implicit operator (0 off, 1 on). LHS-ONLY (dtl spectral radius + DADI acoustic eigenvalues); RHS untouched so converged solution is unchanged, only subiter convergence at low Mach accelerates. Weiss-Smith/Choi-Merkle eigenvalues λ±=½[(1+β)Un±√((1-β)²Un²+4βc²)], β=min(1,max(M²,mfloor²)).
  float precondMfloor = 0.3f; // preconditioning Mach floor: β=min(1,max(M_local²,precondMfloor²)); prevents the M→0 stagnation singularity. Hover: ~tip-Mach scale (Sheng β=min(1,αM_Ω²), α~0.5-1).
  int oversetImplicit = 0;  // implicit overset boundaries (OVERFLOW 2.4d / Derlaga 2021): couple receiver Δq to donor Δq INSIDE the point-RB linear solve (exchange dq between sweeps + include receiver neighbors in the stencil), instead of the once-per-subiteration explicit fringe update. Attacks the slow inter-grid mode. Point-RB smoother only (implicit_line=0).
  int mgLevels = 1;         // pseudo-time FAS multigrid levels (1 = single grid / off); 2-3 typical
  int mgPre = 1, mgPost = 1;// pre/post smoothing sweeps per level in the V-cycle
  float mgRelax = 1.0f;     // prolongation correction scale (KFLOW = 1.0, full-strength trilinear)
  int mgBuffer = 0;         // fringe-buffer layers for coarse mask dilation + prolongation zeroing (0 = off, not in KFLOW)
  int mgHoleMax = 0;        // coarse iblank agglomeration: 0 = freeze if any child hole/recv; 1 = KFLOW max (active if any child active)
  float omega = 1.3f;       // implicit diagonal over-relaxation
  int viscous = 1;
  int turb = TURB_SA;       // none | sa | ddes | vreman | iddes
  float cdes = 0.65f;       // DES length-scale constant (C_DES)
  float bodyForce = 0.f;    // constant streamwise (x) body force per volume (periodic channel driver)
  float initPerturb = 0.f;  // initial random velocity perturbation amplitude (fraction of Mach)
  float lesD4 = 0.f;        // JST 4th-difference scalar dissipation coeff (scale-selective; for KEP-central LES)
  int kep2 = 0;             // 1: 2nd-order two-point KEP flux (single face metric, KE-preserving on curvilinear); 0: 6th-order telescoped
  int saBCM = 0;            // 1: SA-BCM (Cakmakcioglu-Bas-Kaynak) algebraic transition intermittency on SA production
  float tuInf = 1.0f;       // freestream turbulence intensity Tu (%) for the BCM Re_theta_c correlation
  // ---- hypersonic / strong-shock ----
  float twall = 0.f;        // isothermal wall temperature ratio Tw/Tinf (<=0 -> adiabatic)
  int shockSensor = 0;      // 0 off, 1 pressure jump, 2 Ducros-gated pressure jump (shock+turbulence)
  float shockThr = 0.2f;    // relative pressure jump where blending toward 1st order begins
  int wallOut = 0;          // 1: also write Cp, Stanton, heat flux with Cf output
  // ---- high-temperature real gas ----
  int realGas = 0;          // 0 calorically-perfect, 1 thermally-perfect (vibrational excitation)
  float thetaVib = 3056.f;  // characteristic vibrational temperature [K]
  // ---- field inversion / adjoint (FIML) ----
  int adjoint = 0;          // 1: after the forward solve, run the discrete adjoint + gradient
  std::string betaFile;     // read initial beta field (raw float per interior cell); "" -> beta=1
  std::string objMode = "cd";  // objective: "cd" drag match, "cl", "cp" surface-pressure match
  float objTarget = 0.f;    // target value (cd/cl) or reference read from objRef
  std::string objRef;       // reference field file (surface pressure/skin-friction target) cp/cf
  std::string cfTargetOut;  // after a steady run, dump per-wall-face Cf here (twin-experiment target)
  float betaReg = 1e-3f;    // Tikhonov weight on (beta-1)^2
  int fiml = 0;             // >0: FIML gradient-descent inversion, this many iterations
  float fimlStep = 1.0f;    // inversion step size
  int mfAdjoint = 0;        // 1: matrix-free adjoint for large grids -- never assemble the
                            //    exact 39-block Jacobian; use the compact 1st-order Jacobian
                            //    as the transpose operator (approximate/inconsistent adjoint)
  int adjFixedPoint = 0;    // >0: solve the adjoint by preconditioned Richardson (piggyback /
                            //    fixed-point) for this many iterations instead of GMRES. Converges
                            //    at the forward's rate, robust to the near-singular steady operator
                            //    (FP32 floor / periodic-seam ADI gap) that stalls GMRES.
  float adjOmega = 0.7f;    // relaxation factor for the fixed-point adjoint (psi += omega*M^-1*r)
  int adjPetsc = 0;         // 1: solve the adjoint with PETSc GMRES + ILU(k) ,
                            //    assembling the full block-sparse transpose Jacobian incl. seam
  int adjIlu = 1;           // ILU fill level for the PETSc preconditioner (0,1,2,...)
  int adjSeam = 1;          // 1: include the O-grid periodic i-seam coupling in the PETSc matrix
  int saCheck = 0;          // 1: validate the hand-coded reverse-mode adjoint of the SA source
                            //    term via transpose consistency <Jv,w>=<v,J^T w>, then exit
  int cuadCheck = 0;        // 1: validate the cuad-GENERATED SA-source adjoint (src/cuad_sa.cu)
  int cuadJac = 0;          // 1: validate cuad exact dR/dQ tangent assembly (src/cuad_jac.cu) vs FD
  int adjAD = 0;            // 1: buildJacobian uses cuad exact AD tangent (src/cuad_jac.cu) instead of FD
  int adjBCgeom = 0;        // 1: include BC-face geometry response in resSensX AD (negligible for shape; slow)
                            //    against finite difference on the GPU, then exit
  float volFloor = 0.f;     // >0: floor cell volume (singular-line/collapsed-cell structured grids, e.g. CRM)
  float fdAmp = 0.2f;       // directional-derivative FD amplitude in validateGradient; reduce
                            //    for ultra-flat objectives so central FD stays in the linear regime
  // ---- shape optimization (geometric adjoint chain, design.cu) ----
  int   meshSens = 0;       // 1: validate the volume mesh sensitivity dJ/dX = dJ/dX + psi^T dR/dX
  float sensEps  = 5e-3f;   // node-perturbation size as a fraction of the local mesh spacing
                            //    (per-node scaling keeps FP32 metric-difference cancellation in check)
  int   sensP    = 11;      // node-coloring period for the colored-FD dR/dX (> 2*stencil half-width)
  // FFD parameterization (Stage 2): control-point lattice enclosing the near field; each in-box
  // node's y-displacement = sum_ijk Bernstein_i(u)_j(v)_k(w) * dP_ijk. Design vars = dP (y).
  int   ffd = 0;            // 1: Stage-2 FFD dJ/dD validation
  float ffdBox[6] = {0,1,0,1,0,1};   // x0 x1 y0 y1 z0 z1
  int   ffdNx=4, ffdNy=3, ffdNz=1;   // control points per direction
  int   ffdOpt=0;          // >0: run this many steepest-descent FFD design iterations (else validate)
  float ffdStep=1e-4f;     // max control-point displacement per design step
  int   objRaw=0;          // objective returns the RAW value (cd/cl) not 0.5(val-target)^2 (for dCD/dD, dCL/dD)
  int   ffdEval=0;         // 1: single design evaluation for the external optimizer (read design_in -> design_out)
  int   ffdNoAdj=0;        // 1: forward-only design eval (write CD,CL, skip the adjoint) for FD gradients
  std::string designIn, designOut;  // FFD design-vector in / (obj + gradients) out files
  // ---- Lagrangian particle / droplet tracking (Euler-Lagrange, one-way coupled) ----
  int nPart = 0;            // >0: after the steady solve, track this many dispersed particles
  float partDia = 1e-3f;    // particle diameter (nondim, / reference length)
  float partRho = 1000.f;   // particle material density (/ rho_inf)
  float partTp0 = -1.f;     // initial particle temperature (<0 -> local gas T)
  float partVel[3] = {0,0,0}; // initial particle velocity; if partVelSet=0 use local gas velocity
  int   partVelSet = 0;
  float partInj[6] = {0,0,0,0,0,0}; // injection line segment (x0y0z0 -> x1y1z1)
  int   partSteps = 2000;   // number of tracking steps
  float partDt = 1e-3f;     // tracking time step (nondim)
  int   partSub = 10;       // sub-steps per tracking step (drag stiffness)
  int   partHeat = 1;       // 1: also integrate convective heat transfer (Ranz-Marshall)
  int   partOutEvery = 20;  // write particle state every this many steps
  std::string partOut;      // trajectory output file
  int   partWall = 0;       // 1: wall rebound/deposition model (else particle absorbed on wall hit)
  float partEn = 0.8f;      // wall normal restitution coefficient
  float partEt = 0.9f;      // wall tangential restitution coefficient
  float partVcrit = 0.f;    // deposition threshold: stick if |v_normal| < v_crit (0 -> always rebound)
  float partNpp = 1.f;      // real particles per computational parcel (two-way coupling weight)
  int   part2way = 0;       // 1: two-way coupled (particle reaction force/heat back onto the gas)
  // unsteady (dual-time BDF2 when implicit, global-dt RK3 when explicit)
  int unsteady = 0;
  float dtPhys = 0.1f;      // physical time step (nondim, a_inf/L units)
  int ntime = 100;          // physical steps
  int nsub = 25;            // inner (pseudo-time) iterations per step
  float innerTol = 0.f;     // >0: early exit when inner res drops by this factor
  float holeOffset = 0.0f;
  int oversetIHC = 1;       // implicit hole cutting (finest cell wins in overlap)
  float ihcRatio = 0.5f;    // IHC: a cell newly becomes receiver if donor vol < ihcRatio*cell vol (clearly finer)
  float ihcHold  = 0.85f;   // IHC hysteresis: an existing receiver is HELD until donor vol > ihcHold*cell vol (dead band -> stable fringe, no chatter)
  float oversetCubic = 0.f; // overset interp blend toward tri-cubic (C1): 0 = trilinear, 1 = full cubic; result = tri + f*(cubic-tri), both bounded to donor 8-cell range
  int oversetHoleMask = 1;  // 1 = drop hole (non-active) donor corners and renormalize (KFLOW-style); 0 = plain trilinear (may read hole cells)
  int oversetConservative = 0; // 1 = interpolate conserved vars (rho,rho*u,rho*E) then derive primitive; 0 = interpolate primitive (rho,u,v,w,p)
  int oversetCleanPref = 1;    // 1 = prefer all-active donor cells; 0 = pick smallest containing cell only (temporally stable, needs hole-masking)
  std::string restartFile;
  float aref = 1.0f;
  int ngpu = 0;             // 0 = use all visible GPUs
  int kep = 0;              // central part of the sigma-blend: 1 = 6th-order KGP
                            // kinetic-energy-preserving split flux, 0 = interpolated state
  int wdUpdate = 0;         // recompute wall distance every N physical steps (0 = never)
  // rotate = <blk> <omega> <cx> <cy> <cz> <ax> <ay> <az>  (omega in rad per L/a_inf)
  std::vector<std::array<double,8>> rot;
  int gpuAsm = 1;           // GPU overset assembly (single-GPU runs)
  // ---- AMR (octree of Cartesian bricks over amr_base block) ----
  int amr = 0;
  int amrBase = 0;          // background block being refined (must be ~uniform Cartesian)
  int brick = 16;           // brick cells per side (level-l spacing = h0/2^l)
  int amrLevels = 2;        // max refinement levels
  float amrThresh = 0.02f;  // refine when max(h*|vorticity|) in a site exceeds this
  float amrCoarsen = 0.3f;  // coarsen below amrCoarsen*amrThresh
  int nadapt = 25;          // adapt every N steps/iterations
  int maxBricks = 1024;     // brick pool capacity
  // ---- transition control: wall blowing/suction disturbance strip ----
  // forces controlled TS waves (natural transition) or broadband seeding.
  int fBlk = -1;            // wall block hosting the strip (-1 = off)
  float fX0 = 0.f, fX1 = 0.f;   // streamwise strip extent (x)
  float fAmp = 0.f;         // peak wall-normal velocity (fraction of U_inf)
  float fFreq = 0.f;        // fundamental forcing frequency (rad units, 0 = steady suction)
  float fBeta = 0.f;        // spanwise wavenumber of the 3D mode (0 = 2D only)
  float fRand = 0.f;        // broadband random component amplitude (fraction of fAmp)
  // ---- statistics: time+span-averaged skin friction ----
  int avgStart = 0;         // physical step to begin mean accumulation (0 = off)
  int cfBlk = -1;           // wall block for Cf(Re_x) output (-1 = first wall patch)
};

// wall blowing/suction forcing (streamwise = x, spanwise = z on a flat plate)
struct Forcing {
  int blk = -1;
  float x0, x1, amp, freq, beta, rand, t;
};

// device-side donor-block descriptor for GPU assembly
struct DonorBlk {
  Blk B;
  int id;                  // block index
  int per[3];              // periodic (wrap) dirs
  float bb0[3], bb1[3];    // node bbox
  int binOff;              // offset into bin table (48^3 per block)
};

// ---------------- per-device memory ----------------
struct DevMem {
  float *x = nullptr, *y = nullptr, *z = nullptr;   // nodes [totN]
  float *x0 = nullptr, *y0 = nullptr, *z0 = nullptr; // original nodes (moving grids)
  float *q = nullptr, *w = nullptr, *r = nullptr, *dq = nullptr;   // [NV*totC]
  float *qn = nullptr, *qn1 = nullptr;              // unsteady history [NV*totC]
  float *vol = nullptr, *wd = nullptr, *dtl = nullptr, *diag = nullptr,
        *dsa = nullptr, *mut = nullptr;             // [totC]
  char *ib = nullptr;                               // [totC]
  double *red = nullptr;                            // reduction scratch [8]
  float *redf = nullptr;                            // float scratch [4] (atomicMin)
  float *wavg = nullptr;                            // time-mean primitives [NV*totC] (stats)
  float *shk = nullptr;                             // per-cell Ducros sensor [totC] (shock_sensor=2)
  // field-inversion / adjoint (FIML)
  float *beta = nullptr;                            // SA production correction field [totC], init 1
  float *psi = nullptr;                             // adjoint variables [NV*totC]
  float *jac = nullptr;                             // colored discrete Jacobian dR/dQ blocks
  float *djq = nullptr;                             // objective partial dJ/dQ [NV*totC]
  float *f = nullptr, *qr = nullptr;                // pseudo-time multigrid: FAS tau / frozen restricted-Q [NV*totC]
  char *ib2 = nullptr;                              // multigrid: scratch iblank for interface-buffer dilation [totC]
  float *triLo = nullptr, *triDi = nullptr, *triUp = nullptr;  // line-implicit ADI tridiagonal (scalar) [totC]
  float *rhsS = nullptr;                            // line-implicit ADI right-hand side scratch [NV*totC]
  float *dadiCp = nullptr;                          // diagonalized-ADI Thomas c' scratch [NV*totC]
  long totC = 0, totN = 0;
};

// ---- pseudo-time FAS multigrid coarse level ----
// One MgLevel per coarsening step. Blocks mirror the fine block list 1:1 (each coarse
// block is a 2:1 agglomeration of its fine parent, halving whichever dims are even).
// dev reuses DevMem so the coarse level can be swapped into Sim and driven by the
// existing Sim& operators (cons2prim/computeRHS/computeDt/implicitSweeps/updateQ).
struct MgLevel {
  std::vector<Blk> blk;              // coarse blocks (own coff/noff into this level's arrays)
  std::vector<DevMem> dev;           // per-device coarse arrays (DevMem.f/.qr hold FAS tau / frozen ref)
  std::vector<int> parentEven;       // per-block: bit m set if dim m was halved from the finer level
  std::vector<Patch> patch;          // coarse patches (scaled from finer level) for applyBC/matchExchange
  std::vector<MPair*> mSame;         // coarse same-device match lists (per device)
  std::vector<long> mSameN;
};

// ---- dispersed Lagrangian particles (device arrays, single block) ----
struct Particles {
  int n = 0, cap = 0;                        // active count, capacity
  float *x=nullptr,*y=nullptr,*z=nullptr;    // position [cap]
  float *u=nullptr,*v=nullptr,*w=nullptr;    // velocity [cap]
  float *T=nullptr, *d=nullptr;              // temperature, diameter [cap]
  int   *ic=nullptr,*jc=nullptr,*kc=nullptr; // current cell (incremental walk seed) [cap]
  char  *alive=nullptr;                      // 1 in-domain, 0 exited, 2 deposited [cap]
  float *src=nullptr;                        // two-way reaction source on the gas [4*totC] (momx,y,z, E)
};

// thermodynamic model (passed by value to kernels)
struct Thermo {
  int mode = 0;         // 0 calorically-perfect, 1 thermally-perfect (vibrational)
  float R = 1.f/GAM;    // gas constant (nondim): p = rho*R*T, T = GAM*p/rho
  float cvtr = 2.5f/GAM;// translational+rotational cv = (5/2)R
  float thetaV = 15.f;  // vibrational temperature / T_inf (nondim)
};

// ---------------- solver state ----------------
struct Sim {
  Cfg cfg;
  int ndev = 1;
  std::vector<Blk> blk;
  std::vector<Patch> patch;
  std::vector<DevMem> dev;
  std::vector<MgLevel> mg;                       // pseudo-time multigrid coarse levels (mg[0] = first coarse)
  std::vector<long> devCellBase, devNodeBase;   // host (device-major) layout bases
  long totC = 0, totN = 0;                      // totals over all devices

  std::vector<float> hx, hy, hz;                // host nodes, device-major
  std::vector<float> hx0, hy0, hz0;             // original host nodes (moving grids)
  std::vector<double> omg;                      // |omega| per block (rad / time unit)
  std::vector<std::array<double,3>> rotAx, rotC; // unit axis / center per block
  bool haveMotion = false;

  // same-device exchange lists (index = device)
  std::vector<MPair*> mSame; std::vector<long> mSameN;
  std::vector<Recv*>  rSame; std::vector<long> rSameN;
  // cross-device transfers
  std::vector<Xfer> mX, rX;

  // freestream (nondim: rho=1, a=1)
  float uinf[3], pinf, nutinf, muinf;
  // hover point-sink far-field: rotor entrains fluid as a point sink of volume-flux Q
  // at the rotor center -> far-field reference velocity = -Q/(4 pi r^2) r_hat (toward rotor),
  // replaces the quiescent uinf=0 that otherwise chokes entrainment in a finite domain.
  float sinkQ = 0.f, rotorR = 0.f;   // Q updated each step from thrust; R = rotor tip radius
  Thermo thermo;
  Particles part;           // dispersed Lagrangian particles (Euler-Lagrange)
  double time = 0.0;
  long avgCount = 0;        // samples accumulated in wavg

  const float* hostX(const Blk& B) const { return hx.data() + devNodeBase[B.dev]; }
  const float* hostY(const Blk& B) const { return hy.data() + devNodeBase[B.dev]; }
  const float* hostZ(const Blk& B) const { return hz.data() + devNodeBase[B.dev]; }

  // ---- GPU assembly scratch (single device) ----
  struct {
    int inited = 0;
    float3 *wfC = nullptr, *wfN = nullptr;      // wall faces (concatenated per body-block)
    std::vector<int> wfOff, wfCnt;              // per block
    DonorBlk* dblks = nullptr; int nDon = 0;    // donor descriptors (device)
    std::vector<DonorBlk> hdblks;               // host mirror
    int* bins = nullptr;                        // nDon * 48^3 seed bins
    Recv* rec = nullptr; float3* rpos = nullptr; int* rblk = nullptr; int* cnt = nullptr;
    long maxRecv = 0;
    char* ibPrev = nullptr;                     // previous-step iblank (overset fringe hysteresis)
    // AMR brick occupancy (per level 1..L): lattice -> pool slot (-1 empty), device
    int* latMap[4] = {nullptr, nullptr, nullptr, nullptr};
  } ga;

  // ---- AMR state ----
  struct BrickRec { int level, li, lj, lk, slot, blkIdx; };
  struct {
    int on = 0;
    double org[3], h0[3];              // base-grid origin / spacing
    int lat[4][3];                     // lattice dims per level (1..L)
    long poolCellBase = 0, poolNodeBase = 0;   // start of pool region in device arrays
    long brickNcT = 0, brickNN = 0;    // padded cells / nodes per brick slot
    std::vector<BrickRec> bricks;      // active bricks
    std::vector<int> freeSlots;
    std::vector<float*> sens;          // device per-level site sensor arrays
    int nStaticBlk = 0, nStaticPatch = 0;
    Blk* dBricks = nullptr;            // device copy of brick Blks (batched kernels)
  } amr;

  // batched-launch helpers: bricks are identical blocks appended after statics
  int staticBlks() const { return amr.on ? amr.nStaticBlk : (int)blk.size(); }
  int brickBlks() const { return (int)blk.size() - staticBlks(); }
};

inline void syncAll(Sim& s) {
  for (int d = 0; d < s.ndev; d++) { CUCHK(cudaSetDevice(d)); CUCHK(cudaDeviceSynchronize()); }
}

// io.cpp
void readConfig(const char* f, Cfg& c);
void readGrid(Sim& s);
void readBC(Sim& s);
void writeSolution(Sim& s, int iter);
void writeRestart(Sim& s, const char* f);
bool readRestart(Sim& s, const char* f);

// geom.cu
void computeGeometry(Sim& s);
void recomputeGeom(Sim& s);   // recompute cell volumes from current nodes (deformed mesh)
void blankSingular(Sim& s);   // iblank-HOLE the collapsed singular-line cells (vol_floor grids)
void computeWallDistance(Sim& s);
void setupMotion(Sim& s);
void moveMesh(Sim& s, double t);   // rotate moving blocks to angle omega*t (device+host)

// overset.cpp (CPU fallback; used for multi-GPU)
void oversetAssembleCPU(Sim& s, bool verbose = true);
void oversetFree(Sim& s);
// assembly.cu (GPU path, single device)
void gpuAsmInit(Sim& s);
void oversetAssembleGPU(Sim& s, bool verbose = true);
void buildWallFacesGPU(Sim& s);
inline void oversetAssemble(Sim& s, bool verbose = true) {
  // A purely patched multiblock grid (only match/wall/farfield/symmetry BCs, e.g. a
  // pyHyp-extruded multiblock surface) is NOT overset: its wall is one continuous
  // surface split into point-matched patches. Running hole-cutting on it wrongly
  // blanks the near-wall cells of adjacent patches (they lie "inside" a neighbor
  // patch's wall body), which corrupts the junctions and injects oscillations.
  // Skip assembly unless there are real overset BCs (or AMR bricks); device ib is
  // memset IB_ACTIVE at allocation, so every cell stays solved.
  bool hasOverset = false;
  for (auto& P : s.patch) if (P.type == BC_OVERSET) { hasOverset = true; break; }
  if (!hasOverset && !s.cfg.amr) {
    oversetFree(s);
    s.rSame.assign(s.ndev, nullptr); s.rSameN.assign(s.ndev, 0); s.rX.clear();
    for (int d = 0; d < s.ndev; d++) { CUCHK(cudaSetDevice(d)); CUCHK(cudaMemset(s.dev[d].ib, IB_ACTIVE, s.dev[d].totC)); }
    if (verbose) printf("overset: patched grid (no overset BCs) — hole-cutting skipped, all cells active\n");
    return;
  }
  if (s.ndev == 1 && s.cfg.gpuAsm) oversetAssembleGPU(s, verbose);
  else oversetAssembleCPU(s, verbose);
}
// amr.cu
void amrInit(Sim& s);
void amrAdapt(Sim& s, bool verbose = false);
void buildMatch(Sim& s);
void hostWallFaces(Sim& s, int onlyBlk, std::vector<float>& centers, std::vector<float>& normals);

// bc.cu
void applyBC(Sim& s);
void oversetExchange(Sim& s);
void oversetExchangeDq(Sim& s);   // interpolate donor Δq -> receiver Δq (implicit overset boundary coupling)
void matchExchangeDq(Sim& s);     // copy Δq into match ghosts (implicit block-seam coupling, incl. periodic seams)
void matchExchange(Sim& s);
void syncState(Sim& s);   // cons2prim -> overset -> applyBC -> matchExchange (correct ghost order)

// stats.cu — transition statistics
void accumAvg(Sim& s);                       // add current W into the running mean
void writeCf(Sim& s, const char* fname);     // span+time-averaged Cf(Re_x) along the wall
void computeWallCf(Sim& s, std::vector<float>& cf);  // per-wall-face Cf (skin-friction objective)
void wallSurfaceData(Sim& s, std::vector<float>& pts, std::vector<float>& cp, std::vector<float>& cf); // wall .vtp
void computeWallQw(Sim& s, std::vector<float>& qw);  // per-wall-face heat flux (isothermal wall)

// cuad_sa.cu — cuad-generated SA-source derivatives + GPU self-test
void cuadSaSelfTest();                        // validate generated adjoint vs FD on GPU

// adjoint.cu — discrete adjoint + field-inversion (FIML)
void betaInit(Sim& s);                       // allocate beta (=1 or from file)
void runForward(Sim& s, int niter, bool verbose);   // converge steady RANS
double objective(Sim& s);                    // J(Q, beta)
void solveAdjoint(Sim& s);                   // discrete adjoint psi
void gradient(Sim& s, std::vector<float>& g);// dJ/dbeta over interior cells
void fimlOptimize(Sim& s);                   // gradient-descent inversion of beta
void validateGradient(Sim& s);               // adjoint gradient vs finite-difference check
void loadObjRef(Sim& s);                     // reference wall pressures for cp objective

// design.cu — geometric (shape) design chain for adjoint optimization
void meshSensitivity(Sim& s, std::vector<double>& gX);  // dJ/dX = dJ/dX|_Q + psi^T dR/dX  [3*totNode]
void validateMeshSensitivity(Sim& s);        // Stage 1: dJ/dX vs re-solved finite differences
void validateFFDGradient(Sim& s);            // Stage 2: dJ/dD (FFD chain) vs re-solved FD
void ffdOptimize(Sim& s);                    // steepest-descent shape optimization over FFD design vars
void ffdEval(Sim& s);                        // single design eval (obj + dCD/dD + dCL/dD) for external optimizer

// flux.cu
void cons2prim(Sim& s);
void computeRHS(Sim& s);
void computeVortQ(Sim& s, std::vector<float>& vort, std::vector<float>& qcrit);   // output fields
void computeMut(Sim& s);
void computeSAResidual(Sim& s);   // isolated SA source term (for hand-coded reverse-mode check)
void computeConvResidual(Sim& s); // isolated convective (inviscid) residual
void convFluxJTx(Sim& s, const float* xdev, float* wbar);  // (dR_conv/dQ)^T x -> W-bar
void viscFluxJTx(Sim& s, const float* xdev, float* wbar);  // (dR_visc/dQ)^T x -> W-bar
void bcFluxJTx(Sim& s, float* wbar);   // fold ghost W-bar into interior via (dBC/dW)^T

// implicit.cu
void computeDt(Sim& s, float cfl, float dualJ);
void implicitSweeps(Sim& s);
void updateQ(Sim& s);
void rk3(Sim& s, float cfl, float dtGlobal);   // dtGlobal > 0: time-accurate uniform dt
float dtMin(Sim& s);
void addDualSource(Sim& s, float c0, float c1, float c2, float rdt);
double resNorm(Sim& s);
void resProbe(Sim& s);

// ---- pseudo-time FAS multigrid (mg.cu) ----
void mgBuild(Sim& s);                              // allocate coarse levels (call once, after geometry)
void mgFreeAll(Sim& s);
void mgVCycle(Sim& s, float cfl, float dualJ, float rdt, int bdf2);  // one V-cycle replacing implicitSweeps
void mgProbe(Sim& s);   // print worst-residual cells + iblank context (divergence localization)
void mgMoveNodes(Sim& s); // re-subsample coarse nodes of moving blocks after moveMesh (rigid rotation)

// ---- diagonalized ADI (dadi.cu) ----
float dadiSelfTest();   // validate T·Λ·T^{-1} eigenvector transforms (returns max error; ~<1e-3 = OK)
void dadiSolve(Sim& s); // one diagonalized-ADI factored implicit solve (fills dq)
void trackParticles(Sim& s);   // Euler-Lagrange tracking through the frozen (steady) gas
void initParticles(Sim& s);    // allocate + inject the particle set (persists across steps)
void advanceParticlesCoupled(Sim& s, float dt);  // advance particles dt + scatter reaction into part.src
void addPartSource(Sim& s);    // add the accumulated particle reaction source to the gas RHS (D.r)
void freeParticles(Sim& s);
void dumpParticles(Sim& s, FILE* fp, int step, double t);
void forces(Sim& s, double F[3]);
void initFlow(Sim& s);
void shiftTimeLevels(Sim& s);
