target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i1 %cond, i32 %same, i32 %x, i32 %y, i32 %k, i32 %m) {
entry:
  %other = select i1 %C, i32 %x, i32 %y
  %value = select i1 %cond, i32 %same, i32 %other
  %m1 = mul i32 %value, %k
  %result0 = mul i32 %m1, %m
  ret i32 %result0
}
