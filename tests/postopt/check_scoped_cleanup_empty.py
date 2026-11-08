from pathlib import Path
import subprocess,json,re
R=Path('/home/chh/kernel-benchmark-suite'); src=R/'experiments/logical-state-vllm-20261108-v1';o=R/'experiments/scoped-cleanup-empty-20261108-v1';o.mkdir(exist_ok=False)
exe=R/'build/llvm24-tti/scoped-cleanup'
def cfg(p):
 out=[];bb=None
 for l in p.read_text().splitlines():
  if re.match(r'^[-a-zA-Z$._0-9]+:',l):bb=l.split(':')[0]
  if re.match(r'^\s+(br|ret|switch|unreachable)\b',l):out.append((bb,l.strip().split()[0],re.findall(r'label %([-a-zA-Z$._0-9]+)',l)))
 return out
def run(inp,ref,func,d,blocks):
 q=subprocess.run([str(exe),str(inp),str(ref),func,str(d.with_suffix('.ll')),str(d.with_suffix('.json')),*blocks,"--empty-blocks"],capture_output=True,text=True);assert q.returncode==0,q.stderr
 assert sum(t[1]=='br' and len(t[2])==2 for t in cfg(inp))==sum(t[1]=='br' and len(t[2])==2 for t in cfg(d.with_suffix('.ll'))),'conditional branches changed'
 return json.loads(d.with_suffix('.json').read_text())
def cost(p,func='cache_eval'):
 q=subprocess.run([str(R/'tools/run-llvm24-tti'),str(p),func],capture_output=True,text=True);assert q.returncode==0,q.stderr;j=json.loads(q.stdout);assert j['unknown']==0;jpath=p.with_suffix('.tti.json');jpath.write_text(json.dumps(j,indent=2));return j['modeled_cost']
summary=[]
for name,trial,blocks in [('L5+L6','trial-6',['if.else16.i679','if.then19.i680','if.then23.i683','quant_decide.exit685']),('L0+L1','trial-318',['quant_decide.exit707','if.then.i665','if.then3.i668','quant_decide.exit685'])]:
 d=o/name;d.mkdir();ref=src/'state-0.ll';raw=src/trial/'after-raw.ll'
 cr=run(ref,ref,'cache_eval',d/'control',blocks);ar=run(raw,ref,'cache_eval',d/'after',blocks)
 old=json.loads((src/trial/'trial.json').read_text())['score_result'];before=cost(d/'control.ll');after=cost(d/'after.ll');rawcost=cost(raw)
 row={'pair':name,'control_cost':before,'raw_cost':rawcost,'after_cost':after,'gain':before-after,'old_postopt_gain':old['static_gain'],'control_report':cr,'after_report':ar};summary.append(row)
# Direct regression: simplify inside, retain identical opportunities outside.
p=o/'scope-test-input.ll';p.write_text('''define i32 @f(i32 %x, i1 %p) {
entry:
 br i1 %p, label %inside, label %outside
inside:
 %a = add i32 %x, 0
 %dead = mul i32 %x, 7
 br label %join
outside:
 %b = add i32 %x, 0
 br label %join
join:
 %r = phi i32 [ %a, %inside ], [ %b, %outside ]
 ret i32 %r
}
''');run(p,p,'f',o/'scope-test-after',['inside']);s=(o/'scope-test-after.ll').read_text();assert '%a =' not in s and '%dead =' not in s and '%b = add i32 %x, 0' in s
(o/'summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2));print('PASS scope isolation, CFG preservation, verifier')
