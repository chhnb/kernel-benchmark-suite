#include <hip/hip_runtime.h>
#include <math.h>
#include <stdlib.h>
__global__ void flux(double *d_th, double gg, double rn, int* d_inf, double* d_h, int* d_infx, int* d_infy, \
	double* d_baseo, double* d_um, double* d_hm, double* d_uu1, double* d_umo, double* d_vv1, \
	double* d_vva, double* d_vn, double*d_hn, double* d_vno, double* d_uua, \
	double* ho, int N, int cols, int rows, double dx, double dy, double dt2)
{
	double hhn, hhs, hhnp, hhsp, hhe, hhw, hhep, hhwp, hhan, sgnm, hh3, u13, u11uur, u11uul, umr, uml, \
		u11, u12vvu, u12vvd, umu, umd, u12, sqx, ram, v13, v11, v11uur, v11uul, vnr, vnl, v12vvu, v12vvd, vnu, vnd, v12, sqy;

	int f_id = blockDim.x*blockIdx.x + threadIdx.x;

	while (f_id < N){
		int inj = f_id % cols;
		int ini = f_id / cols;

		//      ----------------------
		//      X - DIRECTION
		//      ----------------------

		if (ini > 0 && ini < rows) {
			if (d_inf[f_id] != 0) {
				if (d_inf[f_id - cols] != 0){
					if ((d_h[f_id - cols] > d_th[0]) || (d_h[f_id] > d_th[0])){
						if (d_infx[f_id] != 1){
							hhe = d_h[f_id] + d_baseo[f_id];
							hhw = d_h[f_id - cols] + d_baseo[f_id - cols];
							hhep = d_h[f_id] - d_th[0];
							hhwp = d_h[f_id - cols] - d_th[0];

							//      ----------------------
							//      DRY BED TREATMENT (1)
							//      ----------------------

							if (hhe<d_baseo[f_id - cols]){
								if (d_h[f_id - cols]>d_th[0]){
									d_um[f_id] = 0.5440*d_h[f_id - cols] * sqrt(gg*d_h[f_id - cols]);
								}
								else{
									d_um[f_id] = 0;
								}
							}
							else if (hhw < d_baseo[f_id]){
								if (d_h[f_id]>d_th[0]){
									d_um[f_id] = -0.544*d_h[f_id] * sqrt(gg*d_h[f_id]);
								}
								else{
									d_um[f_id] = 0;
								}
							}
							//      ----------------------
							//      DRY BED TREATMENT (2)
							//      ----------------------
							else if (hhep*hhwp < 0){
								if ((d_h[f_id]>0) || (d_h[f_id - cols]>0)){
									hhan = hhep - hhwp;
									sgnm = hhan / abs(hhan);
									hh3 = fmax((d_h[f_id] + d_baseo[f_id]), (d_h[f_id - cols] + d_baseo[f_id - cols])) - fmax(d_baseo[f_id], d_baseo[f_id - cols]);
									d_um[f_id] = -sgnm*0.350*hh3*sqrt(2.00*gg*hh3);
								}
								else{
									d_um[f_id] = 0;
								}
							}

							else{

								//      ----------------------
								//      GRAVITY TERM
								//      ----------------------
								u13 = gg*d_hm[f_id] * (dt2 / dx)*(d_h[f_id] + d_baseo[f_id] - d_h[f_id - cols] - d_baseo[f_id - cols]);

								//      ----------------------
								//      CONVECTION TERM
								//      ----------------------

								u11uur = 0.50*(d_uu1[f_id + cols] + d_uu1[f_id]);
								u11uul = 0.50*(d_uu1[f_id] + d_uu1[f_id - cols]);
								umr = u11uur*(d_umo[f_id + cols] + d_umo[f_id])*0.50 + abs(u11uur)*(d_umo[f_id] - d_umo[f_id + cols])*0.50;
								uml = u11uul*(d_umo[f_id] + d_umo[f_id - cols])*0.50 + abs(u11uul)*(d_umo[f_id - cols] - d_umo[f_id])*0.50;
								u11 = (dt2 / dx)*(umr - uml);

								if (inj == 0){
									u12 = 0;
								}
								else if (inj == cols){
									u12 = 0;
								}
								else{
									u12vvu = 0.50*(d_vv1[f_id + 1] + d_vv1[f_id - cols + 1]);
									u12vvd = 0.50*(d_vv1[f_id] + d_vv1[f_id - cols]);
									umu = u12vvu*(d_umo[f_id + 1] + d_umo[f_id])*0.50 + abs(u12vvu)*(d_umo[f_id] - d_umo[f_id + 1])*0.50;
									umd = u12vvd*(d_umo[f_id - 1] + d_umo[f_id])*0.50 + abs(u12vvd)*(d_umo[f_id - 1] - d_umo[f_id])*0.50;
									u12 = (dt2 / dy)*(umu - umd);
								}
								//      ----------------------
								//      FRICTION TERM
								//      ----------------------
								sqx = sqrt(d_uu1[f_id] * d_uu1[f_id] + d_vva[f_id] * d_vva[f_id]);
								double expx = pow(double(d_hm[f_id]), double(1.3333330));
								ram = gg*rn*rn*sqx / expx;
								if (d_hm[f_id] <= d_th[0]){
									ram = 0.00;
								}
								//      ----------------------
								//      UM
								//      ----------------------
								d_um[f_id] = ((1.00 - dt2*ram*0.50)*d_umo[f_id] + (-u11 - u12 - u13)) / (1.00 + dt2*ram*0.50);
							}

						}
						else{
							d_um[f_id] = 0;
						}
					}
					else{
						d_um[f_id] = 0;
					}
				}
				else{
					d_um[f_id] = 0;
				}
			}
			else{
				d_um[f_id] = 0;
			}
		}
		else{
			d_um[f_id] = 0;
		}


		//      ----------------------
		//      Y - DIRECTION
		//      ----------------------

		if (inj > 0 && inj < cols) {
			if (d_inf[f_id] != 0) {
				if (d_inf[f_id - 1] != 0){
					if ((d_h[f_id - 1] > d_th[0]) || (d_h[f_id] > d_th[0])){
						if (d_infy[f_id] != 1){
							hhn = d_h[f_id] + d_baseo[f_id];
							hhs = d_h[f_id - 1] + d_baseo[f_id - 1];
							hhnp = d_h[f_id] - d_th[0];
							hhsp = d_h[f_id - 1] - d_th[0];


							//      ----------------------
							//      DRY BED TREATMENT (1)
							//      ----------------------

							if (hhn<d_baseo[f_id - 1]){
								if (d_h[f_id - 1]>d_th[0]){
									d_vn[f_id] = 0.5440*d_h[f_id - 1] * sqrt(gg*d_h[f_id - 1]);
								}
								else{
									d_vn[f_id] = 0;
								}
							}
							else if (hhs < d_baseo[f_id]){
								if (d_h[f_id]>d_th[0]){
									d_vn[f_id] = -0.544*d_h[f_id] * sqrt(gg*d_h[f_id]);
								}
								else{
									d_vn[f_id] = 0;
								}
							}
							//      ----------------------
							//      DRY BED TREATMENT (2)
							//      ----------------------
							else if (hhnp*hhsp < 0){
								if ((d_h[f_id]>0) || (d_h[f_id - 1]>0)){
									hhan = hhnp - hhsp;
									sgnm = hhan / abs(hhan);
									hh3 = fmax((d_h[f_id] + d_baseo[f_id]), (d_h[f_id - 1] + d_baseo[f_id - 1])) - fmax(d_baseo[f_id], d_baseo[f_id - 1]);
									d_vn[f_id] = -sgnm*0.350*hh3*sqrt(2.00*gg*hh3);
								}
								else{
									d_vn[f_id] = 0;
								}
							}

							else{

								//      ----------------------
								//      GRAVITY TERM
								//      ----------------------
								v13 = gg*d_hn[f_id] * (dt2 / dy)*(d_h[f_id] + d_baseo[f_id] - d_h[f_id - 1] - d_baseo[f_id - 1]);

								//      ----------------------
								//      CONVECTION TERM
								//      ----------------------			

								if (ini == 0){
									v11 = 0;
								}
								else if (ini == rows){
									v11 = 0;
								}
								else{
									v11uur = 0.50*(d_uu1[f_id + cols] + d_uu1[f_id + cols - 1]);
									v11uul = 0.50*(d_uu1[f_id] + d_uu1[f_id - 1]);
									vnr = v11uur*(d_vno[f_id + cols] + d_vno[f_id])*0.50 + abs(v11uur)*(d_vno[f_id] - d_vno[f_id + cols])*0.50;
									vnl = v11uul*(d_vno[f_id] + d_vno[f_id - cols])*0.50 + abs(v11uul)*(d_vno[f_id - cols] - d_vno[f_id])*0.50;
									v11 = (dt2 / dx)*(vnr - vnl);
								}

								v12vvu = 0.50*(d_vv1[f_id + 1] + d_vv1[f_id]);
								v12vvd = 0.50*(d_vv1[f_id] + d_vv1[f_id - 1]);
								vnu = v12vvu*(d_vno[f_id + 1] + d_vno[f_id])*0.50 + abs(v12vvu)*(d_vno[f_id] - d_vno[f_id + 1])*0.50;
								vnd = v12vvd*(d_vno[f_id - 1] + d_vno[f_id])*0.50 + abs(v12vvd)*(d_vno[f_id - 1] - d_vno[f_id])*0.50;
								v12 = (dt2 / dy)*(vnu - vnd);
								//      ----------------------
								//      FRICTION TERM
								//      ----------------------
								sqy = sqrt(d_uua[f_id] * d_uua[f_id] + d_vv1[f_id] * d_vv1[f_id]);
								double expy = pow(double(d_hn[f_id]), double(1.3333330));
								ram = gg*rn*rn*sqy / expy;
								if (d_hn[f_id] <= d_th[0]){
									ram = 0.00;
								}
								//      ----------------------
								//      VN
								//      ----------------------
								d_vn[f_id] = ((1.00 - dt2*ram*0.50)*d_vno[f_id] + (-v11 - v12 - v13)) / (1.00 + dt2*ram*0.50);
							}

						}
						else{
							d_vn[f_id] = 0;
						}
					}
					else{
						d_vn[f_id] = 0;
					}
				}
				else{
					d_vn[f_id] = 0;
				}
			}
			else{
				d_vn[f_id] = 0;
			}
		}
		else{
			d_vn[f_id] = 0;
		}

		//      +++++++++++++++++++++++++++++++++++++++++++
		//      CONTINUITY EQUATION
		//      +++++++++++++++++++++++++++++++++++++++++++

		//      +++++++++++++++++++++++++++++++++++++++++++


		f_id += gridDim.x * blockDim.x;
	}

}

