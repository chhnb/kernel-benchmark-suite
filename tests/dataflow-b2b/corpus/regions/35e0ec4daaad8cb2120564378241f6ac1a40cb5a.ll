; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, i32 addrspace(1)* %2, [8192 x i32] addrspace(3)* %3, i32 %4) #0 {
  br i1 %0, label %6, label %198

6:                                                ; preds = %5
  %7 = shl nsw i32 %1, 5
  %8 = sext i32 %7 to i64
  %9 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %8
  %10 = load i32, i32 addrspace(1)* %9, align 4, !tbaa !0
  %11 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %4
  store i32 %10, i32 addrspace(3)* %11, align 16, !tbaa !0
  %12 = or i32 %7, 1
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %13
  %15 = load i32, i32 addrspace(1)* %14, align 4, !tbaa !0
  %16 = or i32 %4, 1
  %17 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %16
  store i32 %15, i32 addrspace(3)* %17, align 4, !tbaa !0
  %18 = or i32 %7, 2
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %19
  %21 = load i32, i32 addrspace(1)* %20, align 4, !tbaa !0
  %22 = or i32 %4, 2
  %23 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %22
  store i32 %21, i32 addrspace(3)* %23, align 8, !tbaa !0
  %24 = or i32 %7, 3
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %25
  %27 = load i32, i32 addrspace(1)* %26, align 4, !tbaa !0
  %28 = or i32 %4, 3
  %29 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %28
  store i32 %27, i32 addrspace(3)* %29, align 4, !tbaa !0
  %30 = or i32 %7, 4
  %31 = sext i32 %30 to i64
  %32 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %31
  %33 = load i32, i32 addrspace(1)* %32, align 4, !tbaa !0
  %34 = or i32 %4, 4
  %35 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %34
  store i32 %33, i32 addrspace(3)* %35, align 16, !tbaa !0
  %36 = or i32 %7, 5
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %37
  %39 = load i32, i32 addrspace(1)* %38, align 4, !tbaa !0
  %40 = or i32 %4, 5
  %41 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %40
  store i32 %39, i32 addrspace(3)* %41, align 4, !tbaa !0
  %42 = or i32 %7, 6
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %43
  %45 = load i32, i32 addrspace(1)* %44, align 4, !tbaa !0
  %46 = or i32 %4, 6
  %47 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %46
  store i32 %45, i32 addrspace(3)* %47, align 8, !tbaa !0
  %48 = or i32 %7, 7
  %49 = sext i32 %48 to i64
  %50 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %49
  %51 = load i32, i32 addrspace(1)* %50, align 4, !tbaa !0
  %52 = or i32 %4, 7
  %53 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %52
  store i32 %51, i32 addrspace(3)* %53, align 4, !tbaa !0
  %54 = or i32 %7, 8
  %55 = sext i32 %54 to i64
  %56 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %55
  %57 = load i32, i32 addrspace(1)* %56, align 4, !tbaa !0
  %58 = or i32 %4, 8
  %59 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %58
  store i32 %57, i32 addrspace(3)* %59, align 16, !tbaa !0
  %60 = or i32 %7, 9
  %61 = sext i32 %60 to i64
  %62 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %61
  %63 = load i32, i32 addrspace(1)* %62, align 4, !tbaa !0
  %64 = or i32 %4, 9
  %65 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %64
  store i32 %63, i32 addrspace(3)* %65, align 4, !tbaa !0
  %66 = or i32 %7, 10
  %67 = sext i32 %66 to i64
  %68 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %67
  %69 = load i32, i32 addrspace(1)* %68, align 4, !tbaa !0
  %70 = or i32 %4, 10
  %71 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %70
  store i32 %69, i32 addrspace(3)* %71, align 8, !tbaa !0
  %72 = or i32 %7, 11
  %73 = sext i32 %72 to i64
  %74 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %73
  %75 = load i32, i32 addrspace(1)* %74, align 4, !tbaa !0
  %76 = or i32 %4, 11
  %77 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %76
  store i32 %75, i32 addrspace(3)* %77, align 4, !tbaa !0
  %78 = or i32 %7, 12
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %79
  %81 = load i32, i32 addrspace(1)* %80, align 4, !tbaa !0
  %82 = or i32 %4, 12
  %83 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %82
  store i32 %81, i32 addrspace(3)* %83, align 16, !tbaa !0
  %84 = or i32 %7, 13
  %85 = sext i32 %84 to i64
  %86 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %85
  %87 = load i32, i32 addrspace(1)* %86, align 4, !tbaa !0
  %88 = or i32 %4, 13
  %89 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %88
  store i32 %87, i32 addrspace(3)* %89, align 4, !tbaa !0
  %90 = or i32 %7, 14
  %91 = sext i32 %90 to i64
  %92 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %91
  %93 = load i32, i32 addrspace(1)* %92, align 4, !tbaa !0
  %94 = or i32 %4, 14
  %95 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %94
  store i32 %93, i32 addrspace(3)* %95, align 8, !tbaa !0
  %96 = or i32 %7, 15
  %97 = sext i32 %96 to i64
  %98 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %97
  %99 = load i32, i32 addrspace(1)* %98, align 4, !tbaa !0
  %100 = or i32 %4, 15
  %101 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %100
  store i32 %99, i32 addrspace(3)* %101, align 4, !tbaa !0
  %102 = or i32 %7, 16
  %103 = sext i32 %102 to i64
  %104 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %103
  %105 = load i32, i32 addrspace(1)* %104, align 4, !tbaa !0
  %106 = or i32 %4, 16
  %107 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %106
  store i32 %105, i32 addrspace(3)* %107, align 16, !tbaa !0
  %108 = or i32 %7, 17
  %109 = sext i32 %108 to i64
  %110 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %109
  %111 = load i32, i32 addrspace(1)* %110, align 4, !tbaa !0
  %112 = or i32 %4, 17
  %113 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %112
  store i32 %111, i32 addrspace(3)* %113, align 4, !tbaa !0
  %114 = or i32 %7, 18
  %115 = sext i32 %114 to i64
  %116 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %115
  %117 = load i32, i32 addrspace(1)* %116, align 4, !tbaa !0
  %118 = or i32 %4, 18
  %119 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %118
  store i32 %117, i32 addrspace(3)* %119, align 8, !tbaa !0
  %120 = or i32 %7, 19
  %121 = sext i32 %120 to i64
  %122 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %121
  %123 = load i32, i32 addrspace(1)* %122, align 4, !tbaa !0
  %124 = or i32 %4, 19
  %125 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %124
  store i32 %123, i32 addrspace(3)* %125, align 4, !tbaa !0
  %126 = or i32 %7, 20
  %127 = sext i32 %126 to i64
  %128 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %127
  %129 = load i32, i32 addrspace(1)* %128, align 4, !tbaa !0
  %130 = or i32 %4, 20
  %131 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %130
  store i32 %129, i32 addrspace(3)* %131, align 16, !tbaa !0
  %132 = or i32 %7, 21
  %133 = sext i32 %132 to i64
  %134 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %133
  %135 = load i32, i32 addrspace(1)* %134, align 4, !tbaa !0
  %136 = or i32 %4, 21
  %137 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %136
  store i32 %135, i32 addrspace(3)* %137, align 4, !tbaa !0
  %138 = or i32 %7, 22
  %139 = sext i32 %138 to i64
  %140 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %139
  %141 = load i32, i32 addrspace(1)* %140, align 4, !tbaa !0
  %142 = or i32 %4, 22
  %143 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %142
  store i32 %141, i32 addrspace(3)* %143, align 8, !tbaa !0
  %144 = or i32 %7, 23
  %145 = sext i32 %144 to i64
  %146 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %145
  %147 = load i32, i32 addrspace(1)* %146, align 4, !tbaa !0
  %148 = or i32 %4, 23
  %149 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %148
  store i32 %147, i32 addrspace(3)* %149, align 4, !tbaa !0
  %150 = or i32 %7, 24
  %151 = sext i32 %150 to i64
  %152 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %151
  %153 = load i32, i32 addrspace(1)* %152, align 4, !tbaa !0
  %154 = or i32 %4, 24
  %155 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %154
  store i32 %153, i32 addrspace(3)* %155, align 16, !tbaa !0
  %156 = or i32 %7, 25
  %157 = sext i32 %156 to i64
  %158 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %157
  %159 = load i32, i32 addrspace(1)* %158, align 4, !tbaa !0
  %160 = or i32 %4, 25
  %161 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %160
  store i32 %159, i32 addrspace(3)* %161, align 4, !tbaa !0
  %162 = or i32 %7, 26
  %163 = sext i32 %162 to i64
  %164 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %163
  %165 = load i32, i32 addrspace(1)* %164, align 4, !tbaa !0
  %166 = or i32 %4, 26
  %167 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %166
  store i32 %165, i32 addrspace(3)* %167, align 8, !tbaa !0
  %168 = or i32 %7, 27
  %169 = sext i32 %168 to i64
  %170 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %169
  %171 = load i32, i32 addrspace(1)* %170, align 4, !tbaa !0
  %172 = or i32 %4, 27
  %173 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %172
  store i32 %171, i32 addrspace(3)* %173, align 4, !tbaa !0
  %174 = or i32 %7, 28
  %175 = sext i32 %174 to i64
  %176 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %175
  %177 = load i32, i32 addrspace(1)* %176, align 4, !tbaa !0
  %178 = or i32 %4, 28
  %179 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %178
  store i32 %177, i32 addrspace(3)* %179, align 16, !tbaa !0
  %180 = or i32 %7, 29
  %181 = sext i32 %180 to i64
  %182 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %181
  %183 = load i32, i32 addrspace(1)* %182, align 4, !tbaa !0
  %184 = or i32 %4, 29
  %185 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %184
  store i32 %183, i32 addrspace(3)* %185, align 4, !tbaa !0
  %186 = or i32 %7, 30
  %187 = sext i32 %186 to i64
  %188 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %187
  %189 = load i32, i32 addrspace(1)* %188, align 4, !tbaa !0
  %190 = or i32 %4, 30
  %191 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %190
  store i32 %189, i32 addrspace(3)* %191, align 8, !tbaa !0
  %192 = or i32 %7, 31
  %193 = sext i32 %192 to i64
  %194 = getelementptr inbounds i32, i32 addrspace(1)* %2, i64 %193
  %195 = load i32, i32 addrspace(1)* %194, align 4, !tbaa !0
  %196 = or i32 %4, 31
  %197 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %3, i32 0, i32 %196
  store i32 %195, i32 addrspace(3)* %197, align 4, !tbaa !0
  br label %198

198:                                              ; preds = %6, %5
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
