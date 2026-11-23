target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i1 %cond, i32 %same, i32 %x, i32 %y, i32 %k, i32 %m) {
entry:
  br i1 %C, label %left, label %right

left:
  %ls = select i1 %cond, i32 %same, i32 %x
  %lm = mul i32 %ls, %k
  %lout = mul i32 %lm, %m
  br label %join

right:
  %rs = select i1 %cond, i32 %same, i32 %y
  %rm = mul i32 %rs, %k
  %rout = mul i32 %rm, %m
  br label %join

join:
  %result0 = phi i32 [ %lout, %left ], [ %rout, %right ]
  ret i32 %result0
}
