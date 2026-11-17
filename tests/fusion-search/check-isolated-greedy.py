#!/usr/bin/env python3
"""Full-rescore versus whole-trial reuse under the explicit isolated policy."""
import argparse,contextlib,json,os,shlex,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path);ap.add_argument('--external',action='store_true');ap.add_argument('--memory',action='store_true');ap.add_argument('--multi',action='store_true');args=ap.parse_args()
env=dict(os.environ)
env['LD_LIBRARY_PATH']=str(root/'build/llvm12-jammy/usr/lib/x86_64-linux-gnu')+':'+env.get('LD_LIBRARY_PATH','')
env.setdefault('LLVM24_LIBDIR',str(root/'build/llvm24-pinned/lib'))
lc=env.get('LLVM_CONFIG',str(root/'build/llvm12-jammy/usr/bin/llvm-config-12'))
def flags(*args):return shlex.split(subprocess.check_output([lc,*args],text=True,env=env))
objects=['ir_pressure','fusion_search','logical_region_state','RegionAnalyzer','RegionMelder','RegionReplicator','CFMelderUtils','InstructionMatch']
if args.out:args.out.mkdir(parents=True,exist_ok=False)
with contextlib.ExitStack() as stack:
 tmp=args.out.resolve() if args.out else Path(stack.enter_context(tempfile.TemporaryDirectory(prefix='isolated-greedy-')))
 exe=tmp/'test'
 command=[env.get('CXX','c++'),*flags('--cxxflags'),'-std=c++17','-fexceptions','-UNDEBUG','-O1','-Wno-deprecated-declarations','-I'+str(root/'tools'),str(root/'tests/fusion-search/check-isolated-greedy.cpp'),*[str(root/'build/llvm24-tti'/f'{o}.o') for o in objects],*flags('--ldflags','--link-shared','--libs','--system-libs'),'-o',str(exe)]
 subprocess.run(command,env=env,check=True)
 worker=root/'tools/run-llvm24-tti'
 output=subprocess.check_output([str(exe),str(tmp),str(worker),str(root/'tests/fusion-search/commit-score-context.ll')]+(['multi'] if args.multi else ['memory'] if args.memory else ['external'] if args.external else []),env=env,text=True)
 (tmp/'run.log').write_text(output);print(output,end='')
 def cost(ir):
  result=json.loads(subprocess.check_output([str(worker),str(ir),'f'],env=env,text=True))
  assert result['unknown']==0 and result['source_revision']=='6be16f356d3e',result
  return result['cost']
 full=[cost(tmp/'baseline.ll')]+[cost(tmp/f'full-{i}.ll') for i in range(2)]
 cached=[cost(tmp/'baseline.ll')]+[cost(tmp/f'cached-{i}.ll') for i in range(2)]
 assert full==cached,(full,cached)
 if not args.memory and not args.multi:assert full==([65,45,25] if args.external else [63,43,23]),full
 elif args.memory:assert [full[i]-full[i+1] for i in range(2)]==[20,20],full
 else:assert all(full[i]>full[i+1] for i in range(2)),full
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
 assert run(tmp/'cpu-baseline.ll')==run(tmp/'cpu-final.ll')
 # Separate old-policy diagnostic: never assert equivalence to global cleanup.
 search=root/'build/llvm24-tti/fusion-search-llvm24'
 subprocess.run([str(search),'--ir',str(tmp/'baseline.ll'),'--function','f','--split','B0','--left','B1','--right','B2','--b2b-strategy','dp1','--cleanup','darm-cfg-dce-instcombine','--tti-worker',str(worker),'--debug-dir',str(tmp/'legacy'),'--out',str(tmp/'legacy.ll')],env=env,check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 legacy=json.loads((tmp/'legacy/trial-0/trial.json').read_text())['score_result']
 subprocess.run([str(search),'--ir',str(tmp/'legacy.ll'),'--function','f','--split','B0','--left','B1','--right','B2','--b2b-strategy','dp1','--cleanup','darm-cfg-dce-instcombine','--tti-worker',str(worker),'--debug-dir',str(tmp/'legacy-second'),'--out',str(tmp/'legacy-second.ll')],env=env,check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 legacySecond=json.loads((tmp/'legacy-second/trial-0/trial.json').read_text())['score_result']
 # Compare scalar IR after stripping only internal identity metadata and
 # symbol names. A mismatch remains evidence, never a changed golden value.
 import re
 opt=Path(subprocess.check_output([lc,'--bindir'],text=True,env=env).strip())/'opt'
 def canonical(path):
  text=path.read_text()
  text=re.sub(r', !fusion.incremental.identity ![0-9]+','',text)
  text='\n'.join(line for line in text.splitlines() if not line.startswith('!'))+'\n'
  clean=tmp/'canonical-input.ll';clean.write_text(text)
  out=subprocess.check_output([str(opt),'-strip','-S',str(clean),'-o','-'],env=env,text=True)
  return '\n'.join(line for line in out.splitlines() if not line.startswith('; ModuleID'))
 sameLegacy=canonical(tmp/'legacy-second.ll')==canonical(tmp/'cached-1.ll')
 report=dict(multiple_outputs=args.multi,external_memory_context=args.memory,external_ssa_inputs=args.external,legacy_second_trial=legacySecond['metrics'],legacy_final_alpha_equal=sameLegacy,isolated_full_costs=full,isolated_cached_costs=cached,cpu_inputs=6724,quote_cache='off',legacy_cleanup_first_trial=legacy['metrics'],legacy_status=legacy['status'],default_driver_changed=False)
 (tmp/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 print('PASS isolated full/cached TTI:',full,'and 6724 CPU inputs')
 print('Separate legacy cleanup steps:',legacy['metrics']['work_before'],legacy['metrics']['work_after'],legacySecond['metrics']['work_after'],'final alpha-equal:',sameLegacy)
