import re
from pathlib import Path
d=Path(__file__).resolve().parent
text=r'''  %study.available = xor i1 %48, true
  %study.descends = xor i1 BACK, true
  %study.a = call i64 @llvm.amdgcn.ballot.i64(i1 %study.available)
  %study.b = call i64 @llvm.amdgcn.ballot.i64(i1 %study.descends)
  %study.active = call i64 @llvm.amdgcn.ballot.i64(i1 true)
  %study.leader = call i32 @llvm.amdgcn.readfirstlane(i32 %8)
  %study.lead = icmp eq i32 %8, %study.leader
  br i1 %study.lead, label %study.collect, label %study.resume

study.collect:
  %study.any.a = icmp ne i64 %study.a, 0
  %study.any.b = icmp ne i64 %study.b, 0
  %study.nonzero.kind = select i1 %study.any.b, i32 2, i32 1
  %study.kind = select i1 %study.any.a, i32 %study.nonzero.kind, i32 0
  %study.base = shl i32 %9, 2
  %study.cell = add i32 %study.base, %study.kind
  %study.cell64 = zext i32 %study.cell to i64
  %study.slot = getelementptr inbounds i64, i64 addrspace(1)* %study.counters, i64 %study.cell64
  %study.wave.update = atomicrmw add i64 addrspace(1)* %study.slot, i64 1 monotonic
  %study.lane.index = or i32 %study.base, 3
  %study.lane.index64 = zext i32 %study.lane.index to i64
  %study.lane.slot = getelementptr inbounds i64, i64 addrspace(1)* %study.counters, i64 %study.lane.index64
  %study.nactive = call i64 @llvm.ctpop.i64(i64 %study.active)
  %study.lane.update = atomicrmw add i64 addrspace(1)* %study.lane.slot, i64 %study.nactive monotonic
  br label %study.resume

study.resume:
'''
decls='''declare i64 @llvm.amdgcn.ballot.i64(i1) convergent nounwind readnone
declare i32 @llvm.amdgcn.readfirstlane(i32) convergent nounwind readnone
declare i64 @llvm.ctpop.i64(i64) nounwind readnone
'''
for version in ('P','C'):
 ir=(d/(version+'.ll')).read_text()
 ir,n=re.subn(r'(define protected amdgpu_kernel void [^\n]+i32 %6)\)',r'\1, i64 addrspace(1)* %study.counters)',ir)
 assert n==1
 if version=='P':
  marker='  br i1 %48, label %merged.bb14, label %merged.bb15'
  compute=('  %study.deeper = add nuw nsw i32 %36, 1\n'
           '  %study.last = icmp eq i32 %study.deeper, %1\n'
           '  %study.back = or i1 %48, %study.last\n')
  back='%study.back'
 else:
  marker='  br i1 %52, label %merged.bb33, label %merged.bb32'
  compute=''
  back='%52'
 assert ir.count(marker)==1
 ir=ir.replace(marker,compute+text.replace('BACK',back)+marker)
 ir=ir.replace('attributes #0 =',decls+'\nattributes #0 =')
 (d/(version+'-count.ll')).write_text(ir)
