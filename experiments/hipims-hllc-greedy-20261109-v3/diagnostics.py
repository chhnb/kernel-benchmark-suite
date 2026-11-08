from pathlib import Path
import subprocess,json
p=Path(__file__).resolve().parent;t=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin');plan=[]
for n in [17,18,22]:
 ir=p/f'scoped-cfg/trial-{n}/after.ll';role=f'forced_{n}'
 for stage,cmd in [('opt',[t/'opt',ir,'-O3','-verify','-S','-o',p/(role+'-final.ll')]),('llc',[t/'llc',p/(role+'-final.ll'),'-O3','-march=nvptx64','-mcpu=sm_70','-mattr=+ptx70','-o',p/(role+'.ptx')]),('ptxas',['/usr/local/cuda/bin/ptxas','-O3','-arch=sm_70','-v',p/(role+'.ptx'),'-o',p/(role+'.cubin')])]:
  plan.append({'role':role,'stage':stage,'argv':list(map(str,cmd))})
  with (p/(role+'-'+stage+'.stdout')).open('w') as o,(p/(role+'-'+stage+'.stderr')).open('w') as e:subprocess.run(cmd,stdout=o,stderr=e,check=True)
(p/'diagnostic-build-plan.json').write_text(json.dumps(plan,indent=2))
