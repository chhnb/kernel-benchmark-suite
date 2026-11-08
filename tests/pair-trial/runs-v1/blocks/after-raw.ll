; ModuleID = '/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/blocks/input.ll'
source_filename = "/home/chh/kernel-benchmark-suite/tests/pair-trial/runs-v1/blocks/input.ll"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  br label %unify.bb

unify.bb:                                         ; preds = %entry
  br label %merged.bb

join:                                             ; preds = %merged.branch.split1, %merged.branch.split
  %v = phi i32 [ %1, %merged.branch.split ], [ %3, %merged.branch.split1 ]
  ret i32 %v

merged.bb:                                        ; preds = %unify.bb
  br i1 %c, label %predication.split, label %predication.tail

predication.split:                                ; preds = %merged.bb
  %0 = add i32 %x, 7
  br label %predication.tail

predication.tail:                                 ; preds = %merged.bb, %predication.split
  %1 = phi i32 [ %0, %predication.split ], [ undef, %merged.bb ]
  br i1 %c, label %predication.tail3, label %predication.split2

predication.split2:                               ; preds = %predication.tail
  %2 = mul i32 %x, 3
  br label %predication.tail3

predication.tail3:                                ; preds = %predication.tail, %predication.split2
  %3 = phi i32 [ %2, %predication.split2 ], [ undef, %predication.tail ]
  br i1 %c, label %merged.branch.split, label %merged.branch.split1

merged.branch.split:                              ; preds = %predication.tail3
  br label %join

merged.branch.split1:                             ; preds = %predication.tail3
  br label %join
}
