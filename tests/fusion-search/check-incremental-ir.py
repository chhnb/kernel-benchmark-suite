#!/usr/bin/env python3
"""Exercise opt-in IR lineage and write/read boundary mechanisms, not score reuse."""
import os,shlex,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
env=dict(os.environ)
env['LD_LIBRARY_PATH']=str(root/'build/llvm12-jammy/usr/lib/x86_64-linux-gnu')+':'+env.get('LD_LIBRARY_PATH','')
lc=env.get('LLVM_CONFIG',str(root/'build/llvm12-jammy/usr/bin/llvm-config-12'))
def flags(*args):return shlex.split(subprocess.check_output([lc,*args],text=True,env=env))
with tempfile.TemporaryDirectory(prefix='incremental-ir-') as tmp:
 for case in ['check-ir-identity','check-ir-snapshot','check-b2b-unit','check-metadata-graph']:
  exe=str(Path(tmp)/case)
  command=[env.get('CXX','c++'),*flags('--cxxflags'),'-std=c++17','-fexceptions','-UNDEBUG','-O1','-Wno-deprecated-declarations','-I'+str(root/'tools'),str(root/'tests/fusion-search'/f'{case}.cpp'),*flags('--ldflags','--libs','core','asmparser','transformutils','--system-libs'),'-o',exe]
  subprocess.run(command,env=env,check=True)
  subprocess.run([exe],env=env,check=True)
