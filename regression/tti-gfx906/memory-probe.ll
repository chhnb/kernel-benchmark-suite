target triple = "amdgcn-amd-amdhsa"
define void @probe(ptr addrspace(1) %g, ptr addrspace(3) %l, ptr addrspace(4) %c, ptr addrspace(5) %p) #0 {
entry:
  %g4 = load i32, ptr addrspace(1) %g, align 4
  store i32 %g4, ptr addrspace(1) %g, align 4
  %l4 = load i32, ptr addrspace(3) %l, align 4
  store i32 %l4, ptr addrspace(3) %l, align 4
  %c4 = load i32, ptr addrspace(4) %c, align 4
  %p4 = load i32, ptr addrspace(5) %p, align 4
  store i32 %p4, ptr addrspace(5) %p, align 4
  %g8 = load double, ptr addrspace(1) %g, align 8
  store double %g8, ptr addrspace(1) %g, align 8
  %l8 = load double, ptr addrspace(3) %l, align 8
  store double %l8, ptr addrspace(3) %l, align 8
  %c8 = load double, ptr addrspace(4) %c, align 8
  %p8 = load double, ptr addrspace(5) %p, align 8
  store double %p8, ptr addrspace(5) %p, align 8
  %g16 = load <4 x i32>, ptr addrspace(1) %g, align 16
  store <4 x i32> %g16, ptr addrspace(1) %g, align 16
  %l16 = load <4 x i32>, ptr addrspace(3) %l, align 16
  store <4 x i32> %l16, ptr addrspace(3) %l, align 16
  %c16 = load <4 x i32>, ptr addrspace(4) %c, align 16
  %p16 = load <4 x i32>, ptr addrspace(5) %p, align 16
  store <4 x i32> %p16, ptr addrspace(5) %p, align 16
  ret void
}
attributes #0 = { "target-cpu"="gfx906" }
