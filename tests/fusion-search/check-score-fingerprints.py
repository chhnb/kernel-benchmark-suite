#!/usr/bin/env python3
"""Falsification tests for the offline scope audit (not a production proof)."""
import importlib.util,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('scope_audit',Path(__file__).with_name('audit-score-reuse.py'))
audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)
scalar='''define i32 @f(i1 %p, i32 %x) {
entry:
  %a = OP i32 %x, CONSTANT
  %z = add i32 %a, 3
  br label %split
split:
  br i1 %p, label %left, label %right
left:
  %l = add i32 %z, 1
  br label %join
right:
  %r = add i32 %z, 2
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %v
}
'''
memory='''@A = global i32 0
@B = global i32 0
define i32 @f(i1 %p, i32 %x) {
entry:
  store i32 %x, i32* @DEST
  br label %split
split:
  br i1 %p, label %left, label %right
left:
  %l = load i32, i32* @A
  br label %join
right:
  %r = load i32, i32* @B
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  ret i32 %v
}
'''
with tempfile.TemporaryDirectory() as temp:
 def parse(name,text):
  p=Path(temp)/(name+'.ll');p.write_text(text);return audit.parse(p,'f')
 def key(p,memory=False,data=False):
  return audit.fingerprint(p,[1,2,3],2,audit.memory_ancestors(p) if memory else None,data)[0]
 a=parse('scalar-a',scalar.replace('OP','and').replace('CONSTANT','0'))
 b=parse('scalar-b',scalar.replace('OP','or').replace('CONSTANT','1'))
 assert key(a)==key(b), 'example must evade a one-level data fingerprint'
 assert key(a,data=True)!=key(b,data=True), 'transitive definition mutation must invalidate'
 a=parse('memory-a',memory.replace('DEST','A'));b=parse('memory-b',memory.replace('DEST','B'))
 assert key(a)==key(b), 'example must evade a local block fingerprint'
 assert key(a,memory=True)!=key(b,memory=True), 'incoming memory mutation must invalidate'
print('PASS offline scope tests: upstream stores and transitive scalar definitions invalidate extended fingerprints')
