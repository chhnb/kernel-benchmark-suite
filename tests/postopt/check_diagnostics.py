#!/usr/bin/env python3
"""Integration tests for the offline C++ diagnostics; also audit archived v1 trials."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[2]
tool = root / 'build/postopt-diagnostics/postopt-diagnostics'
out = Path(sys.argv[1])
out.mkdir(exist_ok=False, parents=True)

def digest(path):
    return hashlib.sha1(path.read_bytes()).hexdigest()

def run(debug, trial, name, success=True):
    dest = out / (name + '.json')
    result = subprocess.run([str(tool), '--debug-dir', str(debug), '--trial', str(trial),
                             '--out', str(dest)], capture_output=True, text=True)
    (out / (name + '.log')).write_text(result.stdout + result.stderr)
    assert (result.returncode == 0) == success, result.stderr
    return json.loads(dest.read_text()) if success else None

def fixture(name, body):
    d = out / name
    (d / 'trial-0').mkdir(parents=True)
    ir = ('target triple = "amdgcn-amd-amdhsa"\n'
          'define i32 @f(i32 %x) #0 {\n' + body + '\n}\n'
          'declare i32 @external(i32)\n'
          'attributes #0 = { "target-cpu"="gfx906" }\n')
    files = [d/'state-0.ll', d/'round-0-control.ll', d/'trial-0/after-raw.ll', d/'trial-0/after.ll']
    for f in files:
        f.write_text(ir)
    hashes = {'parent_hash': digest(files[0]), 'control_hash': digest(files[1])}
    (d/'round-0.json').write_text(json.dumps(dict(hashes, cleanup='test-identical')))
    (d/'trial-0/trial.json').write_text(json.dumps(dict(hashes, candidate='f:B0:B1:B2',
        version=0, valid=True, cleaned_hash=digest(files[3]))))
    return d

known = fixture('fixture-known', ' %v = extractvalue {i32, i32} {i32 1, i32 2}, 0\n ret i32 %v')
j = run(known, 0, 'known')
assert j['all_costs_complete'] and j['net_gain'] == 0 and j['parent_gain'] == 0
assert j['S']['valid_cost_instructions'] == 2
assert j['S']['zero_cost_instructions'] > 0
unknown = fixture('fixture-unknown', ' %v = call i32 @external(i32 %x)\n ret i32 %v')
j = run(unknown, 0, 'unknown')
assert not j['all_costs_complete'] and j['net_gain'] is None
assert j['S']['cost'] is None and j['S']['unknown_cost_instructions'] == 1
assert j['S']['unknown_fraction'] == 0.5
# Header/name parsing must not permit stale or mixed snapshot identities.
(known/'state-0.ll').write_text((known/'state-0.ll').read_text()+'\n')
run(known, 0, 'tampered', False)
target = fixture('fixture-target', ' ret i32 %x')
f = target/'trial-0/after-raw.ll'
f.write_text(f.read_text().replace('gfx906', 'gfx900'))
run(target, 0, 'target-mismatch', False)

records = []
base = root/'experiments/postopt-suite-comparison-v2'
for case in ['boost-landau', 'boost-mapairy', 'boost-saspoint5']:
    debug = base/case/'v1-debug'
    candidates = []
    for p in debug.glob('trial-*/trial.json'):
        t = json.loads(p.read_text())
        if t['valid']:
            candidates.append((int(p.parent.name.split('-')[1]), p, t))
    candidates.sort()
    assert candidates, case
    # Earliest legal candidate, plus a positive and a non-positive modeled trial when available.
    chosen = {candidates[0][0]: candidates[0]}
    for positive in (True, False):
        for item in candidates:
            score = item[2]['score_result']
            if score['status'] == 'scored' and (score['static_gain'] > 0) == positive:
                chosen[item[0]] = item
                break
    for trial, p, t in chosen.values():
        paths = [debug/f'state-{t["version"]}.ll', debug/f'round-{t["version"]}-control.ll',
                 p.parent/'after-raw.ll', p.parent/'after.ll', p]
        before = {str(p): digest(p) for p in paths}
        name = f'{case}-trial-{trial}'
        j = run(debug, trial, name)
        assert before == {str(p): digest(p) for p in paths}
        assert j['decomposition_residual'] in (None, 0)
        if j['all_costs_complete']:
            assert j['parent_gain'] == j['S']['cost']-j['A']['cost']
            assert j['net_gain'] == j['B']['cost']-j['A']['cost']
        score = t['score_result']
        metrics = score['metrics']
        # Same extractor must reproduce archived v1 optimized costs where present.
        for stage, metric in [('B', 'work_before'), ('A', 'work_after')]:
            if metric in metrics:
                assert j[stage]['modeled_subtotal'] == metrics[metric], (name, stage)
        records.append(dict(case=case, trial=trial, candidate=j['candidate'],
            complete=j['all_costs_complete'], costs={s:j[s]['cost'] for s in 'SBRA'},
            transformation_gain=j['transformation_gain'], cleanup_interaction=j['cleanup_interaction'],
            net_gain=j['net_gain'], parent_gain=j['parent_gain'],
            control_ops=[r for r in j['opcode_modeled_cost_breakdown'] if r['opcode'] in ('br','phi','select','fcmp')],
            snapshots_unchanged=True))
(out/'summary.json').write_text(json.dumps(dict(tests='passed', synthetic_tests=4,
    archived_candidates=len(records), records=records), indent=2))
print('PASS synthetic coverage/hash/target tests and', len(records), 'archived candidate audits')
