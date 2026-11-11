__global__ void cuAdvectionMSWEsCartesianKernel(Scalar* gravity, Scalar* h, Scalar* _h_bound, Scalar* z, Scalar* _z_bound, Vector* z_gradient, Vector* hU, Vector* _hU_bound, unsigned int phi_size, ShortDualHandle* cell_neigbours, unsigned int cell_neighbours_length, Scalar* cell_volume, Scalar* h_advection, Vector* hU_advection){

      unsigned int index = blockDim.x * blockIdx.x + threadIdx.x;
      Scalar h_small = 1e-10;
      Vector2 face_normal[4];
      Vector2 face_shear[4];
      face_normal[0] = Vector2(0.0, -1.0);
      face_normal[1] = Vector2(1.0, 0.0);
      face_normal[2] = Vector2(0.0, 1.0);
      face_normal[3] = Vector2(-1.0, 0.0);
      face_shear[0] = Vector2(1.0, 0.0);
      face_shear[1] = Vector2(0.0, 1.0);
      face_shear[2] = Vector2(-1.0, 0.0);
      face_shear[3] = Vector2(0.0, -1.0);
      while (index < phi_size){
        Scalar g_this = gravity[index];
        Scalar h_this = h[index];
        Scalar z_this = z[index];
        Vector2 _z_gradient_this = z_gradient[index];
        Scalar eta_this = h_this + z_this;
        Vector2 hU_this = hU[index];
        Vector2 u_this = 0.0;
        if (h_this < h_small){
          u_this = 0.0;
        }
        else{
          u_this = hU_this / h_this;
        }
        Scalar volume = cell_volume[index];
        Scalar area = sqrt(volume);
        Scalar _h_advection(0.0);
        Scalar _h_advection_constraint(0.0);
        Vector2 _hU_advection(0.0, 0.0);
        for (Flag i = 0; i < 4; ++i){
          Vector2 normal = face_normal[i];
          Vector2 shear = face_shear[i];
          ShortDualHandle neib = cell_neigbours[i*cell_neighbours_length + index];
          Scalar g_neib = 0.0;
          Scalar h_neib = 0.0;
          Scalar z_neib = 0.0;
          Vector2 hU_neib = 0.0;
          Vector2 _z_gradient_neib = 0.0;
          if (!neib.is_boundary()){
            Flag id_neib = neib.get_global_id();
            g_neib = gravity[id_neib];
            h_neib = h[id_neib];
            z_neib = z[id_neib];
            hU_neib = hU[id_neib];
            _z_gradient_neib = z_gradient[id_neib];
          }
          else{
            Flag id_boundary = neib.get_global_id();
            g_neib = g_this;
            h_neib = _h_bound[id_boundary];
            z_neib = _z_bound[id_boundary];
            hU_neib = _hU_bound[id_boundary];
          }
          if (h_this < h_small && h_neib < h_small){
            continue;
          }
          Scalar eta_neib = z_neib + h_neib;
          Vector2 u_neib = 0.0;
          if (h_neib < h_small){
            u_neib = 0.0;
          }
          else{
            u_neib = hU_neib / h_neib;
          }
          Vector2 direction_this = 0.5*normal*area;
          Vector2 direction_neib = -0.5*normal*area;
          Scalar _z_this = z_this + dot(_z_gradient_this, direction_this);
          Scalar _z_neib = z_neib + dot(_z_gradient_neib, direction_neib);
          Scalar z_f = fmax(z_this, z_neib);
          Scalar delta_z = 0.0;
          Scalar dz_clip = _z_neib - _z_this;
          if (neib.is_boundary()){
            dz_clip = 0.0;
          }
          Scalar dz = z_neib - z_this - dz_clip;
          Scalar deta_this = fmax(0.0, fmin(dz, eta_neib - eta_this));
          Scalar deta_neib = fmax(0.0, fmin(-dz, - eta_neib + eta_this));
          Scalar eta_L = eta_this + deta_this;
          Scalar eta_R = eta_neib + deta_neib;
          Scalar h_L = fmax(0.0, eta_L - z_f);
          Scalar h_R = fmax(0.0, eta_R - z_f);
          Vector2 u_L(dot(u_this, normal), dot(u_this, shear));
          Vector2 u_R(dot(u_neib, normal), dot(u_neib, shear));
          Scalar g = 0.5*(g_this + g_neib);
          auto flux = cuHLLCRiemannSolverSWEs(g, ScalarRiemannState(h_L, h_R), VectorRiemannState(h_L*u_L, h_R*u_R));
          Scalar _h_flux = flux.h;
          Vector2 _hU_flux = (flux.q.x*normal + flux.q.y*shear);
          if (h_neib < h_small){
            delta_z = fmax(0.0, z_f - eta_this);
          }
          else{
            delta_z = fmax(0.0, fmin(dz_clip, z_f - eta_this));
          }
          z_f -= delta_z;
          Vector2 _z_flux = 0.5*g*(h_L + h_this)*(z_f - z_this)*normal;
          _h_advection += _h_flux*area / volume;
          _hU_advection += (_hU_flux + _z_flux)*area / volume;
        }
        h_advection[index] = _h_advection;
        hU_advection[index] = _hU_advection;
        __syncthreads();
        index += blockDim.x * gridDim.x;
      }
    }