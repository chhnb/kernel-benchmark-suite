#!/usr/bin/env python3
import argparse,json,subprocess,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
root=Path(__file__).resolve().parents[2];tool=root/'build/fusion-search/postopt-conditions'
def ir(after=False,calc='add i32 %x, 1',guard='select i1 %a, i1 true, i1 %b',prefix=''):
 start='define void @k(i32 %x, i32 %y, i32* %p) {\nentry:\n'+prefix+'  %v = '+calc+'\n  %a = icmp sgt i32 %v, 0\n  %b = icmp sgt i32 %y, 0\n'
 if after:return start+'  %u = '+guard+'\n  br i1 %u, label %merged, label %exit\nmerged:\n  br label %exit\nexit:\n  ret void\n}\n'
 return start+'  br i1 %a, label %left, label %route\nroute:\n  br i1 %b, label %right, label %exit\nleft:\n  br label %exit\nright:\n  br label %exit\nexit:\n  ret void\n}\n'
cases=[('union',ir(),ir(True),True),('commuted_union',ir(),ir(True,guard='or i1 %b, %a'),True),('intersection',ir(),ir(True,guard='and i1 %a, %b'),False),('xor',ir(),ir(True,guard='xor i1 %a, %b'),False),('changed_constant',ir(),ir(True,calc='add i32 %x, 2'),False),('changed_flags',ir(calc='add nsw i32 %x, 1'),ir(True),False),('initial_load',ir(calc='load i32, i32* %p'),ir(True,calc='load i32, i32* %p'),True),('prior_store',ir(calc='load i32, i32* %p'),ir(True,calc='load i32, i32* %p',prefix='  store i32 %x, i32* %p\n'),False),('volatile_load',ir(calc='load volatile i32, i32* %p'),ir(True,calc='load volatile i32, i32* %p'),False),('freeze',ir(calc='freeze i32 %x'),ir(True,calc='freeze i32 %x'),False),('cyclic',ir().replace('label %right, label %exit','label %route, label %right'),ir(True),'cyclic_cfg_unsupported'),('undefined_boolean',ir(),ir(True,guard='select i1 undef, i1 true, i1 %b'),'undefined_boolean_unsupported')]
results=[]
for name,before,after,expected in cases:
 d=a.out/name;d.mkdir();(d/'before.ll').write_text(before);(d/'after.ll').write_text(after);cmd=[str(tool),str(d/'before.ll'),str(d/'after.ll'),'k','left','right','merged']
 r=subprocess.run(cmd,capture_output=True,text=True);(d/'stdout.json').write_text(r.stdout);(d/'stderr.txt').write_text(r.stderr)
 if type(expected) is bool:
  assert r.returncode==0,(name,r.stderr);data=json.loads(r.stdout);assert data['union_proven']==expected,(name,data['union_proven'])
  if name=='union':
   assert subprocess.check_output(cmd,text=True)==r.stdout,'process nondeterminism'
   parent=json.loads(subprocess.check_output(cmd+[str(d/'before.ll')],text=True))
   assert parent['parent_ir_sha1']==hashlib.sha1((d/'before.ll').read_bytes()).hexdigest()
   assert parent['parent_blocks']['B2']==parent['before']['%left']
   assert parent['parent_blocks']['B3']==parent['before']['%right']
 else:assert r.returncode==3 and expected in r.stderr,(name,r.returncode,r.stderr)
 results.append(dict(case=name,expected=expected,passed=True))
(a.out/'verification.json').write_text(json.dumps(dict(tool_sha256=hashlib.sha256(tool.read_bytes()).hexdigest(),cases=results),indent=2))
print('PASS 12 predicate-equivalence, side-effect, poison-flag and unsupported-CFG checks')
