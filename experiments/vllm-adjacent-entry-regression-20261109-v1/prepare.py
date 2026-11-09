from pathlib import Path
import subprocess,json,hashlib
s=Path('/home/chh/kernel-benchmark-suite');p=s/'experiments/vllm-adjacent-entry-regression-20261109-v1';old=s/'experiments/recursive-all32-greedy-20261108-v1'
subprocess.run(['bash',str(s/'tests/postopt/build_recursive_all32.sh')],check=True)
subprocess.run([str(s/'build/llvm24-tti/recursive-all32'),str(old/'state-0.ll'),'cache_eval','all8',str(p/'search-v2'),'greedy'],check=True)
subprocess.run(['python3',str(s/'tools/postopt_compile_pair.py'),'--baseline',str(old/'final.ll'),'--variant',str(p/'search-v2/final.ll'),'--case','vllm-quant-qwen64k','--function','cache_eval','--scope','current-code-all32-LLVM24-greedy-regression','--out',str(p/'pair'),'--admitted'],check=True)
a=json.loads((p/'search-v2/summary.json').read_text());b=json.loads((old/'summary.json').read_text());report={'commits':a['commits'],'stop':a['stop'],'final_ir_identical':(p/'search-v2/final.ll').read_bytes()==(old/'final.ll').read_bytes(),'binary_identical':(p/'pair/variant.hsaco').read_bytes()==(s/'experiments/qwen64k-all32-greedy-20261108-v1/variant.hsaco').read_bytes(),'search_summary_identical':a==b,'code_commit':subprocess.check_output(['git','-C',str(s),'rev-parse','HEAD'],text=True).strip()};(p/'code-regression.json').write_text(json.dumps(report,indent=2));print(report)
