from pathlib import Path
import subprocess,json,sys
R=Path('/home/chh/kernel-benchmark-suite'); O=R/'experiments'/sys.argv[1];O.mkdir(exist_ok=False)
S=R/'build/llvm24-tti/fusion-search-llvm24'
def run(name,ir,greedy=False,extra=()):
 p=O/(name+'.ll');p.write_text(ir);d=O/name
 cmd=[str(S),'--ir',str(p),'--function','f','--out',str(O/(name+'-out.ll')),'--debug-dir',str(d),'--adjacent-only','1','--cleanup','postopt-fp','--scorer','legacy']
 cmd+=['--rounds','4','--trials','100'] if greedy else ['--catalog-only','1'];cmd+=list(extra)
 q=subprocess.run(cmd,capture_output=True,text=True);(O/(name+'.log')).write_text(q.stdout+q.stderr);assert q.returncode==0,(name,q.stderr[-2000:]);return d
prefix='target triple = "amdgcn-amd-amdhsa"\ndefine double @f(double %x) "target-cpu"="gfx906" {\n'
def mixed(reorder=False,invert=False):
 p='oge' if invert else 'olt'; succ='label %tail, label %A' if invert else 'label %A, label %tail'
 # Use unordered >= to invert ordered < exactly including NaN.
 if invert:p='uge'
 bs=[f'entry:\n %p=fcmp {p} double %x, 3.5\n br i1 %p, {succ}\n', 'A:\n %a=fdiv double %x, 3.0\n br label %join\n', 'tail:\n %q=fcmp ugt double %x, 5.0\n br i1 %q, label %C, label %B\n','B:\n %b=fdiv double %x, 4.0\n br label %join\n','C:\n %c=fdiv double %x, 6.0\n br label %join\n','join:\n %out=phi double [ %a, %A ], [ %b, %B ], [ %c, %C ]\n ret double %out\n']
 if reorder:bs=[bs[0]]+bs[:0:-1]
 return prefix+''.join(bs)+'}\n'
for n,r,i in [('mixed',False,False),('reordered',True,False),('inverted',False,True)]:
 d=run(n,mixed(r,i));st=json.loads((d/'logical-state-0.json').read_text());ordered=[x for x in st['decisions'] if x['status']=='ordered'];assert len(ordered)==1,st;g=ordered[0];assert [x['initial_block'] for x in g['leaves']]==['%A','%B','%C'];assert [x['includes_nan'] for x in g['leaves']]==[False,False,True];cat=json.loads((d/'catalog.json').read_text());pairs={(c['logical_left'],c['logical_right']) for c in cat['candidates']};assert pairs=={('D0.L0','D0.L1'),('D0.L1','D0.L2')},pairs
d=run('float32',mixed().replace('double','float'));assert json.loads((d/'catalog.json').read_text())['count']>0
# Equal/unequal produces two disconnected numeric intervals, no guessed ordering.
bad=mixed().replace('fcmp olt double %x, 3.5','fcmp oeq double %x, 3.5');d=run('noncontiguous',bad);assert json.loads((d/'catalog.json').read_text())['count']==0
# Different SSA values are not comparable merely because they have constants.
bad=mixed().replace('tail:\n','tail:\n %z=fadd double %x, 1.0\n').replace('fcmp ugt double %x','fcmp ugt double %z');d=run('mixed-ssa',bad);assert json.loads((d/'catalog.json').read_text())['count']==0
balanced=prefix+'''entry:
 %p=fcmp olt double %x, 2.0
 br i1 %p, label %lo, label %hi
lo:
 %q=fcmp olt double %x, 1.0
 br i1 %q, label %A, label %B
hi:
 %r=fcmp olt double %x, 3.0
 br i1 %r, label %C, label %D
A:
 %a=fdiv double %x, 3.0
 br label %join
B:
 %b=fdiv double %x, 4.0
 br label %join
C:
 %c=fdiv double %x, 5.0
 br label %join
D:
 %d=fdiv double %x, 6.0
 br label %join
join:
 %out=phi double [ %a, %A ], [ %b, %B ], [ %c, %C ], [ %d, %D ]
 ret double %out
}
'''
d=run('balanced',balanced,True)
states=[json.loads(p.read_text()) for p in sorted(d.glob('logical-state-*.json'))]
for st in states:
 for g in st['decisions']:
  if g['status']!='ordered':continue
  hist={h['id']:h for h in g['history']};covered=[]
  for a in g['active']:covered+=list(range(hist[a]['first'],hist[a]['last']+1))
  assert covered==list(range(len(g['leaves']))),(st['version'],covered)
assert len(states)==4,[(s['version'],s['decisions'][0]['active']) for s in states]
last=states[-1]['decisions'][0]; hist={h['id']:h for h in last['history']}; final=hist[last['active'][0]];assert '.G' in final['left'] and '.G' in final['right'],final
# Trials operate on cloned logical state: rejecting all leaves S0 untouched.
d=run('reject-all',balanced,True,['--threshold','100000'])
assert len(list(d.glob('logical-state-*.json')))==1
assert json.loads((d/'result.json').read_text())['commits']==0
print(json.dumps({'passed':['mixed_predicates','block_reorder','true_false_inversion','nan_routing','noncontiguous_reject','multiple_ssa_reject','active_partition'], 'balanced_commits':len(states)-1},indent=2))
