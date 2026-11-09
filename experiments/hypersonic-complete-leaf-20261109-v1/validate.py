from pathlib import Path
import subprocess,json,hashlib
s=Path('/home/chh/kernel-benchmark-suite');p=Path(__file__).resolve().parent
out=p/'validation';out.mkdir(exist_ok=False)
roles={'baseline':p/'L0-L1-pair/baseline.hsaco','L0-L1':p/'L0-L1-pair/variant.hsaco','L1-L2':p/'L1-L2-pair/variant.hsaco'}
rows=[]
for role,binary in roles.items():
 cmd=[str(s/'bench'),'hypersonic','validate','--kernel',str(binary),'--out',str(out/role),'--warmup','3','--repeat','15']
 row={'role':role,'command':cmd,'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest()}
 rows.append(row);(p/'validation.json').write_text(json.dumps(rows,indent=2))
 row['exit']=subprocess.run(cmd,cwd=s).returncode
 (p/'validation.json').write_text(json.dumps(rows,indent=2))
 if row['exit']:raise SystemExit(row['exit'])
 receipt=json.loads((out/role/'accepted.json').read_text());assert receipt['passed']
 row['passed']=True;row['input_snapshot']=receipt['input_snapshot']
 (p/'validation.json').write_text(json.dumps(rows,indent=2))
print('all three variants passed full GPU validation')
