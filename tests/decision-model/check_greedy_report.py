import json,sys
from pathlib import Path
p=Path(sys.argv[1]);s=json.loads(p.read_text());assert s['status']=='completed';cost=s['initial_cost'];commits=0;trials=0
for row in s['rounds']:
 assert row['parent_cost']==cost
 for a in row['attempts']:
  trial=Path(a['directory'])/'trial.json'
  if trial.exists():
   actual=json.loads(trial.read_text())
   if 'left' in actual:
    assert actual['decision']==row['decision'] and actual['left']==a['left'] and actual['right']==a['right'], ('candidate identity mismatch',a['directory'])
  if 'cost' in a:assert trial.exists() and actual['status']=='verified'

 scored=[a for a in row['attempts'] if 'cost' in a];trials+=len(row['attempts'])
 if row['selected']:
  best=min(a['cost'] for a in scored);assert best<cost and best==row['selected_cost'];selected=next(a for a in scored if a['directory']==row['selected']);assert selected['cost']==best
  assert abs(row['score']-(cost-best)/max(cost,1))<1e-12
  cost=best;commits+=1
 else:assert all(a['cost']>=cost for a in scored)
assert cost==s['final_cost'] and commits==s['commits'] and trials==s['trials']
assert Path(s['final_ir']).is_file()
print(p.parent.name, 'best-positive selection, stopping conditions, scores and commit counts verified')
