; ModuleID = 'dataflow-region'
source_filename = "dataflow-region"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-ni:7"
target triple = "amdgcn-amd-amdhsa"

; Function Attrs: convergent norecurse nounwind
define i32 @region(i1 %0, i32 %1, i32 %2, i32 addrspace(1)* %3, [8192 x i32] addrspace(3)* %4) #0 {
  br i1 %0, label %6, label %391

6:                                                ; preds = %5
  %7 = shl nsw i32 %1, 6
  %8 = shl nuw nsw i32 %2, 6
  %9 = sext i32 %7 to i64
  %10 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %9
  %11 = load i32, i32 addrspace(1)* %10, align 4, !tbaa !1
  %12 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %8
  store i32 %11, i32 addrspace(3)* %12, align 16, !tbaa !1
  %13 = or i32 %7, 1
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %14
  %16 = load i32, i32 addrspace(1)* %15, align 4, !tbaa !1
  %17 = or i32 %8, 1
  %18 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %17
  store i32 %16, i32 addrspace(3)* %18, align 4, !tbaa !1
  %19 = or i32 %7, 2
  %20 = sext i32 %19 to i64
  %21 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %20
  %22 = load i32, i32 addrspace(1)* %21, align 4, !tbaa !1
  %23 = or i32 %8, 2
  %24 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %23
  store i32 %22, i32 addrspace(3)* %24, align 8, !tbaa !1
  %25 = or i32 %7, 3
  %26 = sext i32 %25 to i64
  %27 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %26
  %28 = load i32, i32 addrspace(1)* %27, align 4, !tbaa !1
  %29 = or i32 %8, 3
  %30 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %29
  store i32 %28, i32 addrspace(3)* %30, align 4, !tbaa !1
  %31 = or i32 %7, 4
  %32 = sext i32 %31 to i64
  %33 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %32
  %34 = load i32, i32 addrspace(1)* %33, align 4, !tbaa !1
  %35 = or i32 %8, 4
  %36 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %35
  store i32 %34, i32 addrspace(3)* %36, align 16, !tbaa !1
  %37 = or i32 %7, 5
  %38 = sext i32 %37 to i64
  %39 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %38
  %40 = load i32, i32 addrspace(1)* %39, align 4, !tbaa !1
  %41 = or i32 %8, 5
  %42 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %41
  store i32 %40, i32 addrspace(3)* %42, align 4, !tbaa !1
  %43 = or i32 %7, 6
  %44 = sext i32 %43 to i64
  %45 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %44
  %46 = load i32, i32 addrspace(1)* %45, align 4, !tbaa !1
  %47 = or i32 %8, 6
  %48 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %47
  store i32 %46, i32 addrspace(3)* %48, align 8, !tbaa !1
  %49 = or i32 %7, 7
  %50 = sext i32 %49 to i64
  %51 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %50
  %52 = load i32, i32 addrspace(1)* %51, align 4, !tbaa !1
  %53 = or i32 %8, 7
  %54 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %53
  store i32 %52, i32 addrspace(3)* %54, align 4, !tbaa !1
  %55 = or i32 %7, 8
  %56 = sext i32 %55 to i64
  %57 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %56
  %58 = load i32, i32 addrspace(1)* %57, align 4, !tbaa !1
  %59 = or i32 %8, 8
  %60 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %59
  store i32 %58, i32 addrspace(3)* %60, align 16, !tbaa !1
  %61 = or i32 %7, 9
  %62 = sext i32 %61 to i64
  %63 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %62
  %64 = load i32, i32 addrspace(1)* %63, align 4, !tbaa !1
  %65 = or i32 %8, 9
  %66 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %65
  store i32 %64, i32 addrspace(3)* %66, align 4, !tbaa !1
  %67 = or i32 %7, 10
  %68 = sext i32 %67 to i64
  %69 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %68
  %70 = load i32, i32 addrspace(1)* %69, align 4, !tbaa !1
  %71 = or i32 %8, 10
  %72 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %71
  store i32 %70, i32 addrspace(3)* %72, align 8, !tbaa !1
  %73 = or i32 %7, 11
  %74 = sext i32 %73 to i64
  %75 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %74
  %76 = load i32, i32 addrspace(1)* %75, align 4, !tbaa !1
  %77 = or i32 %8, 11
  %78 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %77
  store i32 %76, i32 addrspace(3)* %78, align 4, !tbaa !1
  %79 = or i32 %7, 12
  %80 = sext i32 %79 to i64
  %81 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %80
  %82 = load i32, i32 addrspace(1)* %81, align 4, !tbaa !1
  %83 = or i32 %8, 12
  %84 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %83
  store i32 %82, i32 addrspace(3)* %84, align 16, !tbaa !1
  %85 = or i32 %7, 13
  %86 = sext i32 %85 to i64
  %87 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %86
  %88 = load i32, i32 addrspace(1)* %87, align 4, !tbaa !1
  %89 = or i32 %8, 13
  %90 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %89
  store i32 %88, i32 addrspace(3)* %90, align 4, !tbaa !1
  %91 = or i32 %7, 14
  %92 = sext i32 %91 to i64
  %93 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %92
  %94 = load i32, i32 addrspace(1)* %93, align 4, !tbaa !1
  %95 = or i32 %8, 14
  %96 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %95
  store i32 %94, i32 addrspace(3)* %96, align 8, !tbaa !1
  %97 = or i32 %7, 15
  %98 = sext i32 %97 to i64
  %99 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %98
  %100 = load i32, i32 addrspace(1)* %99, align 4, !tbaa !1
  %101 = or i32 %8, 15
  %102 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %101
  store i32 %100, i32 addrspace(3)* %102, align 4, !tbaa !1
  %103 = or i32 %7, 16
  %104 = sext i32 %103 to i64
  %105 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %104
  %106 = load i32, i32 addrspace(1)* %105, align 4, !tbaa !1
  %107 = or i32 %8, 16
  %108 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %107
  store i32 %106, i32 addrspace(3)* %108, align 16, !tbaa !1
  %109 = or i32 %7, 17
  %110 = sext i32 %109 to i64
  %111 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %110
  %112 = load i32, i32 addrspace(1)* %111, align 4, !tbaa !1
  %113 = or i32 %8, 17
  %114 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %113
  store i32 %112, i32 addrspace(3)* %114, align 4, !tbaa !1
  %115 = or i32 %7, 18
  %116 = sext i32 %115 to i64
  %117 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %116
  %118 = load i32, i32 addrspace(1)* %117, align 4, !tbaa !1
  %119 = or i32 %8, 18
  %120 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %119
  store i32 %118, i32 addrspace(3)* %120, align 8, !tbaa !1
  %121 = or i32 %7, 19
  %122 = sext i32 %121 to i64
  %123 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %122
  %124 = load i32, i32 addrspace(1)* %123, align 4, !tbaa !1
  %125 = or i32 %8, 19
  %126 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %125
  store i32 %124, i32 addrspace(3)* %126, align 4, !tbaa !1
  %127 = or i32 %7, 20
  %128 = sext i32 %127 to i64
  %129 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %128
  %130 = load i32, i32 addrspace(1)* %129, align 4, !tbaa !1
  %131 = or i32 %8, 20
  %132 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %131
  store i32 %130, i32 addrspace(3)* %132, align 16, !tbaa !1
  %133 = or i32 %7, 21
  %134 = sext i32 %133 to i64
  %135 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %134
  %136 = load i32, i32 addrspace(1)* %135, align 4, !tbaa !1
  %137 = or i32 %8, 21
  %138 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %137
  store i32 %136, i32 addrspace(3)* %138, align 4, !tbaa !1
  %139 = or i32 %7, 22
  %140 = sext i32 %139 to i64
  %141 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %140
  %142 = load i32, i32 addrspace(1)* %141, align 4, !tbaa !1
  %143 = or i32 %8, 22
  %144 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %143
  store i32 %142, i32 addrspace(3)* %144, align 8, !tbaa !1
  %145 = or i32 %7, 23
  %146 = sext i32 %145 to i64
  %147 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %146
  %148 = load i32, i32 addrspace(1)* %147, align 4, !tbaa !1
  %149 = or i32 %8, 23
  %150 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %149
  store i32 %148, i32 addrspace(3)* %150, align 4, !tbaa !1
  %151 = or i32 %7, 24
  %152 = sext i32 %151 to i64
  %153 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %152
  %154 = load i32, i32 addrspace(1)* %153, align 4, !tbaa !1
  %155 = or i32 %8, 24
  %156 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %155
  store i32 %154, i32 addrspace(3)* %156, align 16, !tbaa !1
  %157 = or i32 %7, 25
  %158 = sext i32 %157 to i64
  %159 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %158
  %160 = load i32, i32 addrspace(1)* %159, align 4, !tbaa !1
  %161 = or i32 %8, 25
  %162 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %161
  store i32 %160, i32 addrspace(3)* %162, align 4, !tbaa !1
  %163 = or i32 %7, 26
  %164 = sext i32 %163 to i64
  %165 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %164
  %166 = load i32, i32 addrspace(1)* %165, align 4, !tbaa !1
  %167 = or i32 %8, 26
  %168 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %167
  store i32 %166, i32 addrspace(3)* %168, align 8, !tbaa !1
  %169 = or i32 %7, 27
  %170 = sext i32 %169 to i64
  %171 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %170
  %172 = load i32, i32 addrspace(1)* %171, align 4, !tbaa !1
  %173 = or i32 %8, 27
  %174 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %173
  store i32 %172, i32 addrspace(3)* %174, align 4, !tbaa !1
  %175 = or i32 %7, 28
  %176 = sext i32 %175 to i64
  %177 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %176
  %178 = load i32, i32 addrspace(1)* %177, align 4, !tbaa !1
  %179 = or i32 %8, 28
  %180 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %179
  store i32 %178, i32 addrspace(3)* %180, align 16, !tbaa !1
  %181 = or i32 %7, 29
  %182 = sext i32 %181 to i64
  %183 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %182
  %184 = load i32, i32 addrspace(1)* %183, align 4, !tbaa !1
  %185 = or i32 %8, 29
  %186 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %185
  store i32 %184, i32 addrspace(3)* %186, align 4, !tbaa !1
  %187 = or i32 %7, 30
  %188 = sext i32 %187 to i64
  %189 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %188
  %190 = load i32, i32 addrspace(1)* %189, align 4, !tbaa !1
  %191 = or i32 %8, 30
  %192 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %191
  store i32 %190, i32 addrspace(3)* %192, align 8, !tbaa !1
  %193 = or i32 %7, 31
  %194 = sext i32 %193 to i64
  %195 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %194
  %196 = load i32, i32 addrspace(1)* %195, align 4, !tbaa !1
  %197 = or i32 %8, 31
  %198 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %197
  store i32 %196, i32 addrspace(3)* %198, align 4, !tbaa !1
  %199 = or i32 %7, 32
  %200 = sext i32 %199 to i64
  %201 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %200
  %202 = load i32, i32 addrspace(1)* %201, align 4, !tbaa !1
  %203 = or i32 %8, 32
  %204 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %203
  store i32 %202, i32 addrspace(3)* %204, align 16, !tbaa !1
  %205 = or i32 %7, 33
  %206 = sext i32 %205 to i64
  %207 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %206
  %208 = load i32, i32 addrspace(1)* %207, align 4, !tbaa !1
  %209 = or i32 %8, 33
  %210 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %209
  store i32 %208, i32 addrspace(3)* %210, align 4, !tbaa !1
  %211 = or i32 %7, 34
  %212 = sext i32 %211 to i64
  %213 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %212
  %214 = load i32, i32 addrspace(1)* %213, align 4, !tbaa !1
  %215 = or i32 %8, 34
  %216 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %215
  store i32 %214, i32 addrspace(3)* %216, align 8, !tbaa !1
  %217 = or i32 %7, 35
  %218 = sext i32 %217 to i64
  %219 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %218
  %220 = load i32, i32 addrspace(1)* %219, align 4, !tbaa !1
  %221 = or i32 %8, 35
  %222 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %221
  store i32 %220, i32 addrspace(3)* %222, align 4, !tbaa !1
  %223 = or i32 %7, 36
  %224 = sext i32 %223 to i64
  %225 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %224
  %226 = load i32, i32 addrspace(1)* %225, align 4, !tbaa !1
  %227 = or i32 %8, 36
  %228 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %227
  store i32 %226, i32 addrspace(3)* %228, align 16, !tbaa !1
  %229 = or i32 %7, 37
  %230 = sext i32 %229 to i64
  %231 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %230
  %232 = load i32, i32 addrspace(1)* %231, align 4, !tbaa !1
  %233 = or i32 %8, 37
  %234 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %233
  store i32 %232, i32 addrspace(3)* %234, align 4, !tbaa !1
  %235 = or i32 %7, 38
  %236 = sext i32 %235 to i64
  %237 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %236
  %238 = load i32, i32 addrspace(1)* %237, align 4, !tbaa !1
  %239 = or i32 %8, 38
  %240 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %239
  store i32 %238, i32 addrspace(3)* %240, align 8, !tbaa !1
  %241 = or i32 %7, 39
  %242 = sext i32 %241 to i64
  %243 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %242
  %244 = load i32, i32 addrspace(1)* %243, align 4, !tbaa !1
  %245 = or i32 %8, 39
  %246 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %245
  store i32 %244, i32 addrspace(3)* %246, align 4, !tbaa !1
  %247 = or i32 %7, 40
  %248 = sext i32 %247 to i64
  %249 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %248
  %250 = load i32, i32 addrspace(1)* %249, align 4, !tbaa !1
  %251 = or i32 %8, 40
  %252 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %251
  store i32 %250, i32 addrspace(3)* %252, align 16, !tbaa !1
  %253 = or i32 %7, 41
  %254 = sext i32 %253 to i64
  %255 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %254
  %256 = load i32, i32 addrspace(1)* %255, align 4, !tbaa !1
  %257 = or i32 %8, 41
  %258 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %257
  store i32 %256, i32 addrspace(3)* %258, align 4, !tbaa !1
  %259 = or i32 %7, 42
  %260 = sext i32 %259 to i64
  %261 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %260
  %262 = load i32, i32 addrspace(1)* %261, align 4, !tbaa !1
  %263 = or i32 %8, 42
  %264 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %263
  store i32 %262, i32 addrspace(3)* %264, align 8, !tbaa !1
  %265 = or i32 %7, 43
  %266 = sext i32 %265 to i64
  %267 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %266
  %268 = load i32, i32 addrspace(1)* %267, align 4, !tbaa !1
  %269 = or i32 %8, 43
  %270 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %269
  store i32 %268, i32 addrspace(3)* %270, align 4, !tbaa !1
  %271 = or i32 %7, 44
  %272 = sext i32 %271 to i64
  %273 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %272
  %274 = load i32, i32 addrspace(1)* %273, align 4, !tbaa !1
  %275 = or i32 %8, 44
  %276 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %275
  store i32 %274, i32 addrspace(3)* %276, align 16, !tbaa !1
  %277 = or i32 %7, 45
  %278 = sext i32 %277 to i64
  %279 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %278
  %280 = load i32, i32 addrspace(1)* %279, align 4, !tbaa !1
  %281 = or i32 %8, 45
  %282 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %281
  store i32 %280, i32 addrspace(3)* %282, align 4, !tbaa !1
  %283 = or i32 %7, 46
  %284 = sext i32 %283 to i64
  %285 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %284
  %286 = load i32, i32 addrspace(1)* %285, align 4, !tbaa !1
  %287 = or i32 %8, 46
  %288 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %287
  store i32 %286, i32 addrspace(3)* %288, align 8, !tbaa !1
  %289 = or i32 %7, 47
  %290 = sext i32 %289 to i64
  %291 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %290
  %292 = load i32, i32 addrspace(1)* %291, align 4, !tbaa !1
  %293 = or i32 %8, 47
  %294 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %293
  store i32 %292, i32 addrspace(3)* %294, align 4, !tbaa !1
  %295 = or i32 %7, 48
  %296 = sext i32 %295 to i64
  %297 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %296
  %298 = load i32, i32 addrspace(1)* %297, align 4, !tbaa !1
  %299 = or i32 %8, 48
  %300 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %299
  store i32 %298, i32 addrspace(3)* %300, align 16, !tbaa !1
  %301 = or i32 %7, 49
  %302 = sext i32 %301 to i64
  %303 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %302
  %304 = load i32, i32 addrspace(1)* %303, align 4, !tbaa !1
  %305 = or i32 %8, 49
  %306 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %305
  store i32 %304, i32 addrspace(3)* %306, align 4, !tbaa !1
  %307 = or i32 %7, 50
  %308 = sext i32 %307 to i64
  %309 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %308
  %310 = load i32, i32 addrspace(1)* %309, align 4, !tbaa !1
  %311 = or i32 %8, 50
  %312 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %311
  store i32 %310, i32 addrspace(3)* %312, align 8, !tbaa !1
  %313 = or i32 %7, 51
  %314 = sext i32 %313 to i64
  %315 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %314
  %316 = load i32, i32 addrspace(1)* %315, align 4, !tbaa !1
  %317 = or i32 %8, 51
  %318 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %317
  store i32 %316, i32 addrspace(3)* %318, align 4, !tbaa !1
  %319 = or i32 %7, 52
  %320 = sext i32 %319 to i64
  %321 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %320
  %322 = load i32, i32 addrspace(1)* %321, align 4, !tbaa !1
  %323 = or i32 %8, 52
  %324 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %323
  store i32 %322, i32 addrspace(3)* %324, align 16, !tbaa !1
  %325 = or i32 %7, 53
  %326 = sext i32 %325 to i64
  %327 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %326
  %328 = load i32, i32 addrspace(1)* %327, align 4, !tbaa !1
  %329 = or i32 %8, 53
  %330 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %329
  store i32 %328, i32 addrspace(3)* %330, align 4, !tbaa !1
  %331 = or i32 %7, 54
  %332 = sext i32 %331 to i64
  %333 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %332
  %334 = load i32, i32 addrspace(1)* %333, align 4, !tbaa !1
  %335 = or i32 %8, 54
  %336 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %335
  store i32 %334, i32 addrspace(3)* %336, align 8, !tbaa !1
  %337 = or i32 %7, 55
  %338 = sext i32 %337 to i64
  %339 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %338
  %340 = load i32, i32 addrspace(1)* %339, align 4, !tbaa !1
  %341 = or i32 %8, 55
  %342 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %341
  store i32 %340, i32 addrspace(3)* %342, align 4, !tbaa !1
  %343 = or i32 %7, 56
  %344 = sext i32 %343 to i64
  %345 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %344
  %346 = load i32, i32 addrspace(1)* %345, align 4, !tbaa !1
  %347 = or i32 %8, 56
  %348 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %347
  store i32 %346, i32 addrspace(3)* %348, align 16, !tbaa !1
  %349 = or i32 %7, 57
  %350 = sext i32 %349 to i64
  %351 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %350
  %352 = load i32, i32 addrspace(1)* %351, align 4, !tbaa !1
  %353 = or i32 %8, 57
  %354 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %353
  store i32 %352, i32 addrspace(3)* %354, align 4, !tbaa !1
  %355 = or i32 %7, 58
  %356 = sext i32 %355 to i64
  %357 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %356
  %358 = load i32, i32 addrspace(1)* %357, align 4, !tbaa !1
  %359 = or i32 %8, 58
  %360 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %359
  store i32 %358, i32 addrspace(3)* %360, align 8, !tbaa !1
  %361 = or i32 %7, 59
  %362 = sext i32 %361 to i64
  %363 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %362
  %364 = load i32, i32 addrspace(1)* %363, align 4, !tbaa !1
  %365 = or i32 %8, 59
  %366 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %365
  store i32 %364, i32 addrspace(3)* %366, align 4, !tbaa !1
  %367 = or i32 %7, 60
  %368 = sext i32 %367 to i64
  %369 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %368
  %370 = load i32, i32 addrspace(1)* %369, align 4, !tbaa !1
  %371 = or i32 %8, 60
  %372 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %371
  store i32 %370, i32 addrspace(3)* %372, align 16, !tbaa !1
  %373 = or i32 %7, 61
  %374 = sext i32 %373 to i64
  %375 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %374
  %376 = load i32, i32 addrspace(1)* %375, align 4, !tbaa !1
  %377 = or i32 %8, 61
  %378 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %377
  store i32 %376, i32 addrspace(3)* %378, align 4, !tbaa !1
  %379 = or i32 %7, 62
  %380 = sext i32 %379 to i64
  %381 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %380
  %382 = load i32, i32 addrspace(1)* %381, align 4, !tbaa !1
  %383 = or i32 %8, 62
  %384 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %383
  store i32 %382, i32 addrspace(3)* %384, align 8, !tbaa !1
  %385 = or i32 %7, 63
  %386 = sext i32 %385 to i64
  %387 = getelementptr inbounds i32, i32 addrspace(1)* %3, i64 %386
  %388 = load i32, i32 addrspace(1)* %387, align 4, !tbaa !1
  %389 = or i32 %8, 63
  %390 = getelementptr inbounds [8192 x i32], [8192 x i32] addrspace(3)* %4, i32 0, i32 %389
  store i32 %388, i32 addrspace(3)* %390, align 4, !tbaa !1
  br label %393

391:                                              ; preds = %5
  %392 = shl nuw nsw i32 %2, 6
  br label %393

393:                                              ; preds = %391, %6
  %394 = phi i32 [ %8, %6 ], [ %392, %391 ]
  ret i32 %394
}

attributes #0 = { convergent norecurse nounwind "amdgpu-flat-work-group-size"="1,256" "amdgpu-implicitarg-num-bytes"="56" "amdgpu-unsafe-fp-atomics"="true" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx906" "target-features"="+16-bit-insts,+ci-insts,+dl-insts,+dot1-insts,+dot2-insts,+dpp,+flat-address-space,+gfx8-insts,+gfx9-insts,+s-memrealtime" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }

!dataflow.builtin.inputs = !{!0}

!0 = !{i32 2, !"llvm.amdgcn.workitem.id.x"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C++ TBAA"}
