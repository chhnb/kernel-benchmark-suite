target triple = "amdgcn-amd-amdhsa"

define void @micro(i1 zeroext %C, i32 %x, i32 %xr, i32 %y, i32 %z, float %u, float %ur, float %v, float %w, i32* %out) {
entry:
  br i1 %C, label %left, label %right

left:
  %lf = mul i32 %x, %y
  %lf2 = sub i32 %lf, %z
  %lg = fmul float %u, %v
  %lg1 = fsub float %lg, %w
  %lg2 = bitcast float %lg1 to i32
  br label %join

right:
  %rg = fmul float %ur, %v
  %rg1 = fsub float %rg, %w
  %rg2 = bitcast float %rg1 to i32
  %rf = mul i32 %xr, %y
  %rf2 = sub i32 %rf, %z
  br label %join

join:
  %result0 = phi i32 [ %lf2, %left ], [ %rf2, %right ]
  %result1 = phi i32 [ %lg2, %left ], [ %rg2, %right ]
  %slot0 = getelementptr i32, i32* %out, i64 0
  store i32 %result0, i32* %slot0
  %slot1 = getelementptr i32, i32* %out, i64 1
  store i32 %result1, i32* %slot1
  ret void
}
