#!/usr/bin/env python3
"""CPU execution equivalence and conservative structural checks, LLVM12."""
import json, subprocess, tempfile, pathlib, os
root=pathlib.Path(__file__).resolve().parents[2]
binary=root/'build/decision-model/decision-model'
clang=os.environ.get('CLANG','/home/chh/darm-artifacts-repro/build/bin/clang')
base=(pathlib.Path(__file__).parent/'chain.ll').read_text()
harness='''
@fmt = private constant [4 x i8] c"%d\\0A\\00"
declare i32 @printf(i8*, ...)
define i32 @main() {
entry:
 br label %loop
loop:
 %i = phi i32 [-100, %entry], [%n, %loop]
 %v = call i32 @case(i32 %i)
 %p = getelementptr [4 x i8], [4 x i8]* @fmt, i32 0, i32 0
 call i32 (i8*, ...) @printf(i8* %p, i32 %v)
 %n = add i32 %i, 1
 %c = icmp slt i32 %n, 101
 br i1 %c, label %loop, label %exit
exit:
 ret i32 0
}
'''
def run(*args):
 p=subprocess.run(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 if p.returncode: raise RuntimeError(str(args)+': '+p.stderr.decode())
 return p.stdout
def execute(path):
 exe=path.with_suffix('.exe');run(clang,'-O0',path,'-o',exe)
 return run(exe)
with tempfile.TemporaryDirectory() as tmp:
 d=pathlib.Path(tmp)
 variants={
 'chain':base,
 'reverse-second':base.replace('br i1 %c1, label %b, label %test2','br i1 %c1, label %test2, label %b'),
 'reverse':base.replace('br i1 %c0, label %a, label %test1','br i1 %c0, label %test1, label %a'),
 'guarded-div':base.replace('icmp slt i32 %x, 0','icmp eq i32 %x, 0').replace('%c1 = icmp slt i32 %x, 5','%quot = sdiv i32 100, %x\n  %c1 = icmp slt i32 %quot, 5').replace('%bv = mul i32 %x, 7','%bv = mul i32 %quot, 7'),
 'guarded-load':base.replace('%c0 = icmp slt i32 %x, 0','%ptr = alloca i32\n  store i32 %x, i32* %ptr\n  %c0 = icmp eq i32 %x, 0\n  %p = select i1 %c0, i32* null, i32* %ptr').replace('%c1 = icmp slt i32 %x, 5','%loaded = load i32, i32* %p\n  %c1 = icmp slt i32 %loaded, 5').replace('%bv = mul i32 %x, 7','%bv = mul i32 %loaded, 7'),
 }
 for label,ir in variants.items():
  before=d/(label+'.ll');after=d/(label+'-after.ll');before.write_text(ir+harness)
  old=before.read_bytes();catalog=json.loads(run(binary,before,'case'));assert before.read_bytes()==old
  assert len(catalog[0]['arms'])==4,(label,catalog)
  run(binary,before,'case',0,0,after)
  assert execute(before)==execute(after),label
  new=json.loads(run(binary,after,'case'))
  assert len(new[0]['arms'])==3,(label,new[0])
  assert new[0]['arms'][0]['kind']=='SESE',(label,new[0])
  assert new[0]['arms'][0]['merged_from'],label
  again=d/(label+'-again.ll');run(binary,after,'case',0,0,again)
  assert execute(before)==execute(again),label+' recursive'
  rebound=json.loads(run(binary,again,'case'))[0]
  assert len(rebound['arms'])==2,(label,rebound)
  assert len(rebound['arms'][0]['merged_from'])==3,(label,rebound)
  print(label,'execution equivalence OK')
 # Switch aliases must be one logical arm, with both edge alternatives retained.
 sw='''define i32 @case(i32 %x) {
e: switch i32 %x, label %c [i32 0, label %a i32 1, label %a i32 2, label %b]
a: br label %j
b: br label %j
c: br label %j
j: %v = phi i32 [1,%a], [2,%b], [3,%c]
ret i32 %v
}'''
 p=d/'switch.ll';p.write_text(sw);cat=json.loads(run(binary,p,'case'))
 assert len(cat[0]['arms'])==3
 assert sorted(len(a['predicate_alternatives']) for a in cat[0]['arms'])==[1,1,2]
 print('switch aliases OK')
 # Early return and side effects remain visible but are not fusion-eligible.
 for tag,src in {
  'early-return':base.replace('br label %join\nb:', 'ret i32 %av\nb:').replace('[%av,%a], ',''),
  'store':base.replace('%av = add i32 %x, 100','%mem = alloca i32\n  store volatile i32 %x, i32* %mem\n  %av = add i32 %x, 100'),
 }.items():
  p=d/(tag+'.ll');p.write_text(src);cat=json.loads(run(binary,p,'case'))
  assert any(a['kind']=='Unsupported' for a in cat[0]['arms']),tag
  dest=d/(tag+'-out.ll');proc=subprocess.run(list(map(str,[binary,p,'case',0,0,dest])),capture_output=True)
  assert proc.returncode!=0 and not dest.exists(),tag
 print('unsupported arms rejected without output OK')
 convergent=base.replace('%c1 = icmp slt i32 %x, 5','%lane = call i32 @foo(i32 %x)\n  %c1 = icmp slt i32 %lane, 5')+'\ndeclare i32 @foo(i32) readnone nounwind convergent\n'
 p=d/'convergent.ll';p.write_text(convergent);dest=d/'convergent-out.ll'
 proc=subprocess.run(list(map(str,[binary,p,'case',0,0,dest])),capture_output=True)
 assert proc.returncode!=0 and not dest.exists() and b'convergent' in proc.stderr
 print('convergent control-flow change rejected OK')
print('all decision-model checks passed')
