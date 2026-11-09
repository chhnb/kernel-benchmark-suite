from pathlib import Path
import subprocess,json,argparse
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
parser=argparse.ArgumentParser();parser.add_argument('--output-dir');args=parser.parse_args()
if args.output_dir:p=Path(args.output_dir);p.mkdir(exist_ok=False)
src=s/'experiments/hypersonic-complete-leaf-20261109-v1/input.ll'
rows=[]
for role,enabled in [('old','0'),('multi','1')]:
 cmd=[str(s/'build/llvm24-tti/fusion-search-llvm24'),'--ir',str(src),'--function','face_kernel','--structural','1','--cross-decision-leaves','1','--coalesce-gaps','1','--complete-leaf-plan',enabled,'--cleanup','scoped-cfg-triangles','--scorer','llvm24','--split','B7','--left','E8_23','--right','E15_23','--debug-dir',str(p/role),'--out',str(p/(role+'.ll'))]
 with (p/(role+'.stdout')).open('w') as a,(p/(role+'.stderr')).open('w') as b:r=subprocess.run(cmd,stdout=a,stderr=b)
 assert r.returncode==0,(role,r.returncode)
 t=json.loads((p/role/'trial-0/trial.json').read_text());print(role,t,flush=True)
 assert t['valid'] and t['score_result']['status']=='scored'
 rows.append({'role':role,'command':cmd,'trial':t});(p/'trials.json').write_text(json.dumps(rows,indent=2))
