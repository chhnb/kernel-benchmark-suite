; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, float %1, float %2, i64 %3, i64 %4, i64 %5, i32 addrspace(4)* %6, i32 addrspace(4)* %7, i32 addrspace(4)* %8, i32 addrspace(4)* %9, i32 addrspace(4)* %10, <8 x i32> addrspace(4)* %11, <4 x i32> addrspace(4)* %12, float %13, float %14, float %15, float %16, float %17, { float, float, float, i64, i64, i64, float, float }* %18) #0 {
  br i1 %0, label %20, label %68

20:                                               ; preds = %19
  %21 = fsub float %1, %2
  %22 = uitofp i64 %3 to float
  %23 = uitofp i64 %4 to float
  %24 = uitofp i64 %5 to float
  %25 = load i32, i32 addrspace(4)* %6, align 4, !tbaa !0
  %26 = uitofp i32 %25 to float
  %27 = load i32, i32 addrspace(4)* %7, align 4, !tbaa !0
  %28 = lshr i32 %27, 14
  %29 = and i32 %28, 16383
  %30 = add nuw nsw i32 %29, 1
  %31 = uitofp i32 %30 to float
  %32 = load i32, i32 addrspace(4)* %8, align 4, !tbaa !0
  %33 = and i32 %32, 8191
  %34 = add nuw nsw i32 %33, 1
  %35 = uitofp i32 %34 to float
  %36 = load i32, i32 addrspace(4)* %9, align 4, !tbaa !0
  %37 = and i32 %36, 32768
  %38 = icmp eq i32 %37, 0
  %39 = select i1 %38, float %26, float 1.000000e+00
  %40 = select i1 %38, float %31, float 1.000000e+00
  %41 = select i1 %38, float %35, float 1.000000e+00
  %42 = fmul float %39, %22
  %43 = tail call float @llvm.floor.f32(float %42) #4
  %44 = tail call float @llvm.amdgcn.rcp.f32(float %39) #4
  %45 = fmul float %44, %43
  %46 = fmul float %40, %23
  %47 = tail call float @llvm.floor.f32(float %46) #4
  %48 = tail call float @llvm.amdgcn.rcp.f32(float %40) #4
  %49 = fmul float %48, %47
  %50 = fmul float %41, %24
  %51 = tail call float @llvm.floor.f32(float %50) #4
  %52 = tail call float @llvm.amdgcn.rcp.f32(float %41) #4
  %53 = fmul float %52, %51
  %54 = load i32, i32 addrspace(4)* %10, align 4, !tbaa !0
  %55 = and i32 %54, 1048576
  %56 = icmp eq i32 %55, 0
  %57 = select i1 %56, float %45, float %22
  %58 = select i1 %56, float %49, float %23
  %59 = select i1 %56, float %53, float %24
  %60 = load <8 x i32>, <8 x i32> addrspace(4)* %11, align 32, !tbaa !4
  %61 = load <4 x i32>, <4 x i32> addrspace(4)* %12, align 16, !tbaa !4
  %62 = tail call float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 1, float %57, float %58, float %59, <8 x i32> %60, <4 x i32> %61, i1 false, i32 0, i32 0)
  %63 = fmul float %21, %62
  %64 = fadd float %13, %63
  %65 = fadd float %14, %24
  %66 = fptoui float %65 to i64
  %67 = fadd float %15, %1
  br label %68

68:                                               ; preds = %20, %19
  %69 = phi float [ %16, %20 ], [ %16, %19 ]
  %70 = phi float [ %17, %20 ], [ %17, %19 ]
  %71 = phi float [ %67, %20 ], [ %1, %19 ]
  %72 = phi i64 [ %3, %20 ], [ %3, %19 ]
  %73 = phi i64 [ %4, %20 ], [ %4, %19 ]
  %74 = phi i64 [ %66, %20 ], [ %5, %19 ]
  %75 = phi float [ %1, %20 ], [ %2, %19 ]
  %76 = phi float [ %64, %20 ], [ %13, %19 ]
  %77 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 0
  store float %69, float* %77, align 4
  %78 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 1
  store float %70, float* %78, align 4
  %79 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 2
  store float %71, float* %79, align 4
  %80 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 3
  store i64 %72, i64* %80, align 8
  %81 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 4
  store i64 %73, i64* %81, align 8
  %82 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 5
  store i64 %74, i64* %82, align 8
  %83 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 6
  store float %75, float* %83, align 4
  %84 = getelementptr inbounds { float, float, float, i64, i64, i64, float, float }, { float, float, float, i64, i64, i64, float, float }* %18, i32 0, i32 7
  store float %76, float* %84, align 4
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.floor.f32(float) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.amdgcn.rcp.f32(float) #2

; Function Attrs: nounwind readonly willreturn
declare float @llvm.amdgcn.image.sample.lz.3d.f32.f32(i32 immarg, float, float, float, <8 x i32>, <4 x i32>, i1 immarg, i32 immarg, i32 immarg) #3

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,729" "amdgpu-implicitarg-num-bytes"="56" "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { nounwind readonly willreturn }
attributes #4 = { nounwind }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
