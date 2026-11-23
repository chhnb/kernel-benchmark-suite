; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 addrspace(3)* %1, i32 addrspace(3)* %2, i32 addrspace(3)* %3, i32 addrspace(3)* %4, i32 addrspace(3)* %5, i32 addrspace(3)* %6, i32 addrspace(3)* %7, i32 addrspace(3)* %8, i32 addrspace(3)* %9, i32 addrspace(3)* %10, i32 addrspace(3)* %11, i32 addrspace(3)* %12, i32 addrspace(3)* %13, i32 addrspace(3)* %14, i32 addrspace(3)* %15, i32 addrspace(3)* %16, i32 addrspace(3)* %17, i32 addrspace(3)* %18, i32 addrspace(3)* %19, i32 addrspace(3)* %20, i32 addrspace(3)* %21, i32 addrspace(3)* %22, i32 addrspace(3)* %23, i32 addrspace(3)* %24, i32 addrspace(3)* %25, i32 addrspace(3)* %26, i32 addrspace(3)* %27, i32 addrspace(3)* %28, i32 addrspace(3)* %29, i32 addrspace(3)* %30, i32 addrspace(3)* %31, i32 addrspace(3)* %32, i32 addrspace(3)* %33, i32 addrspace(3)* %34, i32 addrspace(3)* %35, i32 addrspace(3)* %36, i32 addrspace(3)* %37, i32 addrspace(3)* %38, i32 addrspace(3)* %39, i32 addrspace(3)* %40, i32 addrspace(3)* %41, i32 addrspace(3)* %42, i32 addrspace(3)* %43, i32 addrspace(3)* %44, i32 addrspace(3)* %45, i32 addrspace(3)* %46, i32 addrspace(3)* %47, i32 addrspace(3)* %48, i32 addrspace(3)* %49, i32 addrspace(3)* %50, i32 addrspace(3)* %51, i32 addrspace(3)* %52, i32 addrspace(3)* %53, i32 addrspace(3)* %54, i32 addrspace(3)* %55, i32 addrspace(3)* %56, i32 addrspace(3)* %57, i32 addrspace(3)* %58, i32 addrspace(3)* %59, i32 addrspace(3)* %60, i32 addrspace(3)* %61, i32 addrspace(3)* %62, i32 addrspace(3)* %63, i32 addrspace(3)* %64) #0 {
  br i1 %0, label %66, label %99

66:                                               ; preds = %65
  %67 = load i32, i32 addrspace(3)* %1, align 16, !tbaa !0
  store i32 %67, i32 addrspace(3)* %2, align 16, !tbaa !0
  %68 = load i32, i32 addrspace(3)* %3, align 4, !tbaa !0
  store i32 %68, i32 addrspace(3)* %4, align 4, !tbaa !0
  %69 = load i32, i32 addrspace(3)* %5, align 8, !tbaa !0
  store i32 %69, i32 addrspace(3)* %6, align 8, !tbaa !0
  %70 = load i32, i32 addrspace(3)* %7, align 4, !tbaa !0
  store i32 %70, i32 addrspace(3)* %8, align 4, !tbaa !0
  %71 = load i32, i32 addrspace(3)* %9, align 16, !tbaa !0
  store i32 %71, i32 addrspace(3)* %10, align 16, !tbaa !0
  %72 = load i32, i32 addrspace(3)* %11, align 4, !tbaa !0
  store i32 %72, i32 addrspace(3)* %12, align 4, !tbaa !0
  %73 = load i32, i32 addrspace(3)* %13, align 8, !tbaa !0
  store i32 %73, i32 addrspace(3)* %14, align 8, !tbaa !0
  %74 = load i32, i32 addrspace(3)* %15, align 4, !tbaa !0
  store i32 %74, i32 addrspace(3)* %16, align 4, !tbaa !0
  %75 = load i32, i32 addrspace(3)* %17, align 16, !tbaa !0
  store i32 %75, i32 addrspace(3)* %18, align 16, !tbaa !0
  %76 = load i32, i32 addrspace(3)* %19, align 4, !tbaa !0
  store i32 %76, i32 addrspace(3)* %20, align 4, !tbaa !0
  %77 = load i32, i32 addrspace(3)* %21, align 8, !tbaa !0
  store i32 %77, i32 addrspace(3)* %22, align 8, !tbaa !0
  %78 = load i32, i32 addrspace(3)* %23, align 4, !tbaa !0
  store i32 %78, i32 addrspace(3)* %24, align 4, !tbaa !0
  %79 = load i32, i32 addrspace(3)* %25, align 16, !tbaa !0
  store i32 %79, i32 addrspace(3)* %26, align 16, !tbaa !0
  %80 = load i32, i32 addrspace(3)* %27, align 4, !tbaa !0
  store i32 %80, i32 addrspace(3)* %28, align 4, !tbaa !0
  %81 = load i32, i32 addrspace(3)* %29, align 8, !tbaa !0
  store i32 %81, i32 addrspace(3)* %30, align 8, !tbaa !0
  %82 = load i32, i32 addrspace(3)* %31, align 4, !tbaa !0
  store i32 %82, i32 addrspace(3)* %32, align 4, !tbaa !0
  %83 = load i32, i32 addrspace(3)* %33, align 16, !tbaa !0
  store i32 %83, i32 addrspace(3)* %34, align 16, !tbaa !0
  %84 = load i32, i32 addrspace(3)* %35, align 4, !tbaa !0
  store i32 %84, i32 addrspace(3)* %36, align 4, !tbaa !0
  %85 = load i32, i32 addrspace(3)* %37, align 8, !tbaa !0
  store i32 %85, i32 addrspace(3)* %38, align 8, !tbaa !0
  %86 = load i32, i32 addrspace(3)* %39, align 4, !tbaa !0
  store i32 %86, i32 addrspace(3)* %40, align 4, !tbaa !0
  %87 = load i32, i32 addrspace(3)* %41, align 16, !tbaa !0
  store i32 %87, i32 addrspace(3)* %42, align 16, !tbaa !0
  %88 = load i32, i32 addrspace(3)* %43, align 4, !tbaa !0
  store i32 %88, i32 addrspace(3)* %44, align 4, !tbaa !0
  %89 = load i32, i32 addrspace(3)* %45, align 8, !tbaa !0
  store i32 %89, i32 addrspace(3)* %46, align 8, !tbaa !0
  %90 = load i32, i32 addrspace(3)* %47, align 4, !tbaa !0
  store i32 %90, i32 addrspace(3)* %48, align 4, !tbaa !0
  %91 = load i32, i32 addrspace(3)* %49, align 16, !tbaa !0
  store i32 %91, i32 addrspace(3)* %50, align 16, !tbaa !0
  %92 = load i32, i32 addrspace(3)* %51, align 4, !tbaa !0
  store i32 %92, i32 addrspace(3)* %52, align 4, !tbaa !0
  %93 = load i32, i32 addrspace(3)* %53, align 8, !tbaa !0
  store i32 %93, i32 addrspace(3)* %54, align 8, !tbaa !0
  %94 = load i32, i32 addrspace(3)* %55, align 4, !tbaa !0
  store i32 %94, i32 addrspace(3)* %56, align 4, !tbaa !0
  %95 = load i32, i32 addrspace(3)* %57, align 16, !tbaa !0
  store i32 %95, i32 addrspace(3)* %58, align 16, !tbaa !0
  %96 = load i32, i32 addrspace(3)* %59, align 4, !tbaa !0
  store i32 %96, i32 addrspace(3)* %60, align 4, !tbaa !0
  %97 = load i32, i32 addrspace(3)* %61, align 8, !tbaa !0
  store i32 %97, i32 addrspace(3)* %62, align 8, !tbaa !0
  %98 = load i32, i32 addrspace(3)* %63, align 4, !tbaa !0
  store i32 %98, i32 addrspace(3)* %64, align 4, !tbaa !0
  br label %99

99:                                               ; preds = %66, %65
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
