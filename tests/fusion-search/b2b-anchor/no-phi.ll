source_filename = "no-phi.ll"
target triple = "amdgcn-amd-amdhsa"

define void @diamond(i1 %cond, i32 %x) #0 {
entry:
  br i1 %cond, label %left, label %right

left:                                             ; preds = %entry
  %l = add i32 %x, 10
  br label %join

right:                                            ; preds = %entry
  %r = add i32 %x, 12
  br label %join

join:                                             ; preds = %right, %left
  ret void
}

attributes #0 = { "target-cpu"="gfx906" }
