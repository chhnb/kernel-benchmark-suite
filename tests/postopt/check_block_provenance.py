#!/usr/bin/env python3
"""Check observational block trace on two authenticated relocated replays."""
import argparse,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('replay',type=Path);a=p.parse_args();root=a.replay.resolve()
paths=[root/x/'debug/trial-0' for x in ['relocated-a','relocated-b']]
traces=[json.loads((x/'block-provenance.json').read_text()) for x in paths]
assert traces[0]==traces[1], 'trace depends on input path/process'
t=traces[0];assert t['candidate']=='evaluate:B23:B24:B37'
for base in paths:
 trial=json.loads((base/'trial.json').read_text());assert t['parent_hash']==trial['parent_hash'] and t['cleaned_hash']==trial['cleaned_hash']
 for row in t['blocks']:
  for stage,name in [('after-raw.ll','raw_block'),('after.ll','cleaned_block')]:
   label=row[name]
   if label:
    assert label.startswith('%') and (label[1:]+':') in (base/stage).read_text(),(stage,label)
  assert row['coverage']==('surviving_block_identity_not_instruction_or_execution_mapping' if row['cleaned_block'] else 'block_deleted_or_untracked')
selected=[x for x in t['blocks'] if (x['left_source_id'],x['right_source_id'])==('B24','B37')]
assert len(selected)==1 and selected[0]['cleaned_block']=='%merged.bb20'
assert any(x['raw_block'] and not x['cleaned_block'] for x in t['blocks']), 'fixture must exercise cleanup deletion'
assert any(x['left_source_id']=='generated_before_alignment' for x in t['blocks']), 'fixture must exercise replication'
print('PASS deterministic trace, exact snapshot binding, selected pair mapping, generated sources and deletion coverage')
