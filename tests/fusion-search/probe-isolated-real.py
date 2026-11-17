#!/usr/bin/env python3
"""Frozen-input diagnostic; every trial is scored, never authorizes reuse."""
import argparse,gzip,hashlib,json,os,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument("--case",required=True);p.add_argument("--greedy",action="store_true");p.add_argument("--out",type=Path,required=True);p.add_argument("--tool",type=Path,required=True);a=p.parse_args()
b=root/"regression/greedy-v1";c=next(c for c in json.loads((b/"manifest.json").read_text())["cases"] if c["case"]==a.case)
data=gzip.decompress((b/c["input"]).read_bytes());assert hashlib.sha256(data).hexdigest()==c["input_sha256"]
a.out.mkdir(parents=True,exist_ok=False);a.out=a.out.resolve();ir=a.out/"input.ll";ir.write_bytes(data)
env=dict(os.environ);env["LD_LIBRARY_PATH"]=str(root/"build/llvm12-jammy/usr/lib/x86_64-linux-gnu")+":"+env.get("LD_LIBRARY_PATH","");env.setdefault("LLVM24_LIBDIR",str(root/"build/llvm24-pinned/lib"))
r=subprocess.run([str(a.tool.resolve()),str(ir),c["function"],str(root/"tools/run-llvm24-tti"),str(a.out)]+(["greedy"] if a.greedy else []),env=env,text=True,capture_output=True)
(a.out/"stderr.log").write_text(r.stderr);r.check_returncode();rows=json.loads(r.stdout);(a.out/"layouts.json").write_text(r.stdout)
if a.greedy:print(json.dumps(rows));raise SystemExit
print(json.dumps(dict(case=a.case,layouts=len(rows),costs=[[r["before"],r["after"]] for r in rows],reuse_enabled=False)))
