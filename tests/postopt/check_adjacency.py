from pathlib import Path
import json, subprocess
R=Path('/home/chh/kernel-benchmark-suite');O=R/'experiments/adjacent-v1-unit-tests-v2';O.mkdir(exist_ok=False)
S=R/'build/llvm24-tti/fusion-search-llvm24'
def check(name,arms,reorder=False,flip=False):
 blocks=[]
 for i,a in enumerate(arms[:-1]):
  cond='entry' if i==0 else 'cond'+str(i)
  dest='cond'+str(i+1) if i+1<len(arms)-1 else arms[-1]
  succ=(dest,a) if flip else (a,dest)
  blocks.append((cond,f'{cond}:\n %p{i}=fcmp olt double %x, {i+1}.0\n br i1 %p{i}, label %{succ[0]}, label %{succ[1]}\n'))
  blocks.append((a,f'{a}:\n %v{a}=fdiv double %x, {i+2}.0\n br label %join\n'))
 a=arms[-1];blocks.append((a,f'{a}:\n %v{a}=fdiv double %x, 9.0\n br label %join\n'))
 blocks.append(('join','join:\n %out=phi double '+', '.join(f'[ %v{a}, %{a} ]' for a in arms)+'\n ret double %out\n'))
 if reorder:blocks=[blocks[0]]+list(reversed(blocks[1:]))
 p=O/(name+'.ll');p.write_text('target triple = "amdgcn-amd-amdhsa"\ndefine double @f(double %x) "target-cpu"="gfx906" {\n'+''.join(b for _,b in blocks)+'}\n')
 d=O/(name+'-debug');res=subprocess.run([str(S),'--ir',str(p),'--function','f','--out',str(O/(name+'-out.ll')),'--catalog-only','1','--adjacent-only','1','--debug-dir',str(d)],capture_output=True,text=True)
 assert res.returncode==0,res.stderr
 cat=json.loads((d/'catalog.json').read_text());pairs=set()
 for c in cat['candidates']:
  if c['left'].startswith('B') and c['right'].startswith('B'):
   pairs.add(frozenset((blocks[int(c['left'][1:])][0],blocks[int(c['right'][1:])][0])))
 expected={frozenset((a,b)) for a,b in zip(arms,arms[1:])}
 assert pairs==expected,(name,pairs,expected)
 return [sorted(p) for p in pairs]
results={}
for name,arms,order,flip in [('chain',['A','B','C','D'],False,False),('reordered',['A','B','C','D'],True,False),('flipped',['A','B','C','D'],False,True),('merged',['AB','C','D'],False,False)]:results[name]=check(name,arms,order,flip)
(O/'summary.json').write_text(json.dumps(results,indent=2));print('PASS neighboring arms only, block-layout invariance, branch polarity, merged group neighbors')
