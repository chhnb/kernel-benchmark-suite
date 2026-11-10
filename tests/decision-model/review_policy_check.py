from pathlib import Path
import subprocess,tempfile,json,os
r=Path(__file__).resolve().parents[2];exe=r/'build/decision-fuse/decision-fuse';base=(r/'tests/decision-model/chain.ll').read_text()
def run(args,env=None):return subprocess.run(list(map(str,args)),env=env,capture_output=True,text=True)
with tempfile.TemporaryDirectory() as td:
 d=Path(td)
 # Outside the selected decision, a barrier may occur before its root.
 barrier=base.replace('entry:\n','pre:\n call void @barrier()\n br label %entry\nentry:\n')+'\ndeclare void @barrier() convergent\n'
 src=d/'outside.ll';src.write_text(barrier);p=run([exe,src,'case',0,0,d/'outside']);assert p.returncode==0,p.stderr
 inside=base.replace('%av = add','call void @barrier()\n %av = add')+'\ndeclare void @barrier() convergent\n';src=d/'inside.ll';src.write_text(inside);p=run([exe,src,'case',0,0,d/'inside']);assert p.returncode!=0
 src=d/'base.ll';src.write_text(base)
 for cb,sb in [(0,100),(100,0)]:
  out=d/f'b-{cb}-{sb}';env=dict(os.environ,DECISION_CONDITION_BUDGET=str(cb),DECISION_SPECULATION_BUDGET=str(sb));p=run([exe,src,'case',0,0,out],env);assert p.returncode==0,p.stderr;t=json.loads((out/'trial.json').read_text());assert t['condition_budget']==cb and t['speculation_budget']==sb;assert ('decision.take = phi' in (out/'normalized.ll').read_text())==(cb==0)
 # Controlled TTI worker: isolate acceptance guards from target pricing.
 root=d/'root';(root/'tools').mkdir(parents=True);(root/'build/decision-fuse').mkdir(parents=True);(root/'build/decision-fuse/decision-fuse').symlink_to(exe)
 worker=root/'tools/run-llvm24-tti';worker.write_text('''#!/usr/bin/env python3
import sys,json,re,os
text=open(sys.argv[1]).read();blocks=len(re.findall(r'^[-a-zA-Z0-9_.]+:',text,re.M));after=sys.argv[1].endswith('/fused.ll');mode=os.environ.get('MOCK','ok')
o={'unknown':0,'source_revision':'6be16f356d3e','cost':900 if after else 1000,'padding':'' if after else 'x'*4096}
if mode!='missing':o['instruction_costs']=[{'block_index':i,'accepted_cost':100 if after and mode=='loss' else 0} for i in range(blocks)]
print(json.dumps(o))
''');worker.chmod(0o755)
 for mode,cap,guard,reason in [('ok','0',False,'pressure_limit'),('loss','1000000',True,'uniform_loss_limit'),('missing','1000000',True,'side_metrics_unavailable'),('ok','1000000',False,None),('loss','1000000',False,None),('missing','1000000',False,None)]:
  out=d/f'g-{mode}-{cap}-{guard}';env=dict(os.environ,MOCK=mode,DECISION_MAX_PRESSURE=cap,DECISION_MAX_PRESSURE_GROWTH='1000000');env.pop('DECISION_MAX_UNIFORM_LOSS',None)
  if guard:env['DECISION_MAX_UNIFORM_LOSS']='0'
  p=run([r/'build/decision-fuse/decision-greedy',src,'case',root,out],env);assert p.returncode==0,p.stderr
  summary=json.loads((out/'summary.json').read_text());assert summary['uniform_loss_guard_enabled']==guard;assert summary['max_uniform_loss']==(0 if guard else -1)
  check=run(['python3',r/'tests/decision-model/check_greedy_report.py',out/'summary.json']);assert check.returncode==0,check.stderr;attempts=[a for round in summary['rounds'] for a in round['attempts']]
  if reason:assert summary['commits']==0 and any(a.get('reason')==reason for a in attempts),(reason,summary)
  else:assert summary['commits']>0,summary
 # Two roots carrying the same identity must never resolve to the first one.
 import re
 second=base[base.index('entry:'):base.rindex('}')]
 def rename(m):return '%'+m.group(1)+'_second' if m.group(1)!='x' else '%x'
 second=re.sub(r'%([a-zA-Z0-9]+)',rename,second)
 second=re.sub(r'^(entry|test1|test2|a|b|c|d|join):',lambda m:m.group(1)+'_second:',second,flags=re.M)
 first=base[:base.rindex('}')].replace('ret i32 %v','br label %entry_second')
 dup=first+second+'}\n!0 = !{!"same-root"}\n'
 dup=dup.replace('br i1 %c0, label %a, label %test1','br i1 %c0, label %a, label %test1, !decision.origin !0').replace('br i1 %c0_second, label %a_second, label %test1_second','br i1 %c0_second, label %a_second, label %test1_second, !decision.origin !0')
 src=d/'duplicate.ll';src.write_text(dup);p=run([r/'build/decision-fuse/decision-greedy',src,'case',root,d/'duplicate']);assert p.returncode!=0 and 'ambiguous decision identity' in p.stderr,p.stderr
 print('outside/inside convergent, independent budgets, pressure/uniform/missing-metric acceptance checks passed')
