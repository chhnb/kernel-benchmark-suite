"""Seven real fusions, two shapes, including inverted final test and group/group."""
from pathlib import Path
import subprocess,json,tempfile,os
r=Path(__file__).resolve().parents[2];exe=r/'build/decision-fuse/decision-fuse';clang=os.environ.get('CLANG','/home/chh/darm-artifacts-repro/build/bin/clang')
def run(args):
 p=subprocess.run(list(map(str,args)),capture_output=True)
 if p.returncode:raise RuntimeError(str(args)+'\n'+p.stderr.decode()[-1500:])
 return p.stdout
lines=['define i32 @case(i32 %x) {','entry:',' %sign = sitofp i32 %x to float']
for i in range(7):
 if i:lines+=['t'+str(i)+':']
 lines+=[' %c'+str(i)+' = icmp '+('sge' if i==6 else 'slt')+' i32 %x, '+str(i*5)]
 yes='L7' if i==6 else 'L'+str(i);no='L6' if i==6 else 't'+str(i+1)
 lines+=[' br i1 %c'+str(i)+', label %'+yes+', label %'+no]
for i in range(8):lines+=['L'+str(i)+':',' %v'+str(i)+' = call float @llvm.copysign.f32(float '+str(i/2)+', float %sign)',' br label %join']
lines+=['join:',' %v = phi float '+', '.join('[%v'+str(i)+',%L'+str(i)+']' for i in range(8)),' %bits = bitcast float %v to i32',' ret i32 %bits','}','declare float @llvm.copysign.f32(float, float) nounwind readnone speculatable']
harness='''
@fmt = private constant [4 x i8] c"%d\\0A\\00"
declare i32 @printf(i8*, ...)
define i32 @main() {
e: br label %loop
loop:
 %i = phi i32 [-100, %e], [%n, %loop]
 %v = call i32 @case(i32 %i)
 %p = getelementptr [4 x i8], [4 x i8]* @fmt, i32 0, i32 0
 call i32 (i8*, ...) @printf(i8* %p, i32 %v)
 %n = add i32 %i, 1
 %c = icmp slt i32 %n, 101
 br i1 %c, label %loop, label %exit
exit: ret i32 0
}
'''
# Preserve failures for inspection; a new directory prevents stale outputs.
d=Path(tempfile.mkdtemp(prefix='decision-full-',dir=r/'build/decision-fuse'));source=d/'input.ll';source.write_text('\n'.join(lines)+harness);order=d/'order.json';order.write_text(json.dumps([{'entry':'%L'+str(i),'family':'fixture','index':i} for i in range(8)]))
def execute(p):
 e=p.with_suffix('.exe');run([clang,'-O0',p,'-o',e]);return run([e])
expected=execute(source)
for name,indices in [('recursive',[0]*7),('balanced',[0,1,2,3,0,1,0])]:
 current=source
 for step,left in enumerate(indices):
  out=d/(name+'-'+str(step));run([exe,current,'case',0,left,out,order]);t=json.loads((out/'trial.json').read_text());assert t['status']=='verified',t
  current=out/'fused.ll';assert execute(current)==expected,(name,step)
  calls=sum('call float @llvm.copysign.f32' in l for l in current.read_text().splitlines());assert calls==7-step,(name,step,calls)
 assert t.get('completed_decision'),t
 print(name,'7 fusions; 8 -> 1 copysign; all 201 outputs equal at every step',flush=True)
print('evidence',d)
