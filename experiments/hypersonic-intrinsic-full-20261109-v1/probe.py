from pathlib import Path
import subprocess,json
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
rows=[]
for tag,split,left,right in [('leaf0_vs_leaf1_inner_region','B5','B6','R3'),('leaf2_vs_leaf3','B13','R4','B19'),('leaf0_vs_leaf1_tail','B5','B6','B12'),('two_boundary_regions','B7','R3','R4')]:
 cmd=[str(s/'build/llvm24-tti/fusion-search-llvm24'),'--ir',str(s/'results/hypersonic-hip-llvm12-ir-v1/start.ll'),'--function','face_kernel','--structural','1','--adjacent-only','0','--cleanup','scoped-cfg','--scorer','llvm24','--split',split,'--left',left,'--right',right,'--debug-dir',str(p/tag),'--out',str(p/(tag+'.ll'))]
 with (p/(tag+'.stdout')).open('w') as a,(p/(tag+'.stderr')).open('w') as b:r=subprocess.run(cmd,stdout=a,stderr=b)
 rows.append({'tag':tag,'command':cmd,'exit':r.returncode,'trials':[json.loads(f.read_text()) for f in (p/tag).glob('trial-*/trial.json')]})
(p/'probes.json').write_text(json.dumps(rows,indent=2))
