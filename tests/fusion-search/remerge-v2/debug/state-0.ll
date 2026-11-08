; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/remerge-v2/chain-before.ll'
source_filename = "<string>"

; Function Attrs: norecurse nounwind readnone
define i32 @choose(i32 %x, i32 %side, i32 %inner) local_unnamed_addr #0 {
entry:
  %c.not = icmp eq i32 %side, 0
  br i1 %c.not, label %right, label %left

left:                                             ; preds = %entry
  %a = sdiv i32 1000, %x
  %aa = add nsw i32 %a, 7
  br label %join

right:                                            ; preds = %entry
  %b = sdiv i32 2000, %x
  %bb = mul nsw i32 %b, 3
  br label %join

join:                                             ; preds = %right, %left
  %v = phi i32 [ %aa, %left ], [ %bb, %right ]
  %d.not = icmp eq i32 %inner, 0
  br i1 %d.not, label %r2, label %l2

l2:                                               ; preds = %join
  %e = sdiv i32 3000, %v
  %ee = add nsw i32 %e, 11
  br label %end

r2:                                               ; preds = %join
  %g = sdiv i32 4000, %v
  %gg = mul nsw i32 %g, 5
  br label %end

end:                                              ; preds = %r2, %l2
  %z = phi i32 [ %ee, %l2 ], [ %gg, %r2 ]
  ret i32 %z
}

attributes #0 = { norecurse nounwind readnone }
