import json,subprocess
from pathlib import Path
r=Path('/home/chh/kernel-benchmark-suite');o=r/'experiments/llvm24-eight-adjacent-catalog-v1';o.mkdir(exist_ok=False)
items=json.loads((r/'experiments/llvm24-focus-nine-20261108-v1/plan.json').read_text())
for it in items:
 if it['case']=='hipims-george':continue
 d=o/it['case'];d.mkdir()
 p=subprocess.run([str(r/'build/llvm24-tti/fusion-search-llvm24'),'--ir',it['source'],'--function',it['function'],'--catalog-only','1','--adjacent-only','1','--cleanup','postopt-fp','--out',str(d/'source.ll'),'--debug-dir',str(d/'debug')],capture_output=True,text=True,timeout=120)
 (d/'command.log').write_text(p.stdout+p.stderr)
 if p.returncode==0:print(it['case'],json.loads((d/'debug/catalog.json').read_text())['count'],flush=True)
 else:print(it['case'],p.returncode,p.stderr[-500:],flush=True)
