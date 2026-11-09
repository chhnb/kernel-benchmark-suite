from pathlib import Path
import sys,subprocess,json,hashlib
s=Path(__file__).resolve().parents[2];case=sys.argv[1];out=Path(sys.argv[2]);out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
source=s/'regression/generators/generated_fixtures.cpp';cmd=['g++','-std=c++17','-O2','-ffp-contract=off','-fno-fast-math',str(source),'-o',str(out/'generate')]
if case=='mapairy':cmd+=['-DMAPAIRY','-DBOOST_MATH_STANDALONE','-I'+str(s/'cases/boost-mapairy/source/boost-math/include')]
subprocess.run(cmd,check=True)
params=[(65536,2026111001),(131072,2026111002)] if case=='vllm' else [(65539,2026110301)]
rows=[]
for count,seed in params:
 d=out/str(count);subprocess.run([str(out/'generate'),str(d),str(count),str(seed)],check=True)
 rows.append({'count':count,'seed':seed,'spec':str(d/'input.txt'),'files':{p.name:sha(p) for p in sorted(d.iterdir()) if p.is_file()}})
(out/'generation.json').write_text(json.dumps({'schema':'generated-fixtures-v1','case':case,'source_sha256':sha(source),'compile':cmd,'generator':'splitmix64-clt12-bf16-v1' if case=='vllm' else 'splitmix64-shuffled-12-anchors-v1','rows':rows},indent=2))
