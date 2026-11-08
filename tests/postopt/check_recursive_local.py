from pathlib import Path
import subprocess,json,ctypes,struct,random,re,sys
R=Path('/home/chh/kernel-benchmark-suite'); O=R/'experiments'/sys.argv[1];O.mkdir(exist_ok=False)
S=R/'build/llvm24-tti/fusion-search-llvm24';CC='/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/clang'
def cmd(args):
 p=subprocess.run(list(map(str,args)),capture_output=True,text=True);assert p.returncode==0,(args,p.stderr[-3000:]);return p
threshold=[.25,.75,1.25,1.75,2.5,3.5,5.];mag=[0,.5,1,1.5,2,3,4,6]
s='target triple = "x86_64-unknown-linux-gnu"\ndeclare float @llvm.fabs.f32(float)\ndeclare float @llvm.copysign.f32(float,float)\ndefine i32 @f(i32 %bits) {\n'
for i,t in enumerate(threshold):
 label='entry' if i==0 else 'check'+str(i)
 s+=label+':\n'
 if i==0:s+=' %input=bitcast i32 %bits to float\n %x=call float @llvm.fabs.f32(float %input)\n'
 p='ugt' if i%2==0 else 'olt';nxt='check'+str(i+1) if i<6 else 'L7';a,b=(nxt,'L'+str(i)) if p=='ugt' else ('L'+str(i),nxt)
 s+=f' %p{i}=fcmp {p} float %x, {t}\n br i1 %p{i}, label %{a}, label %{b}\n'
for i,m in enumerate(mag):s+=f'L{i}:\n %v{i}=call float @llvm.copysign.f32(float {float(m)}, float %input)\n br label %join\n'
s+='join:\n %result=phi float '+', '.join(f'[ %v{i}, %L{i} ]' for i in range(8))+'\n %out=bitcast float %result to i32\n ret i32 %out\n}\n'
p=O/'input.ll';p.write_text(s)
def catalog(inp,name):
 d=O/name;cmd([S,'--ir',inp,'--function','f','--out',O/(name+'.ll'),'--catalog-only','1','--adjacent-only','1','--cleanup','none','--debug-dir',d]);return json.loads((d/'catalog.json').read_text())
# Exact output-bit comparison including thresholds, neighbors, +/-0, +/-inf,
# quiet/signaling NaN payloads and deterministic random float bit patterns.
values={0,0x80000000,0x7f800000,0xff800000,0x7fc00001,0xffc01234,0x7f800001,0xff800001}
for x in threshold:
 b=struct.unpack('I',struct.pack('f',x))[0]
 for sign in [0,0x80000000]:
  values.update((b+delta)|sign for delta in [-1,0,1])
rng=random.Random(452);values.update(rng.getrandbits(32) for _ in range(10000))

DR=R/'build/llvm24-tti/recursive-local-union'
variants={'copysign':s}
# Reuse the same CFG with arithmetic roots, proving recursion is not gated on
# one intrinsic or constant-only operands.
variants['fmul']=re.sub(r'call float @llvm.copysign.f32\(float ([0-9.]+), float %input\)',r'fmul float \1, %input',s)
variants['affine']=re.sub(r'%v(\d+)=call float @llvm.copysign.f32\(float ([0-9.]+), float %input\)',r'%product\1=fmul float \2, %input\n %v\1=fadd float %product\1, 1.0',s)
summary=[]
for kind,source in variants.items():
 inp=O/(kind+'.ll');inp.write_text(source)
 outputs=[]
 for strategy in ['left','right','balanced']:
  d=O/(kind+'-'+strategy)
  cmd([DR,inp,'f','D0',d,strategy,'legacy'])
  result=json.loads((d/'summary.json').read_text());assert result['commits']==7,(kind,strategy,result)
  st=json.loads((d/'logical-state-7.json').read_text());g=st['decisions'][0];assert len(g['active'])==1
  history={h['id']:h for h in g['history']};last=history[g['active'][0]];assert (last['first'],last['last'])==(0,7)
  final=d/'final.ll';text=final.read_text()
  if kind=='copysign':assert text.count('call float @llvm.copysign.f32')==1
  outputs.append((strategy,final));summary.append({'kind':kind,'strategy':strategy,'commits':7})
 for level in [0,3]:
  so=O/(kind+'-before'+str(level)+'.so');cmd([CC,'-shared','-fPIC','-O'+str(level),inp,'-o',so]);base=ctypes.CDLL(str(so));bf=base.f;bf.argtypes=[ctypes.c_uint32];bf.restype=ctypes.c_uint32
  for strategy,ir in outputs:
   so=O/(kind+'-'+strategy+str(level)+'.so');cmd([CC,'-shared','-fPIC','-O'+str(level),ir,'-o',so]);lib=ctypes.CDLL(str(so));f=lib.f;f.argtypes=[ctypes.c_uint32];f.restype=ctypes.c_uint32
   for bits in values:assert bf(bits)==f(bits),(kind,strategy,level,hex(bits),hex(bf(bits)),hex(f(bits)))
(O/'summary.json').write_text(json.dumps({'runs':summary,'inputs_per_run':len(values),'optimization_levels':[0,3]},indent=2));print((O/'summary.json').read_text())
