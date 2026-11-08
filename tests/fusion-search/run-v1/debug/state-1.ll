; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/run-v1/chain-before.ll'
source_filename = "<string>"

; Function Attrs: norecurse nounwind readnone
define i32 @choose(i32 %x, i32 %side, i32 %inner) local_unnamed_addr #0 {
entry:
  %c.not = icmp eq i32 %side, 0
  %merged.select = select i1 %c.not, i32 2000, i32 1000
  %0 = sdiv i32 %merged.select, %x
  %1 = mul nsw i32 %0, 3
  %2 = add nsw i32 %0, 7
  %v = select i1 %c.not, i32 %1, i32 %2
  %d.not = icmp eq i32 %inner, 0
  br i1 %d.not, label %r2, label %l2

l2:                                               ; preds = %entry
  %e = sdiv i32 3000, %v
  %ee = add nsw i32 %e, 11
  br label %end

r2:                                               ; preds = %entry
  %g = sdiv i32 4000, %v
  %gg = mul nsw i32 %g, 5
  br label %end

end:                                              ; preds = %r2, %l2
  %z = phi i32 [ %ee, %l2 ], [ %gg, %r2 ]
  ret i32 %z
}

attributes #0 = { norecurse nounwind readnone }
