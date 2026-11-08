#!/usr/bin/env python3
"""Regression: replicated branch-only blocks must not speculate guarded loads."""
import argparse,json,resource,subprocess,sys,time
from pathlib import Path

root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--admitted',action='store_true');a=p.parse_args()
if not a.admitted:
    sys.exit(subprocess.call([sys.executable,'/home/chh/region-fusion-lab/work/run-cpu.py','guarded-load-'+str(time.time_ns()),sys.executable,str(Path(__file__).resolve()),'--out',str(a.out.resolve()),'--admitted']))
resource.setrlimit(resource.RLIMIT_CORE,(0,0))
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
clang='/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/clang'
fixture=(Path(__file__).parent/'guarded-load.ll').read_text()
driver=out/'driver.cpp'
driver.write_text('''#include <sys/mman.h>
#include <unistd.h>
extern "C" int choose(bool, char*, int*);
int main(){long n=sysconf(_SC_PAGESIZE);char*p=(char*)mmap(nullptr,n,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(p==MAP_FAILED)return 2;
for(int value=-100;value<=100;++value){if(choose(true,p,&value)!=value)return 3;for(char mask=0;mask<2;++mask)if(choose(false,&mask,&value)!=(mask?-value:value))return 4;}
munmap(p,n);return 0;}
''')
records=[]
for swapped in [False,True]:
    d=out/('swapped' if swapped else 'normal');d.mkdir()
    text=fixture
    if swapped:
        text=text.replace('br i1 %outside, label %left, label %right','%inside = xor i1 %outside, true\n br i1 %inside, label %right, label %left')
    source=d/'input.ll';source.write_text(text)
    subprocess.run([str(root/'build/fusion-search/fusion-search'),'--ir',str(source),'--function','choose','--out',str(d/'output.ll'),'--split','B0','--left','B3' if swapped else 'B1','--right','B1' if swapped else 'B3','--debug-dir',str(d/'debug')],check=True,capture_output=True)
    trial=json.loads((d/'debug/trial-0/trial.json').read_text())
    assert trial['valid'] and trial['replication_required']
    for stage,ir in [('baseline',source),('raw',d/'debug/trial-0/after-raw.ll'),('cleaned',d/'debug/trial-0/after.ll')]:
        exe=d/stage
        subprocess.run([clang,'-O2',str(ir),str(driver),'-o',str(exe)],check=True,capture_output=True)
        result=subprocess.run([str(exe)],capture_output=True)
        records.append(dict(swapped=swapped,stage=stage,exit=result.returncode,cases=603))
        (out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
        assert result.returncode==0,records[-1]
print('PASS 3618 guarded and normal load executions across both orientations and raw/cleaned IR')
