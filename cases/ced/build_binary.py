from pathlib import Path
import sys,json,subprocess
C=Path(__file__).resolve().parent;O=Path(sys.argv[1]);T=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin')
def run(tag,cmd):
 cmd=list(map(str,cmd));(O/(tag+'.argv.json')).write_text(json.dumps(cmd,indent=2))
 with (O/(tag+'.stdout')).open('w') as out,(O/(tag+'.stderr')).open('w') as err:subprocess.run(cmd,stdout=out,stderr=err,check=True,timeout=180)
run('frontend',[x.replace('{case}',str(C)).replace('{out}',str(O)) for x in json.loads((C/'recipes/frontend.json').read_text())])
run('finalize',[T/'opt',O/'native.ll','-O3','-verify-each','-S','-o',O/'post.ll'])
run('llc',[T/'llc',O/'post.ll','-O3','-mtriple=amdgcn-amd-amdhsa','-mcpu=gfx906','-mattr=+sram-ecc,-xnack','-filetype=obj','-o',O/'kernel.o'])
run('link',['/opt/rocm/llvm/bin/ld.lld','-shared',O/'kernel.o','-o',O/'kernel.hsaco'])
