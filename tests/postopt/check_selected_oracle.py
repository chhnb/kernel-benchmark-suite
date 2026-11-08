#!/usr/bin/env python3
import argparse,json,struct,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('capture',type=Path);a=p.parse_args();root=a.capture.resolve();m=json.loads((root/'manifest.json').read_text())
assert m['parent_hash']=='662c234256aa366f635db48674a674dbd95c3f3d' and m['candidate']=='evaluate:B23:B24:B37' and m['event_kind']=='selected_block_union'
assert hashlib.sha1((root/'parent.ll').read_bytes()).hexdigest()==m['parent_hash']
rows=[]
for i,item in enumerate(m['inputs']):
 spec=Path(item['original']);lines=[x.split() for x in spec.read_text().splitlines()];assert ['block','256','1','1'] in lines and ['grid','257','1','1'] in lines
 raw=(spec.parent/next(x[2] for x in lines if x[:2]==['buffer','input'])).read_bytes();v=struct.unpack('<'+'d'*(len(raw)//8),raw);assert len(v)==65539 and all(0<x<1 for x in v)
 # B24: -16 <= ilogb(p) <= -9. B37: -64 <= ilogb(p) <= -17.
 # The union excludes the deeper false paths reached by p < 2^-64.
 counts=[0]*4
 for k in range(0,len(v),64):
  t=any(2**-16<=x<2**-8 for x in v[k:k+64]);f=any(2**-64<=x<2**-16 for x in v[k:k+64])
  for j,z in enumerate([t or f,t,f,t and f]):counts[j]+=z
 actual=list(struct.unpack('<4Q',(root/f'capture-{i}/output/0/wave-profile.bin').read_bytes()));assert actual==counts,(actual,counts)
 rows.append(dict(input=str(spec),expected=counts,observed=actual,passed=True))
print(json.dumps(dict(schema='landau-step5-selected-block-oracle-v0',inputs=rows),indent=2))
