from pathlib import Path
import json,subprocess,re
S=Path(__file__).resolve().parents[2];D=S/'tests/pair-trial/runs-v1';D.mkdir();tool=S/'build/pair-trial/pair-trial';inv=S/'build/region-inventory/region-inventory';clang='/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/clang'
sources={
'blocks':"""define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
 %c = icmp ne i32 %side, 0
 br i1 %c, label %left, label %right
left:
 %a = add i32 %x, 7
 br label %join
right:
 %b = mul i32 %x, 3
 br label %join
join:
 %v = phi i32 [%a, %left], [%b, %right]
 ret i32 %v
}
""",
'regions':"""define i32 @choose(i32 %x, i32 %side, i32 %inner) {
entry:
 %c = icmp ne i32 %side, 0
 %d = icmp ne i32 %inner, 0
 br i1 %c, label %left, label %right
left:
 br i1 %d, label %l0, label %l1
l0:
 %a = add i32 %x, 7
 br label %lj
l1:
 %b = mul i32 %x, 3
 br label %lj
lj:
 %lv = phi i32 [%a, %l0], [%b, %l1]
 br label %join
right:
 br i1 %d, label %r0, label %r1
r0:
 %u = sub i32 %x, 5
 br label %rj
r1:
 %v = mul i32 %x, 2
 br label %rj
rj:
 %rv = phi i32 [%u, %r0], [%v, %r1]
 br label %join
join:
 %z = phi i32 [%lv, %lj], [%rv, %rj]
 ret i32 %z
}
"""}
records=[]
for kind,source in sources.items():
 d=D/kind;d.mkdir();ir=d/'input.ll';ir.write_text(source);facts=json.loads(subprocess.check_output([str(inv),str(ir),'choose'],text=True))['functions'][0];bs={b['name']:b['id'] for b in facts['blocks']}
 if kind=='blocks':left,right=bs['%left'],bs['%right']
 else:
  left=next(r['id'] for r in facts['regions'] if r['entry']==bs['%left']);right=next(r['id'] for r in facts['regions'] if r['entry']==bs['%right'])
 req={'function':'choose','split':bs['%entry'],'left':left,'right':right};(d/'request.json').write_text(json.dumps(req));r=subprocess.run([str(tool),str(ir),str(d/'request.json'),str(d)],capture_output=True,text=True);(d/'engine.stderr').write_text(r.stderr);assert r.returncode==0,(kind,r.stderr[-2500:]);assert json.loads((d/'engine-result.json').read_text())['engine_calls']==1
 for stage,raw in [('before',source),('after',(d/'after-raw.ll').read_text())]:
  f=d/(stage+'.ll');f.write_text(raw.replace('@choose(', '@'+stage+'('));subprocess.run([clang,'-O2','-c',str(f),'-o',str(d/(stage+'.o'))],check=True,capture_output=True)
 (d/'harness.cpp').write_text('extern "C" int before(int,int,int); extern "C" int after(int,int,int); int main(){for(int x=-100;x<=100;x++)for(int s=0;s<2;s++)for(int t=0;t<2;t++)if(before(x,s,t)!=after(x,s,t))return 1;return 0;}')
 subprocess.run(['g++',str(d/'harness.cpp'),str(d/'before.o'),str(d/'after.o'),'-o',str(d/'check')],check=True);subprocess.run([str(d/'check')],check=True);records.append({'kind':kind,'passed':True,'comparisons':804})
 bad=d/'overlap';bad.mkdir();req['right']=req['left'];(bad/'request.json').write_text(json.dumps(req));r=subprocess.run([str(tool),str(ir),str(bad/'request.json'),str(bad)],capture_output=True,text=True);assert r.returncode==4 and not (bad/'after-raw.ll').exists();assert json.loads((bad/'engine-result.json').read_text())['reason']=='overlapping_pair'
(D/'review.json').write_text(json.dumps({'passed':True,'records':records,'negative_overlap_rejected':True},indent=2));print('PASS basic-block and region pairs, 1608 CPU differential comparisons; overlapping requests rejected')
