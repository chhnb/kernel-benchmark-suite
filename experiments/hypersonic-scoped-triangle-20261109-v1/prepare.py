from pathlib import Path
import subprocess,json
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
src=s/'experiments/hypersonic-complete-leaf-20261109-v1/input.ll'
rows=[]
for role,cleanup in [('old','scoped-cfg'),('triangle','scoped-cfg-triangles')]:
 cmd=[str(s/'build/llvm24-tti/fusion-search-llvm24'),'--ir',str(src),'--function','face_kernel','--structural','1','--coalesce-gaps','1','--cleanup',cleanup,'--scorer','llvm24','--split','B7','--left','E8_23','--right','E15_23','--debug-dir',str(p/role),'--out',str(p/(role+'.ll'))]
 with (p/(role+'.stdout')).open('w') as a,(p/(role+'.stderr')).open('w') as b:r=subprocess.run(cmd,stdout=a,stderr=b)
 assert r.returncode==0,role
 t=json.loads((p/role/'trial-0/trial.json').read_text());assert t['valid'] and t['score_result']['status']=='scored'
 rows.append({'role':role,'command':cmd,'trial':t});(p/'trials.json').write_text(json.dumps(rows,indent=2))
old=s/'experiments/hypersonic-coalesce-gaps-20261109-v1/L1-L2-on/trial-0'
assert (old/'after-raw.ll').read_bytes()==(p/'old/trial-0/after-raw.ll').read_bytes(),'typo fix changed IR'
assert (p/'old/trial-0/after-raw.ll').read_bytes()==(p/'triangle/trial-0/after-raw.ll').read_bytes(),'raw IR differs between cleanup modes'
print([(r['role'],r['trial']['after']['blocks'],r['trial']['after']['conditional_branches'],r['trial']['after']['phis'],r['trial']['score_result']['static_gain']) for r in rows])
