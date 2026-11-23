target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i1 %lc, i1 %rc, i32 %a, i32 %b, i32 %d, i32 %e, i32 %x, i32 %y) {
entry:
  %lm = mul i32 %a, %x
  %ln = mul i32 %lm, %y
  %rt = sub i32 %d, %x
  %ru = xor i32 %rt, %y
  %ls = select i1 %lc, i32 %ln, i32 %b
  %rs = select i1 %rc, i32 %ru, i32 %e
  %result0 = select i1 %C, i32 %ls, i32 %rs
  ret i32 %result0
}
