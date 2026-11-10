#!/usr/bin/env python3
"""Plan/apply pruning of unselected, valid, scored debug IR; never delete trials."""
from pathlib import Path
import argparse, hashlib, json

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def selected(root):
    rows = [json.loads(p.read_text()) for p in root.glob('commit-*.json')]
    return {(j['parent_version'], j['candidate']) for j in rows}

def removable(meta, winners):
    return (meta.get('valid') is True and meta.get('score_result', {}).get('status') == 'scored'
            and (meta.get('version'), meta.get('candidate')) not in winners)

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--search',type=Path,action='append',default=[])
    p.add_argument('--plan',type=Path,required=True)
    p.add_argument('--apply',action='store_true')
    a=p.parse_args()
    if not a.apply:
        if a.plan.exists():raise RuntimeError('plan must be new')
        rows=[];roots=[]
        for root in a.search:
            root=root.resolve();assert (root/'result.json').is_file(), 'only completed searches'
            winners=selected(root);roots.append(str(root))
            for f in sorted(root.glob('trial-*/trial.json')):
                meta=json.loads(f.read_text())
                if not removable(meta,winners):continue
                for name in ('after.ll','after-raw.ll'):
                    ir=f.parent/name
                    if ir.is_file() and not ir.is_symlink():
                        rows.append({'path':str(ir),'bytes':ir.stat().st_size,'sha256':sha(ir),
                                     'trial_sha256':sha(f),'root':str(root)})
        assert roots, 'supply --search'
        a.plan.parent.mkdir(parents=True,exist_ok=True)
        a.plan.write_text(json.dumps({'roots':roots,'files':rows,'policy':'keep selected, invalid and unscored trials; preserve all parent states and JSON'},indent=2)+'\n')
        print(json.dumps({'files':len(rows),'bytes':sum(r['bytes'] for r in rows)}));return
    plan=json.loads(a.plan.read_text());receipt=a.plan.with_suffix('.receipt.json')
    assert not receipt.exists(), 'already applied or interrupted; inspect receipt'
    winners={r:selected(Path(r)) for r in plan['roots']}
    # Validate the entire frozen plan before the first deletion.
    for r in plan['files']:
        f=Path(r['path']);root=Path(r['root']);meta=f.parent/'trial.json'
        assert f.name in ('after.ll','after-raw.ll') and f.parent.parent==root
        assert f.parent.name.startswith('trial-') and not f.is_symlink()
        assert sha(f)==r['sha256'] and sha(meta)==r['trial_sha256']
        assert removable(json.loads(meta.read_text()),winners[str(root)])
    state={'plan_sha256':sha(a.plan),'status':'applying','removed_files':0,'removed_bytes':0}
    receipt.write_text(json.dumps(state,indent=2))
    try:
        for r in plan['files']:
            Path(r['path']).unlink();state['removed_files']+=1;state['removed_bytes']+=r['bytes']
        for root in plan['roots']:
            (Path(root)/'IR_RETENTION.md').write_text('# Pruned debug IR\n\nUnselected valid scored trials no longer retain after.ll/after-raw.ll. Parent state, trial JSON, selected/invalid/unscored trial IR remain.\n\nFull paths, hashes and sizes: '+str(a.plan)+'\n')
        state['status']='complete'
    finally:receipt.write_text(json.dumps(state,indent=2)+'\n')
    print(json.dumps(state))
if __name__=='__main__':main()
