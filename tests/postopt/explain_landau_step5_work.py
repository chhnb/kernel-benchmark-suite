#!/usr/bin/env python3
"""Pinned diagnostic, not a general scorer or calibrated performance predictor.

The frozen after split computes select(cmp>-17,true,select(cmp>-33,true,cmp>-65));
within original split scope it routes to merged.bb20 iff p >= 2^-64.
Original selected blocks are [2^-16,2^-8) and [2^-64,2^-16).
Thus merged.bb20 executes for exactly the selected-block union. This mapping
is specific to the authenticated IR below; it is not inferred from block names.
"""
import argparse,json,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--provenance-trial',type=Path,required=True);a=p.parse_args()
work=ROOT/'analysis/postopt-step5-block-work-v1';capture=ROOT/'experiments/postopt-step5-selected-profile-v1'
meta=json.loads((work/'report.json').read_text());profile=json.loads((ROOT/'analysis/postopt-step5-selected-profile-v1/portable-profile-v2.json').read_text())
assert meta['candidate']==profile['candidate']=='evaluate:B23:B24:B37'
assert meta['parent_hash']==profile['parent_hash']=='662c234256aa366f635db48674a674dbd95c3f3d'
assert profile['event_kind']=='selected_block_union' and profile['selected_blocks']==['B24','B37']
trial=ROOT/'work/postopt/landau-continuous-cached-v2/trial-415'
for path,h in [(trial.parent/'round-4-control.ll','82e9ea7a7aa1ee721006b3836e3ed6247c844dfc'),(trial/'after.ll','9258cd3b3ce383fd8fddc0ae13e3646293a4c5fc')]:
 assert hashlib.sha1(path.read_bytes()).hexdigest()==h
before=json.loads((work/'before.json').read_text());after=json.loads((work/'after.json').read_text())
b={x['block']:x for x in before['blocks']};c={x['block']:x for x in after['blocks']}
provenance_dir=a.provenance_trial.resolve()
trace=json.loads((provenance_dir/'block-provenance.json').read_text())
traced_trial=json.loads((provenance_dir/'trial.json').read_text())
run=json.loads((provenance_dir.parent/'run.json').read_text())
assert trace['candidate']==meta['candidate'] and trace['cleaned_hash']==meta['snapshots']['after']
assert traced_trial['control_hash']==meta['snapshots']['before']
assert trace['parent_hash']==traced_trial['parent_hash']==run['initial_parent_hash']
assert run.get('replay_parent_hash',trace['parent_hash'])==meta['parent_hash']
rows=[x for x in trace['blocks'] if [x['left_source_id'],x['right_source_id']]==profile['selected_blocks']]
assert len(rows)==1 and rows[0]['cleaned_block'], 'selected merged block not tracked through cleanup'
origin=rows[0]
left=b[origin['left_alignment_label']];right=b[origin['right_alignment_label']];merged=c[origin['cleaned_block']]
assert not any(x['unknown'] for x in [left,right,merged])
rows=[]
for r in profile['records']:
 union,l,rr,both=r['counts'];waves=r['launched_waves']
 raw=__import__('struct').pack('<4Q',*r['counts']);assert hashlib.sha256(raw).hexdigest()==r['counter_sha256']
 old=l*left['work']+rr*right['work'];new=union*merged['work']
 rows.append(dict(workload_id=r['workload_id'],selected_union=union,left_present=l,right_present=rr,both_present=both,weighted_selected_before=old,weighted_merged_after=new,component_gain=old-new,gain_per_launched_wave=(old-new)/waves,gain_per_selected_union=(old-new)/union))
result=dict(schema='pinned-landau-selected-work-diagnostic-v1',candidate=meta['candidate'],parent_hash=meta['parent_hash'],scope='selected/merged bodies only; outside-block changes unweighted; no acceptance decision',mapping_proof='observational engine block provenance; execution union still proven by pinned branch thresholds',block_provenance=origin,block_provenance_sha256=hashlib.sha256((provenance_dir/'block-provenance.json').read_bytes()).hexdigest(),static_body_work=dict(left=left['work'],right=right['work'],merged=merged['work']),static_total_gain=meta['work_delta'],static_outside_body_gain=meta['work_delta']-(left['work']+right['work']-merged['work']),inputs=rows)
with a.out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(result,indent=2))
