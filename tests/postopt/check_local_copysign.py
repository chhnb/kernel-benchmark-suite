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
cat=catalog(p,'catalog');pair=next(c for c in cat['candidates'] if c['logical_left']=='D0.L1' and c['logical_right']=='D0.L2')
def trial(inp,name,c):
 d=O/name;out=O/(name+'.ll');q=cmd([S,'--ir',inp,'--function','f','--out',out,'--debug-dir',d,'--scorer','legacy','--adjacent-only','1','--local-copysign','1','--cleanup','none','--split',c['split'],'--left',c['left'],'--right',c['right']]);return out,d
out,d=trial(p,'local',pair);after=out.read_text();assert after.count('call float @llvm.copysign.f32')==7;assert 'local.magnitude = phi float' in after;assert 'replicated.bb' not in after
j=json.loads((d/'trial-0/trial.json').read_text());assert j['valid'] and not j['replication_required'];st=json.loads((d/'trial-0/logical-state.json').read_text());assert 'D0.G0' in st['decisions'][0]['active']
# Exact output-bit comparison including thresholds, neighbors, +/-0, +/-inf,
# quiet/signaling NaN payloads and deterministic random float bit patterns.
values={0,0x80000000,0x7f800000,0xff800000,0x7fc00001,0xffc01234,0x7f800001,0xff800001}
for x in threshold:
 b=struct.unpack('I',struct.pack('f',x))[0]
 for sign in [0,0x80000000]:
  values.update((b+delta)|sign for delta in [-1,0,1])
rng=random.Random(452);values.update(rng.getrandbits(32) for _ in range(10000))
for level in [0,3]:
 funcs=[]
 for name,ir in [('before',p),('after',out)]:
  so=O/(name+str(level)+'.so');cmd([CC,'-shared','-fPIC','-O'+str(level),ir,'-o',so]);lib=ctypes.CDLL(str(so));f=lib.f;f.argtypes=[ctypes.c_uint32];f.restype=ctypes.c_uint32;funcs.append((lib,f))
 for b in values:assert funcs[0][1](b)==funcs[1][1](b),(level,hex(b))
# Input contains additional work: explicit local route must reject, not silently
# fall back to replication. It remains a valid adjacency candidate.
bad=O/'extra.ll';bad.write_text(s.replace('L1:\n','L1:\n %extra=fadd float %input, 1.0\n'))
bc=catalog(bad,'extra-catalog');c=next(c for c in bc['candidates'] if c['logical_left']=='D0.L1' and c['logical_right']=='D0.L2')
q=subprocess.run([str(S),'--ir',str(bad),'--function','f','--out',str(O/'bad-out.ll'),'--scorer','legacy','--adjacent-only','1','--local-copysign','1','--cleanup','none','--split',c['split'],'--left',c['left'],'--right',c['right']],capture_output=True,text=True);assert q.returncode==4 and 'local_requires_copysign_only_leaves' in q.stderr,q.stderr
(O/'summary.json').write_text(json.dumps({'verified':True,'copysign_before':8,'copysign_after':7,'output_bit_tests_per_optimization_level':len(values),'host_optimization_levels':[0,3],'extra_instruction_rejected':True},indent=2));print((O/'summary.json').read_text())
