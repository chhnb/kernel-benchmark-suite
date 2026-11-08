#!/usr/bin/env python3
"""One-time, uncompressed snapshots. Existing snapshots are never overwritten."""
from pathlib import Path
import hashlib,json,shutil,subprocess
S=Path(__file__).resolve().parents[1]
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(8<<20),b''):h.update(b)
 return h.hexdigest()
def main():
 root=S/'regression/golden/20261109-gfx906-v1';root.mkdir(parents=True,exist_ok=False)
 provenance={}
 def cp(src,dst):
  src=Path(src);out=root/dst;out.parent.mkdir(parents=True,exist_ok=True)
  if src.is_dir():shutil.copytree(src,out,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
  else:shutil.copy2(src,out)
  provenance[str(dst)]=str(src)
 configs={}
 v=S/'experiments/qwen64k-all32-greedy-20261108-v1';t=S/'experiments/tigre-intrinsic-match-20261109-v1'
 for key,case,record,runner in [('vllm','vllm-quant-qwen64k',v,'bench_hip'),('tigre','tigre-siddon',t,'bench_tigre')]:
  cp(record/'measure',f'{key}/historical/measure');cp(record/'summary.json',f'{key}/historical/summary.json')
  binarydir=record if key=='vllm' else record/'pair'
  for src,dst in [('variant.hsaco','winner.hsaco'),('variant-final.ll','winner-postopt.ll'),('manifest.json','build-manifest.json'),('variant-resources.stdout','winner-resources.txt')]:cp(binarydir/src,f'{key}/artifacts/{dst}')
  cp(S/f'build/bin/{runner}',f'{key}/runner/{runner}')
  original=json.loads((S/f'cases/{case}/case.json').read_text());cfg=json.loads(json.dumps(original))
  rt=cfg['runtime'];rt['runner']=str(root/f'{key}/runner/{runner}');rt['default_kernel']=str(root/f'{key}/artifacts/winner.hsaco')
  cfg['name']='frozen-'+case+'-gfx906-20261109';cfg['origin_case']=case
  if key=='vllm':
   inputs=[]
   for n in [3,7,11,15,19,23]:
    src=S/f'cases/vllm-quant-large/fixtures/qwen64k-layer{n:02d}';dest=f'{key}/inputs/layer{n:02d}'
    cp(src,dest);inputs.append(str(root/dest/'input.txt'))
   rt['inputs']=inputs
   base=S/'experiments/recursive-all32-greedy-20261108-v1'
   cp(base/'state-0.ll',f'{key}/artifacts/baseline.ll');cp(base/'final.ll',f'{key}/artifacts/winner.ll')
   cp(base/'summary.json',f'{key}/search-summary.json');cp(base/'logical-state-224.json',f'{key}/final-logical-state.json')
   cp(S/'experiments/kv-dump-tree-comparison-20261108-v1/baseline.hsaco',f'{key}/artifacts/unmerged.hsaco')
   cp(v/'baseline.hsaco',f'{key}/artifacts/balanced-control.hsaco')
   meta=S/'cases/vllm-quant/inputs/qwen35-64k'
   for name in ['README.md','input.json','import-receipt.json','SHA256SUMS','generation']:
    cp(meta/name,f'{key}/input-provenance/{name}')
   ms=json.loads((v/'summary.json').read_text())['sum_layer_medians_ms']['greedy']
   strategy='32 eight-leaf instances; 224 merges; per-instance adjacent LLVM24 greedy, leftmost tie; cleanup none; shared copysign'
   cp(S/'tools/measure_qwen64k_greedy.py',f'{key}/historical/measure.py')
  else:
   cp(S/'cases/tigre-siddon/input',f'{key}/inputs');rt['inputs']=[str(root/f'{key}/inputs')]
   cp(S/'results/tigre-baseline-binary-v1/post.ll',f'{key}/artifacts/baseline.ll');cp(t/'hybrid-cfg.ll',f'{key}/artifacts/winner.ll')
   for name in ['result.json','run.json','commit-1.json','commit-2.json']:
    cp(t/'hybrid-cfg'/name,f'{key}/search/{name}')
   cp(S/'experiments/tigre-new-greedy-vs-artifact-darm-20261108-v1/pair/baseline.hsaco',f'{key}/artifacts/unmerged.hsaco')
   cp(t/'pair/baseline.hsaco',f'{key}/artifacts/original-artifacts-darm.hsaco')
   ms=json.loads((t/'summary.json').read_text())['sum_medians_ms']['hybrid']
   strategy='structural LLVM24 greedy; scoped-local; 2 merges: Y+Z then X+(Y,Z); 1 sample call'
   cp(t/'prepare.py',f'{key}/historical/prepare.py');cp(t/'measure.py',f'{key}/historical/measure.py')
  casepath=root/f'{key}/case';casepath.mkdir();(casepath/'case.json').write_text(json.dumps(cfg,indent=2))
  configs[key]={'case_directory':f'{key}/case','winner_binary':f'{key}/artifacts/winner.hsaco','historical_ms':ms,'strategy':strategy,'timing':'GPU event; sum of six group/layer medians; 3 warmups,15 measured,3 rotated batches','function':'cache_eval' if key=='vllm' else '_Z19kernelPixelDetector8GeometryPfiiP13__hip_texture'}
 for path in ['tools','runner','tests/postopt','CMakeLists.txt','build-runners','bench','cases/tigre-siddon/harness','cases/tigre-siddon/source','cases/vllm-quant/harness','cases/vllm-quant/recipes']:
  cp(S/path,'source/'+path)
 deps=[]
 for path in ['/home/chh/darm-artifacts-repro/build/bin/opt','/home/chh/darm-artifacts-repro/build/bin/llvm-config','/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt','/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/llc']:
  q=Path(path);deps.append({'path':path,'sha256':sha(q),'archived':False})
 for name in ['fusion-search-llvm24','recursive-all32']:
  cp(S/'build/llvm24-tti'/name,'compiler/'+name)
 manifest={'schema':'gpu-performance-golden-v1','date':'2026-11-09','device_target':'AMD gfx906','scope':'current suite software HIP vLLM real Qwen64K and full TIGRE head64; not end-to-end inference or cross-device best','code_commit':subprocess.check_output(['git','-C',str(S),'rev-parse','HEAD'],text=True).strip(),'cases':configs,'provenance':provenance,'external_dependencies':deps,'sha256':{}}
 for p in sorted(root.rglob('*')):
  if p.is_file():manifest['sha256'][str(p.relative_to(root))]=sha(p)
 (root/'manifest.json').write_text(json.dumps(manifest,indent=2))
 # Read-only independent copies, not hard links into mutable experiments.
 for p in root.rglob('*'):
  if p.is_file():p.chmod(p.stat().st_mode & ~0o222)
 print(json.dumps({'archive':str(root),'files':len(manifest['sha256']),'cases':configs},indent=2))
if __name__=='__main__':main()
