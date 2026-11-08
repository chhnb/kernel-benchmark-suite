; ModuleID = '<string>'
source_filename = "<string>"

define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %d = icmp ne i32 %inner, 0
  br i1 %d, label %merged.bb4, label %merged.bb5

merged.bb:                                        ; preds = %merged.bb4, %merged.bb5
  %0 = phi i32 [ %6, %merged.bb5 ], [ %3, %merged.bb4 ]
  %1 = phi i32 [ %6, %merged.bb5 ], [ %5, %merged.bb4 ]
  %z = select i1 %c, i32 %0, i32 %1
  ret i32 %z

merged.bb4:                                       ; preds = %entry
  %2 = add i32 %x, 7
  %3 = select i1 %c, i32 %2, i32 undef
  %4 = sub i32 %x, 5
  %5 = select i1 %c, i32 undef, i32 %4
  br label %merged.bb

merged.bb5:                                       ; preds = %entry
  %merged.select = select i1 %c, i32 3, i32 2
  %6 = mul i32 %x, %merged.select
  br label %merged.bb
}
