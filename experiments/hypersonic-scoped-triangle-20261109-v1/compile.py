from pathlib import Path
import subprocess,json
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
for role in ['old','triangle']:
 subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(s/'experiments/hypersonic-complete-leaf-20261109-v1/input.ll'),'--variant',str(p/(role+'.ll')),'--case','hypersonic','--function','face_kernel','--scope','L1-L2-small-triangle-fixed-LLVM24-throughput-score','--out',str(p/(role+'-pair')),'--admitted'],check=True)
