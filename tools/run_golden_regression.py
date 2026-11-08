#!/usr/bin/env python3
"""Replay immutable golden inputs with the C++ GPU runners and existing admission."""
from pathlib import Path
import argparse, csv, hashlib, json, math, statistics, subprocess, time
S = Path(__file__).resolve().parents[1]
def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for part in iter(lambda: f.read(8 << 20), b''): h.update(part)
    return h.hexdigest()
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('case', choices=['vllm', 'tigre'])
    ap.add_argument('--archive', type=Path, default=S/'regression/golden/20261109-gfx906-v1')
    ap.add_argument('--candidate', type=Path)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--verify-only', action='store_true')
    ap.add_argument('--max-slowdown-pct', type=float, default=2.0)
    a = ap.parse_args()
    if not math.isfinite(a.max_slowdown_pct) or a.max_slowdown_pct < 0: ap.error('invalid threshold')
    root = a.archive.resolve(); m = json.loads((root/'manifest.json').read_text())
    # Verify every archived file, including inputs/oracles, before GPU admission.
    for rel, expected in m['sha256'].items():
        if sha(root/rel) != expected: raise RuntimeError('archive hash mismatch: '+rel)
    cfg = m['cases'][a.case]
    case_dir = root/cfg['case_directory']
    a.out = a.out.resolve(); a.out.mkdir(parents=True, exist_ok=False)
    if a.verify_only:
        (a.out/'integrity.json').write_text(json.dumps({'passed':True,'files':len(m['sha256'])},indent=2))
        print('archive integrity passed'); return
    reference = root/cfg['winner_binary']
    candidate = a.candidate.resolve() if a.candidate else reference
    binaries = {'reference':reference, 'candidate':candidate}
    hashes = {k:sha(v) for k,v in binaries.items()}
    plan = {'case':a.case,'archive':str(root),'archive_manifest_sha256':sha(root/'manifest.json'),
            'binaries':{k:{'path':str(v),'sha256':hashes[k]} for k,v in binaries.items()},
            'timing':'C++ GPU event','warmup':3,'repeat':15,'batches':3,
            'order':[['reference','candidate'],['candidate','reference'],['reference','candidate']],
            'max_slowdown_pct':a.max_slowdown_pct,'status':'planned','commands':[]}
    def save(name): (a.out/name).write_text(json.dumps(plan,indent=2))
    save('plan.json')
    def run(role, phase, dest):
        cmd=[str(S/'bench'),str(case_dir),phase,'--kernel',str(binaries[role]),'--out',str(dest),'--warmup','3','--repeat','15']
        if phase=='benchmark': cmd += ['--validated',str(a.out/(role+'-validation'))]
        for attempt in range(3):
            assert sha(binaries[role]) == hashes[role], 'binary changed'
            plan['commands'].append(cmd); save('progress.json')
            rc=subprocess.run(cmd,cwd=S).returncode
            assert sha(binaries[role]) == hashes[role], 'binary changed'
            if rc==0: return
            # Only retry confirmed prelaunch admission denial, never an execution.
            if (dest/'output').exists() or (dest/'terminal.json').exists():
                raise RuntimeError('GPU execution failed; no retry')
            f=dest/'admission.json'
            if not f.exists() or all(p['admitted'] for p in json.loads(f.read_text())):
                raise RuntimeError('not a confirmed prelaunch admission denial')
            dest.rename(dest.with_name(dest.name+'-denied-'+str(attempt)))
            if attempt<2: time.sleep(3)
        raise RuntimeError('prelaunch admission attempts exhausted')
    def sample_medians(dest):
        receipt=json.loads((dest/'accepted.json').read_text()); assert receipt['passed']
        if a.case=='vllm':
            values=[]
            for i in range(6):
                rows=list(csv.DictReader((dest/'output'/str(i)/'samples.csv').open()))
                assert len(rows)==18 and all(r['full_output_passed']=='1' for r in rows)
                samples=[float(r['microseconds'])/1000 for r in rows if r['warmup']=='0']
                assert len(samples)==15 and all(math.isfinite(x) and x>0 for x in samples)
                values.append(statistics.median(samples))
            return values,receipt['input_snapshot']
        rows=list(csv.DictReader((dest/'output/0/timing.csv').open())); assert len(rows)==108
        values=[]
        for i in range(6):
            samples=[float(r['ms']) for r in rows if r['warmup']=='0' and int(r['batch'])==i]
            assert len(samples)==15 and all(math.isfinite(x) and x>0 for x in samples)
            values.append(statistics.median(samples))
        return values,receipt['input_snapshot']
    try:
        for role in binaries: run(role,'validate',a.out/(role+'-validation'))
        for b,order in enumerate(plan['order']):
            for role in order: run(role,'benchmark',a.out/(role+'-batch-'+str(b)))
        vals={r:[] for r in binaries}; snapshot=None
        for r in binaries:
            for b in range(3):
                v,snap=sample_medians(a.out/(r+'-batch-'+str(b)))
                if snapshot is None: snapshot=snap
                assert snap==snapshot, 'input snapshot mismatch'
                vals[r].append(v)
        totals={r:sum(statistics.median(vals[r][b][i] for b in range(3)) for i in range(6)) for r in vals}
        effect=100*(totals['candidate']/totals['reference']-1)
        result={'correctness_passed':True,'performance_passed':effect<=a.max_slowdown_pct,
                'sum_medians_ms':totals,'candidate_slowdown_pct':effect,'threshold_pct':a.max_slowdown_pct,
                'batch_sums_ms':{r:[sum(v) for v in vals[r]] for r in vals},
                'historical_reference_ms':cfg['historical_ms'],
                'reference_vs_history_pct':100*(totals['reference']/cfg['historical_ms']-1),
                'comparison':'same-run frozen reference; historical timing is informational',
                'candidate_matches_reference_binary':hashes['candidate']==hashes['reference']}
        for rel, expected in m['sha256'].items():
            if sha(root/rel)!=expected: raise RuntimeError('archive changed during run: '+rel)
        (a.out/'summary.json').write_text(json.dumps(result,indent=2)); print(json.dumps(result,indent=2))
        plan['status']='completed'; save('terminal.json')
        if not result['performance_passed']: raise SystemExit(1)
    except Exception as e:
        plan['status']='stopped_preserved';plan['error']=str(e);save('terminal.json');raise
if __name__=='__main__': main()
