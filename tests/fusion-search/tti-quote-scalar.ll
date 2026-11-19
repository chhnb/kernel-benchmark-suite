source_filename = "tti-quote-scalar"
target triple = "amdgcn-amd-amdhsa"
define i32 @choose(i1 %p, i32 %x, i32 %y) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %l = mul i32 %x, 7
  br label %join
right:
  %r = mul i32 %y, 11
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  %answer = add i32 %v, 23
  ret i32 %answer
}
define i32 @unrelated() { ret i32 91 }
attributes #0 = { "target-cpu"="gfx906" }
