target triple = "amdgcn-amd-amdhsa"

declare i32 @llvm.amdgcn.ds.swizzle(i32, i32 immarg) convergent

define i32 @micro(i1 zeroext %C, i32 %x, i32 %fallback) {
entry:
  br i1 %C, label %left, label %join

left:
  %shuffle = call i32 @llvm.amdgcn.ds.swizzle(i32 %x, i32 31)
  br label %join

join:
  %result0 = phi i32 [ %shuffle, %left ], [ %fallback, %entry ]
  ret i32 %result0
}
