target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %z) {
entry:
  %a = add i32 %x, %y
  %b = add i32 %y, %z
  %result0 = select i1 %C, i32 %a, i32 %b
  ret i32 %result0
}
