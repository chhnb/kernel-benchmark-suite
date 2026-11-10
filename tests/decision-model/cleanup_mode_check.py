from pathlib import Path
import tempfile,subprocess,json,os
r=Path(__file__).resolve().parents[2];exe=r/'build/decision-fuse/decision-fuse'
base='''target triple = "x86_64-pc-linux-gnu"
define float @case(float %x, i1 %p) {
entry: br i1 %p, label %a, label %b
a:
 %v = fmul float %x, 0.5
 br label %exit
b:
 %t = fadd float %x, 1.0
 %w = fmul float %t, 0.5
 br label %exit
exit:
 %r = phi float [%v,%a], [%w,%b]
 ret float %r
}
'''
with tempfile.TemporaryDirectory() as td:
 d=Path(td);source=d/'input.ll';source.write_text(base)
 def run(mode,source,label,**extra):
  env={k:v for k,v in os.environ.items() if not k.startswith('DECISION_')};env.update(DECISION_SPECULATION='none',DECISION_CFG_CLEANUP=mode,**extra);dest=d/label
  p=subprocess.run(list(map(str,[exe,source,'case',0,0,dest])),env=env,capture_output=True,text=True)
  t=json.loads((dest/'trial.json').read_text()) if (dest/'trial.json').exists() else {};return p,t,dest
 a,ta,da=run('structural',source,'structural');b,tb,db=run('full',source,'full',DECISION_TTI_WORKER='/bin/false');assert a.returncode==b.returncode==0,(a.stderr,b.stderr,ta,tb)
 assert (da/'meld-raw.ll').read_bytes()==(db/'meld-raw.ll').read_bytes()
 assert (da/'fused.ll').read_text().count('br i1')>(db/'fused.ll').read_text().count('br i1')
 assert tb['cfg_cleanup']=='full' and tb['status']=='verified' and tb['implicit_speculation_metrics_available'] is False
 assert tb['implicit_speculation_metrics_reason']=='implicit_metrics_worker_failed'
 assert any(x['movement']=='conditional_hoist' for x in tb['full_cleanup_moved_instructions'])
 barrier=d/'barrier.ll';barrier.write_text(base.replace('entry: br i1','pre: call void @barrier()\n br label %entry\nentry: br i1')+'declare void @barrier() convergent\n')
 for mode in ['structural','full']:
  p,t,_=run(mode,barrier,'barrier-'+mode);assert (p.returncode==0)==(mode=='structural'),t
  if mode=='full':assert t['reason']=='full_cleanup_function_contains_convergent'
 invalid=d/'unknown.ll';invalid.write_text(base.replace('x86_64-pc-linux-gnu','unknown-unknown-unknown'))
 p,t,_=run('full',invalid,'unknown');assert p.returncode!=0 and 'tti_target_unavailable' in t['reason'],t
 p,t,_=run('full',source,'legacy-conflict',DECISION_DISABLE_SIMPLIFYCFG='1');assert p.returncode==2 and 'conflicts' in p.stderr and not t
 env=dict(os.environ,DECISION_CFG_CLEANUP='full',DECISION_DISABLE_SIMPLIFYCFG='1');p=subprocess.run(list(map(str,[r/'build/decision-fuse/decision-greedy',source,'case',r,d/'greedy-conflict'])),env=env,capture_output=True,text=True);assert p.returncode!=0 and 'conflicts' in p.stderr
 p,t,_=run('bad-option',source,'invalid');assert p.returncode==2 and not t
print('cleanup modes: raw parity, explicit implicit-hoist trace, diagnostic-only failure, convergent and target checks passed')
