; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/incremental-v1/chain-before.ll'
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
  br label %unify.bb

unify.bb:                                         ; preds = %join
  br label %merged.bb

end:                                              ; preds = %merged.branch.split1, %merged.branch.split
  %z = phi i32 [ %4, %merged.branch.split1 ], [ %2, %merged.branch.split ]
  ret i32 %z

merged.bb:                                        ; preds = %unify.bb
  %merged.select = select i1 %d.not, i32 4000, i32 3000
  %0 = sdiv i32 %merged.select, %v
  br i1 %d.not, label %predication.split, label %predication.tail

predication.split:                                ; preds = %merged.bb
  %1 = mul nsw i32 %0, 5
  br label %predication.tail

predication.tail:                                 ; preds = %merged.bb, %predication.split
  %2 = phi i32 [ %1, %predication.split ], [ undef, %merged.bb ]
  br i1 %d.not, label %predication.tail3, label %predication.split2

predication.split2:                               ; preds = %predication.tail
  %3 = add nsw i32 %0, 11
  br label %predication.tail3

predication.tail3:                                ; preds = %predication.tail, %predication.split2
  %4 = phi i32 [ %3, %predication.split2 ], [ undef, %predication.tail ]
  br i1 %d.not, label %merged.branch.split, label %merged.branch.split1

merged.branch.split:                              ; preds = %predication.tail3
  br label %end

merged.branch.split1:                             ; preds = %predication.tail3
  br label %end
}

attributes #0 = { norecurse nounwind readnone }
