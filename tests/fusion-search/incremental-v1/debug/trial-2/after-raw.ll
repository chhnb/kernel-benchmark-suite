; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/incremental-v1/chain-before.ll'
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
  br label %unify.bb

unify.bb:                                         ; preds = %entry
  br label %merged.bb

end:                                              ; preds = %merged.branch.split2, %merged.branch.split
  %z = phi i32 [ %7, %merged.branch.split2 ], [ %5, %merged.branch.split ]
  ret i32 %z

merged.bb:                                        ; preds = %unify.bb
  %merged.select1 = select i1 %d.not, i32 4000, i32 3000
  %3 = sdiv i32 %merged.select1, %v
  br i1 %d.not, label %predication.split, label %predication.tail

predication.split:                                ; preds = %merged.bb
  %4 = mul nsw i32 %3, 5
  br label %predication.tail

predication.tail:                                 ; preds = %merged.bb, %predication.split
  %5 = phi i32 [ %4, %predication.split ], [ undef, %merged.bb ]
  br i1 %d.not, label %predication.tail4, label %predication.split3

predication.split3:                               ; preds = %predication.tail
  %6 = add nsw i32 %3, 11
  br label %predication.tail4

predication.tail4:                                ; preds = %predication.tail, %predication.split3
  %7 = phi i32 [ %6, %predication.split3 ], [ undef, %predication.tail ]
  br i1 %d.not, label %merged.branch.split, label %merged.branch.split2

merged.branch.split:                              ; preds = %predication.tail4
  br label %end

merged.branch.split2:                             ; preds = %predication.tail4
  br label %end
}

attributes #0 = { norecurse nounwind readnone }
