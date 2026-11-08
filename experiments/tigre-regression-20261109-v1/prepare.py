from pathlib import Path
import subprocess,json
s=Path('/home/chh/kernel-benchmark-suite');p=s/'experiments/tigre-regression-20261109-v1';g=s/'regression/golden/20261109-gfx906-v1/tigre';fn='_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture'
subprocess.run([str(s/'build/llvm24-tti/fusion-search-llvm24'),'--ir',str(g/'artifacts/baseline.ll'),'--function',fn,'--structural','1','--adjacent-only','0','--cleanup','scoped-local','--scorer','llvm24','--rounds','256','--trials','100000','--debug-dir',str(p/'search'),'--out',str(p/'final.ll')],check=True)
subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(g/'artifacts/winner.ll'),'--variant',str(p/'final.ll'),'--case','tigre-siddon','--function',fn,'--scope','current-code-frozen-winner-regression','--out',str(p/'pair'),'--admitted'],check=True)
def strip(f):return '\n'.join(l for l in f.read_text().splitlines() if not l.startswith('; ModuleID = '))
r={'search':json.loads((p/'search/result.json').read_text()),'ir_identical_except_module_id_comment':strip(p/'final.ll')==strip(g/'artifacts/winner.ll'),'binary_identical':(p/'pair/variant.hsaco').read_bytes()==(g/'artifacts/winner.hsaco').read_bytes()};(p/'code-regression.json').write_text(json.dumps(r,indent=2));print(r)
