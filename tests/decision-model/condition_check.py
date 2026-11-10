from pathlib import Path
import subprocess,tempfile,struct,json
r=Path(__file__).resolve().parents[2];d=Path(tempfile.mkdtemp(prefix='interval-test-',dir=r/'build/decision-fuse'))
ll=[];decl=[];calls=[];n=0
for ty,preds,bounds in [('i8','eq ne ugt uge ult ule sgt sge slt sle'.split(),[('-128','127'),('0','-1'),('-1','1')]),('float','false oeq ogt oge olt ole one ord ueq ugt uge ult ule une uno true'.split(),[('-1.0','1.0'),('0.0','-0.0'),('0x7FF0000000000000','0xFFF0000000000000'),('0x7FF8000000000000','1.0')])]:
 for lo,hi in bounds:
  for p in preds:
   for q in preds:
    for op in ['or','and','xor','select','nested']:
     name='t'+str(n);n+=1;cmp='icmp' if ty=='i8' else 'fcmp'
     expr=f'{op} i1 %a, %b' if op not in ('select','nested') else ('select i1 %a, i1 true, i1 %b' if op=='select' else 'select i1 %a, i1 %b, i1 %inv')
     ac=f'{ty} %x, {lo}' if n%2 else f'{ty} {lo}, %x';bc=f'{ty} %x, {hi}' if n%3 else f'{ty} {hi}, %x'
     ll.append(f'define i1 @{name}({ty} %x) {{\n %a = {cmp} {p} {ac}\n %b = {cmp} {q} {bc}\n %inv = xor i1 %b, true\n %v = {expr}\n ret i1 %v\n}}')
     cty='signed char' if ty=='i8' else 'float';decl.append(f'extern _Bool {name}({cty});');calls.append(f'for(int i=0;i<{256 if ty=="i8" else 15};++i) putchar(48+{name}({"(signed char)i" if ty=="i8" else "v[i]"}));')
(d/'before.ll').write_text('\n'.join(ll))
bits=[0,0x80000000,1,0x80000001,0x3f7fffff,0x3f800000,0x3f800001,0xbf7fffff,0xbf800000,0xbf800001,0x7f800000,0xff800000,0x7fc00000,0xffc00000,0x7f800001]
(d/'main.c').write_text('#include <stdio.h>\n#include <string.h>\n'+ '\n'.join(decl)+'\nint main(){unsigned bits[]={'+','.join(map(str,bits))+'};float v[15];memcpy(v,bits,sizeof(v));'+''.join(calls)+'return 0;}')
with (d/'after.ll').open('w') as f:subprocess.run([r/'build/decision-fuse/condition-check',d/'before.ll'],stdout=f,check=True)
clang='/home/chh/darm-artifacts-repro/build/bin/clang';outputs=[]
for variant in ['before','after']:
 subprocess.run([clang,'-O0',d/(variant+'.ll'),d/'main.c','-o',d/variant],check=True,stderr=subprocess.DEVNULL);outputs.append(subprocess.check_output([d/variant]))
assert outputs[0]==outputs[1]
print(json.dumps({'functions':n,'evaluations':len(outputs[0]),'equal':True,'evidence':str(d)}))
