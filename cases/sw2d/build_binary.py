from pathlib import Path
import json,subprocess,sys
P=Path(__file__).resolve().parent;out=Path(sys.argv[1]);m=json.loads((P/'case.json').read_text())
def run(name,cmd):
 cmd=[str(x).replace('{case}',str(P)).replace('{out}',str(out)) for x in cmd];r=subprocess.run(cmd,capture_output=True,text=True,timeout=600)
 (out/(name+'.json')).write_text(json.dumps(dict(command=cmd,exit=r.returncode,stdout=r.stdout,stderr=r.stderr),indent=2))
 if r.returncode:print(r.stderr);raise SystemExit(r.returncode)
run('front',m['profiles']['hip-o3']['argv'])
s=(out/'start.ll').read_text().replace('"amdgpu-flat-work-group-size"="1,256"','"amdgpu-flat-work-group-size"="1,1024"');(out/'input.ll').write_text(s)
for name in ['post','llc','link-hsaco']:run(name,json.loads((P/'recipes'/(name+'.json')).read_text()))
for name,path in [('new',out/'kernel.hsaco'),('old',Path('/home/chh/divergence-strategy-search/explorations/sw2d-flux-20261104/build/v1/natural/UNFUSED/kernel.hsaco'))]:run(name,['/opt/rocm/llvm/bin/llvm-objcopy','--dump-section','.text='+str(out/(name+'.text')),path])
equal=(out/'new.text').read_bytes()==(out/'old.text').read_bytes();(out/'comparison.json').write_text(json.dumps({'text_byte_equal':equal}))
assert equal,'Rebuilt baseline differs from retained natural baseline'
