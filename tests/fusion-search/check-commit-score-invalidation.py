#!/usr/bin/env python3
"""A real disjoint fusion changes another candidate's cleanup-dependent gain."""
import json,os,re,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
env=os.environ.copy()
env.setdefault('LLVM24_LIBDIR',str(root/'build/llvm24-pinned/lib'))
env['LD_LIBRARY_PATH']=str(root/'build/llvm12-jammy/usr/lib/x86_64-linux-gnu')+':'+env.get('LD_LIBRARY_PATH','')
def block(text,name):
 match=re.search(r'^'+re.escape(name)+r':[^\n]*\n(.*?)(?=^[\w.]+:|^})',text,re.M|re.S)
 assert match,name
 return '\n'.join(line.split(';')[0].strip() for line in match[1].splitlines() if line.split(';')[0].strip())
with tempfile.TemporaryDirectory() as tmp:
 out=Path(tmp);source=out/'before.ll'
 source.write_text((root/'tests/fusion-search/commit-score-context.ll').read_text())
 def run(name,input,labels):
  names=re.findall(r'^([\w.]+):',input.read_text(),re.M)
  ids=['B'+str(names.index(n)) for n in labels]
  cmd=[root/'build/llvm24-tti/fusion-search-llvm24','--ir',input,'--function','choose',
       '--split',ids[0],'--left',ids[1],'--right',ids[2],'--b2b-strategy','anchor',
       '--tti-worker',root/'tools/run-llvm24-tti','--debug-dir',out/name,'--out',out/(name+'.ll')]
  p=subprocess.run(cmd,capture_output=True,text=True,env=env)
  assert p.returncode==0,(name,p.stderr)
  trial=json.loads((out/name/'trial-0/trial.json').read_text())
  assert trial['score_result']['status']=='scored',trial
  return trial['score_result']['static_gain']
 labels=['stage2','left2','right2']
 before=run('second-before',source,labels)
 assert run('first',source,['entry','left1','right1'])>0
 for name in labels+['exit']:
  assert re.sub(r'\s+','',block(source.read_text(),name))==re.sub(r'\s+','',block((out/'first.ll').read_text(),name)),name
 after=run('second-after',out/'first.ll',labels)
 assert (before,after)==(18,21),(before,after)
 print('PASS actual fusion invalidation: unchanged root/arms/exit, gain 18 -> 21 after rescoring current context')
