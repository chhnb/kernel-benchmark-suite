#!/usr/bin/env python3
"""Build real DP1 capsule replay and execute all generated A/B combinations."""
import os,shlex,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
env=dict(os.environ)
env['LD_LIBRARY_PATH']=str(root/'build/llvm12-jammy/usr/lib/x86_64-linux-gnu')+':'+env.get('LD_LIBRARY_PATH','')
lc=env.get('LLVM_CONFIG',str(root/'build/llvm12-jammy/usr/bin/llvm-config-12'))
def flags(*args):return shlex.split(subprocess.check_output([lc,*args],text=True,env=env))
objects=['ir_pressure','fusion_search','logical_region_state','RegionAnalyzer','RegionMelder','RegionReplicator','CFMelderUtils','InstructionMatch']
with tempfile.TemporaryDirectory(prefix='b2b-capsule-') as temp:
 tmp=Path(temp);exe=tmp/'test'
 command=[env.get('CXX','c++'),*flags('--cxxflags'),'-std=c++17','-fexceptions','-UNDEBUG','-O1','-Wno-deprecated-declarations','-I'+str(root/'tools'),str(root/'tests/fusion-search/check-b2b-capsule.cpp'),*[str(root/'build/llvm24-tti'/f'{o}.o') for o in objects],*flags('--ldflags','--link-shared','--libs','--system-libs'),'-o',str(exe)]
 subprocess.run(command,env=env,check=True)
 subprocess.run([str(exe),str(tmp)],env=env,check=True)
 clang=Path(subprocess.check_output([lc,'--bindir'],text=True,env=env).strip())/'clang'
 harness=tmp/'main.c';harness.write_text('''#include <stdio.h>
#include <stdint.h>
extern int32_t f(_Bool,_Bool,int32_t,int32_t);
int main(void){for(int p=0;p<2;p++)for(int q=0;q<2;q++)
for(int x=-20;x<=20;x++)for(int y=-20;y<=20;y++)
printf("%d\\n",f(p,q,x,y));return 0;}
''')
 def run(ir):
  binary=tmp/'execute'
  subprocess.run([str(clang),'-O0',str(ir),str(harness),'-o',str(binary)],env=env,check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
  return subprocess.check_output([str(binary)],env=env)
 expected=run(tmp/'baseline.ll');products=sorted(tmp.glob('product-*.ll'));assert products
 for ir in products:assert run(ir)==expected,ir.name
 print('PASS CPU equivalence:',len(products),'cached A/B combinations;',4*41*41,'inputs each')
