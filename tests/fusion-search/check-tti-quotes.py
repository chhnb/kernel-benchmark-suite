#!/usr/bin/env python3
"""Compare restricted quote reuse to the pinned worker, including cleanup context."""
import json,os,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
fixtures=Path(__file__).resolve().parent
source=(fixtures/"tti-quote-scalar.ll").read_text()
memory=(fixtures/"tti-quote-memory.ll").read_text()
cases=[("scalar",source,"B0","B1","B2"),
       ("other_cpu",source.replace("gfx906","gfx900"),"B0","B1","B2"),
       ("forwarded",memory.replace("* @C","* @A").replace("* @D","* @B"),"B1","B2","B3"),
       ("unrelated",memory,"B1","B2","B3"),
       ("align",memory.replace("align 4","align 16"),"B1","B2","B3")]
env=os.environ.copy()
env["LLVM24_LIBDIR"]=str(root/"build/llvm24-pinned/lib")
env["LD_LIBRARY_PATH"]=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu")+":"+env.get("LD_LIBRARY_PATH", "")
with tempfile.TemporaryDirectory() as tmp:
 base=Path(tmp);hits=0
 for name,source,split,left,right in cases:
  ir=base/(name+".ll");ir.write_text(source);outputs=[]
  for mode in ["off","audit","on"]:
   dest=base/(name+"-"+mode)
   cmd=[root/"build/llvm24-tti/fusion-search-llvm24","--ir",ir,"--function","choose","--split",split,"--left",left,"--right",right,"--b2b-strategy","anchor","--tti-worker",root/"tools/run-llvm24-tti","--debug-dir",dest,"--out",str(dest)+".ll","--tti-quote-cache",mode]
   p=subprocess.run(cmd,capture_output=True,text=True,env=env)
   assert p.returncode==0 and "score unsupported" not in p.stderr,(name,mode,p.stdout,p.stderr)
   trial=json.loads((dest/"trial-0/trial.json").read_text())
   outputs.append((Path(str(dest)+".ll").read_bytes(),trial["score_result"]))
   stats=json.loads((dest/"tti-quote-cache.json").read_text())
   if mode=="on":hits+=stats["hits"]
   if name=="other_cpu":assert stats["quotes"]==0 and stats["hits"]==0,stats
  assert outputs[0]==outputs[1]==outputs[2],name
 assert hits>0,"test never exercised quotation reuse"
 print("PASS TTI quotes: exact IR and scores for scalar, CPU fallback, upstream memory contexts and alignment; hits="+str(hits))
