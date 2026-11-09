from pathlib import Path
import subprocess,hashlib,json,shutil
import numpy as np
s=Path(__file__).resolve().parents[2];out=s/'regression/runs/20261110-generator-test';out.mkdir(exist_ok=False)
source=s/'regression/generators/generated_fixtures.cpp';subprocess.run(['g++','-std=c++17','-O2','-ffp-contract=off','-fno-fast-math',str(source),'-o',str(out/'generate')],check=True)
for name in ['a','b']:subprocess.run([str(out/'generate'),str(out/name),'64','2026111001'],check=True)
a=out/'a';b=out/'b';assert all((b/p.name).read_bytes()==p.read_bytes() for p in a.iterdir())
t=(s/'archive/python-runtime/vllm-quant/harness/run_hip.py').read_text();ns={'np':np};exec(t[t.index('levels=np.array'):t.index('\ndef dataset(')],ns)
slots=np.fromfile(a/'slots.bin',dtype='<i8');assert (slots<0).any();assert len(set(slots[slots>=0]))==sum(slots>=0)
for role,scale,sw,names in [('key',1.,False,['kd','ks']),('value',1.25,True,['vd','vs'])]:
 x=np.fromfile(a/(role+'.bin'),dtype='<u2').reshape(64,1024);actual=ns['reference'](x,slots,8,128,16,1024,scale,sw)
 for name,ref in zip(names,actual):assert ref.tobytes()==(a/(name+'-ref.bin')).read_bytes(),name
report={'passed':True,'deterministic_two_runs':True,'tokens':64,'exact_reference_buffers':4,'oracle':'independent established NumPy oracle','oracle_sha256':hashlib.sha256(t.encode()).hexdigest(),'generator_sha256':hashlib.sha256(source.read_bytes()).hexdigest()}
(out/'summary.json').write_text(json.dumps(report,indent=2));shutil.rmtree(a);shutil.rmtree(b);print(json.dumps(report))
