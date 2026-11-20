target triple = "amdgcn-amd-amdhsa"
define i32 @store_mismatch(i1 %c, i32 %x, i32 %y, i32 addrspace(3)* %p, float %a, float %b) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  store i32 %x, i32 addrspace(3)* %p, align 4
  br label %join
right:
  store i32 %y, i32 addrspace(3)* %p, align 4, !tbaa !3
  br label %join
join:
  %v = phi i32 [ %x, %left ], [ %y, %right ]
  ret i32 %v
}
define i32 @load_range(i1 %c, i32 %x, i32 %y, i32 addrspace(3)* %p, float %a, float %b) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  %l = load i32, i32 addrspace(3)* %p, align 4, !range !4
  br label %join
right:
  %r = load i32, i32 addrspace(3)* %p, align 4
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %v
}
define i32 @add_flags(i1 %c, i32 %x, i32 %y, i32 addrspace(3)* %p, float %a, float %b) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  %l = add nsw nuw i32 %x, %y
  br label %join
right:
  %r = add i32 %y, 5
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %v
}
define i32 @exact_flags(i1 %c, i32 %x, i32 %y, i32 addrspace(3)* %p, float %a, float %b) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  %l = lshr exact i32 %x, 1
  br label %join
right:
  %r = lshr i32 %y, 1
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %v
}
define float @fmf_flags(i1 %c, i32 %x, i32 %y, i32 addrspace(3)* %p, float %a, float %b) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  %l = fadd nnan float %a, %b
  br label %join
right:
  %r = fadd float %b, %b
  br label %join
join:
  %v = phi float [ %l, %left ], [ %r, %right ]
  ret float %v
}
define i32 @tbaa_same(i1 %c, i32 %x, i32 %y, i32 addrspace(3)* %p, float %a, float %b) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  store i32 %x, i32 addrspace(3)* %p, align 4, !tbaa !3
  br label %join
right:
  store i32 %y, i32 addrspace(3)* %p, align 4, !tbaa !3
  br label %join
join:
  %v = phi i32 [ %x, %left ], [ %y, %right ]
  ret i32 %v
}
define i32 @tbaa_generic(i1 %c, i32 %x, i32 %y, i32 addrspace(3)* %p, float %a, float %b) #0 {
entry:
  br i1 %c, label %left, label %right
left:
  store i32 %x, i32 addrspace(3)* %p, align 4, !tbaa !3
  br label %join
right:
  store i32 %y, i32 addrspace(3)* %p, align 4, !tbaa !6
  br label %join
join:
  %v = phi i32 [ %x, %left ], [ %y, %right ]
  ret i32 %v
}
define i32 @region_load_range(i1 %side, i1 %test, i32 %x, i32 addrspace(3)* %p) #0 {
entry:
  br i1 %side, label %left, label %right
left:
  br i1 %test, label %left.work, label %left.exit
left.work:
  %ll = load i32, i32 addrspace(3)* %p, align 4, !range !4
  %a = mul i32 %ll, 7
  br label %left.exit
left.exit:
  %l = phi i32 [ %x, %left ], [ %a, %left.work ]
  %lv = add i32 %l, 1
  br label %join
right:
  br i1 %test, label %right.work, label %right.exit
right.work:
  %rr = load i32, i32 addrspace(3)* %p, align 4
  %b = mul i32 %rr, 11
  br label %right.exit
right.exit:
  %r = phi i32 [ %x, %right ], [ %b, %right.work ]
  %rv = sub i32 %r, 2
  br label %join
join:
  %result = phi i32 [ %lv, %left.exit ], [ %rv, %right.exit ]
  ret i32 %result
}
attributes #0 = { "target-cpu"="gfx906" }
!0 = !{!"root"}
!1 = !{!"int", !7, i64 0}
!3 = !{!1, !1, i64 0}
!4 = !{i32 0, i32 16}
!5 = !{!"ir-metadata-sibling", !7, i64 0}
!6 = !{!5, !5, i64 0}

!7 = !{!"common", !0, i64 0}
