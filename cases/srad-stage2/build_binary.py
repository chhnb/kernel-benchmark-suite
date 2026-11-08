from pathlib import Path
import sys,json,subprocess
case=Path(__file__).resolve().parent;out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True)
cfg=json.loads((case/'case.json').read_text());t=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin')
commands=[
 [x.replace('{case}',str(case)).replace('{out}',str(out)) for x in cfg['profiles']['hip-o3']['argv']],
 [str(t/'opt'),str(out/'start.ll'),'-always-inline','-O3','-internalize','-internalize-public-api-list=srad_cuda_2','-globaldce','-verify','-S','-o',str(out/'post.ll')],
 [str(t/'opt'),str(out/'post.ll'),'-O3','-verify-each','-S','-o',str(out/'final.ll')],
 [str(t/'llc'),str(out/'final.ll'),'-O3','-mtriple=amdgcn-amd-amdhsa','-mcpu=gfx906','-mattr=+sram-ecc,-xnack','-filetype=obj','-o',str(out/'kernel.o')],
 ['/opt/rocm/llvm/bin/ld.lld','-shared',str(out/'kernel.o'),'-o',str(out/'kernel.hsaco')]]
for i,cmd in enumerate(commands):
 r=subprocess.run(cmd,capture_output=True,text=True)
 (out/('command-'+str(i)+'.json')).write_text(json.dumps({'argv':cmd,'exit':r.returncode,'stdout':r.stdout,'stderr':r.stderr},indent=2))
 r.check_returncode()
