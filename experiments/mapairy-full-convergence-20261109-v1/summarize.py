from pathlib import Path
import json,re
p=Path(__file__).resolve().parent;g=p/'greedy'
anchors={};cur=None
for l in (p/'steps-final/anchors.txt').read_text().splitlines():
 if l.startswith('L'):cur=l.split()[0];anchors[cur]=[]
 else:anchors[cur].append(l)
trials={}
for f in g.glob('trial-*/trial.json'):
 x=json.loads(f.read_text());trials[x['version'],x['candidate']]=x
nodes={frozenset([k]):k for k in anchors};trace=[]
for f in sorted(g.glob('commit-*.json'),key=lambda x:int(x.stem.split('-')[1])):
 x=json.loads(f.read_text());n=x['parent_version'];t=(g/f'state-{n}.ll').read_text();blocks={};cur=None
 for l in t.splitlines():
  m=re.match(r'^([\w.$-]+):',l)
  if m:cur=m[1];blocks[cur]=''
  elif cur:blocks[cur]+=l+'\n'
 z=trials[n,x['candidate']];groups=[]
 for side in ['left','right']:
  txt='\n'.join(blocks.get(b.lstrip('%'),'') for b in z[side]['blocks']);groups.append(frozenset(k for k,aa in anchors.items() if any(a in txt for a in aa)))
 tree=None
 if all(groups) and not(groups[0]&groups[1]):
  tree='('+nodes.get(groups[0],str(sorted(groups[0])))+','+nodes.get(groups[1],str(sorted(groups[1])))+')';nodes[groups[0]|groups[1]]=tree
 trace.append({'step':n+1,'candidate':x['candidate'],'gain':x['score_result']['static_gain'],'before':x['score_result']['metrics']['work_before'],'after':x['score_result']['metrics']['work_after'],'left':z['left'],'right':z['right'],'left_leaves':sorted(groups[0],key=lambda v:int(v[1:])),'right_leaves':sorted(groups[1],key=lambda v:int(v[1:])),'tree_from_preserved_unique_constants':tree,'merge_path':z['merge_path']})
(p/'trace.json').write_text(json.dumps(trace,indent=2));print(json.dumps(trace,indent=2))
last=max((x['version'] for x in trials.values()),default=0)
remaining=[x for x in trials.values() if x['version']==last];scored=[x for x in remaining if x['score_result']['status']=='scored'];out={'last_round':last,'trial_count':len(remaining),'eligible':sum(x['eligible'] for x in remaining),'max_gain':max((x['score_result']['static_gain'] for x in scored),default=None),'result':json.loads((g/'result.json').read_text())};(p/'convergence.json').write_text(json.dumps(out,indent=2));print(out)
