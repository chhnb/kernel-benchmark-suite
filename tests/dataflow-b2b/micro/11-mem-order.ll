target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32* %p, i32* %q, i32 %x, i32 %fallback) {
entry:
  br i1 %C, label %left, label %join

left:
  store i32 %x, i32* %p, align 4
  %loaded = load i32, i32* %q, align 4
  br label %join

join:
  %result0 = phi i32 [ %loaded, %left ], [ %fallback, %entry ]
  ret i32 %result0
}
