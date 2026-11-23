target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %p, i32 %q, i32 %k, i32 %m) {
entry:
  %p1 = select i1 %C, i32 %p, i32 %q
  %first = mul i32 %p1, %k
  %second = sub i32 %p1, %m
  %result0 = add i32 %first, %second
  ret i32 %result0
}
