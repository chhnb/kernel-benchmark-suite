from pathlib import Path
import json,subprocess
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
cmd=json.loads((s/'results/hypersonic-hip-llvm12-ir-v1/command.json').read_text());cmd[cmd.index('-o')+1]=str(p/'frontend.ll');cmd+=['-disable-llvm-passes'];(p/'frontend-command.json').write_text(json.dumps(cmd,indent=2))
with (p/'frontend.stderr').open('w') as f:subprocess.run(cmd,stderr=f,check=True)
subprocess.run(['bash',p/'build.sh'],check=True)
for level in [2,3]:
 for skip in [0,1]:
  name=f'O{level}-'+('no-jt' if skip else 'normal')
  cmd=[s/'build/llvm24-tti/pipeline-without-jt','--input',p/'frontend.ll','--out',p/(name+'.ll'),'--log',p/(name+'-passes.tsv'),'--level',str(level),'--skip-jump-threading='+str(skip),'-amdgpu-early-inline-all=true','-amdgpu-function-calls=false']
  with (p/(name+'.stdout')).open('w') as a,(p/(name+'.stderr')).open('w') as b:subprocess.run(cmd,stdout=a,stderr=b,check=True)
  with (p/(name+'-inventory.json')).open('w') as f:subprocess.run([s/'build/region-inventory/region-inventory',p/(name+'.ll'),'face_kernel'],stdout=f,check=True)

for level in [2,3]:
 a=(p/f'O{level}-normal-passes.tsv').read_text().splitlines()
 b=(p/f'O{level}-no-jt-passes.tsv').read_text().splitlines()
 assert a==[line.replace('SKIP\t','KEEP\t') for line in b]
 assert sum(line.startswith('SKIP\t') for line in b)==2
