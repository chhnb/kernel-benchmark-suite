target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %x, i32 %y, i32 %z, i32 %scale, i32 %offset) {
entry:
  %first = select i1 %C, i32 %x, i32 %y
  %second = select i1 %C, i32 %y, i32 %z
  %sum = add i32 %first, %second
  %m = mul i32 %sum, %scale
  %result0 = sub i32 %m, %offset
  ret i32 %result0
}
