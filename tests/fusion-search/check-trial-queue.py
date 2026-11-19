#!/usr/bin/env python3
"""Shared queue: exactly-once claims, reused workers, parent changes and rejected requests."""
from pathlib import Path
import hashlib
import json
import subprocess
import tempfile
import sys

root = Path(__file__).resolve().parents[2]
search = root / 'build/llvm24-tti/fusion-search-llvm24'
worker = root / 'tools/run-llvm24-tti'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

with tempfile.TemporaryDirectory() as temp:
    out = Path(temp)
    sources = []
    expected = []
    for value in (7, 19):
        source = out / f'parent-{value}.ll'
        source.write_text(f'''target triple = "amdgcn-amd-amdhsa"
%Named = type {{ i32 }}
@named = global %Named zeroinitializer
define i32 @choose(i1 %p, i32 %x, i32 %y) #0 {{
entry:
  br i1 %p, label %left, label %right
left:
  %l = mul i32 %x, {value}
  br label %join
right:
  %r = mul i32 %y, 11
  br label %join
join:
  %v = phi i32 [%l, %left], [%r, %right]
  ret i32 %v
}}
attributes #0 = {{ "target-cpu"="gfx906" }}
''')
        args = [str(search), '--ir', str(source), '--function', 'choose', '--split', 'B0',
                '--left', 'B1', '--right', 'B2', '--b2b-strategy', 'anchor', '--tti-worker', str(worker)]
        result = out / f'expected-{value}.ll'
        subprocess.run([*args, '--out', str(result)], check=True, capture_output=True)
        sources.append(args)
        expected.append(digest(result))
    requests = []
    for i in range(24):
        dest = out / str(i)
        dest.mkdir()
        args = [*sources[(i // 3) % 2], '--out', str(dest / 'after.ll'), '--debug-dir', str(dest / 'debug')]
        # A failed request must not poison cached state or prevent later work.
        if i == 0:
            args += ['--unknown-v1-option', '1']
        if i == 5:
            args[args.index('--left') + 1] = 'B999'
        requests.append(dict(argv=args, status=str(dest / 'status.json'),
                             stdout=str(dest / 'stdout'), stderr=str(dest / 'stderr')))
    manifest = out / 'queue.json'
    manifest.write_text(json.dumps(requests))
    processes = [subprocess.Popen([search, '--trial-queue', manifest], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                 for _ in range(2)]
    for process in processes:
        stdout, stderr = process.communicate(timeout=60)
        assert process.returncode == 0, (stdout, stderr)
    pids = {}
    status_hashes = []
    for i, request in enumerate(requests):
        status = Path(request['status'])
        data = json.loads(status.read_text())
        code = 2 if i == 0 else 4 if i == 5 else 0
        assert data['exit_code'] == code, (i, data)
        pids[data['worker_pid']] = pids.get(data['worker_pid'], 0) + 1
        if code == 0:
            assert digest(out / str(i) / 'after.ll') == expected[(i // 3) % 2], i
        status_hashes.append(digest(status))
    assert len(pids) == 2 and min(pids.values()) > 1, pids
    # Reopening the same queue cannot re-execute claimed work.
    subprocess.run([search, '--trial-queue', manifest], check=True, capture_output=True)
    assert [digest(Path(r['status'])) for r in requests] == status_hashes
    print('PASS queue: 24 unique claims, two reused workers, changed parent IR, error and rejection recovery')
