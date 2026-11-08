; ModuleID = '/home/chh/kernel-benchmark-suite/tests/fusion-search/earlycse-v1/chain-before.ll'
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
  %merged.select1 = select i1 %d, i32 3000, i32 4000
  %3 = sdiv i32 %merged.select1, %v
  %4 = add i32 %3, 11
  %5 = mul i32 %3, 5
  %z = select i1 %d, i32 %4, i32 %5
  ret i32 %z
}
