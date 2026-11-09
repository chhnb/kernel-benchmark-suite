from pathlib import Path
import subprocess,json
p=Path(__file__).resolve().parent
s=Path('/home/chh/kernel-benchmark-suite')
rows=[]
for tag,split,left,right in [('L0-L1','B5','E6_23','E8_23'),('L1-L2','B7','E8_23','E15_23')]:
 cmd=[str(s/'build/llvm24-tti/fusion-search-llvm24'),'--ir','/home/chh/kernel-benchmark-suite/experiments/hypersonic-complete-leaf-20261109-v1/input.ll','--function','face_kernel','--structural','1','--adjacent-only','0','--cleanup','scoped-cfg','--scorer','llvm24','--split',split,'--left',left,'--right',right,'--debug-dir',str(p/(tag+'-v2')),'--out',str(p/(tag+'-v2.ll'))]
 with (p/(tag+'.stdout')).open('w') as a,(p/(tag+'.stderr')).open('w') as b:r=subprocess.run(cmd,stdout=a,stderr=b)
 rows.append({'tag':tag,'command':cmd,'exit':r.returncode,'trials':[json.loads(f.read_text()) for f in (p/(tag+'-v2')).glob('trial-*/trial.json')]})
(p/'fusion-probes-v2.json').write_text(json.dumps(rows,indent=2))
print(json.dumps(rows,indent=2))
