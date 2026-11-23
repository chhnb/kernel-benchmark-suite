target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %z, i32 %scale, i32 %offset) {
entry:
  br i1 %C, label %left, label %right

left:
  %a = add i32 %x, %y
  %lm = mul i32 %a, %scale
  %lout = sub i32 %lm, %offset
  br label %join

right:
  %b = add i32 %y, %z
  %rm = mul i32 %b, %scale
  %rout = sub i32 %rm, %offset
  br label %join

join:
  %result0 = phi i32 [ %lout, %left ], [ %rout, %right ]
  ret i32 %result0
}
