from pathlib import Path
import json,subprocess
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent/'o0';p.mkdir(exist_ok=False)
original=json.loads((s/'results/hypersonic-hip-llvm12-ir-v1/command.json').read_text());cmd=[('-O0' if a=='-O2' else a) for a in original if a not in ['-vectorize-loops','-vectorize-slp']];cmd[cmd.index('-o')+1]=str(p/'o0.ll');commands=[cmd]
with (p/'compile.stderr').open('w') as f:subprocess.run(cmd,stderr=f,check=True)
opt='/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt'
for name,passes in [('mem2reg',['-always-inline','-mem2reg']),('sroa',['-always-inline','-sroa','-mem2reg'])]:
 cmd=[opt,str(p/'o0.ll'),*passes,'-verify','-S','-o',str(p/(name+'.ll'))];commands.append(cmd)
 with (p/(name+'.stderr')).open('w') as f:subprocess.run(cmd,stderr=f,check=True)
for name in ['o0','mem2reg','sroa']:
 cmd=[str(s/'build/region-inventory/region-inventory'),str(p/(name+'.ll')),'face_kernel'];commands.append(cmd)
 with (p/(name+'-inventory.json')).open('w') as f:subprocess.run(cmd,stdout=f,check=True)
(p/'commands.json').write_text(json.dumps(commands,indent=2))
