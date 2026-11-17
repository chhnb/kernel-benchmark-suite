#!/usr/bin/env python3
"""Check complete frozen runs, every commit, and fail-closed quote audit logs."""
import argparse,hashlib,json
from pathlib import Path
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('reference',type=Path)
parser.add_argument('candidate',type=Path)
args=parser.parse_args()
def digest(path):
 return hashlib.sha256(b'\n'.join(line for line in Path(path).read_bytes().splitlines() if not line.startswith(b'; ModuleID ='))).hexdigest()
def chain(summary):
 result=[]
 for step in summary['rounds']:
  selected=step.get('selected')
  if selected:
   chosen=next(a for a in step['attempts'] if a['directory']==selected)
   result.append((chosen.get('candidate'),step['selected_cost'],digest(selected+'/fused.ll')))
 return result
rows=json.loads((args.candidate/'results.json').read_text())
reference=json.loads((args.reference/'results.json').read_text())
assert {r['case'] for r in rows}=={r['case'] for r in reference},'case coverage differs'
assert all(r['passed'] for r in rows),'candidate has failures'
checked=[]
for row in rows:
 case=row['case']
 old=json.loads((args.reference/case/'summary.json').read_text())
 new=json.loads((args.candidate/case/'summary.json').read_text())
 assert new['status']=='completed',case
 assert chain(old)==chain(new),(case,'commit sequence or intermediate IR changed')
 for log in (args.candidate/case).glob('trial-*/stderr'):
  assert 'tti_quote_' not in log.read_text(errors='replace'),str(log)
 checked.append({'case':case,'commits':new['commits'],'tti':new['final_cost'],'identical_commit_chain':True})
(args.candidate/'commit-chain-comparison.json').write_text(json.dumps(checked,indent=2)+'\n')
print('PASS complete commit chains and quote audits:',len(checked),'cases')
