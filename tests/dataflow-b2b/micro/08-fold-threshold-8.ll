target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %k, i32 %fallback) {
entry:
  br i1 %C, label %left, label %join

left:
  %a1 = add i32 %x, %k
  %a2 = xor i32 %a1, %k
  %a3 = add i32 %a2, %k
  %a4 = xor i32 %a3, %k
  %a5 = add i32 %a4, %k
  %a6 = xor i32 %a5, %k
  %a7 = add i32 %a6, %k
  %a8 = xor i32 %a7, %k
  br label %join

join:
  %result0 = phi i32 [ %a8, %left ], [ %fallback, %entry ]
  ret i32 %result0
}
