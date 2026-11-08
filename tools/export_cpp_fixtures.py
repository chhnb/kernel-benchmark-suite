# One-time migration utility, not part of GPU execution.
from pathlib import Path
import json,struct,os,ast,hashlib
import numpy as np
S=Path('/home/chh/kernel-benchmark-suite')
def write(case,name,symbol,grid,block,buffers,args,extra=[]):
 p=S/'cases'/case/'fixtures-cpp'/name;p.mkdir(parents=True,exist_ok=True)
 def rel(x):return os.path.relpath(x,p)
 lines=['kernel '+symbol,'grid '+' '.join(map(str,grid)),'block '+' '.join(map(str,block))]
 for n,init,check,ref,atol,rtol in buffers:lines.append(f'buffer {n} {rel(init)} {check} {rel(ref) if ref else "-"} {atol} {rtol}')
 for kind,v in args:lines.append('arg '+kind+' '+(rel(v) if kind=='file' else v))
 (p/'input.txt').write_text('\n'.join(lines+extra)+'\n')
def ptr(n):return 'ptr',n
def scalar(fmt,x):return 'hex',struct.pack('<'+fmt,x).hex()
for case in ['sw2d','cholla-hlld','cudaflow-particles','srad','vllm-quant']:
 P=S/'cases'/case;m=json.loads((P/'case.json').read_text());symbol=m['runtime']['roles'][0]['symbol']
 if case=='sw2d':
  for fx in json.loads((P/'input/fixed-domain-v1/fixtures.json').read_text()):
   d=P/fx['path'];v=json.loads((d/'meta.json').read_text());buf=[(k,d/(k+'.bin'),'f64' if k in ['um','vn'] else 'readonly',d/('reference_'+k+'.bin') if k in ['um','vn'] else None,1e-10,1e-10) for k in v['arrays']]
   args=[ptr('th'),scalar('d',v['gg']),scalar('d',v['rn'])]+[ptr(k) for k in ['inf','h','infx','infy','baseo','um','hm','uu1','umo','vv1','vva','vn','hn','vno','uua','ho']]+[scalar('i',v[k]) for k in ['N','cols','rows']]+[scalar('d',v[k]) for k in ['dx','dy','dt2']]
   write(case,fx['name'],symbol,[(v['N']+1023)//1024,1,1],[1024,1,1],buf,args)
 elif case=='cholla-hlld':
  d=P/'fixture';a=(d/'ot-first-x.meta.txt').read_text().split();n=int(a[0]);b=int(a[5]);out=P/'fixtures-cpp/OT';out.mkdir(parents=True,exist_ok=True);(out/'flux-init.bin').write_bytes(b'\xff'*(7*n*8))
  buf=[(k,d/f'ot-first-x.{k}.bin','readonly',None,0,0) for k in ['left','right','magnetic']]+[('flux',out/'flux-init.bin','f64',d/'ot-first-x.flux.bin',1e-12,1e-12)]
  write(case,'OT',symbol,[(n+b-1)//b,1,1],[b,1,1],buf,[ptr(k) for k in ['left','right','magnetic','flux']]+[scalar('i',n),scalar('d',float(a[1])),scalar('i',int(a[2])),scalar('i',8)])
 elif case=='cudaflow-particles':
  names=['w','x','y','z','px','py','pz','pu','pv','pw','pT','pd','pic','pjc','pkc','alive'];outputs=names[4:11]+names[12:]
  for fx in json.loads((P/'fixtures.json').read_text()):
   d=P/fx['path'];v=json.loads((d/'meta.json').read_text());buf=[]
   for k in names+['refl']:
    check='geometry' if k in ['pic','pjc','pkc'] else 'exact' if k=='alive' else 'f32' if k in outputs else 'readonly';ref=d/'reference'/(k+'.bin') if check in ['exact','f32'] else None;buf.append((k,d/(k+'.bin'),check,ref,2e-5,2e-4))
   args=[('file',d/'blk.bin')]+[ptr(k) for k in names]+[scalar('i',v['np'])]+[scalar('f',v[k]) for k in ['rhoP','muinf','Sc','dt']]+[scalar('i',v['sub']),scalar('i',v['heat']),ptr('refl'),scalar('i',v['nRefl']),scalar('i',v['wallModel'])]+[scalar('f',v[k]) for k in ['en','et','vcrit']]+[scalar('Q',0),scalar('f',v['npp']),scalar('i',0)]
   write(case,fx['name'],symbol,[(v['np']+127)//128,1,1],[128,1,1],buf,args,['geometry '+' '.join(map(str,v['dims']+v['node_dims']))])
 elif case=='srad':
  tree=ast.parse((S/'archive/python-runtime'/case/'run.py').read_text());ns={'np':np};exec(compile(ast.Module(body=[x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name in ['fixture','oracle']],type_ignores=[]),'oracle','exec'),ns)
  for n in [256,1024]:
   d=P/'fixtures-cpp'/str(n);d.mkdir(parents=True,exist_ok=True);j,q=ns['fixture'](n,'random');refs=ns['oracle'](j,q);j.tofile(d/'J.bin');(d/'poison.bin').write_bytes(b'\xff'*j.nbytes);buf=[('J',d/'J.bin','readonly',None,0,0)]
   for k,v in refs.items():v.tofile(d/(k+'-ref.bin'));buf.append((k,d/'poison.bin','f32',d/(k+'-ref.bin'),3e-5,3e-5))
   write(case,str(n),symbol,[n//16,n//16,1],[16,16,1],buf,[ptr(k) for k in ['E','W','N','S','J','C']]+[scalar('i',n),scalar('i',n),scalar('f',q)])
 else:
  # Reuse the precise established CPU oracle; freeze identical historical inputs.
  t=(S/'archive/python-runtime'/case/'harness/run_hip.py').read_text();start=t.index('levels=np.array');end=t.index('\ndef dataset(');ns={'np':np};exec(t[start:end],ns);rng=np.random.default_rng(20261103)
  prior=json.loads((S/'results/vllm-hip-final-input-validation-v1/output/expected.json').read_text())
  for nt in [1024,4096,16384,32768,131072]:
   d=P/'fixtures-cpp'/str(nt);d.mkdir(parents=True,exist_ok=True);heads=8;dim=128;stride=1024;page=16;capacity=((nt+15)//16+1)*16
   x=rng.standard_normal((2,nt,stride)).astype('f4');x[:,0,:]=0;x[:,1,:16]=np.array([.25,.75,1.25,1.75,2.5,3.5,5,6,-.25,-.75,-1.25,-1.75,-2.5,-3.5,-5,-6],dtype='f4');u=x.view('u4');inp=((u+np.uint32(0x7fff)+((u>>16)&1))>>16).astype('u2');del x,u;slots=rng.permutation(nt).astype('i8');slots[::17]=-1
   inp[0].tofile(d/'key.bin');inp[1].tofile(d/'value.bin');slots.tofile(d/'slots.bin');buf=[(k,d/(k+'.bin'),'readonly',None,0,0) for k in ['key','value','slots']]
   for which,scale,swizzle,names in [(0,1.,False,['kd','ks']),(1,1.25,True,['vd','vs'])]:
    shape=(capacity//16,heads,16);data=np.full((*shape,dim//2),165,'u1');sc=np.full((*shape,dim//16),165,'u1')
    for begin in range(0,nt,1024):ns['reference'](inp[which,begin:begin+1024],slots[begin:begin+1024],heads,dim,page,stride,scale,swizzle,(data,sc))
    for k,arr,index in [(names[0],data,which),(names[1],sc,which+2)]:
     assert hashlib.sha256(arr).hexdigest()==prior[str(nt)][index];arr.tofile(d/(k+'-ref.bin'));np.full(arr.size,165,'u1').tofile(d/(k+'-init.bin'));buf.append((k,d/(k+'-init.bin'),'exact',d/(k+'-ref.bin'),0,0))
    del data,sc
   write(case,str(nt),symbol,[nt,1,1],[64,1,1],buf,[ptr(k) for k in ['key','value','slots','kd','vd','ks','vs']]+[scalar('i',heads),scalar('i',dim),scalar('i',page),scalar('i',stride),scalar('f',1),scalar('f',1.25)])
   print('frozen quant',nt,flush=True)
 if case in ['srad','cudaflow-particles']:
  prefix,version=('srad',2) if case=='srad' else ('cudaflow',1)
  for d in (P/'fixtures-cpp').iterdir():
   prior=S/f'results/{prefix}-final-input-validation-v{version}/output'
   oldref=prior/f'ref-{d.name}-random.npz' if case=='srad' else prior/d.name/'NVCC-r0.npz'
   z=np.load(oldref);lines=[]
   for k in z.files:
    z[k].tofile(d/(k+'-baseline.bin'));lines.append('exactref '+k+' '+k+'-baseline.bin')
   f=d/'input.txt';f.write_text(f.read_text()+'\n'.join(lines)+'\n')
 print(case,'exported',flush=True)
