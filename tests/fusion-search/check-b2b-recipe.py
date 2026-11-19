#!/usr/bin/env python3
"""Current-parent recipe replay, invalidation, and preservation of unrelated edits."""
import json,os,subprocess,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
search=root/'build/llvm24-tti/fusion-search-llvm24'
worker=root/'tools/run-llvm24-tti'
source='''source_filename = "recipe-test"
target triple = "amdgcn-amd-amdhsa"
define i32 @choose(i1 %p, i32 %x, i32 %y) #0 {
entry:
  br i1 %p, label %left, label %right
left:
  %l = mul i32 %x, 7
  br label %join
right:
  %r = mul i32 %y, 11
  br label %join
join:
  %v = phi i32 [ %l, %left ], [ %r, %right ]
  %answer = add i32 %v, 23
  ret i32 %answer
}
define i32 @unrelated() { ret i32 91 }
attributes #0 = { "target-cpu"="gfx906" }
'''
with tempfile.TemporaryDirectory() as temp:
 out=Path(temp)
 def run(name,text,recipe=None,cache=False):
  ir=out/(name+'.ll');ir.write_text(text)
  cmd=[search,'--ir',ir,'--function','choose','--split','B0','--left','B1','--right','B2','--b2b-strategy','dp1','--tti-worker',worker,'--out',out/(name+'.after.ll'),'--debug-dir',out/name]
  if recipe:cmd+=['--b2b-recipe-cache' if cache else '--b2b-recipe-in',recipe]
  p=subprocess.run(cmd,capture_output=True,text=True)
  return p
 p=run('original',source);assert p.returncode==0,p.stderr
 recipe=out/'original/b2b-recipe.json'
 recipe_data=json.loads(recipe.read_text())
 assert recipe_data['schema']=='b2b-recipe-v4' and recipe_data['planner']=='legacy'
 assert all(layout['label']!='single-branch-binary-common-dp' for layout in recipe_data['layouts'])
 old_recipe=out/'old-recipe.json'
 recipe_data['schema']='b2b-recipe-v3'
 old_recipe.write_text(json.dumps(recipe_data))
 rejected=run('old-schema',source,old_recipe)
 assert rejected.returncode!=0 and 'recipe_certificate_mismatch' in rejected.stderr,rejected.stderr
 for label,text in [('same',source),('other_function',source.replace('ret i32 91','ret i32 102')),
                    ('downstream',source.replace('add i32 %v, 23','add i32 %v, 47')),
                    ('operand',source.replace('mul i32 %x, 7','mul i32 %x, 13'))]:
  fresh=run(label+'-fresh',text);assert fresh.returncode==0,fresh.stderr
  replay=run(label+'-replay',text,recipe);assert replay.returncode==0,replay.stderr
  # Only input ModuleID differs; all instructions, globals and other functions
  # must exactly match a new full planning run on the current module.
  def ir(name):return b'\n'.join(l for l in (out/(name+'.after.ll')).read_bytes().splitlines() if not l.startswith(b'; ModuleID ='))
  assert ir(label+'-fresh')==ir(label+'-replay'),label
  a=json.loads((out/(label+'-fresh')/'b2b-recipe.json').read_text());b=json.loads((out/(label+'-replay')/'b2b-recipe.json').read_text())
  assert a['layouts']==b['layouts'],label
 for label,text in [('equality',source.replace('mul i32 %x, 7','mul i32 %x, 11')),
                    ('flags',source.replace('mul i32 %x','mul nsw i32 %x')),
                    ('shape',source.replace('  %l = mul','  %extra = add i32 %x, 1\n  %l = mul'))]:
  p=run(label,text,recipe)
  assert p.returncode!=0 and 'recipe_dependencies_changed' in p.stderr,(label,p.returncode,p.stderr)
  p=run(label+'-cached',text,recipe,True);assert p.returncode==0,p.stderr
  p=run(label+'-fresh',text);assert p.returncode==0,p.stderr
  assert ir(label+'-cached')==ir(label+'-fresh'),label
  report=json.loads((out/(label+'-cached')/'b2b-recipe-cache.json').read_text())
  assert report['status']=='invalidated' and not report['scores_reused'],report

 print('PASS B2B recipe: exact fresh/replay IR, current-parent edits preserved, equality/flags/shape invalidation')

# Identical planner inputs do not certify identical scores: a preceding store
# changes what EarlyCSE can forward into the selected arms.
context_source = """source_filename = "memory-context"
target triple = "amdgcn-amd-amdhsa"
@A = addrspace(1) global i32 0
@B = addrspace(1) global i32 0
@C = addrspace(1) global i32 0
@D = addrspace(1) global i32 0
define i32 @choose(i1 %p, i32 %x, i32 %y) #0 {
entry:
  store i32 %x, i32 addrspace(1)* @DEST1, align 4
  store i32 %y, i32 addrspace(1)* @DEST2, align 4
  br label %split
split:
  br i1 %p, label %left, label %right
left:
  %l = load i32, i32 addrspace(1)* @A, align 4
  %ll = mul i32 %l, 7
  br label %join
right:
  %r = load i32, i32 addrspace(1)* @B, align 4
  %rr = mul i32 %r, 11
  br label %join
join:
  %v = phi i32 [ %ll, %left ], [ %rr, %right ]
  ret i32 %v
}
attributes #0 = { "target-cpu"="gfx906" }
"""
with tempfile.TemporaryDirectory() as temp:
 out = Path(temp)
 observations = []
 first_recipe = None
 for name, destinations in [('forwarded', ('A','B')), ('unrelated', ('C','D'))]:
  ir = out/(name+'.ll')
  ir.write_text(context_source.replace('DEST1',destinations[0]).replace('DEST2',destinations[1]))
  command = [search,'--ir',ir,'--function','choose','--split','B1','--left','B2','--right','B3',
             '--tti-worker',worker,'--out',out/(name+'.after.ll'),'--debug-dir',out/name]
  subprocess.run(command,check=True,capture_output=True)
  recipe = json.loads((out/name/'b2b-recipe.json').read_text())
  result = json.loads((out/name/'trial-0/trial.json').read_text())['score_result']['metrics']
  observations.append((recipe, result['work_before']-result['work_after']))
  if first_recipe is None:
   first_recipe = out/name/'b2b-recipe.json'
  else:
   command[command.index('--out')+1] = out/'replay.ll'
   command[command.index('--debug-dir')+1] = out/'replay'
   subprocess.run(command+['--b2b-recipe-in',first_recipe],check=True,capture_output=True)
   assert (out/'replay.ll').read_bytes()==(out/(name+'.after.ll')).read_bytes()
   replay_result=json.loads((out/'replay/trial-0/trial.json').read_text())['score_result']['metrics']
   assert replay_result['work_before']-replay_result['work_after']==observations[-1][1]
 assert observations[0][0]['planner_facts']==observations[1][0]['planner_facts']
 assert observations[0][0]['layouts']==observations[1][0]['layouts']
 assert observations[0][1]!=observations[1][1],observations
 print('PASS score invalidation: unchanged plans, upstream memory changes gain; replay scores current IR')
