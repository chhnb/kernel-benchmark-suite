#!/usr/bin/env python3
"""Pack validated portable profiles for experimental --scorer v5."""
import argparse,hashlib,json
from pathlib import Path
from postopt_profile import select
p=argparse.ArgumentParser();p.add_argument('--profile',type=Path,action='append',required=True);p.add_argument('--workload',required=True);p.add_argument('--min-visits',type=int,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
profiles=[];sources=[];seen=set()
for path in a.profile:
 raw=path.read_bytes();profile=json.loads(raw);kind=profile.get('event_kind','split_branch')
 r=select(profile,parent_hash=profile['parent_hash'],candidate=profile['candidate'],target=profile['target'],wave_size=profile['wave_size'],workload=a.workload,min_visits=a.min_visits,event_kind=kind)
 if r['status']!='profile_available':raise ValueError(str(path)+': '+r['reason'])
 identity=(profile['parent_hash'],profile['candidate'],kind)
 if identity in seen:raise ValueError('duplicate profile event kind for candidate')
 seen.add(identity);profiles.append(profile);sources.append(dict(path=str(path.resolve()),sha256=hashlib.sha256(raw).hexdigest()))
bundle=dict(schema='postopt-profile-bundle-v1',workload_id=a.workload,min_visits=a.min_visits,profiles=profiles,sources=sources,scope='experimental exact-workload wave-presence work model; no runtime labels')
with a.out.open('x') as f:json.dump(bundle,f,indent=2);f.write('\n')
