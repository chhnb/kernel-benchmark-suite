#!/usr/bin/env python3
import argparse,subprocess,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--parent',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();root=Path(__file__).resolve().parents[2];a.out.mkdir(parents=True,exist_ok=False)
original=a.parent.read_bytes();tool=root/'build/fusion-search/postopt-pair-profile'
for name,left,right in [('overlap',24,24),('swapped',37,24),('outside',0,37)]:
 r=subprocess.run([str(tool),str(a.parent),'evaluate','23',str(a.out/(name+'.ll')),str(left),str(right)],capture_output=True,text=True)
 assert r.returncode==2 and not (a.out/(name+'.ll')).exists(),(name,r.returncode,r.stderr)
cyclic=a.out/'cyclic.ll';cyclic.write_text(original.decode().replace('\n}\n','\nprofile.unreachable.cycle:\n  br label %profile.unreachable.cycle\n}\n',1))
r=subprocess.run([str(tool),str(cyclic),'evaluate','23',str(a.out/'cycle-output.ll'),'24','37'],capture_output=True,text=True)
assert r.returncode==2 and 'cyclic function unsupported' in r.stderr,r.stderr
assert a.parent.read_bytes()==original
print('PASS: overlapping, swapped, outside-scope and cyclic profiles rejected; parent unchanged')
