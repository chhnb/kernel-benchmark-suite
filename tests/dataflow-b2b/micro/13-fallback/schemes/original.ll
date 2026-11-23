target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %d, i32* %q) {
entry:
  br i1 %C, label %left, label %right

left:
  %div = sdiv i32 %x, %d
  br label %join

right:
  %loaded = load i32, i32* %q, align 4
  br label %join

join:
  %result0 = phi i32 [ %div, %left ], [ %loaded, %right ]
  ret i32 %result0
}
