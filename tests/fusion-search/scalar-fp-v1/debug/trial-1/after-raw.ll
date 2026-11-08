; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/scalar-fp-v1/chain-before.ll'
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
  br label %unify.bb

unify.bb:                                         ; preds = %join
  br label %merged.bb

end:                                              ; preds = %merged.branch.split1, %merged.branch.split
  %z = phi i32 [ %2, %merged.branch.split ], [ %4, %merged.branch.split1 ]
  ret i32 %z

merged.bb:                                        ; preds = %unify.bb
  %merged.select = select i1 %d, i32 3000, i32 4000
  %0 = sdiv i32 %merged.select, %v
  br i1 %d, label %predication.split, label %predication.tail

predication.split:                                ; preds = %merged.bb
  %1 = add i32 %0, 11
  br label %predication.tail

predication.tail:                                 ; preds = %merged.bb, %predication.split
  %2 = phi i32 [ %1, %predication.split ], [ undef, %merged.bb ]
  br i1 %d, label %predication.tail3, label %predication.split2

predication.split2:                               ; preds = %predication.tail
  %3 = mul i32 %0, 5
  br label %predication.tail3

predication.tail3:                                ; preds = %predication.tail, %predication.split2
  %4 = phi i32 [ %3, %predication.split2 ], [ undef, %predication.tail ]
  br i1 %d, label %merged.branch.split, label %merged.branch.split1

merged.branch.split:                              ; preds = %predication.tail3
  br label %end

merged.branch.split1:                             ; preds = %predication.tail3
  br label %end
}
