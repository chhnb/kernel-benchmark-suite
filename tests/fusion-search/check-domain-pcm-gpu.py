#!/usr/bin/env python3
"""PCM256 exact GPU output comparison against frozen baseline and CPU sort."""
import argparse,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("baseline",type=Path);p.add_argument("candidate",type=Path);p.add_argument("--out",type=Path,required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
rocm=Path("/opt/rocm-6.3.3");llvm=root/"build/llvm12-jammy/usr/lib/llvm-12/bin"
env=dict(os.environ,LD_LIBRARY_PATH=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu")+":"+str(rocm/"lib"))
for name,ir in [("baseline",a.baseline),("candidate",a.candidate)]:
 subprocess.run([str(llvm/"opt"),"-verify","-disable-output",str(ir.resolve())],env=env,check=True)
 subprocess.run([str(llvm/"llc"),"-O3","-march=amdgcn","-mcpu=gfx906","-mattr=+sramecc","-amdhsa-code-object-version=4","-filetype=obj",str(ir.resolve()),"-o",str(a.out/(name+".o"))],env=env,check=True)
 subprocess.run([str(rocm/"llvm/bin/ld.lld"),"-shared",str(a.out/(name+".o")),"-o",str(a.out/(name+".hsaco"))],env=env,check=True)
subprocess.run([str(rocm/"bin/hipcc"),"-O2",str(root/"tests/fusion-search/check-domain-pcm-gpu.cpp"),"-o",str(a.out/"check")],env=env,check=True)
output=subprocess.check_output([str(a.out/"check"),str(a.out/"baseline.hsaco"),str(a.out/"candidate.hsaco")],env=env,text=True)
(a.out/"results.log").write_text(output)
assert output.count("PASS seed ")==4
(a.out/"result.json").write_text(json.dumps(dict(baseline_sha256=hashlib.sha256(a.baseline.read_bytes()).hexdigest(),candidate_sha256=hashlib.sha256(a.candidate.read_bytes()).hexdigest(),seeds=4,elements_per_seed=131072,baseline_and_cpu_sort_exact=True),indent=2))
print(output,end="")
