#!/usr/bin/env python3
"""Real vLLM eight-leaf fixture: tie order, every-step IR, and CPU bit patterns."""
import argparse,json,os,re,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("--driver",type=Path,required=True);p.add_argument("--out",type=Path,required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
env=dict(os.environ,LD_LIBRARY_PATH=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu"),LLVM24_LIBDIR=str(root/"build/llvm24-pinned/lib"));bin=root/"build/llvm12-jammy/usr/bin";fixture=root/"tests/fusion-search/domain-vllm-quant8.ll"
for mode in ["ordered"]:
 with (a.out/(mode+".stdout")).open("w") as stdout,(a.out/(mode+".stderr")).open("w") as stderr:
  subprocess.run([str(a.driver.resolve()),str(fixture),"quant8",str(root),str(a.out/mode)],env=env,check=True,stdout=stdout,stderr=stderr)
subprocess.run(["python3",str(root/"tests/fusion-search/compare-domain-driver.py"),str(a.out/"ordered"),"--out",str(a.out/"comparison.json")],env=env,check=True,capture_output=True)
subprocess.run(["python3",str(root/"tests/fusion-search/check-ordered-quant8.py"),str(a.out/"ordered")],env=env,check=True,capture_output=True)
paths=[fixture]
for mode in ["ordered"]:
 s=json.loads((a.out/mode/"summary.json").read_text());assert s["commits"]==7 and s["final_cost"]==25
 paths.extend(Path(r["selected"])/"fused.ll" for r in s["rounds"] if r.get("selected"))
expected=None
for i,ir in enumerate(paths):
 text=re.sub(r"^target (triple|datalayout) = .*\n","",ir.read_text(),flags=re.M).replace("\"target-cpu\"=\"gfx906\"","\"target-cpu\"=\"x86-64\"")
 cpu=a.out/("cpu-"+str(i)+".ll");cpu.write_text(text);exe=a.out/("cpu-"+str(i))
 subprocess.run([str(bin/"clang-12"),"-O0",str(cpu),str(root/"tests/fusion-search/domain-quant8-cpu.c"),"-o",str(exe)],env=env,check=True,capture_output=True)
 result=subprocess.check_output([str(exe)],env=env)
 if expected is None:expected=result
 assert result==expected,(i,"bitwise CPU mismatch")
(a.out/"cpu-check.json").write_text(json.dumps(dict(products=len(paths),inputs=100018,bitwise_equal=True),indent=2))
print("PASS 7 ordered steps and 100018 bitwise CPU inputs for every product")
