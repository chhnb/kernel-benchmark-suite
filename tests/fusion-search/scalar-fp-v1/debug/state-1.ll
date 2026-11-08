; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/scalar-fp-v1/chain-before.ll'
source_filename = "<string>"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %merged.select = select i1 %c, i32 1000, i32 2000
  %0 = sdiv i32 %merged.select, %x
  %1 = add i32 %0, 7
  %2 = mul i32 %0, 3
  %v = select i1 %c, i32 %1, i32 %2
  %d = icmp ne i32 %inner, 0
  br i1 %d, label %l2, label %r2

l2:                                               ; preds = %entry
  %e = sdiv i32 3000, %v
  %ee = add i32 %e, 11
  br label %end

r2:                                               ; preds = %entry
  %g = sdiv i32 4000, %v
  %gg = mul i32 %g, 5
  br label %end

end:                                              ; preds = %r2, %l2
  %z = phi i32 [ %ee, %l2 ], [ %gg, %r2 ]
  ret i32 %z
}
