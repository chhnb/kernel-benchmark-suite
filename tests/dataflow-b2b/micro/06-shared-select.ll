target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %p, i32 %q, i32 %k, i32 %m) {
entry:
  br i1 %C, label %left, label %right

left:
  %lm = mul i32 %p, %k
  %ls = sub i32 %p, %m
  %lout = add i32 %lm, %ls
  br label %join

right:
  %rm = mul i32 %q, %k
  %rs = sub i32 %q, %m
  %rout = add i32 %rm, %rs
  br label %join

join:
  %result0 = phi i32 [ %lout, %left ], [ %rout, %right ]
  ret i32 %result0
}
