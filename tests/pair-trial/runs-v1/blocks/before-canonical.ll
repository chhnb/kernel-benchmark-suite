; ModuleID = '/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/blocks/input.ll'
source_filename = "/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/blocks/input.ll"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  br i1 %c, label %left, label %right

left:                                             ; preds = %entry
  %a = add i32 %x, 7
  br label %join

right:                                            ; preds = %entry
  %b = mul i32 %x, 3
  br label %join

join:                                             ; preds = %right, %left
  %v = phi i32 [ %a, %left ], [ %b, %right ]
  ret i32 %v
}
