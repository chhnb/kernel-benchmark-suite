target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %a, i32 %b, i32 %ap, i32 %bp, i32 %scale, i32 %mask) {
entry:
  %left = icmp sgt i32 %a, %b
  %right = icmp slt i32 %bp, %ap
  %condition = select i1 %C, i1 %left, i1 %right
  %z = zext i1 %condition to i32
  %m = mul i32 %z, %scale
  %result0 = xor i32 %m, %mask
  ret i32 %result0
}
