from pathlib import Path
import subprocess
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
for role in ['L0-L1','L1-L2']:
 subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(p/'input.ll'),'--variant',str(p/(role+'-v2.ll')),'--case','hypersonic','--function','face_kernel','--scope','complete-SESE-leaf-trial-common-final-O3','--out',str(p/(role+'-pair')),'--admitted'],check=True)
