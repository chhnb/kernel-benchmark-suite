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
 'inverse-second-predicate':base.replace('%c1 = icmp slt', '%c1 = icmp sge').replace('br i1 %c1, label %b, label %test2', 'br i1 %c1, label %test2, label %b'),
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
  text=after.read_text()
  if label == "inverse-second-predicate":
   assert "%c1 =" not in text, "superseded comparison survived condition cleanup"
   assert "%c0 =" in text, "live dispatch selector was incorrectly deleted"
  assert "decision.was_left" not in text,label
  if label in ("guarded-load","guarded-div"):
   assert "decision.take = phi" in text,label
  else:
   assert "decision.take = phi" not in text,label
   assert "decision.gate:" not in text,label
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
 # Build the right group first. Its unsafe second test creates a multi-block
 # prefix; the old selector c1 escapes into the group and must be bridged
 # when the next normalization adds an entry that bypasses that prefix.
 src=base.replace('%c2 = icmp slt i32 %x, 12', '%quot = sdiv i32 100, %x\n  %c2 = icmp slt i32 %quot, 12')
 before=d/'prefix.ll';before.write_text(src+harness)
 right=d/'prefix-right.ll';run(binary,before,'case',0,1,right)
 merged=d/'prefix-merged.ll';run(binary,right,'case',0,0,merged)
 assert execute(before)==execute(right)==execute(merged)
 assert len(json.loads(run(binary,merged,'case'))[0]['arms'])==2
 assert 'decision.value = phi i1' in merged.read_text()
 print('multi-block prefix selector dominance and execution OK')
 # A reversed first predicate needs a live NOT outside its branch slice.
 # Rediscovery must still expand this condition-only prefix.
 src=variants['guarded-div'].replace('%c0 = icmp eq','%c0 = icmp ne').replace('br i1 %c0, label %a, label %test1','br i1 %c0, label %test1, label %a')
 before=d/'inverted-prefix.ll';before.write_text(src+harness)
 after=d/'inverted-prefix-after.ll';run(binary,before,'case',0,0,after)
 cat=json.loads(run(binary,after,'case'))[0]
 assert len(cat['arms'])==3 and len(cat['arms'][0]['merged_from'])==2
 assert execute(before)==execute(after)
 print('inverted short-circuit prefix identity OK')
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
