; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/remerge-v2/chain-before.ll'
source_filename = "<string>"

; Function Attrs: norecurse nounwind readnone
define i32 @choose(i32 %x, i32 %side, i32 %inner) local_unnamed_addr #0 {
entry:
  %c.not = icmp eq i32 %side, 0
  br label %unify.bb

unify.bb:                                         ; preds = %entry
  br label %merged.bb

join:                                             ; preds = %merged.branch.split1, %merged.branch.split
  %v = phi i32 [ %4, %merged.branch.split1 ], [ %2, %merged.branch.split ]
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

merged.bb:                                        ; preds = %unify.bb
  %merged.select = select i1 %c.not, i32 2000, i32 1000
  %0 = sdiv i32 %merged.select, %x
  br i1 %c.not, label %predication.split, label %predication.tail

predication.split:                                ; preds = %merged.bb
  %1 = mul nsw i32 %0, 3
  br label %predication.tail

predication.tail:                                 ; preds = %merged.bb, %predication.split
  %2 = phi i32 [ %1, %predication.split ], [ undef, %merged.bb ]
  br i1 %c.not, label %predication.tail3, label %predication.split2

predication.split2:                               ; preds = %predication.tail
  %3 = add nsw i32 %0, 7
  br label %predication.tail3

predication.tail3:                                ; preds = %predication.tail, %predication.split2
  %4 = phi i32 [ %3, %predication.split2 ], [ undef, %predication.tail ]
  br i1 %c.not, label %merged.branch.split, label %merged.branch.split1

merged.branch.split:                              ; preds = %predication.tail3
  br label %join

merged.branch.split1:                             ; preds = %predication.tail3
  br label %join
}

attributes #0 = { norecurse nounwind readnone }
