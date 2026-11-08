; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/darm-cleanup-v1/chain-before.ll'
source_filename = "<string>"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %merged.select = select i1 %c, i32 1000, i32 2000
  %0 = sdiv i32 %merged.select, %x
  %1 = add i32 %0, 7
  %2 = select i1 %c, i32 %1, i32 undef
  %3 = mul i32 %0, 3
  %4 = select i1 %c, i32 undef, i32 %3
  %v = select i1 %c, i32 %2, i32 %4
  %d = icmp ne i32 %inner, 0
  br label %unify.bb

unify.bb:                                         ; preds = %entry
  br label %merged.bb

end:                                              ; preds = %merged.branch.split2, %merged.branch.split
  %z = phi i32 [ %7, %merged.branch.split ], [ %9, %merged.branch.split2 ]
  ret i32 %z

merged.bb:                                        ; preds = %unify.bb
  %merged.select1 = select i1 %d, i32 3000, i32 4000
  %5 = sdiv i32 %merged.select1, %v
  br i1 %d, label %predication.split, label %predication.tail

predication.split:                                ; preds = %merged.bb
  %6 = add i32 %5, 11
  br label %predication.tail

predication.tail:                                 ; preds = %merged.bb, %predication.split
  %7 = phi i32 [ %6, %predication.split ], [ undef, %merged.bb ]
  br i1 %d, label %predication.tail4, label %predication.split3

predication.split3:                               ; preds = %predication.tail
  %8 = mul i32 %5, 5
  br label %predication.tail4

predication.tail4:                                ; preds = %predication.tail, %predication.split3
  %9 = phi i32 [ %8, %predication.split3 ], [ undef, %predication.tail ]
  br i1 %d, label %merged.branch.split, label %merged.branch.split2

merged.branch.split:                              ; preds = %predication.tail4
  br label %end

merged.branch.split2:                             ; preds = %predication.tail4
  br label %end
}
