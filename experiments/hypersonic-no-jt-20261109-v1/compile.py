from pathlib import Path
import subprocess
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent;opt='/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/opt'
for role in ['O2-normal','O2-no-jt']:
 subprocess.run([opt,p/(role+'.ll'),'-internalize','-internalize-public-api-list=face_kernel,d_cfg','-globaldce','-verify','-S','-o',p/(role+'-codegen.ll')],check=True)
subprocess.run(['python3',s/'tools/postopt_compile_pair.py','--baseline',p/'O2-normal-codegen.ll','--variant',p/'O2-no-jt-codegen.ll','--case','hypersonic','--function','face_kernel','--scope','normal-vs-no-JT-middle-end-common-final-O3','--out',p/'pair','--admitted'],check=True)
