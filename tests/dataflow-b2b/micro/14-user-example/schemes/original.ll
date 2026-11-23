target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %z) {
entry:
  br i1 %C, label %left, label %right

left:
  %a = add i32 %x, %y
  br label %join

right:
  %b = add i32 %y, %z
  br label %join

join:
  %result0 = phi i32 [ %a, %left ], [ %b, %right ]
  ret i32 %result0
}
