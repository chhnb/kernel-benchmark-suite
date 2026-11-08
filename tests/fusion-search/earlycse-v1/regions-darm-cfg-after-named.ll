; ModuleID = '<string>'
source_filename = "<string>"

define i32 @after(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %d = icmp ne i32 %inner, 0
  br i1 %d, label %merged.bb5, label %merged.bb3

merged.bb3:                                       ; preds = %entry
  %merged.select = select i1 %c, i32 3, i32 2
  %0 = mul i32 %x, %merged.select
  br label %merged.bb4

merged.bb4:                                       ; preds = %merged.bb5, %merged.bb3
  %1 = phi i32 [ %0, %merged.bb3 ], [ %4, %merged.bb5 ]
  %2 = phi i32 [ %0, %merged.bb3 ], [ %6, %merged.bb5 ]
  %z = select i1 %c, i32 %1, i32 %2
  ret i32 %z

merged.bb5:                                       ; preds = %entry
  %3 = add i32 %x, 7
  %4 = select i1 %c, i32 %3, i32 undef
  %5 = sub i32 %x, 5
  %6 = select i1 %c, i32 undef, i32 %5
  br label %merged.bb4
}
