"""End-to-end CPU check of the new direct RegionMelder bridge."""
from pathlib import Path
import subprocess,tempfile,json,os
r=Path(__file__).resolve().parents[2];exe=r/'build/decision-fuse/decision-fuse'
clang=os.environ.get('CLANG','/home/chh/darm-artifacts-repro/build/bin/clang')
base=(Path(__file__).with_name('chain.ll')).read_text()
base=base.replace('%c0 =', '%sign = sitofp i32 %x to float\n  %c0 =')
for before,after in [('%av = add i32 %x, 100','%av = call float @llvm.copysign.f32(float 0.0, float %sign)'),('%bv = mul i32 %x, 7','%bv = call float @llvm.copysign.f32(float 0.5, float %sign)'),('%cv = sub i32 %x, 21','%cv = call float @llvm.copysign.f32(float 1.0, float %sign)'),('%dv = add i32 %x, 9','%dv = call float @llvm.copysign.f32(float 1.5, float %sign)')]:base=base.replace(before,after)
base=base.replace('%v = phi i32','%v = phi float').replace('ret i32 %v','%bits = bitcast float %v to i32\n  ret i32 %bits')+'\ndeclare float @llvm.copysign.f32(float, float) nounwind readnone speculatable\n'
base=base.replace('br i1 %c2, label %c, label %d','br i1 %c2, label %c, label %test3').replace('\na:\n','\ntest3:\n  %c3 = icmp slt i32 %x, 20\n  br i1 %c3, label %d, label %e\ne:\n  %ev = call float @llvm.copysign.f32(float 2.0, float %sign)\n  br label %join\na:\n').replace('[%dv,%d]', '[%dv,%d], [%ev,%e]')
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
def run(args):
 p=subprocess.run(list(map(str,args)),capture_output=True)
 if p.returncode:raise RuntimeError(p.stderr.decode()[-4000:])
 return p.stdout
with tempfile.TemporaryDirectory() as td:
 d=Path(td);parent=d/'input.ll';parent.write_text(base+harness)
 def execute(p):
  binary=p.with_suffix('.exe');run([clang,'-O0',p,'-o',binary]);return run([binary])
 expected=execute(parent)
 for step in range(3):
  out=d/str(step);run([exe,parent,'case',0,0,out]);t=json.loads((out/'trial.json').read_text())
  assert t['status']=='verified' and t['plan'] in ('B2B','native-must-execute-anchors') and t['speculated_gap_ranges']==0
  assert t['rebound_kind'] in ('Linear','SESE') and t['rebound_bindings']==1,t
  assert execute(out/'fused.ll')==expected
  decisions=json.loads((out/'decisions.json').read_text());assert len(decisions[0]['arms'][0]['merged_from'])==step+2
  parent=out/'fused.ll'
 print('three RegionMelder fusions; 201 outputs per stage equal; unique arm rebind; no speculation')
