// Euler-Lagrange dispersed-particle / droplet tracking (one-way coupled).
// After the Eulerian gas field is converged, disperse particles are advected
// through the FROZEN gas: Schiller-Naumann drag + Ranz-Marshall convective heat,
// integrated with a stiffness-robust exponential integrator, located on the
// curvilinear grid by an incremental Newton walk.  Single block.
#include "common.h"
#include "metrics.cuh"
#include <vector>
#include <cstdio>
#include <cmath>
#include <algorithm>

// primitive layout in D.w: [rho, u, v, w, p, nut]
// ---- trilinear inverse map: natural coords (s,t,u) of point p in the hex of 8 corners
__device__ inline bool pNewton(const float P[8][3], float px, float py, float pz,
                               float& s, float& t, float& u) {
  s = t = u = 0.5f;
  for (int it = 0; it < 12; it++) {
    float w[8]  = { (1-s)*(1-t)*(1-u), s*(1-t)*(1-u), (1-s)*t*(1-u), s*t*(1-u),
                    (1-s)*(1-t)*u,     s*(1-t)*u,     (1-s)*t*u,     s*t*u };
    float ws[8] = { -(1-t)*(1-u), (1-t)*(1-u), -t*(1-u), t*(1-u), -(1-t)*u, (1-t)*u, -t*u, t*u };
    float wt[8] = { -(1-s)*(1-u), -s*(1-u), (1-s)*(1-u), s*(1-u), -(1-s)*u, -s*u, (1-s)*u, s*u };
    float wu[8] = { -(1-s)*(1-t), -s*(1-t), -(1-s)*t, -s*t, (1-s)*(1-t), s*(1-t), (1-s)*t, s*t };
    float F[3] = {-px,-py,-pz}, Js[3]={0,0,0}, Jt[3]={0,0,0}, Ju[3]={0,0,0};
    #pragma unroll
    for (int c = 0; c < 8; c++)
      #pragma unroll
      for (int m = 0; m < 3; m++) { F[m]+=w[c]*P[c][m]; Js[m]+=ws[c]*P[c][m]; Jt[m]+=wt[c]*P[c][m]; Ju[m]+=wu[c]*P[c][m]; }
    float det = Js[0]*(Jt[1]*Ju[2]-Jt[2]*Ju[1]) - Jt[0]*(Js[1]*Ju[2]-Js[2]*Ju[1]) + Ju[0]*(Js[1]*Jt[2]-Js[2]*Jt[1]);
    if (fabsf(det) < 1e-30f) return false;
    float di = 1.f/det;
    float ds = -( F[0]*(Jt[1]*Ju[2]-Jt[2]*Ju[1]) - Jt[0]*(F[1]*Ju[2]-F[2]*Ju[1]) + Ju[0]*(F[1]*Jt[2]-F[2]*Jt[1]) )*di;
    float dt = -( Js[0]*(F[1]*Ju[2]-F[2]*Ju[1]) - F[0]*(Js[1]*Ju[2]-Js[2]*Ju[1]) + Ju[0]*(Js[1]*F[2]-Js[2]*F[1]) )*di;
    float du = -( Js[0]*(Jt[1]*F[2]-Jt[2]*F[1]) - Jt[0]*(Js[1]*F[2]-Js[2]*F[1]) + F[0]*(Js[1]*Jt[2]-Js[2]*Jt[1]) )*di;
    s+=ds; t+=dt; u+=du;
    if (fabsf(ds)+fabsf(dt)+fabsf(du) < 1e-6f) break;
  }
  return true;
}

// incremental walk: find the CELL (i,j,k) whose node-hex contains (px,py,pz), from the
// seed cell.  Returns -1 if found (s,t,u valid); else the boundary face code it exited
// (0 imin,1 imax,2 jmin,3 jmax,4 kmin,5 kmax) with ci,cj,ck left at the adjacent cell.
__device__ inline int pWalk(const Blk& B, const float* x, const float* y, const float* z,
                            float px, float py, float pz, int& ci, int& cj, int& ck,
                            float& s, float& t, float& u) {
  int nic = B.ni, njc = B.nj, nkc = B.nk;   // B.ni/nj/nk are CELL counts (niN=ni+1 nodes)
  ci = min(max(ci,0),nic-1); cj = min(max(cj,0),njc-1); ck = min(max(ck,0),nkc-1);
  for (int hop = 0; hop < 300; hop++) {
    float P[8][3];
    #pragma unroll
    for (int c = 0; c < 8; c++) {
      int ii = ci + (c&1), jj = cj + ((c>>1)&1), kk = ck + ((c>>2)&1);
      long n = B.noff + nidx(B, ii, jj, kk);
      P[c][0] = x[n]; P[c][1] = y[n]; P[c][2] = z[n];
    }
    if (!pNewton(P, px, py, pz, s, t, u)) return 2;   // degenerate -> treat as jmin (wall) hit
    const float lo = -1e-4f, hi = 1.f+1e-4f;
    int di = (s < lo) ? -1 : (s > hi) ? 1 : 0;
    int dj = (t < lo) ? -1 : (t > hi) ? 1 : 0;
    int dk = (u < lo) ? -1 : (u > hi) ? 1 : 0;
    if (!di && !dj && !dk) { s=fminf(fmaxf(s,0.f),1.f); t=fminf(fmaxf(t,0.f),1.f); u=fminf(fmaxf(u,0.f),1.f); return -1; }
    int ni2 = ci+di, nj2 = cj+dj, nk2 = ck+dk;
    if (ni2<0)    return 0;  if (ni2>=nic) return 1;   // exited a boundary -> report the face
    if (nj2<0)    return 2;  if (nj2>=njc) return 3;
    if (nk2<0)    return 4;  if (nk2>=nkc) return 5;
    ci = ni2; cj = nj2; ck = nk2;
  }
  return -1;
}

// reflective boundary patch for particles (wall / symmetry / periodic-span)
struct ReflFace { int face, a0, a1, b0, b1, kind; };   // kind: 0 wall, 1 mirror (symmetry/match)

// outward unit normal + face-center of face f of cell (ci,cj,ck)
__device__ inline void faceNormalOut(const Blk& B, const float* x, const float* y, const float* z,
                                     int f, int ci, int cj, int ck, float n[3]) {
  float S[3], C[3];
  if      (f==0) faceI(B,x,y,z, ci,   cj, ck, S,C);
  else if (f==1) faceI(B,x,y,z, ci+1, cj, ck, S,C);
  else if (f==2) faceJ(B,x,y,z, ci, cj,   ck, S,C);
  else if (f==3) faceJ(B,x,y,z, ci, cj+1, ck, S,C);
  else if (f==4) faceK(B,x,y,z, ci, cj, ck,   S,C);
  else           faceK(B,x,y,z, ci, cj, ck+1, S,C);
  float CC[3]; cellCenter(B,x,y,z, ci,cj,ck, CC);
  float dx=C[0]-CC[0], dy=C[1]-CC[1], dz=C[2]-CC[2];
  float m = rsqrtf(dx*dx+dy*dy+dz*dz + 1e-30f);
  n[0]=dx*m; n[1]=dy*m; n[2]=dz*m;   // points from cell center toward the face = outward
}

// one thread per particle: advance it partSub sub-steps of size dt/partSub through the frozen gas
__global__ void partPushK(Blk B, const float* __restrict__ w, const float* __restrict__ x,
                          const float* __restrict__ y, const float* __restrict__ z,
                          float* px, float* py, float* pz, float* pu, float* pv, float* pw,
                          float* pT, const float* pd, int* pic, int* pjc, int* pkc, char* alive,
                          int np, float rhoP, float muinf, float Sc, float dt, int sub, int heat,
                          const ReflFace* refl, int nRefl, int wallModel, float en, float et, float vcrit,
                          float* psrc, float npp, int twoWay) {
  int p = blockIdx.x*blockDim.x + threadIdx.x;
  if (p >= np || alive[p]!=1) return;
  long o = (long)NV*B.coff, ncT = B.ncT;
  float X=px[p],Y=py[p],Z=pz[p], U=pu[p],V=pv[p],W=pw[p], Tp=pT[p], dp=pd[p];
  int ci=pic[p], cj=pjc[p], ck=pkc[p];
  float dts = dt/sub;
  const float Pr = 0.72f, cpg = 1.f/GM1;    // gas specific heat (nondim)
  float mp = rhoP*(float)M_PI/6.f*dp*dp*dp; // particle mass; parcel mass = npp*mp
  float wt = npp*mp/dt;                       // scatter weight: impulse over dt -> reaction force/rate
  for (int ss = 0; ss < sub; ss++) {
    // (1) locate the particle's current (in-domain) cell for the gas sample
    float s,t,u;
    if (pWalk(B, x, y, z, X, Y, Z, ci, cj, ck, s, t, u) >= 0) { alive[p]=0; break; }  // fell out
    long c = cidx(B, ci, cj, ck);
    float rho = w[o+c], ug = w[o+ncT+c], vg = w[o+2*ncT+c], wg = w[o+3*ncT+c], pg = w[o+4*ncT+c];
    float Tg = GAM*pg/fmaxf(rho,1e-8f);
    float mug = sutherland(Tg, muinf, Sc);
    float dux=ug-U, duy=vg-V, duz=wg-W;
    float dmag = sqrtf(dux*dux+duy*duy+duz*duz) + 1e-20f;
    float Rep = rho*dmag*dp/fmaxf(mug,1e-30f);
    float f = 1.f + 0.15f*powf(Rep, 0.687f);            // Schiller-Naumann drag correction
    float tauP = rhoP*dp*dp/(18.f*fmaxf(mug,1e-30f));   // Stokes response time
    float c1 = expf(-f*dts/tauP);                        // exponential (unconditionally stable)
    float ptau = tauP/f*(1.f-c1);
    // (2) tentative move (exact integral of the exponentially-relaxing velocity)
    float Xn = X + ug*dts - dux*ptau, Yn = Y + vg*dts - duy*ptau, Zn = Z + wg*dts - duz*ptau;
    float Un = ug - dux*c1, Vn = vg - duy*c1, Wn = wg - duz*c1;
    // heat exchange this sub-step (Ranz-Marshall); needed before the two-way scatter
    float Tpn = Tp;
    if (heat) {
      float Nu = 2.f + 0.6f*sqrtf(Rep)*powf(Pr, 1.f/3.f);
      float tauT = tauP*1.5f*Pr*(2.f/Nu);
      Tpn = Tg - (Tg-Tp)*expf(-dts/tauT);
    }
    // (2b) TWO-WAY: scatter the gas->particle momentum & energy exchange back onto the gas cell
    if (twoWay && psrc) {
      float dPx = wt*(Un-U), dPy = wt*(Vn-V), dPz = wt*(Wn-W);      // reaction rate = parcel Δp / dt
      float dKE = 0.5f*wt*((Un*Un+Vn*Vn+Wn*Wn)-(U*U+V*V+W*W));
      float dTh = wt*cpg*(Tpn-Tp);                                  // cpp/cpg=1
      atomicAdd(&psrc[0*ncT+c], dPx); atomicAdd(&psrc[1*ncT+c], dPy); atomicAdd(&psrc[2*ncT+c], dPz);
      atomicAdd(&psrc[3*ncT+c], dKE+dTh);
    }
    Tp = Tpn;                                   // commit heat (bounce or move, heat already happened)
    // (3) did the new position cross a boundary? locate it (from the current cell)
    int ci2=ci,cj2=cj,ck2=ck; float s2,t2,u2;
    int fx = pWalk(B, x, y, z, Xn, Yn, Zn, ci2, cj2, ck2, s2, t2, u2);
    if (fx >= 0) {
      int a,b;
      if      (fx<2){a=cj2;b=ck2;} else if (fx<4){a=ck2;b=ci2;} else {a=ci2;b=cj2;}
      int kind = -1;
      for (int r=0;r<nRefl;r++) if (refl[r].face==fx &&
          a>=refl[r].a0&&a<=refl[r].a1&&b>=refl[r].b0&&b<=refl[r].b1) { kind=refl[r].kind; break; }
      if (kind < 0) { X=Xn;Y=Yn;Z=Zn; alive[p]=0; break; }     // farfield/outlet -> leaves domain
      float n[3]; faceNormalOut(B,x,y,z, fx, ci2,cj2,ck2, n);
      float vn = Un*n[0]+Vn*n[1]+Wn*n[2];                       // outward-normal velocity
      if (kind==0 && wallModel && vcrit>0.f && fabsf(vn) < vcrit) { alive[p]=2; break; } // deposit (stick, stay at X)
      if (kind==0 && wallModel) {                               // rebound: tangential*et, normal reversed*en
        U = et*(Un-vn*n[0]) - en*vn*n[0]; V = et*(Vn-vn*n[1]) - en*vn*n[1]; W = et*(Wn-vn*n[2]) - en*vn*n[2];
      } else if (kind==0) { X=Xn;Y=Yn;Z=Zn; alive[p]=0; break; } // wall, no rebound model -> absorbed
      else { U = Un-2.f*vn*n[0]; V = Vn-2.f*vn*n[1]; W = Wn-2.f*vn*n[2]; }  // mirror
      // keep position at X (just inside); the reflected velocity carries it away next sub-step
      continue;
    }
    // (4) commit the move
    X=Xn; Y=Yn; Z=Zn; U=Un; V=Vn; W=Wn; ci=ci2; cj=cj2; ck=ck2;
  }
  px[p]=X; py[p]=Y; pz[p]=Z; pu[p]=U; pv[p]=V; pw[p]=W; pT[p]=Tp; pic[p]=ci; pjc[p]=cj; pkc[p]=ck;
}

