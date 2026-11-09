from pathlib import Path
import subprocess,json,hashlib
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
src=s/'experiments/hypersonic-complete-leaf-20261109-v1/input.ll'
for role in ['L0-L1-off','L0-L1-on']:
 subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(src),'--variant',str(p/(role+'.ll')),'--case','hypersonic','--function','face_kernel','--scope','fixed-alignment-gap-grouping-off-on-common-final-O3','--out',str(p/(role+'-pair')),'--admitted'],check=True)
old=s/'experiments/hypersonic-complete-leaf-20261109-v1/L0-L1-pair'
checks={}
for role in ['baseline','variant']:
 checks['off_'+role+'_matches_previous']=((p/'L0-L1-off-pair'/(role+'.hsaco')).read_bytes()==(old/(role+'.hsaco')).read_bytes())
 assert checks['off_'+role+'_matches_previous']
checks['L1_L2_on_off_raw_identical']=(p/'L1-L2-on/trial-0/after-raw.ll').read_bytes()==(p/'L1-L2-off/trial-0/after-raw.ll').read_bytes()
assert checks['L1_L2_on_off_raw_identical']
(p/'codegen-regression.json').write_text(json.dumps(checks,indent=2))
