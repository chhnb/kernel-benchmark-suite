; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 addrspace(3)* %2, i32 addrspace(1)* %3, i32 addrspace(3)* %4, i32 addrspace(3)* %5, i32 addrspace(3)* %6, i32 addrspace(3)* %7, i32 addrspace(3)* %8, i32 addrspace(3)* %9, i32 addrspace(3)* %10, i32 addrspace(3)* %11, i32 addrspace(3)* %12, i32 addrspace(3)* %13, i32 addrspace(3)* %14, i32 addrspace(3)* %15, i32 addrspace(3)* %16, i32 addrspace(3)* %17, i32 addrspace(3)* %18, i32 addrspace(3)* %19, i32 addrspace(3)* %20, i32 addrspace(3)* %21, i32 addrspace(3)* %22, i32 addrspace(3)* %23, i32 addrspace(3)* %24, i32 addrspace(3)* %25, i32 addrspace(3)* %26, i32 addrspace(3)* %27, i32 addrspace(3)* %28, i32 addrspace(3)* %29, i32 addrspace(3)* %30, i32 addrspace(3)* %31, i32 addrspace(3)* %32, i32 addrspace(3)* %33, i32 addrspace(3)* %34) #0 {
  br i1 %0, label %36, label %165

36:                                               ; preds = %35
  %37 = shl nsw i32 %1, 5
  %38 = load i32, i32 addrspace(3)* %2, align 16, !tbaa !0
  %39 = sext i32 %37 to i64
  %40 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %39
  store i32 %38, i32 addrspace(1)* %40, align 4, !tbaa !0
  %41 = load i32, i32 addrspace(3)* %4, align 4, !tbaa !0
  %42 = or i32 %37, 1
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %43
  store i32 %41, i32 addrspace(1)* %44, align 4, !tbaa !0
  %45 = load i32, i32 addrspace(3)* %5, align 8, !tbaa !0
  %46 = or i32 %37, 2
  %47 = sext i32 %46 to i64
  %48 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %47
  store i32 %45, i32 addrspace(1)* %48, align 4, !tbaa !0
  %49 = load i32, i32 addrspace(3)* %6, align 4, !tbaa !0
  %50 = or i32 %37, 3
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %51
  store i32 %49, i32 addrspace(1)* %52, align 4, !tbaa !0
  %53 = load i32, i32 addrspace(3)* %7, align 16, !tbaa !0
  %54 = or i32 %37, 4
  %55 = sext i32 %54 to i64
  %56 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %55
  store i32 %53, i32 addrspace(1)* %56, align 4, !tbaa !0
  %57 = load i32, i32 addrspace(3)* %8, align 4, !tbaa !0
  %58 = or i32 %37, 5
  %59 = sext i32 %58 to i64
  %60 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %59
  store i32 %57, i32 addrspace(1)* %60, align 4, !tbaa !0
  %61 = load i32, i32 addrspace(3)* %9, align 8, !tbaa !0
  %62 = or i32 %37, 6
  %63 = sext i32 %62 to i64
  %64 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %63
  store i32 %61, i32 addrspace(1)* %64, align 4, !tbaa !0
  %65 = load i32, i32 addrspace(3)* %10, align 4, !tbaa !0
  %66 = or i32 %37, 7
  %67 = sext i32 %66 to i64
  %68 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %67
  store i32 %65, i32 addrspace(1)* %68, align 4, !tbaa !0
  %69 = load i32, i32 addrspace(3)* %11, align 16, !tbaa !0
  %70 = or i32 %37, 8
  %71 = sext i32 %70 to i64
  %72 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %71
  store i32 %69, i32 addrspace(1)* %72, align 4, !tbaa !0
  %73 = load i32, i32 addrspace(3)* %12, align 4, !tbaa !0
  %74 = or i32 %37, 9
  %75 = sext i32 %74 to i64
  %76 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %75
  store i32 %73, i32 addrspace(1)* %76, align 4, !tbaa !0
  %77 = load i32, i32 addrspace(3)* %13, align 8, !tbaa !0
  %78 = or i32 %37, 10
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %79
  store i32 %77, i32 addrspace(1)* %80, align 4, !tbaa !0
  %81 = load i32, i32 addrspace(3)* %14, align 4, !tbaa !0
  %82 = or i32 %37, 11
  %83 = sext i32 %82 to i64
  %84 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %83
  store i32 %81, i32 addrspace(1)* %84, align 4, !tbaa !0
  %85 = load i32, i32 addrspace(3)* %15, align 16, !tbaa !0
  %86 = or i32 %37, 12
  %87 = sext i32 %86 to i64
  %88 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %87
  store i32 %85, i32 addrspace(1)* %88, align 4, !tbaa !0
  %89 = load i32, i32 addrspace(3)* %16, align 4, !tbaa !0
  %90 = or i32 %37, 13
  %91 = sext i32 %90 to i64
  %92 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %91
  store i32 %89, i32 addrspace(1)* %92, align 4, !tbaa !0
  %93 = load i32, i32 addrspace(3)* %17, align 8, !tbaa !0
  %94 = or i32 %37, 14
  %95 = sext i32 %94 to i64
  %96 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %95
  store i32 %93, i32 addrspace(1)* %96, align 4, !tbaa !0
  %97 = load i32, i32 addrspace(3)* %18, align 4, !tbaa !0
  %98 = or i32 %37, 15
  %99 = sext i32 %98 to i64
  %100 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %99
  store i32 %97, i32 addrspace(1)* %100, align 4, !tbaa !0
  %101 = load i32, i32 addrspace(3)* %19, align 16, !tbaa !0
  %102 = or i32 %37, 16
  %103 = sext i32 %102 to i64
  %104 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %103
  store i32 %101, i32 addrspace(1)* %104, align 4, !tbaa !0
  %105 = load i32, i32 addrspace(3)* %20, align 4, !tbaa !0
  %106 = or i32 %37, 17
  %107 = sext i32 %106 to i64
  %108 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %107
  store i32 %105, i32 addrspace(1)* %108, align 4, !tbaa !0
  %109 = load i32, i32 addrspace(3)* %21, align 8, !tbaa !0
  %110 = or i32 %37, 18
  %111 = sext i32 %110 to i64
  %112 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %111
  store i32 %109, i32 addrspace(1)* %112, align 4, !tbaa !0
  %113 = load i32, i32 addrspace(3)* %22, align 4, !tbaa !0
  %114 = or i32 %37, 19
  %115 = sext i32 %114 to i64
  %116 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %115
  store i32 %113, i32 addrspace(1)* %116, align 4, !tbaa !0
  %117 = load i32, i32 addrspace(3)* %23, align 16, !tbaa !0
  %118 = or i32 %37, 20
  %119 = sext i32 %118 to i64
  %120 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %119
  store i32 %117, i32 addrspace(1)* %120, align 4, !tbaa !0
  %121 = load i32, i32 addrspace(3)* %24, align 4, !tbaa !0
  %122 = or i32 %37, 21
  %123 = sext i32 %122 to i64
  %124 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %123
  store i32 %121, i32 addrspace(1)* %124, align 4, !tbaa !0
  %125 = load i32, i32 addrspace(3)* %25, align 8, !tbaa !0
  %126 = or i32 %37, 22
  %127 = sext i32 %126 to i64
  %128 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %127
  store i32 %125, i32 addrspace(1)* %128, align 4, !tbaa !0
  %129 = load i32, i32 addrspace(3)* %26, align 4, !tbaa !0
  %130 = or i32 %37, 23
  %131 = sext i32 %130 to i64
  %132 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %131
  store i32 %129, i32 addrspace(1)* %132, align 4, !tbaa !0
  %133 = load i32, i32 addrspace(3)* %27, align 16, !tbaa !0
  %134 = or i32 %37, 24
  %135 = sext i32 %134 to i64
  %136 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %135
  store i32 %133, i32 addrspace(1)* %136, align 4, !tbaa !0
  %137 = load i32, i32 addrspace(3)* %28, align 4, !tbaa !0
  %138 = or i32 %37, 25
  %139 = sext i32 %138 to i64
  %140 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %139
  store i32 %137, i32 addrspace(1)* %140, align 4, !tbaa !0
  %141 = load i32, i32 addrspace(3)* %29, align 8, !tbaa !0
  %142 = or i32 %37, 26
  %143 = sext i32 %142 to i64
  %144 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %143
  store i32 %141, i32 addrspace(1)* %144, align 4, !tbaa !0
  %145 = load i32, i32 addrspace(3)* %30, align 4, !tbaa !0
  %146 = or i32 %37, 27
  %147 = sext i32 %146 to i64
  %148 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %147
  store i32 %145, i32 addrspace(1)* %148, align 4, !tbaa !0
  %149 = load i32, i32 addrspace(3)* %31, align 16, !tbaa !0
  %150 = or i32 %37, 28
  %151 = sext i32 %150 to i64
  %152 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %151
  store i32 %149, i32 addrspace(1)* %152, align 4, !tbaa !0
  %153 = load i32, i32 addrspace(3)* %32, align 4, !tbaa !0
  %154 = or i32 %37, 29
  %155 = sext i32 %154 to i64
  %156 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %155
  store i32 %153, i32 addrspace(1)* %156, align 4, !tbaa !0
  %157 = load i32, i32 addrspace(3)* %33, align 8, !tbaa !0
  %158 = or i32 %37, 30
  %159 = sext i32 %158 to i64
  %160 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %159
  store i32 %157, i32 addrspace(1)* %160, align 4, !tbaa !0
  %161 = load i32, i32 addrspace(3)* %34, align 4, !tbaa !0
  %162 = or i32 %37, 31
  %163 = sext i32 %162 to i64
  %164 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %163
  store i32 %161, i32 addrspace(1)* %164, align 4, !tbaa !0
  br label %165

165:                                              ; preds = %36, %35
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
