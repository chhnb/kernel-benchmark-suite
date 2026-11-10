"""Isolated generated fixtures; never alters the frozen generator/protocol."""
from pathlib import Path
import sys,subprocess,json,hashlib
s=Path(sys.argv[1]);out=Path(sys.argv[2]);out.mkdir(exist_ok=False)
for case in ['mapairy','vllm']:
 subprocess.run(['python3',str(s/'regression/generators/prepare.py'),case,str(out/case)],check=True)
source=(s/'regression/generators/generated_fixtures.cpp').read_text()
old='for(size_t i=0;i<n;++i)x[i]=anchors[i%12];for(size_t i=n-1;i;i--)std::swap(x[i],x[random64()%(i+1)]);'
new='for(size_t i=0;i<n;++i)x[i]=anchors[std::min(size_t(11),i*12/n)];'
assert source.count(old)==1
p=out/'coherent.cpp';p.write_text(source.replace(old,new));exe=out/'coherent-generator'
subprocess.run(['g++','-std=c++17','-O2','-ffp-contract=off','-fno-fast-math','-DMAPAIRY','-DBOOST_MATH_STANDALONE','-I'+str(s/'cases/boost-mapairy/source/boost-math/include'),str(p),'-o',str(exe)],check=True)
subprocess.run([str(exe),str(out/'mapairy-coherent'),'65539','2026110301'],check=True)
rows=[]
for case in ['mapairy','vllm']:
 m=json.loads((out/case/'generation.json').read_text())
 for row in m['rows']:rows.append(dict(row,case=case,layout='mixture' if case=='mapairy' else 'random-bf16'))
p=out/'mapairy-coherent';rows.append({'case':'mapairy','layout':'coherent-blocks','count':65539,'seed':2026110301,'spec':str(p/'input.txt'),'files':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in p.iterdir()},'generator_source_sha256':hashlib.sha256(source.replace(old,new).encode()).hexdigest()})
(out/'inputs.json').write_text(json.dumps(rows,indent=2))
