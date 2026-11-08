#!/usr/bin/env python3
import json
import subprocess
import hashlib
from pathlib import Path
import sys

root=Path(__file__).resolve().parents[2]
out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=False)
worker=root/'tools/run-llvm24-tti'
search=root/'build/llvm24-tti/fusion-search-llvm24'
def query(path,fn,dest):
    p=subprocess.run([str(worker),str(path),fn],capture_output=True,text=True)
    assert p.returncode==0,p.stderr
    dest.write_text(p.stdout)
    return json.loads(p.stdout)

fixture=out/'fixture.ll'
fixture.write_text('''target triple = "amdgcn-amd-amdhsa"
define i32 @f(i1 %c, i32 %x) #0 {
entry:
 br i1 %c, label %left, label %right
left:
 %a = mul i32 %x, 7
 br label %end
right:
 %b = add i32 %x, 7
 br label %end
end:
 %p = phi i32 [ %a, %left ], [ %b, %right ]
 ret i32 %p
}
attributes #0 = { "target-cpu"="gfx906" }
''')
j=query(fixture,'f',out/'fixture.json')
assert j['unknown']==0
assert {r['tti_cost'] for r in j['instruction_costs'] if r['key'].startswith('br.conditional:')}=={7}
assert {r['tti_cost'] for r in j['instruction_costs'] if r['key'].startswith('br.unconditional:')}=={4}
unknown=out/'unknown.ll'
unknown.write_text('''target triple = "amdgcn-amd-amdhsa"
declare i32 @opaque(i32)
define i32 @f(i32 %x) #0 { %v = call i32 @opaque(i32 %x)
ret i32 %v }
attributes #0 = { "target-cpu"="gfx906" }
''')
j=query(unknown,'f',out/'unknown.json');assert j['unknown']==1 and j['cost'] is None
base=root/'experiments/postopt-suite-comparison-v2'
summary=[]
for case in ['boost-landau','boost-mapairy','boost-saspoint5']:
    source=base/case/'v1-debug/state-0.ll'
    source_hash=hashlib.sha256(source.read_bytes()).hexdigest()
    d=out/case;d.mkdir()
    j=query(source,'evaluate',d/'parent-llvm24.json')
    assert j['unknown']==0
    cmd=[str(search),'--ir',str(source),'--function','evaluate','--out',str(d/'result.ll'),
         '--cleanup','postopt-fp','--rounds','1','--trials','1000','--debug-dir',str(d/'debug')]
    p=subprocess.run(cmd,capture_output=True,text=True)
    (d/'search.log').write_text(p.stdout+p.stderr)
    assert p.returncode==0,p.stderr
    r=json.loads((d/'debug/result.json').read_text())
    assert r['policy']=='llvm24' and r['commits']==1,r
    scored=0
    for t in (d/'debug').glob('trial-*/trial.json'):
        info=json.loads(t.read_text());s=info['score_result']
        if info['valid']:
            assert s['status']=='scored',s['reason']
            assert s['metrics']['tti_major']==24
            scored+=1
    commit=json.loads((d/'debug/commit-1.json').read_text())
    final=query(d/'result.ll','evaluate',d/'result-llvm24.json')
    assert final['cost']==commit['score_result']['metrics']['work_after']
    assert hashlib.sha256(source.read_bytes()).hexdigest()==source_hash
    summary.append(dict(case=case,initial_cost=j['cost'],final_cost=final['cost'],
        scored_trials=scored,selected=commit['candidate'],result=r))
(out/'summary.json').write_text(json.dumps(summary,indent=2))
print('PASS LLVM24 branch costs, opaque-call rejection, three complete greedy rounds, score/result agreement')
