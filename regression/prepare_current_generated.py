from pathlib import Path
import sys,subprocess,json,hashlib
s=Path(__file__).resolve().parents[1];out=Path(sys.argv[1]);out.mkdir(exist_ok=False)
def run(cmd):subprocess.run([str(x) for x in cmd],check=True,cwd=s)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
run(['bash',s/'tests/postopt/build_recursive_all32.sh'])
v=s/'experiments/recursive-all32-greedy-20261108-v1';m=s/'experiments/mapairy-full-convergence-20261109-v1'
run([s/'build/llvm24-tti/recursive-all32',v/'state-0.ll','cache_eval','all8',out/'vllm-search','greedy'])
run([s/'build/llvm24-tti/fusion-search-llvm24','--ir',m/'steps-final/state-0.ll','--function','evaluate','--structural','1','--cleanup','scoped-cfg','--scorer','llvm24','--rounds','256','--trials','100000','--debug-dir',out/'mapairy-search','--out',out/'mapairy.ll'])
records={}
for case,fn,baseline,variant,reference in [('vllm','cache_eval',v/'state-0.ll',out/'vllm-search/final.ll',s/'regression/golden/20261109-gfx906-v1/vllm/artifacts/winner.hsaco'),('mapairy','evaluate',m/'steps-final/state-0.ll',out/'mapairy.ll',m/'greedy-pair/variant.hsaco')]:
 pair=out/(case+'-pair');run(['python3',s/'tools/postopt_compile_pair.py','--baseline',baseline,'--variant',variant,'--case','vllm-quant' if case=='vllm' else 'boost-mapairy','--function',fn,'--scope','current-code-generated-regression','--out',pair,'--admitted'])
 records[case]={'candidate':str(pair/'variant.hsaco'),'candidate_sha256':sha(pair/'variant.hsaco'),'reference_sha256':sha(reference),'binary_identical':sha(reference)==sha(pair/'variant.hsaco')}
records['code_commit']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=s,text=True).strip();(out/'code-regression.json').write_text(json.dumps(records,indent=2));print(json.dumps(records,indent=2))
