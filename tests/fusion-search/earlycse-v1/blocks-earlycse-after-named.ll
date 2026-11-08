; ModuleID = '<string>'
source_filename = "<string>"

define i32 @after(i32 %x, i32 %side, i32 %inner) {
entry:
  %c = icmp ne i32 %side, 0
  %0 = add i32 %x, 7
  %1 = mul i32 %x, 3
  %v = select i1 %c, i32 %0, i32 %1
  ret i32 %v
}
