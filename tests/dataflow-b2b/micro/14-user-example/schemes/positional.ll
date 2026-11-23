target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %z) {
entry:
  %first = select i1 %C, i32 %x, i32 %y
  %second = select i1 %C, i32 %y, i32 %z
  %result0 = add i32 %first, %second
  ret i32 %result0
}
