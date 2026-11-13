"""Check actual emitted plans, CPU semantics, monotone cost and replay stability."""
from pathlib import Path
import subprocess,tempfile,os,json,re,sys
r=Path(__file__).resolve().parents[2];exe=r/'build/decision-fuse/decision-fuse'
select='''target triple = "amdgcn-amd-amdhsa"
define float @case(i1 %c, i1 %a, i1 %b, float %x, float %y, float %z, float %w) #0 {
entry: br i1 %c, label %left, label %right
left:
 %l = select i1 %a, float %x, float %y
 %lv = call float @llvm.copysign.f32(float %l, float -1.0)
 br label %join
right:
 %r = select i1 %b, float %z, float %w
 %rv = call float @llvm.copysign.f32(float %r, float -1.0)
 br label %join
join:
 %v = phi float [%lv,%left], [%rv,%right]
 ret float %v
}
declare float @llvm.copysign.f32(float,float) nounwind readnone speculatable
attributes #0 = { "target-cpu"="gfx906" }
'''
div='''target triple = "amdgcn-amd-amdhsa"
define float @case(i1 %c, float %x, float %y, float %z) #0 {
entry: br i1 %c, label %left, label %right
left: %l = fdiv float %x, %y
 br label %join
right: %r = fdiv float %x, %z
 br label %join
join: %v = phi float [%l,%left], [%r,%right]
 ret float %v
}
attributes #0 = { "target-cpu"="gfx906" }
'''
def run(src,out,mode):
 env=dict(os.environ,DECISION_SPECULATION=mode,DECISION_GAP_SEARCH='1',DECISION_CFG_CLEANUP='structural')
 env.pop('DECISION_GAP_KEEP_TRIALS',None)
 p=subprocess.run([str(exe),str(src),'case','0','0',str(out)],env=env,capture_output=True)
 assert p.returncode==0,p.stderr.decode()
 if sys.platform.startswith('linux'):
  assert {path.name for path in out.iterdir()}=={'meld-raw.ll','fused.ll','trial.json','decisions.json','gap-search.json'}
 s=json.loads((out/'gap-search.json').read_text());cost=s['initial_cost']
 for a in s['accepted']:assert a['before']==cost and a['after']<cost;cost=a['after']
 assert cost==s['final_cost'];return s

def execute(ir,path):
 text=ir.read_text().replace('"target-cpu"="gfx906"','').replace('target triple = "amdgcn-amd-amdhsa"','target triple = "x86_64-unknown-linux-gnu"')
 text=re.sub(r'^attributes #[0-9]+ = .*$', '', text, flags=re.M);text=re.sub(r' #[0-9]+', '', text)
 ll=path.with_suffix('.ll');ll.write_text(text)
 harness=path.with_suffix('.c');harness.write_text(r'''#include <stdio.h>
#include <stdint.h>
#include <string.h>
extern float case_fn(_Bool,_Bool,_Bool,float,float,float,float) __asm__("case");
int main(){uint32_t bits[]={0,0x80000000,0x3f800000,0xbf800000,0x7f800000,0xff800000,0x7fc00001,0xffc01234,1,0x80000001};float v[10];memcpy(v,bits,sizeof(v));
for(int c=0;c<2;++c)for(int a=0;a<2;++a)for(int b=0;b<2;++b)for(int i=0;i<10;++i){float x=case_fn(c,a,b,v[i],v[(i+1)%10],v[(i+2)%10],v[(i+3)%10]);uint32_t n;memcpy(&n,&x,4);printf("%u\n",n);}return 0;}
''')
 if 'float* %p' in text:
  h=harness.read_text().replace('_Bool,_Bool,_Bool,float,float,float,float','_Bool,float*,float')
  h=h.replace('case_fn(c,a,b,v[i],v[(i+1)%10],v[(i+2)%10],v[(i+3)%10])','case_fn(c,c?&v[i]:0,v[(i+1)%10])');harness.write_text(h)
 p=subprocess.run([os.environ.get('CLANG','/home/chh/darm-artifacts-repro/build/bin/clang'),'-O0',str(ll),str(harness),'-o',str(path)],capture_output=True)
 assert p.returncode==0,p.stderr.decode()
 return subprocess.check_output([str(path)])

with tempfile.TemporaryDirectory() as tmp:
 d=Path(tmp);src=d/'select.ll';src.write_text(select)
 for mode in ['none','cost']:
  s=run(src,d/mode,mode);text=(d/mode/'meld-raw.ll').read_text()
  print(mode,'selects',len(re.findall(r'= select ',text)),'cost',s['initial_cost'],'->',s['final_cost'],'trials',s['trials'],flush=True)
 assert execute(src,d/'original-exe')==execute(d/'cost/fused.ll',d/'cost-exe')==execute(d/'none/fused.ll',d/'none-exe')
 print('80 complete CPU outputs equal, including NaN payloads, infinities and signed zeros')
 a=run(src,d/'repeat','cost');assert (d/'cost/fused.ll').read_bytes()==(d/'repeat/fused.ll').read_bytes()
 first=json.loads((d/'cost/gap-search.json').read_text());assert [x['state'] for x in first['accepted']]==[x['state'] for x in a['accepted']]
 if sys.platform.startswith('linux'):
  expected=[row['root'] for row in json.loads((d/'cost/decisions.json').read_text())]
  env=dict(os.environ,DECISION_SPECULATION='cost',DECISION_GAP_SEARCH='1',
           DECISION_CFG_CLEANUP='structural',DECISION_GAP_ROOTS_STDOUT='1')
  env.pop('DECISION_GAP_KEEP_TRIALS',None)
  for keep in ['0','1']:
   dest=d/('roots-'+keep)
   result=subprocess.run([exe,src,'case','0','0',dest],
                         env=dict(env,DECISION_GAP_KEEP_CATALOG=keep),capture_output=True,check=True)
   assert json.loads(result.stdout)==expected
   assert (dest/'decisions.json').exists()==(keep=='1')
   assert (dest/'fused.ll').read_bytes()==(d/'cost/fused.ll').read_bytes()
  print('stdout roots and debug catalog match full catalog; final IR identical',flush=True)
 chain=select.replace('i1 %b, float %x','i1 %b, i1 %d, i1 %e, float %x').replace('float %z, float %w) #0','float %z, float %w, float %u, float %other) #0')
 chain=chain.replace(' %lv = call',' %l1 = select i1 %d, float %l, float %u\n %lv = call').replace('float %l, float -1.0','float %l1, float -1.0')
 chain=chain.replace(' %rv = call',' %r1 = select i1 %e, float %r, float %other\n %rv = call').replace('float %r, float -1.0','float %r1, float -1.0')
 chain_src=d/'chain.ll';chain_src.write_text(chain);cs=run(chain_src,d/'chain','cost')
 assert len(cs['accepted'])>=2,cs
 print('dependent matched users rescored; accepted',len(cs['accepted']),'strict improvements',flush=True)
 src=d/'div.ll';src.write_text(div);s=run(src,d/'div','cost');text=(d/'div/meld-raw.ll').read_text();assert len(re.findall(r'= fdiv ',text))==1
 load='''target triple = "amdgcn-amd-amdhsa"
define float @case(i1 %c,float* %p,float %x) #0 {
e: br i1 %c,label %l,label %r
l: %a=load float,float* %p
 %av=call float @llvm.copysign.f32(float %a,float -1.0)
 br label %j
r: %b=fadd float %x,1.0
 %bv=call float @llvm.copysign.f32(float %b,float -1.0)
 br label %j
j: %v=phi float [%av,%l],[%bv,%r]
 ret float %v
}
declare float @llvm.copysign.f32(float,float) nounwind readnone speculatable
attributes #0 = { "target-cpu"="gfx906" }
'''
 src=d/'load.ll';src.write_text(load);run(src,d/'load','cost')
 assert execute(src,d/'load-before')==execute(d/'load/fused.ll',d/'load-after')
 print('guarded load preserves null-pointer untaken-side behavior')
 print('expensive fdiv match retained; deterministic IR and strict cost descent verified')
