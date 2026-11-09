from pathlib import Path
import subprocess
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
for i in [1,2,3]:
 subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(p/'steps-final/state-0.ll'),'--variant',str(p/('steps-final/state-'+str(i)+'.ll')),'--case','boost-mapairy','--function','evaluate','--scope','direct-adjacent-entry-forced-replay','--out',str(p/('pair-'+str(i))),'--admitted'],check=True)
