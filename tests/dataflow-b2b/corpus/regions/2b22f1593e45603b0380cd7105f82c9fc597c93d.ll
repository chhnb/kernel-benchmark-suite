; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define void @region(i1 %0, i32 %1, [8192 x i32] addrspace(3)* %2, i32 %3, i32 addrspace(1)* %4) #0 {
  br i1 %0, label %6, label %390

6:                                                ; preds = %5
  %7 = shl nsw i32 %1, 6
  %8 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %3
  %9 = load i32, i32 addrspace(3)* %8, align 16, !tbaa !0
  %10 = sext i32 %7 to i64
  %11 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %10
  store i32 %9, i32 addrspace(1)* %11, align 4, !tbaa !0
  %12 = or i32 %3, 1
  %13 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %12
  %14 = load i32, i32 addrspace(3)* %13, align 4, !tbaa !0
  %15 = or i32 %7, 1
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %16
  store i32 %14, i32 addrspace(1)* %17, align 4, !tbaa !0
  %18 = or i32 %3, 2
  %19 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %18
  %20 = load i32, i32 addrspace(3)* %19, align 8, !tbaa !0
  %21 = or i32 %7, 2
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %22
  store i32 %20, i32 addrspace(1)* %23, align 4, !tbaa !0
  %24 = or i32 %3, 3
  %25 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %24
  %26 = load i32, i32 addrspace(3)* %25, align 4, !tbaa !0
  %27 = or i32 %7, 3
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %28
  store i32 %26, i32 addrspace(1)* %29, align 4, !tbaa !0
  %30 = or i32 %3, 4
  %31 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %30
  %32 = load i32, i32 addrspace(3)* %31, align 16, !tbaa !0
  %33 = or i32 %7, 4
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %34
  store i32 %32, i32 addrspace(1)* %35, align 4, !tbaa !0
  %36 = or i32 %3, 5
  %37 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %36
  %38 = load i32, i32 addrspace(3)* %37, align 4, !tbaa !0
  %39 = or i32 %7, 5
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %40
  store i32 %38, i32 addrspace(1)* %41, align 4, !tbaa !0
  %42 = or i32 %3, 6
  %43 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %42
  %44 = load i32, i32 addrspace(3)* %43, align 8, !tbaa !0
  %45 = or i32 %7, 6
  %46 = sext i32 %45 to i64
  %47 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %46
  store i32 %44, i32 addrspace(1)* %47, align 4, !tbaa !0
  %48 = or i32 %3, 7
  %49 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %48
  %50 = load i32, i32 addrspace(3)* %49, align 4, !tbaa !0
  %51 = or i32 %7, 7
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %52
  store i32 %50, i32 addrspace(1)* %53, align 4, !tbaa !0
  %54 = or i32 %3, 8
  %55 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %54
  %56 = load i32, i32 addrspace(3)* %55, align 16, !tbaa !0
  %57 = or i32 %7, 8
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %58
  store i32 %56, i32 addrspace(1)* %59, align 4, !tbaa !0
  %60 = or i32 %3, 9
  %61 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %60
  %62 = load i32, i32 addrspace(3)* %61, align 4, !tbaa !0
  %63 = or i32 %7, 9
  %64 = sext i32 %63 to i64
  %65 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %64
  store i32 %62, i32 addrspace(1)* %65, align 4, !tbaa !0
  %66 = or i32 %3, 10
  %67 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %66
  %68 = load i32, i32 addrspace(3)* %67, align 8, !tbaa !0
  %69 = or i32 %7, 10
  %70 = sext i32 %69 to i64
  %71 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %70
  store i32 %68, i32 addrspace(1)* %71, align 4, !tbaa !0
  %72 = or i32 %3, 11
  %73 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %72
  %74 = load i32, i32 addrspace(3)* %73, align 4, !tbaa !0
  %75 = or i32 %7, 11
  %76 = sext i32 %75 to i64
  %77 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %76
  store i32 %74, i32 addrspace(1)* %77, align 4, !tbaa !0
  %78 = or i32 %3, 12
  %79 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %78
  %80 = load i32, i32 addrspace(3)* %79, align 16, !tbaa !0
  %81 = or i32 %7, 12
  %82 = sext i32 %81 to i64
  %83 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %82
  store i32 %80, i32 addrspace(1)* %83, align 4, !tbaa !0
  %84 = or i32 %3, 13
  %85 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %84
  %86 = load i32, i32 addrspace(3)* %85, align 4, !tbaa !0
  %87 = or i32 %7, 13
  %88 = sext i32 %87 to i64
  %89 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %88
  store i32 %86, i32 addrspace(1)* %89, align 4, !tbaa !0
  %90 = or i32 %3, 14
  %91 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %90
  %92 = load i32, i32 addrspace(3)* %91, align 8, !tbaa !0
  %93 = or i32 %7, 14
  %94 = sext i32 %93 to i64
  %95 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %94
  store i32 %92, i32 addrspace(1)* %95, align 4, !tbaa !0
  %96 = or i32 %3, 15
  %97 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %96
  %98 = load i32, i32 addrspace(3)* %97, align 4, !tbaa !0
  %99 = or i32 %7, 15
  %100 = sext i32 %99 to i64
  %101 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %100
  store i32 %98, i32 addrspace(1)* %101, align 4, !tbaa !0
  %102 = or i32 %3, 16
  %103 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %102
  %104 = load i32, i32 addrspace(3)* %103, align 16, !tbaa !0
  %105 = or i32 %7, 16
  %106 = sext i32 %105 to i64
  %107 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %106
  store i32 %104, i32 addrspace(1)* %107, align 4, !tbaa !0
  %108 = or i32 %3, 17
  %109 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %108
  %110 = load i32, i32 addrspace(3)* %109, align 4, !tbaa !0
  %111 = or i32 %7, 17
  %112 = sext i32 %111 to i64
  %113 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %112
  store i32 %110, i32 addrspace(1)* %113, align 4, !tbaa !0
  %114 = or i32 %3, 18
  %115 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %114
  %116 = load i32, i32 addrspace(3)* %115, align 8, !tbaa !0
  %117 = or i32 %7, 18
  %118 = sext i32 %117 to i64
  %119 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %118
  store i32 %116, i32 addrspace(1)* %119, align 4, !tbaa !0
  %120 = or i32 %3, 19
  %121 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %120
  %122 = load i32, i32 addrspace(3)* %121, align 4, !tbaa !0
  %123 = or i32 %7, 19
  %124 = sext i32 %123 to i64
  %125 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %124
  store i32 %122, i32 addrspace(1)* %125, align 4, !tbaa !0
  %126 = or i32 %3, 20
  %127 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %126
  %128 = load i32, i32 addrspace(3)* %127, align 16, !tbaa !0
  %129 = or i32 %7, 20
  %130 = sext i32 %129 to i64
  %131 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %130
  store i32 %128, i32 addrspace(1)* %131, align 4, !tbaa !0
  %132 = or i32 %3, 21
  %133 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %132
  %134 = load i32, i32 addrspace(3)* %133, align 4, !tbaa !0
  %135 = or i32 %7, 21
  %136 = sext i32 %135 to i64
  %137 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %136
  store i32 %134, i32 addrspace(1)* %137, align 4, !tbaa !0
  %138 = or i32 %3, 22
  %139 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %138
  %140 = load i32, i32 addrspace(3)* %139, align 8, !tbaa !0
  %141 = or i32 %7, 22
  %142 = sext i32 %141 to i64
  %143 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %142
  store i32 %140, i32 addrspace(1)* %143, align 4, !tbaa !0
  %144 = or i32 %3, 23
  %145 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %144
  %146 = load i32, i32 addrspace(3)* %145, align 4, !tbaa !0
  %147 = or i32 %7, 23
  %148 = sext i32 %147 to i64
  %149 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %148
  store i32 %146, i32 addrspace(1)* %149, align 4, !tbaa !0
  %150 = or i32 %3, 24
  %151 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %150
  %152 = load i32, i32 addrspace(3)* %151, align 16, !tbaa !0
  %153 = or i32 %7, 24
  %154 = sext i32 %153 to i64
  %155 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %154
  store i32 %152, i32 addrspace(1)* %155, align 4, !tbaa !0
  %156 = or i32 %3, 25
  %157 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %156
  %158 = load i32, i32 addrspace(3)* %157, align 4, !tbaa !0
  %159 = or i32 %7, 25
  %160 = sext i32 %159 to i64
  %161 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %160
  store i32 %158, i32 addrspace(1)* %161, align 4, !tbaa !0
  %162 = or i32 %3, 26
  %163 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %162
  %164 = load i32, i32 addrspace(3)* %163, align 8, !tbaa !0
  %165 = or i32 %7, 26
  %166 = sext i32 %165 to i64
  %167 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %166
  store i32 %164, i32 addrspace(1)* %167, align 4, !tbaa !0
  %168 = or i32 %3, 27
  %169 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %168
  %170 = load i32, i32 addrspace(3)* %169, align 4, !tbaa !0
  %171 = or i32 %7, 27
  %172 = sext i32 %171 to i64
  %173 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %172
  store i32 %170, i32 addrspace(1)* %173, align 4, !tbaa !0
  %174 = or i32 %3, 28
  %175 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %174
  %176 = load i32, i32 addrspace(3)* %175, align 16, !tbaa !0
  %177 = or i32 %7, 28
  %178 = sext i32 %177 to i64
  %179 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %178
  store i32 %176, i32 addrspace(1)* %179, align 4, !tbaa !0
  %180 = or i32 %3, 29
  %181 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %180
  %182 = load i32, i32 addrspace(3)* %181, align 4, !tbaa !0
  %183 = or i32 %7, 29
  %184 = sext i32 %183 to i64
  %185 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %184
  store i32 %182, i32 addrspace(1)* %185, align 4, !tbaa !0
  %186 = or i32 %3, 30
  %187 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %186
  %188 = load i32, i32 addrspace(3)* %187, align 8, !tbaa !0
  %189 = or i32 %7, 30
  %190 = sext i32 %189 to i64
  %191 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %190
  store i32 %188, i32 addrspace(1)* %191, align 4, !tbaa !0
  %192 = or i32 %3, 31
  %193 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %192
  %194 = load i32, i32 addrspace(3)* %193, align 4, !tbaa !0
  %195 = or i32 %7, 31
  %196 = sext i32 %195 to i64
  %197 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %196
  store i32 %194, i32 addrspace(1)* %197, align 4, !tbaa !0
  %198 = or i32 %3, 32
  %199 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %198
  %200 = load i32, i32 addrspace(3)* %199, align 16, !tbaa !0
  %201 = or i32 %7, 32
  %202 = sext i32 %201 to i64
  %203 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %202
  store i32 %200, i32 addrspace(1)* %203, align 4, !tbaa !0
  %204 = or i32 %3, 33
  %205 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %204
  %206 = load i32, i32 addrspace(3)* %205, align 4, !tbaa !0
  %207 = or i32 %7, 33
  %208 = sext i32 %207 to i64
  %209 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %208
  store i32 %206, i32 addrspace(1)* %209, align 4, !tbaa !0
  %210 = or i32 %3, 34
  %211 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %210
  %212 = load i32, i32 addrspace(3)* %211, align 8, !tbaa !0
  %213 = or i32 %7, 34
  %214 = sext i32 %213 to i64
  %215 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %214
  store i32 %212, i32 addrspace(1)* %215, align 4, !tbaa !0
  %216 = or i32 %3, 35
  %217 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %216
  %218 = load i32, i32 addrspace(3)* %217, align 4, !tbaa !0
  %219 = or i32 %7, 35
  %220 = sext i32 %219 to i64
  %221 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %220
  store i32 %218, i32 addrspace(1)* %221, align 4, !tbaa !0
  %222 = or i32 %3, 36
  %223 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %222
  %224 = load i32, i32 addrspace(3)* %223, align 16, !tbaa !0
  %225 = or i32 %7, 36
  %226 = sext i32 %225 to i64
  %227 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %226
  store i32 %224, i32 addrspace(1)* %227, align 4, !tbaa !0
  %228 = or i32 %3, 37
  %229 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %228
  %230 = load i32, i32 addrspace(3)* %229, align 4, !tbaa !0
  %231 = or i32 %7, 37
  %232 = sext i32 %231 to i64
  %233 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %232
  store i32 %230, i32 addrspace(1)* %233, align 4, !tbaa !0
  %234 = or i32 %3, 38
  %235 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %234
  %236 = load i32, i32 addrspace(3)* %235, align 8, !tbaa !0
  %237 = or i32 %7, 38
  %238 = sext i32 %237 to i64
  %239 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %238
  store i32 %236, i32 addrspace(1)* %239, align 4, !tbaa !0
  %240 = or i32 %3, 39
  %241 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %240
  %242 = load i32, i32 addrspace(3)* %241, align 4, !tbaa !0
  %243 = or i32 %7, 39
  %244 = sext i32 %243 to i64
  %245 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %244
  store i32 %242, i32 addrspace(1)* %245, align 4, !tbaa !0
  %246 = or i32 %3, 40
  %247 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %246
  %248 = load i32, i32 addrspace(3)* %247, align 16, !tbaa !0
  %249 = or i32 %7, 40
  %250 = sext i32 %249 to i64
  %251 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %250
  store i32 %248, i32 addrspace(1)* %251, align 4, !tbaa !0
  %252 = or i32 %3, 41
  %253 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %252
  %254 = load i32, i32 addrspace(3)* %253, align 4, !tbaa !0
  %255 = or i32 %7, 41
  %256 = sext i32 %255 to i64
  %257 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %256
  store i32 %254, i32 addrspace(1)* %257, align 4, !tbaa !0
  %258 = or i32 %3, 42
  %259 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %258
  %260 = load i32, i32 addrspace(3)* %259, align 8, !tbaa !0
  %261 = or i32 %7, 42
  %262 = sext i32 %261 to i64
  %263 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %262
  store i32 %260, i32 addrspace(1)* %263, align 4, !tbaa !0
  %264 = or i32 %3, 43
  %265 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %264
  %266 = load i32, i32 addrspace(3)* %265, align 4, !tbaa !0
  %267 = or i32 %7, 43
  %268 = sext i32 %267 to i64
  %269 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %268
  store i32 %266, i32 addrspace(1)* %269, align 4, !tbaa !0
  %270 = or i32 %3, 44
  %271 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %270
  %272 = load i32, i32 addrspace(3)* %271, align 16, !tbaa !0
  %273 = or i32 %7, 44
  %274 = sext i32 %273 to i64
  %275 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %274
  store i32 %272, i32 addrspace(1)* %275, align 4, !tbaa !0
  %276 = or i32 %3, 45
  %277 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %276
  %278 = load i32, i32 addrspace(3)* %277, align 4, !tbaa !0
  %279 = or i32 %7, 45
  %280 = sext i32 %279 to i64
  %281 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %280
  store i32 %278, i32 addrspace(1)* %281, align 4, !tbaa !0
  %282 = or i32 %3, 46
  %283 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %282
  %284 = load i32, i32 addrspace(3)* %283, align 8, !tbaa !0
  %285 = or i32 %7, 46
  %286 = sext i32 %285 to i64
  %287 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %286
  store i32 %284, i32 addrspace(1)* %287, align 4, !tbaa !0
  %288 = or i32 %3, 47
  %289 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %288
  %290 = load i32, i32 addrspace(3)* %289, align 4, !tbaa !0
  %291 = or i32 %7, 47
  %292 = sext i32 %291 to i64
  %293 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %292
  store i32 %290, i32 addrspace(1)* %293, align 4, !tbaa !0
  %294 = or i32 %3, 48
  %295 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %294
  %296 = load i32, i32 addrspace(3)* %295, align 16, !tbaa !0
  %297 = or i32 %7, 48
  %298 = sext i32 %297 to i64
  %299 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %298
  store i32 %296, i32 addrspace(1)* %299, align 4, !tbaa !0
  %300 = or i32 %3, 49
  %301 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %300
  %302 = load i32, i32 addrspace(3)* %301, align 4, !tbaa !0
  %303 = or i32 %7, 49
  %304 = sext i32 %303 to i64
  %305 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %304
  store i32 %302, i32 addrspace(1)* %305, align 4, !tbaa !0
  %306 = or i32 %3, 50
  %307 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %306
  %308 = load i32, i32 addrspace(3)* %307, align 8, !tbaa !0
  %309 = or i32 %7, 50
  %310 = sext i32 %309 to i64
  %311 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %310
  store i32 %308, i32 addrspace(1)* %311, align 4, !tbaa !0
  %312 = or i32 %3, 51
  %313 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %312
  %314 = load i32, i32 addrspace(3)* %313, align 4, !tbaa !0
  %315 = or i32 %7, 51
  %316 = sext i32 %315 to i64
  %317 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %316
  store i32 %314, i32 addrspace(1)* %317, align 4, !tbaa !0
  %318 = or i32 %3, 52
  %319 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %318
  %320 = load i32, i32 addrspace(3)* %319, align 16, !tbaa !0
  %321 = or i32 %7, 52
  %322 = sext i32 %321 to i64
  %323 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %322
  store i32 %320, i32 addrspace(1)* %323, align 4, !tbaa !0
  %324 = or i32 %3, 53
  %325 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %324
  %326 = load i32, i32 addrspace(3)* %325, align 4, !tbaa !0
  %327 = or i32 %7, 53
  %328 = sext i32 %327 to i64
  %329 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %328
  store i32 %326, i32 addrspace(1)* %329, align 4, !tbaa !0
  %330 = or i32 %3, 54
  %331 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %330
  %332 = load i32, i32 addrspace(3)* %331, align 8, !tbaa !0
  %333 = or i32 %7, 54
  %334 = sext i32 %333 to i64
  %335 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %334
  store i32 %332, i32 addrspace(1)* %335, align 4, !tbaa !0
  %336 = or i32 %3, 55
  %337 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %336
  %338 = load i32, i32 addrspace(3)* %337, align 4, !tbaa !0
  %339 = or i32 %7, 55
  %340 = sext i32 %339 to i64
  %341 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %340
  store i32 %338, i32 addrspace(1)* %341, align 4, !tbaa !0
  %342 = or i32 %3, 56
  %343 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %342
  %344 = load i32, i32 addrspace(3)* %343, align 16, !tbaa !0
  %345 = or i32 %7, 56
  %346 = sext i32 %345 to i64
  %347 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %346
  store i32 %344, i32 addrspace(1)* %347, align 4, !tbaa !0
  %348 = or i32 %3, 57
  %349 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %348
  %350 = load i32, i32 addrspace(3)* %349, align 4, !tbaa !0
  %351 = or i32 %7, 57
  %352 = sext i32 %351 to i64
  %353 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %352
  store i32 %350, i32 addrspace(1)* %353, align 4, !tbaa !0
  %354 = or i32 %3, 58
  %355 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %354
  %356 = load i32, i32 addrspace(3)* %355, align 8, !tbaa !0
  %357 = or i32 %7, 58
  %358 = sext i32 %357 to i64
  %359 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %358
  store i32 %356, i32 addrspace(1)* %359, align 4, !tbaa !0
  %360 = or i32 %3, 59
  %361 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %360
  %362 = load i32, i32 addrspace(3)* %361, align 4, !tbaa !0
  %363 = or i32 %7, 59
  %364 = sext i32 %363 to i64
  %365 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %364
  store i32 %362, i32 addrspace(1)* %365, align 4, !tbaa !0
  %366 = or i32 %3, 60
  %367 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %366
  %368 = load i32, i32 addrspace(3)* %367, align 16, !tbaa !0
  %369 = or i32 %7, 60
  %370 = sext i32 %369 to i64
  %371 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %370
  store i32 %368, i32 addrspace(1)* %371, align 4, !tbaa !0
  %372 = or i32 %3, 61
  %373 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %372
  %374 = load i32, i32 addrspace(3)* %373, align 4, !tbaa !0
  %375 = or i32 %7, 61
  %376 = sext i32 %375 to i64
  %377 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %376
  store i32 %374, i32 addrspace(1)* %377, align 4, !tbaa !0
  %378 = or i32 %3, 62
  %379 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %378
  %380 = load i32, i32 addrspace(3)* %379, align 8, !tbaa !0
  %381 = or i32 %7, 62
  %382 = sext i32 %381 to i64
  %383 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %382
  store i32 %380, i32 addrspace(1)* %383, align 4, !tbaa !0
  %384 = or i32 %3, 63
  %385 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %2, i32 0, i32 %384
  %386 = load i32, i32 addrspace(3)* %385, align 4, !tbaa !0
  %387 = or i32 %7, 63
  %388 = sext i32 %387 to i64
  %389 = getelementptr inbounds i32, i32 addrspace(1)* %4, i64 %388
  store i32 %386, i32 addrspace(1)* %389, align 4, !tbaa !0
  br label %390

390:                                              ; preds = %6, %5
  ret void
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!1, !1, i64 0}
!1 = !{!"int", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C++ TBAA"}
