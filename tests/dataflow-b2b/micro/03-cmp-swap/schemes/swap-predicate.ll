target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %a, i32 %b, i32 %ap, i32 %bp, i32 %scale, i32 %mask) {
entry:
  %first = select i1 %C, i32 %a, i32 %ap
  %second = select i1 %C, i32 %b, i32 %bp
  %condition = icmp sgt i32 %first, %second
  %z = zext i1 %condition to i32
  %m = mul i32 %z, %scale
  %result0 = xor i32 %m, %mask
  ret i32 %result0
}
