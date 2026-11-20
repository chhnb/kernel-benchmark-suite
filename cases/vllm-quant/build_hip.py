from pathlib import Path
import json,subprocess,sys
P=Path(__file__).resolve().parent;out=Path(sys.argv[1]);out.mkdir(exist_ok=True)
for name in ['front','prep','link','post','llc','link-hsaco']:
 cmd=[x.replace('{case}',str(P)).replace('{out}',str(out)) for x in json.loads((P/'recipes'/(name+'.json')).read_text())]
 r=subprocess.run(cmd,capture_output=True,text=True,timeout=600)
 (out/(name+'.json')).write_text(json.dumps({'command':cmd,'returncode':r.returncode,'stdout':r.stdout,'stderr':r.stderr},indent=2))
 if r.returncode:print(r.stderr);raise SystemExit(r.returncode)
ref=Path('/home/chh/region-fusion-lab/runs/amd-vllm-cache-port-v1/unmerged/kernel.hsaco')
for name,path in [('new',out/'kernel.hsaco'),('historical',ref)]:
 subprocess.run(['/opt/rocm/llvm/bin/llvm-objcopy','--dump-section','.text='+str(out/(name+'.text')),str(path)],check=True)
equal=(out/'new.text').read_bytes()==(out/'historical.text').read_bytes()
(out/'baseline-comparison.json').write_text(json.dumps({'historical_binary':str(ref),'text_byte_equal':equal,'fresh_gpu_validation':False},indent=2))
if not equal:raise SystemExit('Baseline machine code differs from historical baseline')
print('HIP baseline rebuilt; machine code byte-identical to historical unmerged baseline')
