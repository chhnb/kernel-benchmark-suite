; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: nofree norecurse nounwind willreturn
define void @region(i1 %0, double %1, double %2, double %3, double %4, double %5, double %6, double %7, double %8, double %9, double %10, double %11, double %12, double %13, double %14, double %15, double %16, double %17, double %18, double %19, double %20, double %21, double %22, double %23, double %24, double %25, double %26, double %27, double addrspace(1)* %28, i64 %29, i64 %30, i64 %31, i64 %32, i64 %33, i64 %34, i64 %35) #0 {
  br i1 %0, label %95, label %37

37:                                               ; preds = %36
  %38 = fsub double %1, %2
  %39 = fmul double %3, %2
  %40 = fsub double %4, %39
  %41 = fmul double %5, %38
  %42 = fsub double %40, %41
  %43 = fmul double %5, %1
  %44 = fadd double %43, %42
  %45 = fmul double %4, %2
  %46 = fsub double %6, %45
  %47 = fmul double %7, %5
  %48 = fmul double %47, %38
  %49 = fsub double %46, %48
  %50 = fmul double %47, %1
  %51 = fadd double %50, %49
  %52 = fmul double %3, %8
  %53 = fmul double %52, %2
  %54 = fsub double %9, %53
  %55 = fmul double %5, %10
  %56 = fmul double %38, %55
  %57 = fsub double %54, %56
  %58 = fmul double %5, %11
  %59 = fmul double %1, %58
  %60 = fadd double %57, %59
  %61 = fmul double %3, %12
  %62 = fmul double %61, %2
  %63 = fsub double %13, %62
  %64 = fmul double %5, %14
  %65 = fmul double %38, %64
  %66 = fsub double %63, %65
  %67 = fmul double %5, %15
  %68 = fmul double %1, %67
  %69 = fadd double %66, %68
  %70 = fmul double %16, %2
  %71 = fsub double %17, %70
  %72 = fmul double %38, %18
  %73 = fsub double %71, %72
  %74 = fmul double %1, %19
  %75 = fadd double %73, %74
  %76 = fmul double %20, %2
  %77 = fsub double %21, %76
  %78 = fmul double %38, %22
  %79 = fsub double %77, %78
  %80 = fmul double %1, %23
  %81 = fadd double %79, %80
  %82 = fmul double %24, %2
  %83 = fsub double %25, %82
  %84 = fmul double %38, %26
  %85 = fsub double %83, %84
  %86 = fmul double %1, %27
  %87 = fadd double %85, %86
  %88 = getelementptr inbounds double, double addrspace(1)* %28, i64 %29
  store double %44, double addrspace(1)* %88, align 8, !tbaa !0
  %89 = getelementptr inbounds double, double addrspace(1)* %28, i64 %30
  store double %51, double addrspace(1)* %89, align 8, !tbaa !0
  %90 = getelementptr inbounds double, double addrspace(1)* %28, i64 %31
  store double %60, double addrspace(1)* %90, align 8, !tbaa !0
  %91 = getelementptr inbounds double, double addrspace(1)* %28, i64 %32
  store double %69, double addrspace(1)* %91, align 8, !tbaa !0
  %92 = getelementptr inbounds double, double addrspace(1)* %28, i64 %33
  store double %75, double addrspace(1)* %92, align 8, !tbaa !0
  %93 = getelementptr inbounds double, double addrspace(1)* %28, i64 %34
  store double %81, double addrspace(1)* %93, align 8, !tbaa !0
  %94 = getelementptr inbounds double, double addrspace(1)* %28, i64 %35
  store double %87, double addrspace(1)* %94, align 8, !tbaa !0
  br label %95

95:                                               ; preds = %37, %36
  ret void
}

attributes #0 = { nofree norecurse nounwind willreturn "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"double", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
