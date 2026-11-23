; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, [8 x [8 x float]] addrspace(3)* %1, i32 %2, [8 x [8 x float]] addrspace(3)* %3, [8 x [8 x float]] addrspace(3)* %4) #0 {
  %6 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 0
  %7 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 0
  %8 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 1
  %9 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 0
  %10 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 1
  %11 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 2
  %12 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 0
  %13 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 1
  %14 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 2
  %15 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 3
  %16 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 0
  %17 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 1
  %18 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 2
  %19 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 3
  %20 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 4
  %21 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 0
  %22 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 1
  %23 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 2
  %24 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 3
  %25 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 4
  %26 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 5
  %27 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 0
  %28 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 1
  %29 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 2
  %30 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 3
  %31 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 4
  %32 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 5
  %33 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 6
  %34 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 0
  %35 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 1
  %36 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 1
  %37 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 2
  %38 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 2
  %39 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 2
  %40 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 3
  %41 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 3
  %42 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 3
  %43 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 3
  %44 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 4
  %45 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 4
  %46 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 4
  %47 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 4
  %48 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 4
  %49 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 5
  %50 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 5
  %51 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 5
  %52 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 5
  %53 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 5
  %54 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 5
  %55 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 6
  %56 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 6
  %57 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 6
  %58 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 6
  %59 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 6
  %60 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 6
  %61 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 6
  %62 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 0, i32 7
  %63 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 1, i32 7
  %64 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 2, i32 7
  %65 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 3, i32 7
  %66 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 4, i32 7
  %67 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 5, i32 7
  %68 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 6, i32 7
  %69 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %3, i32 0, i32 7, i32 7
  br i1 %0, label %70, label %225

70:                                               ; preds = %5
  %71 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %72 = load float, float addrspace(3)* %71, align 4, !tbaa !1
  %73 = load float, float addrspace(3)* %6, align 16, !tbaa !1
  %74 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %75 = load float, float addrspace(3)* %74, align 4, !tbaa !1
  %76 = fmul contract float %73, %75
  %77 = fsub contract float %72, %76
  store float %77, float addrspace(3)* %71, align 4, !tbaa !1
  %78 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 %2
  %79 = load float, float addrspace(3)* %78, align 4, !tbaa !1
  %80 = load float, float addrspace(3)* %7, align 16, !tbaa !1
  %81 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %82 = load float, float addrspace(3)* %81, align 4, !tbaa !1
  %83 = fmul contract float %80, %82
  %84 = fsub contract float %79, %83
  store float %84, float addrspace(3)* %78, align 4, !tbaa !1
  %85 = load float, float addrspace(3)* %8, align 4, !tbaa !1
  %86 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %87 = load float, float addrspace(3)* %86, align 4, !tbaa !1
  %88 = fmul contract float %85, %87
  %89 = fsub contract float %84, %88
  store float %89, float addrspace(3)* %78, align 4, !tbaa !1
  %90 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 %2
  %91 = load float, float addrspace(3)* %90, align 4, !tbaa !1
  %92 = load float, float addrspace(3)* %9, align 16, !tbaa !1
  %93 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %94 = load float, float addrspace(3)* %93, align 4, !tbaa !1
  %95 = fmul contract float %92, %94
  %96 = fsub contract float %91, %95
  store float %96, float addrspace(3)* %90, align 4, !tbaa !1
  %97 = load float, float addrspace(3)* %10, align 4, !tbaa !1
  %98 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %99 = load float, float addrspace(3)* %98, align 4, !tbaa !1
  %100 = fmul contract float %97, %99
  %101 = fsub contract float %96, %100
  store float %101, float addrspace(3)* %90, align 4, !tbaa !1
  %102 = load float, float addrspace(3)* %11, align 8, !tbaa !1
  %103 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 %2
  %104 = load float, float addrspace(3)* %103, align 4, !tbaa !1
  %105 = fmul contract float %102, %104
  %106 = fsub contract float %101, %105
  store float %106, float addrspace(3)* %90, align 4, !tbaa !1
  %107 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 %2
  %108 = load float, float addrspace(3)* %107, align 4, !tbaa !1
  %109 = load float, float addrspace(3)* %12, align 16, !tbaa !1
  %110 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %111 = load float, float addrspace(3)* %110, align 4, !tbaa !1
  %112 = fmul contract float %109, %111
  %113 = fsub contract float %108, %112
  store float %113, float addrspace(3)* %107, align 4, !tbaa !1
  %114 = load float, float addrspace(3)* %13, align 4, !tbaa !1
  %115 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %116 = load float, float addrspace(3)* %115, align 4, !tbaa !1
  %117 = fmul contract float %114, %116
  %118 = fsub contract float %113, %117
  store float %118, float addrspace(3)* %107, align 4, !tbaa !1
  %119 = load float, float addrspace(3)* %14, align 8, !tbaa !1
  %120 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 %2
  %121 = load float, float addrspace(3)* %120, align 4, !tbaa !1
  %122 = fmul contract float %119, %121
  %123 = fsub contract float %118, %122
  store float %123, float addrspace(3)* %107, align 4, !tbaa !1
  %124 = load float, float addrspace(3)* %15, align 4, !tbaa !1
  %125 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 %2
  %126 = load float, float addrspace(3)* %125, align 4, !tbaa !1
  %127 = fmul contract float %124, %126
  %128 = fsub contract float %123, %127
  store float %128, float addrspace(3)* %107, align 4, !tbaa !1
  %129 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 5, i32 %2
  %130 = load float, float addrspace(3)* %129, align 4, !tbaa !1
  %131 = load float, float addrspace(3)* %16, align 16, !tbaa !1
  %132 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %133 = load float, float addrspace(3)* %132, align 4, !tbaa !1
  %134 = fmul contract float %131, %133
  %135 = fsub contract float %130, %134
  store float %135, float addrspace(3)* %129, align 4, !tbaa !1
  %136 = load float, float addrspace(3)* %17, align 4, !tbaa !1
  %137 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %138 = load float, float addrspace(3)* %137, align 4, !tbaa !1
  %139 = fmul contract float %136, %138
  %140 = fsub contract float %135, %139
  store float %140, float addrspace(3)* %129, align 4, !tbaa !1
  %141 = load float, float addrspace(3)* %18, align 8, !tbaa !1
  %142 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 %2
  %143 = load float, float addrspace(3)* %142, align 4, !tbaa !1
  %144 = fmul contract float %141, %143
  %145 = fsub contract float %140, %144
  store float %145, float addrspace(3)* %129, align 4, !tbaa !1
  %146 = load float, float addrspace(3)* %19, align 4, !tbaa !1
  %147 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 %2
  %148 = load float, float addrspace(3)* %147, align 4, !tbaa !1
  %149 = fmul contract float %146, %148
  %150 = fsub contract float %145, %149
  store float %150, float addrspace(3)* %129, align 4, !tbaa !1
  %151 = load float, float addrspace(3)* %20, align 16, !tbaa !1
  %152 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 %2
  %153 = load float, float addrspace(3)* %152, align 4, !tbaa !1
  %154 = fmul contract float %151, %153
  %155 = fsub contract float %150, %154
  store float %155, float addrspace(3)* %129, align 4, !tbaa !1
  %156 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 6, i32 %2
  %157 = load float, float addrspace(3)* %156, align 4, !tbaa !1
  %158 = load float, float addrspace(3)* %21, align 16, !tbaa !1
  %159 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %160 = load float, float addrspace(3)* %159, align 4, !tbaa !1
  %161 = fmul contract float %158, %160
  %162 = fsub contract float %157, %161
  store float %162, float addrspace(3)* %156, align 4, !tbaa !1
  %163 = load float, float addrspace(3)* %22, align 4, !tbaa !1
  %164 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %165 = load float, float addrspace(3)* %164, align 4, !tbaa !1
  %166 = fmul contract float %163, %165
  %167 = fsub contract float %162, %166
  store float %167, float addrspace(3)* %156, align 4, !tbaa !1
  %168 = load float, float addrspace(3)* %23, align 8, !tbaa !1
  %169 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 %2
  %170 = load float, float addrspace(3)* %169, align 4, !tbaa !1
  %171 = fmul contract float %168, %170
  %172 = fsub contract float %167, %171
  store float %172, float addrspace(3)* %156, align 4, !tbaa !1
  %173 = load float, float addrspace(3)* %24, align 4, !tbaa !1
  %174 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 %2
  %175 = load float, float addrspace(3)* %174, align 4, !tbaa !1
  %176 = fmul contract float %173, %175
  %177 = fsub contract float %172, %176
  store float %177, float addrspace(3)* %156, align 4, !tbaa !1
  %178 = load float, float addrspace(3)* %25, align 16, !tbaa !1
  %179 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 %2
  %180 = load float, float addrspace(3)* %179, align 4, !tbaa !1
  %181 = fmul contract float %178, %180
  %182 = fsub contract float %177, %181
  store float %182, float addrspace(3)* %156, align 4, !tbaa !1
  %183 = load float, float addrspace(3)* %26, align 4, !tbaa !1
  %184 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 5, i32 %2
  %185 = load float, float addrspace(3)* %184, align 4, !tbaa !1
  %186 = fmul contract float %183, %185
  %187 = fsub contract float %182, %186
  store float %187, float addrspace(3)* %156, align 4, !tbaa !1
  %188 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 7, i32 %2
  %189 = load float, float addrspace(3)* %188, align 4, !tbaa !1
  %190 = load float, float addrspace(3)* %27, align 16, !tbaa !1
  %191 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 0, i32 %2
  %192 = load float, float addrspace(3)* %191, align 4, !tbaa !1
  %193 = fmul contract float %190, %192
  %194 = fsub contract float %189, %193
  store float %194, float addrspace(3)* %188, align 4, !tbaa !1
  %195 = load float, float addrspace(3)* %28, align 4, !tbaa !1
  %196 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 1, i32 %2
  %197 = load float, float addrspace(3)* %196, align 4, !tbaa !1
  %198 = fmul contract float %195, %197
  %199 = fsub contract float %194, %198
  store float %199, float addrspace(3)* %188, align 4, !tbaa !1
  %200 = load float, float addrspace(3)* %29, align 8, !tbaa !1
  %201 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 2, i32 %2
  %202 = load float, float addrspace(3)* %201, align 4, !tbaa !1
  %203 = fmul contract float %200, %202
  %204 = fsub contract float %199, %203
  store float %204, float addrspace(3)* %188, align 4, !tbaa !1
  %205 = load float, float addrspace(3)* %30, align 4, !tbaa !1
  %206 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 3, i32 %2
  %207 = load float, float addrspace(3)* %206, align 4, !tbaa !1
  %208 = fmul contract float %205, %207
  %209 = fsub contract float %204, %208
  store float %209, float addrspace(3)* %188, align 4, !tbaa !1
  %210 = load float, float addrspace(3)* %31, align 16, !tbaa !1
  %211 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 4, i32 %2
  %212 = load float, float addrspace(3)* %211, align 4, !tbaa !1
  %213 = fmul contract float %210, %212
  %214 = fsub contract float %209, %213
  store float %214, float addrspace(3)* %188, align 4, !tbaa !1
  %215 = load float, float addrspace(3)* %32, align 4, !tbaa !1
  %216 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 5, i32 %2
  %217 = load float, float addrspace(3)* %216, align 4, !tbaa !1
  %218 = fmul contract float %215, %217
  %219 = fsub contract float %214, %218
  store float %219, float addrspace(3)* %188, align 4, !tbaa !1
  %220 = load float, float addrspace(3)* %33, align 8, !tbaa !1
  %221 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %1, i32 0, i32 6, i32 %2
  %222 = load float, float addrspace(3)* %221, align 4, !tbaa !1
  %223 = fmul contract float %220, %222
  %224 = fsub contract float %219, %223
  store float %224, float addrspace(3)* %188, align 4, !tbaa !1
  br label %393

225:                                              ; preds = %5
  %226 = add nsw i32 %2, -8
  %227 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 0
  %228 = load float, float addrspace(3)* %227, align 16, !tbaa !1
  %229 = load float, float addrspace(3)* %34, align 16, !tbaa !1
  %230 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 0
  %231 = fdiv contract float %228, %229
  store float %231, float addrspace(3)* %230, align 16, !tbaa !1
  %232 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %233 = load float, float addrspace(3)* %232, align 4, !tbaa !1
  %234 = load float, float addrspace(3)* %35, align 4, !tbaa !1
  %235 = fmul contract float %231, %234
  %236 = fsub contract float %233, %235
  store float %236, float addrspace(3)* %232, align 4, !tbaa !1
  %237 = load float, float addrspace(3)* %36, align 4, !tbaa !1
  %238 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %239 = fdiv contract float %236, %237
  store float %239, float addrspace(3)* %238, align 4, !tbaa !1
  %240 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 2
  %241 = load float, float addrspace(3)* %240, align 8, !tbaa !1
  %242 = load float, float addrspace(3)* %37, align 8, !tbaa !1
  %243 = fmul contract float %231, %242
  %244 = fsub contract float %241, %243
  store float %244, float addrspace(3)* %240, align 8, !tbaa !1
  %245 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %246 = load float, float addrspace(3)* %245, align 4, !tbaa !1
  %247 = load float, float addrspace(3)* %38, align 8, !tbaa !1
  %248 = fmul contract float %246, %247
  %249 = fsub contract float %244, %248
  store float %249, float addrspace(3)* %240, align 8, !tbaa !1
  %250 = load float, float addrspace(3)* %39, align 8, !tbaa !1
  %251 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 2
  %252 = fdiv contract float %249, %250
  store float %252, float addrspace(3)* %251, align 8, !tbaa !1
  %253 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 3
  %254 = load float, float addrspace(3)* %253, align 4, !tbaa !1
  %255 = load float, float addrspace(3)* %40, align 4, !tbaa !1
  %256 = fmul contract float %231, %255
  %257 = fsub contract float %254, %256
  store float %257, float addrspace(3)* %253, align 4, !tbaa !1
  %258 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %259 = load float, float addrspace(3)* %258, align 4, !tbaa !1
  %260 = load float, float addrspace(3)* %41, align 4, !tbaa !1
  %261 = fmul contract float %259, %260
  %262 = fsub contract float %257, %261
  store float %262, float addrspace(3)* %253, align 4, !tbaa !1
  %263 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 2
  %264 = load float, float addrspace(3)* %263, align 8, !tbaa !1
  %265 = load float, float addrspace(3)* %42, align 4, !tbaa !1
  %266 = fmul contract float %264, %265
  %267 = fsub contract float %262, %266
  store float %267, float addrspace(3)* %253, align 4, !tbaa !1
  %268 = load float, float addrspace(3)* %43, align 4, !tbaa !1
  %269 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 3
  %270 = fdiv contract float %267, %268
  store float %270, float addrspace(3)* %269, align 4, !tbaa !1
  %271 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 4
  %272 = load float, float addrspace(3)* %271, align 16, !tbaa !1
  %273 = load float, float addrspace(3)* %44, align 16, !tbaa !1
  %274 = fmul contract float %231, %273
  %275 = fsub contract float %272, %274
  store float %275, float addrspace(3)* %271, align 16, !tbaa !1
  %276 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %277 = load float, float addrspace(3)* %276, align 4, !tbaa !1
  %278 = load float, float addrspace(3)* %45, align 16, !tbaa !1
  %279 = fmul contract float %277, %278
  %280 = fsub contract float %275, %279
  store float %280, float addrspace(3)* %271, align 16, !tbaa !1
  %281 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 2
  %282 = load float, float addrspace(3)* %281, align 8, !tbaa !1
  %283 = load float, float addrspace(3)* %46, align 16, !tbaa !1
  %284 = fmul contract float %282, %283
  %285 = fsub contract float %280, %284
  store float %285, float addrspace(3)* %271, align 16, !tbaa !1
  %286 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 3
  %287 = load float, float addrspace(3)* %286, align 4, !tbaa !1
  %288 = load float, float addrspace(3)* %47, align 16, !tbaa !1
  %289 = fmul contract float %287, %288
  %290 = fsub contract float %285, %289
  store float %290, float addrspace(3)* %271, align 16, !tbaa !1
  %291 = load float, float addrspace(3)* %48, align 16, !tbaa !1
  %292 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 4
  %293 = fdiv contract float %290, %291
  store float %293, float addrspace(3)* %292, align 16, !tbaa !1
  %294 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 5
  %295 = load float, float addrspace(3)* %294, align 4, !tbaa !1
  %296 = load float, float addrspace(3)* %49, align 4, !tbaa !1
  %297 = fmul contract float %231, %296
  %298 = fsub contract float %295, %297
  store float %298, float addrspace(3)* %294, align 4, !tbaa !1
  %299 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %300 = load float, float addrspace(3)* %299, align 4, !tbaa !1
  %301 = load float, float addrspace(3)* %50, align 4, !tbaa !1
  %302 = fmul contract float %300, %301
  %303 = fsub contract float %298, %302
  store float %303, float addrspace(3)* %294, align 4, !tbaa !1
  %304 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 2
  %305 = load float, float addrspace(3)* %304, align 8, !tbaa !1
  %306 = load float, float addrspace(3)* %51, align 4, !tbaa !1
  %307 = fmul contract float %305, %306
  %308 = fsub contract float %303, %307
  store float %308, float addrspace(3)* %294, align 4, !tbaa !1
  %309 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 3
  %310 = load float, float addrspace(3)* %309, align 4, !tbaa !1
  %311 = load float, float addrspace(3)* %52, align 4, !tbaa !1
  %312 = fmul contract float %310, %311
  %313 = fsub contract float %308, %312
  store float %313, float addrspace(3)* %294, align 4, !tbaa !1
  %314 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 4
  %315 = load float, float addrspace(3)* %314, align 16, !tbaa !1
  %316 = load float, float addrspace(3)* %53, align 4, !tbaa !1
  %317 = fmul contract float %315, %316
  %318 = fsub contract float %313, %317
  store float %318, float addrspace(3)* %294, align 4, !tbaa !1
  %319 = load float, float addrspace(3)* %54, align 4, !tbaa !1
  %320 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 5
  %321 = fdiv contract float %318, %319
  store float %321, float addrspace(3)* %320, align 4, !tbaa !1
  %322 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 6
  %323 = load float, float addrspace(3)* %322, align 8, !tbaa !1
  %324 = load float, float addrspace(3)* %55, align 8, !tbaa !1
  %325 = fmul contract float %231, %324
  %326 = fsub contract float %323, %325
  store float %326, float addrspace(3)* %322, align 8, !tbaa !1
  %327 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %328 = load float, float addrspace(3)* %327, align 4, !tbaa !1
  %329 = load float, float addrspace(3)* %56, align 8, !tbaa !1
  %330 = fmul contract float %328, %329
  %331 = fsub contract float %326, %330
  store float %331, float addrspace(3)* %322, align 8, !tbaa !1
  %332 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 2
  %333 = load float, float addrspace(3)* %332, align 8, !tbaa !1
  %334 = load float, float addrspace(3)* %57, align 8, !tbaa !1
  %335 = fmul contract float %333, %334
  %336 = fsub contract float %331, %335
  store float %336, float addrspace(3)* %322, align 8, !tbaa !1
  %337 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 3
  %338 = load float, float addrspace(3)* %337, align 4, !tbaa !1
  %339 = load float, float addrspace(3)* %58, align 8, !tbaa !1
  %340 = fmul contract float %338, %339
  %341 = fsub contract float %336, %340
  store float %341, float addrspace(3)* %322, align 8, !tbaa !1
  %342 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 4
  %343 = load float, float addrspace(3)* %342, align 16, !tbaa !1
  %344 = load float, float addrspace(3)* %59, align 8, !tbaa !1
  %345 = fmul contract float %343, %344
  %346 = fsub contract float %341, %345
  store float %346, float addrspace(3)* %322, align 8, !tbaa !1
  %347 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 5
  %348 = load float, float addrspace(3)* %347, align 4, !tbaa !1
  %349 = load float, float addrspace(3)* %60, align 8, !tbaa !1
  %350 = fmul contract float %348, %349
  %351 = fsub contract float %346, %350
  store float %351, float addrspace(3)* %322, align 8, !tbaa !1
  %352 = load float, float addrspace(3)* %61, align 8, !tbaa !1
  %353 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 6
  %354 = fdiv contract float %351, %352
  store float %354, float addrspace(3)* %353, align 8, !tbaa !1
  %355 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 7
  %356 = load float, float addrspace(3)* %355, align 4, !tbaa !1
  %357 = load float, float addrspace(3)* %62, align 4, !tbaa !1
  %358 = fmul contract float %231, %357
  %359 = fsub contract float %356, %358
  store float %359, float addrspace(3)* %355, align 4, !tbaa !1
  %360 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 1
  %361 = load float, float addrspace(3)* %360, align 4, !tbaa !1
  %362 = load float, float addrspace(3)* %63, align 4, !tbaa !1
  %363 = fmul contract float %361, %362
  %364 = fsub contract float %359, %363
  store float %364, float addrspace(3)* %355, align 4, !tbaa !1
  %365 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 2
  %366 = load float, float addrspace(3)* %365, align 8, !tbaa !1
  %367 = load float, float addrspace(3)* %64, align 4, !tbaa !1
  %368 = fmul contract float %366, %367
  %369 = fsub contract float %364, %368
  store float %369, float addrspace(3)* %355, align 4, !tbaa !1
  %370 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 3
  %371 = load float, float addrspace(3)* %370, align 4, !tbaa !1
  %372 = load float, float addrspace(3)* %65, align 4, !tbaa !1
  %373 = fmul contract float %371, %372
  %374 = fsub contract float %369, %373
  store float %374, float addrspace(3)* %355, align 4, !tbaa !1
  %375 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 4
  %376 = load float, float addrspace(3)* %375, align 16, !tbaa !1
  %377 = load float, float addrspace(3)* %66, align 4, !tbaa !1
  %378 = fmul contract float %376, %377
  %379 = fsub contract float %374, %378
  store float %379, float addrspace(3)* %355, align 4, !tbaa !1
  %380 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 5
  %381 = load float, float addrspace(3)* %380, align 4, !tbaa !1
  %382 = load float, float addrspace(3)* %67, align 4, !tbaa !1
  %383 = fmul contract float %381, %382
  %384 = fsub contract float %379, %383
  store float %384, float addrspace(3)* %355, align 4, !tbaa !1
  %385 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 6
  %386 = load float, float addrspace(3)* %385, align 8, !tbaa !1
  %387 = load float, float addrspace(3)* %68, align 4, !tbaa !1
  %388 = fmul contract float %386, %387
  %389 = fsub contract float %384, %388
  store float %389, float addrspace(3)* %355, align 4, !tbaa !1
  %390 = load float, float addrspace(3)* %69, align 4, !tbaa !1
  %391 = getelementptr inbounds [8 x [8 x float]], [8 x [8 x float]] addrspace(3)* %4, i32 0, i32 %226, i32 7
  %392 = fdiv contract float %389, %390
  store float %392, float addrspace(3)* %391, align 4, !tbaa !1
  br label %393

393:                                              ; preds = %225, %70
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,1024" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"float", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
