#!/usr/bin/env python3
"""Portable profile selection, with explicit static fallback. No timing features."""
import argparse,hashlib,json,struct
from pathlib import Path
from postopt_wave_report import report,counters

def workload_id(item):
    # Paths are not workload identity. Relative filenames and contents include
    # the original launch/ABI specification and its input and oracle files.
    base=Path(item['original']).parent
    entries=[]
    for name,digest in item['original_sha256'].items():
        rel=Path(name).relative_to(base).as_posix()
        entries.append([rel,digest])
    return hashlib.sha256(json.dumps(sorted(entries),separators=(',',':')).encode()).hexdigest()

def export(root):
    checked=report(root)  # Requires preserved admitted validation artifacts.
    manifest=json.loads((root/'manifest.json').read_text())
    if manifest['wave_size']!=64 or manifest['target']!='gfx906':
        raise ValueError('unsupported profile target')
    if hashlib.sha1((root/'parent.ll').read_bytes()).hexdigest()!=manifest['parent_hash']:
        raise ValueError('parent identity mismatch')
    kind=manifest.get('event_kind','split_branch')
    if kind not in ('split_branch','selected_block_union'):raise ValueError('unknown event kind')
    records=[]
    for item,row in zip(manifest['inputs'],checked['inputs']):
        records.append(dict(workload_id=workload_id(item),
            counts=[row[k] for k in ['visits','true_present','false_present','both_present']],
            launched_waves=row['launched_waves'],counter_sha256=row['counter_sha256'],
            validation_receipt_sha256=row['validation_receipt_sha256']))
    return dict(schema='postopt-profile-v1',event_kind=kind,selected_blocks=manifest.get('selected_blocks'),parent_hash=checked['parent_hash'],
        candidate=checked['candidate'],target=manifest['target'],wave_size=manifest['wave_size'],
        profile_manifest_sha256=checked['manifest_sha256'],records=records,
        scope='exact workload and frozen parent only; not generalized to unseen inputs')

def select(data,*,parent_hash,candidate,target,wave_size,workload,min_visits,event_kind="split_branch"):
    """Caller retains its static decision on every fallback; never infer d=1.

    min_visits is an explicit coverage policy, not a confidence guarantee.
    A changed IR/target/workload is stale even when the file is recent.
    """
    if type(min_visits) is not int or min_visits<1:
        raise ValueError('min_visits must be a positive integer')
    def fallback(reason):return dict(status='static_fallback',reason=reason,profile=None)
    if event_kind not in ('split_branch','selected_block_union'):raise ValueError('unknown requested event kind')
    if data is None:return fallback('profile_missing')
    try:
        if data['schema']!='postopt-profile-v1':return fallback('unsupported_schema')
        for key,value in [('parent_hash',parent_hash),('candidate',candidate),('target',target),('wave_size',wave_size)]:
            if data[key]!=value:return fallback('stale_'+key)
        if data.get('event_kind','split_branch')!=event_kind:return fallback('wrong_event_kind')
        matches=[x for x in data['records'] if x['workload_id']==workload]
        if not matches:return fallback('workload_not_covered')
        if len(matches)!=1:return fallback('ambiguous_workload')
        r=matches[0];values=r['counts']
        if len(values)!=4 or any(type(v) is not int or not 0<=v<2**64 for v in values):
            return fallback('invalid_counters')
        waves=r['launched_waves']
        if type(waves) is not int or waves<1:return fallback('invalid_launch')
        raw=struct.pack('<4Q',*values)
        if hashlib.sha256(raw).hexdigest()!=r['counter_sha256']:return fallback('counter_hash_mismatch')
        features=counters(raw)
        if not features['visits']:return fallback('region_not_executed')
        if features['visits']<min_visits:return fallback('insufficient_visits')
        features['visits_per_launched_wave']=features['visits']/waves
        return dict(status='profile_available',reason='exact_identity_and_coverage',profile=features)
    except (KeyError,TypeError,ValueError,OverflowError,struct.error):
        return fallback('malformed_profile')

def main():
    p=argparse.ArgumentParser();s=p.add_subparsers(dest='command',required=True)
    e=s.add_parser('export');e.add_argument('--capture',required=True,type=Path);e.add_argument('--out',required=True,type=Path)
    c=s.add_parser('select');c.add_argument('--profile',required=True,type=Path);c.add_argument('--context',required=True,type=Path)
    a=p.parse_args()
    if a.command=='export':
        data=export(a.capture.resolve())
        with a.out.open('x') as f:json.dump(data,f,indent=2);f.write('\n')
    else:
        context=json.loads(a.context.read_text())
        try:data=json.loads(a.profile.read_text())
        except FileNotFoundError:data=None
        except (OSError,ValueError):
            print(json.dumps(dict(status='static_fallback',reason='profile_unreadable',profile=None)));return
        print(json.dumps(select(data,**context),indent=2))
if __name__=='__main__':main()
