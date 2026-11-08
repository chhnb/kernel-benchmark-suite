; ModuleID = '/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/regions/input.ll'
source_filename = "/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/regions/input.ll"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %d = icmp ne i32 %inner, 0
  br label %unify.bb

unify.bb:                                         ; preds = %entry
  br label %merged.bb

lj:                                               ; preds = %merged.branch.split
  br label %join

rj:                                               ; preds = %merged.branch.split6
  br label %join

join:                                             ; preds = %rj, %lj
  %z = phi i32 [ %5, %lj ], [ %6, %rj ]
  ret i32 %z

merged.bb:                                        ; preds = %unify.bb
  br i1 %d, label %merged.bb3, label %merged.bb4

merged.bb3:                                       ; preds = %merged.bb
  br i1 %c, label %predication.split, label %predication.tail

predication.split:                                ; preds = %merged.bb3
  %0 = add i32 %x, 7
  br label %predication.tail

predication.tail:                                 ; preds = %merged.bb3, %predication.split
  %1 = phi i32 [ %0, %predication.split ], [ undef, %merged.bb3 ]
  br i1 %c, label %predication.tail8, label %predication.split7

predication.split7:                               ; preds = %predication.tail
  %2 = sub i32 %x, 5
  br label %predication.tail8

predication.tail8:                                ; preds = %predication.tail, %predication.split7
  %3 = phi i32 [ %2, %predication.split7 ], [ undef, %predication.tail ]
  br label %merged.bb5

merged.bb4:                                       ; preds = %merged.bb
  %merged.select = select i1 %c, i32 3, i32 2
  %4 = mul i32 %x, %merged.select
  br label %merged.bb5

merged.bb5:                                       ; preds = %predication.tail8, %merged.bb4
  %5 = phi i32 [ %1, %predication.tail8 ], [ %4, %merged.bb4 ]
  %6 = phi i32 [ %3, %predication.tail8 ], [ %4, %merged.bb4 ]
  br i1 %c, label %merged.branch.split, label %merged.branch.split6

merged.branch.split:                              ; preds = %merged.bb5
  br label %lj

merged.branch.split6:                             ; preds = %merged.bb5
  br label %rj
}
