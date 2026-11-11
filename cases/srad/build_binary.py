from pathlib import Path
import json,subprocess,sys
P=Path(__file__).resolve().parent;out=Path(sys.argv[1])
for name in ['source-clang','source-prep','post','llc','link-hsaco']:
 cmd=[x.replace('{case}',str(P)).replace('{out}',str(out)) for x in json.loads((P/'recipes'/(name+'.json')).read_text())];r=subprocess.run(cmd,capture_output=True,text=True,timeout=600)
 (out/(name+'.json')).write_text(json.dumps(dict(command=cmd,exit=r.returncode,stdout=r.stdout,stderr=r.stderr),indent=2))
 if r.returncode:print(r.stderr);raise SystemExit(r.returncode)
