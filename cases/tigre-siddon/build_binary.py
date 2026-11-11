from pathlib import Path
import sys,json,subprocess
P=Path(__file__).resolve().parent;D=Path(sys.argv[1]);m=json.loads((P/'case.json').read_text())
def run(n,c):
 r=subprocess.run(c,capture_output=True,text=True);(D/(n+'.json')).write_text(json.dumps(dict(command=c,exit=r.returncode,stdout=r.stdout,stderr=r.stderr),indent=2));r.check_returncode()
run('frontend',[x.replace('{case}',str(P)).replace('{out}',str(D)) for x in m['profiles']['hip-o3']['argv']])
run('post',['/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt',str(D/'start.ll'),'-simplifycfg','-O3','-mem2reg','-verify','-S','-o',str(D/'post.ll')])
run('llc',['/opt/rocm/llvm/bin/llc',str(D/'post.ll'),'-O3','-mtriple=amdgcn-amd-amdhsa','-mcpu=gfx906','-relocation-model=pic','-filetype=obj','-o',str(D/'kernel.o')])
run('link',['/opt/rocm/llvm/bin/ld.lld','-shared',str(D/'kernel.o'),'-o',str(D/'kernel.hsaco')])
