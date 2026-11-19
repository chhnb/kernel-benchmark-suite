#!/usr/bin/env python3
"""Compare ordered/legacy scheduling without assuming identical merge order."""
import argparse,json,os,re,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("--driver",type=Path,required=True);p.add_argument("--out",type=Path,required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
env=dict(os.environ,LD_LIBRARY_PATH=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu"),LLVM24_LIBDIR=str(root/"build/llvm24-pinned/lib"))
bindir=root/"build/llvm12-jammy/usr/bin"
source=root/"tests/fusion-search/commit-score-context.ll"
harness=a.out/"main.c"
harness.write_text("""#include <stdio.h>
extern int choose(_Bool,_Bool,int,int);extern int A,B,C;
int main(){for(int p=0;p<2;p++)for(int q=0;q<2;q++)for(int x=-20;x<=20;x++)for(int y=-20;y<=20;y++){A=13;B=-9;C=7;int z=choose(p,q,x,y);printf(\"%d %d %d %d\\n\",z,A,B,C);}return 0;}
""")
def execute(ir,label):
 text=ir.read_text();text=re.sub(r"^target (triple|datalayout) = .*\n","",text,flags=re.M)
 text=text.replace("addrspace(1)","");text=re.sub(r"\"target-(cpu|features)\"=\"[^\"]*\"","",text)
 for empty in re.findall(r"attributes #(\d+) = \{\s*\}",text):
  text=re.sub(r"attributes #"+empty+r" = \{\s*\}\n","",text)
  text=re.sub(r"#"+empty+r"\b","",text)
 cpu=a.out/(label+".ll");cpu.write_text(text);binary=a.out/(label+".exe")
 subprocess.run([str(bindir/"clang-12"),"-O0",str(cpu),str(harness),"-o",str(binary)],env=env,check=True,capture_output=True)
 return subprocess.check_output([str(binary)],env=env)
expected=execute(source,"baseline");rows=[]
for mode in ["legacy","ordered"]:
 out=a.out/mode;start=time.monotonic()
 with (a.out/(mode+".stdout")).open("w") as stdout,(a.out/(mode+".stderr")).open("w") as stderr:
  subprocess.run([str(a.driver.resolve()),str(source),"choose",str(root),str(out),"--domain-schedule",mode],env=env,check=True,stdout=stdout,stderr=stderr)
 s=json.loads((out/"summary.json").read_text());assert s["status"]=="completed"
 paths=[Path(r["selected"])/"fused.ll" for r in s["rounds"] if r.get("selected")]+[out/"final.ll"]
 for n,ir in enumerate(paths):
  subprocess.run([str(bindir/"opt-12"),"-verify","-disable-output",str(ir)],env=env,check=True,capture_output=True)
  assert execute(ir,mode+str(n))==expected,(mode,n,"CPU memory/output mismatch")
 rows.append(dict(mode=mode,seconds=time.monotonic()-start,commits=s["commits"],trials=s["trials"],tti=s["final_cost"],verified_products=len(paths),cpu_inputs=6724))
(a.out/"results.json").write_text(json.dumps(rows,indent=2));print(json.dumps(rows,indent=2))
