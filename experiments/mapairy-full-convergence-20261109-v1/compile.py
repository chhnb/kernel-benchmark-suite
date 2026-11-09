from pathlib import Path
import subprocess
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
for role,ir in [('balanced',p/'steps-final/state-7.ll'),('greedy',p/'greedy.ll')]:
 subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(p/'steps-final/state-0.ll'),'--variant',str(ir),'--case','boost-mapairy','--function','evaluate','--scope','full-convergence-and-prescribed-eight-leaf-balanced-tree','--out',str(p/(role+'-pair')),'--admitted'],check=True)
