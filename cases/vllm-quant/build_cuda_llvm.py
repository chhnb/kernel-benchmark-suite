from pathlib import Path
import subprocess,json,sys
P=Path(__file__).resolve().parent;out=Path(sys.argv[1]);T=Path('/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin')
commands=[
[T/'clang','-std=c++17','-x','cuda','--cuda-device-only','-nocudainc','-nocudalib','--cuda-gpu-arch=sm_70','-ffp-contract=off','-O3','-Xclang','-mlink-builtin-bitcode','-Xclang','/usr/local/cuda-12.9/nvvm/libdevice/libdevice.10.bc','-S','-emit-llvm',P/'source/llvm-cache.cu','-o',out/'start.ll'],
[T/'llc','-O3','-march=nvptx64','-mcpu=sm_70',out/'start.ll','-o',out/'baseline.ptx'],
['/usr/local/cuda-12.9/bin/ptxas','-arch=sm_70',out/'baseline.ptx','-o',out/'llvm-cache.cubin']]
for i,cmd in enumerate(commands):
 cmd=list(map(str,cmd));r=subprocess.run(cmd,capture_output=True,text=True,timeout=600)
 (out/f'step-{i}.json').write_text(json.dumps(dict(command=cmd,exit=r.returncode,stdout=r.stdout,stderr=r.stderr),indent=2))
 if r.returncode:raise SystemExit(r.returncode)
