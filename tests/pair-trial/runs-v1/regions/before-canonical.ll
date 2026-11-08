; ModuleID = '/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/regions/input.ll'
source_filename = "/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/regions/input.ll"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %d = icmp ne i32 %inner, 0
  br i1 %c, label %left, label %right

left:                                             ; preds = %entry
  br i1 %d, label %l0, label %l1

l0:                                               ; preds = %left
  %a = add i32 %x, 7
  br label %lj

l1:                                               ; preds = %left
  %b = mul i32 %x, 3
  br label %lj

lj:                                               ; preds = %l1, %l0
  %lv = phi i32 [ %a, %l0 ], [ %b, %l1 ]
  br label %join

right:                                            ; preds = %entry
  br i1 %d, label %r0, label %r1

r0:                                               ; preds = %right
  %u = sub i32 %x, 5
  br label %rj

r1:                                               ; preds = %right
  %v = mul i32 %x, 2
  br label %rj

rj:                                               ; preds = %r1, %r0
  %rv = phi i32 [ %u, %r0 ], [ %v, %r1 ]
  br label %join

join:                                             ; preds = %rj, %lj
  %z = phi i32 [ %lv, %lj ], [ %rv, %rj ]
  ret i32 %z
}
