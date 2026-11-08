#!/usr/bin/env python3
"""Native differential and independent-oracle check for the loop fixture."""
import subprocess,sys
from pathlib import Path
run=Path(sys.argv[1]).resolve()
clang='/home/chh/region-fusion-lab/toolchains/llvm12/amd-bootstrap/bin/clang'
for side in ('before','after'):
    source=run/('loop-'+side+'.ll')
    named=run/('loop-'+side+'-named.ll')
    named.write_text(source.read_text().replace('@choose(', '@'+side+'('))
    subprocess.run([clang,'-O0','-c',str(named),'-o',str(run/(side+'.o'))],check=True)
harness=run/'loop-compare.cpp'
harness.write_text('''#include <cstdio>
extern "C" int before(int,int,int);
extern "C" int after(int,int,int);
int main(){int count=0;for(int x=-3;x<=3;++x)for(int side=-2;side<=3;++side)for(int n=-2;n<=64;++n){
 int expected=0;for(int i=0;i<n;++i)expected+=x+(((i+side)&1)==0?7:11);
 int b=before(x,side,n),a=after(x,side,n);
 if(b!=expected||a!=expected){std::fprintf(stderr,"mismatch x=%d side=%d n=%d before=%d after=%d expected=%d\\n",x,side,n,b,a,expected);return 1;}++count;
}std::printf("PASS %d loop inputs against independent oracle\\n",count);return 0;}
''')
subprocess.run(['g++',str(harness),str(run/'before.o'),str(run/'after.o'),'-o',str(run/'loop-compare')],check=True)
subprocess.run([str(run/'loop-compare')],check=True)
