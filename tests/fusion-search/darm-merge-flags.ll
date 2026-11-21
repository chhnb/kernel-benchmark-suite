target triple = "amdgcn-amd-amdhsa"

define i32 @integer_flags(i1 %condition, i32 %a, i32 %b) #0 {
entry:
  br i1 %condition, label %left, label %right
left:
  %la = add nuw nsw i32 %a, 2
  %ls = shl nuw nsw i32 %la, 1
  %lr = lshr exact i32 %ls, 1
  br label %join
right:
  %ra = add nuw i32 %b, 3
  %rs = shl nuw i32 %ra, 2
  %rr = lshr i32 %rs, 1
  br label %join
join:
  %value = phi i32 [ %lr, %left ], [ %rr, %right ]
  ret i32 %value
}

define float @float_flags(i1 %condition, float %a, float %b) #0 {
entry:
  br i1 %condition, label %left, label %right
left:
  %l = fadd fast float %a, 2.0
  br label %join
right:
  %r = fadd float %b, 3.0
  br label %join
join:
  %value = phi float [ %l, %left ], [ %r, %right ]
  ret float %value
}

define i32 @memory_metadata(i1 %condition, i32 addrspace(3)* %a, i32 addrspace(3)* %b,
                           i32 addrspace(3)* %out) #0 {
entry:
  br i1 %condition, label %left, label %right
left:
  %l = load i32, i32 addrspace(3)* %a, align 4, !tbaa !2, !range !6
  store i32 %l, i32 addrspace(3)* %out, align 4, !tbaa !2
  br label %join
right:
  %r = load i32, i32 addrspace(3)* %b, align 4, !tbaa !5
  store i32 %r, i32 addrspace(3)* %out, align 4, !tbaa !5
  br label %join
join:
  %value = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %value
}

attributes #0 = { "target-cpu"="gfx906" }

!0 = !{!"root A"}
!1 = !{!"type A", !0, i64 0}
!2 = !{!1, !1, i64 0}
!3 = !{!"root B"}
!4 = !{!"type B", !3, i64 0}
!5 = !{!4, !4, i64 0}
!6 = !{i32 0, i32 8}
