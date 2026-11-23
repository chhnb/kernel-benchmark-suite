target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %z) {
entry:
  %other = select i1 %C, i32 %x, i32 %z
  %result0 = add i32 %other, %y
  ret i32 %result0
}
