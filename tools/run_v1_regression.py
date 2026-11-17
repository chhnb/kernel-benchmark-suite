#!/usr/bin/env python3
"""Reproduce frozen v1 IR, scores and commit counts from checked-in inputs."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'regression/greedy-v1/manifest.json'

def ir_hash(path):
    return hashlib.sha256(b'\n'.join(line for line in path.read_bytes().splitlines()
                                    if not line.startswith(b'; ModuleID ='))).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--case', action='append', dest='cases')
    parser.add_argument('--jobs', type=int, default=4)
    parser.add_argument('--timeout', type=int, default=900)
    parser.add_argument('--tti-quote-cache', choices=['off','audit','on'], default='on')
    parser.add_argument('--include-slow', action='store_true', help='include PCM128/256, which timed out in the checkpoint')
    args = parser.parse_args()
    if args.jobs < 1 or args.timeout < 1:
        parser.error('jobs and timeout must be positive')
    rows = json.loads(MANIFEST.read_text())['cases']
    if args.cases:
        unknown = set(args.cases) - {r['case'] for r in rows}
        if unknown:
            parser.error(f'unknown cases: {sorted(unknown)}')
        rows = [r for r in rows if r['case'] in args.cases]
    elif not args.include_slow:
        rows = [r for r in rows if r['reference_exit'] == 0]
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    env.setdefault('LLVM24_LIBDIR', str(ROOT / 'build/llvm24-pinned/lib'))
    env['LD_LIBRARY_PATH'] = str(ROOT / 'build/llvm12-jammy/usr/lib/x86_64-linux-gnu') + ':' + env.get('LD_LIBRARY_PATH', '')
    env.setdefault('DECISION_GREEDY_JOBS', '16')
    opt = Path(env.get('LLVM12_OPT', str(ROOT / 'build/llvm12-jammy/usr/lib/llvm-12/bin/opt')))

    def run(row):
        case = row['case']
        source = out / (case + '.ll')
        data = gzip.decompress((MANIFEST.parent / row['input']).read_bytes())
        if hashlib.sha256(data).hexdigest() != row['input_sha256']:
            raise RuntimeError(f'{case}: frozen input hash mismatch')
        source.write_bytes(data)
        dest = out / case
        begin = time.monotonic()
        with (out / (case + '.log')).open('w') as log:
            rc = subprocess.run(['timeout', '-k', '3s', str(args.timeout) + 's',
                                 ROOT / 'build/decision-fuse/decision-greedy', source,
                                 row['function'], ROOT, dest, '--b2b-strategy', 'dp1', '--tti-quote-cache', args.tti_quote_cache],
                                stdout=log, stderr=subprocess.STDOUT, env=env).returncode
        result = dict(case=case, exit=rc, seconds=round(time.monotonic() - begin, 2), passed=False)
        summary = dest / 'summary.json'
        if summary.exists():
            s = json.loads(summary.read_text())
            result.update(commits=s['commits'], tti=s['final_cost'])
        if rc == 0:
            result['verified'] = subprocess.run([opt, '-verify', '-disable-output', dest / 'final.ll'], env=env).returncode == 0
            result['ir_sha256'] = ir_hash(dest / 'final.ll')
            result['identical_ir'] = result['ir_sha256'] == row.get('expected_ir_sha256')
            result['passed'] = (result['verified'] and result['identical_ir'] and
                                result['commits'] == row['expected_commits'] and result['tti'] == row['expected_tti'])
        elif rc == 124 and row['reference_exit'] == 124:
            result['known_timeout'] = True  # explicitly not a passing regression
        (out / (case + '.result.json')).write_text(json.dumps(result, indent=2) + '\n')
        print(json.dumps(result), flush=True)
        return result

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = list(pool.map(run, rows))
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    return 0 if all(r['passed'] for r in results) else 1

if __name__ == '__main__':
    raise SystemExit(main())
