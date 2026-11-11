from pathlib import Path
import json, hashlib, struct, sys
import numpy as np
S=Path('/home/chh/kernel-benchmark-suite'); src=S/'cases/vllm-quant/inputs/kv'; out=S/'cases/vllm-quant-kv-dump'
sys.path.insert(0,str(S/'archive/python-runtime/vllm-quant/harness'))
from oracle import reference
out.mkdir(exist_ok=False); manifest=json.loads((src/'manifest.json').read_text()); records=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for rec in manifest['records']:
 f=src/rec['file']; z=np.load(f); key=z['key']; value=z['value']; nt,heads,dim=key.shape
 assert key.dtype==np.uint16 and value.shape==key.shape and dim%64==0
 d=out/'fixtures'/f.stem;d.mkdir(parents=True);page=16;stride=heads*dim; slots=np.arange(nt,dtype='<i8');kg=float(z['key_global']);vg=float(z['value_global'])
 lines=['kernel cache_eval',f'grid {nt} 1 1',f'block {min(heads*(dim//16),256)} 1 1']
 for name,arr in [('key',key),('value',value),('slots',slots)]:
  arr.tofile(d/(name+'.bin')); lines.append(f'buffer {name} {name}.bin readonly - 0 0')
 for inp,scale,swizzle,names in [(key,kg,False,['kd','ks']),(value,vg,True,['vd','vs'])]:
  refs=reference(inp,slots,heads,dim,page,stride,scale,swizzle)
  for name,arr in zip(names,refs):
   arr.tofile(d/(name+'-ref.bin')); np.full(arr.size,165,'u1').tofile(d/(name+'-init.bin'));lines.append(f'buffer {name} {name}-init.bin exact {name}-ref.bin 0 0')
 lines += ['arg ptr '+k for k in ['key','value','slots','kd','vd','ks','vs']]
 lines += ['arg hex '+struct.pack('<'+fmt,v).hex() for fmt,v in [('i',heads),('i',dim),('i',page),('i',stride),('f',kg),('f',vg)]]
 (d/'input.txt').write_text('\n'.join(lines)+'\n'); records.append({**rec,'source_sha256':sha(f),'fixture':str((d/'input.txt').relative_to(out)),'files':{p.name:sha(p) for p in sorted(d.iterdir())}})
parent=json.loads((S/'cases/vllm-quant/case.json').read_text());m={'name':'vllm-quant-kv-dump','status':'fixtures_exported_validation_pending','origin':str(src),'runtime':parent['runtime']};m['runtime']['inputs']=[r['fixture'] for r in records];m['runtime']['scope']='60 original SmolLM2 post-RoPE dumps; 75-token prefill and 1-token decode, 3 heads dim64; BF16 and original scales, sequential slots, no replication; HIP software cache_eval, not native FP4 or end-to-end inference'
(out/'case.json').write_text(json.dumps(m,indent=2));(out/'provenance.json').write_text(json.dumps({'source_manifest_sha256':sha(src/'manifest.json'),'source_manifest':manifest,'oracle_sha256':sha(S/'archive/python-runtime/vllm-quant/harness/oracle.py'),'records':records},indent=2));print('Exported',len(records),'dump fixtures')
