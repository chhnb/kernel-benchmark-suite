; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/darm-cleanup-v1/chain-before.ll'
source_filename = "<string>"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  br i1 %c, label %left, label %right

left:                                             ; preds = %entry
  %a = sdiv i32 1000, %x
  %aa = add i32 %a, 7
  br label %join

right:                                            ; preds = %entry
  %b = sdiv i32 2000, %x
  %bb = mul i32 %b, 3
  br label %join

join:                                             ; preds = %right, %left
  %v = phi i32 [ %aa, %left ], [ %bb, %right ]
  %d = icmp ne i32 %inner, 0
  br i1 %d, label %l2, label %r2

l2:                                               ; preds = %join
  %e = sdiv i32 3000, %v
  %ee = add i32 %e, 11
  br label %end

r2:                                               ; preds = %join
  %g = sdiv i32 4000, %v
  %gg = mul i32 %g, 5
  br label %end

end:                                              ; preds = %r2, %l2
  %z = phi i32 [ %ee, %l2 ], [ %gg, %r2 ]
  ret i32 %z
}
