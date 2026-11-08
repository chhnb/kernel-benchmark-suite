#!/usr/bin/env python3
"""Independent input-level oracle for the pinned Landau step-5 branch only."""
import argparse,json,struct,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('profile',type=Path);a=p.parse_args();root=a.profile.resolve();m=json.loads((root/'manifest.json').read_text())
assert m['parent_hash']=='662c234256aa366f635db48674a674dbd95c3f3d' and m['candidate']=='evaluate:B23:B24:B37'
assert hashlib.sha1((root/'parent.ll').read_bytes()).hexdigest()==m['parent_hash']
rows=[]
for i,item in enumerate(m['inputs']):
 spec=Path(item['original']);lines=[x.split() for x in spec.read_text().splitlines()]
 assert ['block','256','1','1'] in lines and ['grid','257','1','1'] in lines
 path=spec.parent/next(x[2] for x in lines if x[:2]==['buffer','input']);raw=path.read_bytes();values=struct.unpack('<'+'d'*(len(raw)//8),raw)
 assert len(values)==65539 and all(0<x<1 for x in values)
 # Parent B23 reached when ilogb(p) <= -9. True iff ilogb(p) > -17.
 # For these finite positive inputs: p < 2^-8, then p >= 2^-16.
 counts=[0]*4
 for k in range(0,len(values),64):
  active=[x for x in values[k:k+64] if x<2**-8]
  if active:
   t=any(x>=2**-16 for x in active);f=any(x<2**-16 for x in active)
   for j,v in enumerate([1,t,f,t and f]):counts[j]+=v
 actual=list(struct.unpack('<4Q',(root/f'capture-{i}/output/0/wave-profile.bin').read_bytes()))
 assert counts==actual,(counts,actual)
 rows.append(dict(input=str(spec),expected=counts,observed=actual,passed=True))
print(json.dumps(dict(schema='landau-step5-wave-oracle-v0',inputs=rows),indent=2))
