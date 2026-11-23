target triple = "amdgcn-amd-amdhsa"

define i32 @micro(i1 zeroext %C, i32 %a, i32 %b, i32 %ap, i32 %bp, i32 %scale, i32 %mask) {
entry:
  br i1 %C, label %left, label %right

left:
  %lc = icmp sgt i32 %a, %b
  %lz = zext i1 %lc to i32
  %lm = mul i32 %lz, %scale
  %lout = xor i32 %lm, %mask
  br label %join

right:
  %rc = icmp slt i32 %bp, %ap
  %rz = zext i1 %rc to i32
  %rm = mul i32 %rz, %scale
  %rout = xor i32 %rm, %mask
  br label %join

join:
  %result0 = phi i32 [ %lout, %left ], [ %rout, %right ]
  ret i32 %result0
}
