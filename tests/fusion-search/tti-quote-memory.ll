source_filename = "memory-context"
target triple = "amdgcn-amd-amdhsa"
@A = addrspace(1) global i32 0
@B = addrspace(1) global i32 0
@C = addrspace(1) global i32 0
@D = addrspace(1) global i32 0
define i32 @choose(i1 %p, i32 %x, i32 %y) #0 {
entry:
  store i32 %x, i32 addrspace(1)* @C, align 4
  store i32 %y, i32 addrspace(1)* @D, align 4
  br label %split
split:
  br i1 %p, label %left, label %right
left:
  %l = load i32, i32 addrspace(1)* @A, align 4
  %ll = mul i32 %l, 7
  br label %join
right:
  %r = load i32, i32 addrspace(1)* @B, align 4
  %rr = mul i32 %r, 11
  br label %join
join:
  %v = phi i32 [ %ll, %left ], [ %rr, %right ]
  ret i32 %v
}
attributes #0 = { "target-cpu"="gfx906" }
