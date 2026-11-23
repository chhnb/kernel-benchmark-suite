target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i1 %lc, i1 %rc, i32 %a, i32 %b, i32 %d, i32 %e, i32 %x, i32 %y) {
entry:
  br i1 %C, label %left, label %right

left:
  %lm = mul i32 %a, %x
  %ln = mul i32 %lm, %y
  %ls = select i1 %lc, i32 %ln, i32 %b
  br label %join

right:
  %rt = sub i32 %d, %x
  %ru = xor i32 %rt, %y
  %rs = select i1 %rc, i32 %ru, i32 %e
  br label %join

join:
  %result0 = phi i32 [ %ls, %left ], [ %rs, %right ]
  ret i32 %result0
}
