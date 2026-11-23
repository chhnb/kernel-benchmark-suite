target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i1 %lc, i1 %rc, i32 %a, i32 %b, i32 %d, i32 %e, i32 %x, i32 %y) {
entry:
  %lm = mul i32 %a, %x
  %ln = mul i32 %lm, %y
  %rt = sub i32 %d, %x
  %ru = xor i32 %rt, %y
  %condition = select i1 %C, i1 %lc, i1 %rc
  %t = select i1 %C, i32 %ln, i32 %ru
  %f = select i1 %C, i32 %b, i32 %e
  %result0 = select i1 %condition, i32 %t, i32 %f
  ret i32 %result0
}
