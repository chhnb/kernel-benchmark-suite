from pathlib import Path
import json,hashlib,struct
import numpy as np
S=Path('/home/chh/kernel-benchmark-suite');src=S/'cases/vllm-quant/inputs/qwen35-64k';out=S/'cases/vllm-quant-large';out.mkdir(exist_ok=False)
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(8*1024*1024),b''):h.update(b)
 return h.hexdigest()
t=(S/'archive/python-runtime/vllm-quant/harness/run_hip.py').read_text();ns={'np':np};exec(t[t.index('levels=np.array'):t.index('\ndef dataset(')],ns)
old=json.loads((src/'historical/amd-qwen64k-compare-v1/gpu-validation.json').read_text())['records'];receipt=json.loads((src/'import-receipt.json').read_text());hashes={r['destination']:r['sha256'] for r in receipt['files']};records=[]
for rec in json.loads((src/'manifest.json').read_text())['records']:
 if rec['kind']!='key':continue
 k=src/rec['file'];v=src/rec['file'].replace('-key','-value');assert sha(k)==hashes[k.name] and sha(v)==hashes[v.name]
 key=np.load(k,mmap_mode='r');val=np.load(v,mmap_mode='r');nt,heads,dim=key.shape;assert (nt,heads,dim)==(65536,2,256)
 page=16;stride=heads*dim;capacity=((nt+15)//16+1)*16;slots=np.arange(nt,dtype='<i8')
 def scale(x):
  amax=max(float(np.abs((x[a:a+1024].astype('u4')<<16).view('f4')).max()) for a in range(0,nt,1024))
  return float(np.float32(2688/max(amax,1e-30)))
 kg,vg=scale(key),scale(val);historic=[r for r in old if r['file']==k.name];assert historic and all(r['key_global']==kg and r['value_global']==vg for r in historic)
 d=out/'fixtures'/('qwen64k-layer%02d'%rec['layer']);d.mkdir(parents=True);lines=['kernel cache_eval',f'grid {nt} 1 1',f'block {heads*(dim//16)} 1 1']
 for name,arr in [('key',key),('value',val),('slots',slots)]:arr.tofile(d/(name+'.bin'));lines.append(f'buffer {name} {name}.bin readonly - 0 0')
 for inp,g,sw,names in [(key,kg,False,['kd','ks']),(val,vg,True,['vd','vs'])]:
  data=np.full((capacity//page,heads,page,dim//2),165,'u1');sc=np.full((capacity//page,heads,page,dim//16),165,'u1')
  for a in range(0,nt,1024):ns['reference'](inp[a:a+1024],slots[a:a+1024],heads,dim,page,stride,g,sw,(data,sc))
  for name,arr in zip(names,[data,sc]):
   arr.tofile(d/(name+'-ref.bin'));np.full(arr.size,165,'u1').tofile(d/(name+'-init.bin'));lines.append(f'buffer {name} {name}-init.bin exact {name}-ref.bin 0 0')
 lines+=['arg ptr '+n for n in ['key','value','slots','kd','vd','ks','vs']]
 lines+=['arg hex '+struct.pack('<'+fmt,x).hex() for fmt,x in [('i',heads),('i',dim),('i',page),('i',stride),('f',kg),('f',vg)]]
 (d/'input.txt').write_text('\n'.join(lines)+'\n');records.append({'kind':'real_qwen64k','layer':rec['layer'],'key_global':kg,'value_global':vg,'source_key_sha256':hashes[k.name],'source_value_sha256':hashes[v.name],'fixture':str(d/'input.txt'),'files':{p.name:sha(p) for p in d.iterdir()}});print('Exported layer',rec['layer'],flush=True)
parent=json.loads((S/'cases/vllm-quant/case.json').read_text());rt=parent['runtime'];synthetic=S/'cases/vllm-quant/fixtures-cpp/131072/input.txt';rt['inputs']=[r['fixture'] for r in records]+[str(synthetic)];rt['scope']='Six real Qwen 65536-token layers with historical scales/sequential slots plus synthetic 131072-token fixture; full software HIP cache_eval; D16 tree comparison';case={'name':'vllm-quant-large','status':'exported_pending_gpu','runtime':rt};(out/'case.json').write_text(json.dumps(case,indent=2));(out/'provenance.json').write_text(json.dumps({'records':records,'synthetic128k':{'fixture':str(synthetic),'seed':20261103,'heads':8,'dim':128,'source':'existing frozen standard-normal BF16 fixture with boundary values and skipped/shuffled slots'},'oracle_source':str(S/'archive/python-runtime/vllm-quant/harness/run_hip.py'),'oracle_sha256':sha(S/'archive/python-runtime/vllm-quant/harness/run_hip.py')},indent=2))
