#!/usr/bin/env python3
"""Check postopt-fp with external PHI predecessors and both branch orientations.
Run under the project's CPU admission wrapper (like tests/postopt/run).
"""
import subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
clang='/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/clang'
fixture='''target triple = "x86_64-unknown-linux-gnu"
define i32 @choose(i1 %outside, i1 %c, i32 %x, i32 %y) {
entry:
 br i1 %outside, label %external, label %split
external:
 br label %exit
split:
 br i1 %c, label %calc, label %join
calc:
 %v = add i32 %x, 7
 br label %join
join:
 %p = phi i32 [ %v, %calc ], [ %y, %split ]
 br label %exit
exit:
 %q = phi i32 [ %x, %external ], [ %p, %join ]
 ret i32 %q
}
'''
with tempfile.TemporaryDirectory(prefix='postopt-cleanup-') as tmp:
 d=Path(tmp)
 for reverse in [False,True]:
  d=Path(tmp)/str(reverse);d.mkdir()
  ir=fixture
  if reverse:ir=ir.replace('label %calc, label %join','label %join, label %calc')
  src=d/'input.ll';src.write_text(ir);out=d/'output.ll';twice=d/'twice.ll'
  for inp,dest in [(src,out),(out,twice)]:
   subprocess.run([str(root/'build/fusion-search/fusion-search'),'--ir',str(inp),'--function','choose','--out',str(dest),'--control-only','1','--cleanup','postopt-fp'],check=True)
  normalized=lambda p:'\n'.join(p.read_text().splitlines()[1:])
  assert normalized(out)==normalized(twice),'cleanup not idempotent'
  driver=d/'driver.cpp';driver.write_text('extern "C" int choose(bool,bool,int,int);\nint main(){for(int x=-64;x<=64;++x)for(int y=-4;y<=4;++y)for(int a=0;a<2;++a)for(int c=0;c<2;++c){int expected=a?x:('+('!c' if reverse else 'c')+'?x+7:y);if(choose(a,c,x,y)!=expected)return 1;}return 0;}')
  for name,p in [('baseline',src),('cleaned',out)]:
   exe=d/name;subprocess.run([clang,'-O0',str(p),str(driver),'-o',str(exe)],check=True);subprocess.run([str(exe)],check=True)
print('PASS postopt-fp: 18576 native executions, external predecessor, both orientations, idempotence')
