target triple = "amdgcn-amd-amdhsa"

define void @micro(i1 zeroext %C, i32 %x, i32 %xr, i32 %y, i32 %z, float %u, float %ur, float %v, float %w, i32* %out) {
entry:
  %x1 = select i1 %C, i32 %x, i32 %xr
  %u1 = select i1 %C, float %u, float %ur
  %f = mul i32 %x1, %y
  %result0 = sub i32 %f, %z
  %g = fmul float %u1, %v
  %g1 = fsub float %g, %w
  %result1 = bitcast float %g1 to i32
  %slot0 = getelementptr i32, i32* %out, i64 0
  store i32 %result0, i32* %slot0
  %slot1 = getelementptr i32, i32* %out, i64 1
  store i32 %result1, i32* %slot1
  ret void
}
