import re
from pathlib import Path
d=Path(__file__).resolve().parent
raw=(d/'P.ll').read_text()
p=re.sub(r'%(1(?:0[7-9]|[1-4]\d))\b',r'%orig.\1',raw)
old_head='  br i1 %48, label %merged.bb14, label %merged.bb15'
assert p.count(old_head)==1
share=p.replace(old_head,'  %study.shared.previous = add nsw i32 %36, -1\n'+old_head)
for k in (113,143):
 share=share.replace(f'  %orig.{k} = add nsw i32 %36, -1\n','').replace(f'%orig.{k}', '%study.shared.previous')
# In this control, the two redundant operations must survive LLVM CSE and machine CSE.
# Issue the same single instruction through two opaque inline asm calls.
step='call i32 asm sideeffect "v_add_u32_e32 $0, -1, $1", "=v,v"(i32 %36)'
branch=p.replace(old_head,f'''  %study.next = add nuw nsw i32 %36, 1
  %study.last = icmp eq i32 %study.next, %1
  %study.back = or i1 %48, %study.last
  %study.dead.previous = {step}
  %study.leaf.previous = {step}
  %study.previous = select i1 %48, i32 %study.dead.previous, i32 %study.leaf.previous
  %study.more = add nsw i32 %35, 1
  %study.count = select i1 %48, i32 %35, i32 %study.more
  %study.new.count = select i1 %study.back, i32 %study.count, i32 %35
  br i1 %study.back, label %merged.bb14, label %merged.bb16''')
start=branch.index('merged.bb: ')
end=branch.index('merged.bb16: ',start)
branch=branch[:start]+'''merged.bb:
  %orig.110 = phi i32 [ %study.previous, %merged.bb14 ], [ %study.next, %merged.bb16 ]
  %orig.111 = phi i32 [ %study.new.count, %merged.bb14 ], [ %35, %merged.bb16 ]
  %orig.112 = icmp sgt i32 %orig.110, -1
  br i1 %orig.112, label %49, label %52, !llvm.loop !12

merged.bb14:
  br label %merged.bb

'''+branch[end:branch.index('merged.bb17: ',end)]+branch[branch.index('\n}',end):]
branch=branch.replace('%orig.114','%study.next')
for name,ir in (('V-share',share),('V-branch',branch)):
 (d/(name+'.ll')).write_text(ir)
