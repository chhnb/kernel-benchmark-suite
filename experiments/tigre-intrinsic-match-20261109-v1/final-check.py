from pathlib import Path
import subprocess,json
s=Path('/home/chh/kernel-benchmark-suite');p=s/'experiments/tigre-intrinsic-match-20261109-v1'
for name in ['intrinsic_matching','hybrid_test','scoped_local','recursive_local_union']:
 subprocess.run(['bash',str(s/('tests/postopt/build_'+name+'.sh'))],check=True)
plan=json.loads((p/'build-plan.json').read_text());cmd=plan['commands'][0]['argv']
cmd=[x.replace(str(p/'hybrid-cfg'),str(p/'final-check')) for x in cmd]
subprocess.run(cmd,check=True)
assert (p/'final-check.ll').read_bytes()==(p/'hybrid-cfg.ll').read_bytes()
subprocess.run([str(s/'build/llvm24-tti/recursive-local-union'),str(s/'experiments/recursive-all32-greedy-20261108-v1/state-0.ll'),'cache_eval','D16',str(p/'vllm-D16-regression'),'greedy'],check=True)
a=json.loads((p/'vllm-D16-regression/summary.json').read_text());assert a['commits']==7
print('PASS final TIGRE IR byte-identical to GPU-validated IR; vLLM D16 seven recursive local merges')
