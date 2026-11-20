__global__ __launch_bounds__(729) void kernelPixelDetector( Geometry geo,
        float* detector,
        const int currProjSetNumber,
        const int totalNoOfProjections,
        cudaTextureObject_t tex){
    
    
    unsigned long long u = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned long long v = blockIdx.y * blockDim.y + threadIdx.y;
    unsigned long long projNumber=threadIdx.z;
    
    
    if (u>= geo.nDetecU || v>= geo.nDetecV || projNumber>=PROJ_PER_BLOCK)
        return;
    
#if IS_FOR_MATLAB_TIGRE
    size_t idx =  (size_t)(u * (unsigned long long)geo.nDetecV + v)+ projNumber*(unsigned long long)geo.nDetecV *(unsigned long long)geo.nDetecU ;
#else
    size_t idx =  (size_t)(v * (unsigned long long)geo.nDetecU + u)+ projNumber*(unsigned long long)geo.nDetecV *(unsigned long long)geo.nDetecU ;
#endif
    unsigned long indAlpha = currProjSetNumber*PROJ_PER_BLOCK+projNumber;  // This is the ABSOLUTE projection number in the projection array (for a given GPU)

    if(indAlpha>=totalNoOfProjections)
        return;
    
    Point3D uvOrigin = projParamsArrayDev[4*projNumber];  // 6*projNumber because we have 6 Point3D values per projection
    Point3D deltaU = projParamsArrayDev[4*projNumber+1];
    Point3D deltaV = projParamsArrayDev[4*projNumber+2];
    Point3D source = projParamsArrayDev[4*projNumber+3];
    
    /////// Get coordinates XYZ of pixel UV
    unsigned long pixelV = geo.nDetecV-v-1;
    unsigned long pixelU = u;
    Point3D pixel1D;
    pixel1D.x=(uvOrigin.x+pixelU*deltaU.x+pixelV*deltaV.x);
    pixel1D.y=(uvOrigin.y+pixelU*deltaU.y+pixelV*deltaV.y);
    pixel1D.z=(uvOrigin.z+pixelU*deltaU.z+pixelV*deltaV.z);
    ///////
    // Siddon's ray-voxel intersection, optimized as in doi=10.1.1.55.7516
    //////
    // Also called Jacobs algorithms
    Point3D ray;
    // vector of Xray
    ray.x=pixel1D.x-source.x;
    ray.y=pixel1D.y-source.y;
    ray.z=pixel1D.z-source.z;
    float eps=0.001;
    ray.x=(fabsf(ray.x)<eps)? 0 : ray.x;
    ray.y=(fabsf(ray.y)<eps)? 0 : ray.y; 
    ray.z=(fabsf(ray.z)<eps)? 0 : ray.z; 
    // This variables are ommited because
    // bx,by,bz ={0,0,0}
    // dx,dy,dz ={1,1,1}
    // compute parameter values for x-ray parametric equation. eq(3-10)
    float axm,aym,azm;
    float axM,ayM,azM;
    // In the paper Nx= number of X planes-> Nvoxel+1
   
    axm=fminf(__fdividef(-source.x,ray.x),__fdividef(geo.nVoxelX-source.x,ray.x));
    aym=fminf(__fdividef(-source.y,ray.y),__fdividef(geo.nVoxelY-source.y,ray.y));
    azm=fminf(__fdividef(-source.z,ray.z),__fdividef(geo.nVoxelZ-source.z,ray.z));
    axM=fmaxf(__fdividef(-source.x,ray.x),__fdividef(geo.nVoxelX-source.x,ray.x));
    ayM=fmaxf(__fdividef(-source.y,ray.y),__fdividef(geo.nVoxelY-source.y,ray.y));
    azM=fmaxf(__fdividef(-source.z,ray.z),__fdividef(geo.nVoxelZ-source.z,ray.z));
    
    float am=fmaxf(fmaxf(axm,aym),azm);
    float aM=fminf(fminf(axM,ayM),azM);
    
    // line intersects voxel space ->   am<aM
    // The ray never enters the volume. RETURN HERE. Without it, execution
    // falls into the index block below, whose imin..kmax are only meaningful
    // for a ray that does enter. For a ray the eps guard has snapped to run
    // exactly along one voxel axis, with the source OUTSIDE the volume on
    // one of its zero axes, the two quotients for that axis share a sign, so
    // fminf and fmaxf collapse (axm == axM == -inf) and aM inherits -inf.
    // The other zero component then gives aM*ray = (-inf)*0 = NaN, Np is
    // NaN, and (unsigned long)NaN is 2^63 on CUDA: that thread iterates
    // ~9e18 times and the kernel never returns -- 100% SM, idle memory
    // controller, no error, no result. Measured: 2 rays in 261 million on an
    // odd x odd detector with an off-axis object; see
    // Python/tests/test_siddon_missing_ray.py and
    // Frontispiece/siddon_missed_ray_hang.png. A NEGATIVE Np does not do
    // this -- CUDA saturates negatives and -inf to 0, a zero-trip loop.
    if (am>=aM){
        detector[idx]=0;
        return;
    }

    // Compute max/min image INDEX for intersection eq(11-19)
    // Discussion about ternary operator in CUDA: https://stackoverflow.com/questions/7104384/in-cuda-why-is-a-b010-more-efficient-than-an-if-else-version
    float imin,imax,jmin,jmax,kmin,kmax;
    // for X
    if( source.x<pixel1D.x){
        imin=(am==axm)? 1.0f             : ceilf (source.x+am*ray.x);
        imax=(aM==axM)? geo.nVoxelX      : floorf(source.x+aM*ray.x);
    }else{
        imax=(am==axm)? geo.nVoxelX-1.0f : floorf(source.x+am*ray.x);
        imin=(aM==axM)? 0.0f             : ceilf (source.x+aM*ray.x);
    }
    // for Y
    if( source.y<pixel1D.y){
        jmin=(am==aym)? 1.0f             : ceilf (source.y+am*ray.y);
        jmax=(aM==ayM)? geo.nVoxelY      : floorf(source.y+aM*ray.y);
    }else{
        jmax=(am==aym)? geo.nVoxelY-1.0f : floorf(source.y+am*ray.y);
        jmin=(aM==ayM)? 0.0f             : ceilf (source.y+aM*ray.y);
    }
    // for Z
    if( source.z<pixel1D.z){
        kmin=(am==azm)? 1.0f             : ceilf (source.z+am*ray.z);
        kmax=(aM==azM)? geo.nVoxelZ      : floorf(source.z+aM*ray.z);
    }else{
        kmax=(am==azm)? geo.nVoxelZ-1.0f : floorf(source.z+am*ray.z);
        kmin=(aM==azM)? 0.0f             : ceilf (source.z+aM*ray.z);
    }
    
    // get intersection point N1. eq(20-21) [(also eq 9-10)]
    float ax,ay,az;
    ax=(source.x<pixel1D.x)?  __fdividef(imin-source.x,ray.x) :  __fdividef(imax-source.x,ray.x);
    ay=(source.y<pixel1D.y)?  __fdividef(jmin-source.y,ray.y) :  __fdividef(jmax-source.y,ray.y);
    az=(source.z<pixel1D.z)?  __fdividef(kmin-source.z,ray.z) :  __fdividef(kmax-source.z,ray.z);
    
    // If its Infinite (i.e. ray is parallel to axis), make sure its positive
    ax=(isinf(ax))? abs(ax) : ax;
    ay=(isinf(ay))? abs(ay) : ay;
    az=(isinf(az))? abs(az) : az;    
       
    
    // get index of first intersection. eq (26) and (19)
    unsigned long i,j,k;
    float aminc=fminf(fminf(ax,ay),az);
    i=(unsigned long)floorf(source.x+ (aminc+am)*0.5f*ray.x);
    j=(unsigned long)floorf(source.y+ (aminc+am)*0.5f*ray.y);
    k=(unsigned long)floorf(source.z+ (aminc+am)*0.5f*ray.z);
    // Initialize
    float ac=am;
    //eq (28), unit anlges
    float axu,ayu,azu;
    axu=__frcp_rd(fabsf(ray.x));
    ayu=__frcp_rd(fabsf(ray.y));
    azu=__frcp_rd(fabsf(ray.z));
    // eq(29), direction of update
    float iu,ju,ku;
    iu=(source.x< pixel1D.x)? 1.0f : -1.0f;
    ju=(source.y< pixel1D.y)? 1.0f : -1.0f;
    ku=(source.z< pixel1D.z)? 1.0f : -1.0f;
    
    float maxlength=__fsqrt_rd(ray.x*ray.x*geo.dVoxelX*geo.dVoxelX+ray.y*ray.y*geo.dVoxelY*geo.dVoxelY+ray.z*ray.z*geo.dVoxelZ*geo.dVoxelZ);
    float sum=0.0f;
    unsigned long Np=(imax-imin+1)+(jmax-jmin+1)+(kmax-kmin+1); // Number of intersections
    // Go iterating over the line, intersection by intersection. If double point, no worries, 0 will be computed
    i+=0.5f;
    j+=0.5f;
    k+=0.5f;
    for (unsigned long ii=0;ii<Np;ii++){
        if (ax==aminc){
            sum+=(ax-ac)*tex3D<float>(tex, i, j, k);
            i=i+iu;
            ac=ax;
            ax+=axu;
        }else if(ay==aminc){
            sum+=(ay-ac)*tex3D<float>(tex, i, j, k);
            j=j+ju;
            ac=ay;
            ay+=ayu;
        }else if(az==aminc){
            sum+=(az-ac)*tex3D<float>(tex, i, j, k);
            k=k+ku;
            ac=az;
            az+=azu;
        }
        aminc=fminf(fminf(ax,ay),az);
    }
    detector[idx]=sum*maxlength;
}
