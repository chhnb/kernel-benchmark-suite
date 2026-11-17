target triple = "amdgcn-amd-amdhsa"
@A = addrspace(1) global i32 0
@B = addrspace(1) global i32 0
@C = addrspace(1) global i32 0
define i32 @choose(i1 %p, i1 %q, i32 %x, i32 %y) #0 {
entry:
  br i1 %p, label %left1, label %right1
left1:
  store i32 %x, i32 addrspace(1)* @A, align 4
  br label %mid
right1:
  store i32 %y, i32 addrspace(1)* @B, align 4
  br label %mid
mid:
  br i1 %q, label %stage2, label %early
stage2:
  br i1 %p, label %left2, label %right2
left2:
  %a = load i32, i32 addrspace(1)* @A, align 4
  %aa = mul i32 %a, 7
  br label %exit
right2:
  %b = load i32, i32 addrspace(1)* @B, align 4
  %bb = mul i32 %b, 11
  br label %exit
exit:
  %v = phi i32 [%aa, %left2], [%bb, %right2]
  store i32 %v, i32 addrspace(1)* @C, align 4
  ret i32 %v
early:
  ret i32 0
}
attributes #0 = { "target-cpu"="gfx906" }
