target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %k, i32 %fallback) {
entry:
  %a1 = add i32 %x, %k
  %a2 = xor i32 %a1, %k
  %a3 = add i32 %a2, %k
  %a4 = xor i32 %a3, %k
  %a5 = add i32 %a4, %k
  %a6 = xor i32 %a5, %k
  %a7 = add i32 %a6, %k
  %a8 = xor i32 %a7, %k
  %result0 = select i1 %C, i32 %a8, i32 %fallback
  ret i32 %result0
}
